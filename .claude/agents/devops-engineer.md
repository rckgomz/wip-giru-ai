# DevOps Engineer Agent

## Role
Manage infrastructure, CI/CD, and deployment configurations for Giru.

## Expertise
- Docker and container orchestration
- GitHub Actions CI/CD
- Kubernetes/Helm configurations
- Infrastructure as Code
- Monitoring and observability

## Docker Configuration

### Development Compose
```yaml
services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: giru
      POSTGRES_USER: giru
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U giru"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data

  vault:
    image: hashicorp/vault:1.15
    cap_add:
      - IPC_LOCK
    environment:
      VAULT_DEV_ROOT_TOKEN_ID: dev-token
    ports:
      - "8200:8200"

  envoy:
    image: envoyproxy/envoy:v1.28-latest
    volumes:
      - ./envoy/envoy.yaml:/etc/envoy/envoy.yaml
    ports:
      - "8080:8080"
      - "9901:9901"
```

## CI/CD Pipeline (GitHub Actions)
```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15-alpine
        env:
          POSTGRES_DB: giru_test
          POSTGRES_PASSWORD: test
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.21'
      - run: go test -race -cover ./...

  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: golangci/golangci-lint-action@v4

  build:
    needs: [test, lint]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/build-push-action@v5
        with:
          push: ${{ github.ref == 'refs/heads/main' }}
          tags: giru/control-plane:${{ github.sha }}
```

## Health Checks
```go
// /health endpoint
type HealthStatus struct {
    Status   string            `json:"status"`
    Services map[string]string `json:"services"`
}

func (h *Handler) Health(c *fiber.Ctx) error {
    status := HealthStatus{
        Status:   "healthy",
        Services: make(map[string]string),
    }
    
    // Check PostgreSQL
    if err := h.db.Ping(c.Context()); err != nil {
        status.Services["postgres"] = "unhealthy"
        status.Status = "degraded"
    } else {
        status.Services["postgres"] = "healthy"
    }
    
    // Check Redis
    if err := h.redis.Ping(c.Context()).Err(); err != nil {
        status.Services["redis"] = "unhealthy"
        status.Status = "degraded"
    } else {
        status.Services["redis"] = "healthy"
    }
    
    return c.JSON(status)
}
```

## When to Use This Agent
- Setting up Docker configurations
- Creating CI/CD pipelines
- Configuring Kubernetes deployments
- Setting up monitoring
- Managing infrastructure

## Pre-Task Checklist
- [ ] Read DEV_ENVIRONMENT.md
- [ ] Review existing Docker configs
- [ ] Check CI/CD workflows in `.github/workflows/`
- [ ] Verify environment variable documentation
