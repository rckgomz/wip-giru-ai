# SCAFFOLD.md Navigation Index

This index helps you quickly locate specific sections in SCAFFOLD.md for common development tasks.

---

## By Task Type

### "I need to add a database table or modify schema"
1. **Read**: SCAFFOLD.md § "Canonical Database Schema" - understand existing tables
2. **Pattern**: Create migration in `db/migrations/` using Goose format
3. **Queries**: Add sqlc queries in `db/queries/`
4. **Generate**: Run `make sqlc-generate`
5. **Remember**: All tables need `tenant_id`, `created_at`, `updated_at`, `deleted_at`

### "I need to write an OPA/Rego policy"
1. **Read**: SCAFFOLD.md § "Compliance Policy Code" - see existing patterns
2. **Read**: SCAFFOLD.md § "Policy Data Management" - understand data flow
3. **Pattern**: Default deny (`default allow := false`)
4. **Location**: `policies/<domain>/<policy_name>.rego`
5. **Tests**: `policies/tests/<policy_name>_test.rego`

### "I need to understand the request flow"
1. **Read**: SCAFFOLD.md § "Request Flow Architecture" - complete flow diagram
2. **Key steps**: Auth → Subscription resolution → Rate limit → OPA → Route → Response

### "I need to add a new REST API endpoint"
1. **Read**: SCAFFOLD.md § "Directory Structure" - see handler organization
2. **Location**: `internal/api/rest/handlers/<resource>.go`
3. **Register**: Add route in `internal/api/rest/routes.go`
4. **Pattern**: Parse → Validate → Get tenant_id → Business logic → Response

### "I need to add a new MCP server integration"
1. **Read**: SCAFFOLD.md § "MCP JSON-RPC Protocol Details" - protocol spec
2. **Read**: SCAFFOLD.md § "Core Data Entities" - understand MCP Server entity
3. **Transports**: `internal/mcp/transport_stdio.go`, `transport_http.go`

### "I need to understand provider abstraction (proxy/policy engines)"
1. **Read**: SCAFFOLD.md § "Provider Abstraction Architecture" - interfaces
2. **Proxy interface**: `internal/proxy/provider.go`
3. **Policy interface**: `internal/policy/engine.go`
4. **Default implementations**: Envoy (`internal/proxy/envoy/`), OPA (`internal/policy/opa/`)

### "I need to add a Svelte UI feature"
1. **Read**: SCAFFOLD.md § "Web UI Strategy" - feature breakdown
2. **Location**: `web-ui/src/routes/<feature>/+page.svelte`
3. **State**: Use Svelte 5 runes (`$state`, `$derived`, `$effect`)
4. **API client**: `web-ui/src/lib/api/`

### "I need to add authentication/credential handling"
1. **Read**: SCAFFOLD.md § "Authentication & Credential Management"
2. **Three layers**: Client→Giru, Giru→MCP, User→UI
3. **Vault client**: `internal/vault/client.go`
4. **Fallback**: pgcrypto for non-Vault deployments

---

## Critical Sections (Read Before Any Implementation)

| Section | Why It Matters |
|---------|----------------|
| Core Data Entities | Understand the domain model before coding |
| The Five Golden Rules | Non-negotiable constraints for ALL code |
| Technical Decisions and Rationale | Why we chose each technology |
| Provider Abstraction Architecture | How swappable components work |

---

## Section Quick Links

### Architecture & Design
- Project Overview - High-level architecture
- Core Concepts - MCP protocol, entities, three-layer design
- Request Flow Architecture - Step-by-step request processing
- Technical Decisions and Rationale - Why Envoy, OPA, Go, etc.
- Provider Abstraction Architecture - Swappable proxy/policy engines

### Implementation Details
- Directory Structure to Create - Complete file tree
- Database Strategy - Schema, sqlc, migrations
- Policy Data Management - OPA data with tenant overrides
- Authentication & Credential Management - Vault, OAuth, API keys
- Compliance Policy Code - HIPAA, PCI-DSS, SOC2 examples

### Operations
- Development Environment Configurations - Docker Compose, kind
- CI/CD Pipelines - GitHub Actions workflows
- Implementation Priorities - What to build and in what order

### Business Context
- Business Model - SaaS vs self-hosted, pricing tiers
- Success Metrics - Technical and business targets
- Post-MVP Roadmap - Future enhancements

---

## The Five Golden Rules (Quick Reference)

**These apply to ALL code. No exceptions.**

### Backend (Go)
1. IDs: `ulid.Make().String()` - NEVER `uuid.New()`
2. Multi-Tenant: `tenant_id` in EVERY query
3. Errors: Check ALL errors - NEVER `_`
4. Money: `int64` cents - NEVER float
5. Soft Delete: `deleted_at IS NULL` in ALL SELECTs

### Database (PostgreSQL)
1. All tables: `tenant_id`, `created_at`, `updated_at`, `deleted_at`
2. Primary keys: `CHAR(26)` for ULIDs
3. All queries: Include `deleted_at IS NULL`
4. Never query across tenants

### OPA Policies
1. Always: `default allow := false`
2. Always verify `tenant_id`
3. Log all authorization decisions
4. Never expose cross-tenant data

### Frontend (Svelte)
1. State: Svelte 5 runes only
2. Types: Full TypeScript - never `any`
3. API: Always include tenant context
4. Errors: User-friendly messages

---

## Common Patterns

### Creating a New Feature (Full Stack)

```
1. Database
   └── db/migrations/000XX_add_feature.sql
   └── db/queries/feature.sql
   └── make sqlc-generate

2. Backend
   └── internal/api/rest/handlers/feature.go
   └── internal/api/rest/routes.go (register)

3. Policy (if authorization needed)
   └── policies/feature/access.rego
   └── policies/tests/feature_test.rego

4. Frontend
   └── web-ui/src/routes/feature/+page.svelte
   └── web-ui/src/lib/api/feature.ts
```

### Adding a Compliance Policy

```
1. Policy file
   └── policies/compliance/<framework>/<rule>.rego

2. Policy data (defaults)
   └── policies/data/<framework>/<config>.json

3. Tests
   └── policies/tests/<framework>_<rule>_test.rego

4. Documentation
   └── Update docs/policies/writing-policies.md
```
