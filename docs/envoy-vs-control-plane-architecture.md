# Envoy vs Control Plane: Architectural Decision

## The Question

In the original scaffold, we had:
```
Client → Envoy → OPA → MCP Backend
         (with xDS routing tables)
```

In the subscription model, I described:
```
Client → Envoy → Control Plane → MCP Backend
                  (Control Plane proxies the request)
```

**Which is correct for MCP with subscriptions?**

## Option 1: Envoy as Data Plane (Pure xDS)

```
┌─────────┐         ┌─────────┐         ┌─────────┐         ┌─────────┐
│ Client  │────────▶│  Envoy  │────────▶│   OPA   │────────▶│   MCP   │
│         │         │ (Proxy) │         │ (AuthZ) │         │ Backend │
└─────────┘         └────┬────┘         └─────────┘         └─────────┘
                         │
                         │ xDS updates
                         ▼
                  ┌─────────────┐
                  │   Control   │
                  │    Plane    │
                  │ (xDS Server)│
                  └─────────────┘
```

### How It Works

1. **Control Plane generates xDS configuration**:
   - Reads subscriptions from database
   - Generates Envoy clusters for each MCP backend
   - Generates Envoy routes based on tool names
   - Pushes configuration to Envoy via xDS

2. **Envoy handles ALL request routing**:
   - Client sends JSON-RPC request
   - Envoy matches route (tool name → MCP cluster)
   - Envoy calls OPA for authorization
   - Envoy proxies to MCP backend
   - **No Control Plane in request path** (except auth validation)

### Pros ✅
- **Maximum performance**: Envoy is C++, handles 100K+ RPS
- **Battle-tested**: Proven at scale (Lyft, Google, AWS App Mesh)
- **Less Control Plane load**: Control Plane only manages config, not data
- **Standard service mesh**: Works with Istio, Linkerd, Consul
- **Circuit breaking, retry logic**: All built into Envoy

### Cons ❌
- **Complex xDS generation**: Must translate subscriptions → Envoy config
- **Limited request inspection**: Envoy can't deeply parse JSON-RPC
- **Stateful logic challenging**: Rate limiting needs Envoy rate limit filter + external service
- **MCP protocol complexity**: JSON-RPC 2.0 isn't HTTP REST (harder for Envoy to route)

## Option 2: Control Plane as Data Plane (Envoy for TLS/Auth only)

```
┌─────────┐         ┌─────────┐         ┌──────────────┐         ┌─────────┐
│ Client  │────────▶│  Envoy  │────────▶│    Control   │────────▶│   MCP   │
│         │         │ (L4/TLS)│         │     Plane    │         │ Backend │
│         │         │  +Auth  │         │ (App Proxy)  │         │         │
└─────────┘         └─────────┘         └──────┬───────┘         └─────────┘
                                               │
                                               ▼
                                        ┌─────────────┐
                                        │     OPA     │
                                        │   (AuthZ)   │
                                        └─────────────┘
```

### How It Works

1. **Envoy handles**:
   - TLS termination
   - Client authentication (ext_authz filter)
   - Load balancing to Control Plane instances
   - Metrics/tracing

2. **Control Plane handles**:
   - JSON-RPC parsing
   - Subscription resolution
   - Tool routing
   - Rate limiting (Redis)
   - Quota checking (PostgreSQL)
   - OPA policy evaluation
   - Proxying to MCP backend

### Pros ✅
- **Deep protocol inspection**: Control Plane understands JSON-RPC/MCP fully
- **Flexible business logic**: Subscription resolution, rate limiting, quotas in Go
- **Easier debugging**: Application-level code is easier to debug than Envoy config
- **Rapid iteration**: Change routing logic without xDS complexity
- **Better for MCP**: MCP is stateful (sessions), Control Plane manages this better

### Cons ❌
- **Lower throughput**: Go (Control Plane) vs C++ (Envoy)
- **More Control Plane instances needed**: Must scale horizontally
- **Less battle-tested**: Custom proxy code vs Envoy's proven stack
- **Manual implementation**: Rate limiting, circuit breaking, retries in Go

## Recommended Hybrid Architecture

**Use BOTH: Envoy for L4/L7 capabilities + Control Plane for MCP intelligence**

```
┌─────────────────────────────────────────────────────────────────┐
│                         Request Flow                             │
└─────────────────────────────────────────────────────────────────┘

Client
  │
  │ 1. HTTPS Request (JSON-RPC 2.0)
  ▼
┌─────────────────────────────────────────────────────────────────┐
│  Envoy Proxy (Layer 4/7)                                        │
├─────────────────────────────────────────────────────────────────┤
│  ✅ TLS Termination                                             │
│  ✅ Client Authentication (ext_authz → Control Plane)           │
│  ✅ Load Balancing (to Control Plane instances)                 │
│  ✅ Connection Pooling                                           │
│  ✅ HTTP/2, gRPC support                                         │
│  ✅ Access Logging, Metrics (Prometheus), Tracing (Jaeger)      │
│  ✅ Circuit Breaking (to Control Plane)                          │
│  ❌ NO MCP-specific routing (delegates to Control Plane)        │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           │ 2. Validated request
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  Control Plane (Layer 7 - Application Intelligence)            │
├─────────────────────────────────────────────────────────────────┤
│  ✅ JSON-RPC 2.0 Parsing                                        │
│  ✅ MCP Session Management (initialize, tools/list, tools/call) │
│  ✅ Subscription Resolution (tool name → MCP backend)           │
│  ✅ Rate Limiting (Redis)                                        │
│  ✅ Quota Checking (PostgreSQL)                                  │
│  ✅ OPA Policy Evaluation (parameter validation, compliance)    │
│  ✅ Tool Routing (proxy to correct MCP backend)                 │
│  ✅ Usage Tracking (billing, analytics)                          │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           │ 3. Routed request (with MCP auth)
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  MCP Backend (e.g., GitHub MCP Server)                          │
├─────────────────────────────────────────────────────────────────┤
│  ✅ Tool Execution                                              │
│  ✅ Returns JSON-RPC response                                   │
└─────────────────────────────────────────────────────────────────┘
```

### Division of Responsibilities

| Layer | Component | Responsibility |
|-------|-----------|----------------|
| **L4/L7** | Envoy | TLS, auth, load balancing, observability |
| **L7 App** | Control Plane | MCP protocol, subscriptions, rate limits, routing |
| **Policy** | OPA | Authorization, compliance, parameter validation |
| **State** | Redis | Rate limiting counters, session state |
| **Persistence** | PostgreSQL | Subscriptions, usage, clients, MCPs |

## Why This Hybrid is Best for MCP

### 1. MCP Protocol Complexity

**MCP is NOT simple HTTP REST:**
- Stateful sessions (initialize → initialized → tools/call)
- JSON-RPC 2.0 with request IDs
- Bidirectional notifications (server → client)
- Multiple transport protocols (STDIO, HTTP, SSE)

**Envoy alone can't handle this**. You need application-level logic.

### 2. Subscription Resolution Requires Business Logic

```
Tool name "github__list_repos"
  → Query DB: Which subscription grants access?
  → Check rate limit (Redis)
  → Check quota (PostgreSQL)
  → Evaluate OPA policy
  → Route to correct MCP backend
```

This is **too complex for xDS routing tables**. It needs Go code.

### 3. Dynamic MCP Backends

MCPs are not static services:
- MCP servers can be added/removed dynamically
- STDIO MCPs are spawned on-demand (process lifecycle)
- HTTP MCPs may be behind load balancers
- OAuth tokens need refreshing

**Control Plane manages this lifecycle**, Envoy just load balances to Control Plane.

### 4. Performance is Still Excellent

```
Client → Envoy (C++, <1ms) → Control Plane (Go, 2-5ms) → MCP
         ────────────────────────────────────────────────
                    Total latency: 3-6ms
```

For MCP use cases (AI agents calling tools), **3-6ms is negligible** compared to:
- LLM inference: 500ms - 5s
- Tool execution time: 100ms - 10s

## What About xDS?

**We still use xDS, but for infrastructure, not MCP routing:**

### xDS Configuration (Simplified)

```yaml
# Control Plane generates this xDS config for Envoy
static_resources:
  listeners:
  - name: mcp_listener
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 8080
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          route_config:
            name: local_route
            virtual_hosts:
            - name: mcp_gateway
              domains: ["*"]
              routes:
              # ALL MCP requests go to Control Plane
              - match:
                  prefix: "/mcp/v1/"
                route:
                  cluster: control_plane
                  timeout: 30s
          http_filters:
          # 1. External Auth (validate client API key/JWT)
          - name: envoy.filters.http.ext_authz
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.ext_authz.v3.ExtAuthz
              grpc_service:
                envoy_grpc:
                  cluster_name: control_plane_auth
                timeout: 1s
          # 2. Rate limiting (DDoS protection, per-client limits)
          - name: envoy.filters.http.ratelimit
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.ratelimit.v3.RateLimit
              domain: mcp_gateway
              rate_limit_service:
                grpc_service:
                  envoy_grpc:
                    cluster_name: redis_ratelimit
          # 3. Router (final filter)
          - name: envoy.filters.http.router

  clusters:
  # Control Plane cluster (handles ALL MCP routing)
  - name: control_plane
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: control_plane
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: control-plane
                port_value: 8081
    health_checks:
    - timeout: 1s
      interval: 5s
      http_health_check:
        path: /health
    circuit_breakers:
      thresholds:
      - max_connections: 1000
        max_requests: 1000
  
  # Auth service (validates client credentials)
  - name: control_plane_auth
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: control_plane_auth
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: control-plane
                port_value: 8082  # Separate port for auth
```

**Key Point**: Envoy's routing config is **simple** - it just sends everything to Control Plane. No per-tool routing, no subscription logic.

### When Control Plane Updates xDS

```go
// packages/core/control-plane/internal/xds/server.go

// Control Plane acts as xDS server for Envoy
func (s *XDSServer) GenerateSnapshot() *cache.Snapshot {
    // Generate Envoy config based on current state
    
    listeners := s.generateListeners()
    clusters := s.generateClusters()
    routes := s.generateRoutes()
    
    // Create snapshot
    snapshot := cache.NewSnapshot(
        s.version,
        []types.Resource{}, // endpoints
        clusters,
        routes,
        listeners,
        []types.Resource{}, // runtimes
        []types.Resource{}, // secrets
    )
    
    return snapshot
}

func (s *XDSServer) generateClusters() []types.Resource {
    clusters := []types.Resource{
        // Control Plane cluster (static)
        &cluster.Cluster{
            Name: "control_plane",
            ClusterDiscoveryType: &cluster.Cluster_Type{Type: cluster.Cluster_STRICT_DNS},
            LoadAssignment: &endpoint.ClusterLoadAssignment{
                ClusterName: "control_plane",
                Endpoints: s.getControlPlaneEndpoints(), // From service discovery
            },
        },
    }
    
    // We DON'T add MCP backend clusters here anymore
    // Control Plane manages those connections directly
    
    return clusters
}

// When subscriptions change, we DON'T need to update Envoy
// Only Control Plane's internal routing changes
func (s *XDSServer) OnSubscriptionCreated(sub *Subscription) {
    // No xDS update needed!
    // Control Plane will handle routing internally
}
```

## Updated Request Flow (Complete)

```
┌──────────────────────────────────────────────────────────────────┐
│  Step 1: Client Request                                          │
└──────────────────────────────────────────────────────────────────┘

POST https://gateway.giru.ai/mcp/v1/session
Authorization: Bearer giru_sk_prod_...

{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "tools/call",
  "params": {
    "name": "github__list_repos",
    "arguments": { "owner": "anthropics" }
  }
}

        │
        ▼

┌──────────────────────────────────────────────────────────────────┐
│  Step 2: Envoy - TLS Termination                                 │
└──────────────────────────────────────────────────────────────────┘

Envoy:
  - Accepts TLS connection
  - Parses HTTP/2 request
  - Extracts Authorization header

        │
        ▼

┌──────────────────────────────────────────────────────────────────┐
│  Step 3: Envoy - External Auth Filter                            │
└──────────────────────────────────────────────────────────────────┘

Envoy → Control Plane:
  POST /auth/check (gRPC)
  {
    "headers": {"authorization": "Bearer giru_sk_prod_..."},
    "path": "/mcp/v1/session"
  }

Control Plane → Envoy:
  {
    "allowed": true,
    "headers": {
      "x-client-id": "client-123",
      "x-tenant-id": "tenant-abc",
      "x-environment-id": "env-prod"
    }
  }

        │
        ▼

┌──────────────────────────────────────────────────────────────────┐
│  Step 4: Envoy - Route to Control Plane                          │
└──────────────────────────────────────────────────────────────────┘

Envoy:
  - Adds injected headers (x-client-id, x-tenant-id)
  - Routes to control_plane cluster
  - Load balances across Control Plane instances

        │
        ▼

┌──────────────────────────────────────────────────────────────────┐
│  Step 5: Control Plane - MCP Protocol Handler                    │
└──────────────────────────────────────────────────────────────────┘

Control Plane (Go):
  // Parse JSON-RPC
  clientID := c.Get("x-client-id")
  environmentID := c.Get("x-environment-id")
  
  var req JSONRPCRequest
  json.Unmarshal(body, &req)
  
  toolName := req.Params["name"] // "github__list_repos"

        │
        ▼

┌──────────────────────────────────────────────────────────────────┐
│  Step 6: Subscription Resolution                                 │
└──────────────────────────────────────────────────────────────────┘

Control Plane → PostgreSQL:
  SELECT resolve_tool_subscription(
    'client-123', 
    'github__list_repos', 
    'env-prod'
  )
  
  Returns:
    subscription_id: sub-789
    mcp_server_id: mcp-456
    mcp_endpoint: https://github-mcp.internal:8080
    rate_limit_rps: 10
    quota_per_day: 1000

        │
        ▼

┌──────────────────────────────────────────────────────────────────┐
│  Step 7: Rate Limit Check                                        │
└──────────────────────────────────────────────────────────────────┘

Control Plane → Redis:
  INCR ratelimit:sub:sub-789:1736960400  // Unix timestamp
  EXPIRE ratelimit:sub:sub-789:1736960400 2
  
  If count > 10: REJECT (429 Too Many Requests)

        │
        ▼

┌──────────────────────────────────────────────────────────────────┐
│  Step 8: Quota Check                                             │
└──────────────────────────────────────────────────────────────────┘

Control Plane → PostgreSQL:
  SELECT COUNT(*) FROM subscription_usage
  WHERE subscription_id = 'sub-789'
    AND DATE(timestamp) = CURRENT_DATE
  
  If count >= 1000: REJECT (429 Quota Exceeded)

        │
        ▼

┌──────────────────────────────────────────────────────────────────┐
│  Step 9: OPA Policy Evaluation                                   │
└──────────────────────────────────────────────────────────────────┘

Control Plane → OPA:
  POST /v1/data/giru/subscriptions/allow
  {
    "input": {
      "subscription": { "status": "active", "constraints": {...} },
      "tool": { "name": "github__list_repos", "category": "data" },
      "arguments": { "owner": "anthropics" },
      "environment": { "name": "prod" }
    }
  }
  
  OPA evaluates:
    - Subscription active? ✅
    - Temporal valid? ✅
    - Parameter constraints met? ✅
    - PII filtering? ✅
    - Tool allowed in prod? ✅
  
  Returns: { "result": true }

        │
        ▼

┌──────────────────────────────────────────────────────────────────┐
│  Step 10: Route to MCP Backend                                   │
└──────────────────────────────────────────────────────────────────┘

Control Plane → MCP Backend:
  POST https://github-mcp.internal:8080
  Authorization: Bearer <mcp_oauth_token>
  
  {
    "jsonrpc": "2.0",
    "id": 3,
    "method": "tools/call",
    "params": {
      "name": "github__list_repos",
      "arguments": { "owner": "anthropics" }
    }
  }

        │
        ▼

┌──────────────────────────────────────────────────────────────────┐
│  Step 11: MCP Backend Executes Tool                              │
└──────────────────────────────────────────────────────────────────┘

GitHub MCP Server:
  - Validates OAuth token
  - Calls GitHub API
  - Returns JSON-RPC response

        │
        ▼

┌──────────────────────────────────────────────────────────────────┐
│  Step 12: Record Usage                                           │
└──────────────────────────────────────────────────────────────────┘

Control Plane → PostgreSQL:
  INSERT INTO subscription_usage (
    subscription_id, tool_name, duration_ms, status_code
  ) VALUES (
    'sub-789', 'github__list_repos', 243, 200
  )

        │
        ▼

┌──────────────────────────────────────────────────────────────────┐
│  Step 13: Return to Client                                       │
└──────────────────────────────────────────────────────────────────┘

Control Plane → Envoy → Client:
  {
    "jsonrpc": "2.0",
    "id": 3,
    "result": {
      "content": [
        { "type": "text", "text": "Found 42 repositories" }
      ]
    }
  }
```

## Summary: Envoy's Role in Subscription Model

| What Envoy Does | What Control Plane Does |
|-----------------|-------------------------|
| ✅ TLS termination | ✅ JSON-RPC parsing |
| ✅ Client authentication (ext_authz) | ✅ MCP session management |
| ✅ Load balancing to Control Plane | ✅ Subscription resolution |
| ✅ HTTP/2, gRPC support | ✅ Rate limiting (Redis) |
| ✅ Access logs, metrics, tracing | ✅ Quota checking (PostgreSQL) |
| ✅ Circuit breaking | ✅ OPA policy evaluation |
| ✅ DDoS protection (rate limiting) | ✅ Tool routing |
| ❌ MCP protocol awareness | ✅ Usage tracking |
| ❌ Subscription resolution | ✅ MCP backend connection pooling |
| ❌ Tool-level routing | ✅ OAuth token management |

## Conclusion

**We are NOT moving away from Envoy**. Envoy still plays a critical role:
- TLS, authentication, load balancing, observability
- Battle-tested performance and reliability
- Standard service mesh integration

**BUT**: MCP protocol complexity + subscription intelligence requires Control Plane to be in the data path.

This is the **correct architecture** for an MCP gateway with subscriptions. It's similar to how **API gateways** like Kong, Tyk, and AWS API Gateway work: edge proxy (Envoy/nginx) + application logic (Go/Node/Java).
