# Giru Gateway - Technology Stack

> **Last Updated**: 2025-11-11  
> **Status**: Ready for MVP Implementation

## Overview

Giru is an infrastructure-grade MCP gateway built for Fortune 500 enterprises. Think "Kubernetes for MCP" - we provide the production infrastructure layer for Model Context Protocol servers.

---

## Core Architecture (3 Layers)

### Layer 1: Envoy Proxy (Performance Foundation)
- **Technology**: Envoy v1.28+ (C++)
- **Why**: 
  - 100K+ requests/sec capability
  - Battle-tested (Netflix, Lyft, AWS)
  - Dynamic xDS configuration (zero-downtime updates)
  - Native service mesh integration
- **Configuration**: Dynamic (xDS protocol), not static files

### Layer 2: OPA Policy Engine (Governance Brain)
- **Technology**: Open Policy Agent (CNCF Graduated)
- **Why**:
  - Declarative Rego policies (readable by compliance teams)
  - Testable policies with unit tests
  - GitOps native (version controlled)
  - Used by Goldman Sachs, Netflix
- **Integration**: Envoy External Authorization filter

### Layer 3: Control Plane (Orchestration)
- **Technology**: Go 1.21+ with Fiber v2
- **Why**:
  - **Go**: Compiled, concurrent, single binary deployment
  - **Fiber**: 6M req/sec (2.4x faster than Gin, 3.3x faster than stdlib)
  - Infrastructure-grade performance requirements
- **Protocols**: 
  - REST API (Fiber)
  - gRPC (xDS protocol)
- **Database**: PostgreSQL 15+ (configuration)
- **Cache**: Redis 7+ (performance)

---

## Enterprise Web UI (Proprietary)

### Frontend Stack
- **Framework**: Svelte 5 + SvelteKit 2
- **Language**: TypeScript (strict mode)
- **Styling**: Tailwind CSS + DaisyUI
- **Charts**: Chart.js or Apache ECharts
- **Testing**: Vitest + Testing Library
- **Build Tool**: Vite

### Why Svelte Over Next.js/React?

| Metric | Svelte | Next.js/React |
|--------|--------|---------------|
| **Bundle Size** | ~60KB | ~250KB |
| **Performance** | Compile-time, no virtual DOM | Runtime, virtual DOM overhead |
| **Complexity** | Simple reactive syntax | Hooks, Server Components |
| **Real-time** | Native WebSocket/SSE | Requires additional setup |
| **Enterprise Use** | 1Password, Spotify, Apple | Vercel, GitHub, TikTok |
| **Maintenance** | Less boilerplate | More boilerplate |

**Decision**: For a daily-use ops dashboard, 5x smaller bundle and simpler maintenance wins.

### Integration Pattern

```
Development:
┌─────────────┐      ┌─────────────┐
│ Svelte Dev  │─────▶│  Go API     │
│ (Vite:5173) │ Proxy│ (Fiber:8080)│
└─────────────┘      └─────────────┘

Production:
┌──────────────────────────────┐
│      Single Go Binary        │
│  ┌────────────────────────┐  │
│  │ Embedded Svelte Build  │  │
│  │ (go:embed static)      │  │
│  └────────────────────────┘  │
│  ┌────────────────────────┐  │
│  │ API Routes (/api/*)    │  │
│  └────────────────────────┘  │
└──────────────────────────────┘
```

**Benefits**:
- Single Docker image deployment
- No Node.js in production
- Simplified ops (one binary to manage)

---

## Build System

### Makefile (CNCF Standard)

**Why Makefile over Taskfile?**
- 100% of CNCF Go projects use Makefile (Kubernetes, OPA, Prometheus, etcd)
- Zero installation (works out-of-box on Unix)
- Native CI/CD support everywhere
- Enterprise ops teams know it universally
- 40+ years battle-tested

**Key Targets**:
```bash
make help              # Self-documenting help
make build             # Build all binaries
make build-ui          # Build Svelte UI
make build-enterprise  # Build enterprise edition
make test              # Run all tests (Go + Svelte)
make lint              # Run all linters
make dev-up            # Start local environment
make dev-ui            # Start Svelte dev server
make ci                # Run all CI checks
```

---

## API & Client Access

### Primary Interface: CLI
```bash
giru server create --name my-server --endpoint https://...
giru policy apply -f policy.rego
giru deploy --env production
```

### Programmatic Access: OpenAPI Spec
- **No hand-written SDKs** (for MVP)
- **OpenAPI 3.0** specification (auto-generated from Go code)
- **Users generate clients** on-demand in any language
- **Rationale**: Infrastructure tool (like K8s), not SaaS (like Stripe)

**Future**: Polished SDKs when launching Managed SaaS offering

---

## Deployment & Infrastructure

### Local Development
- **Docker Compose**: Full stack (Envoy + OPA + Control Plane + DB)
- **Hot Reload**: 
  - Go (air)
  - Svelte (Vite HMR)
  - Envoy (xDS)
  - OPA (policy bundles)

### Kubernetes Production
- **Deployment**: Kustomize overlays (dev/staging/production)
- **Service Mesh**: Native Istio/Linkerd integration
- **Monitoring**: Prometheus + Grafana + Jaeger
- **HA**: Multi-zone, PostgreSQL primary/replica

### Observability
- **Metrics**: Prometheus (Envoy, OPA, custom)
- **Logs**: Structured JSON (Loki or ELK)
- **Tracing**: Jaeger (OpenTelemetry)
- **Dashboards**: Grafana

---

## Configuration Management (GitOps)

### Everything as Code
```
git repository
├── manifests/
│   ├── servers/          # MCP server definitions (YAML)
│   ├── routes/           # Routing rules
│   └── clients/          # Client configurations
└── policies/
    ├── authorization/    # OPA policies (Rego)
    ├── rate_limiting/
    └── compliance/
```

### Workflow
1. Developer commits manifest changes to Git
2. CI/CD validates manifests + policies
3. Control plane loads from PostgreSQL
4. xDS pushes to Envoy (zero downtime)

**Like**: Kubernetes manifests, Istio VirtualServices

---

## Security Architecture

### Defense in Depth (5 Layers)
1. **Network**: TLS 1.3, mTLS for service-to-service
2. **Authentication**: JWT, API keys, SSO (enterprise)
3. **Authorization**: OPA policies (RBAC/ABAC)
4. **Data Protection**: PII filtering, encryption at rest
5. **Audit**: Immutable logs, compliance reporting

---

## Testing Strategy

### Test Types
- **Unit Tests**: 
  - Go (80%+ coverage)
  - OPA policies (100% required)
  - Svelte components (Vitest)
- **Integration Tests**: Envoy + OPA + Control Plane
- **E2E Tests**: Full request flows
- **Performance Tests**: k6 (target: 100K+ RPS, P99 < 5ms)
- **Security Tests**: OWASP Top 10, dependency scanning

---

## Business Model

### Open Core Strategy

#### Community Edition (Apache 2.0)
- Basic routing and auth
- Core OPA policies
- Single-tenant
- Self-service support

#### Enterprise Edition (Proprietary)
- SSO (SAML, OIDC, Azure AD, Okta)
- Compliance policies (SOC2, HIPAA, GDPR)
- Multi-tenancy
- HA clustering
- 24/7 support
- Advanced analytics

#### Managed SaaS (Future - Phase 5)
- Usage-based pricing
- Guaranteed SLAs
- Fully managed infrastructure
- **Official SDKs** (TypeScript, Python, Go)
- Terraform provider

### Revenue Targets
- **Year 1**: $2M ARR (30 customers)
- **Year 2**: $6M ARR (80 customers, SaaS launch)
- **Year 3**: $15M ARR (200 customers)
- **Year 5**: $30M ARR (400 customers)

### Target Market
- **Primary**: Fortune 500 (finance, healthcare, e-commerce, government)
- **Secondary**: Mid-market with regulatory requirements

---

## Development Roadmap

### Phase 1-4: MVP (16 weeks) - Self-Hosted
1. **Phase 1 (Weeks 1-4)**: Core infrastructure
   - Envoy integration
   - OPA basics
   - Control plane (xDS + API)
   - Docker Compose
   - CLI

2. **Phase 2 (Weeks 5-8)**: Production ready
   - Kubernetes manifests
   - Monitoring stack
   - CI/CD pipelines
   - Security hardening

3. **Phase 3 (Weeks 9-12)**: Enterprise features
   - SSO integration
   - Multi-tenancy
   - Compliance policies
   - Svelte admin UI
   - License management

4. **Phase 4 (Weeks 13-16)**: Polish & launch
   - Performance tuning
   - Documentation
   - Examples
   - Community launch

### Phase 5+: Managed SaaS
- Multi-tenant control plane
- Usage metering & billing
- Customer portal
- Official SDKs
- Terraform provider

---

## Technology Decisions Summary

| Decision | Chosen | Alternative(s) | Rationale |
|----------|--------|----------------|-----------|
| **HTTP Framework** | Fiber v2 | Chi, Gin, stdlib | 2.4x faster, infrastructure needs |
| **Build System** | Makefile | Taskfile | CNCF standard, zero install |
| **Frontend** | Svelte 5 | Next.js, HTMX | 5x smaller, better for ops dashboards |
| **Proxy** | Envoy | Custom, Nginx | xDS, service mesh, battle-tested |
| **Policy Engine** | OPA | Custom Go | CNCF graduated, compliance-readable |
| **Database** | PostgreSQL | MySQL, MongoDB | ACID, JSON support, enterprise trust |
| **Cache** | Redis | Memcached | Rich features, Pub/Sub |
| **Monitoring** | Prometheus | Datadog, New Relic | Open source, CNCF ecosystem |

---

## Competitive Advantages

1. **Performance**: Envoy + Fiber = infrastructure-grade throughput
2. **Compliance**: OPA policies readable by auditors (vs code)
3. **GitOps**: Everything version-controlled (vs UI configuration)
4. **Service Mesh**: Native integration (vs standalone only)
5. **Open Core**: Community trust + enterprise features
6. **Single Binary**: Go + embedded UI = simple deployment
7. **CNCF Alignment**: Uses graduated projects (trust factor)

---

## Success Metrics

### Technical
- **Performance**: 100K+ RPS, P99 < 5ms
- **Reliability**: 99.99% uptime
- **Security**: Zero critical CVEs
- **Test Coverage**: 80%+ Go, 100% policies

### Business
- **ARR Growth**: YoY targets
- **Logo Retention**: > 95%
- **NRR**: > 120%
- **CAC**: < $30k
- **LTV:CAC**: > 10:1

### Developer
- **Time to Value**: < 15 minutes (clone to running)
- **Build Time**: < 5 minutes
- **Deploy Time**: < 10 minutes
- **PR Review**: < 24 hours

---

## Repository Structure

```
giru/
├── packages/
│   ├── core/                    # OPEN SOURCE (Apache 2.0)
│   │   ├── envoy/              # Envoy configs
│   │   ├── opa/                # Core OPA policies
│   │   ├── control-plane/      # Go backend (Fiber)
│   │   └── cli/                # CLI tool
│   └── enterprise/             # PROPRIETARY
│       ├── opa-policies/       # Compliance policies
│       ├── control-plane/      # Enterprise features (SSO, etc)
│       └── web-ui/             # Svelte admin dashboard
├── deployments/
│   ├── kubernetes/             # K8s manifests
│   ├── docker-compose/         # Local development
│   ├── terraform/              # Infrastructure as code
│   └── helm/                   # Helm charts
├── docs/                       # Documentation
├── examples/                   # Usage examples
└── Makefile                    # Build automation
```

---

## Getting Started (Developer)

```bash
# Clone repository
git clone https://github.com/giru/giru-gateway.git
cd giru-gateway

# One-command setup
make dev-setup

# Start development environment
make dev-up         # Docker Compose (backend stack)
make dev-ui         # Svelte dev server (enterprise UI)

# Gateway available at:
# - API: http://localhost:8080
# - UI: http://localhost:5173
# - Prometheus: http://localhost:9090
# - Grafana: http://localhost:3001
```

---

## Next Steps

1. **Review this tech stack** - Validate decisions
2. **Iterate on SCAFFOLD.md** - Refine directory structure
3. **Execute scaffolding** - Generate initial project structure
4. **Start Phase 1** - Build MVP over 16 weeks

---

**This is production-grade infrastructure software built to compete with any commercial offering while maintaining open-source community trust.**
