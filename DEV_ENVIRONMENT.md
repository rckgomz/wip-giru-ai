# Giru Gateway - Development Environment Guide

> Quick reference for developers working on Giru

## TL;DR - Get Started in 2 Minutes

```bash
# Clone and setup
git clone https://github.com/giru/giru-gateway.git
cd giru-gateway
make dev-setup

# Start development
make dev-up         # Terminal 1: Start backend stack
make dev-ui         # Terminal 2: Start Svelte UI

# Code with instant hot reload! 🚀
# - Go changes: air rebuilds (~1s)
# - Svelte changes: Vite HMR (instant)
# - Envoy config: xDS push (instant)
# - OPA policies: Bundle reload (~1s)
```

**Access URLs:**
- Gateway: http://localhost:8080
- Admin UI: http://localhost:5173
- Control Plane API: http://localhost:18000
- Envoy Admin: http://localhost:9901
- OPA: http://localhost:8181
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000

---

## Development Philosophy: Layered Approach

We follow CNCF best practices with a three-tier development model:

### Tier 1: Docker Compose (95% of Daily Work)
**When:** Adding features, fixing bugs, writing policies, UI development

**Why:**
- ✅ Fast startup (~10 seconds)
- ✅ Hot reload for everything
- ✅ No Kubernetes knowledge needed
- ✅ Resource efficient
- ✅ Familiar to all developers

**Commands:**
```bash
make dev-up       # Start all services
make dev-down     # Stop all services
make dev-logs     # Tail logs
make dev-ui       # Start Svelte dev server
```

---

### Tier 2: kind + Skaffold (5% for K8s Testing)
**When:** Testing K8s-specific features, multi-tenancy, service mesh integration

**Why:**
- ✅ Real Kubernetes environment
- ✅ Test namespaces, RBAC, network policies
- ✅ Validate Helm charts
- ✅ Service mesh integration (Istio)
- ✅ Still has hot reload via Skaffold

**Commands:**
```bash
# One-time setup
make kind-create

# Development
make skaffold-dev   # Deploy with hot reload, tail logs

# Test multi-tenancy
kubectl create namespace tenant-acme
kubectl apply -f examples/multi-tenant/

# Cleanup
make kind-delete
```

---

### Tier 3: Production Builds (CI/CD Only)
**When:** Building images for staging/production

**Options:**
```bash
# Standard Docker (recommended)
make build-production

# Go-optimized with ko (optional)
make ko-build
```

---

## Detailed: Tier 1 - Docker Compose

### What's Included

```
┌─────────────────────────────────────────┐
│  Docker Compose Stack (8 containers)   │
├─────────────────────────────────────────┤
│  1. Envoy        - Gateway proxy        │
│  2. OPA          - Policy engine        │
│  3. Control Plane - Go API (Fiber)      │
│  4. PostgreSQL   - Configuration DB     │
│  5. Redis        - Cache                │
│  6. Prometheus   - Metrics              │
│  7. Grafana      - Dashboards           │
│  8. (Svelte UI runs separately)         │
└─────────────────────────────────────────┘
```

### Hot Reload Magic

| Component | Tool | Speed | What Triggers Reload |
|-----------|------|-------|---------------------|
| **Go Control Plane** | air | ~1s | `*.go` file changes |
| **Svelte UI** | Vite | Instant | `*.svelte`, `*.ts` changes |
| **Envoy Config** | xDS | Instant | Control plane pushes new config |
| **OPA Policies** | Bundle reload | ~1s | `*.rego` file changes |

### Development Workflow

```bash
# 1. Start backend stack
make dev-up

# 2. In separate terminal, start UI
make dev-ui

# 3. Edit code - watch it reload automatically!
# packages/core/control-plane/pkg/api/rest/handlers/servers.go
# packages/enterprise/web-ui/src/routes/servers/+page.svelte
# packages/core/opa/policies/authorization/basic_auth.rego

# 4. View logs
make dev-logs

# 5. Stop when done
make dev-down
```

### Troubleshooting

**Services won't start?**
```bash
# Check what's using ports
make dev-status

# Force cleanup
make dev-down
docker-compose -f deployments/docker-compose/docker-compose.dev.yml down -v

# Restart
make dev-up
```

**Database issues?**
```bash
# Reset database
make dev-db-reset

# Access PostgreSQL
docker exec -it giru-postgres psql -U postgres -d giru
```

**Want to see what's running?**
```bash
docker-compose -f deployments/docker-compose/docker-compose.dev.yml ps
```

---

## Detailed: Tier 2 - kind + Skaffold

### When to Use

Use kind when you need to test:
- ✅ Multi-tenant isolation (namespaces)
- ✅ Kubernetes RBAC policies
- ✅ Network policies
- ✅ Service mesh integration (Istio)
- ✅ Helm chart deployment
- ✅ xDS configuration in real K8s
- ✅ Horizontal Pod Autoscaling

### Setup (One-Time)

```bash
# Install tools (if not already installed)
make deps-dev

# Verify installation
make dev-info

# Create kind cluster (3 nodes: 1 control-plane, 2 workers)
make kind-create

# Verify cluster
kubectl get nodes
# Should show 3 nodes
```

### Development Workflow

```bash
# Deploy with hot reload
make skaffold-dev

# Skaffold will:
# 1. Build images (using ko for Go, Docker for others)
# 2. Load images into kind cluster
# 3. Deploy to giru-dev namespace
# 4. Port-forward services to localhost
# 5. Tail logs
# 6. Watch for changes and rebuild/redeploy

# In another terminal, you can:
kubectl get pods -n giru-dev
kubectl logs -f deployment/giru-control-plane -n giru-dev
kubectl describe pod <pod-name> -n giru-dev
```

### Testing Multi-Tenancy

```bash
# Create tenant namespaces
kubectl create namespace tenant-acme
kubectl create namespace tenant-globex

# Deploy tenant-specific configs
kubectl apply -f examples/multi-tenant/acme-config.yaml
kubectl apply -f examples/multi-tenant/globex-config.yaml

# Verify isolation
kubectl get mcpservers -n tenant-acme
kubectl get mcpservers -n tenant-globex
```

### Testing Service Mesh (Istio)

```bash
# Install Istio (if not already)
istioctl install --set profile=demo -y

# Label namespace for injection
kubectl label namespace giru-dev istio-injection=enabled

# Redeploy
make skaffold-run

# View service mesh
istioctl dashboard kiali
```

### Cleanup

```bash
# Stop Skaffold (Ctrl+C) or
make skaffold-delete

# Delete kind cluster
make kind-delete
```

---

## Build Strategies

### Option A: Docker (Standard - Recommended)

**Use for:** MVP, development, all non-Go images

```dockerfile
# Multi-stage build
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /giru ./cmd/server

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /giru /
EXPOSE 8080
ENTRYPOINT ["/giru"]
```

**Pros:**
- Familiar to all developers
- Flexible (custom base images, multi-language)
- Works for Envoy, OPA, Svelte UI, Go
- Well-documented

**Cons:**
- Slightly slower than ko
- Requires Dockerfile maintenance

---

### Option B: ko (Go-Optimized - Optional)

**Use for:** Production Go binaries, fast iteration in K8s

```bash
# Build without Dockerfile
ko build ./packages/core/control-plane/cmd/server

# Build and deploy to K8s
ko apply -f deployments/kubernetes/base/

# Multi-arch
ko build --platform=linux/amd64,linux/arm64 ./cmd/server
```

**Pros:**
- Faster builds (incremental)
- Smaller images (~15MB vs ~20MB)
- Automatic distroless base
- No Dockerfile needed
- Multi-arch automatic

**Cons:**
- Go only (can't use for Envoy, OPA, Svelte)
- Less familiar to team
- Less flexible than Dockerfile

**Recommendation:** Start with Docker, add ko later for production optimization

---

## Common Tasks

### Running Tests

```bash
# All tests
make test

# Just Go tests
make test-go

# Just UI tests
make test-ui

# OPA policy tests
make test-policies

# Integration tests (requires kind)
make kind-create
make test-integration
```

### Linting

```bash
# All linters
make lint

# Just Go
make lint-go

# Just Svelte/TypeScript
make lint-ui
```

### Building

```bash
# Build Go binaries
make build

# Build Svelte UI
make build-ui

# Build Docker images
make docker-build

# Build everything (community edition)
make build-community

# Build everything (enterprise edition)
make build-enterprise
```

### Database Operations

```bash
# Run migrations
make migrate-up

# Rollback migration
make migrate-down

# Reset database
make dev-db-reset

# Seed test data
make dev-db-seed
```

---

## Environment Variables

### Docker Compose

Edit `deployments/docker-compose/.env`:

```bash
# Database
DATABASE_URL=postgresql://postgres:password@postgres:5432/giru

# Redis
REDIS_URL=redis://redis:6379

# OPA
OPA_URL=http://opa:8181

# Log level
LOG_LEVEL=debug

# Envoy admin port
ENVOY_ADMIN_PORT=9901
```

### kind + Skaffold

Set via ConfigMaps/Secrets in `deployments/kubernetes/overlays/dev/`

---

## Port Reference

| Service | Port | URL |
|---------|------|-----|
| **Gateway (Envoy)** | 8080 | http://localhost:8080 |
| **Envoy Admin** | 9901 | http://localhost:9901 |
| **Control Plane API** | 18000 | http://localhost:18000 |
| **Control Plane xDS** | 19000 | grpc://localhost:19000 |
| **OPA** | 8181 | http://localhost:8181 |
| **PostgreSQL** | 5432 | postgresql://localhost:5432 |
| **Redis** | 6379 | redis://localhost:6379 |
| **Prometheus** | 9090 | http://localhost:9090 |
| **Grafana** | 3000 | http://localhost:3000 |
| **Svelte UI** | 5173 | http://localhost:5173 |

---

## Tools Installation

### Required

```bash
# macOS
brew install docker docker-compose

# Ubuntu/Debian
sudo apt install docker.io docker-compose

# Verify
docker --version
docker-compose --version
```

### Optional (for K8s development)

```bash
# Install via make
make deps-dev

# Or manually:

# kind
go install sigs.k8s.io/kind@latest

# skaffold
# macOS
brew install skaffold
# Linux
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
chmod +x skaffold && sudo mv skaffold /usr/local/bin

# ko
go install github.com/google/ko@latest

# kubectl
# macOS
brew install kubectl
# Ubuntu/Debian
sudo apt install kubectl
```

### Verify Installation

```bash
make dev-info
```

Output:
```
Giru Development Environment

Available Environments:
  1. Docker Compose (Tier 1 - Daily Development)
     Commands: make dev-up, make dev-ui, make dev-logs, make dev-down

  2. kind + Skaffold (Tier 2 - K8s Testing)
     Commands: make kind-create, make skaffold-dev, make kind-delete

Build Options:
  - Docker:    make build (standard)
  - ko:        make ko-build (Go optimization)

Installed Tools:
  ✅ Docker
  ✅ kind
  ✅ Skaffold
  ✅ ko
  ✅ kubectl
```

---

## Best Practices

### 1. Use Docker Compose for Daily Work
Don't overcomplicate. 95% of development doesn't need Kubernetes.

### 2. Test in kind Before PRs
Run `make kind-create && make skaffold-dev` to catch K8s-specific issues.

### 3. Keep kind Cluster Running
Creating/destroying kind clusters is slow. Create once, use for days.

### 4. Use Hot Reload
Don't rebuild manually. Let air (Go) and Vite (Svelte) handle it.

### 5. Check Logs Often
```bash
make dev-logs  # See all service logs
```

### 6. Clean Up
```bash
make dev-down  # Stop Docker Compose
make kind-delete  # Delete kind cluster (when done for the day)
```

---

## Getting Help

- **Documentation**: `/docs`
- **Examples**: `/examples`
- **Troubleshooting**: `/docs/guides/troubleshooting.md`
- **Slack**: `#giru-dev` channel
- **GitHub Issues**: For bugs

---

## Quick Reference Card

```bash
# Daily Development
make dev-up          # Start Docker Compose
make dev-ui          # Start Svelte dev server
make dev-logs        # View logs
make dev-down        # Stop services

# Kubernetes Testing
make kind-create     # Create cluster (once)
make skaffold-dev    # Deploy with hot reload
make kind-delete     # Delete cluster

# Building
make build           # Build Go binaries
make build-ui        # Build Svelte UI
make docker-build    # Build Docker images

# Testing
make test            # Run all tests
make lint            # Run all linters

# Utilities
make clean           # Clean build artifacts
make dev-info        # Show environment info
make help            # Show all make targets
```

---

**Happy coding! 🚀**
