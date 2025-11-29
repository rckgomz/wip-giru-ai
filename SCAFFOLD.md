# Giru MCP Gateway - Project Scaffolding Instructions

This file contains comprehensive instructions for Claude Code to scaffold the Giru MCP Gateway project. This is an infrastructure-grade, production-ready gateway for Model Context Protocol (MCP) servers, designed for Fortune 500 enterprises.

## Project Overview

**Giru** (giru.ai) is "Kubernetes for MCP" - providing the infrastructure layer that makes MCP servers production-ready for enterprises. Think of it as the three-layer architecture:

1. **Layer 1: Envoy Proxy** - Performance foundation (C++ core)
2. **Layer 2: OPA Policy Engine** - Governance brain (Rego policies)
3. **Layer 3: Control Plane** - Orchestration layer (Go + TypeScript)

## Business Model: Managed SaaS + Open Source

**Primary Strategy**: Managed multi-tenant SaaS (like Datadog, Auth0, Stripe)
**Secondary**: Open-source community edition for self-hosters

### Repository Strategy

1. **Open Source (Community Edition)**: `github.com/giru-ai/giru` (Apache 2.0)
   - Core MCP gateway functionality
   - Self-hosted deployment only
   - Community-driven development
   - Production-ready for developers/startups
   - Path to CNCF Sandbox → Incubation → Graduation

2. **Managed SaaS (Closed Source)**: `github.com/giru-ai/giru-cloud` (Private, Proprietary)
   - Multi-tenant control plane
   - Billing and metering
   - Advanced compliance features (HIPAA/PCI-DSS blueprints)
   - Tenant isolation and resource management
   - SLA monitoring and guarantees

3. **Shared Libraries**: `github.com/giru-ai/giru-common` (Apache 2.0)
   - Common data models and utilities
   - API contracts and protocol buffers
   - Compliance policy library (shared with community)

**Why This Model?**
- ✅ **Better margins**: 85% gross margin (SaaS) vs 60% (enterprise licenses)
- ✅ **Faster growth**: Product-led growth via free community edition
- ✅ **Lower CAC**: Self-service signup, no sales team for small customers
- ✅ **Community trust**: Core gateway is fully open source
- ✅ **Proven model**: Auth0 ($6.5B), Kong ($1.5B), Hasura ($100M ARR)

### Revenue Streams

**Primary: Managed SaaS (giru.ai)**
- **Starter**: $99/mo (10 MCP servers, 100K requests/mo)
- **Professional**: $499/mo (50 servers, 1M requests/mo, SSO)
- **Business**: $1,999/mo (200 servers, 10M requests/mo, HIPAA/PCI-DSS)
- **Enterprise**: Custom pricing (dedicated instances, 99.99% SLA, 24/7 support)

**Secondary: Community Edition (Self-Hosted)**
- Free forever (Apache 2.0 license)
- GitHub Discussions support
- Upgrade CTA to managed SaaS

**Target Markets**:
- **Primary**: Mid-market SaaS companies ($10M-$100M ARR)
- **Secondary**: Healthcare providers, financial services, Fortune 500

**Development Priority**:
- **Phase 1-2 (MVP)**: Community Edition (8 weeks)
  - Open source MCP gateway core
  - Basic compliance policies
  - Docker Compose + Kubernetes deployment
- **Phase 3-4 (SaaS Alpha)**: Multi-tenant SaaS (8 weeks)
  - Tenant isolation
  - Billing integration (Stripe)
  - Self-service signup
- **Phase 5+ (SaaS GA)**: Enterprise features
  - Dedicated instances
  - Advanced compliance (HIPAA audits)
  - 24/7 support

**Revenue Targets**:
- 2026: $180K ARR (50 Starter, 10 Professional customers)
- 2027: $2M ARR (500 customers, expand to Business tier)
- 2028: $8M ARR (1,200 customers, 20 Enterprise)
- 2030: $50M ARR (5,000 customers, dominant market position)

## Directory Structure to Create

### Repository 1: giru-ai/giru (Open Source - Apache 2.0)

**This is the CNCF project repository with production-ready core features.**

```
giru/
├── LICENSE                          # Apache 2.0 License
├── README.md                        # Project overview, CNCF badges, quick start
├── CONTRIBUTING.md                  # Contribution guidelines
├── CODE_OF_CONDUCT.md              # CNCF Code of Conduct
├── GOVERNANCE.md                    # CNCF governance model
├── SECURITY.md                      # Security policy and disclosure
├── MAINTAINERS.md                   # List of maintainers
├── .gitignore                       # Git ignore rules
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                   # CI pipeline (tests, linting)
│   │   ├── deploy-dev.yml           # Dev environment deployment
│   │   ├── deploy-staging.yml       # Staging deployment
│   │   ├── deploy-production.yml    # Production deployment
│   │   └── policy-tests.yml         # OPA policy testing
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   ├── feature_request.md
│   │   └── enterprise_support.md
│   └── PULL_REQUEST_TEMPLATE.md
├── docs/
│   ├── architecture/
│   │   ├── overview.md              # High-level architecture
│   │   ├── envoy-integration.md     # Envoy proxy details
│   │   ├── opa-policies.md          # OPA policy architecture
│   │   ├── control-plane.md         # Control plane design
│   │   └── request-flow.md          # Request processing flow
│   ├── deployment/
│   │   ├── kubernetes.md            # K8s deployment guide
│   │   ├── docker-compose.md        # Local development setup
│   │   ├── production-checklist.md  # Production readiness
│   │   └── multi-region.md          # Multi-region setup
│   ├── policies/
│   │   ├── writing-policies.md      # How to write OPA policies
│   │   ├── testing-policies.md      # Policy testing guide
│   │   ├── compliance/
│   │   │   ├── soc2.md
│   │   │   ├── hipaa.md
│   │   │   └── gdpr.md
│   │   └── examples/
│   ├── api/
│   │   ├── rest-api.md              # REST API documentation
│   │   ├── openapi-spec.yaml        # OpenAPI 3.0 specification
│   │   ├── client-generation.md     # How to generate clients
│   │   ├── curl-examples.md         # API usage examples
│   │   ├── grpc-api.md              # gRPC API docs
│   │   └── xds-protocol.md          # xDS integration
│   ├── guides/
│   │   ├── quick-start.md           # 5-minute setup
│   │   ├── production-deployment.md
│   │   ├── monitoring.md            # Observability setup
│   │   └── troubleshooting.md
│   └── enterprise/                   # Documentation only (code in separate repo)
│       ├── README.md                # Links to giru-enterprise repo
│       ├── features.md              # Enterprise feature list
│       └── migration-guide.md       # Migrating to enterprise
├── packages/
│   ├── envoy/
│   │   ├── configs/
│   │   │   ├── envoy-base.yaml      # Base Envoy configuration
│   │   │   ├── listeners.yaml       # Listener definitions
│   │   │   ├── clusters.yaml        # Cluster configurations
│   │   │   └── routes.yaml          # Route configurations
│   │   ├── filters/
│   │   │   ├── ext-authz.yaml       # OPA integration
│   │   │   ├── rate-limit.yaml      # Rate limiting
│   │   │   └── logging.yaml         # Access logging
│   │   └── templates/
│   │       └── dynamic-config.tmpl
│   ├── opa/
│   │   ├── policies/
│   │   │   ├── authorization/
│   │   │   │   ├── basic_auth.rego
│   │   │   │   ├── api_key_validation.rego
│   │   │   │   └── jwt_validation.rego
│   │   │   ├── rate_limiting/
│   │   │   │   ├── basic_limits.rego
│   │   │   │   └── quota_management.rego
│   │   │   ├── routing/
│   │   │   │   ├── path_based.rego
│   │   │   │   └── header_based.rego
│   │   │   ├── security/
│   │   │   │   ├── tls_requirements.rego
│   │   │   │   └── cors_policy.rego
│   │   │   └── tool_access/
│   │   │       ├── tool_authorization.rego
│   │   │       └── parameter_validation.rego
│   │   └── tests/
│   │       ├── authorization_test.rego
│   │       ├── rate_limiting_test.rego
│   │       ├── routing_test.rego
│   │       └── tool_access_test.rego
│   ├── control-plane/
│   │   ├── cmd/
│   │   │   └── server/
│   │   │       └── main.go          # Control plane entry point
│   │   ├── pkg/
│   │   │   ├── xds/
│   │   │   │   ├── server.go        # xDS server implementation
│   │   │   │   ├── snapshot.go      # Configuration snapshots
│   │   │   │   ├── cds.go           # Cluster Discovery
│   │   │   │   ├── eds.go           # Endpoint Discovery
│   │   │   │   ├── rds.go           # Route Discovery
│   │   │   │   ├── lds.go           # Listener Discovery
│   │   │   │   └── sds.go           # Secret Discovery
│   │   │   ├── registry/
│   │   │   │   ├── service.go       # MCP server registry
│   │   │   │   ├── discovery.go     # Service discovery
│   │   │   │   └── health.go        # Health checking
│   │   │   ├── router/
│   │   │   │   ├── resolver.go      # Route resolution
│   │   │   │   └── matcher.go       # Path/header matching
│   │   │   ├── api/
│   │   │   │   ├── rest/
│   │   │   │   │   ├── server.go    # REST API server (Fiber)
│   │   │   │   │   ├── routes.go    # Route definitions
│   │   │   │   │   └── handlers/    # Request handlers
│   │   │   │   ├── grpc/
│   │   │   │   │   ├── server.go    # gRPC server
│   │   │   │   │   └── services/    # gRPC services
│   │   │   │   └── openapi/
│   │   │   │       ├── spec.yaml    # OpenAPI 3.0 spec
│   │   │   │       └── generator.go # Auto-generate from code
│   │   │   ├── config/
│   │   │   │   ├── loader.go        # Config loading
│   │   │   │   ├── validator.go     # Config validation
│   │   │   │   └── watcher.go       # Hot reload
│   │   │   ├── observability/
│   │   │   │   ├── metrics.go       # Prometheus metrics
│   │   │   │   ├── tracing.go       # Distributed tracing
│   │   │   │   └── logging.go       # Structured logging
│   │   │   └── storage/
│   │   │       ├── postgres.go      # PostgreSQL backend
│   │   │       ├── redis.go         # Redis cache
│   │   │       └── models/          # Data models
│   │   ├── db/
│   │   │   ├── migrations/          # Goose migrations
│   │   │   ├── seeds/              # Seed data
│   │   │   ├── queries/            # sqlc queries
│   │   │   └── sqlc.yaml           # sqlc config
│   │   ├── internal/
│   │   │   ├── database/
│   │   │   │   ├── db.go
│   │   │   │   ├── migrations.go
│   │   │   │   ├── models/         # sqlc generated
│   │   │   │   └── tx.go
│   │   │   └── utils/
│   │   ├── go.mod
│   │   ├── go.sum
│   │   └── Makefile
│   ├── cli/
│   │   ├── cmd/
│   │   │   ├── root.go              # CLI root command
│   │   │   ├── deploy.go            # Deploy commands
│   │   │   ├── policy.go            # Policy management
│   │   │   ├── server.go            # Server management
│   │   │   ├── route.go             # Route management
│   │   │   └── client.go            # Client management
│   │   ├── go.mod
│   │   └── Makefile
│   └── web-ui/                      # Basic web UI (Svelte)
│       ├── src/
│       │   ├── routes/
│       │   │   ├── +layout.svelte   # Root layout
│       │   │   ├── +page.svelte     # Dashboard home
│       │   │   ├── servers/         # Server management
│       │   │   ├── routes/          # Route configuration
│       │   │   ├── policies/        # Policy viewer
│       │   │   ├── clients/         # Client management
│       │   │   └── settings/        # System settings
│       │   ├── lib/
│       │   │   ├── components/      # Reusable components
│       │   │   ├── stores/          # Svelte stores
│       │   │   ├── api/             # API client
│       │   │   └── utils/           # Utilities
│       │   ├── app.html             # HTML template
│       │   └── app.css              # Global styles
│       ├── static/                  # Static assets
│       ├── package.json
│       ├── tsconfig.json
│       ├── svelte.config.js         # SvelteKit config
│       ├── vite.config.ts           # Vite config
│       └── tailwind.config.js
├── deployments/
│   ├── docker-compose/                  # Tier 1: Primary Development
│   │   ├── docker-compose.yml           # Full stack
│   │   ├── docker-compose.dev.yml       # Development with hot reload
│   │   ├── envoy.yaml                   # Envoy configuration
│   │   └── .env.example
│   ├── kind/                            # Tier 2: Kubernetes Testing
│   │   ├── kind-config.yaml             # kind cluster configuration
│   │   └── skaffold.yaml                # Skaffold hot reload config
│   ├── kubernetes/
│   │   ├── namespaces/
│   │   │   ├── dev.yaml
│   │   │   ├── staging.yaml
│   │   │   └── production.yaml
│   │   ├── base/
│   │   │   ├── namespace.yaml
│   │   │   ├── envoy-deployment.yaml
│   │   │   ├── envoy-service.yaml
│   │   │   ├── opa-deployment.yaml
│   │   │   ├── opa-service.yaml
│   │   │   ├── control-plane-deployment.yaml
│   │   │   ├── control-plane-service.yaml
│   │   │   ├── postgres-statefulset.yaml
│   │   │   ├── postgres-service.yaml
│   │   │   ├── redis-deployment.yaml
│   │   │   ├── redis-service.yaml
│   │   │   └── kustomization.yaml
│   │   ├── overlays/
│   │   │   ├── dev/
│   │   │   │   ├── kustomization.yaml
│   │   │   │   └── patches/
│   │   │   ├── staging/
│   │   │   │   ├── kustomization.yaml
│   │   │   │   └── patches/
│   │   │   └── production/
│   │   │       ├── kustomization.yaml
│   │   │       ├── patches/
│   │   │       └── secrets/
│   │   └── monitoring/
│   │       ├── prometheus/
│   │       │   ├── prometheus.yaml
│   │       │   └── servicemonitor.yaml
│   │       ├── grafana/
│   │       │   ├── grafana.yaml
│   │       │   └── dashboards/
│   │       └── jaeger/
│   │           └── jaeger.yaml
│   ├── terraform/
│   │   ├── aws/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   └── modules/
│   │   ├── gcp/
│   │   └── azure/
│   └── helm/
│       └── giru-core/
│           ├── Chart.yaml
│           ├── values.yaml
│           └── templates/
├── examples/
│   ├── basic-setup/
│   │   ├── README.md
│   │   ├── config.yaml
│   │   └── docker-compose.yml
│   ├── multi-server/
│   │   ├── README.md
│   │   └── manifests/
│   ├── policy-examples/
│   │   ├── rbac/
│   │   ├── rate-limiting/
│   │   └── data-filtering/
│   └── integrations/
│       ├── kubernetes/
│       ├── istio/
│       └── service-mesh/
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
│   └── clients/
│       ├── mobile-app.yaml
│       ├── web-app.yaml
│       └── internal-tools.yaml
├── scripts/
│   ├── setup/
│   │   ├── install-dev.sh              # Dev environment setup
│   │   ├── install-deps.sh             # Install dependencies
│   │   └── generate-certs.sh           # TLS certificate generation
│   ├── deploy/
│   │   ├── deploy-k8s.sh               # Kubernetes deployment
│   │   ├── deploy-docker.sh            # Docker deployment
│   │   └── rollback.sh                 # Rollback script
│   ├── test/
│   │   ├── smoke-tests.sh              # Smoke tests
│   │   ├── integration-tests.sh        # Integration tests
│   │   ├── load-tests.sh               # Load testing
│   │   └── policy-tests.sh             # OPA policy tests
│   ├── monitoring/
│   │   ├── monitor-canary.sh           # Canary monitoring
│   │   └── health-check.sh             # Health checking
│   └── utils/
│       ├── backup-postgres.sh          # Database backup
│       └── restore-postgres.sh         # Database restore
├── tests/
│   ├── integration/
│   │   ├── envoy_test.go
│   │   ├── opa_test.go
│   │   ├── control_plane_test.go
│   │   └── e2e_test.go
│   ├── performance/
│   │   ├── load_test.js                # k6 load tests
│   │   └── benchmarks/
│   └── security/
│       ├── penetration/
│       └── compliance/
├── build/
│   ├── docker/
│   │   ├── Dockerfile.envoy            # Envoy container
│   │   ├── Dockerfile.opa              # OPA container
│   │   ├── Dockerfile.control-plane    # Control plane
│   │   └── Dockerfile.web-ui           # Svelte UI (enterprise)
│   ├── build-community.sh              # Build community edition
│   ├── build-enterprise.sh             # Build enterprise edition
│   └── release.sh                      # Release script
├── tools/
│   ├── policy-validator/               # OPA policy validator
│   ├── config-generator/               # Config generation tool
│   └── migration/                      # Database migrations
└── Makefile                            # Build automation

```

### Repository 2: giru-ai/giru-enterprise (Private - Proprietary)

**This is the commercial product repository with enterprise-grade features.**

```
giru-enterprise/
├── LICENSE                          # Proprietary License
├── README.md                        # Enterprise README with setup
├── .gitignore                       # Git ignore rules
├── go.mod                           # Go module (imports github.com/giru-ai/giru)
├── go.sum
├── cmd/
│   └── giru-enterprise/
│       └── main.go                  # Enterprise entry point
├── pkg/
│   ├── auth/
│   │   ├── sso/
│   │   │   ├── saml.go              # SAML integration
│   │   │   ├── oidc.go              # OIDC integration
│   │   │   ├── azure_ad.go          # Azure AD
│   │   │   ├── okta.go              # Okta
│   │   │   └── google.go            # Google Workspace
│   │   └── mfa/
│   │       ├── totp.go              # TOTP MFA
│   │       └── webauthn.go          # WebAuthn
│   ├── multitenancy/
│   │   ├── manager.go               # Tenant management
│   │   ├── isolation.go             # Resource isolation
│   │   └── quotas.go                # Quota enforcement
│   ├── audit/
│   │   ├── logger.go                # Enhanced audit logging
│   │   ├── compliance.go            # Compliance reporting
│   │   └── export.go                # Log export (S3, etc)
│   ├── analytics/
│   │   ├── usage.go                 # Usage analytics
│   │   ├── billing.go               # Metering for billing
│   │   └── reporting.go             # Custom reports
│   └── license/
│       ├── manager.go               # License validation
│       ├── features.go              # Feature gating
│       └── telemetry.go             # License telemetry
├── opa-policies/
│   ├── compliance/
│   │   ├── soc2/
│   │   │   ├── access_control.rego
│   │   │   ├── audit_logging.rego
│   │   │   └── encryption.rego
│   │   ├── hipaa/
│   │   │   ├── phi_protection.rego
│   │   │   ├── access_audit.rego
│   │   │   └── encryption_requirements.rego
│   │   ├── gdpr/
│   │   │   ├── data_residency.rego
│   │   │   ├── pii_protection.rego
│   │   │   └── right_to_erasure.rego
│   │   └── pci/
│   │       ├── card_data_protection.rego
│   │       └── network_segmentation.rego
│   ├── advanced/
│   │   ├── adaptive_rate_limiting.rego
│   │   ├── ml_based_anomaly.rego
│   │   ├── context_aware_auth.rego
│   │   └── data_classification.rego
│   └── tests/
│       ├── compliance_test.rego
│       └── advanced_test.rego
├── web-ui/                          # Advanced enterprise UI
│   ├── src/
│   │   ├── routes/
│   │   │   ├── +layout.svelte       # Root layout
│   │   │   ├── +page.svelte         # Dashboard home
│   │   │   ├── tenants/             # Multi-tenant management
│   │   │   ├── analytics/           # Advanced analytics
│   │   │   ├── compliance/          # Compliance reports
│   │   │   ├── audit/               # Audit logs viewer
│   │   │   └── admin/               # Admin settings
│   │   └── lib/
│   │       ├── components/
│   │       │   ├── charts/          # Advanced charts
│   │       │   └── reports/         # Report components
│   │       └── api/                 # API client
│   ├── package.json
│   ├── svelte.config.js
│   └── vite.config.ts
├── build/
│   └── docker/
│       ├── Dockerfile.enterprise    # Enterprise Docker build
│       └── Dockerfile.enterprise-ui # Enterprise UI build
├── helm/
│   └── giru-enterprise/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── configmap.yaml
│           └── secrets.yaml
├── docs/
│   ├── installation.md              # Enterprise installation
│   ├── sso-setup.md                 # SSO configuration
│   ├── multi-tenancy.md             # Multi-tenancy guide
│   └── compliance.md                # Compliance documentation
└── Makefile                         # Enterprise build automation

```

**Enterprise Integration Pattern:**

```go
// cmd/giru-enterprise/main.go
package main

import (
    // Import open-source core
    "github.com/giru-ai/giru/packages/control-plane/pkg/server"
    "github.com/giru-ai/giru/packages/control-plane/pkg/config"
    
    // Import enterprise extensions
    "github.com/giru-ai/giru-enterprise/pkg/auth/sso"
    "github.com/giru-ai/giru-enterprise/pkg/multitenancy"
    "github.com/giru-ai/giru-enterprise/pkg/audit"
    "github.com/giru-ai/giru-enterprise/pkg/license"
)

func main() {
    // Load base configuration
    cfg, _ := config.Load()
    
    // Validate enterprise license
    lic, err := license.Validate()
    if err != nil {
        log.Fatal("Invalid enterprise license")
    }
    
    // Create base server from open-source core
    srv := server.New(cfg)
    
    // Register enterprise extensions
    if lic.HasFeature("sso") {
        srv.RegisterAuthProvider(sso.NewSAMLProvider())
        srv.RegisterAuthProvider(sso.NewOIDCProvider())
    }
    
    if lic.HasFeature("multi-tenancy") {
        srv.EnableMultiTenancy(multitenancy.NewManager())
    }
    
    if lic.HasFeature("audit") {
        srv.RegisterAuditLogger(audit.NewEnhancedLogger())
    }
    
    // Start server with enterprise features
    srv.Start()
}
```

### Repository 3: giru-ai/giru-common (Public - Apache 2.0)

**Shared libraries used by both open-source and enterprise.**

```
giru-common/
├── LICENSE                          # Apache 2.0 License
├── README.md
├── go.mod
├── go.sum
├── pkg/
│   ├── models/                      # Shared data models
│   │   ├── server.go
│   │   ├── route.go
│   │   ├── client.go
│   │   └── policy.go
│   ├── proto/                       # Protocol buffers
│   │   ├── xds/
│   │   └── api/
│   ├── contracts/                   # API contracts
│   │   ├── control_plane.go
│   │   └── registry.go
│   └── utils/                       # Shared utilities
│       ├── logger/
│       ├── metrics/
│       └── validation/
└── Makefile

```

## Key Implementation Requirements

### 1. Core Technology Stack

**Envoy Proxy (Layer 1)**
- Version: Envoy 1.28+
- Configuration: Dynamic xDS-based (not static files)
- Features to enable:
  - HTTP/1.1, HTTP/2, gRPC support
  - TLS termination with automatic cert rotation
  - Prometheus metrics exporter
  - Distributed tracing (Jaeger)
  - External authorization (OPA integration)
  - Rate limiting
  - Circuit breaking
  - Health checking

**OPA Policy Engine (Layer 2)**
- Version: OPA latest (CNCF graduated)
- Integration: Envoy External Authorization
- Policy structure:
  - Declarative Rego policies
  - Unit tests for all policies
  - Bundle distribution via control plane
  - Decision logging for audit

**Control Plane (Layer 3)**
- Language: Go 1.21+ for backend
- Framework: **Fiber v2** (fasthttp-based, 6M req/sec - 2.4x faster than alternatives)
- gRPC for xDS protocol
- Database: PostgreSQL 15+ for configuration
- Cache: Redis 7+ for performance
- Authentication: JWT validation, API key management
- SSO: SAML, OIDC (Enterprise only)

**Web UI (Enterprise)**
- Framework: Svelte 5 + SvelteKit 2 with TypeScript
- UI Library: DaisyUI + Tailwind CSS
- State Management: Svelte Stores (built-in)
- Visualization: Chart.js or Apache ECharts
- Real-time: Native WebSocket/SSE support

### 2. Feature Segmentation (Separate Repositories)

**Open Source Core - github.com/giru-ai/giru (Apache 2.0)**

Production-ready features for self-hosted deployments:
- ✅ Full Envoy proxy configuration (dynamic xDS)
- ✅ Core OPA policies (authentication, JWT validation, basic rate limiting, tool-level access control)
- ✅ Complete xDS server implementation
- ✅ MCP server registry and health checking
- ✅ Route resolution (path-based, priority-based, header-based)
- ✅ REST API for all operations (OpenAPI documented)
- ✅ Basic web UI (Svelte) for configuration
- ✅ Full observability (Prometheus metrics, Jaeger tracing, structured logging)
- ✅ CLI for deployment and management
- ✅ Docker Compose for local development
- ✅ Kubernetes manifests and Helm charts
- ✅ PostgreSQL + Redis for storage
- ✅ Database migrations (Goose) and seeds
- ✅ Type-safe queries (sqlc)
- ✅ Single-tenant mode
- ✅ API key authentication
- ✅ Tool-level access control (basic)
- ✅ Complete documentation and examples

**Enterprise Features - github.com/giru-ai/giru-enterprise (Proprietary)**

Additional features built on top of open-source core:
- 🔒 SSO integration (SAML, OIDC, Azure AD, Okta, Google Workspace)
- 🔒 MFA (TOTP, WebAuthn)
- 🔒 Advanced OPA policies:
  - Compliance (SOC2, HIPAA, GDPR, PCI-DSS)
  - ML-based anomaly detection
  - Adaptive rate limiting
  - Context-aware authorization (time, location, environment)
  - Data classification and PII filtering
- 🔒 Multi-tenancy with full resource isolation
- 🔒 Enhanced audit logging with compliance reports
- 🔒 Advanced analytics and usage reporting
- 🔒 Advanced web UI (multi-tenant management, compliance dashboards)
- 🔒 License management system
- 🔒 24/7 premium support with SLA guarantees
- 🔒 Advanced deployment tools (Terraform modules, enterprise Helm charts)
- 🔒 Metering and billing integration (for managed SaaS)

**Distribution Model:**
- **Open Source**: Public GitHub repository, Docker images (`giru/gateway:latest`)
- **Enterprise**: Private repository, binary/Docker distribution (`giru/gateway:enterprise`)
- **Integration**: Enterprise imports and extends open-source core

### 3. Enterprise License Management

**Runtime License Validation**
```go
// giru-enterprise/pkg/license/manager.go
package license

type Manager struct {
    publicKey *rsa.PublicKey
}

type License struct {
    CustomerID   string
    Features     []string
    ExpiresAt    time.Time
    MaxTenants   int
    MaxServers   int
    Support      string // "standard", "premium", "enterprise"
}

func (m *Manager) Validate() (*License, error) {
    // Load license from file or environment
    licenseData, err := loadLicense()
    if err != nil {
        return nil, fmt.Errorf("no valid license found")
    }
    
    // Verify RSA signature
    if err := m.verifySignature(licenseData); err != nil {
        return nil, fmt.Errorf("invalid license signature")
    }
    
    // Parse and validate expiration
    lic, err := parseLicense(licenseData)
    if err != nil {
        return nil, err
    }
    
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
    
    for _, f := range lic.Features {
        if f == feature {
            return true
        }
    }
    return false
}
```

**Feature Gates in Enterprise**
```go
// giru-enterprise/cmd/giru-enterprise/main.go
func main() {
    // Validate license first
    licMgr := license.NewManager()
    lic, err := licMgr.Validate()
    if err != nil {
        log.Fatalf("License validation failed: %v", err)
    }
    
    log.Printf("Licensed to: %s (expires: %s)", lic.CustomerID, lic.ExpiresAt)
    
    // Create base server from open-source
    srv := server.New(config.Load())
    
    // Conditionally enable enterprise features based on license
    if licMgr.HasFeature("sso") {
        srv.RegisterAuthProvider(sso.NewSAMLProvider())
        srv.RegisterAuthProvider(sso.NewOIDCProvider())
        log.Println("✅ SSO enabled")
    }
    
    if licMgr.HasFeature("multi-tenancy") {
        srv.EnableMultiTenancy(multitenancy.NewManager(lic.MaxTenants))
        log.Printf("✅ Multi-tenancy enabled (max: %d tenants)", lic.MaxTenants)
    }
    
    if licMgr.HasFeature("compliance") {
        srv.LoadOPAPolicies("compliance/*")
        log.Println("✅ Compliance policies loaded")
    }
    
    if licMgr.HasFeature("advanced-audit") {
        srv.RegisterAuditLogger(audit.NewEnhancedLogger())
        log.Println("✅ Enhanced audit logging enabled")
    }
    
    srv.Start()
}
```

**License File Location**
- `/etc/giru/license.key` (production)
- Environment variable: `GIRU_LICENSE_KEY`
- Format: JWT signed with RSA private key
- Validation: RSA public key embedded in binary

**No License = Open Source Mode**
```go
// If no license is found, enterprise binary falls back to open-source features
if err := licMgr.Validate(); err != nil {
    log.Warn("Running in open-source mode (no valid license)")
    srv := server.New(config.Load())  // Just the open-source core
    srv.Start()
    return
}
```

### 4. Configuration Management (GitOps)

**Manifest Structure**
- YAML-based configuration
- Kubernetes-style API (apiVersion, kind, metadata, spec)
- CRD-like structure for familiarity
- Schema validation using JSON Schema

**Example Manifest Types**
1. `MCPServer` - MCP server registration
2. `Route` - Routing rules
3. `Client` - Client configuration
4. `Policy` - OPA policy bundle references

**Configuration Flow**
1. User commits manifest changes to Git
2. CI/CD validates manifests and policies
3. Control plane loads configuration from PostgreSQL
4. xDS server pushes updates to Envoy
5. Zero-downtime configuration reload

### 5. Observability (Three Pillars)

**Metrics (Prometheus)**
- Envoy metrics (requests, latency, errors)
- OPA decision metrics
- Control plane health metrics
- Custom business metrics (tool usage, etc.)
- Grafana dashboards

**Logging (Structured)**
- Envoy access logs (JSON format)
- OPA decision logs
- Control plane application logs
- Audit logs (enterprise)
- Log aggregation: Loki or ELK stack

**Tracing (Distributed)**
- Jaeger integration
- OpenTelemetry support
- End-to-end request tracing
- Performance bottleneck identification

### 6. Security Architecture

**Defense in Depth**
1. **Network**: TLS 1.3, mTLS for service-to-service
2. **Authentication**: JWT, API keys, SSO (enterprise)
3. **Authorization**: OPA policies with RBAC/ABAC
4. **Data Protection**: PII filtering, encryption at rest
5. **Audit**: Immutable logs, compliance reporting

**Security Features**
- Rate limiting (prevent abuse)
- Circuit breaking (resilience)
- Request validation (prevent injection)
- CORS policies
- DDoS protection

### 7. Development & Deployment Environments

**Tier 1: Docker Compose (Primary Development - 95% of time)**
- Fast iteration (~10 second startup)
- Hot reload: air (Go), Vite (Svelte), xDS (Envoy), OPA bundles
- Full stack: Envoy + OPA + Control Plane + PostgreSQL + Redis
- No Kubernetes knowledge required
- Resource efficient
- **Use for:** Daily development, adding features, writing policies, UI work

**Tier 2: kind + Skaffold (Kubernetes Testing - 5% of time)**
- Real Kubernetes environment
- Multi-tenant testing (namespaces)
- Service mesh integration (Istio)
- Manifest validation
- Hot reload in K8s (Skaffold file sync)
- **Use for:** Integration tests, K8s-specific features, pre-PR validation

**Tier 3: Production Builds (CI/CD)**
- **Option A**: Docker buildx (multi-arch, standard)
- **Option B**: ko (Go-specific, faster, distroless)
- **Use for:** Production images, multi-arch support, security scanning

**Staging**
- Kubernetes deployment (EKS/GKE/AKS)
- Horizontal Pod Autoscaling
- Service mesh integration (optional)
- Monitoring stack (Prometheus, Grafana, Jaeger)

**Production**
- Multi-zone deployment
- HA PostgreSQL (primary/replica)
- Redis cluster
- Automated backups
- Canary deployments
- Blue/green deployments

### 8. Build System & Container Strategies

**Build System: Makefile (CNCF Standard)**
- All major CNCF projects use Makefile (Kubernetes, OPA, Prometheus, etcd, etc.)
- Zero installation required for contributors
- Native CI/CD support in all platforms
- Cross-platform compatibility with proper configuration
- Efficient parallel builds with `make -j`

**Container Build Strategies**

**Option A: Docker (Standard - Recommended for MVP)**
```dockerfile
# Multi-stage build for Go control plane
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /giru-control-plane ./cmd/server

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /giru-control-plane /
EXPOSE 8080
ENTRYPOINT ["/giru-control-plane"]
```

**Option B: ko (Go-Optimized - Optional)**
```yaml
# No Dockerfile needed, reference in K8s manifest:
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      containers:
        - name: control-plane
          image: ko://github.com/giru/giru-gateway/packages/core/control-plane/cmd/server
```

**Build Comparison:**

| Method | Speed | Image Size | Multi-arch | Flexibility | Learning Curve |
|--------|-------|------------|------------|-------------|----------------|
| **Docker** | Medium | ~20MB | ✅ buildx | ✅ High | Easy |
| **ko** | Fast | ~15MB | ✅ Native | ⚠️ Go only | Medium |

**Recommendation:** 
- **MVP/Development**: Use Docker (familiar, flexible)
- **Production**: Consider ko for Go binaries (faster, smaller)
- **Non-Go images**: Always use Docker (Envoy, OPA, Svelte UI)

**Build Scripts**
```bash
# Build community edition (Docker)
make build-community

# Build enterprise edition (Docker)
make build-enterprise

# Build with ko (Go binaries only)
make build-ko

# Multi-arch production builds
make build-production

# Run tests
make test

# Policy tests
make test-policies

# Parallel builds
make -j8 build test
```

**Edition Artifacts:**

**Community Edition**
- Includes: core packages only
- Docker images: 
  - `giru/gateway:community`
  - `giru/control-plane:community`
- Helm chart: `giru-core`

**Enterprise Edition**
- Includes: core + enterprise packages
- Requires valid license key at runtime
- Docker images:
  - `giru/gateway:enterprise`
  - `giru/control-plane:enterprise`
  - `giru/web-ui:enterprise`
- Helm chart: `giru-enterprise`

### 9. Testing Strategy

**Unit Tests**
- Go tests for control plane (80%+ coverage)
- OPA policy tests (100% coverage required)
- Svelte component tests with Vitest (enterprise UI)

**Integration Tests**
- Envoy + OPA integration
- Control plane + xDS
- End-to-end request flows

**Performance Tests**
- k6 load tests
- Target: 100K+ requests/second
- P99 latency < 5ms

**Security Tests**
- OWASP Top 10 scanning
- Dependency vulnerability scanning
- Policy compliance validation

### 10. Documentation Requirements

**Technical Documentation**
- Architecture diagrams (Mermaid or PlantUML)
- API reference (OpenAPI 3.0 spec with Swagger UI)
- Client generation guide (for programmatic access)
- Policy writing guide
- Deployment guides (K8s, Docker Compose)
- Troubleshooting guide

**User Documentation**
- Quick start (5-minute setup)
- Configuration reference
- Best practices
- Migration guides
- FAQ

**Enterprise Documentation**
- SSO integration guides
- Compliance mapping (SOC2, HIPAA, GDPR)
- Multi-tenancy setup
- Advanced analytics

### 11. CI/CD Pipelines

**GitHub Actions Workflows**

1. **CI Pipeline** (`.github/workflows/ci.yml`)
   - Lint Go code (golangci-lint)
   - Lint Svelte/TypeScript (ESLint + svelte-check)
   - Run Go unit tests
   - Run Svelte component tests (Vitest)
   - OPA policy tests
   - Security scanning (Trivy, Snyk)
   - Build Svelte UI (static assets)
   - Build Docker images
   - Push to registry (on main)

2. **Deploy Dev** (`.github/workflows/deploy-dev.yml`)
   - Trigger: Push to main
   - Deploy to dev Kubernetes cluster
   - Run smoke tests
   - Notify team

3. **Deploy Staging** (`.github/workflows/deploy-staging.yml`)
   - Trigger: Manual or tag
   - Deploy to staging
   - Run integration tests
   - Performance benchmarks

4. **Deploy Production** (`.github/workflows/deploy-production.yml`)
   - Trigger: Manual approval
   - Canary deployment (10% traffic)
   - Monitor canary metrics
   - Full rollout or rollback

5. **Policy Tests** (`.github/workflows/policy-tests.yml`)
   - Trigger: Changes to `policies/**`
   - Validate Rego syntax
   - Run policy unit tests
   - Check compliance mappings

### 12. Developer Experience

**Local Development Setup**

**Tier 1: Docker Compose (Recommended for Daily Work)**
```bash
# One-command setup
git clone https://github.com/giru/giru-gateway.git
cd giru-gateway
make dev-setup

# Starts Docker Compose with:
# - Envoy proxy
# - OPA policy engine
# - Control plane (with air hot reload)
# - PostgreSQL
# - Redis
# - Prometheus
# - Grafana

# Gateway available at: http://localhost:8080
# Control Plane API: http://localhost:18000
# Admin UI: http://localhost:5173 (Svelte dev server)
# Envoy Admin: http://localhost:9901
# OPA API: http://localhost:8181
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3000

# Development workflow
make dev-up         # Start all services
make dev-ui         # Start Svelte dev server (separate terminal)
make dev-logs       # Tail logs
make dev-down       # Stop all services
```

**Tier 2: kind + Skaffold (For Kubernetes Testing)**
```bash
# One-time setup
make kind-create    # Creates kind cluster

# Development with hot reload
make skaffold-dev   # Deploy to kind, tail logs, rebuild on changes

# Available at:
# - Gateway: http://localhost:8080 (port-forwarded)
# - All K8s features: kubectl get pods -n giru-dev

# Test multi-tenancy
kubectl create namespace tenant-acme
kubectl apply -f examples/multi-tenant/acme-config.yaml

# Cleanup
make kind-delete
```

**Hot Reload Support**

| Component | Docker Compose | kind + Skaffold |
|-----------|----------------|-----------------|
| **Go (Control Plane)** | ✅ air (instant) | ✅ Skaffold rebuild (~10s) |
| **Svelte UI** | ✅ Vite HMR (instant) | ✅ File sync (instant) |
| **Envoy Config** | ✅ xDS push (instant) | ✅ xDS push (instant) |
| **OPA Policies** | ✅ Bundle reload (~1s) | ✅ Bundle reload (~1s) |
| **K8s Manifests** | ❌ N/A | ✅ kubectl apply (~2s) |

**CLI Tool (Primary Interface)**
```bash
# Install CLI
go install github.com/giru/giru-gateway/packages/core/cli@latest

# Manage servers
giru server list
giru server create --name my-server --endpoint https://mcp.example.com
giru server delete my-server
giru server describe my-server
giru server health my-server

# Manage policies
giru policy validate policy.rego
giru policy test policy.rego
giru policy apply -f policy.rego
giru policy list

# Deploy configurations
giru apply -f manifests/
giru deploy --env production --wait

# Get cluster info
giru cluster info
giru cluster health
```

**OpenAPI Specification (For Programmatic Access)**
```bash
# View API docs
giru api docs
# Opens Swagger UI at http://localhost:8080/api/docs

# Generate client in any language
npx @openapitools/openapi-generator-cli generate \
  -i http://localhost:8080/api/openapi.yaml \
  -g typescript-fetch \
  -o ./giru-client

# Use generated client
import { ServersApi } from './giru-client';
const api = new ServersApi({ basePath: 'http://localhost:8080' });
const servers = await api.listServers();
```

**REST API Examples**
```bash
# Create MCP server via curl
curl -X POST http://localhost:8080/api/v1/servers \
  -H "Authorization: Bearer $Giru_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "my-server",
    "endpoint": "https://mcp.example.com",
    "protocol": "http"
  }'

# List servers
curl http://localhost:8080/api/v1/servers \
  -H "Authorization: Bearer $Giru_API_KEY"
```

### 13. Community and Contribution

**Contribution Guidelines**
- Contributor License Agreement (CLA)
- Code of conduct
- PR template with checklist
- Issue templates (bug, feature request, enterprise)

**Community Resources**
- GitHub Discussions for Q&A
- Discord server for real-time chat
- Monthly community calls
- Blog for announcements
- YouTube for tutorials

**Open Source Best Practices**
- Semantic versioning
- Changelog (keepachangelog.com format)
- Security policy (SECURITY.md)
- Responsible disclosure process
- Regular releases (monthly)

### 14. Monitoring and Alerting

**Prometheus Alerts**
```yaml
groups:
  - name: giru_alerts
    rules:
      - alert: HighErrorRate
        expr: rate(envoy_cluster_upstream_rq{envoy_response_code=~"5.."}[5m]) > 0.05
        annotations:
          summary: "High error rate detected"
      
      - alert: HighLatency
        expr: histogram_quantile(0.99, envoy_cluster_upstream_rq_time_bucket) > 100
        annotations:
          summary: "P99 latency above 100ms"
```

**Grafana Dashboards**
- Gateway overview (traffic, errors, latency)
- OPA policy decisions
- MCP server health
- Resource utilization
- Business metrics (tool usage)

### 15. Release Process

**Versioning**
- Community: v1.0.0, v1.1.0, etc.
- Enterprise: v1.0.0-enterprise

**Release Checklist**
1. Update CHANGELOG.md
2. Run full test suite
3. Security scan
4. Build Docker images
5. Push to registry
6. Create GitHub release
7. Update documentation
8. Announce release

**Support Policy**
- Community: Best effort, GitHub issues
- Enterprise: SLA-based support, 24/7 critical issues

## Initial Implementation Priority

### Phase 1: MVP (Weeks 1-4)
1. Repository structure and licensing
2. Basic Envoy configuration
3. OPA integration with sample policies
4. **Compliance policy implementations** (see Compliance Policy Code section below)
   - HIPAA minimum necessary standard
   - PCI-DSS data access controls
   - SOC2 audit logging requirements
5. Control plane (xDS server + basic API)
6. Docker Compose for local dev
7. Basic CLI
8. Documentation (quick start, architecture)

### Phase 2: Production Ready (Weeks 5-8)
1. Kubernetes deployment manifests
2. Helm charts
3. Monitoring stack (Prometheus, Grafana, Jaeger)
4. CI/CD pipelines
5. Integration tests
6. Security hardening
7. Production deployment guide

### Phase 3: Enterprise Features (Weeks 9-12)
1. SSO integration (SAML, OIDC)
2. Multi-tenancy
3. Enhanced audit logging
4. Compliance policies (SOC2, HIPAA)
5. Web-based admin UI
6. License management
7. Advanced analytics

### Phase 4: Polish and Launch (Weeks 13-16)
1. Performance optimization
2. Load testing and tuning
3. Documentation polish
4. Video tutorials
5. Example applications
6. Community launch
7. Marketing website

### Phase 5: Managed SaaS Foundation (Future)
1. Multi-tenant control plane architecture
2. Usage metering and billing integration
3. Customer portal and onboarding
4. Automated provisioning
5. SLA monitoring and guarantees
6. Official SDKs (TypeScript, Python, Go) for SaaS API
7. Terraform provider for infrastructure-as-code

## Technical Decisions and Rationale

### Why Envoy?
- Battle-tested at Netflix, Lyft, AWS
- 3-10x faster than Go stdlib
- Dynamic configuration (xDS)
- Service mesh compatibility
- Industry standard

### Why OPA?
- CNCF graduated (trusted)
- Declarative policies (readable by compliance)
- Testable (unit tests for policies)
- Version controlled (GitOps native)
- Used by Goldman Sachs, Netflix

### Why Go for Control Plane?
- Performance (compiled, concurrent)
- Ecosystem (gRPC, Kubernetes clients)
- Developer familiarity
- Easy deployment (single binary)

### Why Single Repo (Monorepo)?
- Industry standard (Elastic, GitLab)
- Easier development workflow
- Shared code between editions
- Simplified CI/CD
- Community can see enterprise features

### Why PostgreSQL?
- ACID compliance
- JSON support (flexible schemas)
- Robust replication
- Operational maturity
- Free and open source

### Why Svelte for UI?
- **5x Smaller Bundle**: ~60KB vs 250KB (Next.js/React)
- **Compile-Time Framework**: No virtual DOM, compiles to vanilla JS
- **Simpler Syntax**: Less boilerplate than React, easier to maintain
- **TypeScript Support**: Full type safety
- **SSR/SSG**: Built into SvelteKit
- **Real-time Native**: Easy WebSocket/SSE integration
- **Great DX**: Fast HMR, intuitive reactivity with Runes
- **Enterprise Adoption**: 1Password, Spotify, Apple Music use Svelte
- **Performance**: Better for daily-use dashboards (ops teams)

### Why Fiber for HTTP Framework?
- **Performance**: 6M req/sec (2.4x faster than Gin, 3.3x faster than stdlib)
- Zero memory allocation in hot paths (fasthttp)
- Express-like API (familiar to developers)
- Rich middleware ecosystem (CORS, compression, rate limiting)
- Production-proven (Alibaba, etc.)
- Perfect for infrastructure-grade performance requirements

### Why Makefile over Taskfile?
- **CNCF Standard**: 100% of major Go CNCF projects use Makefile
- **Zero Installation**: Works out-of-the-box on all Unix systems
- **CI/CD Native**: Built-in support in GitHub Actions, GitLab CI, etc.
- **Enterprise Familiarity**: Operations teams know `make` universally
- **40+ Years**: Battle-tested, proven, mature ecosystem
- **Parallel Builds**: Native `-j` flag for concurrent execution

### Why No SDKs (Initially)?
- **Infrastructure, Not SaaS**: Like Kubernetes, users interact via CLI and manifests
- **CLI Covers 95% of Use Cases**: `giru server create`, `giru policy apply`
- **OpenAPI Spec Available**: Users can generate clients in any language on-demand
- **Lower Maintenance**: No multi-language SDK versioning/releases
- **Future SaaS Offering**: When launching managed SaaS, will add polished SDKs for programmatic access

### Why Goose for Migrations?
- **Simplicity**: Just SQL files with sequential versioning, zero learning curve
- **Infrastructure Pattern**: Explicit control over schema changes (vs declarative)
- **Seed Data Support**: Native support for SQL seeds and Go-based complex seeding
- **Production Track Record**: Used by Kubernetes projects, GitLab, infrastructure companies
- **Go Integration**: Embeds in control plane binary for automated migrations
- **Clear Audit Trail**: Sequential SQL files show exactly what changed when

### Why pgx + sqlc for Database Layer?
- **Performance**: pgx is 30-50% faster than GORM (no reflection, PostgreSQL-native)
- **Type Safety**: sqlc generates type-safe Go code from SQL queries
- **Maintainability**: SQL queries in .sql files (easier to review, optimize, version)
- **Zero Runtime Overhead**: Code generation at build time, no reflection
- **PostgreSQL Features**: Full access to advanced features (JSONB, arrays, custom types)
- **Explicit Control**: Perfect for infrastructure projects with stable schemas

## Compliance Policy Code

This section provides reference implementations of the pre-built compliance blueprints that differentiate Giru from generic MCP gateways.

### Directory Structure

```
packages/policies/
├── hipaa/                      # HIPAA compliance policies
│   ├── minimum_necessary.rego  # Minimum necessary standard
│   ├── access_controls.rego    # Access control requirements
│   ├── audit_controls.rego     # Audit and accountability
│   ├── encryption.rego         # Encryption standards
│   └── breach_notification.rego # Breach detection
├── pci_dss/                    # PCI-DSS compliance policies
│   ├── cardholder_data.rego    # Protect stored data
│   ├── access_control.rego     # Restrict access by business need
│   ├── encryption.rego         # Encrypt transmission of data
│   ├── audit_logging.rego      # Track and monitor access
│   └── testing.rego            # Regularly test security
├── soc2/                       # SOC2 compliance policies
│   ├── access_control.rego     # Logical access controls
│   ├── change_management.rego  # System operations
│   ├── risk_mitigation.rego    # Risk assessment
│   └── monitoring.rego         # Monitoring controls
├── common/                     # Shared utilities
│   ├── rate_limiting.rego      # Rate limiting utilities
│   ├── time_windows.rego       # Time-based access controls
│   └── helpers.rego            # Common helper functions
└── tests/                      # Policy tests
    ├── hipaa_test.rego
    ├── pci_dss_test.rego
    └── soc2_test.rego
```

### HIPAA Policies

#### packages/policies/hipaa/minimum_necessary.rego

```rego
# HIPAA Minimum Necessary Standard (45 CFR § 164.502(b))
# Ensures MCP tools only access the minimum PHI required for the intended purpose
package hipaa.minimum_necessary

import future.keywords.if
import future.keywords.in

# Default deny - require explicit approval for PHI access
default allow := false

# Track if request involves PHI
is_phi_request if {
    some tag in input.mcp.tool.tags
    tag == "phi"
}

is_phi_request if {
    contains(lower(input.mcp.tool.name), "patient")
}

is_phi_request if {
    contains(lower(input.mcp.tool.name), "medical")
}

# Deny if requesting more records than justified
deny[msg] if {
    is_phi_request
    input.mcp.arguments.record_count > input.context.clinical_need_threshold
    msg := sprintf(
        "HIPAA violation: Requesting %d records exceeds clinical need threshold of %d",
        [input.mcp.arguments.record_count, input.context.clinical_need_threshold]
    )
}

# Deny if requesting fields beyond minimum necessary
deny[msg] if {
    is_phi_request
    some field in input.mcp.arguments.fields
    not field in data.hipaa.permitted_fields[input.context.user_role]
    msg := sprintf(
        "HIPAA violation: Field '%s' not permitted for role '%s'",
        [field, input.context.user_role]
    )
}

# Deny access outside permitted time windows
deny[msg] if {
    is_phi_request
    not is_within_access_hours
    msg := "HIPAA violation: PHI access outside permitted hours"
}

is_within_access_hours if {
    current_hour := time.clock([time.now_ns()])[0]
    start_hour := data.hipaa.access_hours[input.context.user_role].start
    end_hour := data.hipaa.access_hours[input.context.user_role].end
    current_hour >= start_hour
    current_hour < end_hour
}

# Allow if all checks pass
allow if {
    is_phi_request
    count(deny) == 0
    input.context.user_authenticated
}

# Audit requirement - every PHI access must be logged
audit_required[entry] if {
    is_phi_request
    allow
    entry := {
        "timestamp": time.now_ns(),
        "user_id": input.context.user_id,
        "user_role": input.context.user_role,
        "tool_name": input.mcp.tool.name,
        "action": "phi_access",
        "record_count": input.mcp.arguments.record_count,
        "fields_accessed": input.mcp.arguments.fields,
        "purpose": input.context.purpose_of_use,
        "compliance_framework": "HIPAA_164.502(b)",
    }
}
```

#### packages/policies/hipaa/access_controls.rego

```rego
# HIPAA Access Control Requirements (45 CFR § 164.312(a))
# Implements unique user identification, emergency access, and automatic logoff
package hipaa.access_controls

import future.keywords.if
import future.keywords.in

# Require unique user identification
deny[msg] if {
    not input.context.user_id
    msg := "HIPAA violation: Missing unique user identification (164.312(a)(2)(i))"
}

# Require emergency access procedure for break-glass scenarios
allow_emergency_access if {
    input.context.emergency_access_enabled
    input.context.break_glass_authorized
    input.context.emergency_justification
}

deny[msg] if {
    input.context.emergency_access_requested
    not allow_emergency_access
    msg := "HIPAA violation: Emergency access requested without proper authorization"
}

# Automatic logoff after period of inactivity
deny[msg] if {
    session_inactive_minutes := (time.now_ns() - input.context.last_activity_ns) / 60000000000
    session_inactive_minutes > 15  # 15 minute timeout
    not input.context.emergency_access_enabled
    msg := sprintf(
        "HIPAA violation: Session inactive for %d minutes (auto-logoff required)",
        [session_inactive_minutes]
    )
}

# Require encryption for PHI in transit
deny[msg] if {
    not input.request.tls_enabled
    some tag in input.mcp.tool.tags
    tag == "phi"
    msg := "HIPAA violation: PHI transmission requires TLS encryption (164.312(e)(1))"
}

# Role-based access control
deny[msg] if {
    required_roles := data.hipaa.tool_role_requirements[input.mcp.tool.name]
    not input.context.user_role in required_roles
    msg := sprintf(
        "HIPAA violation: Role '%s' not authorized for tool '%s'",
        [input.context.user_role, input.mcp.tool.name]
    )
}
```

### PCI-DSS Policies

#### packages/policies/pci_dss/cardholder_data.rego

```rego
# PCI-DSS Requirement 3: Protect Stored Cardholder Data
# Ensures proper handling of credit card data in MCP tool requests
package pci_dss.cardholder_data

import future.keywords.if
import future.keywords.in

# Detect if request involves cardholder data
is_cardholder_data if {
    some tag in input.mcp.tool.tags
    tag in ["pci", "payment", "cardholder_data"]
}

# PCI-DSS 3.4: Render PAN unreadable (mask, truncate, hash)
deny[msg] if {
    is_cardholder_data
    some arg_name, arg_value in input.mcp.arguments
    is_full_pan(arg_value)
    msg := sprintf(
        "PCI-DSS violation: Full PAN detected in argument '%s'. Must be masked/truncated (Req 3.4)",
        [arg_name]
    )
}

# Detect full Primary Account Number (PAN)
is_full_pan(value) if {
    is_string(value)
    # Remove spaces and dashes
    cleaned := replace(replace(value, " ", ""), "-", "")
    # Check if it's 13-19 digits (valid card number length)
    count(cleaned) >= 13
    count(cleaned) <= 19
    # Check if all characters are digits
    regex.match(`^\d+$`, cleaned)
    # Luhn algorithm check (proper credit card validation)
    luhn_valid(cleaned)
}

# Luhn algorithm implementation
luhn_valid(pan) if {
    digits := [to_number(c) | c := split(pan, "")[_]]
    checksum := luhn_checksum(digits, count(digits) - 1, 0, false)
    checksum % 10 == 0
}

luhn_checksum(digits, index, sum, double) := sum if {
    index < 0
}

luhn_checksum(digits, index, sum, double) := new_sum if {
    index >= 0
    digit := digits[index]
    doubled := double
    
    # Double every second digit from the right
    digit_to_add := digit * 2 if doubled else digit
    
    # If doubled digit > 9, subtract 9
    final_digit := digit_to_add - 9 if digit_to_add > 9 else digit_to_add
    
    new_sum := luhn_checksum(digits, index - 1, sum + final_digit, not doubled)
}

# PCI-DSS 3.5: Protect encryption keys
deny[msg] if {
    is_cardholder_data
    not input.context.encryption_key_management_enabled
    msg := "PCI-DSS violation: Cardholder data access requires encryption key management (Req 3.5)"
}

# PCI-DSS 3.6: Document and implement key management processes
deny[msg] if {
    is_cardholder_data
    not input.context.key_custodian_authorized
    msg := "PCI-DSS violation: Only authorized key custodians can access cardholder data (Req 3.6)"
}
```

#### packages/policies/pci_dss/access_control.rego

```rego
# PCI-DSS Requirement 7: Restrict Access by Business Need-to-Know
package pci_dss.access_control

import future.keywords.if

# PCI-DSS 7.1: Limit access to system components and cardholder data
deny[msg] if {
    some tag in input.mcp.tool.tags
    tag in ["pci", "payment", "cardholder_data"]
    
    not has_business_need
    msg := "PCI-DSS violation: Access denied - no documented business need-to-know (Req 7.1)"
}

has_business_need if {
    # Check if user's job function requires access
    user_functions := data.pci_dss.user_job_functions[input.context.user_id]
    tool_required_function := data.pci_dss.tool_job_requirements[input.mcp.tool.name]
    tool_required_function in user_functions
}

# PCI-DSS 7.2: Establish access control system with deny-all default
default allow := false

allow if {
    has_business_need
    count(deny) == 0
}

# PCI-DSS 7.3: Restrict physical access to cardholder data
deny[msg] if {
    some tag in input.mcp.tool.tags
    tag == "cardholder_data"
    
    # Check if request originates from secure facility
    not input.context.network_zone in data.pci_dss.cardholder_data_zones
    msg := sprintf(
        "PCI-DSS violation: Cardholder data access only permitted from secure zones, not '%s' (Req 7.3)",
        [input.context.network_zone]
    )
}
```

### SOC2 Policies

#### packages/policies/soc2/access_control.rego

```rego
# SOC2 Trust Services Criteria: Common Criteria 6.0 - Logical and Physical Access Controls
package soc2.access_control

import future.keywords.if

# CC6.1: Logical access security measures to protect information assets
deny[msg] if {
    not input.context.user_authenticated
    msg := "SOC2 violation: Unauthenticated access not permitted (CC6.1)"
}

deny[msg] if {
    not input.context.mfa_verified
    input.mcp.tool.sensitivity_level == "high"
    msg := "SOC2 violation: MFA required for high-sensitivity tools (CC6.1)"
}

# CC6.2: Prior to issuing system credentials, personnel authorized
deny[msg] if {
    not user_authorized_in_iam_system
    msg := "SOC2 violation: User not found in IAM authorization system (CC6.2)"
}

user_authorized_in_iam_system if {
    data.soc2.authorized_users[input.context.user_id]
}

# CC6.3: Logical access removed when no longer required
deny[msg] if {
    user_access_expired
    msg := "SOC2 violation: User access has expired and must be re-certified (CC6.3)"
}

user_access_expired if {
    last_cert := data.soc2.user_certifications[input.context.user_id].last_certified_ns
    days_since_cert := (time.now_ns() - last_cert) / 86400000000000  # Convert to days
    days_since_cert > 90  # Re-certify every 90 days
}

# CC6.6: Audit logs and monitoring
audit_required[entry] if {
    allow
    entry := {
        "timestamp": time.now_ns(),
        "event_type": "mcp_tool_access",
        "user_id": input.context.user_id,
        "tool_name": input.mcp.tool.name,
        "sensitivity_level": input.mcp.tool.sensitivity_level,
        "source_ip": input.request.source_ip,
        "trust_service": "CC6.6",
    }
}
```

#### packages/policies/soc2/monitoring.rego

```rego
# SOC2 Trust Services Criteria: Common Criteria 7.0 - System Operations
package soc2.monitoring

import future.keywords.if

# CC7.2: System monitoring controls to detect anomalies
deny[msg] if {
    is_anomalous_request
    msg := sprintf(
        "SOC2 violation: Anomalous request pattern detected for user %s (CC7.2)",
        [input.context.user_id]
    )
}

is_anomalous_request if {
    # Check for unusual request volume
    recent_requests := data.soc2.user_request_counts[input.context.user_id].last_hour
    recent_requests > 100  # Threshold for anomaly
}

is_anomalous_request if {
    # Check for access outside normal hours
    current_hour := time.clock([time.now_ns()])[0]
    not current_hour in data.soc2.user_normal_hours[input.context.user_id]
}

is_anomalous_request if {
    # Check for geographic anomaly
    not input.request.geo_location in data.soc2.user_normal_locations[input.context.user_id]
}

# CC7.3: Response to identified security events
alert_required[alert] if {
    is_anomalous_request
    alert := {
        "severity": "medium",
        "type": "anomalous_access_pattern",
        "user_id": input.context.user_id,
        "timestamp": time.now_ns(),
        "action_required": "review_and_investigate",
        "trust_service": "CC7.3",
    }
}
```

### Policy Data Configuration

These policies reference data files that customers configure based on their environment:

#### data/hipaa/permitted_fields.json

```json
{
  "physician": ["patient_id", "name", "diagnosis", "medications", "vitals", "lab_results"],
  "nurse": ["patient_id", "name", "medications", "vitals", "care_plan"],
  "billing": ["patient_id", "name", "insurance_id", "billing_codes"],
  "researcher": ["patient_id_hashed", "age_range", "diagnosis", "outcomes"]
}
```

#### data/pci_dss/cardholder_data_zones.json

```json
{
  "cardholder_data_zones": [
    "secure-zone-1",
    "payment-processing-zone",
    "pci-compliant-datacenter"
  ]
}
```

### Testing Policies

#### packages/policies/tests/hipaa_test.rego

```rego
package hipaa.minimum_necessary_test

import data.hipaa.minimum_necessary

# Test: Deny excessive record requests
test_deny_excessive_records if {
    input := {
        "mcp": {
            "tool": {
                "name": "get_patient_records",
                "tags": ["phi"],
            },
            "arguments": {
                "record_count": 100,
                "fields": ["patient_id", "name"],
            },
        },
        "context": {
            "user_id": "user123",
            "user_role": "physician",
            "user_authenticated": true,
            "clinical_need_threshold": 10,
        },
    }
    
    count(minimum_necessary.deny) > 0
    some msg in minimum_necessary.deny
    contains(msg, "exceeds clinical need threshold")
}

# Test: Allow appropriate requests
test_allow_appropriate_request if {
    input := {
        "mcp": {
            "tool": {
                "name": "get_patient_records",
                "tags": ["phi"],
            },
            "arguments": {
                "record_count": 5,
                "fields": ["patient_id", "name"],
            },
        },
        "context": {
            "user_id": "user123",
            "user_role": "physician",
            "user_authenticated": true,
            "clinical_need_threshold": 10,
        },
    }
    
    minimum_necessary.allow
}
```

### Integration with Envoy

These OPA policies are loaded into the Envoy External Authorization filter:

#### configs/envoy/envoy.yaml (snippet)

```yaml
http_filters:
  - name: envoy.filters.http.ext_authz
    typed_config:
      "@type": type.googleapis.com/envoy.extensions.filters.http.ext_authz.v3.ExtAuthz
      grpc_service:
        envoy_grpc:
          cluster_name: opa
        timeout: 0.5s
      with_request_body:
        max_request_bytes: 8192
        allow_partial_message: true
      failure_mode_allow: false  # Fail closed for security
      transport_api_version: V3
      # Include metadata for policy decisions
      metadata_context_namespaces:
        - envoy.filters.http.header_to_metadata
```

### Key Features of These Policies

1. **Compliance-Ready**: Map directly to regulatory requirements (45 CFR § 164.502(b), PCI-DSS Req 3.4, SOC2 CC6.1)
2. **Testable**: Include unit tests that can be run with `opa test`
3. **Auditable**: Generate structured audit logs for compliance officers
4. **Configurable**: Use external data files for customer-specific rules
5. **Production-Grade**: Include helper functions (Luhn algorithm, time windows, etc.)

This is the technical moat that differentiates Giru from competitors who only provide generic gateway infrastructure.

## Authentication & Credential Management

### Overview

Giru solves a critical UX problem: **MCP credential management hell**. Users typically manage OAuth tokens, API keys, and connection strings manually across dozens of MCP servers. Giru abstracts this completely using HashiCorp Vault as a secure credential vault.

**User Experience**:
- ✅ Click "Connect GitHub MCP" → OAuth flow → Done (never see tokens)
- ✅ Tokens automatically refreshed before expiration
- ✅ Zero configuration files, zero credential sprawl
- ✅ Audit trail of every credential access (SOC2/HIPAA compliant)

**This is a differentiator**: Generic MCP implementations force users to manage credentials manually. Giru's credential vault is zero-friction.

### The Three Authentication Layers

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 1: User → Giru Gateway                                │
│ Purpose: Authenticate WHO is using the platform             │
│                                                             │
│ Methods:                                                    │
│ - Open Core: API Keys                                       │
│ - Enterprise: SSO (SAML/OIDC via Okta/Auth0)              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Layer 2: Client (AI Agent) → Giru Gateway                  │
│ Purpose: Authenticate WHICH agent is making requests        │
│                                                             │
│ Methods:                                                    │
│ - API Keys (recommended for MVP)                           │
│ - OAuth 2.1 Client Credentials (enterprise agents)        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Layer 3: Giru Gateway → MCP Servers (THE HARD PART)        │
│ Purpose: Authenticate TO backend MCP services               │
│                                                             │
│ Reality: Every MCP has different auth mechanisms            │
│ - GitHub MCP: OAuth 2.0 with GitHub API                    │
│ - Slack MCP: OAuth 2.0 with Slack API                      │
│ - Database MCP: Connection strings                         │
│ - File System MCP: No auth (local STDIO)                   │
│                                                             │
│ Solution: Giru stores credentials in HashiCorp Vault       │
└─────────────────────────────────────────────────────────────┘
```

### Why HashiCorp Vault?

| Feature | HashiCorp Vault | AWS KMS / GCP KMS | pgcrypto |
|---------|----------------|-------------------|----------|
| **Cloud-agnostic** | ✅ Any cloud + on-prem | ❌ Vendor lock-in | ✅ Yes |
| **Self-hosted** | ✅ Aligns with deployment model | ❌ Managed only | ✅ Yes |
| **Dynamic secrets** | ✅ Generate DB creds on-demand | ❌ No | ❌ No |
| **Auto rotation** | ✅ Built-in | ❌ Manual | ❌ Manual |
| **Multi-tenancy** | ✅ Namespaces | ❌ Multi-account | ⚠️ Same key |
| **Audit logging** | ✅ Every access | ✅ Yes | ❌ No |
| **Secret versioning** | ✅ Automatic | ❌ No | ❌ No |
| **Cost** | 🏆 Free (OSS) | 💰 Pay per call | 🏆 Free |

**Decision**: Use Vault for production, pgcrypto fallback for MVP.

### Architecture Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                     User Experience                             │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  User clicks: "Connect GitHub MCP"                            │
│       ↓                                                        │
│  OAuth flow redirects to GitHub                               │
│       ↓                                                        │
│  User approves (GitHub sends token to Giru, NOT user)        │
│       ↓                                                        │
│  Done! User never sees token                                  │
└────────────────────────────────────────────────────────────────┘
                              ↓
┌────────────────────────────────────────────────────────────────┐
│                   Giru Control Plane                           │
│                                                                │
│  ┌──────────────────────────────────────────────────────┐    │
│  │ OAuth Handler                                        │    │
│  │ 1. Receives token from GitHub OAuth callback        │    │
│  │ 2. Stores in Vault: secret/tenants/{id}/mcp/github  │    │
│  │ 3. Saves Vault path reference in PostgreSQL         │    │
│  └──────────────────────────────────────────────────────┘    │
│                                                                │
│  ┌──────────────────────────────────────────────────────┐    │
│  │ MCP Request Handler                                  │    │
│  │ 1. AI agent calls "github__list_repos"              │    │
│  │ 2. Lookup: which MCP provides this tool?            │    │
│  │ 3. Fetch token from Vault (decrypt)                 │    │
│  │ 4. Forward request to GitHub MCP with token         │    │
│  │ 5. Return result to AI agent                        │    │
│  └──────────────────────────────────────────────────────┘    │
│                                                                │
│  ┌──────────────────────────────────────────────────────┐    │
│  │ Token Refresh Job (Background)                       │    │
│  │ 1. Find tokens expiring in next 24 hours            │    │
│  │ 2. Refresh using stored refresh_token               │    │
│  │ 3. Update Vault with new token (versioned)          │    │
│  └──────────────────────────────────────────────────────┘    │
└────────────────────────────────────────────────────────────────┘
                              ↓
┌────────────────────────────────────────────────────────────────┐
│              HashiCorp Vault (Credential Store)                │
│                                                                │
│  secret/                                                       │
│  ├── tenants/                                                 │
│  │   ├── tenant-uuid-1/                                      │
│  │   │   └── mcp/                                            │
│  │   │       ├── github/                                     │
│  │   │       │   └── data:                                   │
│  │   │       │       access_token: "gho_xxxxx" (encrypted)  │
│  │   │       │       expires_at: "2026-12-01"               │
│  │   │       │       scopes: ["repo", "read:org"]           │
│  │   │       ├── slack/                                      │
│  │   │       │   └── data:                                   │
│  │   │       │       access_token: "xoxb-xxxx"              │
│  │   │       │       refresh_token: "xoxe-xxxx"             │
│  │   │       │       expires_at: "2025-12-20"               │
│  │   │       └── postgres/                                   │
│  │   │           └── data:                                   │
│  │   │               connection_string: "postgresql://..."   │
│  │   └── tenant-uuid-2/                                      │
│  │       └── mcp/ ...                                        │
│                                                                │
│  Audit Log: /vault/logs/audit.log                            │
│  - Every read/write logged with timestamp, user, path        │
└────────────────────────────────────────────────────────────────┘
```

### Database Schema (Vault-aware)

```sql
-- MCP Servers: Store Vault references, NOT actual credentials
CREATE TABLE mcp_servers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    display_name VARCHAR(255),
    
    -- Connection details
    endpoint_url VARCHAR(500) NOT NULL,
    transport VARCHAR(50) NOT NULL DEFAULT 'stdio', -- 'stdio', 'sse', 'http'
    
    -- Authentication strategy
    auth_type VARCHAR(50) NOT NULL, -- 'oauth', 'api_key', 'basic', 'mtls', 'none'
    auth_provider VARCHAR(50), -- 'github', 'slack', 'google', 'custom', null
    
    -- Vault integration (production)
    vault_secret_path VARCHAR(500), -- e.g., "secret/data/tenants/uuid-123/mcp/github"
    vault_secret_version INTEGER, -- Track which version of secret we're using
    
    -- Fallback: pgcrypto encryption (MVP only)
    auth_config_encrypted BYTEA, -- Encrypted JSON with tokens (pgcrypto)
    
    -- Token lifecycle metadata
    token_expires_at TIMESTAMP,
    token_last_refreshed TIMESTAMP,
    token_refresh_enabled BOOLEAN DEFAULT false,
    
    -- MCP protocol info
    protocol_version VARCHAR(50) DEFAULT '2024-11-05',
    server_capabilities JSONB,
    
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    last_health_check TIMESTAMP,
    
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    UNIQUE(tenant_id, name),
    INDEX idx_mcp_servers_tenant (tenant_id),
    INDEX idx_mcp_servers_token_expiry (token_expires_at) -- For refresh job
    
    -- Constraint: Must have either vault_secret_path OR auth_config_encrypted
    CHECK (
        (vault_secret_path IS NOT NULL) OR 
        (auth_config_encrypted IS NOT NULL)
    )
);

-- OAuth callback state tracking (prevent CSRF)
CREATE TABLE oauth_states (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    state_token VARCHAR(255) NOT NULL UNIQUE,
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    provider VARCHAR(50) NOT NULL, -- 'github', 'slack', etc.
    redirect_uri TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP NOT NULL DEFAULT NOW() + INTERVAL '10 minutes',
    
    INDEX idx_oauth_states_token (state_token),
    INDEX idx_oauth_states_expires (expires_at)
);

-- Audit trail of credential operations (separate from Vault audit log)
CREATE TABLE credential_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    mcp_server_id UUID REFERENCES mcp_servers(id) ON DELETE SET NULL,
    operation VARCHAR(50) NOT NULL, -- 'created', 'read', 'refreshed', 'revoked'
    user_id UUID, -- Who performed the operation
    client_id UUID REFERENCES clients(id), -- Which AI agent accessed it
    ip_address INET,
    user_agent TEXT,
    success BOOLEAN NOT NULL,
    error_message TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    INDEX idx_credential_audit_tenant (tenant_id),
    INDEX idx_credential_audit_timestamp (created_at),
    INDEX idx_credential_audit_operation (operation)
);
```

### Vault Setup (Kubernetes)

#### Development (Single Pod)
```yaml
# deployments/k8s/dev/vault-dev.yaml
apiVersion: v1
kind: Pod
metadata:
  name: vault
  namespace: giru-dev
spec:
  containers:
  - name: vault
    image: hashicorp/vault:1.15
    command:
    - vault
    - server
    - -dev
    - -dev-root-token-id=root
    env:
    - name: VAULT_DEV_ROOT_TOKEN_ID
      value: "root"
    - name: VAULT_DEV_LISTEN_ADDRESS
      value: "0.0.0.0:8200"
    ports:
    - containerPort: 8200
      name: vault
---
apiVersion: v1
kind: Service
metadata:
  name: vault
  namespace: giru-dev
spec:
  selector:
    app: vault
  ports:
  - port: 8200
    targetPort: 8200
```

#### Production (HA Cluster with Raft Storage)
```yaml
# deployments/k8s/prod/vault-cluster.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: vault-config
  namespace: giru-prod
data:
  vault.hcl: |
    storage "raft" {
      path = "/vault/data"
      node_id = "HOSTNAME"
    }
    
    listener "tcp" {
      address = "0.0.0.0:8200"
      tls_disable = false
      tls_cert_file = "/vault/tls/tls.crt"
      tls_key_file = "/vault/tls/tls.key"
    }
    
    api_addr = "https://HOSTNAME:8200"
    cluster_addr = "https://HOSTNAME:8201"
    ui = true
    
    seal "awskms" {
      region = "us-east-1"
      kms_key_id = "alias/vault-unseal-key"
    }
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: vault
  namespace: giru-prod
spec:
  serviceName: vault
  replicas: 3
  selector:
    matchLabels:
      app: vault
  template:
    metadata:
      labels:
        app: vault
    spec:
      containers:
      - name: vault
        image: hashicorp/vault:1.15
        command:
        - /bin/sh
        - -c
        - |
          sed -i "s/HOSTNAME/${HOSTNAME}/g" /vault/config/vault.hcl
          vault server -config=/vault/config/vault.hcl
        env:
        - name: HOSTNAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: VAULT_ADDR
          value: "https://127.0.0.1:8200"
        - name: VAULT_SKIP_VERIFY
          value: "true"
        ports:
        - containerPort: 8200
          name: vault
        - containerPort: 8201
          name: cluster
        volumeMounts:
        - name: vault-data
          mountPath: /vault/data
        - name: vault-config
          mountPath: /vault/config
        - name: vault-tls
          mountPath: /vault/tls
        readinessProbe:
          httpGet:
            path: /v1/sys/health
            port: 8200
            scheme: HTTPS
          initialDelaySeconds: 10
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /v1/sys/health
            port: 8200
            scheme: HTTPS
          initialDelaySeconds: 30
          periodSeconds: 10
      volumes:
      - name: vault-config
        configMap:
          name: vault-config
      - name: vault-tls
        secret:
          secretName: vault-tls
  volumeClaimTemplates:
  - metadata:
      name: vault-data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: fast-ssd
      resources:
        requests:
          storage: 10Gi
---
apiVersion: v1
kind: Service
metadata:
  name: vault
  namespace: giru-prod
spec:
  clusterIP: None
  selector:
    app: vault
  ports:
  - name: vault
    port: 8200
    targetPort: 8200
  - name: cluster
    port: 8201
    targetPort: 8201
---
apiVersion: v1
kind: Service
metadata:
  name: vault-active
  namespace: giru-prod
spec:
  selector:
    app: vault
    vault-active: "true"
  ports:
  - port: 8200
    targetPort: 8200
```

### Go Implementation

#### 1. Vault Client Wrapper

```go
// packages/core/control-plane/internal/vault/client.go
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
        return nil, fmt.Errorf("failed to create vault client: %w", err)
    }
    
    client.SetToken(token)
    
    // Test connection
    _, err = client.Sys().Health()
    if err != nil {
        return nil, fmt.Errorf("vault health check failed: %w", err)
    }
    
    return &Client{client: client}, nil
}

// StoreOAuthToken stores OAuth credentials in Vault KV v2
func (v *Client) StoreOAuthToken(ctx context.Context, tenantID, provider string, token *OAuthToken) (string, int, error) {
    path := fmt.Sprintf("tenants/%s/mcp/%s", tenantID, provider)
    
    data := map[string]interface{}{
        "access_token":  token.AccessToken,
        "refresh_token": token.RefreshToken,
        "token_type":    token.TokenType,
        "expires_at":    token.ExpiresAt.Format(time.RFC3339),
        "scopes":        token.Scopes,
        "stored_at":     time.Now().Format(time.RFC3339),
    }
    
    // Write to Vault KV v2 (automatically versioned)
    secret, err := v.client.KVv2("secret").Put(ctx, path, data)
    if err != nil {
        return "", 0, fmt.Errorf("failed to store token in vault: %w", err)
    }
    
    versionInt := int(secret.VersionMetadata.Version)
    fullPath := fmt.Sprintf("secret/data/%s", path)
    
    return fullPath, versionInt, nil
}

// GetOAuthToken retrieves OAuth credentials from Vault
func (v *Client) GetOAuthToken(ctx context.Context, path string) (*OAuthToken, error) {
    // Extract path without "secret/data/" prefix for KVv2 API
    cleanPath := strings.TrimPrefix(path, "secret/data/")
    
    secret, err := v.client.KVv2("secret").Get(ctx, cleanPath)
    if err != nil {
        return nil, fmt.Errorf("failed to read token from vault: %w", err)
    }
    
    data := secret.Data
    
    expiresAt, err := time.Parse(time.RFC3339, data["expires_at"].(string))
    if err != nil {
        return nil, fmt.Errorf("invalid expires_at format: %w", err)
    }
    
    scopes := []string{}
    if scopesRaw, ok := data["scopes"].([]interface{}); ok {
        for _, s := range scopesRaw {
            scopes = append(scopes, s.(string))
        }
    }
    
    return &OAuthToken{
        AccessToken:  data["access_token"].(string),
        RefreshToken: data["refresh_token"].(string),
        TokenType:    data["token_type"].(string),
        ExpiresAt:    expiresAt,
        Scopes:       scopes,
    }, nil
}

// DeleteOAuthToken revokes OAuth credentials
func (v *Client) DeleteOAuthToken(ctx context.Context, path string) error {
    cleanPath := strings.TrimPrefix(path, "secret/data/")
    return v.client.KVv2("secret").DeleteMetadata(ctx, cleanPath)
}

// GetSecretVersion retrieves a specific version of a secret
func (v *Client) GetSecretVersion(ctx context.Context, path string, version int) (*OAuthToken, error) {
    cleanPath := strings.TrimPrefix(path, "secret/data/")
    
    secret, err := v.client.KVv2("secret").GetVersion(ctx, cleanPath, version)
    if err != nil {
        return nil, fmt.Errorf("failed to read version %d: %w", version, err)
    }
    
    // Same parsing as GetOAuthToken...
    return parseOAuthToken(secret.Data)
}
```

#### 2. OAuth Handler (GitHub Example)

```go
// packages/core/control-plane/internal/oauth/github.go
package oauth

import (
    "crypto/rand"
    "encoding/base64"
    "fmt"
    "time"
    
    "github.com/gofiber/fiber/v2"
    "golang.org/x/oauth2"
    "golang.org/x/oauth2/github"
    
    "github.com/giru/giru-gateway/packages/core/control-plane/internal/db"
    "github.com/giru/giru-gateway/packages/core/control-plane/internal/vault"
)

type GitHubOAuthHandler struct {
    db           *db.DB
    vault        *vault.Client
    oauthConfig  *oauth2.Config
}

func NewGitHubOAuthHandler(db *db.DB, vault *vault.Client, clientID, clientSecret, redirectURL string) *GitHubOAuthHandler {
    return &GitHubOAuthHandler{
        db:    db,
        vault: vault,
        oauthConfig: &oauth2.Config{
            ClientID:     clientID,
            ClientSecret: clientSecret,
            RedirectURL:  redirectURL,
            Scopes:       []string{"repo", "read:org", "user:email"},
            Endpoint:     github.Endpoint,
        },
    }
}

// InitiateOAuth starts the OAuth flow
func (h *GitHubOAuthHandler) InitiateOAuth(c *fiber.Ctx) error {
    tenantID := c.Locals("tenant_id").(string)
    
    // Generate CSRF token
    stateBytes := make([]byte, 32)
    rand.Read(stateBytes)
    state := base64.URLEncoding.EncodeToString(stateBytes)
    
    // Store state in database (expires in 10 minutes)
    err := h.db.CreateOAuthState(c.Context(), &db.CreateOAuthStateParams{
        StateToken:  state,
        TenantID:    tenantID,
        Provider:    "github",
        RedirectURI: c.Query("redirect_uri", "/ui/mcp-catalog"),
        ExpiresAt:   time.Now().Add(10 * time.Minute),
    })
    if err != nil {
        return fiber.NewError(500, "Failed to initiate OAuth")
    }
    
    // Redirect to GitHub
    authURL := h.oauthConfig.AuthCodeURL(state, oauth2.AccessTypeOffline)
    return c.Redirect(authURL, 302)
}

// HandleCallback processes OAuth callback from GitHub
func (h *GitHubOAuthHandler) HandleCallback(c *fiber.Ctx) error {
    ctx := c.Context()
    
    // Validate state token (CSRF protection)
    state := c.Query("state")
    oauthState, err := h.db.GetOAuthState(ctx, state)
    if err != nil {
        return fiber.NewError(400, "Invalid or expired state token")
    }
    
    // Delete used state token
    h.db.DeleteOAuthState(ctx, state)
    
    // Exchange code for token
    code := c.Query("code")
    token, err := h.oauthConfig.Exchange(ctx, code)
    if err != nil {
        return fiber.NewError(500, "Failed to exchange code for token")
    }
    
    // Store token in Vault
    vaultPath, version, err := h.vault.StoreOAuthToken(ctx, oauthState.TenantID, "github", &vault.OAuthToken{
        AccessToken:  token.AccessToken,
        RefreshToken: token.RefreshToken,
        TokenType:    token.TokenType,
        ExpiresAt:    token.Expiry,
        Scopes:       h.oauthConfig.Scopes,
    })
    if err != nil {
        return fiber.NewError(500, "Failed to store credentials")
    }
    
    // Create or update MCP server record
    err = h.db.UpsertMCPServer(ctx, &db.UpsertMCPServerParams{
        TenantID:            oauthState.TenantID,
        Name:                "github",
        DisplayName:         "GitHub MCP",
        EndpointURL:         "npx:-y:@modelcontextprotocol/server-github",
        Transport:           "stdio",
        AuthType:            "oauth",
        AuthProvider:        "github",
        VaultSecretPath:     vaultPath,
        VaultSecretVersion:  version,
        TokenExpiresAt:      sql.NullTime{Time: token.Expiry, Valid: true},
        TokenRefreshEnabled: true,
    })
    if err != nil {
        return fiber.NewError(500, "Failed to save MCP server configuration")
    }
    
    // Audit log
    h.db.CreateCredentialAuditLog(ctx, &db.CreateCredentialAuditLogParams{
        TenantID:  oauthState.TenantID,
        Operation: "created",
        Success:   true,
        IPAddress: c.IP(),
        UserAgent: c.Get("User-Agent"),
    })
    
    // Redirect back to UI
    redirectURI := oauthState.RedirectURI + "?success=github"
    return c.Redirect(redirectURI, 302)
}
```

#### 3. MCP Request Handler (Using Vault Credentials)

```go
// packages/core/control-plane/internal/handlers/mcp_jsonrpc.go
package handlers

import (
    "context"
    "fmt"
    "time"
    
    "github.com/giru/giru-gateway/packages/core/control-plane/internal/db"
    "github.com/giru/giru-gateway/packages/core/control-plane/internal/vault"
    "github.com/giru/giru-gateway/packages/core/control-plane/internal/mcp"
)

type MCPHandler struct {
    db        *db.DB
    vault     *vault.Client
    mcpClient *mcp.Client
}

// HandleToolsCall processes MCP tools/call requests
func (h *MCPHandler) HandleToolsCall(ctx context.Context, req *MCPRequest) (*MCPResponse, error) {
    toolName := req.Params.Name
    clientID := ctx.Value("client_id").(string)
    
    // 1. Resolve which MCP server provides this tool
    mcpServer, err := h.db.ResolveToolSubscription(ctx, clientID, toolName)
    if err != nil {
        return nil, fmt.Errorf("no subscription grants access to tool %s: %w", toolName, err)
    }
    
    // 2. Fetch credentials from Vault (if needed)
    var authToken string
    if mcpServer.AuthType == "oauth" || mcpServer.AuthType == "api_key" {
        // Check if token is expired
        if mcpServer.TokenExpiresAt.Valid && time.Now().After(mcpServer.TokenExpiresAt.Time) {
            return nil, fmt.Errorf("token expired, refresh required")
        }
        
        // Fetch from Vault
        token, err := h.vault.GetOAuthToken(ctx, mcpServer.VaultSecretPath)
        if err != nil {
            // Audit log: credential access failed
            h.db.CreateCredentialAuditLog(ctx, &db.CreateCredentialAuditLogParams{
                TenantID:     mcpServer.TenantID,
                MCPServerID:  sql.NullString{String: mcpServer.ID, Valid: true},
                Operation:    "read",
                Success:      false,
                ErrorMessage: sql.NullString{String: err.Error(), Valid: true},
            })
            
            return nil, fmt.Errorf("failed to retrieve credentials: %w", err)
        }
        
        authToken = token.AccessToken
        
        // Audit log: successful credential access
        h.db.CreateCredentialAuditLog(ctx, &db.CreateCredentialAuditLogParams{
            TenantID:    mcpServer.TenantID,
            MCPServerID: sql.NullString{String: mcpServer.ID, Valid: true},
            ClientID:    sql.NullString{String: clientID, Valid: true},
            Operation:   "read",
            Success:     true,
        })
    }
    
    // 3. Call MCP server with credentials
    response, err := h.mcpClient.CallTool(ctx, &mcp.CallToolRequest{
        ServerEndpoint: mcpServer.EndpointURL,
        Transport:      mcpServer.Transport,
        ToolName:       toolName,
        Arguments:      req.Params.Arguments,
        Auth: &mcp.Auth{
            Type:  mcpServer.AuthType,
            Token: authToken,
        },
    })
    
    if err != nil {
        return nil, fmt.Errorf("MCP call failed: %w", err)
    }
    
    return response, nil
}
```

#### 4. Background Token Refresh Job

```go
// packages/core/control-plane/internal/jobs/token_refresher.go
package jobs

import (
    "context"
    "log"
    "time"
    
    "github.com/giru/giru-gateway/packages/core/control-plane/internal/db"
    "github.com/giru/giru-gateway/packages/core/control-plane/internal/vault"
    "github.com/giru/giru-gateway/packages/core/control-plane/internal/oauth"
)

type TokenRefresher struct {
    db           *db.DB
    vault        *vault.Client
    oauthClients map[string]oauth.RefreshHandler // provider -> client
}

func NewTokenRefresher(db *db.DB, vault *vault.Client) *TokenRefresher {
    return &TokenRefresher{
        db:    db,
        vault: vault,
        oauthClients: map[string]oauth.RefreshHandler{
            "github": oauth.NewGitHubRefresher(),
            "slack":  oauth.NewSlackRefresher(),
            "google": oauth.NewGoogleRefresher(),
        },
    }
}

// Run executes token refresh job every hour
func (r *TokenRefresher) Run(ctx context.Context) {
    ticker := time.NewTicker(1 * time.Hour)
    defer ticker.Stop()
    
    for {
        select {
        case <-ticker.C:
            r.refreshExpiredTokens(ctx)
        case <-ctx.Done():
            return
        }
    }
}

func (r *TokenRefresher) refreshExpiredTokens(ctx context.Context) {
    // Find tokens expiring in next 24 hours
    servers, err := r.db.GetMCPServersWithExpiringTokens(ctx, time.Now().Add(24*time.Hour))
    if err != nil {
        log.Printf("Error fetching expiring tokens: %v", err)
        return
    }
    
    log.Printf("Found %d tokens to refresh", len(servers))
    
    for _, server := range servers {
        // Skip if refresh not enabled
        if !server.TokenRefreshEnabled {
            continue
        }
        
        // Get refresh handler for provider
        refresher, ok := r.oauthClients[server.AuthProvider]
        if !ok {
            log.Printf("No refresh handler for provider: %s", server.AuthProvider)
            continue
        }
        
        // Fetch current token from Vault
        oldToken, err := r.vault.GetOAuthToken(ctx, server.VaultSecretPath)
        if err != nil {
            log.Printf("Failed to fetch token for %s: %v", server.Name, err)
            continue
        }
        
        // Refresh token
        newToken, err := refresher.RefreshToken(ctx, oldToken.RefreshToken)
        if err != nil {
            log.Printf("Failed to refresh token for %s: %v", server.Name, err)
            
            // Audit log: refresh failed
            r.db.CreateCredentialAuditLog(ctx, &db.CreateCredentialAuditLogParams{
                TenantID:     server.TenantID,
                MCPServerID:  sql.NullString{String: server.ID, Valid: true},
                Operation:    "refreshed",
                Success:      false,
                ErrorMessage: sql.NullString{String: err.Error(), Valid: true},
            })
            
            continue
        }
        
        // Store new token in Vault (creates new version)
        vaultPath, version, err := r.vault.StoreOAuthToken(ctx, server.TenantID, server.AuthProvider, newToken)
        if err != nil {
            log.Printf("Failed to store refreshed token for %s: %v", server.Name, err)
            continue
        }
        
        // Update database with new expiry and version
        err = r.db.UpdateMCPServerToken(ctx, &db.UpdateMCPServerTokenParams{
            ID:                 server.ID,
            VaultSecretVersion: version,
            TokenExpiresAt:     sql.NullTime{Time: newToken.ExpiresAt, Valid: true},
            TokenLastRefreshed: sql.NullTime{Time: time.Now(), Valid: true},
        })
        if err != nil {
            log.Printf("Failed to update database for %s: %v", server.Name, err)
            continue
        }
        
        // Audit log: successful refresh
        r.db.CreateCredentialAuditLog(ctx, &db.CreateCredentialAuditLogParams{
            TenantID:    server.TenantID,
            MCPServerID: sql.NullString{String: server.ID, Valid: true},
            Operation:   "refreshed",
            Success:     true,
        })
        
        log.Printf("Successfully refreshed token for %s (version %d)", server.Name, version)
    }
}
```

### Migration Strategy: pgcrypto → Vault

For customers who start with MVP (pgcrypto) and upgrade to production (Vault):

```sql
-- db/migrations/00010_add_vault_support.sql
-- +goose Up

-- Add Vault columns (nullable for backwards compatibility)
ALTER TABLE mcp_servers 
  ADD COLUMN vault_secret_path VARCHAR(500),
  ADD COLUMN vault_secret_version INTEGER,
  ADD COLUMN token_refresh_enabled BOOLEAN DEFAULT false;

-- Add index for token refresh job
CREATE INDEX idx_mcp_servers_token_expiry ON mcp_servers(token_expires_at) 
  WHERE token_refresh_enabled = true AND status = 'active';

-- +goose Down
ALTER TABLE mcp_servers 
  DROP COLUMN vault_secret_path,
  DROP COLUMN vault_secret_version,
  DROP COLUMN token_refresh_enabled;

DROP INDEX idx_mcp_servers_token_expiry;
```

Migration script:
```go
// cmd/migrate-to-vault/main.go
package main

import (
    "context"
    "log"
    
    "github.com/giru/giru-gateway/packages/core/control-plane/internal/db"
    "github.com/giru/giru-gateway/packages/core/control-plane/internal/vault"
)

func main() {
    ctx := context.Background()
    
    // Connect to database and Vault
    database, _ := db.Connect(ctx, os.Getenv("DATABASE_URL"))
    vaultClient, _ := vault.NewClient(os.Getenv("VAULT_ADDR"), os.Getenv("VAULT_TOKEN"))
    
    // Find all MCP servers with pgcrypto credentials
    servers, err := database.GetMCPServersWithEncryptedConfig(ctx)
    if err != nil {
        log.Fatalf("Failed to fetch servers: %v", err)
    }
    
    log.Printf("Migrating %d servers from pgcrypto to Vault...", len(servers))
    
    for _, server := range servers {
        // Decrypt from pgcrypto
        token, err := decryptPgcrypto(server.AuthConfigEncrypted)
        if err != nil {
            log.Printf("Failed to decrypt %s: %v", server.Name, err)
            continue
        }
        
        // Store in Vault
        vaultPath, version, err := vaultClient.StoreOAuthToken(ctx, server.TenantID, server.AuthProvider, token)
        if err != nil {
            log.Printf("Failed to store %s in Vault: %v", server.Name, err)
            continue
        }
        
        // Update database
        err = database.MigrateToVault(ctx, &db.MigrateToVaultParams{
            ID:                  server.ID,
            VaultSecretPath:     vaultPath,
            VaultSecretVersion:  version,
            AuthConfigEncrypted: nil, // Clear old encrypted data
        })
        if err != nil {
            log.Printf("Failed to update database for %s: %v", server.Name, err)
            continue
        }
        
        log.Printf("✓ Migrated %s to Vault (version %d)", server.Name, version)
    }
    
    log.Println("Migration complete!")
}
```

### Compliance Benefits

| Regulation | Requirement | How Vault Helps |
|------------|-------------|----------------|
| **HIPAA § 164.312(a)(2)(iv)** | Encryption at rest | ✅ Vault encrypts all secrets with AES-256-GCM |
| **HIPAA § 164.308(a)(1)(ii)(D)** | Audit controls | ✅ Vault audit log records every access |
| **PCI-DSS Req 3.5** | Protect encryption keys | ✅ Vault manages keys, not application code |
| **PCI-DSS Req 7** | Restrict access by need-to-know | ✅ Vault policies enforce fine-grained access |
| **SOC2 CC6.1** | Logical access controls | ✅ Vault authentication required for secrets |
| **SOC2 CC6.6** | Audit logging | ✅ Every secret read/write logged |
| **GDPR Art. 32** | Encryption of personal data | ✅ OAuth tokens encrypted before storage |

### Phase Implementation

**Phase 1: MVP (Week 4) - pgcrypto Only**
```go
// Use PostgreSQL built-in encryption
auth_config_encrypted = pgp_sym_encrypt('{"token":"..."}', encryption_key)
```
- Simpler for first customers
- No additional infrastructure
- Good enough for pilots

**Phase 2: Production (Week 8) - Add Vault**
- Deploy Vault cluster
- Migrate existing credentials
- Enable automatic token refresh
- Implement audit logging

**Phase 3: Enterprise (Week 12) - Advanced Vault Features**
- Vault namespaces per tenant (isolation)
- Dynamic database credentials (generate on-demand)
- Vault Agent sidecar injection
- Vault Enterprise features (HSM, FIPS 140-2)

### Security Checklist

- [ ] Vault root token rotated after initial setup
- [ ] Vault audit logging enabled
- [ ] Vault auto-unseal configured (AWS KMS/GCP KMS)
- [ ] Vault TLS certificates valid and rotated
- [ ] Vault backup strategy implemented
- [ ] PostgreSQL connection uses TLS
- [ ] Database encryption key stored in environment (not code)
- [ ] OAuth state tokens expire after 10 minutes
- [ ] CSRF protection on OAuth callbacks
- [ ] Rate limiting on OAuth endpoints (prevent abuse)
- [ ] Credential access logged for compliance
- [ ] Token refresh alerts on failure
- [ ] Vault health checks monitored

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
└─────────────────────────────────────────┘
```

### Directory Structure

```
packages/core/control-plane/
├── db/
│   ├── migrations/              # Goose migrations
│   │   ├── 00001_init.sql
│   │   ├── 00002_add_tenants.sql
│   │   ├── 00003_add_policies.sql
│   │   ├── 00004_add_audit_logs.sql
│   │   └── embed.go            # Embed migrations in binary
│   ├── seeds/                  # Seed data
│   │   ├── 001_tenants.sql
│   │   ├── 002_demo_servers.sql
│   │   └── 003_default_policies.sql
│   ├── queries/                # sqlc queries
│   │   ├── tenants.sql
│   │   ├── servers.sql
│   │   ├── policies.sql
│   │   ├── routes.sql
│   │   └── clients.sql
│   ├── schema.sql              # Complete schema (generated from migrations)
│   └── sqlc.yaml               # sqlc configuration
├── internal/
│   └── database/
│       ├── db.go               # Connection pool
│       ├── migrations.go       # Goose runner
│       ├── models/             # sqlc generated models
│       │   ├── db.go
│       │   ├── tenants.sql.go
│       │   ├── servers.sql.go
│       │   └── querier.go
│       └── tx.go               # Transaction helpers
```

### Migration Files (Goose)

**Example: Initial Schema**

```sql
-- db/migrations/00001_init.sql
-- +goose Up
-- +goose StatementBegin

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Tenants table (for multi-tenancy)
CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL UNIQUE,
    display_name VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    license_key TEXT,
    license_type VARCHAR(50) DEFAULT 'community', -- community, enterprise
    features JSONB DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP
);

CREATE INDEX idx_tenants_status ON tenants(status);
CREATE INDEX idx_tenants_license_type ON tenants(license_type);

-- MCP Servers registry
CREATE TABLE mcp_servers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    display_name VARCHAR(255) NOT NULL,
    endpoint VARCHAR(512) NOT NULL,
    protocol VARCHAR(50) NOT NULL, -- http, grpc, stdio
    status VARCHAR(50) NOT NULL DEFAULT 'healthy',
    health_check_url VARCHAR(512),
    health_check_interval_seconds INT DEFAULT 30,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP,
    UNIQUE(tenant_id, name)
);

CREATE INDEX idx_servers_tenant ON mcp_servers(tenant_id);
CREATE INDEX idx_servers_status ON mcp_servers(status);
CREATE INDEX idx_servers_name ON mcp_servers(name);

-- Routes configuration
CREATE TABLE routes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    path_pattern VARCHAR(512) NOT NULL,
    server_id UUID NOT NULL REFERENCES mcp_servers(id) ON DELETE CASCADE,
    priority INT DEFAULT 0,
    enabled BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(tenant_id, name)
);

CREATE INDEX idx_routes_tenant ON routes(tenant_id);
CREATE INDEX idx_routes_server ON routes(server_id);
CREATE INDEX idx_routes_priority ON routes(priority DESC);

-- Clients (API consumers)
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    api_key_hash TEXT NOT NULL,
    permissions JSONB DEFAULT '[]',
    rate_limit_rps INT DEFAULT 100,
    enabled BOOLEAN DEFAULT true,
    last_used_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP,
    UNIQUE(tenant_id, name)
);

CREATE INDEX idx_clients_tenant ON clients(tenant_id);
CREATE INDEX idx_clients_api_key ON clients(api_key_hash);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS clients;
DROP TABLE IF EXISTS routes;
DROP TABLE IF EXISTS mcp_servers;
DROP TABLE IF EXISTS tenants;
DROP EXTENSION IF EXISTS "pgcrypto";
DROP EXTENSION IF EXISTS "uuid-ossp";
-- +goose StatementEnd
```

**Example: Add Audit Logging (Enterprise)**

```sql
-- db/migrations/00004_add_audit_logs.sql
-- +goose Up
-- +goose StatementBegin

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    event_type VARCHAR(100) NOT NULL,
    actor_type VARCHAR(50) NOT NULL, -- user, system, client
    actor_id UUID,
    resource_type VARCHAR(100) NOT NULL,
    resource_id UUID,
    action VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL, -- success, failure
    details JSONB DEFAULT '{}',
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_tenant ON audit_logs(tenant_id);
CREATE INDEX idx_audit_created ON audit_logs(created_at DESC);
CREATE INDEX idx_audit_event ON audit_logs(event_type);
CREATE INDEX idx_audit_resource ON audit_logs(resource_type, resource_id);

-- Partition by month for performance
CREATE TABLE audit_logs_y2025m01 PARTITION OF audit_logs
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS audit_logs_y2025m01;
DROP TABLE IF EXISTS audit_logs;
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
        package: "models"
        out: "../internal/database/models"
        sql_package: "pgx/v5"
        emit_json_tags: true
        emit_prepared_queries: false
        emit_interface: true
        emit_exact_table_names: false
        emit_empty_slices: true
        emit_exported_queries: true
        emit_result_struct_pointers: false
        emit_params_struct_pointers: false
        emit_methods_with_db_argument: false
        emit_pointers_for_null_types: true
        emit_enum_valid_method: true
        emit_all_enum_values: true
        json_tags_case_style: "snake"
        omit_unused_structs: true
```

### Query Files (sqlc)

**Example: Tenant Queries**

```sql
-- db/queries/tenants.sql

-- name: CreateTenant :one
INSERT INTO tenants (
    name,
    display_name,
    license_type,
    features,
    metadata
) VALUES (
    $1, $2, $3, $4, $5
) RETURNING *;

-- name: GetTenant :one
SELECT * FROM tenants
WHERE id = $1 AND deleted_at IS NULL;

-- name: GetTenantByName :one
SELECT * FROM tenants
WHERE name = $1 AND deleted_at IS NULL;

-- name: ListTenants :many
SELECT * FROM tenants
WHERE deleted_at IS NULL
ORDER BY created_at DESC
LIMIT $1 OFFSET $2;

-- name: UpdateTenant :one
UPDATE tenants
SET
    display_name = COALESCE(sqlc.narg('display_name'), display_name),
    status = COALESCE(sqlc.narg('status'), status),
    license_key = COALESCE(sqlc.narg('license_key'), license_key),
    license_type = COALESCE(sqlc.narg('license_type'), license_type),
    features = COALESCE(sqlc.narg('features'), features),
    metadata = COALESCE(sqlc.narg('metadata'), metadata),
    updated_at = NOW()
WHERE id = $1 AND deleted_at IS NULL
RETURNING *;

-- name: DeleteTenant :exec
UPDATE tenants
SET deleted_at = NOW()
WHERE id = $1;

-- name: CountTenantsByLicenseType :many
SELECT license_type, COUNT(*) as count
FROM tenants
WHERE deleted_at IS NULL
GROUP BY license_type;
```

**Example: Server Queries**

```sql
-- db/queries/servers.sql

-- name: CreateServer :one
INSERT INTO mcp_servers (
    tenant_id,
    name,
    display_name,
    endpoint,
    protocol,
    health_check_url,
    health_check_interval_seconds,
    metadata
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8
) RETURNING *;

-- name: GetServer :one
SELECT * FROM mcp_servers
WHERE id = $1 AND deleted_at IS NULL;

-- name: GetServerByName :one
SELECT * FROM mcp_servers
WHERE tenant_id = $1 AND name = $2 AND deleted_at IS NULL;

-- name: ListServersByTenant :many
SELECT * FROM mcp_servers
WHERE tenant_id = $1 AND deleted_at IS NULL
ORDER BY created_at DESC;

-- name: ListHealthyServers :many
SELECT * FROM mcp_servers
WHERE tenant_id = $1 
  AND status = 'healthy' 
  AND deleted_at IS NULL
ORDER BY created_at DESC;

-- name: UpdateServerStatus :exec
UPDATE mcp_servers
SET 
    status = $2,
    updated_at = NOW()
WHERE id = $1;

-- name: DeleteServer :exec
UPDATE mcp_servers
SET deleted_at = NOW()
WHERE id = $1;
```

### Seed Data

**Example: Default Tenants**

```sql
-- db/seeds/001_tenants.sql
INSERT INTO tenants (id, name, display_name, license_type, features)
VALUES 
    ('00000000-0000-0000-0000-000000000001', 'demo', 'Demo Tenant', 'community', '{"max_servers": 5}'),
    ('00000000-0000-0000-0000-000000000002', 'enterprise-demo', 'Enterprise Demo', 'enterprise', '{"max_servers": 100, "sso": true, "audit_logs": true}')
ON CONFLICT (name) DO NOTHING;
```

**Example: Demo Servers**

```sql
-- db/seeds/002_demo_servers.sql
INSERT INTO mcp_servers (tenant_id, name, display_name, endpoint, protocol, health_check_url)
VALUES 
    ('00000000-0000-0000-0000-000000000001', 'filesystem', 'Filesystem MCP', 'http://mcp-filesystem:8080', 'http', 'http://mcp-filesystem:8080/health'),
    ('00000000-0000-0000-0000-000000000001', 'github', 'GitHub MCP', 'http://mcp-github:8080', 'http', 'http://mcp-github:8080/health')
ON CONFLICT (tenant_id, name) DO NOTHING;
```

### Go Integration

**Database Connection**

```go
// internal/database/db.go
package database

import (
    "context"
    "fmt"
    "time"

    "github.com/jackc/pgx/v5/pgxpool"
    "github.com/giru/giru-gateway/packages/core/control-plane/internal/database/models"
)

type DB struct {
    Pool    *pgxpool.Pool
    Queries *models.Queries
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
    config.HealthCheckPeriod = 1 * time.Minute

    pool, err := pgxpool.NewWithConfig(ctx, config)
    if err != nil {
        return nil, fmt.Errorf("create connection pool: %w", err)
    }

    // Verify connection
    if err := pool.Ping(ctx); err != nil {
        return nil, fmt.Errorf("ping database: %w", err)
    }

    return &DB{
        Pool:    pool,
        Queries: models.New(pool),
    }, nil
}

func (db *DB) Close() {
    db.Pool.Close()
}
```

**Migration Runner**

```go
// internal/database/migrations.go
package database

import (
    "embed"
    "fmt"

    "github.com/jackc/pgx/v5/stdlib"
    "github.com/pressly/goose/v3"
)

//go:embed migrations/*.sql
var embedMigrations embed.FS

func RunMigrations(databaseURL string) error {
    // Open database connection
    db, err := stdlib.OpenDB(*stdlib.ParseConfig(databaseURL))
    if err != nil {
        return fmt.Errorf("open database: %w", err)
    }
    defer db.Close()

    // Set embed FS
    goose.SetBaseFS(embedMigrations)

    // Run migrations
    if err := goose.SetDialect("postgres"); err != nil {
        return fmt.Errorf("set dialect: %w", err)
    }

    if err := goose.Up(db, "migrations"); err != nil {
        return fmt.Errorf("run migrations: %w", err)
    }

    return nil
}

func GetMigrationStatus(databaseURL string) error {
    db, err := stdlib.OpenDB(*stdlib.ParseConfig(databaseURL))
    if err != nil {
        return fmt.Errorf("open database: %w", err)
    }
    defer db.Close()

    goose.SetBaseFS(embedMigrations)
    if err := goose.SetDialect("postgres"); err != nil {
        return err
    }

    return goose.Status(db, "migrations")
}
```

**Transaction Helper**

```go
// internal/database/tx.go
package database

import (
    "context"
    "fmt"

    "github.com/jackc/pgx/v5"
)

type TxFunc func(ctx context.Context, tx pgx.Tx) error

func (db *DB) WithTx(ctx context.Context, fn TxFunc) error {
    tx, err := db.Pool.Begin(ctx)
    if err != nil {
        return fmt.Errorf("begin transaction: %w", err)
    }

    defer func() {
        if p := recover(); p != nil {
            _ = tx.Rollback(ctx)
            panic(p)
        }
    }()

    if err := fn(ctx, tx); err != nil {
        if rbErr := tx.Rollback(ctx); rbErr != nil {
            return fmt.Errorf("rollback transaction: %v (original error: %w)", rbErr, err)
        }
        return err
    }

    if err := tx.Commit(ctx); err != nil {
        return fmt.Errorf("commit transaction: %w", err)
    }

    return nil
}
```

**Usage Example**

```go
// pkg/api/rest/handlers/tenants.go
package handlers

import (
    "github.com/gofiber/fiber/v2"
    "github.com/giru/giru-gateway/packages/core/control-plane/internal/database"
    "github.com/giru/giru-gateway/packages/core/control-plane/internal/database/models"
)

type TenantHandler struct {
    db *database.DB
}

func NewTenantHandler(db *database.DB) *TenantHandler {
    return &TenantHandler{db: db}
}

func (h *TenantHandler) CreateTenant(c *fiber.Ctx) error {
    var req struct {
        Name        string `json:"name" validate:"required"`
        DisplayName string `json:"display_name" validate:"required"`
        LicenseType string `json:"license_type"`
    }

    if err := c.BodyParser(&req); err != nil {
        return c.Status(400).JSON(fiber.Map{"error": "invalid request"})
    }

    tenant, err := h.db.Queries.CreateTenant(c.Context(), models.CreateTenantParams{
        Name:        req.Name,
        DisplayName: req.DisplayName,
        LicenseType: req.LicenseType,
        Features:    []byte("{}"),
        Metadata:    []byte("{}"),
    })

    if err != nil {
        return c.Status(500).JSON(fiber.Map{"error": "failed to create tenant"})
    }

    return c.Status(201).JSON(tenant)
}

func (h *TenantHandler) ListTenants(c *fiber.Ctx) error {
    limit := c.QueryInt("limit", 20)
    offset := c.QueryInt("offset", 0)

    tenants, err := h.db.Queries.ListTenants(c.Context(), models.ListTenantsParams{
        Limit:  int32(limit),
        Offset: int32(offset),
    })

    if err != nil {
        return c.Status(500).JSON(fiber.Map{"error": "failed to list tenants"})
    }

    return c.JSON(tenants)
}
```

### Makefile Targets

```makefile
# Database management targets

.PHONY: db-install
db-install: ## Install goose CLI
	@echo "$(COLOR_BOLD)Installing goose...$(COLOR_RESET)"
	go install github.com/pressly/goose/v3/cmd/goose@latest

.PHONY: db-create
db-create: ## Create database
	@echo "$(COLOR_BOLD)Creating database...$(COLOR_RESET)"
	createdb giru

.PHONY: db-drop
db-drop: ## Drop database
	@echo "$(COLOR_BOLD)Dropping database...$(COLOR_RESET)"
	dropdb giru

.PHONY: db-migrate
db-migrate: ## Run database migrations
	@echo "$(COLOR_BOLD)Running migrations...$(COLOR_RESET)"
	goose -dir packages/core/control-plane/db/migrations postgres "${DATABASE_URL}" up

.PHONY: db-migrate-status
db-migrate-status: ## Show migration status
	@echo "$(COLOR_BOLD)Migration status:$(COLOR_RESET)"
	goose -dir packages/core/control-plane/db/migrations postgres "${DATABASE_URL}" status

.PHONY: db-migrate-down
db-migrate-down: ## Rollback last migration
	@echo "$(COLOR_BOLD)Rolling back last migration...$(COLOR_RESET)"
	goose -dir packages/core/control-plane/db/migrations postgres "${DATABASE_URL}" down

.PHONY: db-migrate-reset
db-migrate-reset: ## Reset all migrations
	@echo "$(COLOR_BOLD)Resetting all migrations...$(COLOR_RESET)"
	goose -dir packages/core/control-plane/db/migrations postgres "${DATABASE_URL}" reset

.PHONY: db-migrate-create
db-migrate-create: ## Create new migration (usage: make db-migrate-create NAME=add_users)
	@if [ -z "$(NAME)" ]; then \
		echo "$(COLOR_YELLOW)Usage: make db-migrate-create NAME=migration_name$(COLOR_RESET)"; \
		exit 1; \
	fi
	@echo "$(COLOR_BOLD)Creating migration: $(NAME)$(COLOR_RESET)"
	goose -dir packages/core/control-plane/db/migrations create $(NAME) sql

.PHONY: db-seed
db-seed: ## Populate database with seed data
	@echo "$(COLOR_BOLD)Seeding database...$(COLOR_RESET)"
	@for file in packages/core/control-plane/db/seeds/*.sql; do \
		echo "  Loading $$file..."; \
		psql "${DATABASE_URL}" -f $$file; \
	done

.PHONY: db-reset
db-reset: db-migrate-reset db-migrate db-seed ## Reset database and apply seeds
	@echo "$(COLOR_GREEN)Database reset complete!$(COLOR_RESET)"

.PHONY: sqlc-generate
sqlc-generate: ## Generate Go code from SQL queries
	@echo "$(COLOR_BOLD)Generating sqlc code...$(COLOR_RESET)"
	cd packages/core/control-plane && sqlc generate

.PHONY: sqlc-install
sqlc-install: ## Install sqlc CLI
	@echo "$(COLOR_BOLD)Installing sqlc...$(COLOR_RESET)"
	go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest

.PHONY: db-console
db-console: ## Open PostgreSQL console
	@echo "$(COLOR_BOLD)Opening database console...$(COLOR_RESET)"
	psql "${DATABASE_URL}"

.PHONY: db-dump
db-dump: ## Dump database to file
	@echo "$(COLOR_BOLD)Dumping database...$(COLOR_RESET)"
	pg_dump "${DATABASE_URL}" > backup-$(shell date +%Y%m%d-%H%M%S).sql

.PHONY: db-restore
db-restore: ## Restore database from file (usage: make db-restore FILE=backup.sql)
	@if [ -z "$(FILE)" ]; then \
		echo "$(COLOR_YELLOW)Usage: make db-restore FILE=backup.sql$(COLOR_RESET)"; \
		exit 1; \
	fi
	@echo "$(COLOR_BOLD)Restoring database from $(FILE)...$(COLOR_RESET)"
	psql "${DATABASE_URL}" < $(FILE)
```

### Development Workflow

**Daily Development**

```bash
# Start development environment (includes PostgreSQL)
make dev-up

# Run migrations
make db-migrate

# Seed data for testing
make db-seed

# Generate sqlc models after query changes
make sqlc-generate

# Run tests
make test-go
```

**Creating New Features**

```bash
# 1. Create migration
make db-migrate-create NAME=add_policies_table

# 2. Edit migration file
vim packages/core/control-plane/db/migrations/00005_add_policies_table.sql

# 3. Apply migration
make db-migrate

# 4. Add SQL queries
vim packages/core/control-plane/db/queries/policies.sql

# 5. Generate Go code
make sqlc-generate

# 6. Implement handlers using generated models
vim packages/core/control-plane/pkg/api/rest/handlers/policies.go
```

**Testing Migrations**

```bash
# Test up migration
make db-migrate

# Test down migration
make db-migrate-down

# Test full reset
make db-reset
```

### Production Considerations

**Connection Pooling**
- Max 25 connections (tune based on workload)
- Min 5 connections (warm pool)
- 1-hour max connection lifetime
- 30-minute idle timeout
- Health checks every minute

**Performance**
- Indexes on all foreign keys
- Indexes on frequently queried columns
- JSONB columns for flexible metadata
- Soft deletes (deleted_at) for audit trail
- Prepared statements disabled (sqlc recommendation for pgx)

**Security**
- All passwords hashed with bcrypt/pgcrypto
- API keys hashed before storage
- Row-level security for multi-tenancy (optional)
- SSL/TLS connections in production
- Least privilege database users

**Monitoring**
- Connection pool metrics (Prometheus)
- Query latency tracking
- Slow query logging
- Dead tuple monitoring
- Replication lag (if using replicas)

**Backup Strategy**
- Daily full backups (pg_dump)
- Continuous WAL archiving
- Point-in-time recovery enabled
- Backup retention: 30 days
- Regular restore testing

## Access Control & Routing Architecture

### Overview

Giru provides standard API gateway functionality for MCP tool access: client authentication, access control, rate limiting, and routing. This is table-stakes infrastructure, not a differentiator.

**What it does**: Manages which AI agents can call which MCP tools, with rate limits and audit logging.

**Client Experience**:
```
Before (Direct MCP):
- Client manages multiple MCP connections
- Client handles MCP-specific authentication
- Client needs to know MCP endpoints

After (Via Giru):
- Client connects once to Giru (single API key)
- Giru routes tools to correct MCP servers
- Giru enforces compliance policies (HIPAA/PCI-DSS)
- Client abstracted from MCP implementation details
```

### Core Entities

#### 1. Clients
Any entity that consumes MCP tools through Giru:
- AI Agents (ChatGPT, Claude Desktop, custom agents)
- Applications (web apps, mobile apps)
- Users (individual developers)

```sql
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    display_name VARCHAR(255),
    client_type VARCHAR(50) NOT NULL, -- 'agent', 'application', 'user'
    
    -- Authentication (client → gateway)
    api_key_hash VARCHAR(255) NOT NULL,
    
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    metadata JSONB DEFAULT '{}',
    
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    UNIQUE(tenant_id, name),
    INDEX idx_clients_tenant_type (tenant_id, client_type)
);
```

#### 2. MCP Servers
MCP servers registered in Giru that provide tools:

```sql
CREATE TABLE mcp_servers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    display_name VARCHAR(255),
    
    -- Connection details (gateway → MCP)
    endpoint_url VARCHAR(500) NOT NULL,
    transport VARCHAR(50) NOT NULL DEFAULT 'stdio', -- 'stdio', 'sse', 'http'
    
    -- Authentication (gateway authenticates TO the MCP)
    auth_type VARCHAR(50) NOT NULL, -- 'oauth', 'api_key', 'mtls'
    auth_config JSONB, -- { "token": "...", "client_id": "...", "resource": "..." }
    
    -- MCP protocol info
    protocol_version VARCHAR(50) DEFAULT '2024-11-05',
    server_capabilities JSONB, -- Result from MCP initialize
    
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    last_health_check TIMESTAMP,
    
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    UNIQUE(tenant_id, name),
    INDEX idx_mcp_servers_tenant (tenant_id)
);
```

#### 3. MCP Tools
Individual tools provided by MCP servers:

```sql
CREATE TABLE mcp_tools (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mcp_server_id UUID NOT NULL REFERENCES mcp_servers(id) ON DELETE CASCADE,
    
    -- Tool identity
    name VARCHAR(255) NOT NULL, -- e.g., "github__list_repos"
    display_name VARCHAR(255),
    description TEXT,
    
    -- MCP protocol schema
    input_schema JSONB NOT NULL, -- JSON Schema from MCP tools/list
    
    -- Metadata for routing and billing
    category VARCHAR(100), -- 'data', 'communication', 'computation'
    tags TEXT[],
    cost_tier VARCHAR(50), -- 'free', 'standard', 'premium' (for usage-based billing)
    
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    UNIQUE(mcp_server_id, name),
    INDEX idx_mcp_tools_name (name) -- Critical for fast tool → MCP resolution
);
```

#### 4. Access Grants (Subscriptions)
Access control table mapping Client → MCP Server:

```sql
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- The relationship
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    mcp_server_id UUID NOT NULL REFERENCES mcp_servers(id) ON DELETE CASCADE,
    environment_id UUID REFERENCES environments(id), -- 'dev', 'staging', 'prod'
    
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Scope: Which tools can be accessed
    scope_type VARCHAR(50) NOT NULL DEFAULT 'selective', -- 'all', 'selective'
    scope_tools TEXT[], -- Tool names: ['github__list_repos', 'github__create_issue']
    
    -- Rate limiting & quotas (enforced by Control Plane, NOT OPA)
    rate_limit_rps INTEGER, -- Requests per second
    quota_per_day INTEGER, -- Max requests per day
    quota_per_month INTEGER, -- Max requests per month
    
    -- Constraints (evaluated by OPA)
    constraints JSONB, -- { "max_file_size": 10485760, "filter_pii": true }
    
    -- Lifecycle management
    status VARCHAR(50) NOT NULL DEFAULT 'pending', -- 'pending', 'active', 'suspended', 'expired'
    requires_approval BOOLEAN DEFAULT false,
    approved_by UUID REFERENCES users(id), -- ENTERPRISE: Who approved
    approved_at TIMESTAMP,
    
    -- Temporal validity
    starts_at TIMESTAMP,
    expires_at TIMESTAMP,
    auto_renew BOOLEAN DEFAULT false, -- ENTERPRISE: Auto-renewal
    
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    UNIQUE(client_id, mcp_server_id, environment_id, name),
    INDEX idx_subscriptions_client (client_id),
    INDEX idx_subscriptions_mcp (mcp_server_id),
    INDEX idx_subscriptions_status_expires (status, expires_at)
);
```

#### 5. Environments (New Concept)
Control subscription behavior per environment:

```sql
CREATE TABLE environments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    
    name VARCHAR(50) NOT NULL, -- 'dev', 'staging', 'prod'
    display_name VARCHAR(255),
    
    -- Environment-specific policies
    config JSONB NOT NULL DEFAULT '{}', -- {
    --   "allow_auto_approval": true,
    --   "allow_auto_renewal": false,
    --   "require_mfa": true,
    --   "max_rate_limit_rps": 1000
    -- }
    
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    UNIQUE(tenant_id, name),
    INDEX idx_environments_tenant (tenant_id)
);

-- Default environments for new tenants
INSERT INTO environments (tenant_id, name, display_name, config) VALUES
  ('<tenant>', 'dev', 'Development', '{"allow_auto_approval": true, "allow_auto_renewal": true}'),
  ('<tenant>', 'staging', 'Staging', '{"allow_auto_approval": true, "allow_auto_renewal": false}'),
  ('<tenant>', 'prod', 'Production', '{"allow_auto_approval": false, "allow_auto_renewal": false, "require_mfa": true}');
```

### MCP JSON-RPC Protocol Integration

Giru implements the **Model Context Protocol (MCP)** as defined in the [MCP specification](https://github.com/modelcontextprotocol/specification). MCP uses **JSON-RPC 2.0** as its wire protocol.

#### Transport Support

| Transport | Status | Use Case |
|-----------|--------|----------|
| **STDIO** | ✅ Supported | Local MCP servers (process spawning) |
| **HTTP** | ✅ Supported | Remote MCP servers (recommended for production) |
| **SSE** | ⚠️ Legacy | Deprecated in MCP spec, not recommended |

#### Session Lifecycle

```
1. Client → Gateway: Initialize
   {
     "jsonrpc": "2.0",
     "id": 1,
     "method": "initialize",
     "params": {
       "protocolVersion": "2024-11-05",
       "capabilities": { "sampling": {}, "roots": { "listChanged": true } },
       "clientInfo": { "name": "sales-agent", "version": "1.0.0" }
     }
   }

2. Gateway → Client: Server capabilities
   {
     "jsonrpc": "2.0",
     "id": 1,
     "result": {
       "protocolVersion": "2024-11-05",
       "capabilities": { "tools": {}, "resources": {} },
       "serverInfo": { "name": "giru-gateway", "version": "1.0.0" }
     }
   }

3. Client → Gateway: Initialized notification
   { "jsonrpc": "2.0", "method": "initialized" }

4. Ready for tool calls
```

#### Tool Discovery & Execution

```
# List available tools (aggregated from ALL subscribed MCPs)
Client → Gateway:
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/list"
}

Gateway Response (merged from multiple MCP backends):
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
            "owner": { "type": "string", "description": "Repository owner" }
          },
          "required": ["owner"]
        }
      },
      {
        "name": "slack__send_message",
        "description": "Send Slack message",
        "inputSchema": { ... }
      }
    ]
  }
}

# Execute tool (gateway resolves via subscriptions)
Client → Gateway:
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "tools/call",
  "params": {
    "name": "github__list_repos",
    "arguments": {
      "owner": "anthropics"
    }
  }
}

Gateway Response:
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

### Request Flow with Subscriptions

```
┌─────────────┐          ┌─────────────┐          ┌─────────────┐
│   Client    │          │    Giru     │          │ MCP Server  │
│  (Agent)    │          │   Gateway   │          │  (GitHub)   │
└──────┬──────┘          └──────┬──────┘          └──────┬──────┘
       │                        │                        │
       │ 1. tools/call          │                        │
       │   "github__list_repos" │                        │
       ├───────────────────────>│                        │
       │                        │                        │
       │                   2. Authenticate               │
       │                      (validate client token)    │
       │                        │                        │
       │                   3. Resolve Subscription       │
       │                      (query DB: client → tool → MCP)
       │                        │                        │
       │                   4. Check Rate Limit           │
       │                      (Redis: requests/sec)      │
       │                        │                        │
       │                   5. Check Quota                │
       │                      (PostgreSQL: requests/day) │
       │                        │                        │
       │                   6. Evaluate OPA Policy        │
       │                      (stateless: params valid?) │
       │                        │                        │
       │                        │ 7. Route to MCP        │
       │                        ├───────────────────────>│
       │                        │   tools/call           │
       │                        │                        │
       │                        │ 8. MCP Response        │
       │                        │<───────────────────────┤
       │                        │                        │
       │                   9. Record Usage               │
       │                      (subscription_usage table) │
       │                        │                        │
       │ 10. Return Result      │                        │
       │<───────────────────────┤                        │
       │                        │                        │
```

#### Detailed Step-by-Step

**Step 1: Client Request**
```go
// Client sends JSON-RPC request
POST /mcp/v1/session
Authorization: Bearer <client_api_key>

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

**Step 2-3: Authentication & Subscription Resolution**
```go
// packages/core/control-plane/internal/handlers/mcp_jsonrpc.go
func (h *MCPHandler) HandleToolsCall(c *fiber.Ctx) error {
    // 2. Authenticate client
    clientID := c.Locals("client_id").(string) // From auth middleware
    
    // 3. Resolve subscription
    sub, err := h.db.ResolveToolSubscription(ctx, clientID, req.Params.Name)
    if err != nil {
        return jsonrpc.Error(-32001, "No subscription grants access to this tool")
    }
    
    // Continue to rate limiting...
}
```

**Step 4: Rate Limiting (Redis, NOT OPA)**
```go
// packages/core/control-plane/internal/ratelimit/redis.go
func (r *RedisRateLimiter) Check(subscriptionID string, limit int) bool {
    key := fmt.Sprintf("ratelimit:sub:%s", subscriptionID)
    
    // Sliding window rate limiting
    now := time.Now().Unix()
    r.redis.ZRemRangeByScore(ctx, key, "0", fmt.Sprintf("%d", now-1))
    
    count := r.redis.ZCard(ctx, key).Val()
    if count >= int64(limit) {
        return false // Rate limit exceeded
    }
    
    r.redis.ZAdd(ctx, key, &redis.Z{Score: float64(now), Member: uuid.New().String()})
    r.redis.Expire(ctx, key, 2*time.Second)
    return true
}
```

**Step 5: Quota Check (PostgreSQL, NOT OPA)**
```sql
-- db/queries/subscriptions.sql
-- name: CheckDailyQuota :one
SELECT 
    s.quota_per_day,
    COALESCE(COUNT(u.id), 0) as used_today
FROM subscriptions s
LEFT JOIN subscription_usage u ON u.subscription_id = s.id 
    AND DATE(u.timestamp) = CURRENT_DATE
WHERE s.id = $1
GROUP BY s.quota_per_day;
```

**Step 6: OPA Policy Evaluation (Stateless Only)**
```rego
# deployments/opa/policies/subscriptions.rego
package giru.subscriptions

default allow = false

# Allow if subscription is valid and constraints are met
allow {
    subscription_active
    temporal_valid
    parameter_constraints_met
}

subscription_active {
    input.subscription.status == "active"
}

temporal_valid {
    now := time.now_ns()
    input.subscription.starts_at <= now
    input.subscription.expires_at >= now
}

# Check parameter constraints (e.g., file size limits)
parameter_constraints_met {
    constraints := input.subscription.constraints
    args := input.arguments
    
    # File size constraint
    not constraints.max_file_size
    or args.file_size <= constraints.max_file_size
}

# PII filtering (if enabled in subscription)
parameter_constraints_met {
    constraints := input.subscription.constraints
    
    # If PII filtering is required
    constraints.filter_pii == true
    
    # Ensure request doesn't contain PII
    not contains_pii(input.arguments)
}

contains_pii(args) {
    # SSN pattern
    regex.match(`\d{3}-\d{2}-\d{4}`, args.text)
}

contains_pii(args) {
    # Credit card pattern
    regex.match(`\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}`, args.text)
}
```

**Key Principle: OPA vs State-Based Checks**

```
┌──────────────────────────────────────────────────────────────┐
│  OPA (Stateless Policy Engine)                               │
├──────────────────────────────────────────────────────────────┤
│  ✅ Authorization: Can client access tool?                   │
│  ✅ Parameter validation: Are arguments within constraints?  │
│  ✅ Compliance: Does request meet regulatory requirements?   │
│  ✅ Environment policies: Is this allowed in prod?           │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│  Control Plane + Redis/PostgreSQL (Stateful)                 │
├──────────────────────────────────────────────────────────────┤
│  ✅ Rate limiting: Requests per second (Redis)               │
│  ✅ Quotas: Daily/monthly usage (PostgreSQL)                 │
│  ✅ Usage tracking: Billing, analytics (PostgreSQL)          │
│  ✅ Session management: Active sessions (Redis)              │
└──────────────────────────────────────────────────────────────┘
```

**Step 7-8: Route to MCP Backend**
```go
// packages/core/control-plane/internal/mcp/client.go
func (c *MCPClient) CallTool(ctx context.Context, mcpServerID, toolName string, args map[string]interface{}) (*ToolResult, error) {
    // Get MCP server connection info
    server, err := c.db.GetMCPServer(ctx, mcpServerID)
    
    // Get or create connection to MCP backend
    conn, err := c.getOrCreateConnection(server)
    
    // Send JSON-RPC request to MCP backend
    req := &jsonrpc.Request{
        JSONRPC: "2.0",
        ID:      c.nextID(),
        Method:  "tools/call",
        Params: map[string]interface{}{
            "name":      toolName,
            "arguments": args,
        },
    }
    
    // Send request based on transport
    var resp *jsonrpc.Response
    switch server.Transport {
    case "stdio":
        resp, err = c.sendSTDIO(conn, req)
    case "http":
        resp, err = c.sendHTTP(server.EndpointURL, req, server.AuthConfig)
    }
    
    return resp.Result, nil
}
```

**Step 9: Record Usage**
```sql
-- db/queries/subscriptions.sql
-- name: RecordSubscriptionUsage :one
INSERT INTO subscription_usage (
    subscription_id,
    tool_name,
    request_id,
    duration_ms,
    status_code,
    tokens_used,
    timestamp
) VALUES (
    $1, $2, $3, $4, $5, $6, NOW()
) RETURNING id;
```

### Tool Name Collision Handling

When multiple MCPs provide the same tool name, clients can use **explicit routing**:

```json
// Option 1: Auto-resolve (first active subscription)
{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "params": {
    "name": "github__list_repos",
    "arguments": { "owner": "anthropics" }
  }
}

// Option 2: Explicit MCP selection
{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "params": {
    "name": "github__list_repos",
    "arguments": { "owner": "anthropics" },
    "_giru": {
      "prefer_mcp": "github-primary-mcp"
    }
  }
}
```

Implementation:
```go
func (h *MCPHandler) resolveToolToMCP(clientID, toolName string, hint *string) (*Subscription, error) {
    if hint != nil {
        // Explicit routing
        return h.db.ResolveToolSubscriptionWithMCP(clientID, toolName, *hint)
    }
    
    // Auto-resolve: first active subscription
    return h.db.ResolveToolSubscription(clientID, toolName)
}
```

### Subscription Management APIs

#### Create Subscription
```http
POST /api/v1/subscriptions
Authorization: Bearer <tenant_admin_token>

{
  "client_id": "client-abc-123",
  "mcp_server_id": "mcp-github-456",
  "environment_id": "env-prod-789",
  "name": "sales-agent-github-access",
  "scope_type": "selective",
  "scope_tools": ["github__list_repos", "github__create_issue"],
  "rate_limit_rps": 10,
  "quota_per_day": 1000,
  "constraints": {
    "max_file_size": 10485760,
    "filter_pii": true
  },
  "requires_approval": true,
  "expires_at": "2025-12-31T23:59:59Z"
}

Response 201:
{
  "id": "sub-xyz-789",
  "status": "pending_approval",
  "created_at": "2025-01-15T10:00:00Z"
}
```

#### List Client's Available Tools
```http
GET /api/v1/clients/{client_id}/tools
Authorization: Bearer <client_api_key>

Response 200:
{
  "tools": [
    {
      "name": "github__list_repos",
      "display_name": "List GitHub Repositories",
      "description": "Retrieve list of repositories for a user/org",
      "category": "data",
      "inputSchema": { ... },
      "provided_by": {
        "mcp_server_id": "mcp-github-456",
        "mcp_server_name": "github-integration",
        "subscription_id": "sub-xyz-789"
      },
      "quota": {
        "used_today": 234,
        "limit": 1000,
        "remaining": 766
      }
    }
  ]
}
```

### Usage Tracking & Analytics

```sql
-- Subscription usage table
CREATE TABLE subscription_usage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
    
    tool_name VARCHAR(255) NOT NULL,
    request_id UUID NOT NULL,
    
    -- Performance metrics
    duration_ms INTEGER,
    status_code INTEGER,
    tokens_used INTEGER,
    
    -- Billing (ENTERPRISE)
    computed_cost DECIMAL(10, 4),
    
    timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    
    INDEX idx_usage_subscription_day (subscription_id, DATE(timestamp)),
    INDEX idx_usage_timestamp (timestamp DESC)
);

-- Analytics view for billing/dashboards
CREATE VIEW subscription_usage_daily AS
SELECT 
    subscription_id,
    DATE(timestamp) as usage_date,
    COUNT(*) as total_requests,
    SUM(tokens_used) as total_tokens,
    SUM(computed_cost) as total_cost,
    AVG(duration_ms) as avg_duration_ms,
    COUNT(CASE WHEN status_code >= 400 THEN 1 END) as error_count
FROM subscription_usage
GROUP BY subscription_id, DATE(timestamp);
```

### Open Core vs Enterprise Features

#### Open Core (Community Edition)
- ✅ Client registration
- ✅ MCP server registration  
- ✅ Basic subscriptions (same-tenant only)
- ✅ Tool-level scoping (selective tools)
- ✅ Rate limiting & quotas
- ✅ Manual subscription creation
- ✅ Basic usage tracking
- ✅ Single environment (no environment separation)

#### Enterprise Edition
- 💰 **Cross-tenant subscriptions** (Client in Org A → MCP in Org B)
- 💰 **Approval workflows** (manager approval before subscription activation)
- 💰 **Environment-aware policies** (different rules for dev/staging/prod)
- 💰 **Auto-renewal** (subscriptions automatically extend before expiry)
- 💰 **Usage-based billing** (cost calculation, invoice generation)
- 💰 **Advanced analytics** (ROI analysis, optimization recommendations)
- 💰 **Subscription templates** (pre-configured bundles: "Sales Agent Bundle")
- 💰 **SLA tracking** (response time guarantees per subscription)
- 💰 **Audit trail** (who created/modified/approved subscriptions)

#### License Feature Flags
```go
// packages/enterprise/license/features.go
const (
    FeatureCrossTenantSubscriptions = "cross_tenant_subscriptions"
    FeatureApprovalWorkflows        = "approval_workflows"
    FeatureEnvironmentPolicies      = "environment_policies"
    FeatureAutoRenewal              = "auto_renewal"
    FeatureUsageBasedBilling        = "usage_based_billing"
    FeatureAdvancedAnalytics        = "advanced_analytics"
    FeatureSubscriptionTemplates    = "subscription_templates"
    FeatureSLATracking              = "sla_tracking"
)

// Example usage in code
if !license.HasFeature(FeatureAutoRenewal) {
    return errors.New("auto_renewal requires enterprise license")
}
```

### Migration Strategy

**Phase 1 (MVP - Week 4)**: Basic subscriptions
```sql
-- db/migrations/00005_add_subscriptions.sql
-- Add: clients, mcp_servers, mcp_tools, subscriptions tables
-- No environments, no approval workflows
```

**Phase 2 (Week 8)**: Environments & usage tracking
```sql
-- db/migrations/00006_add_environments.sql
-- Add: environments, subscription_usage tables
-- Add: environment_id FK to subscriptions
```

**Phase 3 (Enterprise - Week 12)**: Approval workflows & analytics
```sql
-- db/migrations/00007_add_approval_workflows.sql  -- ENTERPRISE ONLY
-- Add: subscription_events, approval_history tables
-- Add: auto_renew, requires_approval columns
```

### Database Functions for Subscription Resolution

```sql
-- Critical function: Resolve which subscription allows tool access
CREATE OR REPLACE FUNCTION resolve_tool_subscription(
    p_client_id UUID,
    p_tool_name VARCHAR,
    p_prefer_mcp_name VARCHAR DEFAULT NULL
) RETURNS TABLE (
    subscription_id UUID,
    mcp_server_id UUID,
    mcp_endpoint VARCHAR,
    mcp_auth_config JSONB,
    rate_limit_rps INTEGER,
    quota_per_day INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id AS subscription_id,
        s.mcp_server_id,
        m.endpoint_url AS mcp_endpoint,
        m.auth_config AS mcp_auth_config,
        s.rate_limit_rps,
        s.quota_per_day
    FROM subscriptions s
    JOIN mcp_servers m ON s.mcp_server_id = m.id
    JOIN mcp_tools t ON t.mcp_server_id = m.id
    WHERE s.client_id = p_client_id
      AND t.name = p_tool_name
      AND s.status = 'active'
      AND m.status = 'active'
      AND (s.starts_at IS NULL OR s.starts_at <= NOW())
      AND (s.expires_at IS NULL OR s.expires_at > NOW())
      AND (
          -- Full access to all tools
          s.scope_type = 'all'
          -- Or tool is explicitly in scope
          OR (s.scope_type = 'selective' AND p_tool_name = ANY(s.scope_tools))
      )
      -- Prefer specific MCP if hint provided
      AND (p_prefer_mcp_name IS NULL OR m.name = p_prefer_mcp_name)
    ORDER BY 
        -- Prefer explicit MCP hints
        CASE WHEN m.name = p_prefer_mcp_name THEN 0 ELSE 1 END,
        -- Then by subscription priority (could add priority column)
        s.created_at DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
```

### Key Architecture Decisions

**1. Why Rate Limiting Outside OPA?**
- OPA is stateless and optimized for policy evaluation
- Rate limiting needs state (counters, sliding windows)
- Redis provides microsecond latency for counters
- Separation of concerns: OPA = policy, Control Plane = state

**2. Why JSON-RPC for MCP?**
- MCP specification mandates JSON-RPC 2.0
- Standardized error codes and message format
- Supports notifications (server → client events)
- Battle-tested protocol (used by LSP, many RPC systems)

## Success Metrics

### Technical Metrics
- **Performance**: 100K+ RPS, P99 < 5ms
- **Reliability**: 99.99% uptime
- **Test Coverage**: 80%+ code, 100% policies
- **Security**: Zero critical CVEs

### Business Metrics
- **Community Adoption**: GitHub stars, Docker pulls, community forum engagement
- **Enterprise Customers**: Fortune 500 adoptions (financial, healthcare, e-commerce, government)
- **Time to Value**: < 15 minutes from clone to running gateway
- **Support Satisfaction**: > 90% CSAT for enterprise customers
- **Revenue Growth**: YoY ARR growth, logo retention, expansion revenue

### Go-to-Market Metrics (Enterprise)
- **Customer Acquisition Cost (CAC)**: < $30k per enterprise customer
- **Lifetime Value (LTV)**: > $300k (10:1 LTV:CAC ratio)
- **Sales Cycle**: < 90 days for mid-market, < 180 days for enterprise
- **Net Revenue Retention**: > 120% (expansion through seat growth, SaaS upgrade)

### Developer Metrics
- **Build Time**: < 5 minutes
- **Deploy Time**: < 10 minutes
- **PR Review Time**: < 24 hours
- **Issue Resolution**: < 7 days average

## Development Environment Configurations

### Docker Compose Configuration

```yaml
# deployments/docker-compose/docker-compose.dev.yml
version: '3.8'

services:
  envoy:
    image: envoyproxy/envoy:v1.28
    ports:
      - "8080:8080"   # Gateway
      - "9901:9901"   # Admin UI
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
    command:
      - "run"
      - "--server"
      - "--addr=0.0.0.0:8181"
      - "--set=decision_logs.console=true"
      - "/policies"
    volumes:
      - ../../packages/core/opa/policies:/policies:ro
      - ../../packages/enterprise/opa-policies:/enterprise-policies:ro
    networks:
      - giru

  control-plane:
    build:
      context: ../../
      dockerfile: build/docker/Dockerfile.control-plane.dev
    ports:
      - "18000:18000"  # API
      - "19000:19000"  # gRPC (xDS)
    environment:
      - DATABASE_URL=postgresql://postgres:password@postgres:5432/giru
      - REDIS_URL=redis://redis:6379
      - OPA_URL=http://opa:8181
      - ENVOY_XDS_PORT=19000
      - LOG_LEVEL=debug
    volumes:
      # Mount source for hot reload with air
      - ../../packages/core/control-plane:/app:ro
      - control-plane-build:/app/tmp  # air working directory
    depends_on:
      - postgres
      - redis
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
      - ./init-db.sql:/docker-entrypoint-initdb.d/init.sql:ro
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
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus-data:/prometheus
    networks:
      - giru

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    volumes:
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards:ro
      - ./grafana/datasources:/etc/grafana/provisioning/datasources:ro
      - grafana-data:/var/lib/grafana
    depends_on:
      - prometheus
    networks:
      - giru

volumes:
  postgres-data:
  redis-data:
  prometheus-data:
  grafana-data:
  control-plane-build:

networks:
  giru:
    driver: bridge
```

### kind Configuration

```yaml
# deployments/kind/kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: giru-dev
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      # Gateway
      - containerPort: 30080
        hostPort: 8080
        protocol: TCP
      # Grafana
      - containerPort: 30300
        hostPort: 3000
        protocol: TCP
  # Optional: Add worker nodes for testing multi-node scenarios
  - role: worker
  - role: worker
```

### Skaffold Configuration

```yaml
# deployments/kind/skaffold.yaml
apiVersion: skaffold/v4beta6
kind: Config
metadata:
  name: giru-gateway

build:
  artifacts:
    # Control Plane (Go) - use ko for fast builds
    - image: giru/control-plane
      ko:
        dependencies:
          paths:
            - packages/core/control-plane/**/*.go
            - packages/enterprise/control-plane/**/*.go
        labels:
          app: giru-control-plane
        env:
          - CGO_ENABLED=0

    # Envoy (use existing image, just tag)
    - image: giru/envoy
      docker:
        dockerfile: build/docker/Dockerfile.envoy
        cacheFrom:
          - giru/envoy:latest

    # OPA (use existing image with custom policies)
    - image: giru/opa
      docker:
        dockerfile: build/docker/Dockerfile.opa

    # Svelte UI (enterprise)
    - image: giru/web-ui
      docker:
        dockerfile: build/docker/Dockerfile.web-ui

  local:
    push: false        # Don't push to registry
    useBuildkit: true  # Faster Docker builds
    concurrency: 4     # Build 4 images in parallel

deploy:
  kubectl:
    defaultNamespace: giru-dev
    manifests:
      - deployments/kubernetes/namespaces/dev.yaml
      - deployments/kubernetes/base/*.yaml
    hooks:
      before:
        - host:
            command: ["sh", "-c", "kubectl create namespace giru-dev --dry-run=client -o yaml | kubectl apply -f -"]
      after:
        - host:
            command: ["kubectl", "wait", "--for=condition=ready", "pod", "-l", "app=giru-control-plane", "--timeout=60s", "-n", "giru-dev"]

portForward:
  - resourceType: service
    resourceName: giru-gateway
    namespace: giru-dev
    port: 8080
    localPort: 8080

  - resourceType: service
    resourceName: grafana
    namespace: giru-dev
    port: 3000
    localPort: 3000

# File sync for fast iteration
sync:
  manual:
    - src: "packages/enterprise/web-ui/build/**/*"
      dest: /app/ui
      strip: "packages/enterprise/web-ui/build/"

# Logs
logs:
  prefix: auto

# Development profiles
profiles:
  # Minimal profile (just control plane + essential services)
  - name: minimal
    activation:
      - command: dev
        env: Giru_PROFILE=minimal
    patches:
      - op: remove
        path: /build/artifacts/3  # Remove Svelte UI

  # Full profile (all services)
  - name: full
    activation:
      - command: dev
        env: Giru_PROFILE=full
    # No patches, use all artifacts
```

## Svelte + Go Integration Pattern

**Architecture: Static Frontend + Go Backend**

```
┌─────────────────────────────────────┐
│   Development (Separate Servers)   │
├─────────────────────────────────────┤
│  Svelte Dev Server  │  Go API      │
│  (Vite: 5173)       │  (Fiber:8080)│
│  - HMR              │  - REST API  │
│  - Proxy to :8080   │  - WebSocket │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│    Production (Single Binary)      │
├─────────────────────────────────────┤
│         Go Binary (Fiber)           │
│  ┌───────────────────────────────┐  │
│  │  Static Assets (embedded)     │  │
│  │  - Svelte build output        │  │
│  │  - index.html, JS, CSS        │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │  API Routes                   │  │
│  │  - /api/*                     │  │
│  │  - WebSocket /ws              │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

**Build Process:**

```bash
# 1. Build Svelte to static files
cd packages/enterprise/web-ui
npm run build
# Output: build/ directory with:
#   - index.html
#   - _app/immutable/*.js (hashed)
#   - _app/immutable/*.css

# 2. Embed in Go binary (using embed)
# packages/enterprise/control-plane/pkg/ui/embed.go
package ui

import "embed"

//go:embed all:dist
var Assets embed.FS

# 3. Serve from Go
// main.go
app.Get("/", func(c *fiber.Ctx) error {
    return c.SendFile("./ui/dist/index.html")
})
app.Static("/_app", "./ui/dist/_app")
app.Get("/api/*", apiHandler)
```

**Development Workflow:**

```bash
# Terminal 1: Run Go backend
cd packages/core/control-plane
make run-dev  # Runs with air (hot reload)

# Terminal 2: Run Svelte frontend
cd packages/enterprise/web-ui
npm run dev   # Vite dev server on :5173

# svelte.config.js proxies API calls to :8080
```

**Production Deployment:**

```bash
# Single command builds everything
make build-enterprise

# Results in:
# 1. bin/giru-control-plane (Go binary with embedded UI)
# 2. All static assets embedded in binary
# 3. Single Docker image with everything
```

**SvelteKit Configuration for Go Backend:**

```javascript
// packages/enterprise/web-ui/svelte.config.js
import adapter from '@sveltejs/adapter-static';

export default {
  kit: {
    adapter: adapter({
      pages: 'build',
      assets: 'build',
      fallback: 'index.html',  // SPA mode
      precompress: false,
      strict: true
    }),
    // Proxy API calls in development
    vite: {
      server: {
        proxy: {
          '/api': {
            target: 'http://localhost:8080',
            changeOrigin: true
          },
          '/ws': {
            target: 'ws://localhost:8080',
            ws: true
          }
        }
      }
    }
  }
};
```

**API Client (Svelte):**

```typescript
// packages/enterprise/web-ui/src/lib/api/client.ts
export class GiruAPI {
  private baseUrl = import.meta.env.PROD ? '' : 'http://localhost:8080';

  async listServers(): Promise<Server[]> {
    const response = await fetch(`${this.baseUrl}/api/v1/servers`, {
      headers: {
        'Authorization': `Bearer ${this.getToken()}`
      }
    });
    if (!response.ok) throw new Error('Failed to fetch servers');
    return response.json();
  }

  createWebSocket(path: string): WebSocket {
    const wsUrl = this.baseUrl.replace('http', 'ws');
    return new WebSocket(`${wsUrl}${path}`);
  }

  private getToken(): string {
    return localStorage.getItem('giru_token') || '';
  }
}

export const api = new GiruAPI();
```

**Real-time Updates Example:**

```svelte
<!-- packages/enterprise/web-ui/src/routes/dashboard/+page.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import { api } from '$lib/api/client';
  
  let metrics = $state({ requests: 0, errors: 0, latency: 0 });
  let ws: WebSocket;

  onMount(() => {
    // Establish WebSocket connection for real-time metrics
    ws = api.createWebSocket('/api/v1/metrics/stream');
    
    ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      metrics = data;
    };

    return () => ws?.close();
  });
</script>

<div class="stats shadow">
  <div class="stat">
    <div class="stat-title">Requests</div>
    <div class="stat-value">{metrics.requests.toLocaleString()}</div>
  </div>
  <div class="stat">
    <div class="stat-title">Errors</div>
    <div class="stat-value text-error">{metrics.errors}</div>
  </div>
  <div class="stat">
    <div class="stat-title">Latency (P99)</div>
    <div class="stat-value">{metrics.latency}ms</div>
  </div>
</div>
```

**Go Backend WebSocket Handler:**

```go
// packages/enterprise/control-plane/pkg/api/rest/handlers/metrics.go
package handlers

import (
    "github.com/gofiber/fiber/v2"
    "github.com/gofiber/websocket/v2"
)

func StreamMetrics(c *websocket.Conn) {
    ticker := time.NewTicker(1 * time.Second)
    defer ticker.Stop()

    for {
        select {
        case <-ticker.C:
            metrics := getLatestMetrics()
            if err := c.WriteJSON(metrics); err != nil {
                return
            }
        }
    }
}
```

## Makefile Best Practices and Template

**Root Makefile Template** (`/Makefile`)

```makefile
# vim: set noexpandtab:
# -*- mode: makefile -*-
# Giru Gateway - Root Makefile

.DEFAULT_GOAL := help
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# Variables
VERSION ?= $(shell git describe --tags --always --dirty)
COMMIT := $(shell git rev-parse --short HEAD)
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
LDFLAGS := -ldflags "-X main.Version=$(VERSION) -X main.Commit=$(COMMIT) -X main.BuildDate=$(BUILD_DATE)"

# Binary names
CONTROL_PLANE_BIN := bin/giru-control-plane
CLI_BIN := bin/giru

# Directories
BUILD_DIR := build
BIN_DIR := bin
DIST_DIR := dist

# Go settings
GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)
CGO_ENABLED ?= 0

# Docker settings
DOCKER_REGISTRY ?= docker.io
DOCKER_ORG ?= giru
DOCKER_TAG ?= $(VERSION)

# Colors for output
COLOR_RESET := \033[0m
COLOR_BOLD := \033[1m
COLOR_GREEN := \033[32m
COLOR_YELLOW := \033[33m

.PHONY: help
help: ## Show this help message
	@echo '$(COLOR_BOLD)Giru Gateway - Build System$(COLOR_RESET)'
	@echo ''
	@echo '$(COLOR_BOLD)Usage:$(COLOR_RESET)'
	@echo '  make [target]'
	@echo ''
	@echo '$(COLOR_BOLD)Available targets:$(COLOR_RESET)'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(COLOR_GREEN)%-20s$(COLOR_RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: all
all: test build ## Run tests and build all binaries

.PHONY: deps
deps: ## Install dependencies
	@echo "$(COLOR_BOLD)Installing Go dependencies...$(COLOR_RESET)"
	go mod download
	go mod verify
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	go install github.com/cosmtrek/air@latest

.PHONY: deps-dev
deps-dev: deps ## Install all development dependencies
	@echo "$(COLOR_BOLD)Installing development tools...$(COLOR_RESET)"
	# kind
	@which kind > /dev/null || (echo "Installing kind..." && \
		go install sigs.k8s.io/kind@latest)
	# skaffold
	@which skaffold > /dev/null || (echo "Installing skaffold..." && \
		curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-$(shell uname -s | tr '[:upper:]' '[:lower:]')-$(shell uname -m | sed 's/x86_64/amd64/') && \
		chmod +x skaffold && sudo mv skaffold /usr/local/bin)
	# ko (optional)
	@which ko > /dev/null || (echo "Installing ko..." && \
		go install github.com/google/ko@latest)
	# kubectl (if not present)
	@which kubectl > /dev/null || (echo "kubectl not found. Please install from https://kubernetes.io/docs/tasks/tools/")
	@echo "$(COLOR_GREEN)All development tools installed!$(COLOR_RESET)"

.PHONY: build
build: build-control-plane build-cli ## Build all binaries

.PHONY: build-control-plane
build-control-plane: ## Build control plane binary
	@echo "$(COLOR_BOLD)Building control plane...$(COLOR_RESET)"
	@mkdir -p $(BIN_DIR)
	CGO_ENABLED=$(CGO_ENABLED) GOOS=$(GOOS) GOARCH=$(GOARCH) go build \
		$(LDFLAGS) \
		-o $(CONTROL_PLANE_BIN) \
		./packages/core/control-plane/cmd/server

.PHONY: build-cli
build-cli: ## Build CLI binary
	@echo "$(COLOR_BOLD)Building CLI...$(COLOR_RESET)"
	@mkdir -p $(BIN_DIR)
	CGO_ENABLED=$(CGO_ENABLED) GOOS=$(GOOS) GOARCH=$(GOARCH) go build \
		$(LDFLAGS) \
		-o $(CLI_BIN) \
		./packages/core/cli/cmd

.PHONY: build-community
build-community: ## Build community edition
	@echo "$(COLOR_BOLD)Building community edition...$(COLOR_RESET)"
	BUILD_EDITION=community $(MAKE) build
	$(MAKE) docker-build-community

.PHONY: build-enterprise
build-enterprise: build-ui ## Build enterprise edition (requires license key)
	@echo "$(COLOR_BOLD)Building enterprise edition...$(COLOR_RESET)"
	BUILD_EDITION=enterprise $(MAKE) build
	$(MAKE) docker-build-enterprise

.PHONY: build-ui
build-ui: ## Build Svelte UI (enterprise)
	@echo "$(COLOR_BOLD)Building Svelte UI...$(COLOR_RESET)"
	cd packages/enterprise/web-ui && npm install && npm run build

.PHONY: test
test: test-go test-ui ## Run all tests

.PHONY: test-go
test-go: ## Run Go tests
	@echo "$(COLOR_BOLD)Running Go tests...$(COLOR_RESET)"
	go test -v -race -coverprofile=coverage.out -covermode=atomic ./...

.PHONY: test-ui
test-ui: ## Run Svelte UI tests (enterprise)
	@echo "$(COLOR_BOLD)Running Svelte tests...$(COLOR_RESET)"
	@if [ -d packages/enterprise/web-ui ]; then \
		cd packages/enterprise/web-ui && npm test; \
	fi

.PHONY: test-coverage
test-coverage: test ## Run tests with coverage report
	@echo "$(COLOR_BOLD)Generating coverage report...$(COLOR_RESET)"
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report: coverage.html"

.PHONY: test-policies
test-policies: ## Run OPA policy tests
	@echo "$(COLOR_BOLD)Testing OPA policies...$(COLOR_RESET)"
	opa test packages/core/opa/policies -v
	@if [ -d packages/enterprise/opa-policies ]; then \
		opa test packages/enterprise/opa-policies -v; \
	fi

.PHONY: test-integration
test-integration: ## Run integration tests
	@echo "$(COLOR_BOLD)Running integration tests...$(COLOR_RESET)"
	go test -v -tags=integration ./tests/integration/...

.PHONY: test-e2e
test-e2e: ## Run end-to-end tests
	@echo "$(COLOR_BOLD)Running E2E tests...$(COLOR_RESET)"
	./scripts/test/smoke-tests.sh

.PHONY: lint
lint: lint-go lint-ui ## Run all linters

.PHONY: lint-go
lint-go: ## Run Go linters
	@echo "$(COLOR_BOLD)Running Go linters...$(COLOR_RESET)"
	golangci-lint run --timeout 5m ./...

.PHONY: lint-ui
lint-ui: ## Run Svelte/TypeScript linters
	@echo "$(COLOR_BOLD)Running Svelte linters...$(COLOR_RESET)"
	@if [ -d packages/enterprise/web-ui ]; then \
		cd packages/enterprise/web-ui && npm run lint && npm run check; \
	fi

.PHONY: fmt
fmt: ## Format code
	@echo "$(COLOR_BOLD)Formatting code...$(COLOR_RESET)"
	go fmt ./...
	gofmt -s -w .

.PHONY: vet
vet: ## Run go vet
	@echo "$(COLOR_BOLD)Running go vet...$(COLOR_RESET)"
	go vet ./...

.PHONY: clean
clean: ## Clean build artifacts
	@echo "$(COLOR_BOLD)Cleaning...$(COLOR_RESET)"
	rm -rf $(BIN_DIR) $(BUILD_DIR) $(DIST_DIR)
	rm -f coverage.out coverage.html
	@if [ -d packages/enterprise/web-ui ]; then \
		cd packages/enterprise/web-ui && rm -rf build node_modules .svelte-kit; \
	fi

.PHONY: docker-build
docker-build: docker-build-envoy docker-build-opa docker-build-control-plane ## Build all Docker images

.PHONY: docker-build-envoy
docker-build-envoy: ## Build Envoy Docker image
	@echo "$(COLOR_BOLD)Building Envoy Docker image...$(COLOR_RESET)"
	docker build -f build/docker/Dockerfile.envoy -t $(DOCKER_ORG)/envoy:$(DOCKER_TAG) .

.PHONY: docker-build-opa
docker-build-opa: ## Build OPA Docker image
	@echo "$(COLOR_BOLD)Building OPA Docker image...$(COLOR_RESET)"
	docker build -f build/docker/Dockerfile.opa -t $(DOCKER_ORG)/opa:$(DOCKER_TAG) .

.PHONY: docker-build-control-plane
docker-build-control-plane: ## Build control plane Docker image
	@echo "$(COLOR_BOLD)Building control plane Docker image...$(COLOR_RESET)"
	docker build -f build/docker/Dockerfile.control-plane -t $(DOCKER_ORG)/control-plane:$(DOCKER_TAG) .

.PHONY: docker-build-community
docker-build-community: ## Build community edition Docker image
	@echo "$(COLOR_BOLD)Building community edition...$(COLOR_RESET)"
	docker build -t $(DOCKER_ORG)/gateway:$(DOCKER_TAG)-community .

.PHONY: docker-build-enterprise
docker-build-enterprise: ## Build enterprise edition Docker image
	@echo "$(COLOR_BOLD)Building enterprise edition...$(COLOR_RESET)"
	docker build -t $(DOCKER_ORG)/gateway:$(DOCKER_TAG)-enterprise -f build/docker/Dockerfile.enterprise .

.PHONY: docker-push
docker-push: ## Push Docker images to registry
	@echo "$(COLOR_BOLD)Pushing Docker images...$(COLOR_RESET)"
	docker push $(DOCKER_ORG)/gateway:$(DOCKER_TAG)-community
	docker push $(DOCKER_ORG)/gateway:$(DOCKER_TAG)-enterprise

.PHONY: dev-setup
dev-setup: deps ## Setup development environment
	@echo "$(COLOR_BOLD)Setting up development environment...$(COLOR_RESET)"
	./scripts/setup/install-dev.sh
	$(MAKE) dev-up

.PHONY: dev-up
dev-up: ## Start local development environment (Docker Compose)
	@echo "$(COLOR_BOLD)Starting development environment...$(COLOR_RESET)"
	docker-compose -f deployments/docker-compose/docker-compose.dev.yml up -d

.PHONY: dev-ui
dev-ui: ## Start Svelte UI dev server (enterprise)
	@echo "$(COLOR_BOLD)Starting Svelte dev server...$(COLOR_RESET)"
	cd packages/enterprise/web-ui && npm run dev

.PHONY: dev-down
dev-down: ## Stop local development environment
	@echo "$(COLOR_BOLD)Stopping development environment...$(COLOR_RESET)"
	docker-compose -f deployments/docker-compose/docker-compose.dev.yml down

# Kubernetes Development (kind + Skaffold)
.PHONY: kind-create
kind-create: ## Create kind cluster for local K8s development
	@echo "$(COLOR_BOLD)Creating kind cluster...$(COLOR_RESET)"
	kind create cluster --config deployments/kind/kind-config.yaml
	kubectl cluster-info --context kind-giru-dev

.PHONY: kind-delete
kind-delete: ## Delete kind cluster
	@echo "$(COLOR_BOLD)Deleting kind cluster...$(COLOR_RESET)"
	kind delete cluster --name giru-dev

.PHONY: kind-status
kind-status: ## Show kind cluster status
	@echo "$(COLOR_BOLD)Kind cluster status:$(COLOR_RESET)"
	@kind get clusters
	@kubectl get nodes

.PHONY: skaffold-dev
skaffold-dev: ## Run Skaffold in dev mode (hot reload in K8s)
	@echo "$(COLOR_BOLD)Starting Skaffold development...$(COLOR_RESET)"
	cd deployments/kind && skaffold dev

.PHONY: skaffold-run
skaffold-run: ## Deploy to kind cluster (one-time)
	@echo "$(COLOR_BOLD)Deploying to kind cluster...$(COLOR_RESET)"
	cd deployments/kind && skaffold run

.PHONY: skaffold-delete
skaffold-delete: ## Delete Skaffold deployments
	@echo "$(COLOR_BOLD)Deleting Skaffold deployments...$(COLOR_RESET)"
	cd deployments/kind && skaffold delete

# ko builds (Go container optimization)
.PHONY: ko-build
ko-build: ## Build Go binaries with ko
	@echo "$(COLOR_BOLD)Building with ko...$(COLOR_RESET)"
	ko build --local --platform=linux/amd64,linux/arm64 ./packages/core/control-plane/cmd/server

.PHONY: ko-apply
ko-apply: ## Build and deploy with ko to current K8s context
	@echo "$(COLOR_BOLD)Building and deploying with ko...$(COLOR_RESET)"
	ko apply -f deployments/kubernetes/base/

.PHONY: dev-logs
dev-logs: ## Show logs from development environment
	docker-compose -f deployments/docker-compose/docker-compose.dev.yml logs -f

.PHONY: run
run: build-control-plane ## Run control plane locally
	@echo "$(COLOR_BOLD)Running control plane...$(COLOR_RESET)"
	$(CONTROL_PLANE_BIN)

.PHONY: run-dev
run-dev: ## Run control plane with hot reload (air)
	@echo "$(COLOR_BOLD)Running with hot reload...$(COLOR_RESET)"
	cd packages/core/control-plane && air

.PHONY: deploy-k8s
deploy-k8s: ## Deploy to Kubernetes
	@echo "$(COLOR_BOLD)Deploying to Kubernetes...$(COLOR_RESET)"
	kubectl apply -k deployments/kubernetes/overlays/dev

.PHONY: deploy-staging
deploy-staging: ## Deploy to staging environment
	@echo "$(COLOR_BOLD)Deploying to staging...$(COLOR_RESET)"
	kubectl apply -k deployments/kubernetes/overlays/staging

.PHONY: deploy-production
deploy-production: ## Deploy to production environment
	@echo "$(COLOR_BOLD)Deploying to production...$(COLOR_RESET)"
	kubectl apply -k deployments/kubernetes/overlays/production

.PHONY: validate-manifests
validate-manifests: ## Validate Kubernetes manifests
	@echo "$(COLOR_BOLD)Validating manifests...$(COLOR_RESET)"
	kubectl apply --dry-run=client -k deployments/kubernetes/base

.PHONY: validate-policies
validate-policies: ## Validate OPA policies
	@echo "$(COLOR_BOLD)Validating OPA policies...$(COLOR_RESET)"
	opa check packages/core/opa/policies
	@if [ -d packages/enterprise/opa-policies ]; then \
		opa check packages/enterprise/opa-policies; \
	fi

.PHONY: security-scan
security-scan: ## Run security scans
	@echo "$(COLOR_BOLD)Running security scans...$(COLOR_RESET)"
	go list -json -m all | docker run -i sonatypecommunity/nancy:latest sleuth
	trivy fs --severity HIGH,CRITICAL .

.PHONY: benchmark
benchmark: ## Run benchmarks
	@echo "$(COLOR_BOLD)Running benchmarks...$(COLOR_RESET)"
	go test -bench=. -benchmem ./...

.PHONY: ci
ci: lint test test-policies validate-manifests validate-policies ## Run all CI checks

.PHONY: release
release: ## Create a new release
	@echo "$(COLOR_BOLD)Creating release $(VERSION)...$(COLOR_RESET)"
	./build/release.sh $(VERSION)

.PHONY: version
version: ## Show version information
	@echo "Version:    $(VERSION)"
	@echo "Commit:     $(COMMIT)"
	@echo "Build Date: $(BUILD_DATE)"
	@echo "Go Version: $(shell go version)"

.PHONY: dev-info
dev-info: ## Show development environment info
	@echo "$(COLOR_BOLD)Giru Development Environment$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_BOLD)Available Environments:$(COLOR_RESET)"
	@echo "  1. Docker Compose (Tier 1 - Daily Development)"
	@echo "     Commands: make dev-up, make dev-ui, make dev-logs, make dev-down"
	@echo ""
	@echo "  2. kind + Skaffold (Tier 2 - K8s Testing)"
	@echo "     Commands: make kind-create, make skaffold-dev, make kind-delete"
	@echo ""
	@echo "$(COLOR_BOLD)Build Options:$(COLOR_RESET)"
	@echo "  - Docker:    make build (standard)"
	@echo "  - ko:        make ko-build (Go optimization)"
	@echo ""
	@echo "$(COLOR_BOLD)Installed Tools:$(COLOR_RESET)"
	@which docker > /dev/null && echo "  ✅ Docker" || echo "  ❌ Docker (required)"
	@which kind > /dev/null && echo "  ✅ kind" || echo "  ⚠️  kind (optional, install: make deps-dev)"
	@which skaffold > /dev/null && echo "  ✅ Skaffold" || echo "  ⚠️  Skaffold (optional, install: make deps-dev)"
	@which ko > /dev/null && echo "  ✅ ko" || echo "  ⚠️  ko (optional, install: make deps-dev)"
	@which kubectl > /dev/null && echo "  ✅ kubectl" || echo "  ⚠️  kubectl (required for K8s dev)"
```

**Key Makefile Features:**

1. **Self-Documenting Help**: `make help` shows all available targets with descriptions
2. **Colored Output**: Visual feedback for better UX
3. **Version Management**: Git-based versioning automatically embedded in binaries
4. **Parallel Support**: Use `make -j8` for concurrent builds
5. **Cross-Platform**: Works on Linux, macOS, and WSL
6. **Safety Flags**: Fail fast with `-eu -o pipefail`
7. **Tab Safety**: Header comments for vim/emacs configuration
8. **CI Integration**: Single `make ci` runs all checks

## Final Notes for Claude Code

**Approach**
- Start with core infrastructure (Envoy, OPA, basic control plane)
- Get local development working first (Docker Compose)
- Add features iteratively
- Test thoroughly at each step
- Document as you build

**Code Quality**
- Follow Go standards (gofmt, golangci-lint)
- TypeScript strict mode (Svelte UI)
- Svelte best practices (proper reactivity, component composition)
- Comprehensive error handling
- Structured logging everywhere
- Security-first mindset
- OpenAPI spec auto-generated from code annotations

**Configuration Over Code**
- Make everything configurable
- Sensible defaults
- Environment-specific overrides
- Validation at load time

**Future-Proofing**
- gRPC for all internal APIs (protocol buffers)
- OpenTelemetry for observability
- Kubernetes CRDs for native integration
- Plugin architecture for extensibility

This scaffold represents a production-grade, enterprise-ready MCP gateway that can compete with any commercial offering while maintaining an open-source core for community adoption and trust.
