# Technical Architecture: Envoy, xDS, and OPA Integration

# Technical Architecture: Envoy, xDS, and OPA Integration

## Overview

Think of [Giru.ai](http://Giru.ai) like **Kubernetes for MCP** - we're not replacing MCP servers (the applications), we're providing the infrastructure layer that makes them production-ready for Fortune 500 enterprises.

---

## The Three-Layer Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    MCP Clients                          │
│         (Claude Desktop, VS Code, Custom Apps)          │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│              Layer 3: Control Plane                     │
│  (xDS Server, Policy Manager, Registry, Observability)  │
└────────────────┬────────────────────────────────────────┘
                 │ (xDS Protocol)
                 ▼
┌─────────────────────────────────────────────────────────┐
│              Layer 1: Envoy Proxy                       │
│     (Performance Foundation - C++ Core)                 │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│              Layer 2: OPA Policy Engine                 │
│         (Governance Brain - Rego Policies)              │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│                    MCP Servers                          │
│    (Filesystem, GitHub, Slack, Custom Tools)            │
└─────────────────────────────────────────────────────────┘
```

---

## Layer 1: Envoy Proxy - The Performance Foundation

### Why Envoy is Non-Negotiable

Envoy isn't just a reverse proxy - it's the foundation that gives us competitive advantages others cannot replicate without massive rewrites.

### What Envoy Provides

**1. Battle-Tested Performance**

- Powers Lyft at millions of requests per second
- Netflix uses Envoy for their microservices (190M+ subscribers)
- AWS App Mesh built on Envoy
- **3-10x faster than Go stdlib** at high throughput

**2. Protocol Versatility**

- HTTP/1.1, HTTP/2 (MCP's current SSE transport)
- gRPC (potential future MCP transport)
- WebSocket (future-proofing)
- Native support for Server-Sent Events (SSE)

**3. Dynamic Configuration (xDS Protocol)**

- Zero-downtime configuration updates
- Real-time routing changes
- No gateway restarts required
- API-driven, not config file-based

**4. Enterprise Security Built-In**

- TLS termination with automatic cert rotation
- mTLS for service-to-service communication
- Support for SPIFFE/SPIRE identity framework
- Integration with Kubernetes cert-manager

**5. Observability Native**

- Prometheus metrics out-of-the-box
- Distributed tracing (Jaeger, Zipkin)
- Access logs with custom formats
- Health check endpoints

**6. Advanced Traffic Management**

- Load balancing algorithms: Round robin, least request, ring hash, maglev
- Zone-aware routing, priority-based routing
- Circuit breaking with configurable thresholds
- Automatic retries with exponential backoff
- Request hedging for latency-sensitive operations

**7. Service Mesh Compatibility**

- Native Istio integration
- Linkerd compatibility
- Consul Connect support
- Can act as ingress gateway or sidecar

### The Competitive Moat

| Feature | Giru (Envoy) | Obot (Go stdlib) | Microsoft (.NET) | IBM (Python) |
| --- | --- | --- | --- | --- |
| **Throughput** | 100K+ RPS | ~30K RPS | ~50K RPS | ~10K RPS |
| **Latency P99** | <5ms | ~10ms | ~8ms | ~20ms |
| **Service Mesh** | Native | ❌ | Azure only | ❌ |
| **Hot Reload** | ✅ xDS | ❌ Restart | ⚠️ Limited | ❌ Restart |
| **Protocol Support** | All | HTTP only | HTTP only | HTTP only |

---

## Layer 2: OPA Policy Engine - The Governance Brain

### Why OPA Changes Everything for Enterprise

**Open Policy Agent (OPA)** is a CNCF graduated project that transforms security and compliance from hard-coded application logic into declarative, testable, auditable policy-as-code.

### The OPA Architecture

```
Policy Repository (Git) → CI/CD Pipeline → OPA Bundle Distribution → OPA Runtime
  ├── policies/
  │   ├── pii_protection.rego
  │   ├── compliance/
  │   │   ├── soc2.rego
  │   │   ├── hipaa.rego
  │   │   └── gdpr.rego
  │   ├── access_control/
  │   │   ├── rbac.rego
  │   │   ├── abac.rego
  │   │   └── time_based.rego
  └── tests/ (Policy unit tests)
```

### OPA Policy Example - PII Protection

```
package giru.mcp.pii_protection

default allow = false

# Allow PII access for data scientists during business hours
allow {
    input.user.role == "data_scientist"
    [input.data](http://input.data)_classification != "restricted"
    business_hours
}

# Data scientists with PII training can access restricted data
allow {
    input.user.role == "data_scientist"
    input.user.certifications[_] == "pii_handling"
    [input.data](http://input.data)_classification == "restricted"
    requires_audit_log
}

# Compliance officers have read-only access anytime
allow {
    input.user.role == "compliance_officer"
    input.operation == "read"
}

business_hours {
    time.weekday([time.now](http://time.now)_ns()) != "Saturday"
    time.weekday([time.now](http://time.now)_ns()) != "Sunday"
    hour := time.clock([time.now](http://time.now)_ns())[0]
    hour >= 9
    hour < 17
}

requires_audit_log {
    # Trigger enhanced audit logging
    true
}
```

### What OPA Gives Enterprises

| Capability | Giru (OPA) | Obot (Custom) | Microsoft | IBM |
| --- | --- | --- | --- | --- |
| **Policy Language** | Declarative Rego | Imperative Go | YAML/JSON | Python |
| **Readable by Compliance** | ✅ Yes | ❌ No | ⚠️ Limited | ❌ No |
| **Version Control** | ✅ Git native | ⚠️ Code only | ⚠️ Limited | ⚠️ Code only |
| **Automated Testing** | ✅ OPA test framework | Unit tests | ⚠️ Limited | Unit tests |
| **Hot Reload** | ✅ Zero downtime | ❌ Restart | ⚠️ Limited | ❌ Restart |
| **Audit Trail** | ✅ Every decision | ⚠️ Manual | ⚠️ Basic | ⚠️ Basic |
| **Multi-Tenancy** | ✅ Namespace isolation | ⚠️ Custom | ⚠️ Azure | ⚠️ Custom |
| **Proven at Scale** | ✅ Goldman Sachs | ❌ New | ❌ | ❌ |

### The Enterprise Value

**For Security Teams**: Policies are readable, not buried in code. Review via Git pull requests.

**For Compliance Officers**: Map policies directly to SOC2, HIPAA, GDPR. Generate compliance reports.

**For Developers**: No policy logic in application code. Policy changes don't require deployments.

**For Operations**: Update policies without gateway downtime. Monitor policy performance.

---

## GitOps Architecture: Infrastructure as Code

### Philosophy: Everything as Code

[Giru.ai](http://Giru.ai) extends the GitOps approach beyond just OPA policies to **all gateway configuration**. Think of it like Kubernetes manifests - every aspect of your MCP gateway is version-controlled, peer-reviewed, and automatically deployed.

### Why GitOps for MCP Gateway?

**Analogy**: Traditional gateway configuration is like editing a production database directly. GitOps is like having a Git repository where every change goes through pull requests, CI/CD, and can be rolled back instantly.

**Benefits**:

- **Version Control**: Every configuration change has a commit history
- **Peer Review**: All changes go through pull requests
- **Automated Testing**: CI/CD validates configurations before deployment
- **Rollback**: Instant rollback to any previous state
- **Audit Trail**: Complete history of who changed what and why
- **Multi-Environment**: Promote configs from dev → staging → production

### What Gets Version Controlled?

1. **MCP Server Definitions** - Which servers exist and their capabilities
2. **Routing Rules** - How requests are routed to servers
3. **Client Configurations** - Which clients can access which servers
4. **OPA Policies** - Authorization, rate limiting, data filtering
5. **Observability Settings** - Metrics, logging, tracing configuration

---

## Manifest Structure

### MCP Server Definition

```yaml
# manifests/servers/my-mcp-server.yaml
apiVersion: [gateway.mcp.io/v1](http://gateway.mcp.io/v1)
kind: MCPServer
metadata:
  name: my-mcp-server
  labels:
    environment: production
    team: ai-platform
    compliance: hipaa
spec:
  endpoint: [https://mcp.example.com](https://mcp.example.com)
  protocol: http
  healthCheck:
    path: /health
    interval: 30s
    timeout: 5s
    healthyThreshold: 2
    unhealthyThreshold: 3
  capabilities:
    - tools
    - prompts
    - resources
  metadata:
    description: "Production MCP server for customer data"
    owner: "[ai-platform-team@example.com](mailto:ai-platform-team@example.com)"
    dataClassification: "confidential"
```

### Routing Configuration

```yaml
# manifests/routes/api-route.yaml
apiVersion: [gateway.mcp.io/v1](http://gateway.mcp.io/v1)
kind: Route
metadata:
  name: api-route
  labels:
    priority: high
spec:
  match:
    prefix: /api/v1
    headers:
      - name: X-API-Version
        value: "1.0"
    method: [GET, POST]
  destination:
    server: my-mcp-server
    loadBalancing: round_robin
    retries:
      attempts: 3
      perTryTimeout: 5s
      retryOn: 5xx
  timeout: 30s
  policies:
    - rate-limiting
    - require-auth
    - pii-filtering
```

### Client Configuration

```yaml
# manifests/clients/mobile-app.yaml
apiVersion: [gateway.mcp.io/v1](http://gateway.mcp.io/v1)
kind: Client
metadata:
  name: mobile-app
  labels:
    platform: ios
    version: 2.1.0
spec:
  authentication:
    type: api-key
    apiKeyHash: "$2a$10$..."  # bcrypt hash
  authorization:
    allowedServers:
      - my-mcp-server
      - analytics-server
    allowedCapabilities:
      - tools
      - resources
  rateLimit:
    requestsPerMinute: 1000
    burstSize: 100
  policies:
    - client-authorization
    - adaptive-rate-limiting
  monitoring:
    enableTracing: true
    samplingRate: 0.1  # 10% of requests
```

---

## OPA Policy Files

### Client Authorization Policy

```
# policies/authorization/client_authorization.rego
package gateway.authorization

import future.keywords.if

default allow = false

# Allow if client has access to the target server
allow if {
    input.client.allowedServers[_] == input.request.targetServer
    input.client.authenticated == true
}

# Deny if client is suspended
allow = false if {
    input.client.status == "suspended"
}

# Enterprise: Team-based access control
allow if {
    [input.client.team](http://input.client.team) == [input.server.team](http://input.server.team)
    has_permission(input.client.role, "server:access")
}

# Enterprise: Time-based access (business hours only)
allow if {
    input.client.role == "contractor"
    business_hours
    has_permission(input.client.role, "server:access")
}

business_hours if {
    time.weekday([time.now](http://time.now)_ns()) != "Saturday"
    time.weekday([time.now](http://time.now)_ns()) != "Sunday"
    hour := time.clock([time.now](http://time.now)_ns())[0]
    hour >= 9
    hour < 17
}

has_permission(role, permission) if {
    role_permissions[role][_] == permission
}

role_permissions := {
    "admin": ["server:access", "server:manage", "policy:write"],
    "developer": ["server:access", "server:read"],
    "contractor": ["server:access"],
    "viewer": ["server:read"]
}
```

### Adaptive Rate Limiting Policy

```
# policies/rate_limiting/adaptive_limits.rego
package gateway.ratelimit

import future.keywords.if

default limit = 100

# Base limit from client configuration
limit = input.client.rateLimit.requestsPerMinute if {
    input.client.rateLimit.requestsPerMinute
}

# Enterprise: Adaptive limits based on server health
limit = adjusted_limit if {
    server_health := input.server.healthScore
    base_limit := input.client.rateLimit.requestsPerMinute
    server_health < 80  # Server under stress
    adjusted_limit := base_limit * (server_health / 100)
}

# Enterprise: Priority clients get higher limits
limit = priority_limit if {
    input.client.tier == "enterprise"
    priority_limit := input.client.rateLimit.requestsPerMinute * 5
}

# Enterprise: Burst allowance during off-peak hours
limit = burst_limit if {
    off_peak_hours
    burst_limit := input.client.rateLimit.requestsPerMinute * 2
}

off_peak_hours if {
    hour := time.clock([time.now](http://time.now)_ns())[0]
    # 6pm - 6am
    hour >= 18 or hour < 6
}
```

### PII Filtering Policy

```
# policies/data_filtering/pii_removal.rego
package gateway.datafilter

import future.keywords.if

# Enterprise: Remove PII from responses based on client permissions
filtered_response = response if {
    # Client has PII access permission
    input.client.permissions[_] == "pii:read"
    response := input.response
}

filtered_response = response if {
    # Client doesn't have PII access - redact sensitive fields
    not input.client.permissions[_] == "pii:read"
    response := remove_sensitive_fields(input.response)
}

remove_sensitive_fields(obj) = result if {
    # Remove email, phone, ssn, credit card fields
    sensitive_fields := ["email", "phone", "ssn", "creditCard", "taxId"]
    result := {k: v |
        obj[k] = v
        not sensitive_fields[_] == k
    }
}

# Enterprise: Redact but preserve format for testing
remove_sensitive_fields(obj) = result if {
    input.environment == "staging"
    result := {k: redacted_value(k, v) |
        obj[k] = v
    }
}

redacted_value(key, value) = "***@***.com" if {
    key == "email"
}

redacted_value(key, value) = "***-***-****" if {
    key == "phone"
}

redacted_value(key, value) = "****-****-****-****" if {
    key == "creditCard"
}

redacted_value(key, value) = value if {
    # Pass through non-sensitive fields
    not key in ["email", "phone", "creditCard", "ssn", "taxId"]
}
```

### Compliance Policy (HIPAA Example)

```
# policies/compliance/hipaa.rego
package gateway.compliance.hipaa

import future.keywords.if

default compliant = false

# HIPAA requires encryption in transit
compliant if {
    input.request.protocol == "https"
    input.request.tlsVersion >= "1.2"
}

# HIPAA requires audit logging for PHI access
compliant if {
    input.server.labels.dataType == "phi"
    input.logging.auditEnabled == true
    input.logging.includeRequestBody == true
    input.logging.retention >= 2555  # 7 years in days
}

# HIPAA requires role-based access
compliant if {
    input.server.labels.dataType == "phi"
    input.client.role in allowed_phi_roles
    input.client.certifications[_] == "hipaa_trained"
}

allowed_phi_roles := ["physician", "nurse", "compliance_officer", "authorized_staff"]

# HIPAA requires MFA for remote access
compliant if {
    input.client.remoteAccess == true
    input.client.mfaVerified == true
}

violations[msg] {
    not compliant
    msg := "HIPAA violation: Missing required controls"
}
```

---

## GitOps Workflow

### Development Process

```
1. Developer Creates Branch
   │
   ├─ git checkout -b feature/add-new-mcp-server
   │
   ▼
2. Add/Modify Manifests
   │
   ├─ manifests/servers/new-server.yaml
   ├─ policies/authorization/new-server-policy.rego
   │
   ▼
3. Local Testing
   │
   ├─ make test-policies
   ├─ make validate-manifests
   ├─ make dry-run
   │
   ▼
4. Create Pull Request
   │
   ├─ CI/CD runs automatically:
   │   ├─ Schema validation
   │   ├─ OPA policy tests
   │   ├─ Security scanning
   │   ├─ Integration tests
   │   └─ Preview deployment
   │
   ▼
5. Peer Review
   │
   ├─ Security team reviews policies
   ├─ Platform team reviews manifests
   ├─ Automated checks pass
   │
   ▼
6. Merge to Main
   │
   ▼
7. Automatic Deployment
   │
   ├─ Dev environment (immediate)
   ├─ Staging environment (after smoke tests)
   └─ Production (after approval + canary)
```

### CI/CD Pipeline (GitHub Actions Example)

```yaml
# .github/workflows/deploy-gateway-config.yml
name: Deploy Gateway Configuration

on:
  pull_request:
    paths:
      - 'manifests/**'
      - 'policies/**'
  push:
    branches:
      - main

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Validate Manifests
        run: |
          kubectl apply --dry-run=client -f manifests/

      - name: Test OPA Policies
        run: |
          opa test policies/ -v

      - name: Security Scan
        run: |
          conftest test manifests/ --policy policies/security/

  deploy-dev:
    needs: validate
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Dev
        run: |
          kubectl apply -f manifests/ --namespace=giru-dev

      - name: Smoke Tests
        run: |
          ./scripts/[smoke-tests.sh](http://smoke-tests.sh) dev

  deploy-staging:
    needs: deploy-dev
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Staging
        run: |
          kubectl apply -f manifests/ --namespace=giru-staging

      - name: Integration Tests
        run: |
          ./scripts/[integration-tests.sh](http://integration-tests.sh) staging

  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Canary Deployment
        run: |
          # Deploy to 10% of production traffic
          kubectl apply -f manifests/ --namespace=giru-prod-canary

      - name: Monitor Canary
        run: |
          ./scripts/[monitor-canary.sh](http://monitor-canary.sh) 10m

      - name: Full Production Deployment
        if: success()
        run: |
          kubectl apply -f manifests/ --namespace=giru-prod
```

---

## Directory Structure

```
giru-gateway-config/
├── manifests/
│   ├── servers/
│   │   ├── production/
│   │   │   ├── mcp-filesystem.yaml
│   │   │   ├── mcp-github.yaml
│   │   │   └── mcp-slack.yaml
│   │   ├── staging/
│   │   └── dev/
│   ├── routes/
│   │   ├── api-routes.yaml
│   │   ├── internal-routes.yaml
│   │   └── partner-routes.yaml
│   ├── clients/
│   │   ├── mobile-app.yaml
│   │   ├── web-app.yaml
│   │   └── internal-tools.yaml
│   └── observability/
│       ├── prometheus.yaml
│       ├── jaeger.yaml
│       └── dashboards.yaml
├── policies/
│   ├── authorization/
│   │   ├── client_authorization.rego
│   │   ├── rbac.rego
│   │   └── team_access.rego
│   ├── rate_limiting/
│   │   ├── adaptive_limits.rego
│   │   └── quota_management.rego
│   ├── data_filtering/
│   │   ├── pii_removal.rego
│   │   └── data_classification.rego
│   ├── compliance/
│   │   ├── soc2.rego
│   │   ├── hipaa.rego
│   │   └── gdpr.rego
│   └── security/
│       ├── tls_requirements.rego
│       └── api_key_validation.rego
├── tests/
│   ├── authorization_test.rego
│   ├── rate_limiting_test.rego
│   └── compliance_test.rego
├── scripts/
│   ├── [smoke-tests.sh](http://smoke-tests.sh)
│   ├── [integration-tests.sh](http://integration-tests.sh)
│   └── [monitor-canary.sh](http://monitor-canary.sh)
├── .github/
│   └── workflows/
│       ├── deploy-gateway-config.yml
│       └── policy-tests.yml
└── [README.md](http://README.md)
```

---

## Advantages Over Competitors

| Capability | Giru (GitOps) | Obot | Microsoft | IBM |
| --- | --- | --- | --- | --- |
| **Configuration as Code** | ✅ Full GitOps | ❌ Database UI | ⚠️ Azure Resource Manager | ⚠️ Config files |
| **Policy Testing** | ✅ OPA test framework | ❌ Manual | ❌ | ❌ |
| **Peer Review** | ✅ Git PR workflow | ❌ | ❌ | ❌ |
| **Rollback** | ✅ Git revert (instant) | ⚠️ Database restore | ⚠️ ARM templates | ⚠️ Manual |
| **Multi-Environment** | ✅ Git branches | ⚠️ Separate instances | ✅ Azure DevOps | ⚠️ Manual |
| **Audit Trail** | ✅ Git history | ⚠️ Database logs | ⚠️ Azure logs | ⚠️ Logs |
| **CI/CD Integration** | ✅ Native | ❌ | ✅ Azure Pipelines | ⚠️ Custom |

**The Competitive Edge**: While competitors require manual configuration changes through UIs or APIs, [Giru.ai](http://Giru.ai) treats **everything as code**. This means:

- Changes go through the same review process as application code
- Compliance teams can audit configuration history in Git
- Rollbacks are instant (git revert)
- Configuration can be tested before deployment
- Multi-environment promotion is built-in

This is **infrastructure as code** applied to MCP gateways - a paradigm shift from traditional configuration management.

---

## Layer 3: Control Plane - The Orchestration Layer

### Core Responsibilities

**1. Dynamic Configuration Management (xDS)**

- **Cluster Discovery Service (CDS)**: Backend MCP servers
- **Endpoint Discovery Service (EDS)**: Health and availability
- **Route Discovery Service (RDS)**: Request routing rules
- **Listener Discovery Service (LDS)**: Port and protocol bindings
- **Secret Discovery Service (SDS)**: Certificate rotation

**2. MCP Server Registry**

- Service discovery for MCP servers
- Health checking and status monitoring
- Version management
- Deployment orchestration (Docker, K8s)

**3. Authentication & Identity**

- SSO integration (Azure AD, Okta, OneLogin, Google Workspace)
- JWT token validation
- API key management
- OAuth 2.0/2.1 flows

**4. Policy Management**

- OPA bundle distribution
- Policy version control
- Policy testing interface
- Decision log aggregation

**5. Observability & Analytics**

- Metrics aggregation (Prometheus)
- Distributed tracing (Jaeger, Tempo)
- Log aggregation (Loki, Elasticsearch)
- Usage analytics and reporting

**6. Multi-Tenancy**

- Organization/project isolation
- Resource quotas
- Billing and metering
- Team management

### Technology Stack

- **Language**: Go (performance) + TypeScript (admin UI)
- **Database**: PostgreSQL (configuration) + Redis (caching)
- **API**: gRPC (internal) + REST (external)
- **Queue**: NATS or RabbitMQ (async operations)

---

## Request Flow: How It All Works Together

### Step-by-Step Request Processing

```
1. MCP Client Request
   │
   ▼
2. Envoy Receives Request
   │ - TLS termination
   │ - Extract JWT/API key
   │ - Initial metrics collection
   │
   ▼
3. OPA Policy Check (Ext Auth Filter)
   │ - Evaluate access policies
   │ - Check rate limits
   │ - Validate data classification
   │ - Log decision
   │
   ├─[DENY]─► Return 403 Forbidden
   │
   ▼[ALLOW]
4. Route to MCP Server
   │ - Load balancing
   │ - Circuit breaker check
   │ - Add trace headers
   │
   ▼
5. MCP Server Processes Request
   │
   ▼
6. Response Through Envoy
   │ - Content filtering (PII redaction)
   │ - Audit logging
   │ - Metrics emission
   │
   ▼
7. Return to MCP Client
```

### Configuration Update Flow (xDS)

```
1. Admin Updates Configuration
   │ (via Web UI or API)
   │
   ▼
2. Control Plane Validates
   │ - Schema validation
   │ - Policy testing
   │ - Conflict detection
   │
   ▼
3. xDS Server Pushes Update
   │ - gRPC stream to Envoy
   │ - Incremental updates
   │ - Version tracking
   │
   ▼
4. Envoy Applies Configuration
   │ - Zero downtime
   │ - Atomic update
   │ - Rollback on error
   │
   ▼
5. Configuration Active
   └─► No gateway restart needed
```

---

## Integration Patterns

### Service Mesh Integration (Istio Example)

```yaml
apiVersion: [networking.istio.io/v1beta1](http://networking.istio.io/v1beta1)
kind: Gateway
metadata:
  name: giru-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: giru-tls-cert
    hosts:
    - "[mcp.example.com](http://mcp.example.com)"
---
apiVersion: [networking.istio.io/v1beta1](http://networking.istio.io/v1beta1)
kind: VirtualService
metadata:
  name: mcp-routing
spec:
  hosts:
  - "[mcp.example.com](http://mcp.example.com)"
  gateways:
  - giru-gateway
  http:
  - match:
    - uri:
        prefix: "/v1/"
    route:
    - destination:
        host: giru-envoy-gateway
        port:
          number: 8080
```

### Multi-Region Deployment

```
┌─────────────────┐       ┌─────────────────┐
│   US-EAST-1     │       │    EU-WEST-1    │
│                 │       │                 │
│  ┌──────────┐   │       │  ┌──────────┐   │
│  │  Envoy   │   │       │  │  Envoy   │   │
│  │ Gateway  │   │       │  │ Gateway  │   │
│  └────┬─────┘   │       │  └────┬─────┘   │
│       │         │       │       │         │
│  ┌────▼─────┐   │       │  ┌────▼─────┐   │
│  │   OPA    │   │       │  │   OPA    │   │
│  └────┬─────┘   │       │  └────┬─────┘   │
│       │         │       │       │         │
│  ┌────▼─────┐   │       │  ┌────▼─────┐   │
│  │MCP Servers│  │       │  │MCP Servers│  │
│  │(US Data) │   │       │  │(EU Data)  │   │
│  └──────────┘   │       │  └──────────┘   │
└─────────────────┘       └─────────────────┘
         │                         │
         └─────────┬───────────────┘
                   │
        ┌──────────▼──────────┐
        │  Global Control     │
        │      Plane          │
        │  (Config, Metrics)  │
        └─────────────────────┘
```

---

## Deployment Models

### Kubernetes Deployment

**Recommended architecture for production:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: giru-gateway
spec:
  replicas: 3
  selector:
    matchLabels:
      app: giru-gateway
  template:
    metadata:
      labels:
        app: giru-gateway
    spec:
      containers:
      - name: envoy
        image: envoyproxy/envoy:v1.28
        ports:
        - containerPort: 8080
          name: http
        - containerPort: 8443
          name: https
        - containerPort: 9901
          name: admin
        volumeMounts:
        - name: envoy-config
          mountPath: /etc/envoy

      - name: opa
        image: openpolicyagent/opa:latest
        ports:
        - containerPort: 8181
        args:
        - "run"
        - "--server"
        - "--addr=0.0.0.0:8181"
        - "--set=decision_logs.console=true"
        volumeMounts:
        - name: opa-policies
          mountPath: /policies

      volumes:
      - name: envoy-config
        configMap:
          name: envoy-config
      - name: opa-policies
        configMap:
          name: opa-policies
```

### Docker Compose (Development)

```yaml
version: '3.8'
services:
  envoy:
    image: envoyproxy/envoy:v1.28
    ports:
      - "8080:8080"
      - "9901:9901"
    volumes:
      - ./envoy.yaml:/etc/envoy/envoy.yaml
    depends_on:
      - opa
      - control-plane

  opa:
    image: openpolicyagent/opa:latest
    ports:
      - "8181:8181"
    command:
      - "run"
      - "--server"
      - "--addr=0.0.0.0:8181"
    volumes:
      - ./policies:/policies

  control-plane:
    build: ./control-plane
    ports:
      - "18000:18000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@postgres:5432/giru
    depends_on:
      - postgres
      - redis

  postgres:
    image: postgres:15
    environment:
      - POSTGRES_DB=giru
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres-data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  postgres-data:
```

---

## Security Architecture

### Defense in Depth

**Layer 1: Network Security**

- TLS 1.3 for all client connections
- mTLS for service-to-service communication
- Network policies (Kubernetes NetworkPolicy or Istio AuthorizationPolicy)

**Layer 2: Authentication**

- JWT validation at Envoy
- SSO integration via OIDC
- API key management with rotation

**Layer 3: Authorization**

- OPA policy evaluation
- RBAC (Role-Based Access Control)
- ABAC (Attribute-Based Access Control)
- Time-based access controls

**Layer 4: Data Protection**

- PII detection and redaction
- Data classification enforcement
- Encryption at rest (database)
- Encryption in transit (TLS)

**Layer 5: Audit & Compliance**

- Immutable audit logs
- Decision logging from OPA
- Request/response logging
- Compliance reporting

---

## Performance Optimization

### Caching Strategy

**1. OPA Decision Caching**

- Cache policy decisions for frequently accessed resources
- TTL-based invalidation
- Redis-backed distributed cache

**2. MCP Server Response Caching**

- Cache static tool definitions
- Cache resource listings
- Configurable per-server policies

**3. Configuration Caching**

- Local Envoy config cache
- xDS snapshot caching in control plane

### Load Balancing

**Algorithms supported:**

- **Round Robin**: Simple, works for homogeneous backends
- **Least Request**: Better for heterogeneous workloads
- **Ring Hash**: Consistent hashing for session affinity
- **Maglev**: Google's consistent hashing (minimal disruption)

### Circuit Breaking

```yaml
circuit_breakers:
  thresholds:
  - priority: DEFAULT
    max_connections: 1000
    max_pending_requests: 1000
    max_requests: 1000
    max_retries: 3
```

---

## Observability Deep Dive

### Metrics (Prometheus)

**Envoy Metrics:**

- `envoy_cluster_upstream_rq_total` - Total requests to backends
- `envoy_cluster_upstream_rq_time` - Request duration
- `envoy_cluster_upstream_rq_xx` - Response codes (2xx, 4xx, 5xx)
- `envoy_cluster_circuit_breakers_*` - Circuit breaker states

**OPA Metrics:**

- `http_request_duration_seconds` - Policy evaluation time
- `opa_decisions_total` - Total policy decisions
- `opa_policy_evaluation_duration_seconds` - Per-policy timing

**Custom Business Metrics:**

- MCP tool invocation counts
- Data classification access patterns
- PII detection/redaction events
- Policy violation attempts

### Distributed Tracing (Jaeger)

```
Trace ID: a1b2c3d4-e5f6-7890-abcd-ef1234567890
│
├─ Span: envoy.ingress
│  Duration: 150ms
│  Tags: http.method=POST, http.status=200
│  │
│  ├─ Span: opa.policy_evaluation
│  │  Duration: 5ms
│  │  Tags: policy.allow=true, policy.rule=pii_protection
│  │
│  └─ Span: [mcp.filesystem.read](http://mcp.filesystem.read)
│     Duration: 140ms
│     Tags: mcp.tool=read_file, file.path=/data/report.pdf
```

---

## Disaster Recovery & High Availability

### Multi-Zone Deployment

```
Availability Zone 1    Availability Zone 2    Availability Zone 3
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Envoy (Active) │    │  Envoy (Active) │    │  Envoy (Active) │
│  OPA (Active)   │    │  OPA (Active)   │    │  OPA (Active)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                      │                      │
         └──────────────────────┴──────────────────────┘
                               │
                    ┌──────────▼──────────┐
                    │   Control Plane     │
                    │   (Active-Passive)  │
                    └─────────────────────┘
                               │
                    ┌──────────▼──────────┐
                    │   PostgreSQL HA     │
                    │   (Primary/Replica) │
                    └─────────────────────┘
```

### Backup & Restore

**Configuration Backup:**

- Automated daily backups to S3/GCS/Azure Blob
- Point-in-time recovery for PostgreSQL
- Policy version history in Git

**State Management:**

- Stateless Envoy instances (easy scaling)
- Control plane state in PostgreSQL (replicated)
- Redis for ephemeral caching only

---

## Development Roadmap

### Phase 1: MVP (Months 0-3)

- ✅ Envoy integration with basic routing
- ✅ OPA integration with sample policies
- ✅ xDS control plane (CDS, EDS, LDS)
- ✅ Basic authentication (JWT, API keys)
- ✅ Prometheus metrics
- ✅ Health check endpoints

### Phase 2: Enterprise Features (Months 3-6)

- SSO integration (Azure AD, Okta)
- Compliance policy bundles (SOC2, HIPAA, GDPR)
- Advanced audit logging
- Multi-tenancy support
- Service mesh integration (Istio)
- Admin UI

### Phase 3: Advanced Capabilities (Months 6-12)

- Distributed tracing (Jaeger, Tempo)
- Advanced rate limiting
- Data residency controls
- PII detection/redaction
- Policy testing framework
- Performance optimization

### Phase 4: Platform (Year 2+)

- AI-powered policy recommendations
- Anomaly detection
- Cost optimization
- Self-service portal
- Marketplace for policies
- Private registry integration

---

## Appendix: Example Configurations

### Envoy Configuration (envoy.yaml)

```yaml
static_resources:
  listeners:
  - name: main_listener
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 8080
    filter_chains:
    - filters:
      - name: [envoy.filters.network](http://envoy.filters.network).http_connection_manager
        typed_config:
          "@type": [type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager](http://type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager)
          stat_prefix: ingress_http
          route_config:
            name: local_route
            virtual_hosts:
            - name: backend
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: mcp_servers
          http_filters:
          - name: envoy.filters.http.ext_authz
            typed_config:
              "@type": [type.googleapis.com/envoy.extensions.filters.http.ext_authz.v3.ExtAuthz](http://type.googleapis.com/envoy.extensions.filters.http.ext_authz.v3.ExtAuthz)
              transport_api_version: V3
              grpc_service:
                envoy_grpc:
                  cluster_name: opa_cluster
          - name: envoy.filters.http.router
            typed_config:
              "@type": [type.googleapis.com/envoy.extensions.filters.http.router.v3.Router](http://type.googleapis.com/envoy.extensions.filters.http.router.v3.Router)

  clusters:
  - name: mcp_servers
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: mcp_servers
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: mcp-server-1
                port_value: 3000
        - endpoint:
            address:
              socket_address:
                address: mcp-server-2
                port_value: 3000

  - name: opa_cluster
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    http2_protocol_options: {}
    load_assignment:
      cluster_name: opa_cluster
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: opa
                port_value: 9191

admin:
  address:
    socket_address:
      address: 0.0.0.0
      port_value: 9901
```

### OPA Policy Test Example

```
package giru.mcp.pii_protection_test

import data.giru.mcp.pii_protection
import future.keywords.if

test_data_scientist_allowed_business_hours if {
    allow with input as {
        "user": {
            "role": "data_scientist",
            "certifications": []
        },
        "data_classification": "internal",
        "operation": "read",
        "time": "2025-11-11T14:00:00Z"  # Tuesday, 2pm
    }
}

test_data_scientist_denied_restricted_without_cert if {
    not allow with input as {
        "user": {
            "role": "data_scientist",
            "certifications": []
        },
        "data_classification": "restricted",
        "operation": "read",
        "time": "2025-11-11T14:00:00Z"
    }
}

test_data_scientist_allowed_restricted_with_cert if {
    allow with input as {
        "user": {
            "role": "data_scientist",
            "certifications": ["pii_handling"]
        },
        "data_classification": "restricted",
        "operation": "read",
        "time": "2025-11-11T14:00:00Z"
    }
}

test_compliance_officer_always_allowed_read if {
    allow with input as {
        "user": {
            "role": "compliance_officer"
        },
        "operation": "read",
        "time": "2025-11-11T02:00:00Z"  # 2am
    }
}
```

---

## Summary: Why This Architecture Wins

### Technical Superiority

1. **Envoy**: 10x performance at scale, battle-tested at Fortune 500
2. **OPA**: Declarative, testable policies readable by compliance teams
3. **xDS**: Zero-downtime configuration updates
4. **Service Mesh**: Native integration (unique competitive advantage)

### Enterprise Trust

1. **CNCF Graduated**: Both Envoy and OPA are proven infrastructure standards
2. **Production Validated**: Powers Netflix, Lyft, Goldman Sachs
3. **Community**: 1000+ contributors, extensive documentation
4. **Hiring**: Easier to find Envoy/OPA talent than custom stack expertise

### Operational Excellence

1. **Observability**: Metrics, tracing, logging built-in
2. **Scalability**: Proven to millions of RPS
3. **Reliability**: Circuit breakers, retries, health checks
4. **Security**: Defense in depth with multiple layers

This architecture isn't just technically superior - it's **defensible**. Competitors would need to rewrite their entire stack to match these capabilities.
