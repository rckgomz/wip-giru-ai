# Giru MCP Gateway - Project Scaffolding Instructions

This file contains comprehensive instructions for Claude Code to scaffold the Giru MCP Gateway project. This is an infrastructure-grade, production-ready gateway for Model Context Protocol (MCP) servers, designed for Fortune 500 enterprises.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Business Model](#business-model-managed-saas--open-source)
3. [Core Concepts](#core-concepts)
4. [Request Flow Architecture](#request-flow-architecture)
5. [Technical Decisions and Rationale](#technical-decisions-and-rationale)
6. [Directory Structure](#directory-structure-to-create)
7. [Web UI Strategy](#web-ui-strategy)
8. [Database Strategy](#database-strategy)
9. [Policy Data Management](#policy-data-management)
10. [Authentication & Credential Management](#authentication--credential-management)
11. [Compliance Policy Code](#compliance-policy-code)
12. [Key Implementation Requirements](#key-implementation-requirements)
13. [Development Environment](#development-environment-configurations)
14. [CI/CD and Deployment](#cicd-pipelines)
15. [Implementation Priorities](#initial-implementation-priority)
16. [Post-MVP Roadmap](#post-mvp-roadmap)
17. [Success Metrics](#success-metrics)
18. [AI-First Development](#ai-first-development)
19. [Final Notes for Claude Code](#final-notes-for-claude-code)

---

## Quick Reference: Where to Start

Use this table to find the right entry point for common tasks.

| Task Type | Entry Point | Key Files |
|-----------|-------------|-----------|
| New API endpoint | `internal/api/rest/handlers/` | `routes.go`, create handler file |
| Database change | `db/migrations/` | Create migration → `db/queries/` → `make sqlc-generate` |
| New OPA policy | `policies/<domain>/` | Policy `.rego` file → test in `policies/tests/` |
| UI feature | `web-ui/src/routes/` | Route folder → component → `$lib/stores/` |
| New MCP transport | `internal/mcp/` | `transport_<type>.go` implementation |
| Proxy configuration | `internal/proxy/envoy/` | xDS configuration files |
| Add compliance rule | `policies/compliance/<framework>/` | Rego policy → JSON data → tests |
| New CLI command | `cmd/giru/` | Command file → register in root |

### File Naming Conventions

```
internal/api/rest/handlers/subscriptions.go  # REST handler (plural noun)
db/queries/subscriptions.sql                  # sqlc queries (plural noun)
db/migrations/00004_add_quotas.sql           # Migration (numbered, snake_case)
policies/compliance/hipaa/minimum_necessary.rego  # Policy (snake_case)
web-ui/src/routes/subscriptions/+page.svelte # Svelte route (plural noun)
```

---

## Project Overview

**Giru** (giru.ai) is "Kubernetes for MCP" - providing the infrastructure layer that makes MCP servers production-ready for enterprises. Think of it as the three-layer architecture:

1. **Layer 1: Envoy Proxy** - Performance foundation (C++ core)
2. **Layer 2: OPA Policy Engine** - Governance brain (Rego policies)
3. **Layer 3: Control Plane** - Orchestration layer (Go + TypeScript)

---

## Business Model: Managed SaaS + Open Source

**Primary Strategy**: Managed multi-tenant SaaS (like Datadog, Auth0, Stripe)
**Secondary**: Open-source community edition for self-hosters

### Repository Strategy

| Repository | License | Purpose |
|------------|---------|---------|
| `github.com/giru-ai/giru` | Apache 2.0 | Open Source Community Edition |
| `github.com/giru-ai/giru-enterprise` | Proprietary | Enterprise features + Managed SaaS backend |
| `github.com/giru-ai/giru-common` | Apache 2.0 | Shared libraries, API contracts, protocol buffers |

**Repository Details:**

1. **Open Source (Community Edition)**: `github.com/giru-ai/giru` (Apache 2.0)
   - Core MCP gateway functionality
   - Self-hosted deployment only
   - Community-driven development
   - Production-ready for developers/startups
   - Path to CNCF Sandbox → Incubation → Graduation

2. **Enterprise Edition**: `github.com/giru-ai/giru-enterprise` (Private, Proprietary)
   - Enterprise self-hosted features (SSO, multi-tenancy, compliance)
   - Managed SaaS control plane (multi-tenant, billing, metering)
   - Advanced compliance features (HIPAA/PCI-DSS blueprints)
   - Tenant isolation and resource management
   - SLA monitoring and guarantees

3. **Shared Libraries**: `github.com/giru-ai/giru-common` (Apache 2.0)
   - Common data models and utilities
   - API contracts and protocol buffers
   - Compliance policy library (shared with community)

**Why This Model?**
- Better margins: 85% gross margin (SaaS) vs 60% (enterprise licenses)
- Faster growth: Product-led growth via free community edition
- Lower CAC: Self-service signup, no sales team for small customers
- Community trust: Core gateway is fully open source
- Proven model: Auth0 ($6.5B), Kong ($1.5B), Hasura ($100M ARR)

### Revenue Streams

**Primary: Managed SaaS (giru.ai)**
| Tier | Price | Limits |
|------|-------|--------|
| Starter | $99/mo | 10 MCP servers, 100K requests/mo |
| Professional | $499/mo | 50 servers, 1M requests/mo, SSO |
| Business | $1,999/mo | 200 servers, 10M requests/mo, HIPAA/PCI-DSS |
| Enterprise | Custom | Dedicated instances, 99.99% SLA, 24/7 support |

**Secondary: Community Edition (Self-Hosted)**
- Free forever (Apache 2.0 license)
- GitHub Discussions support
- Upgrade CTA to managed SaaS

**Target Markets**:
- **Primary**: Mid-market SaaS companies ($10M-$100M ARR)
- **Secondary**: Healthcare providers, financial services, Fortune 500

**Revenue Targets**:
| Year | ARR | Customers |
|------|-----|-----------|
| 2026 | $180K | 50 Starter, 10 Professional |
| 2027 | $2M | 500 customers, expand to Business tier |
| 2028 | $8M | 1,200 customers, 20 Enterprise |
| 2030 | $50M | 5,000 customers, dominant market position |

---

## Core Concepts

This section explains the fundamental concepts you need to understand before diving into implementation.

### What is MCP?

**Model Context Protocol (MCP)** is a standard protocol for AI agents to interact with external tools and data sources. Think of it as "USB for AI" - a universal connector.

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│   AI Agent      │  MCP    │   MCP Server    │         │  External       │
│  (Claude, GPT)  │◄───────►│  (Tool Provider)│◄───────►│  Service        │
│                 │ JSON-RPC│                 │   API   │  (GitHub, etc)  │
└─────────────────┘         └─────────────────┘         └─────────────────┘
```

**MCP uses JSON-RPC 2.0** as its wire protocol. Key operations:
- `initialize` - Establish session, exchange capabilities
- `tools/list` - Discover available tools
- `tools/call` - Execute a tool with arguments
- `resources/list` - List available data resources
- `resources/read` - Read a specific resource

### Why Giru? The Problem We Solve

**Without Giru** (Direct MCP):
```
┌─────────────┐     ┌─────────────┐
│  AI Agent   │────►│ GitHub MCP  │  Each agent manages its own
│             │────►│ Slack MCP   │  connections, auth, rate limits
│             │────►│ DB MCP      │  No centralized control
└─────────────┘     └─────────────┘
```

**With Giru** (Managed Gateway):
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  AI Agent   │────►│    Giru     │────►│ GitHub MCP  │
│  (single    │     │   Gateway   │────►│ Slack MCP   │
│  connection)│     │             │────►│ DB MCP      │
└─────────────┘     └─────────────┘     └─────────────┘
                          │
                    ┌─────┴─────┐
                    │ Features: │
                    │ • Auth    │
                    │ • Routing │
                    │ • Limits  │
                    │ • Audit   │
                    │ • Comply  │
                    └───────────┘
```

### The Three-Layer Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                     Layer 3: Control Plane                      │
│  • Go + Fiber HTTP framework                                   │
│  • xDS server for dynamic Envoy config                         │
│  • REST API for management                                     │
│  • PostgreSQL for persistence, Redis for caching               │
│  • Svelte UI for administration                                │
└────────────────────────────────────────────────────────────────┘
                              │
                              │ xDS (dynamic config)
                              ▼
┌────────────────────────────────────────────────────────────────┐
│                     Layer 2: OPA Policy Engine                  │
│  • Rego policy language                                        │
│  • Stateless authorization decisions                           │
│  • Compliance policies (HIPAA, PCI-DSS, SOC2)                  │
│  • Parameter validation, PII filtering                         │
└────────────────────────────────────────────────────────────────┘
                              │
                              │ External Authorization
                              ▼
┌────────────────────────────────────────────────────────────────┐
│                     Layer 1: Envoy Proxy                        │
│  • High-performance C++ proxy (3-10x faster than Go)           │
│  • TLS termination, rate limiting, circuit breaking            │
│  • Prometheus metrics, distributed tracing                     │
│  • Routes requests to MCP backends                             │
└────────────────────────────────────────────────────────────────┘
```

### Core Data Entities

Understanding these entities is critical before looking at code:

```
┌─────────────────────────────────────────────────────────────────┐
│                         TENANT                                   │
│  An organization using Giru (company, team, project)            │
│  Example: "Acme Corp"                                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────────┐         ┌───────────────┐                   │
│  │    CLIENT     │         │  MCP SERVER   │                   │
│  │ (AI Agent)    │         │ (Tool Source) │                   │
│  │               │         │               │                   │
│  │ • API key     │         │ • Endpoint    │                   │
│  │ • Rate limit  │         │ • Auth config │                   │
│  │ • Type: agent │         │ • Transport   │                   │
│  └───────┬───────┘         └───────┬───────┘                   │
│          │                         │                            │
│          │    ┌─────────────┐      │                            │
│          └───►│SUBSCRIPTION │◄─────┘                            │
│               │ (Access)    │                                   │
│               │             │                                   │
│               │ • Scope     │                                   │
│               │ • Limits    │                                   │
│               │ • Expires   │                                   │
│               └──────┬──────┘                                   │
│                      │                                          │
│                      ▼                                          │
│               ┌─────────────┐                                   │
│               │  MCP TOOL   │                                   │
│               │             │                                   │
│               │ • Name      │                                   │
│               │ • Schema    │                                   │
│               │ • Category  │                                   │
│               └─────────────┘                                   │
└─────────────────────────────────────────────────────────────────┘
```

**Entity Definitions:**

| Entity | Description | Example |
|--------|-------------|---------|
| **Tenant** | Organization/company using Giru | "Acme Corp", "startup-xyz" |
| **Client** | AI agent or app consuming tools | "sales-bot", "support-agent" |
| **MCP Server** | Backend providing MCP tools | GitHub MCP, Slack MCP |
| **MCP Tool** | Individual capability from a server | `github__list_repos`, `slack__send_message` |
| **Subscription** | Access grant: Client → MCP Server | "sales-bot can use GitHub MCP" |
| **Environment** | Deployment context | dev, staging, production |

### MCP JSON-RPC Protocol Details

Giru implements the **Model Context Protocol (MCP)** as defined in the [MCP specification](https://spec.modelcontextprotocol.io/).

#### Transport Support

| Transport | Status | Use Case |
|-----------|--------|----------|
| **STDIO** | Supported | Local MCP servers (process spawning) |
| **HTTP** | Supported | Remote MCP servers (recommended for production) |
| **SSE** | Legacy | Deprecated in MCP spec, not recommended |

#### Session Lifecycle

```
1. Client → Giru: Initialize session
   ┌──────────────────────────────────────────────────────────┐
   │ {                                                        │
   │   "jsonrpc": "2.0",                                      │
   │   "id": 1,                                               │
   │   "method": "initialize",                                │
   │   "params": {                                            │
   │     "protocolVersion": "2024-11-05",                     │
   │     "capabilities": { "sampling": {} },                  │
   │     "clientInfo": { "name": "sales-agent", "version": "1.0" }
   │   }                                                      │
   │ }                                                        │
   └──────────────────────────────────────────────────────────┘

2. Giru → Client: Server capabilities
   ┌──────────────────────────────────────────────────────────┐
   │ {                                                        │
   │   "jsonrpc": "2.0",                                      │
   │   "id": 1,                                               │
   │   "result": {                                            │
   │     "protocolVersion": "2024-11-05",                     │
   │     "capabilities": { "tools": {} },                     │
   │     "serverInfo": { "name": "giru-gateway", "version": "1.0" }
   │   }                                                      │
   │ }                                                        │
   └──────────────────────────────────────────────────────────┘

3. Client → Giru: Initialized notification
   { "jsonrpc": "2.0", "method": "initialized" }

4. Ready for tool calls!
```

#### Tool Discovery

```
Client → Giru: List available tools
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/list"
}

Giru → Client: Aggregated tools from ALL subscribed MCPs
{
  "jsonrpc": "2.0",
  "id": 2,
  "result": {
    "tools": [
      {
        "name": "github__list_repos",
        "description": "List GitHub repositories",
        "inputSchema": {
          "type": "object",
          "properties": {
            "owner": { "type": "string" }
          },
          "required": ["owner"]
        }
      },
      {
        "name": "slack__send_message",
        "description": "Send a Slack message",
        "inputSchema": { ... }
      }
    ]
  }
}
```

#### Tool Execution

```
Client → Giru: Call a tool
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "tools/call",
  "params": {
    "name": "github__list_repos",
    "arguments": { "owner": "anthropics" }
  }
}

Giru → Client: Tool result
{
  "jsonrpc": "2.0",
  "id": 3,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "Found 42 repositories for anthropics"
      }
    ],
    "isError": false
  }
}
```

---

## Request Flow Architecture

This section shows exactly what happens when a request flows through Giru.

### Complete Request Flow

```
┌─────────────┐          ┌─────────────┐          ┌─────────────┐          ┌─────────────┐
│   Client    │          │   Envoy     │          │  Control    │          │ MCP Server  │
│  (AI Agent) │          │   Proxy     │          │   Plane     │          │  (GitHub)   │
└──────┬──────┘          └──────┬──────┘          └──────┬──────┘          └──────┬──────┘
       │                        │                        │                        │
       │ 1. tools/call          │                        │                        │
       │   Authorization: Bearer│xxx                     │                        │
       ├───────────────────────►│                        │                        │
       │                        │                        │                        │
       │                        │ 2. ext_authz           │                        │
       │                        │   (validate token)     │                        │
       │                        ├───────────────────────►│                        │
       │                        │                        │                        │
       │                        │                        │ 3. Authenticate        │
       │                        │                        │    (lookup API key)    │
       │                        │                        │                        │
       │                        │                        │ 4. Resolve subscription │
       │                        │                        │    (client → tool → MCP)│
       │                        │                        │                        │
       │                        │                        │ 5. Check rate limit    │
       │                        │                        │    (Redis counter)     │
       │                        │                        │                        │
       │                        │                        │ 6. Check quota         │
       │                        │                        │    (PostgreSQL)        │
       │                        │                        │                        │
       │                        │                        │ 7. Evaluate OPA policy │
       │                        │                        │    (compliance check)  │
       │                        │                        │                        │
       │                        │ 8. authz OK + headers  │                        │
       │                        │◄───────────────────────┤                        │
       │                        │                        │                        │
       │                        │ 9. Route to MCP backend│                        │
       │                        ├────────────────────────┼───────────────────────►│
       │                        │                        │                        │
       │                        │ 10. MCP Response       │                        │
       │                        │◄───────────────────────┼────────────────────────┤
       │                        │                        │                        │
       │                        │                        │ 11. Record usage       │
       │                        │                        │     (async)            │
       │                        │                        │                        │
       │ 12. Return result      │                        │                        │
       │◄───────────────────────┤                        │                        │
       │                        │                        │                        │
```

### Step-by-Step Breakdown

**Step 1-2: Client Request & Initial Routing**
```http
POST /mcp/v1/session HTTP/1.1
Host: gateway.giru.ai
Authorization: Bearer giru_client_abc123xyz
Content-Type: application/json

{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "tools/call",
  "params": {
    "name": "github__list_repos",
    "arguments": { "owner": "anthropics" }
  }
}
```

**Step 3: Authentication**
```go
// Control Plane validates the API key
func (h *AuthMiddleware) Authenticate(c *fiber.Ctx) error {
    token := c.Get("Authorization")
    apiKey := strings.TrimPrefix(token, "Bearer ")
    
    // Hash and lookup
    keyHash := sha256.Sum256([]byte(apiKey))
    client, err := h.db.GetClientByAPIKeyHash(ctx, hex.EncodeToString(keyHash[:]))
    if err != nil {
        return fiber.NewError(401, "Invalid API key")
    }
    
    c.Locals("client_id", client.ID)
    c.Locals("tenant_id", client.TenantID)
    return c.Next()
}
```

**Step 4: Subscription Resolution**
```sql
-- Find which MCP server provides this tool for this client
SELECT 
    s.id AS subscription_id,
    m.id AS mcp_server_id,
    m.endpoint_url,
    m.auth_config,
    s.rate_limit_rps,
    s.quota_per_day
FROM subscriptions s
JOIN mcp_servers m ON s.mcp_server_id = m.id
JOIN mcp_tools t ON t.mcp_server_id = m.id
WHERE s.client_id = $1           -- This client
  AND t.name = $2                -- Wants this tool
  AND s.status = 'active'        -- Active subscription
  AND (s.scope_type = 'all' OR $2 = ANY(s.scope_tools))
ORDER BY s.created_at DESC
LIMIT 1;
```

**Step 5-6: Rate Limiting & Quotas**

| Check | Technology | Why |
|-------|------------|-----|
| Rate Limit (req/sec) | Redis | Microsecond latency for counters |
| Daily/Monthly Quota | PostgreSQL | Durable, transactional |
| OPA Policies | OPA | Stateless policy decisions |

```go
// Rate limiting with Redis sliding window
func (r *RateLimiter) Check(subscriptionID string, limit int) bool {
    key := fmt.Sprintf("ratelimit:%s", subscriptionID)
    now := time.Now().UnixMilli()
    
    // Remove old entries (outside 1-second window)
    r.redis.ZRemRangeByScore(ctx, key, "0", fmt.Sprintf("%d", now-1000))
    
    // Count current requests
    count := r.redis.ZCard(ctx, key).Val()
    if count >= int64(limit) {
        return false // Rate limit exceeded
    }
    
    // Add this request
    r.redis.ZAdd(ctx, key, &redis.Z{Score: float64(now), Member: ulid.Make().String()})
    r.redis.Expire(ctx, key, 2*time.Second)
    return true
}
```

**Step 7: OPA Policy Evaluation**

OPA handles **stateless** policy decisions:
- Authorization (can this client access this tool?)
- Parameter validation (are the arguments valid?)
- Compliance checks (does this violate HIPAA/PCI-DSS?)

```rego
# OPA policy for subscription validation
package giru.subscriptions

default allow = false

allow {
    subscription_active
    within_time_window
    parameters_valid
}

subscription_active {
    input.subscription.status == "active"
}

within_time_window {
    now := time.now_ns()
    input.subscription.starts_at <= now
    input.subscription.expires_at >= now
}

parameters_valid {
    # Check file size constraints
    not input.subscription.constraints.max_file_size
    OR input.arguments.file_size <= input.subscription.constraints.max_file_size
}
```

**Step 8-10: Route to MCP Backend**
```go
func (h *MCPHandler) RouteToBackend(ctx context.Context, server *MCPServer, req *JSONRPCRequest) (*JSONRPCResponse, error) {
    // Get credentials from Vault
    creds, err := h.vault.GetOAuthToken(ctx, server.VaultSecretPath)
    if err != nil {
        return nil, fmt.Errorf("credential retrieval failed: %w", err)
    }
    
    // Call MCP backend based on transport type
    switch server.Transport {
    case "stdio":
        return h.callSTDIO(ctx, server, req, creds)
    case "http":
        return h.callHTTP(ctx, server, req, creds)
    default:
        return nil, fmt.Errorf("unsupported transport: %s", server.Transport)
    }
}
```

**Step 11: Usage Recording (Async)**
```go
// Fire-and-forget usage recording
go func() {
    h.db.RecordUsage(context.Background(), &UsageRecord{
        SubscriptionID: sub.ID,
        ToolName:       toolName,
        DurationMs:     duration.Milliseconds(),
        StatusCode:     200,
        Timestamp:      time.Now(),
    })
}()
```

### Tool Name Collision Handling

When multiple MCPs provide the same tool name:

```json
// Option 1: Auto-resolve (first active subscription wins)
{
  "method": "tools/call",
  "params": {
    "name": "github__list_repos",
    "arguments": { "owner": "anthropics" }
  }
}

// Option 2: Explicit MCP selection
{
  "method": "tools/call",
  "params": {
    "name": "github__list_repos",
    "arguments": { "owner": "anthropics" },
    "_giru": {
      "prefer_mcp": "github-enterprise-mcp"
    }
  }
}
```

---

## Technical Decisions and Rationale

### Why Envoy? (Default Proxy Provider)
- Battle-tested at Netflix, Lyft, AWS
- 3-10x faster than Go stdlib HTTP
- Dynamic configuration via xDS protocol
- Service mesh compatibility (Istio)
- Industry standard for API gateways
- **Envoy AI Gateway**: Native MCP support coming (Oct 2025), allows Giru to offload protocol handling
- **Note**: Envoy is the default; Enterprise supports Kong, NGINX (see Provider Abstraction Architecture)

### Why OPA? (Default Policy Engine)
- CNCF graduated project (trusted)
- Declarative Rego policies (readable by compliance teams)
- Testable (unit tests for policies)
- Version controlled (GitOps native)
- Used by Goldman Sachs, Netflix, Atlassian
- **Note**: OPA is the default; Enterprise supports Cedar, SpiceDB (see Provider Abstraction Architecture)

### Why Swappable Providers?
- **Enterprise reality**: Customers have existing investments in Kong, NGINX, or other proxies
- **Policy diversity**: Some prefer Cedar (AWS) or SpiceDB (Zanzibar) over OPA
- **Vendor neutrality**: Avoid lock-in, increase adoption across different infrastructure stacks
- **Future-proofing**: New proxies/engines can be added without core architecture changes
- **Managed vs Self-Hosted**: We control the stack for SaaS; enterprise customers choose theirs
- **Clean architecture**: Provider interfaces ensure consistent behavior regardless of implementation

### Why Go for Control Plane?
- Performance (compiled, concurrent)
- Ecosystem (gRPC, Kubernetes clients, database drivers)
- Developer familiarity in infrastructure space
- Easy deployment (single binary)
- Strong typing catches bugs at compile time

### Why Fiber for HTTP Framework?
- **Performance**: 6M req/sec (2.4x faster than Gin, 3.3x faster than stdlib)
- Zero memory allocation in hot paths (fasthttp-based)
- Express-like API (familiar to JavaScript developers)
- Rich middleware ecosystem (CORS, compression, rate limiting)
- Production-proven at scale

### Why PostgreSQL?
- ACID compliance for critical data
- JSONB for flexible metadata
- Robust replication for HA
- 30+ years of operational maturity
- Free and open source

### Why Redis?
- Sub-millisecond latency for rate limiting
- Pub/sub for real-time updates
- Session storage for MCP connections
- Proven at massive scale

### Why Svelte for UI?
- **5x smaller bundle**: ~60KB vs 250KB (React)
- Compile-time framework (no virtual DOM overhead)
- Simpler syntax, less boilerplate
- Built-in reactivity (Runes in Svelte 5)
- Great developer experience with fast HMR

### Why Makefile over Taskfile?
- **CNCF standard**: 100% of major Go CNCF projects use Makefile
- **Zero installation**: Works out-of-the-box on all Unix systems
- **CI/CD native**: Built-in support in GitHub Actions, GitLab CI
- **40+ years**: Battle-tested, proven, mature ecosystem

### Why Goose + sqlc for Database?
| Tool | Purpose | Why |
|------|---------|-----|
| **Goose** | Migrations | Simple SQL files, Go-embeddable, explicit control |
| **sqlc** | Query codegen | Type-safe Go from SQL, zero runtime overhead |
| **pgx** | Driver | 30-50% faster than GORM, PostgreSQL-native features |

### Why HashiCorp Vault for Credentials?
- Cloud-agnostic (works on AWS, GCP, Azure, on-prem)
- Self-hosted (aligns with open source model)
- Dynamic secrets (generate credentials on-demand)
- Automatic rotation
- Full audit logging (SOC2/HIPAA compliant)
- Free open source version

### Why No SDKs (Initially)?
- **Infrastructure, not SaaS**: Like Kubernetes, users interact via CLI and manifests
- **CLI covers 95%**: `giru server create`, `giru policy apply`
- **OpenAPI available**: Users can generate clients in any language
- **Lower maintenance**: No multi-language SDK versioning
- **Future**: SDKs planned for Phase 5 (Managed SaaS)

---

## Provider Abstraction Architecture

Giru is designed with **swappable infrastructure providers** to support diverse enterprise requirements. The open source edition ships with Envoy and OPA as defaults, while enterprise customers can swap in alternative proxies (Kong, NGINX) or policy engines (Cedar, SpiceDB/Zanzibar).

> **Note**: See [Why Swappable Providers?](#why-swappable-providers) in the Technical Decisions section for the full rationale.

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     GIRU CONTROL PLANE                          │
│  Multi-tenancy │ Subscriptions │ Compliance │ Billing │ UI     │
├─────────────────────────────────────────────────────────────────┤
│                   PROVIDER ABSTRACTION LAYER                    │
│                                                                 │
│  ┌─────────────────────┐       ┌─────────────────────┐         │
│  │   ProxyProvider     │       │   PolicyEngine      │         │
│  │   Interface         │       │   Interface         │         │
│  └─────────┬───────────┘       └─────────┬───────────┘         │
│            │                             │                      │
│  ┌─────────┴───────────┐       ┌─────────┴───────────┐         │
│  │ Implementations:    │       │ Implementations:    │         │
│  │ • Envoy (default)   │       │ • OPA (default)     │         │
│  │ • Kong (enterprise) │       │ • Cedar (enterprise)│         │
│  │ • NGINX (enterprise)│       │ • SpiceDB (ent.)    │         │
│  └─────────────────────┘       └─────────────────────┘         │
└─────────────────────────────────────────────────────────────────┘
```

### Proxy Provider Interface

```go
// internal/proxy/provider.go
package proxy

import "context"

// Provider abstracts the proxy layer (Envoy, Kong, NGINX, etc.)
// Open source ships with Envoy; enterprise supports alternatives.
type Provider interface {
    // Name returns the provider identifier (e.g., "envoy", "kong")
    Name() string
    
    // --- Route Management ---
    // UpdateRoutes pushes route configuration to the proxy
    UpdateRoutes(ctx context.Context, routes []Route) error
    
    // DeleteRoute removes a route from the proxy
    DeleteRoute(ctx context.Context, routeID string) error
    
    // --- Rate Limiting ---
    // UpdateRateLimits configures rate limit rules
    UpdateRateLimits(ctx context.Context, limits []RateLimit) error
    
    // --- Upstream Management ---
    // RegisterUpstream adds an MCP server as a backend
    RegisterUpstream(ctx context.Context, upstream Upstream) error
    
    // DeregisterUpstream removes an MCP server backend
    DeregisterUpstream(ctx context.Context, upstreamID string) error
    
    // --- Health & Observability ---
    // HealthCheck verifies proxy connectivity
    HealthCheck(ctx context.Context) error
    
    // GetMetrics retrieves proxy metrics (connections, latency, etc.)
    GetMetrics(ctx context.Context) (*Metrics, error)
    
    // --- Lifecycle ---
    // Start initializes the provider (e.g., start xDS server for Envoy)
    Start(ctx context.Context) error
    
    // Stop gracefully shuts down the provider
    Stop(ctx context.Context) error
}

// Route represents a routing rule from client to MCP server
type Route struct {
    ID           string            // ULID
    TenantID     string            // Multi-tenant isolation
    ClientID     string            // Source client
    MCPServerID  string            // Destination MCP server
    PathPrefix   string            // e.g., "/mcp/github"
    Headers      map[string]string // Header matching
    Priority     int               // Route precedence
    Metadata     map[string]string // Provider-specific config
}

// RateLimit represents a rate limiting rule
type RateLimit struct {
    ID          string
    TenantID    string
    ClientID    string   // Empty = tenant-wide
    MCPServerID string   // Empty = all servers
    Requests    int      // Requests per window
    Window      Duration // Time window (e.g., 1m, 1h)
    BurstSize   int      // Token bucket burst
}

// Upstream represents an MCP server backend
type Upstream struct {
    ID           string
    TenantID     string
    Name         string
    Address      string            // host:port or URL
    Protocol     string            // "http", "grpc", "stdio"
    TLSEnabled   bool
    HealthPath   string            // Health check endpoint
    Metadata     map[string]string // Provider-specific config
}

// Metrics contains proxy telemetry
type Metrics struct {
    ActiveConnections int64
    RequestsTotal     int64
    RequestsPerSecond float64
    LatencyP50        time.Duration
    LatencyP99        time.Duration
    ErrorRate         float64
    UpstreamHealth    map[string]bool // upstreamID -> healthy
}
```

### Policy Engine Interface

```go
// internal/policy/engine.go
package policy

import "context"

// Engine abstracts the policy decision layer (OPA, Cedar, SpiceDB, etc.)
// Open source ships with OPA; enterprise supports alternatives.
type Engine interface {
    // Name returns the engine identifier (e.g., "opa", "cedar")
    Name() string
    
    // --- Policy Evaluation ---
    // Evaluate makes an authorization decision
    Evaluate(ctx context.Context, input *EvaluationInput) (*EvaluationResult, error)
    
    // EvaluateBatch evaluates multiple requests (for preflight checks)
    EvaluateBatch(ctx context.Context, inputs []*EvaluationInput) ([]*EvaluationResult, error)
    
    // --- Policy Management ---
    // LoadPolicies loads/reloads policy definitions
    LoadPolicies(ctx context.Context, policies []PolicyDefinition) error
    
    // LoadPolicyData loads/reloads policy data (e.g., role mappings)
    LoadPolicyData(ctx context.Context, data map[string]any) error
    
    // --- Compliance ---
    // ValidateCompliance checks if a request meets compliance requirements
    ValidateCompliance(ctx context.Context, input *ComplianceInput) (*ComplianceResult, error)
    
    // --- Audit ---
    // GetAuditLog retrieves policy decision audit entries
    GetAuditLog(ctx context.Context, filter AuditFilter) ([]AuditEntry, error)
    
    // --- Lifecycle ---
    // Start initializes the engine
    Start(ctx context.Context) error
    
    // Stop gracefully shuts down the engine
    Stop(ctx context.Context) error
}

// EvaluationInput contains all context for a policy decision
type EvaluationInput struct {
    TenantID      string            // Multi-tenant context
    ClientID      string            // Requesting client
    MCPServerID   string            // Target MCP server
    ToolName      string            // MCP tool being called
    Action        string            // "tools/call", "resources/read", etc.
    Parameters    map[string]any    // Tool parameters
    UserContext   *UserContext      // User info (from JWT/API key)
    RequestID     string            // For correlation
    Timestamp     time.Time
}

// UserContext contains authenticated user information
type UserContext struct {
    UserID      string
    Email       string
    Roles       []string
    Groups      []string
    Attributes  map[string]string // Custom claims
}

// EvaluationResult contains the policy decision
type EvaluationResult struct {
    Allowed       bool
    Reason        string            // Human-readable explanation
    Violations    []Violation       // Specific policy violations
    FilteredParams map[string]any   // Parameters after PII filtering
    AuditEntry    *AuditEntry       // For logging
    Latency       time.Duration     // Decision time
}

// Violation represents a specific policy violation
type Violation struct {
    Policy      string // Policy name (e.g., "hipaa.minimum_necessary")
    Rule        string // Specific rule violated
    Message     string // Human-readable message
    Severity    string // "error", "warning", "info"
}

// ComplianceInput contains compliance check context
type ComplianceInput struct {
    TenantID    string
    Framework   string   // "hipaa", "pci_dss", "soc2"
    ToolName    string
    Parameters  map[string]any
    UserRole    string
}

// ComplianceResult contains compliance check results
type ComplianceResult struct {
    Compliant    bool
    Framework    string
    Violations   []Violation
    Remediation  []string // Suggested fixes
}

// PolicyDefinition represents a policy to load
type PolicyDefinition struct {
    ID       string
    Name     string
    Version  string
    Content  string // Rego, Cedar, or other policy language
    Enabled  bool
}

// AuditFilter for querying audit logs
type AuditFilter struct {
    TenantID    string
    ClientID    string
    MCPServerID string
    StartTime   time.Time
    EndTime     time.Time
    Allowed     *bool  // nil = all, true = allowed only, false = denied only
    Limit       int
    Offset      int
}

// AuditEntry represents a policy decision audit log
type AuditEntry struct {
    ID          string
    Timestamp   time.Time
    TenantID    string
    ClientID    string
    MCPServerID string
    ToolName    string
    Action      string
    Allowed     bool
    Reason      string
    Latency     time.Duration
    RequestID   string
}
```

### Provider Registry

```go
// internal/provider/registry.go
package provider

import (
    "fmt"
    "sync"
    
    "github.com/giru-ai/giru/internal/proxy"
    "github.com/giru-ai/giru/internal/policy"
)

// Registry manages available providers and active instances
type Registry struct {
    mu sync.RWMutex
    
    // Registered provider factories
    proxyFactories  map[string]ProxyFactory
    policyFactories map[string]PolicyFactory
    
    // Active instances
    activeProxy  proxy.Provider
    activePolicy policy.Engine
}

// ProxyFactory creates a proxy provider from config
type ProxyFactory func(cfg *ProxyConfig) (proxy.Provider, error)

// PolicyFactory creates a policy engine from config
type PolicyFactory func(cfg *PolicyConfig) (policy.Engine, error)

// ProxyConfig contains proxy provider configuration
type ProxyConfig struct {
    Provider string            // "envoy", "kong", "nginx"
    Address  string            // Provider-specific address
    Options  map[string]any    // Provider-specific options
}

// PolicyConfig contains policy engine configuration
type PolicyConfig struct {
    Engine  string            // "opa", "cedar", "spicedb"
    Address string            // Engine-specific address
    Options map[string]any    // Engine-specific options
}

// Global registry instance
var globalRegistry = &Registry{
    proxyFactories:  make(map[string]ProxyFactory),
    policyFactories: make(map[string]PolicyFactory),
}

// RegisterProxyProvider registers a proxy provider factory
// Called in init() by each provider implementation
func RegisterProxyProvider(name string, factory ProxyFactory) {
    globalRegistry.mu.Lock()
    defer globalRegistry.mu.Unlock()
    globalRegistry.proxyFactories[name] = factory
}

// RegisterPolicyEngine registers a policy engine factory
// Called in init() by each engine implementation
func RegisterPolicyEngine(name string, factory PolicyFactory) {
    globalRegistry.mu.Lock()
    defer globalRegistry.mu.Unlock()
    globalRegistry.policyFactories[name] = factory
}

// NewProxyProvider creates a proxy provider by name
func NewProxyProvider(cfg *ProxyConfig) (proxy.Provider, error) {
    globalRegistry.mu.RLock()
    factory, ok := globalRegistry.proxyFactories[cfg.Provider]
    globalRegistry.mu.RUnlock()
    
    if !ok {
        return nil, fmt.Errorf("unknown proxy provider: %s", cfg.Provider)
    }
    return factory(cfg)
}

// NewPolicyEngine creates a policy engine by name
func NewPolicyEngine(cfg *PolicyConfig) (policy.Engine, error) {
    globalRegistry.mu.RLock()
    factory, ok := globalRegistry.policyFactories[cfg.Engine]
    globalRegistry.mu.RUnlock()
    
    if !ok {
        return nil, fmt.Errorf("unknown policy engine: %s", cfg.Engine)
    }
    return factory(cfg)
}

// AvailableProxyProviders returns registered proxy provider names
func AvailableProxyProviders() []string {
    globalRegistry.mu.RLock()
    defer globalRegistry.mu.RUnlock()
    
    names := make([]string, 0, len(globalRegistry.proxyFactories))
    for name := range globalRegistry.proxyFactories {
        names = append(names, name)
    }
    return names
}

// AvailablePolicyEngines returns registered policy engine names
func AvailablePolicyEngines() []string {
    globalRegistry.mu.RLock()
    defer globalRegistry.mu.RUnlock()
    
    names := make([]string, 0, len(globalRegistry.policyFactories))
    for name := range globalRegistry.policyFactories {
        names = append(names, name)
    }
    return names
}
```

### Default Implementations (Open Source)

#### Envoy Proxy Provider

```go
// internal/proxy/envoy/provider.go
package envoy

import (
    "context"
    
    "github.com/giru-ai/giru/internal/proxy"
    "github.com/giru-ai/giru/internal/provider"
)

func init() {
    // Register Envoy provider at startup
    provider.RegisterProxyProvider("envoy", NewProvider)
}

// Provider implements proxy.Provider for Envoy via xDS
type Provider struct {
    xdsServer  *XDSServer
    config     *Config
}

type Config struct {
    XDSPort        int    // gRPC port for xDS (default: 18000)
    NodeID         string // Envoy node identifier
    ClusterName    string // Envoy cluster name
    EnableALS      bool   // Access Log Service
}

func NewProvider(cfg *provider.ProxyConfig) (proxy.Provider, error) {
    config := parseConfig(cfg.Options)
    return &Provider{
        config: config,
    }, nil
}

func (p *Provider) Name() string { return "envoy" }

func (p *Provider) Start(ctx context.Context) error {
    // Initialize xDS gRPC server
    p.xdsServer = NewXDSServer(p.config)
    return p.xdsServer.Start(ctx)
}

func (p *Provider) UpdateRoutes(ctx context.Context, routes []proxy.Route) error {
    // Convert to Envoy RouteConfiguration and push via xDS
    return p.xdsServer.PushRoutes(ctx, routes)
}

func (p *Provider) UpdateRateLimits(ctx context.Context, limits []proxy.RateLimit) error {
    // Configure Envoy rate limit service
    return p.xdsServer.PushRateLimits(ctx, limits)
}

func (p *Provider) RegisterUpstream(ctx context.Context, upstream proxy.Upstream) error {
    // Add to Envoy ClusterLoadAssignment
    return p.xdsServer.AddUpstream(ctx, upstream)
}

// ... implement remaining interface methods
```

#### OPA Policy Engine

```go
// internal/policy/opa/engine.go
package opa

import (
    "context"
    
    "github.com/giru-ai/giru/internal/policy"
    "github.com/giru-ai/giru/internal/provider"
    "github.com/open-policy-agent/opa/rego"
)

func init() {
    // Register OPA engine at startup
    provider.RegisterPolicyEngine("opa", NewEngine)
}

// Engine implements policy.Engine for OPA
type Engine struct {
    client     *http.Client  // For remote OPA
    embedded   *rego.Rego    // For embedded OPA
    config     *Config
    policyData map[string]any
}

type Config struct {
    Mode          string // "embedded" or "remote"
    RemoteAddress string // OPA server address (remote mode)
    BundlePath    string // Policy bundle path (embedded mode)
}

func NewEngine(cfg *provider.PolicyConfig) (policy.Engine, error) {
    config := parseConfig(cfg.Options)
    return &Engine{
        config:     config,
        policyData: make(map[string]any),
    }, nil
}

func (e *Engine) Name() string { return "opa" }

func (e *Engine) Start(ctx context.Context) error {
    if e.config.Mode == "embedded" {
        return e.initEmbedded(ctx)
    }
    return e.initRemote(ctx)
}

func (e *Engine) Evaluate(ctx context.Context, input *policy.EvaluationInput) (*policy.EvaluationResult, error) {
    start := time.Now()
    
    // Build OPA input document
    opaInput := map[string]any{
        "tenant_id":     input.TenantID,
        "client_id":     input.ClientID,
        "mcp_server_id": input.MCPServerID,
        "tool_name":     input.ToolName,
        "action":        input.Action,
        "parameters":    input.Parameters,
        "user":          input.UserContext,
        "timestamp":     input.Timestamp,
    }
    
    // Query OPA
    result, err := e.query(ctx, "data.giru.authz.allow", opaInput)
    if err != nil {
        return nil, err
    }
    
    return &policy.EvaluationResult{
        Allowed: result.Allowed,
        Reason:  result.Reason,
        Latency: time.Since(start),
    }, nil
}

// ... implement remaining interface methods
```

### Enterprise Implementations (giru-enterprise)

Enterprise customers can use alternative providers:

```go
// giru-enterprise/internal/proxy/kong/provider.go
package kong

func init() {
    provider.RegisterProxyProvider("kong", NewProvider)
}

// Provider implements proxy.Provider for Kong Gateway
type Provider struct {
    adminClient *KongAdminClient
    config      *Config
}

// Uses Kong Admin API to configure routes, upstreams, plugins
```

```go
// giru-enterprise/internal/policy/cedar/engine.go
package cedar

func init() {
    provider.RegisterPolicyEngine("cedar", NewEngine)
}

// Engine implements policy.Engine for AWS Cedar
type Engine struct {
    // Uses Cedar policy language for fine-grained authorization
}
```

```go
// giru-enterprise/internal/policy/spicedb/engine.go
package spicedb

func init() {
    provider.RegisterPolicyEngine("spicedb", NewEngine)
}

// Engine implements policy.Engine for SpiceDB (Zanzibar)
type Engine struct {
    // Uses SpiceDB for relationship-based access control
}
```

### Configuration

```yaml
# configs/giru.yaml

# Proxy provider configuration
proxy:
  provider: envoy  # "envoy" (default), "kong", "nginx" (enterprise)
  envoy:
    xds_port: 18000
    node_id: giru-gateway
    enable_als: true
  # kong:  # Enterprise only
  #   admin_url: http://localhost:8001
  #   workspace: default
  # nginx:  # Enterprise only
  #   config_path: /etc/nginx/conf.d

# Policy engine configuration  
policy:
  engine: opa  # "opa" (default), "cedar", "spicedb" (enterprise)
  opa:
    mode: embedded  # "embedded" or "remote"
    bundle_path: ./policies
    # remote_address: http://localhost:8181  # For remote mode
  # cedar:  # Enterprise only
  #   policy_store: ./policies/cedar
  # spicedb:  # Enterprise only
  #   endpoint: localhost:50051
  #   preshared_key: ${SPICEDB_KEY}
```

### Provider Selection by Deployment Model

| Deployment | Proxy | Policy Engine | Notes |
|------------|-------|---------------|-------|
| **Open Source Self-Host** | Envoy | OPA | CNCF stack, battle-tested |
| **Managed SaaS** | Envoy AI Gateway | OPA | We control, optimized for MCP |
| **Enterprise Self-Host** | Customer choice | Customer choice | Adapters provided |
| **Enterprise (We Manage)** | Customer choice | Customer choice | We deploy in their cloud |

### Envoy AI Gateway Integration

As Envoy AI Gateway adds native MCP support, Giru leverages it:

```go
// internal/proxy/envoy/aigateway.go
package envoy

// AIGatewayProvider extends Provider with Envoy AI Gateway features
type AIGatewayProvider struct {
    *Provider
    mcpConfig *MCPConfig
}

type MCPConfig struct {
    // Leverage Envoy AI Gateway's native MCP support
    EnableMCPProxy     bool
    MCPServerDiscovery bool   // Auto-discover MCP servers
    ToolAggregation    bool   // Aggregate tools from multiple servers
}

func (p *AIGatewayProvider) ConfigureMCPRouting(ctx context.Context) error {
    // Use Envoy AI Gateway's MCP-specific configuration
    // This offloads protocol handling to Envoy while Giru manages:
    // - Multi-tenancy
    // - Subscriptions
    // - Compliance policies
    // - Billing/metering
}
```

---

## Directory Structure to Create

> **Reading Guide**: This section shows the complete file/folder structure. Detailed implementation for each component (Database Strategy, Policy Data Management, Authentication, Compliance Policies, etc.) follows in subsequent sections.

### Repository 1: giru-ai/giru (Open Source - Apache 2.0)

This is the CNCF project repository with production-ready core features.

```
giru/
├── LICENSE                          # Apache 2.0 License
├── README.md                        # Project overview, quick start
├── CONTRIBUTING.md                  # Contribution guidelines
├── CODE_OF_CONDUCT.md              # CNCF Code of Conduct
├── GOVERNANCE.md                    # CNCF governance model
├── SECURITY.md                      # Security policy and disclosure
├── MAINTAINERS.md                   # List of maintainers
├── .gitignore
├── go.mod                           # Go module (root)
├── go.sum
├── Makefile                         # Build automation
│
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                   # CI pipeline
│   │   ├── release.yml              # Release automation
│   │   └── security.yml             # Security scanning
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   └── feature_request.md
│   └── PULL_REQUEST_TEMPLATE.md
│
├── cmd/
│   ├── giru-server/                 # Control plane entry point
│   │   └── main.go
│   └── giru/                        # CLI entry point
│       └── main.go
│
├── internal/                        # Private application code
│   ├── api/
│   │   ├── rest/                    # Fiber REST handlers
│   │   │   ├── server.go
│   │   │   ├── routes.go
│   │   │   └── handlers/
│   │   │       ├── tenants.go
│   │   │       ├── clients.go
│   │   │       ├── servers.go
│   │   │       ├── subscriptions.go
│   │   │       └── mcp.go           # MCP JSON-RPC handler
│   │   └── grpc/                    # gRPC for xDS
│   │       └── xds_server.go
│   │
│   ├── proxy/                       # Proxy provider abstraction
│   │   ├── provider.go              # Provider interface (see Provider Abstraction Architecture)
│   │   ├── types.go                 # Route, RateLimit, Upstream, Metrics types
│   │   └── envoy/                   # Envoy implementation (default)
│   │       ├── provider.go          # Envoy provider implementation
│   │       ├── xds.go               # xDS server for dynamic config
│   │       ├── routes.go            # Route configuration
│   │       ├── clusters.go          # Upstream cluster management
│   │       └── ratelimit.go         # Rate limit configuration
│   │
│   ├── policy/                      # Policy engine abstraction
│   │   ├── engine.go                # Engine interface (see Provider Abstraction Architecture)
│   │   ├── types.go                 # EvaluationInput, EvaluationResult, etc.
│   │   └── opa/                     # OPA implementation (default)
│   │       ├── engine.go            # OPA engine implementation
│   │       ├── embedded.go          # Embedded OPA mode
│   │       ├── remote.go            # Remote OPA mode
│   │       └── compliance.go        # Compliance policy helpers
│   │
│   ├── provider/                    # Provider registry and factory
│   │   ├── registry.go              # Global provider registry
│   │   ├── config.go                # ProxyConfig, PolicyConfig types
│   │   └── factory.go               # Provider factory functions
│   │
│   ├── database/
│   │   ├── db.go                    # Connection pool (pgx)
│   │   ├── migrations.go            # Goose runner
│   │   ├── tx.go                    # Transaction helpers
│   │   └── gen/                     # sqlc generated code
│   │
│   ├── mcp/                         # MCP client implementation
│   │   ├── client.go                # MCP JSON-RPC client
│   │   ├── transport_stdio.go
│   │   ├── transport_http.go
│   │   └── session.go
│   │
│   ├── auth/                        # Authentication
│   │   ├── middleware.go            # Fiber auth middleware
│   │   ├── apikey.go
│   │   └── jwt.go
│   │
│   ├── ratelimit/                   # Rate limiting (Redis-based, used by proxy providers)
│   │   └── redis.go
│   │
│   ├── config/                      # Configuration
│   │   ├── config.go
│   │   └── loader.go
│   │
│   └── observability/               # Metrics, tracing, logging
│       ├── metrics.go
│       ├── tracing.go
│       └── logging.go
│
├── pkg/                             # Public libraries (importable)
│   └── models/                      # Shared data models
│       ├── tenant.go
│       ├── client.go
│       ├── server.go
│       └── subscription.go
│
├── db/
│   ├── migrations/                  # Goose SQL migrations
│   │   ├── 00001_init.sql
│   │   ├── 00002_add_mcp_servers.sql
│   │   ├── 00003_add_subscriptions.sql
│   │   └── embed.go                 # Embed migrations in binary
│   ├── queries/                     # sqlc query files
│   │   ├── tenants.sql
│   │   ├── clients.sql
│   │   ├── servers.sql
│   │   └── subscriptions.sql
│   ├── seeds/                       # Seed data
│   │   └── 001_demo_data.sql
│   └── sqlc.yaml                    # sqlc configuration
│
├── configs/
│   ├── envoy/                       # Envoy configuration
│   │   ├── envoy.yaml               # Base config
│   │   └── xds-bootstrap.yaml
│   └── opa/                         # OPA configuration
│       └── config.yaml
│
├── policies/                        # OPA Rego policies
│   ├── authorization/
│   │   ├── api_key.rego
│   │   └── jwt.rego
│   ├── subscriptions/
│   │   └── access.rego
│   ├── compliance/                  # Shared compliance policies
│   │   ├── hipaa/
│   │   │   └── minimum_necessary.rego
│   │   ├── pci_dss/
│   │   │   └── cardholder_data.rego
│   │   └── soc2/
│   │       └── access_control.rego
│   ├── data/                        # Default policy data (can be overridden per-tenant)
│   │   ├── hipaa/
│   │   │   └── permitted_fields.json
│   │   ├── pci_dss/
│   │   │   └── cardholder_zones.json
│   │   └── soc2/
│   │       └── user_certifications.json
│   └── tests/                       # Policy unit tests
│       └── authorization_test.rego
│
├── deployments/
│   ├── docker-compose/              # Local development
│   │   ├── docker-compose.yml
│   │   ├── docker-compose.dev.yml
│   │   └── .env.example
│   ├── kubernetes/                  # K8s manifests
│   │   ├── base/
│   │   │   ├── namespace.yaml
│   │   │   ├── control-plane.yaml
│   │   │   ├── envoy.yaml
│   │   │   ├── opa.yaml
│   │   │   ├── postgres.yaml
│   │   │   ├── redis.yaml
│   │   │   └── kustomization.yaml
│   │   └── overlays/
│   │       ├── dev/
│   │       ├── staging/
│   │       └── production/
│   ├── helm/                        # Helm chart
│   │   └── giru/
│   │       ├── Chart.yaml
│   │       ├── values.yaml
│   │       └── templates/
│   └── kind/                        # Local K8s testing
│       ├── kind-config.yaml
│       └── skaffold.yaml
│
├── build/
│   └── docker/
│       ├── Dockerfile               # Multi-stage production build
│       ├── Dockerfile.dev           # Development with hot reload
│       ├── Dockerfile.envoy
│       └── Dockerfile.opa
│
├── scripts/
│   ├── setup/
│   │   └── install-dev.sh
│   └── test/
│       └── smoke-tests.sh
│
├── docs/
│   ├── architecture/
│   │   └── overview.md
│   ├── deployment/
│   │   ├── kubernetes.md
│   │   └── docker-compose.md
│   ├── api/
│   │   └── openapi.yaml             # OpenAPI 3.0 spec
│   └── policies/
│       └── writing-policies.md
│
├── examples/
│   ├── basic-setup/
│   │   └── README.md
│   └── multi-server/
│       └── README.md
│
├── sdks/                            # SDK placeholders (Phase 5)
│   ├── typescript/
│   │   ├── README.md
│   │   └── package.json
│   ├── python/
│   │   ├── README.md
│   │   └── pyproject.toml
│   └── go/
│       ├── README.md
│       └── go.mod
│
├── web-ui/                          # Community Web UI (Svelte)
│   ├── src/
│   │   ├── routes/
│   │   │   ├── +layout.svelte
│   │   │   ├── +page.svelte         # Dashboard home
│   │   │   ├── servers/             # MCP server management
│   │   │   ├── clients/             # Client management
│   │   │   ├── subscriptions/       # Subscription management
│   │   │   └── settings/            # Basic settings
│   │   └── lib/
│   │       ├── components/          # Reusable UI components
│   │       ├── stores/              # Svelte stores
│   │       └── api/                 # API client
│   ├── package.json
│   ├── svelte.config.js
│   ├── vite.config.ts
│   └── tailwind.config.js
│
└── tests/
    ├── integration/
    │   └── e2e_test.go
    └── performance/
        └── load_test.js             # k6 load tests
```

### Repository 2: giru-ai/giru-enterprise (Private - Proprietary)

Enterprise features built on top of the open source core.

```
giru-enterprise/
├── LICENSE                          # Proprietary License
├── README.md
├── go.mod                           # Imports github.com/giru-ai/giru
├── go.sum
├── Makefile
│
├── cmd/
│   └── giru-enterprise/
│       └── main.go                  # Enterprise entry point
│
├── internal/
│   ├── license/                     # License validation
│   │   ├── manager.go
│   │   └── features.go
│   │
│   ├── proxy/                       # Alternative proxy providers (Enterprise)
│   │   ├── kong/                    # Kong Gateway provider
│   │   │   ├── provider.go          # Implements proxy.Provider
│   │   │   ├── admin.go             # Kong Admin API client
│   │   │   ├── routes.go            # Route/Service management
│   │   │   └── plugins.go           # Plugin configuration
│   │   └── nginx/                   # NGINX provider
│   │       ├── provider.go          # Implements proxy.Provider
│   │       ├── config.go            # NGINX config generation
│   │       └── reload.go            # Config reload handling
│   │
│   ├── policy/                      # Alternative policy engines (Enterprise)
│   │   ├── cedar/                   # AWS Cedar engine
│   │   │   ├── engine.go            # Implements policy.Engine
│   │   │   ├── schema.go            # Cedar schema definitions
│   │   │   └── policies.go          # Cedar policy management
│   │   └── spicedb/                 # SpiceDB/Zanzibar engine
│   │       ├── engine.go            # Implements policy.Engine
│   │       ├── schema.go            # SpiceDB schema definitions
│   │       └── relationships.go     # Relationship management
│   │
│   ├── auth/
│   │   ├── sso/                     # SSO providers
│   │   │   ├── saml.go
│   │   │   ├── oidc.go
│   │   │   └── providers/
│   │   │       ├── okta.go
│   │   │       ├── azure_ad.go
│   │   │       └── google.go
│   │   └── mfa/
│   │       ├── totp.go
│   │       └── webauthn.go
│   │
│   ├── multitenancy/                # Multi-tenant isolation
│   │   ├── manager.go
│   │   ├── isolation.go
│   │   └── quotas.go
│   │
│   ├── audit/                       # Enhanced audit logging
│   │   ├── logger.go
│   │   └── export.go
│   │
│   ├── billing/                     # Usage metering & billing
│   │   ├── metering.go
│   │   └── stripe.go
│   │
│   └── analytics/                   # Advanced analytics
│       └── reporting.go
│
├── policies/                        # Enterprise-only OPA policies
│   ├── compliance/
│   │   ├── hipaa/
│   │   │   ├── phi_protection.rego
│   │   │   └── access_audit.rego
│   │   ├── pci_dss/
│   │   │   └── network_segmentation.rego
│   │   └── gdpr/
│   │       ├── data_residency.rego
│   │       └── right_to_erasure.rego
│   └── advanced/
│       ├── adaptive_rate_limiting.rego
│       └── anomaly_detection.rego
│
├── web-ui/                          # Enterprise Svelte UI
│   ├── src/
│   │   ├── routes/
│   │   │   ├── +layout.svelte
│   │   │   ├── +page.svelte
│   │   │   ├── tenants/
│   │   │   ├── analytics/
│   │   │   ├── compliance/
│   │   │   └── audit/
│   │   └── lib/
│   │       ├── components/
│   │       ├── stores/
│   │       └── api/
│   ├── package.json
│   ├── svelte.config.js
│   ├── vite.config.ts
│   └── tailwind.config.js
│
├── build/
│   └── docker/
│       └── Dockerfile.enterprise
│
└── helm/
    └── giru-enterprise/
        ├── Chart.yaml
        ├── values.yaml
        └── templates/
```

**Enterprise Integration Pattern:**

```go
// cmd/giru-enterprise/main.go
package main

import (
    // Import open-source core
    "github.com/giru-ai/giru/internal/api/rest"
    "github.com/giru-ai/giru/internal/config"
    
    // Import enterprise extensions
    "github.com/giru-ai/giru-enterprise/internal/license"
    "github.com/giru-ai/giru-enterprise/internal/auth/sso"
    "github.com/giru-ai/giru-enterprise/internal/multitenancy"
)

func main() {
    // Load config
    cfg := config.Load()
    
    // Validate enterprise license
    lic, err := license.Validate()
    if err != nil {
        log.Warn("No valid license - running in community mode")
        // Fall back to open source features only
        runCommunityMode(cfg)
        return
    }
    
    log.Printf("Licensed to: %s (expires: %s)", lic.CustomerID, lic.ExpiresAt)
    
    // Create server with enterprise features
    srv := rest.NewServer(cfg)
    
    // Register enterprise features based on license
    if lic.HasFeature("sso") {
        srv.RegisterAuthProvider(sso.NewSAMLProvider())
        srv.RegisterAuthProvider(sso.NewOIDCProvider())
    }
    
    if lic.HasFeature("multi_tenancy") {
        srv.EnableMultiTenancy(multitenancy.NewManager(lic.MaxTenants))
    }
    
    srv.Start()
}
```

### Repository 3: giru-ai/giru-common (Apache 2.0)

Shared libraries used by both repositories.

```
giru-common/
├── LICENSE                          # Apache 2.0
├── README.md
├── go.mod
├── go.sum
│
├── models/                          # Shared data models
│   ├── tenant.go
│   ├── client.go
│   ├── server.go
│   ├── subscription.go
│   └── tool.go
│
├── proto/                           # Protocol Buffers
│   ├── api/
│   │   └── v1/
│   │       ├── tenant.proto
│   │       ├── client.proto
│   │       └── server.proto
│   └── xds/                         # xDS protocol definitions
│
├── contracts/                       # Interface contracts
│   ├── auth_provider.go
│   ├── storage.go
│   └── mcp_client.go
│
└── utils/
    ├── logger/
    ├── metrics/
    └── validation/
```

---

## Web UI Strategy

Both Community and Enterprise editions include a Svelte-based Web UI, but with different feature sets.

### Community Web UI Features

The Community Web UI provides full management capabilities for single-tenant deployments:

| Feature | Description |
|---------|-------------|
| **Dashboard** | System health, request metrics, active connections |
| **MCP Servers** | Register, configure, health check MCP backends |
| **Clients** | Create API keys, manage AI agent access |
| **Subscriptions** | Grant client access to MCP servers/tools |
| **Settings** | Basic configuration, environment variables |
| **Logs Viewer** | Recent requests, errors (last 24 hours) |

### Enterprise Web UI Additional Features

Enterprise builds on Community with advanced management and compliance features:

| Feature | Description |
|---------|-------------|
| **Multi-Tenant Management** | Create/manage tenants, resource isolation |
| **Analytics Dashboard** | Usage trends, cost analysis, ROI metrics |
| **Compliance Center** | HIPAA/PCI-DSS/SOC2 audit reports, policy violations |
| **Audit Log Viewer** | Searchable audit trail, export to SIEM |
| **SSO Configuration** | SAML/OIDC provider setup, user provisioning |
| **Approval Workflows** | Subscription requests, change approvals |
| **Billing Dashboard** | Usage metering, invoice generation (SaaS) |
| **Environment Management** | Dev/staging/prod environment policies |

### UI Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Web UI Architecture                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Community (giru/web-ui/)          Enterprise (giru-enterprise/web-ui/)
│  ├── Dashboard                     ├── Everything in Community +
│  ├── Servers                       ├── Tenants
│  ├── Clients                       ├── Analytics
│  ├── Subscriptions                 ├── Compliance
│  └── Settings                      ├── Audit Logs
│                                    ├── SSO Config
│                                    └── Billing
│                                                                 │
│  Shared Components (via npm package or copy):                  │
│  - Data tables, forms, modals                                  │
│  - Charts (Chart.js)                                           │
│  - API client                                                  │
│  - Auth context                                                │
└─────────────────────────────────────────────────────────────────┘
```

### Build & Embedding Strategy

Both UIs are built as static assets and embedded in the Go binary:

```go
// internal/api/rest/ui.go
package rest

import (
    "embed"
    "io/fs"
    "net/http"
    
    "github.com/gofiber/fiber/v2"
    "github.com/gofiber/fiber/v2/middleware/filesystem"
)

//go:embed all:ui/dist
var uiAssets embed.FS

func (s *Server) setupUI() {
    // Serve static assets
    uiFS, _ := fs.Sub(uiAssets, "ui/dist")
    s.app.Use("/", filesystem.New(filesystem.Config{
        Root:       http.FS(uiFS),
        Browse:     false,
        Index:      "index.html",
        NotFoundFile: "index.html", // SPA fallback
    }))
}
```

---

## Database Strategy

### Stack Overview

```
┌─────────────────────────────────────────┐
│    Database Stack for Giru              │
├─────────────────────────────────────────┤
│  Driver:      pgx v5                    │
│  Queries:     sqlc (type-safe codegen)  │
│  Migrations:  goose (imperative SQL)    │
│  Seeds:       SQL files + Makefile      │
│  Database:    PostgreSQL 15+            │
│  Cache:       Redis 7+                  │
└─────────────────────────────────────────┘
```

### Canonical Database Schema

**This is the single source of truth for all database tables.**

```sql
-- db/migrations/00001_init.sql
-- +goose Up
-- +goose StatementBegin

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Note: ULIDs are generated in application code using ulid.Make().String()
-- ULIDs are stored as CHAR(26) - they are lexicographically sortable

-- ============================================================================
-- TENANTS
-- ============================================================================
CREATE TABLE tenants (
    id CHAR(26) PRIMARY KEY,                       -- ULID generated in application
    name VARCHAR(255) NOT NULL UNIQUE,
    display_name VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'active',  -- active, suspended, deleted
    license_type VARCHAR(50) DEFAULT 'community',  -- community, enterprise
    features JSONB DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_tenants_status ON tenants(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_tenants_name ON tenants(name) WHERE deleted_at IS NULL;

-- ============================================================================
-- ENVIRONMENTS
-- ============================================================================
CREATE TABLE environments (
    id CHAR(26) PRIMARY KEY,                        -- ULID generated in application
    tenant_id CHAR(26) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL,              -- dev, staging, prod
    display_name VARCHAR(255),
    config JSONB NOT NULL DEFAULT '{}',     -- environment-specific settings
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(tenant_id, name)
);

CREATE INDEX idx_environments_tenant ON environments(tenant_id);

-- ============================================================================
-- CLIENTS (AI Agents / Applications)
-- ============================================================================
CREATE TABLE clients (
    id CHAR(26) PRIMARY KEY,                        -- ULID generated in application
    tenant_id CHAR(26) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    display_name VARCHAR(255),
    client_type VARCHAR(50) NOT NULL,       -- agent, application, user
    
    -- Authentication
    api_key_hash VARCHAR(255) NOT NULL,     -- SHA-256 hash of API key
    
    -- Defaults (can be overridden per subscription)
    default_rate_limit_rps INTEGER DEFAULT 100,
    
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    last_used_at TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}',
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    
    UNIQUE(tenant_id, name)
);

CREATE INDEX idx_clients_tenant ON clients(tenant_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_clients_api_key ON clients(api_key_hash);

-- ============================================================================
-- MCP SERVERS
-- ============================================================================
CREATE TABLE mcp_servers (
    id CHAR(26) PRIMARY KEY,                          -- ULID generated in application
    tenant_id CHAR(26) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    display_name VARCHAR(255),
    
    -- Connection details
    endpoint_url VARCHAR(500) NOT NULL,
    transport VARCHAR(50) NOT NULL DEFAULT 'stdio',  -- stdio, http, sse
    
    -- Authentication TO the MCP backend
    auth_type VARCHAR(50) NOT NULL DEFAULT 'none',   -- none, oauth, api_key, mtls
    auth_provider VARCHAR(50),                        -- github, slack, google, custom
    
    -- Credential storage (production: Vault, MVP: pgcrypto)
    vault_secret_path VARCHAR(500),                   -- secret/data/tenants/{id}/mcp/{name}
    vault_secret_version INTEGER,
    auth_config_encrypted BYTEA,                      -- Fallback: pgcrypto encrypted JSON
    
    -- Token lifecycle
    token_expires_at TIMESTAMPTZ,
    token_last_refreshed TIMESTAMPTZ,
    token_refresh_enabled BOOLEAN DEFAULT false,
    
    -- MCP protocol info
    protocol_version VARCHAR(50) DEFAULT '2024-11-05',
    server_capabilities JSONB,                        -- From MCP initialize response
    
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    last_health_check TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    
    UNIQUE(tenant_id, name),
    
    -- Must have either Vault path OR encrypted config (or none for auth_type=none)
    CONSTRAINT valid_auth_config CHECK (
        auth_type = 'none' 
        OR vault_secret_path IS NOT NULL 
        OR auth_config_encrypted IS NOT NULL
    )
);

CREATE INDEX idx_mcp_servers_tenant ON mcp_servers(tenant_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_mcp_servers_token_expiry ON mcp_servers(token_expires_at) 
    WHERE token_refresh_enabled = true AND status = 'active';

-- ============================================================================
-- MCP TOOLS
-- ============================================================================
CREATE TABLE mcp_tools (
    id CHAR(26) PRIMARY KEY,                          -- ULID generated in application
    mcp_server_id CHAR(26) NOT NULL REFERENCES mcp_servers(id) ON DELETE CASCADE,
    
    name VARCHAR(255) NOT NULL,              -- e.g., github__list_repos
    display_name VARCHAR(255),
    description TEXT,
    
    input_schema JSONB NOT NULL,             -- JSON Schema from MCP tools/list
    
    category VARCHAR(100),                   -- data, communication, computation
    tags TEXT[],
    cost_tier VARCHAR(50) DEFAULT 'free',    -- free, standard, premium
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(mcp_server_id, name)
);

CREATE INDEX idx_mcp_tools_name ON mcp_tools(name);
CREATE INDEX idx_mcp_tools_server ON mcp_tools(mcp_server_id);

-- ============================================================================
-- SUBSCRIPTIONS (Access Grants: Client -> MCP Server)
-- ============================================================================
CREATE TABLE subscriptions (
    id CHAR(26) PRIMARY KEY,                        -- ULID generated in application
    
    -- The relationship
    client_id CHAR(26) NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    mcp_server_id CHAR(26) NOT NULL REFERENCES mcp_servers(id) ON DELETE CASCADE,
    environment_id CHAR(26) REFERENCES environments(id),
    
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Scope: which tools can be accessed
    scope_type VARCHAR(50) NOT NULL DEFAULT 'selective',  -- all, selective
    scope_tools TEXT[],                                    -- Tool names when selective
    
    -- Rate limiting & quotas
    rate_limit_rps INTEGER,
    quota_per_day INTEGER,
    quota_per_month INTEGER,
    
    -- Constraints (evaluated by OPA)
    constraints JSONB DEFAULT '{}',          -- { "max_file_size": 10485760, "filter_pii": true }
    
    -- Lifecycle
    status VARCHAR(50) NOT NULL DEFAULT 'active',  -- pending, active, suspended, expired
    requires_approval BOOLEAN DEFAULT false,        -- ENTERPRISE
    approved_by CHAR(26),                           -- ENTERPRISE
    approved_at TIMESTAMPTZ,                        -- ENTERPRISE
    
    -- Temporal validity
    starts_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    auto_renew BOOLEAN DEFAULT false,               -- ENTERPRISE
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(client_id, mcp_server_id, environment_id, name)
);

CREATE INDEX idx_subscriptions_client ON subscriptions(client_id);
CREATE INDEX idx_subscriptions_mcp ON subscriptions(mcp_server_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status, expires_at);

-- ============================================================================
-- SUBSCRIPTION USAGE (For quotas and billing)
-- ============================================================================
CREATE TABLE subscription_usage (
    id CHAR(26) PRIMARY KEY,                        -- ULID generated in application
    subscription_id CHAR(26) NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
    
    tool_name VARCHAR(255) NOT NULL,
    request_id CHAR(26) NOT NULL,
    
    duration_ms INTEGER,
    status_code INTEGER,
    tokens_used INTEGER,
    computed_cost DECIMAL(10, 4),            -- ENTERPRISE: for billing
    
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_usage_subscription_day ON subscription_usage(subscription_id, DATE(timestamp));
CREATE INDEX idx_usage_timestamp ON subscription_usage(timestamp DESC);

-- ============================================================================
-- OAUTH STATE (CSRF protection for OAuth flows)
-- ============================================================================
CREATE TABLE oauth_states (
    id CHAR(26) PRIMARY KEY,                        -- ULID generated in application
    state_token VARCHAR(255) NOT NULL UNIQUE,
    tenant_id CHAR(26) NOT NULL REFERENCES tenants(id),
    provider VARCHAR(50) NOT NULL,
    redirect_uri TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL DEFAULT NOW() + INTERVAL '10 minutes'
);

CREATE INDEX idx_oauth_states_token ON oauth_states(state_token);
CREATE INDEX idx_oauth_states_expires ON oauth_states(expires_at);

-- ============================================================================
-- CREDENTIAL AUDIT LOG
-- ============================================================================
CREATE TABLE credential_audit_log (
    id CHAR(26) PRIMARY KEY,                        -- ULID generated in application
    tenant_id CHAR(26) NOT NULL REFERENCES tenants(id),
    mcp_server_id CHAR(26) REFERENCES mcp_servers(id) ON DELETE SET NULL,
    client_id CHAR(26) REFERENCES clients(id) ON DELETE SET NULL,
    
    operation VARCHAR(50) NOT NULL,          -- created, read, refreshed, revoked
    success BOOLEAN NOT NULL,
    error_message TEXT,
    
    ip_address INET,
    user_agent TEXT,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_credential_audit_tenant ON credential_audit_log(tenant_id);
CREATE INDEX idx_credential_audit_timestamp ON credential_audit_log(created_at DESC);

-- ============================================================================
-- AUDIT LOGS (ENTERPRISE)
-- ============================================================================
CREATE TABLE audit_logs (
    id CHAR(26) PRIMARY KEY,                        -- ULID generated in application
    tenant_id CHAR(26) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    
    event_type VARCHAR(100) NOT NULL,
    actor_type VARCHAR(50) NOT NULL,         -- user, system, client
    actor_id CHAR(26),
    
    resource_type VARCHAR(100) NOT NULL,
    resource_id CHAR(26),
    action VARCHAR(100) NOT NULL,
    
    status VARCHAR(50) NOT NULL,             -- success, failure
    details JSONB DEFAULT '{}',
    
    ip_address INET,
    user_agent TEXT,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
) PARTITION BY RANGE (created_at);

CREATE INDEX idx_audit_tenant ON audit_logs(tenant_id);
CREATE INDEX idx_audit_created ON audit_logs(created_at DESC);
CREATE INDEX idx_audit_event ON audit_logs(event_type);

-- Create initial partition
CREATE TABLE audit_logs_y2025 PARTITION OF audit_logs
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function to resolve which subscription allows access to a tool
CREATE OR REPLACE FUNCTION resolve_tool_subscription(
    p_client_id CHAR(26),
    p_tool_name VARCHAR,
    p_prefer_mcp_name VARCHAR DEFAULT NULL
) RETURNS TABLE (
    subscription_id CHAR(26),
    mcp_server_id CHAR(26),
    mcp_endpoint VARCHAR,
    mcp_auth_type VARCHAR,
    vault_secret_path VARCHAR,
    rate_limit_rps INTEGER,
    quota_per_day INTEGER,
    constraints JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id AS subscription_id,
        s.mcp_server_id,
        m.endpoint_url AS mcp_endpoint,
        m.auth_type AS mcp_auth_type,
        m.vault_secret_path,
        s.rate_limit_rps,
        s.quota_per_day,
        s.constraints
    FROM subscriptions s
    JOIN mcp_servers m ON s.mcp_server_id = m.id
    JOIN mcp_tools t ON t.mcp_server_id = m.id
    WHERE s.client_id = p_client_id
      AND t.name = p_tool_name
      AND s.status = 'active'
      AND m.status = 'active'
      AND m.deleted_at IS NULL
      AND (s.starts_at IS NULL OR s.starts_at <= NOW())
      AND (s.expires_at IS NULL OR s.expires_at > NOW())
      AND (s.scope_type = 'all' OR p_tool_name = ANY(s.scope_tools))
      AND (p_prefer_mcp_name IS NULL OR m.name = p_prefer_mcp_name)
    ORDER BY 
        CASE WHEN m.name = p_prefer_mcp_name THEN 0 ELSE 1 END,
        s.created_at DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP FUNCTION IF EXISTS resolve_tool_subscription;
DROP TABLE IF EXISTS audit_logs_y2025;
DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS credential_audit_log;
DROP TABLE IF EXISTS oauth_states;
DROP TABLE IF EXISTS subscription_usage;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS mcp_tools;
DROP TABLE IF EXISTS mcp_servers;
DROP TABLE IF EXISTS clients;
DROP TABLE IF EXISTS environments;
DROP TABLE IF EXISTS tenants;
DROP EXTENSION IF EXISTS "pgcrypto";
-- +goose StatementEnd
```

### sqlc Configuration

```yaml
# db/sqlc.yaml
version: "2"
sql:
  - engine: "postgresql"
    queries: "queries/"
    schema: "migrations/"
    gen:
      go:
        package: "gen"
        out: "../internal/database/gen"
        sql_package: "pgx/v5"
        emit_json_tags: true
        emit_interface: true
        emit_empty_slices: true
        emit_pointers_for_null_types: true
        json_tags_case_style: "snake"
```

### Example Queries (sqlc)

```sql
-- db/queries/subscriptions.sql

-- name: ResolveToolSubscription :one
SELECT * FROM resolve_tool_subscription($1, $2, $3);

-- name: CreateSubscription :one
INSERT INTO subscriptions (
    client_id, mcp_server_id, environment_id, name, description,
    scope_type, scope_tools, rate_limit_rps, quota_per_day, constraints
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10
) RETURNING *;

-- name: GetClientSubscriptions :many
SELECT s.*, m.name as mcp_server_name, m.display_name as mcp_display_name
FROM subscriptions s
JOIN mcp_servers m ON s.mcp_server_id = m.id
WHERE s.client_id = $1 AND s.status = 'active'
ORDER BY s.created_at DESC;

-- name: CheckDailyQuota :one
SELECT 
    s.quota_per_day,
    COALESCE(COUNT(u.id), 0)::INTEGER as used_today
FROM subscriptions s
LEFT JOIN subscription_usage u ON u.subscription_id = s.id 
    AND DATE(u.timestamp) = CURRENT_DATE
WHERE s.id = $1
GROUP BY s.quota_per_day;

-- name: RecordUsage :one
INSERT INTO subscription_usage (
    subscription_id, tool_name, request_id, duration_ms, status_code, tokens_used
) VALUES ($1, $2, $3, $4, $5, $6)
RETURNING id;
```

### Database Connection Code

```go
// internal/database/db.go
package database

import (
    "context"
    "fmt"
    "time"

    "github.com/jackc/pgx/v5/pgxpool"
    "github.com/giru-ai/giru/internal/database/gen"
)

type DB struct {
    Pool    *pgxpool.Pool
    Queries *gen.Queries
}

func Connect(ctx context.Context, databaseURL string) (*DB, error) {
    config, err := pgxpool.ParseConfig(databaseURL)
    if err != nil {
        return nil, fmt.Errorf("parse database URL: %w", err)
    }

    // Connection pool settings
    config.MaxConns = 25
    config.MinConns = 5
    config.MaxConnLifetime = time.Hour
    config.MaxConnIdleTime = 30 * time.Minute
    config.HealthCheckPeriod = time.Minute

    pool, err := pgxpool.NewWithConfig(ctx, config)
    if err != nil {
        return nil, fmt.Errorf("create connection pool: %w", err)
    }

    if err := pool.Ping(ctx); err != nil {
        return nil, fmt.Errorf("ping database: %w", err)
    }

    return &DB{
        Pool:    pool,
        Queries: gen.New(pool),
    }, nil
}

func (db *DB) Close() {
    db.Pool.Close()
}
```

### Makefile Targets for Database

```makefile
# Database targets
DATABASE_URL ?= postgresql://postgres:password@localhost:5432/giru

.PHONY: db-migrate
db-migrate: ## Run database migrations
	goose -dir db/migrations postgres "$(DATABASE_URL)" up

.PHONY: db-migrate-down
db-migrate-down: ## Rollback last migration
	goose -dir db/migrations postgres "$(DATABASE_URL)" down

.PHONY: db-migrate-status
db-migrate-status: ## Show migration status
	goose -dir db/migrations postgres "$(DATABASE_URL)" status

.PHONY: db-migrate-create
db-migrate-create: ## Create new migration (NAME=migration_name)
	@if [ -z "$(NAME)" ]; then echo "Usage: make db-migrate-create NAME=name"; exit 1; fi
	goose -dir db/migrations create $(NAME) sql

.PHONY: db-seed
db-seed: ## Load seed data
	@for f in db/seeds/*.sql; do psql "$(DATABASE_URL)" -f $$f; done

.PHONY: db-reset
db-reset: ## Reset database (migrate down, up, seed)
	goose -dir db/migrations postgres "$(DATABASE_URL)" reset
	$(MAKE) db-migrate
	$(MAKE) db-seed

.PHONY: sqlc-generate
sqlc-generate: ## Generate Go code from SQL
	cd db && sqlc generate

.PHONY: db-console
db-console: ## Open psql console
	psql "$(DATABASE_URL)"
```

---

## Policy Data Management

OPA policies reference external data (e.g., HIPAA permitted fields, PCI-DSS zones). This section describes how policy data is managed with a hybrid approach: default templates + tenant-specific overrides.

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                   Policy Data Flow                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Default Templates (shipped with Giru)                      │
│     policies/data/hipaa/permitted_fields.json                  │
│     policies/data/pci_dss/cardholder_zones.json               │
│                                                                 │
│  2. Tenant Overrides (stored in PostgreSQL)                    │
│     policy_data_overrides table                                │
│                                                                 │
│  3. Merged Data (cached in Redis)                              │
│     policy:<tenant_id>:<namespace>:<key>                       │
│     TTL: 5 minutes                                             │
│                                                                 │
│  4. OPA Bundle                                                 │
│     Control Plane pushes merged data to OPA                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Database Schema for Overrides

```sql
-- Add to db/migrations/00001_init.sql

-- ============================================================================
-- POLICY DATA OVERRIDES
-- ============================================================================
CREATE TABLE policy_data_overrides (
    id CHAR(26) PRIMARY KEY,                        -- ULID generated in application
    tenant_id CHAR(26) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    
    policy_namespace VARCHAR(100) NOT NULL,  -- 'hipaa', 'pci_dss', 'soc2'
    data_key VARCHAR(100) NOT NULL,          -- 'permitted_fields', 'cardholder_zones'
    data_value JSONB NOT NULL,               -- Customer's custom config
    
    created_by CHAR(26),                     -- User who created override
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(tenant_id, policy_namespace, data_key)
);

CREATE INDEX idx_policy_overrides_tenant ON policy_data_overrides(tenant_id);
CREATE INDEX idx_policy_overrides_namespace ON policy_data_overrides(policy_namespace);
```

### Go Implementation with Caching

```go
// internal/policy/data_service.go
package policy

import (
    "context"
    "encoding/json"
    "fmt"
    "time"
    
    "github.com/redis/go-redis/v9"
)

type DataService struct {
    db     *database.DB
    redis  *redis.Client
    defaults map[string]map[string]json.RawMessage // namespace -> key -> data
}

func NewDataService(db *database.DB, redis *redis.Client) *DataService {
    svc := &DataService{
        db:       db,
        redis:    redis,
        defaults: make(map[string]map[string]json.RawMessage),
    }
    svc.loadDefaults()
    return svc
}

// loadDefaults loads default policy data from embedded files
func (s *DataService) loadDefaults() {
    // Load from policies/data/ directory (embedded in binary)
    // Example: hipaa/permitted_fields.json
}

// GetPolicyData retrieves merged policy data (defaults + overrides) with caching
func (s *DataService) GetPolicyData(ctx context.Context, tenantID, namespace, key string) (json.RawMessage, error) {
    cacheKey := fmt.Sprintf("policy:%s:%s:%s", tenantID, namespace, key)
    
    // 1. Try cache first
    if cached, err := s.redis.Get(ctx, cacheKey).Bytes(); err == nil {
        return cached, nil
    }
    
    // 2. Cache miss - load and merge
    data, err := s.loadAndMerge(ctx, tenantID, namespace, key)
    if err != nil {
        return nil, err
    }
    
    // 3. Cache for 5 minutes
    s.redis.Set(ctx, cacheKey, data, 5*time.Minute)
    
    return data, nil
}

// loadAndMerge loads defaults and applies tenant overrides
func (s *DataService) loadAndMerge(ctx context.Context, tenantID, namespace, key string) (json.RawMessage, error) {
    // Start with defaults
    defaults, ok := s.defaults[namespace][key]
    if !ok {
        return nil, fmt.Errorf("no default data for %s/%s", namespace, key)
    }
    
    // Check for tenant override
    override, err := s.db.Queries.GetPolicyDataOverride(ctx, database.GetPolicyDataOverrideParams{
        TenantID:        tenantID,
        PolicyNamespace: namespace,
        DataKey:         key,
    })
    
    if err == nil {
        // Override exists - return it (full replacement)
        return override.DataValue, nil
    }
    
    // No override - return defaults
    return defaults, nil
}

// SetPolicyDataOverride creates or updates a tenant-specific override
func (s *DataService) SetPolicyDataOverride(ctx context.Context, tenantID, namespace, key string, data json.RawMessage) error {
    // Validate the data structure matches expected schema
    if err := s.validateData(namespace, key, data); err != nil {
        return fmt.Errorf("invalid data structure: %w", err)
    }
    
    // Upsert override
    err := s.db.Queries.UpsertPolicyDataOverride(ctx, database.UpsertPolicyDataOverrideParams{
        TenantID:        tenantID,
        PolicyNamespace: namespace,
        DataKey:         key,
        DataValue:       data,
    })
    if err != nil {
        return err
    }
    
    // Invalidate cache
    cacheKey := fmt.Sprintf("policy:%s:%s:%s", tenantID, namespace, key)
    s.redis.Del(ctx, cacheKey)
    
    return nil
}

// DeletePolicyDataOverride removes override, reverting to defaults
func (s *DataService) DeletePolicyDataOverride(ctx context.Context, tenantID, namespace, key string) error {
    err := s.db.Queries.DeletePolicyDataOverride(ctx, database.DeletePolicyDataOverrideParams{
        TenantID:        tenantID,
        PolicyNamespace: namespace,
        DataKey:         key,
    })
    if err != nil {
        return err
    }
    
    // Invalidate cache
    cacheKey := fmt.Sprintf("policy:%s:%s:%s", tenantID, namespace, key)
    s.redis.Del(ctx, cacheKey)
    
    return nil
}
```

### REST API Endpoints

```go
// internal/api/rest/handlers/policy_data.go

// GET /api/v1/policies/:namespace/:key
// Returns merged policy data (defaults + tenant override)
func (h *PolicyDataHandler) Get(c *fiber.Ctx) error {
    tenantID := c.Locals("tenant_id").(string)
    namespace := c.Params("namespace")
    key := c.Params("key")
    
    data, err := h.policyService.GetPolicyData(c.Context(), tenantID, namespace, key)
    if err != nil {
        return c.Status(404).JSON(fiber.Map{"error": err.Error()})
    }
    
    return c.JSON(fiber.Map{
        "namespace": namespace,
        "key":       key,
        "data":      data,
    })
}

// PUT /api/v1/policies/:namespace/:key
// Creates or updates tenant-specific override
func (h *PolicyDataHandler) Set(c *fiber.Ctx) error {
    tenantID := c.Locals("tenant_id").(string)
    namespace := c.Params("namespace")
    key := c.Params("key")
    
    var body json.RawMessage
    if err := c.BodyParser(&body); err != nil {
        return c.Status(400).JSON(fiber.Map{"error": "invalid JSON"})
    }
    
    if err := h.policyService.SetPolicyDataOverride(c.Context(), tenantID, namespace, key, body); err != nil {
        return c.Status(400).JSON(fiber.Map{"error": err.Error()})
    }
    
    return c.Status(200).JSON(fiber.Map{"status": "updated"})
}

// DELETE /api/v1/policies/:namespace/:key
// Removes override, reverts to defaults
func (h *PolicyDataHandler) Delete(c *fiber.Ctx) error {
    tenantID := c.Locals("tenant_id").(string)
    namespace := c.Params("namespace")
    key := c.Params("key")
    
    if err := h.policyService.DeletePolicyDataOverride(c.Context(), tenantID, namespace, key); err != nil {
        return c.Status(500).JSON(fiber.Map{"error": err.Error()})
    }
    
    return c.Status(200).JSON(fiber.Map{"status": "deleted", "message": "Reverted to defaults"})
}
```

### Default Policy Data Files

```json
// policies/data/hipaa/permitted_fields.json
{
  "physician": ["patient_id", "name", "diagnosis", "medications", "vitals", "lab_results"],
  "nurse": ["patient_id", "name", "medications", "vitals", "care_plan"],
  "billing": ["patient_id", "name", "insurance_id", "billing_codes"],
  "researcher": ["patient_id_hashed", "age_range", "diagnosis", "outcomes"]
}
```

```json
// policies/data/pci_dss/cardholder_zones.json
{
  "allowed_zones": [
    "secure-zone-1",
    "payment-processing-zone",
    "pci-compliant-datacenter"
  ]
}
```

### Usage Example

```bash
# View current HIPAA permitted fields (defaults + any overrides)
curl -X GET http://localhost:18000/api/v1/policies/hipaa/permitted_fields \
  -H "Authorization: Bearer $API_KEY"

# Override for this tenant (nurses can now see lab_results)
curl -X PUT http://localhost:18000/api/v1/policies/hipaa/permitted_fields \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "physician": ["patient_id", "name", "diagnosis", "medications", "vitals", "lab_results"],
    "nurse": ["patient_id", "name", "medications", "vitals", "care_plan", "lab_results"],
    "billing": ["patient_id", "name", "insurance_id", "billing_codes"],
    "researcher": ["patient_id_hashed", "age_range", "diagnosis", "outcomes"]
  }'

# Reset to defaults
curl -X DELETE http://localhost:18000/api/v1/policies/hipaa/permitted_fields \
  -H "Authorization: Bearer $API_KEY"
```

---

## Authentication & Credential Management

### Overview

Giru solves a critical UX problem: **MCP credential management hell**. Users typically manage OAuth tokens, API keys, and connection strings manually across dozens of MCP servers. Giru abstracts this completely.

**User Experience**:
- Click "Connect GitHub MCP" → OAuth flow → Done (never see tokens)
- Tokens automatically refreshed before expiration
- Zero configuration files, zero credential sprawl
- Audit trail of every credential access (SOC2/HIPAA compliant)

### The Three Authentication Layers

```
┌─────────────────────────────────────────────────────────────────┐
│ Layer 1: User → Giru Gateway                                    │
│ Purpose: Authenticate WHO is using the platform                 │
│ Methods: API Keys (Open Core), SSO (Enterprise)                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ Layer 2: Client (AI Agent) → Giru Gateway                       │
│ Purpose: Authenticate WHICH agent is making requests            │
│ Methods: API Keys, OAuth 2.1 Client Credentials                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ Layer 3: Giru Gateway → MCP Servers (THE HARD PART)             │
│ Purpose: Authenticate TO backend MCP services                   │
│ Reality: Every MCP has different auth (OAuth, API keys, etc)   │
│ Solution: Giru stores credentials in HashiCorp Vault           │
└─────────────────────────────────────────────────────────────────┘
```

### Why HashiCorp Vault?

| Feature | Vault | Cloud KMS | pgcrypto |
|---------|-------|-----------|----------|
| Cloud-agnostic | ✅ | ❌ Lock-in | ✅ |
| Self-hosted | ✅ | ❌ | ✅ |
| Dynamic secrets | ✅ | ❌ | ❌ |
| Auto rotation | ✅ | ❌ | ❌ |
| Audit logging | ✅ | ✅ | ❌ |
| Cost | Free OSS | Pay per call | Free |

**Strategy**: Vault is the **default** for all deployments (including development). pgcrypto is available as a **fallback** for environments where Vault is not available.

```yaml
# Environment configuration
GIRU_CREDENTIAL_STORE=vault      # Default: vault, fallback: pgcrypto

# Vault configuration (required when GIRU_CREDENTIAL_STORE=vault)
GIRU_VAULT_ADDR=http://vault:8200
GIRU_VAULT_TOKEN=...             # Or use Kubernetes auth

# pgcrypto fallback (only when GIRU_CREDENTIAL_STORE=pgcrypto)
GIRU_PGCRYPTO_KEY=...            # Symmetric encryption key
```

**Why Vault as Default?**
- Docker Compose includes Vault in dev mode (zero setup)
- Consistent behavior between development and production
- Developers learn Vault patterns early
- pgcrypto fallback exists for edge cases (air-gapped, minimal deployments)

### Credential Flow Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                     OAuth Flow Example                          │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  1. User clicks: "Connect GitHub MCP"                          │
│       │                                                        │
│       ▼                                                        │
│  2. Giru redirects to GitHub OAuth                            │
│       │                                                        │
│       ▼                                                        │
│  3. User approves in GitHub                                   │
│       │                                                        │
│       ▼                                                        │
│  4. GitHub sends token to Giru (NOT user)                     │
│       │                                                        │
│       ▼                                                        │
│  5. Giru stores token in Vault                                │
│     Path: secret/tenants/{tenant_id}/mcp/github               │
│       │                                                        │
│       ▼                                                        │
│  6. Done! User never sees the token                           │
│                                                                │
└────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────────┐
│                     Runtime Usage                               │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  1. AI agent calls: github__list_repos                        │
│       │                                                        │
│       ▼                                                        │
│  2. Giru looks up subscription → finds GitHub MCP             │
│       │                                                        │
│       ▼                                                        │
│  3. Giru fetches token from Vault                             │
│       │                                                        │
│       ▼                                                        │
│  4. Giru calls GitHub MCP with token                          │
│       │                                                        │
│       ▼                                                        │
│  5. Returns result to AI agent                                │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

### Vault Go Client

```go
// internal/vault/client.go
package vault

import (
    "context"
    "fmt"
    "time"
    
    vaultapi "github.com/hashicorp/vault/api"
)

type Client struct {
    client *vaultapi.Client
}

type OAuthToken struct {
    AccessToken  string    `json:"access_token"`
    RefreshToken string    `json:"refresh_token,omitempty"`
    TokenType    string    `json:"token_type"`
    ExpiresAt    time.Time `json:"expires_at"`
    Scopes       []string  `json:"scopes"`
}

func NewClient(address, token string) (*Client, error) {
    config := vaultapi.DefaultConfig()
    config.Address = address
    
    client, err := vaultapi.NewClient(config)
    if err != nil {
        return nil, fmt.Errorf("create vault client: %w", err)
    }
    
    client.SetToken(token)
    return &Client{client: client}, nil
}

func (v *Client) StoreOAuthToken(ctx context.Context, tenantID, provider string, token *OAuthToken) (string, int, error) {
    path := fmt.Sprintf("tenants/%s/mcp/%s", tenantID, provider)
    
    data := map[string]interface{}{
        "access_token":  token.AccessToken,
        "refresh_token": token.RefreshToken,
        "token_type":    token.TokenType,
        "expires_at":    token.ExpiresAt.Format(time.RFC3339),
        "scopes":        token.Scopes,
    }
    
    secret, err := v.client.KVv2("secret").Put(ctx, path, data)
    if err != nil {
        return "", 0, fmt.Errorf("store token: %w", err)
    }
    
    fullPath := fmt.Sprintf("secret/data/%s", path)
    version := int(secret.VersionMetadata.Version)
    
    return fullPath, version, nil
}

func (v *Client) GetOAuthToken(ctx context.Context, path string) (*OAuthToken, error) {
    cleanPath := strings.TrimPrefix(path, "secret/data/")
    
    secret, err := v.client.KVv2("secret").Get(ctx, cleanPath)
    if err != nil {
        return nil, fmt.Errorf("get token: %w", err)
    }
    
    data := secret.Data
    expiresAt, _ := time.Parse(time.RFC3339, data["expires_at"].(string))
    
    return &OAuthToken{
        AccessToken:  data["access_token"].(string),
        RefreshToken: data["refresh_token"].(string),
        TokenType:    data["token_type"].(string),
        ExpiresAt:    expiresAt,
    }, nil
}
```

### Token Refresh Job

```go
// internal/jobs/token_refresher.go
package jobs

func (r *TokenRefresher) Run(ctx context.Context) {
    ticker := time.NewTicker(1 * time.Hour)
    defer ticker.Stop()
    
    for {
        select {
        case <-ticker.C:
            r.refreshExpiringTokens(ctx)
        case <-ctx.Done():
            return
        }
    }
}

func (r *TokenRefresher) refreshExpiringTokens(ctx context.Context) {
    // Find tokens expiring in next 24 hours
    servers, err := r.db.GetMCPServersWithExpiringTokens(ctx, time.Now().Add(24*time.Hour))
    if err != nil {
        log.Printf("Error fetching expiring tokens: %v", err)
        return
    }
    
    for _, server := range servers {
        if !server.TokenRefreshEnabled {
            continue
        }
        
        // Get current token from Vault
        oldToken, err := r.vault.GetOAuthToken(ctx, server.VaultSecretPath)
        if err != nil {
            continue
        }
        
        // Refresh using provider-specific client
        refresher := r.getRefresher(server.AuthProvider)
        newToken, err := refresher.Refresh(ctx, oldToken.RefreshToken)
        if err != nil {
            log.Printf("Failed to refresh %s: %v", server.Name, err)
            continue
        }
        
        // Store new token in Vault
        _, version, _ := r.vault.StoreOAuthToken(ctx, server.TenantID, server.AuthProvider, newToken)
        
        // Update database
        r.db.UpdateMCPServerToken(ctx, server.ID, version, newToken.ExpiresAt)
        
        log.Printf("Refreshed token for %s", server.Name)
    }
}
```

---

## Compliance Policy Code

Pre-built compliance blueprints that differentiate Giru from generic gateways.

### Policy Directory Structure

```
policies/
├── compliance/
│   ├── hipaa/
│   │   ├── minimum_necessary.rego
│   │   └── access_controls.rego
│   ├── pci_dss/
│   │   ├── cardholder_data.rego
│   │   └── access_control.rego
│   └── soc2/
│       ├── access_control.rego
│       └── monitoring.rego
├── data/                            # Customer-configurable data
│   ├── hipaa/
│   │   └── permitted_fields.json
│   └── pci_dss/
│       └── cardholder_zones.json
└── tests/
    └── compliance_test.rego
```

### HIPAA: Minimum Necessary Standard

```rego
# policies/compliance/hipaa/minimum_necessary.rego
# Implements 45 CFR § 164.502(b)

package hipaa.minimum_necessary

import future.keywords.if
import future.keywords.in

default allow := false

# Detect PHI requests
is_phi_request if {
    some tag in input.mcp.tool.tags
    tag == "phi"
}

is_phi_request if {
    contains(lower(input.mcp.tool.name), "patient")
}

# Deny excessive record requests
deny[msg] if {
    is_phi_request
    input.mcp.arguments.record_count > input.context.clinical_need_threshold
    msg := sprintf(
        "HIPAA: Requesting %d records exceeds threshold of %d",
        [input.mcp.arguments.record_count, input.context.clinical_need_threshold]
    )
}

# Deny unauthorized fields
deny[msg] if {
    is_phi_request
    some field in input.mcp.arguments.fields
    not field in data.hipaa.permitted_fields[input.context.user_role]
    msg := sprintf(
        "HIPAA: Field '%s' not permitted for role '%s'",
        [field, input.context.user_role]
    )
}

# Allow if all checks pass
allow if {
    is_phi_request
    count(deny) == 0
    input.context.user_authenticated
}

# Audit requirement
audit_entry[entry] if {
    is_phi_request
    allow
    entry := {
        "timestamp": time.now_ns(),
        "user_id": input.context.user_id,
        "tool_name": input.mcp.tool.name,
        "fields_accessed": input.mcp.arguments.fields,
        "compliance_framework": "HIPAA_164.502(b)",
    }
}
```

### PCI-DSS: Cardholder Data Protection

```rego
# policies/compliance/pci_dss/cardholder_data.rego
# Implements PCI-DSS Requirement 3

package pci_dss.cardholder_data

import future.keywords.if
import future.keywords.in

is_cardholder_data if {
    some tag in input.mcp.tool.tags
    tag in ["pci", "payment", "cardholder_data"]
}

# Detect full PAN (Primary Account Number)
deny[msg] if {
    is_cardholder_data
    some arg_name, arg_value in input.mcp.arguments
    is_full_pan(arg_value)
    msg := sprintf(
        "PCI-DSS 3.4: Full PAN detected in '%s'. Must be masked/truncated",
        [arg_name]
    )
}

is_full_pan(value) if {
    is_string(value)
    cleaned := replace(replace(value, " ", ""), "-", "")
    count(cleaned) >= 13
    count(cleaned) <= 19
    regex.match(`^\d+$`, cleaned)
}

# Require encryption key management
deny[msg] if {
    is_cardholder_data
    not input.context.encryption_key_management_enabled
    msg := "PCI-DSS 3.5: Cardholder data requires encryption key management"
}
```

### SOC2: Access Control

```rego
# policies/compliance/soc2/access_control.rego
# Implements CC6.0 - Logical Access Controls

package soc2.access_control

import future.keywords.if

# CC6.1: Require authentication
deny[msg] if {
    not input.context.user_authenticated
    msg := "SOC2 CC6.1: Unauthenticated access not permitted"
}

# CC6.1: Require MFA for high-sensitivity tools
deny[msg] if {
    not input.context.mfa_verified
    input.mcp.tool.sensitivity_level == "high"
    msg := "SOC2 CC6.1: MFA required for high-sensitivity tools"
}

# CC6.3: Check for expired access
deny[msg] if {
    last_cert := data.soc2.user_certifications[input.context.user_id].last_certified_ns
    days_since_cert := (time.now_ns() - last_cert) / 86400000000000
    days_since_cert > 90
    msg := "SOC2 CC6.3: User access expired, re-certification required"
}

# Audit entry
audit_entry[entry] if {
    allow
    entry := {
        "timestamp": time.now_ns(),
        "event_type": "mcp_tool_access",
        "user_id": input.context.user_id,
        "tool_name": input.mcp.tool.name,
        "trust_service": "CC6",
    }
}
```

### Policy Data Configuration

```json
// policies/data/hipaa/permitted_fields.json
{
  "physician": ["patient_id", "name", "diagnosis", "medications", "vitals", "lab_results"],
  "nurse": ["patient_id", "name", "medications", "vitals", "care_plan"],
  "billing": ["patient_id", "name", "insurance_id", "billing_codes"],
  "researcher": ["patient_id_hashed", "age_range", "diagnosis", "outcomes"]
}
```

### Policy Testing

```rego
# policies/tests/compliance_test.rego
package hipaa.minimum_necessary_test

import data.hipaa.minimum_necessary

test_deny_excessive_records {
    input := {
        "mcp": {
            "tool": {"name": "get_patient_records", "tags": ["phi"]},
            "arguments": {"record_count": 100, "fields": ["patient_id"]}
        },
        "context": {
            "user_id": "user123",
            "user_role": "physician",
            "user_authenticated": true,
            "clinical_need_threshold": 10
        }
    }
    
    count(minimum_necessary.deny) > 0
}

test_allow_appropriate_request {
    input := {
        "mcp": {
            "tool": {"name": "get_patient_records", "tags": ["phi"]},
            "arguments": {"record_count": 5, "fields": ["patient_id"]}
        },
        "context": {
            "user_id": "user123",
            "user_role": "physician",
            "user_authenticated": true,
            "clinical_need_threshold": 10
        }
    }
    
    minimum_necessary.allow
}
```

---

## Key Implementation Requirements

### Technology Stack Summary

| Layer | Technology | Purpose | Swappable? |
|-------|------------|---------|------------|
| Proxy | Envoy 1.28+ (default) | High-performance routing, TLS, rate limiting | ✅ Enterprise: Kong, NGINX |
| Policy | OPA (default) | Authorization, compliance, parameter validation | ✅ Enterprise: Cedar, SpiceDB |
| Control Plane | Go 1.21+ / Fiber | REST API, xDS server, business logic | ❌ Core component |
| Database | PostgreSQL 15+ | Configuration, audit logs | ❌ Core component |
| Cache | Redis 7+ | Rate limiting, sessions | ❌ Core component |
| UI | Svelte 5 / SvelteKit 2 | Admin dashboard (Enterprise) | ❌ Core component |
| Credentials | HashiCorp Vault | Secret storage, rotation | ❌ Core component |

### Feature Matrix: Open Source vs Enterprise

| Feature | Community | Enterprise |
|---------|-----------|------------|
| **Core Gateway** | | |
| MCP gateway core | ✅ | ✅ |
| xDS dynamic config | ✅ | ✅ |
| Basic rate limiting | ✅ | ✅ |
| API key auth | ✅ | ✅ |
| REST API | ✅ | ✅ |
| CLI | ✅ | ✅ |
| PostgreSQL + Redis | ✅ | ✅ |
| Prometheus metrics | ✅ | ✅ |
| Docker Compose | ✅ | ✅ |
| Kubernetes manifests | ✅ | ✅ |
| Basic compliance policies | ✅ | ✅ |
| **Proxy Providers** | | |
| Envoy (default) | ✅ | ✅ |
| Envoy AI Gateway integration | ✅ | ✅ |
| Kong Gateway | ❌ | ✅ |
| NGINX | ❌ | ✅ |
| Custom proxy adapters | ❌ | ✅ |
| **Policy Engines** | | |
| OPA/Rego (default) | ✅ | ✅ |
| AWS Cedar | ❌ | ✅ |
| SpiceDB (Zanzibar) | ❌ | ✅ |
| Custom policy adapters | ❌ | ✅ |
| **Authentication** | | |
| SSO (SAML/OIDC) | ❌ | ✅ |
| MFA | ❌ | ✅ |
| **Enterprise Features** | | |
| Multi-tenancy | ❌ | ✅ |
| Enhanced audit logs | ❌ | ✅ |
| Advanced compliance (HIPAA/PCI-DSS) | ❌ | ✅ |
| Web UI | Basic | Full |
| Approval workflows | ❌ | ✅ |
| Usage-based billing | ❌ | ✅ |
| 24/7 support | ❌ | ✅ |

### License Management (Enterprise)

```go
// giru-enterprise/internal/license/manager.go
package license

type License struct {
    CustomerID   string
    Features     []string
    ExpiresAt    time.Time
    MaxTenants   int
    MaxServers   int
    Support      string // standard, premium, enterprise
}

func (m *Manager) Validate() (*License, error) {
    // Load from file or environment
    licenseData, err := loadLicense()
    if err != nil {
        return nil, fmt.Errorf("no valid license found")
    }
    
    // Verify RSA signature
    if err := m.verifySignature(licenseData); err != nil {
        return nil, fmt.Errorf("invalid license signature")
    }
    
    lic, _ := parseLicense(licenseData)
    if time.Now().After(lic.ExpiresAt) {
        return nil, fmt.Errorf("license expired")
    }
    
    return lic, nil
}

func (m *Manager) HasFeature(feature string) bool {
    lic, _ := m.Validate()
    if lic == nil {
        return false
    }
    return slices.Contains(lic.Features, feature)
}
```

**Feature Constants:**
```go
const (
    FeatureSSO                = "sso"
    FeatureMFA                = "mfa"
    FeatureMultiTenancy       = "multi_tenancy"
    FeatureAdvancedAudit      = "advanced_audit"
    FeatureCompliancePolicies = "compliance_policies"
    FeatureApprovalWorkflows  = "approval_workflows"
    FeatureUsageBilling       = "usage_billing"
)
```

---

## Development Environment Configurations

### Tier 1: Docker Compose (Primary Development - 95% of time)

Fast iteration, no Kubernetes knowledge required.

```yaml
# deployments/docker-compose/docker-compose.dev.yml
version: '3.8'

services:
  envoy:
    image: envoyproxy/envoy:v1.28
    ports:
      - "8080:8080"   # Gateway
      - "9901:9901"   # Admin
    volumes:
      - ./envoy.yaml:/etc/envoy/envoy.yaml
    depends_on:
      - opa
      - control-plane
    networks:
      - giru

  opa:
    image: openpolicyagent/opa:latest
    ports:
      - "8181:8181"
    command: ["run", "--server", "--addr=0.0.0.0:8181", "/policies"]
    volumes:
      - ../../policies:/policies:ro
    networks:
      - giru

  control-plane:
    build:
      context: ../../
      dockerfile: build/docker/Dockerfile.dev
    ports:
      - "18000:18000"  # REST API
      - "19000:19000"  # gRPC (xDS)
    environment:
      - DATABASE_URL=postgresql://postgres:password@postgres:5432/giru
      - REDIS_URL=redis://redis:6379
      - OPA_URL=http://opa:8181
      - GIRU_LOG_LEVEL=debug
    volumes:
      - ../../:/app:ro
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - giru

  postgres:
    image: postgres:15-alpine
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_DB=giru
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - giru
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    volumes:
      - redis-data:/data
    networks:
      - giru
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
    networks:
      - giru

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    depends_on:
      - prometheus
    networks:
      - giru

volumes:
  postgres-data:
  redis-data:

networks:
  giru:
    driver: bridge
```

### Tier 2: kind + Skaffold (Kubernetes Testing - 5% of time)

Real Kubernetes for integration testing.

```yaml
# deployments/kind/kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: giru-dev
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 30080
        hostPort: 8080
      - containerPort: 30300
        hostPort: 3000
  - role: worker
  - role: worker
```

```yaml
# deployments/kind/skaffold.yaml
apiVersion: skaffold/v4beta6
kind: Config
metadata:
  name: giru-gateway

build:
  artifacts:
    - image: giru/control-plane
      ko:
        dependencies:
          paths:
            - cmd/**
            - internal/**
            - pkg/**
  local:
    push: false
    useBuildkit: true

deploy:
  kubectl:
    defaultNamespace: giru-dev
    manifests:
      - ../kubernetes/base/*.yaml

portForward:
  - resourceType: service
    resourceName: giru-gateway
    port: 8080
    localPort: 8080
```

### Development Commands

```makefile
# Development targets

.PHONY: dev-setup
dev-setup: deps ## One-time development setup
	./scripts/setup/install-dev.sh
	$(MAKE) dev-up
	$(MAKE) db-migrate
	$(MAKE) db-seed

.PHONY: dev-up
dev-up: ## Start Docker Compose environment
	docker-compose -f deployments/docker-compose/docker-compose.dev.yml up -d
	@echo "Gateway:     http://localhost:8080"
	@echo "API:         http://localhost:18000"
	@echo "Envoy Admin: http://localhost:9901"
	@echo "OPA:         http://localhost:8181"
	@echo "Prometheus:  http://localhost:9090"
	@echo "Grafana:     http://localhost:3000"

.PHONY: dev-down
dev-down: ## Stop Docker Compose environment
	docker-compose -f deployments/docker-compose/docker-compose.dev.yml down

.PHONY: dev-logs
dev-logs: ## Tail logs from all services
	docker-compose -f deployments/docker-compose/docker-compose.dev.yml logs -f

.PHONY: dev-restart
dev-restart: dev-down dev-up ## Restart environment

# kind + Skaffold
.PHONY: kind-create
kind-create: ## Create kind cluster
	kind create cluster --config deployments/kind/kind-config.yaml

.PHONY: kind-delete
kind-delete: ## Delete kind cluster
	kind delete cluster --name giru-dev

.PHONY: skaffold-dev
skaffold-dev: ## Run Skaffold in dev mode
	cd deployments/kind && skaffold dev
```

### Hot Reload Configuration

**Go (air):**
```toml
# .air.toml
root = "."
tmp_dir = "tmp"

[build]
cmd = "go build -o ./tmp/giru-server ./cmd/giru-server"
bin = "tmp/giru-server"
include_ext = ["go", "yaml"]
exclude_dir = ["tmp", "vendor", "web-ui"]
```

**Svelte (Vite):**
```javascript
// web-ui/vite.config.ts
export default {
  server: {
    proxy: {
      '/api': 'http://localhost:18000',
      '/ws': { target: 'ws://localhost:18000', ws: true }
    }
  }
}
```

---

## CI/CD Pipelines

### GitHub Actions: CI

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.21'
      - name: golangci-lint
        uses: golangci/golangci-lint-action@v3

  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_DB: giru_test
          POSTGRES_PASSWORD: test
        ports:
          - 5432:5432
      redis:
        image: redis:7
        ports:
          - 6379:6379
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.21'
      - name: Run tests
        env:
          DATABASE_URL: postgresql://postgres:test@localhost:5432/giru_test
          REDIS_URL: redis://localhost:6379
        run: make test-go

  test-policies:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup OPA
        uses: open-policy-agent/setup-opa@v2
      - name: Test policies
        run: make test-policies

  build:
    runs-on: ubuntu-latest
    needs: [lint, test, test-policies]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.21'
      - name: Build
        run: make build
      - name: Build Docker images
        run: make docker-build
```

### GitHub Actions: Release

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.21'
      
      - name: Build binaries
        run: |
          GOOS=linux GOARCH=amd64 make build
          GOOS=darwin GOARCH=arm64 make build
      
      - name: Build and push Docker images
        run: |
          echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
          make docker-build docker-push
      
      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            bin/*
          generate_release_notes: true
```

---

## Initial Implementation Priority

Implementation is organized by priority level, not timelines. Complete each priority level before moving to the next.

### Priority 1: Foundation (MVP Core)

**Goal**: Working MCP gateway with basic features
**Prerequisite**: None - start here

- [ ] Repository structure and licensing
- [ ] Database schema and migrations (Goose)
- [ ] sqlc query generation
- [ ] Basic Envoy configuration
- [ ] OPA integration (authorization policies)
- [ ] Control plane REST API (Fiber)
  - Tenants CRUD
  - Clients CRUD
  - MCP Servers CRUD
  - Subscriptions CRUD
- [ ] MCP JSON-RPC handler (tools/list, tools/call)
- [ ] API key authentication
- [ ] Rate limiting (Redis)
- [ ] Docker Compose development environment
- [ ] Basic CLI (`giru server list`, `giru client create`)
- [ ] Documentation (quick start, architecture)

### Priority 2: Production Ready

**Goal**: Deployable to production Kubernetes
**Prerequisite**: Priority 1 complete

- [ ] xDS server for dynamic Envoy config
- [ ] Kubernetes manifests (Kustomize)
- [ ] Helm chart
- [ ] Prometheus metrics
- [ ] Grafana dashboards
- [ ] Distributed tracing (Jaeger)
- [ ] Health checks and readiness probes
- [ ] CI/CD pipelines (GitHub Actions)
- [ ] Integration tests
- [ ] Security hardening
- [ ] HashiCorp Vault integration
- [ ] OAuth flow for MCP servers
- [ ] Token refresh job
- [ ] Production deployment guide

### Priority 3: Enterprise Features

**Goal**: Enterprise-ready with compliance
**Prerequisite**: Priority 2 complete

- [ ] License management system
- [ ] SSO integration (SAML, OIDC)
- [ ] Multi-tenancy with isolation
- [ ] Enhanced audit logging
- [ ] Compliance policies (HIPAA, PCI-DSS, SOC2)
- [ ] Svelte admin UI
- [ ] Approval workflows
- [ ] Advanced analytics
- [ ] Enterprise Helm chart
- [ ] Enterprise documentation

### Priority 4: Launch Readiness

**Goal**: Public launch ready
**Prerequisite**: Priority 3 complete

- [ ] Performance optimization
- [ ] Load testing (100K+ RPS target)
- [ ] Security audit
- [ ] Documentation polish
- [ ] Video tutorials
- [ ] Example applications
- [ ] Community launch
- [ ] Marketing website

### Priority 5: Managed SaaS (Future)

**Goal**: Multi-tenant SaaS platform
**Prerequisite**: Priority 4 complete, market validation

- [ ] Multi-tenant control plane
- [ ] Usage metering
- [ ] Billing integration (Stripe)
- [ ] Customer portal
- [ ] Self-service signup
- [ ] SLA monitoring
- [ ] Official SDKs (TypeScript, Python, Go)
- [ ] Terraform provider

---

## Post-MVP Roadmap

This section tracks improvements and optimizations to implement after MVP is stable and deployed. Items are prioritized based on user feedback and real usage data.

### Performance Optimizations

| Item | Priority | Trigger | Description |
|------|----------|---------|-------------|
| Connection pooling tuning | High | > 1K concurrent connections | Tune pgx pool settings based on actual load |
| Query optimization | High | P99 > 10ms for any query | Add indexes, optimize slow queries identified in production |
| Redis cluster mode | Medium | > 10K req/sec rate limiting | Migrate from single Redis to cluster for rate limiting |
| gRPC for internal calls | Medium | Control plane latency | Replace HTTP between services with gRPC |
| Response caching | Low | Read-heavy workloads | Cache tools/list responses per client |

### Scalability Improvements

| Item | Priority | Trigger | Description |
|------|----------|---------|-------------|
| Horizontal Pod Autoscaling tuning | High | Variable traffic | Tune HPA based on real metrics |
| Database read replicas | Medium | > 5K read queries/sec | Add PostgreSQL read replicas |
| Sharding strategy | Low | > 1M subscriptions | Plan for data partitioning |
| Multi-region support | Low | Enterprise customers | Geographic distribution |

### Operational Improvements

| Item | Priority | Description |
|------|----------|-------------|
| Better error messages | High | Improve error context for debugging |
| Structured logging improvements | High | Add correlation IDs, request tracing |
| Health check granularity | Medium | Detailed health endpoints per component |
| Chaos testing | Medium | Implement fault injection testing |
| Runbook automation | Medium | Self-healing for common issues |
| Cost monitoring | Low | Track infrastructure costs per tenant |

### Developer Experience

| Item | Priority | Description |
|------|----------|-------------|
| CLI autocomplete | High | Bash/Zsh completion for giru CLI |
| Better validation errors | High | Actionable error messages for manifests |
| Local policy testing | Medium | `giru policy test` command |
| Mock MCP servers | Medium | Built-in mock servers for testing |
| VS Code extension | Low | Syntax highlighting for Giru manifests |

### Security Hardening

| Item | Priority | Description |
|------|----------|-------------|
| Rate limit per IP | High | Add IP-based rate limiting (DDoS protection) |
| API key rotation | High | Built-in key rotation workflow |
| mTLS everywhere | Medium | Mutual TLS between all services |
| Secret scanning | Medium | Prevent secrets in logs/responses |
| Penetration testing | Low | Third-party security audit |

### Caching Optimizations

| Item | Priority | Description |
|------|----------|-------------|
| Policy data cache warming | Medium | Pre-warm cache on startup |
| Subscription resolution cache | Medium | Cache client→tool→MCP resolution |
| MCP server capabilities cache | Low | Cache initialize responses |
| Negative cache | Low | Cache "subscription not found" to prevent repeated lookups |

### Monitoring Enhancements

| Item | Priority | Description |
|------|----------|-------------|
| Custom Grafana dashboards | High | Per-tenant usage, compliance violations |
| Alerting rules | High | PagerDuty/Slack integration |
| SLO tracking | Medium | Track against 99.9% availability target |
| Cost per request | Medium | Calculate and track request costs |
| Anomaly detection | Low | ML-based unusual pattern detection |

### Feature Enhancements (Non-Enterprise)

| Item | Priority | Description |
|------|----------|-------------|
| Webhook notifications | Medium | Notify on subscription events |
| API versioning | Medium | Support /v2/ endpoints |
| Batch operations | Low | Bulk create/update APIs |
| GraphQL API | Low | Alternative to REST |

### Documentation

| Item | Priority | Description |
|------|----------|-------------|
| Video tutorials | High | Quick start, common use cases |
| Architecture deep-dives | Medium | Blog posts on design decisions |
| Troubleshooting guide | Medium | Common issues and solutions |
| Performance tuning guide | Low | How to optimize for high throughput |

---

## Success Metrics

### Technical Metrics
| Metric | Target |
|--------|--------|
| Throughput | 100K+ RPS |
| Latency (P99) | < 5ms |
| Uptime | 99.99% |
| Test Coverage | 80%+ code, 100% policies |
| Security | Zero critical CVEs |

### Business Metrics
| Metric | Target |
|--------|--------|
| Time to Value | < 15 minutes |
| GitHub Stars | 1,000+ (Year 1) |
| Docker Pulls | 10,000+ (Year 1) |
| Enterprise Customers | 10 (Year 1) |
| Support Satisfaction | > 90% CSAT |

### Developer Metrics
| Metric | Target |
|--------|--------|
| Build Time | < 5 minutes |
| Deploy Time | < 10 minutes |
| PR Review Time | < 24 hours |
| Issue Resolution | < 7 days average |

---

## AI-First Development

This project uses **AI-first development** (Vibe Coding) with Claude Code. All development follows structured workflows with specialized agents.

### Required Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Main AI instructions, The Five Golden Rules |
| `.claude/AI_WORKFLOW.md` | Development phases and conventions |
| `.claude/context/agents/PRE-FLIGHT-CHECKLIST.md` | Mandatory pre-coding checklist |
| `.claude/context/INDEX.md` | Navigation to all context files |

### Directory Structure

```
.claude/
├── agents/              # Specialized agent profiles
│   ├── backend-architect.md
│   ├── database-optimizer.md
│   ├── policy-engineer.md
│   ├── envoy-specialist.md
│   ├── frontend-developer.md
│   ├── security-auditor.md
│   ├── test-automator.md
│   ├── mcp-integration.md
│   ├── devops-engineer.md
│   ├── documentation-writer.md
│   └── code-reviewer.md
├── hooks/               # Automation scripts
│   ├── pre-task.sh
│   ├── pre-commit.sh
│   └── post-task.sh
├── commands/            # Custom slash commands
├── settings.json        # Project configuration
├── AI_WORKFLOW.md       # Development workflow
├── context/
│   ├── INDEX.md         # Navigation index
│   ├── agents/          # Agent-specific context
│   │   └── PRE-FLIGHT-CHECKLIST.md
│   ├── domains/         # Domain knowledge
│   ├── architecture/    # Architecture docs
│   ├── patterns/        # Code patterns
│   └── integrations/    # Integration guides
└── tasks/
    ├── TASK_TEMPLATE.md # Template for new tasks
    ├── active/          # Current work
    ├── backlog/         # Pending tasks
    └── completed/       # Finished tasks
```

### The Five Golden Rules (Summary)

**CRITICAL: These rules apply to ALL code in this project.**

#### Backend (Go)
1. **IDs**: `ulid.Make().String()` - NEVER `uuid.New()`
2. **Multi-Tenant**: `tenant_id` in EVERY database query
3. **Errors**: Check ALL errors - NEVER ignore with `_`
4. **Money**: `int64` cents - NEVER float
5. **Soft Delete**: `deleted_at IS NULL` in ALL SELECTs

#### Database (PostgreSQL)
1. **Tables**: ALL have `tenant_id`, `created_at`, `updated_at`, `deleted_at`
2. **IDs**: Primary keys are `CHAR(26)` for ULIDs
3. **Queries**: ALL include `deleted_at IS NULL`
4. **Isolation**: NEVER query across tenants
5. **Money**: `DECIMAL(10,2)`, store as cents in app

#### OPA Policies
1. **Default**: Always `default allow := false`
2. **Tenant**: Every policy verifies `tenant_id`
3. **Roles**: Respect hierarchy (admin > manager > user)
4. **Audit**: Log all authorization decisions
5. **Isolation**: Never expose cross-tenant data

#### Frontend (Svelte)
1. **State**: Svelte 5 runes (`$state`, `$derived`, `$effect`)
2. **Types**: Full TypeScript - NEVER `any`
3. **API**: Include tenant context header
4. **Auth**: Check on EVERY protected route
5. **Errors**: User-friendly messages, log technical

### Development Workflow

1. **Task Definition**: Create task file from template
2. **Context Loading**: Complete PRE-FLIGHT-CHECKLIST
3. **Implementation**: Follow agent guidelines
4. **Validation**: Run tests, security checks
5. **Completion**: Update task, commit changes

### Agent Selection

| Task Type | Agent |
|-----------|-------|
| API endpoints, services | backend-architect |
| Schema, queries, migrations | database-optimizer |
| Authorization, RBAC | policy-engineer |
| Gateway, routing | envoy-specialist |
| UI components | frontend-developer |
| Security review | security-auditor |
| Writing tests | test-automator |
| MCP protocol | mcp-integration |
| Docker, CI/CD | devops-engineer |
| Documentation | documentation-writer |
| Code review | code-reviewer |

---

## Final Notes for Claude Code

### Approach
1. Start with core infrastructure (Envoy, OPA, basic control plane)
2. Get local development working first (Docker Compose)
3. Add features iteratively
4. Test thoroughly at each step
5. Document as you build

### Code Quality
- Follow Go standards (gofmt, golangci-lint)
- TypeScript strict mode for Svelte
- Comprehensive error handling
- Structured logging everywhere
- Security-first mindset

### Environment Variables

All environment variables should use the `GIRU_` prefix for consistency:

```bash
# Database
GIRU_DATABASE_URL=postgresql://...
GIRU_REDIS_URL=redis://...

# Vault
GIRU_VAULT_ADDR=http://vault:8200
GIRU_VAULT_TOKEN=...

# OPA
GIRU_OPA_URL=http://opa:8181

# Server
GIRU_HTTP_PORT=18000
GIRU_GRPC_PORT=19000
GIRU_LOG_LEVEL=info

# License (Enterprise)
GIRU_LICENSE_KEY=...
```

### Configuration Over Code
- Make everything configurable
- Sensible defaults
- Environment-specific overrides
- Validation at load time

### Future-Proofing
- gRPC for all internal APIs
- OpenTelemetry for observability
- Kubernetes CRDs for native integration
- Plugin architecture for extensibility

---

*This scaffold represents a production-grade, enterprise-ready MCP gateway that can compete with any commercial offering while maintaining an open-source core for community adoption and trust.*
