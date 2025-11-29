# SCAFFOLD.md Changelog

## Updates Applied - 2025-11-11

### 1. **HTTP Framework: Changed to Fiber v2**
- **From**: Chi or Gin
- **To**: Fiber v2 (fasthttp-based)
- **Rationale**: 
  - 6M requests/sec (2.4x faster than Gin, 3.3x faster than stdlib)
  - Zero memory allocation in hot paths
  - Production-proven (Alibaba, etc.)
  - Perfect for infrastructure-grade performance

### 2. **Build System: Makefile (CNCF Standard)**
- **Decision**: Use Makefile over Taskfile
- **Rationale**:
  - 100% of major CNCF Go projects use Makefile (Kubernetes, OPA, Prometheus, etcd)
  - Zero installation required for contributors
  - Native CI/CD support across all platforms
  - Enterprise operations teams universally familiar
  - 40+ years of battle-testing
- **Added**: Comprehensive production-grade Makefile template with 40+ targets

### 3. **Removed SDKs (TypeScript/Python)**
- **Decision**: No client SDKs in MVP
- **Rationale**:
  - Giru is infrastructure (like K8s), not SaaS (like Stripe)
  - CLI covers 95% of use cases
  - OpenAPI spec allows on-demand client generation
  - Lower maintenance burden
  - Will add polished SDKs when launching Managed SaaS offering
- **Replaced With**:
  - Robust CLI (`giru` command)
  - OpenAPI 3.0 specification (auto-generated from code)
  - Client generation documentation
  - curl examples and REST API docs

### 3.5. **Frontend: Changed from Next.js to Svelte**
- **From**: Next.js 14 + React + shadcn/ui
- **To**: Svelte 5 + SvelteKit 2 + DaisyUI
- **Rationale**:
  - **5x Smaller Bundle**: ~60KB vs 250KB (Next.js/React)
  - **Better Performance**: Compile-time framework, no virtual DOM
  - **Simpler Maintenance**: Less boilerplate, clearer mental model
  - **Infrastructure UI Focus**: Ops teams use dashboards daily, performance matters
  - **Real-time Native**: Easy WebSocket/SSE integration
  - **TypeScript Support**: Full type safety maintained
  - **Enterprise Credibility**: Used by 1Password, Spotify, Apple Music
  - **Go Integration**: Static build embedded in Go binary (single deployment)
- **Integration Pattern**: Svelte static build → embedded in Go binary → single Docker image

### 4. **Business Model Clarification**
- **Added**: Revenue streams and targets
  - Community Edition (Open Source - Apache 2.0)
  - Enterprise Edition (Commercial - Proprietary)
  - Managed SaaS (Future - with SDKs)
- **Added**: Revenue targets
  - Year 1: $2M ARR (30 customers)
  - Year 2: $6M ARR (80 customers, SaaS launch)
  - Year 3: $15M ARR (200 customers)
  - Year 5: $30M ARR (400 customers)
- **Added**: Go-to-market metrics (CAC, LTV, sales cycle, NRR)

### 5. **Phase 5 Roadmap Addition**
- **Added**: Managed SaaS Foundation phase
  - Multi-tenant control plane
  - Usage metering and billing
  - Customer portal
  - Automated provisioning
  - Official SDKs (TypeScript, Python, Go) for SaaS API
  - Terraform provider

### 6. **Directory Structure Changes**
- **Removed**: 
  ```
  packages/core/sdk/
    typescript/
    python/
  ```
- **Added**:
  ```
  packages/core/control-plane/pkg/api/openapi/
    spec.yaml       # OpenAPI 3.0 spec
    generator.go    # Auto-generate from code
  ```
- **Changed**:
  ```
  packages/enterprise/web-ui/
    src/
      routes/        # SvelteKit file-based routing (was: app/)
      lib/           # Reusable code (was: components/, lib/)
    svelte.config.js # SvelteKit config (was: next.config.js)
    vite.config.ts   # Vite config (new)
  ```

### 7. **Documentation Updates**
- **Added**: API documentation structure
  - `docs/api/openapi-spec.yaml`
  - `docs/api/client-generation.md`
  - `docs/api/curl-examples.md`
- **Updated**: Focus on CLI as primary interface
- **Added**: OpenAPI-first approach documentation

### 8. **Technical Rationale Sections**
- **Added**: "Why Fiber for HTTP Framework?"
- **Added**: "Why Makefile over Taskfile?"
- **Added**: "Why No SDKs (Initially)?"

### 9. **Developer Experience**
- **Enhanced**: CLI command examples
- **Added**: OpenAPI client generation examples
- **Added**: REST API curl examples
- **Added**: Swagger UI integration (`/api/docs`)

### 10. **Makefile Template**
- **Added**: Complete production-grade Makefile with:
  - Self-documenting help system
  - Colored output
  - Git-based versioning
  - Parallel build support
  - Cross-platform compatibility
  - 50+ make targets (build, test, lint, docker, deploy, UI, etc.)
  - CI integration (`make ci`)
  - Svelte-specific targets:
    - `make build-ui` - Build Svelte to static assets
    - `make dev-ui` - Start Svelte dev server
    - `make test-ui` - Run Vitest tests
    - `make lint-ui` - Run svelte-check + ESLint

### 11. **Svelte + Go Integration**
- **Added**: Comprehensive integration pattern documentation
  - Development: Separate servers (Vite :5173 + Fiber :8080)
  - Production: Single Go binary with embedded static assets
  - Build process: `npm run build` → `go:embed` → single deployment
  - Real-time: WebSocket examples with Svelte + Go
  - API client: TypeScript client with dev/prod environment handling
  - Configuration: SvelteKit adapter-static for SPA mode

### 12. **Multi-Tier Development Environment**
- **Added**: Layered development approach (following CNCF best practices)
  - **Tier 1 - Docker Compose** (95% of daily work):
    - Fast startup (~10 seconds)
    - Hot reload: air (Go), Vite (Svelte), xDS (Envoy), OPA
    - Full stack in containers
    - No K8s knowledge required
  - **Tier 2 - kind + Skaffold** (5% K8s testing):
    - Real Kubernetes environment
    - Multi-tenant testing (namespaces)
    - Service mesh integration (Istio)
    - Hot reload in K8s (Skaffold file sync)
  - **Tier 3 - Production Builds**:
    - Docker buildx (multi-arch standard)
    - ko (Go-optimized, optional)
- **Rationale**: Matches how CNCF projects develop (OPA, Envoy, Kubernetes)

### 13. **Container Build Strategies**
- **Added**: Docker vs ko comparison
  - **Docker**: Standard, flexible, familiar (recommended for MVP)
  - **ko**: Faster, smaller, distroless (optional optimization)
  - Multi-stage Dockerfiles with distroless base images
  - Build comparison table (speed, size, multi-arch, flexibility)
- **Recommendation**: Start with Docker, add ko for Go binaries in production

### 14. **Complete Configuration Examples**
- **Added**: Production-ready Docker Compose configuration
  - Full stack: Envoy, OPA, Control Plane, PostgreSQL, Redis, Prometheus, Grafana
  - Health checks for all services
  - Volume mounts for hot reload
  - Network isolation
- **Added**: kind cluster configuration
  - Multi-node setup (1 control plane + 2 workers)
  - Port mappings for local access
  - Ingress-ready labels
- **Added**: Skaffold configuration
  - ko integration for Go builds
  - File sync for fast iteration
  - Port forwarding
  - Development profiles (minimal/full)
  - Deployment hooks

### 15. **Enhanced Makefile**
- **Added**: 15+ new targets for K8s development
  - `make deps-dev` - Install kind, skaffold, ko
  - `make kind-create` - Create kind cluster
  - `make kind-delete` - Delete kind cluster
  - `make skaffold-dev` - Deploy with hot reload
  - `make ko-build` - Build with ko
  - `make ko-apply` - Build and deploy with ko
  - `make dev-info` - Show environment info and installed tools
- **Total targets**: 65+ make targets covering all workflows

### 16. **Repository Restructuring for CNCF Compliance**
- **Decision**: Separate repositories for open-source and enterprise (BREAKING CHANGE)
- **Rationale**:
  - CNCF requires 100% Apache 2.0 license for donated projects
  - Single monorepo with mixed licenses is NOT acceptable for CNCF
  - Community trust requires clear separation of open vs proprietary code
  - Proven model: Cilium/Isovalent ($100M funding), Kong (IPO'd), Traefik
  - Easier governance (CNCF governs open-source, company controls enterprise)
- **New Structure**:
  1. **giru-ai/giru** (Public, Apache 2.0) - CNCF project
  2. **giru-ai/giru-enterprise** (Private, Proprietary) - Commercial product
  3. **giru-ai/giru-common** (Public, Apache 2.0) - Shared libraries
- **Changes to SCAFFOLD.md**:
  - Removed `packages/core/` and `packages/enterprise/` structure
  - Added three separate repository structures with full directory trees
  - Moved enterprise directory to completely separate repository
  - Updated business model section with repository strategy explanation
  - Added "Why Separate Repositories?" rationale with CNCF requirements
- **Open Source Repository (giru-ai/giru)**:
  - Contains ALL production-ready core features
  - Full Envoy + OPA + Control Plane + CLI + Basic Web UI
  - Complete database layer (PostgreSQL, migrations, sqlc)
  - Full observability (Prometheus, Jaeger, logging)
  - Docker Compose and Kubernetes deployment
  - Single-tenant mode with API key auth
  - Tool-level access control (basic)
  - 100% Apache 2.0 licensed
- **Enterprise Repository (giru-ai/giru-enterprise)**:
  - Imports and extends open-source core
  - SSO (SAML, OIDC, Azure AD, Okta, Google)
  - Multi-tenancy with resource isolation
  - Compliance policies (SOC2, HIPAA, GDPR, PCI)
  - Advanced audit logging and analytics
  - License management system
  - Advanced enterprise UI
  - Proprietary licensed
- **Common Repository (giru-ai/giru-common)**:
  - Shared data models and utilities
  - Protocol buffers and API contracts
  - Used by both open-source and enterprise
  - Apache 2.0 licensed
- **Integration Pattern**:
  - Enterprise binary imports `github.com/giru-ai/giru` as dependency
  - Registers enterprise extensions via server hooks/plugins
  - License validation gates enterprise features
  - Fallback to open-source mode if no license
- **Distribution**:
  - **Open Source**: Docker images `giru/gateway:latest`
  - **Enterprise**: Docker images `giru/gateway:enterprise`
- **CNCF Submission Path**:
  - Month 1-4: Build open-source MVP
  - Month 5: Apply to CNCF Sandbox
  - Month 6-8: Launch enterprise product (separate repo)
  - Month 12-18: Apply for CNCF Incubation
  - Month 24-36: Apply for CNCF Graduation
- **Updated Files**:
  - Created `CNCF_REPO_STRATEGY.md` with complete research and strategy
  - Updated `SCAFFOLD.md` repository structure (3 separate repos)
  - Updated `SCAFFOLD.md` business model section
  - Updated feature segmentation to show open-source vs enterprise clearly
  - Updated license management section with enterprise-specific code
- **Research Documentation**:
  - Analyzed Cilium/Isovalent, Kong, Traefik, Grafana repository patterns
  - Documented why single-repo doesn't work for CNCF
  - Provided examples of successful open-core CNCF projects
  - Detailed CNCF requirements and governance implications

### 17. **Database Strategy (Goose + pgx + sqlc)**
- **Added**: Complete database layer architecture
  - **Driver**: pgx v5 (30-50% faster than GORM, PostgreSQL-native)
  - **Query Builder**: sqlc (type-safe Go code generation from SQL)
  - **Migrations**: goose (imperative SQL with sequential versioning)
  - **Seeds**: SQL files + Makefile targets
- **Rationale**:
  - **Simplicity**: Goose uses plain SQL files, zero learning curve
  - **Infrastructure Pattern**: Explicit control over schema changes (vs declarative Atlas)
  - **Seed Support**: Native SQL seeds + Go code option for complex scenarios
  - **Production Track Record**: Used by Kubernetes projects, GitLab, infrastructure companies
  - **Go Integration**: Migrations embed in control plane binary for automated startup
  - **Type Safety**: sqlc generates type-safe Go from SQL at build time
  - **Performance**: pgx eliminates reflection overhead, full PostgreSQL feature access
- **Added**: Complete directory structure
  ```
  packages/core/control-plane/
  ├── db/
  │   ├── migrations/       # Goose SQL migrations
  │   ├── seeds/           # Seed data SQL files
  │   ├── queries/         # sqlc query files
  │   └── sqlc.yaml        # sqlc configuration
  ├── internal/
  │   └── database/
  │       ├── db.go        # Connection pool (pgxpool)
  │       ├── migrations.go # Goose runner with embed
  │       ├── models/      # sqlc generated code
  │       └── tx.go        # Transaction helpers
  ```
- **Added**: Example migration files
  - `00001_init.sql` - Core tables (tenants, mcp_servers, routes, clients)
  - `00004_add_audit_logs.sql` - Audit logging with partitioning (enterprise)
  - Goose up/down syntax examples
  - PostgreSQL best practices (UUID, JSONB, indexes, soft deletes)
- **Added**: Example sqlc query files
  - `tenants.sql` - CRUD operations with type-safe parameters
  - `servers.sql` - Server registry queries
  - Demonstrates sqlc annotations (`:one`, `:many`, `:exec`)
- **Added**: Example seed files
  - `001_tenants.sql` - Demo and enterprise demo tenants
  - `002_demo_servers.sql` - Sample MCP servers
  - `ON CONFLICT` handling for idempotency
- **Added**: Go integration code examples
  - Database connection with pgxpool
  - Migration runner with embedded FS
  - Transaction helper with panic recovery
  - Handler examples using sqlc-generated models
- **Added**: 12 new Makefile targets
  - `make db-install` - Install goose CLI
  - `make db-create` / `make db-drop` - Database creation
  - `make db-migrate` - Run migrations
  - `make db-migrate-status` - Show migration status
  - `make db-migrate-down` - Rollback last migration
  - `make db-migrate-reset` - Reset all migrations
  - `make db-migrate-create NAME=xxx` - Create new migration
  - `make db-seed` - Load seed data
  - `make db-reset` - Complete reset (migrate + seed)
  - `make sqlc-generate` - Generate Go code from queries
  - `make sqlc-install` - Install sqlc CLI
  - `make db-console` - Open psql console
  - `make db-dump` / `make db-restore` - Backup/restore
- **Added**: Development workflow documentation
  - Daily development cycle
  - Creating new features workflow
  - Testing migrations (up/down/reset)
- **Added**: Production considerations
  - Connection pooling settings (25 max, 5 min, health checks)
  - Performance best practices (indexes, JSONB, soft deletes)
  - Security guidelines (hashing, TLS, least privilege)
  - Monitoring recommendations (metrics, slow queries, replication)
  - Backup strategy (daily dumps, WAL archiving, PITR, 30-day retention)
- **Added**: Technical rationale sections
  - "Why Goose for Migrations?" (vs Atlas)
  - "Why pgx + sqlc for Database Layer?" (vs GORM)
  - Comparison table: Goose vs Atlas feature matrix
  - Code comparison: Imperative (Goose) vs Declarative (Atlas)
- **Total Makefile targets**: Now 77+ targets (was 65+)

## Summary

The scaffold now reflects a **production-grade, CNCF-ready, infrastructure-focused MCP gateway** that:

1. **CNCF Compliant Repository Structure** 🆕
   - Three separate repositories (open-source, enterprise, common)
   - 100% Apache 2.0 for CNCF donation (giru-ai/giru)
   - Clear path to CNCF Sandbox → Incubation → Graduation
   - Proven model used by Cilium ($100M), Kong (IPO'd), Traefik
   - Enterprise features in private repo (giru-ai/giru-enterprise)
2. **Prioritizes performance** 
   - Backend: Fiber v2 HTTP framework (6M req/sec)
   - Frontend: Svelte (5x smaller bundle than React)
   - Database: pgx driver (30-50% faster than GORM)
3. **Follows CNCF standards** 
   - Makefile build system (like Kubernetes, OPA, Prometheus)
   - Multi-tier development (Docker Compose + kind + Skaffold)
   - Container strategies (Docker + ko option)
   - Separate repositories for open-core model
4. **Embraces infrastructure patterns** 
   - CLI and manifests over SDKs
   - Explicit schema control (Goose SQL migrations vs declarative)
   - Type-safe database layer (sqlc code generation)
   - Extension/plugin architecture for enterprise features
5. **Production-ready open source core**
   - Full Envoy + OPA + Control Plane + CLI + Basic UI
   - Complete observability (Prometheus, Jaeger, logging)
   - Docker Compose and Kubernetes deployment
   - PostgreSQL + Redis with migrations and seeds
6. **Enterprise product strategy** 
   - Separate private repository (giru-enterprise)
   - Imports and extends open-source core
   - License-based feature gating
   - SSO, multi-tenancy, compliance, advanced audit
7. **Plans for SaaS future** while focusing on self-hosted MVP
8. **Targets enterprise revenue** with clear business model and metrics
9. **Maintains developer experience** 
   - OpenAPI and client generation
   - Fast iteration (Docker Compose with hot reload)
   - K8s testing when needed (kind + Skaffold)
   - Simple database workflow (SQL files + make commands)
10. **Optimized for daily use** - Ops teams use dashboards constantly, speed matters
11. **Single binary deployment** - Go + embedded Svelte UI + embedded migrations for simplicity
12. **Developer-friendly workflows** 
    - 95% Docker Compose, 5% K8s testing
    - Plain SQL queries in .sql files (easy to review, optimize, version)
    - Makefile targets for all database operations (migrate, seed, reset)
13. **Production-ready database layer**
    - Connection pooling and health checks
    - Audit logging with partitioning
    - Backup/restore procedures
    - Security best practices (hashing, TLS, least privilege)

## Ready for Implementation

The scaffold is now ready to guide Claude Code through:
- **Phase 1-4**: Building the self-hosted MVP (16 weeks)
- **Phase 5+**: Expanding to Managed SaaS offering

All technical decisions are justified, aligned with CNCF best practices, and optimized for the target market (Fortune 500 enterprises).

## Developer Workflow Summary

### Daily Development (95% of time)
```bash
make dev-up      # Start Docker Compose stack
make dev-ui      # Start Svelte dev server
# Code with hot reload (instant feedback)
make test        # Run tests
make dev-down    # Stop when done
```

### Kubernetes Testing (5% of time)
```bash
make kind-create    # Create local K8s cluster (one-time)
make skaffold-dev   # Deploy with hot reload
# Test multi-tenancy, service mesh, K8s manifests
make kind-delete    # Cleanup
```

### Production Builds (CI/CD)
```bash
make build-production  # Multi-arch Docker images
# OR
make ko-build         # Optimized Go builds
```

This matches how CNCF projects (Kubernetes, OPA, Istio) are developed in practice.
