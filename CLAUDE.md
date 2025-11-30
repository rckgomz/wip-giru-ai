# Giru MCP Gateway - Claude Code Instructions

This document configures Claude Code for AI-first development on the Giru MCP Gateway project.

---

## Quick Reference

```bash
# Development
task dev                    # Start full development environment
task dev:backend            # Backend only (Go)
task dev:ui                 # Frontend only (Svelte)
task test                   # Run all tests
task lint                   # Run all linters

# Database
task db:migrate             # Run migrations
task db:seed                # Load seed data
task db:reset               # Reset and reseed

# Policies
task policy:test            # Test OPA policies
task policy:fmt             # Format Rego files
```

---

## The Five Golden Rules

### Backend (Go) - MANDATORY

1. **IDs**: Use `ulid.Make().String()` - NEVER `uuid.New()`
2. **Multi-Tenant**: Include `tenant_id` in EVERY database query
3. **Errors**: Check ALL errors, NEVER ignore with `_`
4. **Money**: Use `int64` cents (DB: `DECIMAL(10,2)`), NEVER float
5. **Soft Delete**: Add `deleted_at IS NULL` in ALL SELECT queries

### Database (PostgreSQL/sqlc) - MANDATORY

1. **tenant_id**: REQUIRED in ALL queries (security critical)
2. **deleted_at IS NULL**: In ALL SELECT statements
3. **ULID**: For all primary keys, NEVER UUID
4. **Transactions**: For multi-table operations
5. **sqlc**: Type-safe queries only, NO raw SQL in Go code

### OPA Policies (Rego) - MANDATORY

1. **Package naming**: `package giru.<domain>.<policy>`
2. **Default deny**: Always `default allow := false`
3. **Test coverage**: 100% for all policies
4. **Input validation**: Validate all input fields
5. **Audit entries**: Generate audit entries for all decisions

### Frontend (Svelte) - MANDATORY

1. **TypeScript**: Strict mode, no `any` types
2. **Reactivity**: Use Svelte 5 runes (`$state`, `$derived`, `$effect`)
3. **API calls**: Use the generated API client, never raw fetch
4. **Error handling**: Show user-friendly errors, log technical details
5. **Loading states**: Always show loading indicators for async operations

---

## Mandatory Agent System

**CRITICAL**: Every task MUST use the appropriate agent based on domain.

### Agent Selection Matrix

| Task Type | Primary Agent | Secondary Agent |
|-----------|---------------|-----------------|
| Go backend, API design | `backend-architect` | `golang-expert` |
| Database, migrations, sqlc | `database-optimizer` | `backend-architect` |
| OPA policies, Rego | `policy-engineer` | `security-auditor` |
| Envoy configuration | `envoy-specialist` | `backend-architect` |
| Svelte UI | `frontend-developer` | `ui-ux-designer` |
| Testing (Go/Svelte/OPA) | `test-automator` | domain expert |
| Security, auth, multi-tenant | `security-auditor` | `backend-architect` |
| Performance optimization | `performance-engineer` | domain expert |
| DevOps, Docker, K8s | `deployment-engineer` | `devops-troubleshooter` |
| Multi-domain tasks | `project-orchestrator` | all relevant agents |
| Debugging, errors | `error-detective` | domain expert |
| Code review | `code-reviewer` | domain expert |
| Documentation | `context-manager` | domain expert |

### Working Modes

**Autonomous Mode** - Use when:
- Requirements are clear and specific
- Following established patterns
- Single-domain changes
- Bug fixes with clear reproduction

**Guided Mode** - Use when:
- Architectural decisions needed
- Requirements are unclear
- Multi-domain impact
- New patterns being established

---

## Project Architecture

### Three-Layer Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                     Layer 3: Control Plane                      │
│  Go + Fiber | REST API | xDS Server | PostgreSQL + Redis       │
├────────────────────────────────────────────────────────────────┤
│                     Layer 2: OPA Policy Engine                  │
│  Rego Policies | Authorization | Compliance | Audit            │
├────────────────────────────────────────────────────────────────┤
│                     Layer 1: Envoy Proxy                        │
│  Traffic Routing | Rate Limiting | TLS | Metrics               │
└────────────────────────────────────────────────────────────────┘
```

### Core Entities

- **Tenant**: Organization using Giru
- **Client**: AI agent or application consuming MCP tools
- **MCP Server**: Backend providing MCP tools
- **Subscription**: Access grant (Client → MCP Server)
- **MCP Tool**: Individual capability from a server

### Tech Stack

| Component | Technology | Notes |
|-----------|------------|-------|
| Control Plane | Go 1.21+ / Fiber | High-performance HTTP |
| Database | PostgreSQL 15+ / pgx / sqlc | Type-safe queries |
| Cache | Redis 7+ | Rate limiting, sessions |
| Proxy | Envoy 1.28+ | Dynamic xDS config |
| Policy | OPA / Rego | Stateless decisions |
| Secrets | HashiCorp Vault | Default, pgcrypto fallback |
| UI | Svelte 5 / SvelteKit 2 | Enterprise edition |
| Build | Taskfile | NOT Make |

---

## Directory Structure

```
giru/
├── CLAUDE.md                    # This file
├── SCAFFOLD.md                  # Full project specification
├── AI_WORKFLOW.md               # Development workflow
├── Taskfile.yml                 # Build automation (NOT Makefile)
│
├── .claude/
│   ├── settings.json            # Claude Code settings
│   ├── agents/                  # Agent profiles (15+)
│   └── hooks/                   # Automation hooks
│
├── context/
│   ├── INDEX.md                 # Navigation index
│   ├── agents/                  # Agent-specific context
│   │   └── PRE-FLIGHT-CHECKLIST.md  # MANDATORY before coding
│   ├── domains/                 # Business domain docs
│   ├── architecture/            # Technical decisions
│   ├── patterns/                # Implementation patterns
│   └── integrations/            # External service docs
│
├── tasks/
│   ├── active/                  # Currently working on
│   ├── completed/               # Archived with summary
│   └── backlog/                 # Future work
│
├── cmd/                         # Entry points
├── internal/                    # Private code
├── pkg/                         # Public libraries
├── db/                          # Database (migrations, queries)
├── policies/                    # OPA Rego policies
├── configs/                     # Envoy, OPA configs
├── deployments/                 # Docker, K8s, Helm
├── web-ui/                      # Svelte UI (Community)
└── tests/                       # Integration, performance
```

---

## Context Loading Strategy

### Before ANY Code

1. **ALWAYS** read `context/agents/PRE-FLIGHT-CHECKLIST.md`
2. Load agent-specific context based on task domain
3. Reference architecture decisions for design choices
4. Check existing patterns before creating new ones

### Context Priority

```
1. PRE-FLIGHT-CHECKLIST.md (mandatory)
2. Agent context file (based on task)
3. Domain documentation (if business logic)
4. Architecture decisions (if design choices)
5. Pattern library (if implementing features)
```

---

## Code Patterns

### Go Backend Pattern

```go
// Package naming: internal/api/rest/handlers/
package handlers

// Handler function with proper error handling
func (h *Handler) CreateSubscription(c *fiber.Ctx) error {
    // 1. Parse and validate input
    var req CreateSubscriptionRequest
    if err := c.BodyParser(&req); err != nil {
        return fiber.NewError(fiber.StatusBadRequest, "invalid request body")
    }
    
    // 2. Get tenant from context (MANDATORY)
    tenantID := c.Locals("tenant_id").(string)
    
    // 3. Business logic with transaction
    sub, err := h.db.WithTx(c.Context(), func(tx pgx.Tx) (*Subscription, error) {
        // All queries include tenant_id
        return h.subscriptionService.Create(c.Context(), tx, tenantID, &req)
    })
    if err != nil {
        // Log technical details, return user-friendly error
        h.logger.Error("create subscription failed", "error", err, "tenant_id", tenantID)
        return fiber.NewError(fiber.StatusInternalServerError, "failed to create subscription")
    }
    
    return c.Status(fiber.StatusCreated).JSON(sub)
}
```

### sqlc Query Pattern

```sql
-- db/queries/subscriptions.sql

-- name: CreateSubscription :one
INSERT INTO subscriptions (
    id, tenant_id, client_id, mcp_server_id, name, status
) VALUES (
    @id, @tenant_id, @client_id, @mcp_server_id, @name, 'active'
) RETURNING *;

-- name: GetSubscription :one
SELECT * FROM subscriptions
WHERE id = @id 
  AND tenant_id = @tenant_id  -- MANDATORY
  AND deleted_at IS NULL      -- MANDATORY
LIMIT 1;

-- name: ListSubscriptionsByClient :many
SELECT * FROM subscriptions
WHERE client_id = @client_id
  AND tenant_id = @tenant_id  -- MANDATORY
  AND deleted_at IS NULL      -- MANDATORY
ORDER BY created_at DESC;
```

### OPA Policy Pattern

```rego
# policies/subscriptions/access.rego
package giru.subscriptions.access

import future.keywords.if
import future.keywords.in

default allow := false

# Allow if subscription is active and within time window
allow if {
    subscription_active
    within_time_window
    parameters_valid
}

subscription_active if {
    input.subscription.status == "active"
}

within_time_window if {
    now := time.now_ns()
    input.subscription.starts_at <= now
    input.subscription.expires_at >= now
}

parameters_valid if {
    # Validate all required parameters
    input.client_id
    input.tool_name
}

# Generate audit entry for all decisions
audit_entry[entry] if {
    entry := {
        "timestamp": time.now_ns(),
        "client_id": input.client_id,
        "tool_name": input.tool_name,
        "allowed": allow,
        "reason": decision_reason,
    }
}

decision_reason := "subscription_active" if allow
decision_reason := "subscription_inactive" if not subscription_active
decision_reason := "outside_time_window" if not within_time_window
decision_reason := "invalid_parameters" if not parameters_valid
```

### Svelte Component Pattern

```svelte
<!-- web-ui/src/routes/subscriptions/+page.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import { api } from '$lib/api/client';
  import { LoadingSpinner, ErrorAlert, DataTable } from '$lib/components';
  import type { Subscription } from '$lib/types';

  let subscriptions = $state<Subscription[]>([]);
  let loading = $state(true);
  let error = $state<string | null>(null);

  onMount(async () => {
    try {
      subscriptions = await api.subscriptions.list();
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load subscriptions';
      console.error('Subscription load error:', e);
    } finally {
      loading = false;
    }
  });
</script>

{#if loading}
  <LoadingSpinner />
{:else if error}
  <ErrorAlert message={error} />
{:else}
  <DataTable data={subscriptions} columns={columns} />
{/if}
```

---

## Security Patterns (CRITICAL)

### Multi-Tenancy Enforcement

```go
// EVERY database query MUST include tenant_id
// This is NON-NEGOTIABLE for security

// ✅ CORRECT
sub, err := store.GetSubscription(ctx, db.GetSubscriptionParams{
    ID:       subID,
    TenantID: tenantID,  // REQUIRED
})

// ❌ WRONG - SECURITY VIOLATION
sub, err := store.GetSubscriptionByID(ctx, subID)  // Missing tenant_id
```

### ULID vs UUID

```go
// ✅ CORRECT - Use ULID
import "github.com/oklog/ulid/v2"

id := ulid.Make().String()

// ❌ WRONG - Never use UUID
import "github.com/google/uuid"

id := uuid.New().String()  // VIOLATION
```

### Credential Handling

```go
// ✅ CORRECT - Use Vault (default)
token, err := h.vault.GetOAuthToken(ctx, server.VaultSecretPath)

// ⚠️ FALLBACK ONLY - pgcrypto (when Vault unavailable)
// Must be explicitly configured via GIRU_CREDENTIAL_STORE=pgcrypto
```

---

## Testing Requirements

### Coverage Targets

| Component | Minimum Coverage |
|-----------|------------------|
| Go handlers | 80% |
| Go services | 90% |
| OPA policies | 100% |
| Svelte components | 70% |
| Integration tests | Critical paths |

### Test Commands

```bash
# All tests
task test

# Go tests with coverage
task test:go

# OPA policy tests
task policy:test

# Svelte tests
task test:ui

# Integration tests
task test:integration
```

---

## Commit and Branch Conventions

### Branch Naming

```bash
feat/giru-123-subscription-api     # New feature
fix/giru-456-rate-limit-bug        # Bug fix
policy/giru-789-hipaa-compliance   # OPA policy
ui/giru-012-dashboard              # UI changes
docs/giru-345-api-reference        # Documentation
test/giru-678-integration          # Test improvements
chore/giru-901-dependencies        # Maintenance
```

### Commit Message Format

```bash
<type>(<scope>): <description>

# Examples:
feat(api): add subscription CRUD endpoints
fix(policy): correct HIPAA field validation
policy(compliance): add PCI-DSS cardholder data rules
ui(dashboard): implement metrics visualization
test(integration): add MCP routing tests
docs(api): update OpenAPI spec for v1.1
chore(deps): upgrade Fiber to v2.52
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `policy`: OPA policy changes
- `ui`: Frontend changes
- `test`: Test changes
- `docs`: Documentation
- `chore`: Maintenance
- `refactor`: Code refactoring
- `perf`: Performance improvement
- `security`: Security fix

---

## Pre-Commit Checklist

Before committing, ensure:

- [ ] `task lint` passes with 0 errors
- [ ] `task test` passes
- [ ] `task policy:test` passes (if policies changed)
- [ ] All queries include `tenant_id`
- [ ] All queries include `deleted_at IS NULL`
- [ ] No UUID usage (only ULID)
- [ ] No hardcoded strings in Svelte (if applicable)
- [ ] Error handling is complete (no ignored errors)
- [ ] Commit message follows convention

---

## References

- **Full Specification**: [SCAFFOLD.md](./SCAFFOLD.md)
- **Development Workflow**: [AI_WORKFLOW.md](./AI_WORKFLOW.md)
- **Context Index**: [context/INDEX.md](./context/INDEX.md)
- **Pre-Flight Checklist**: [context/agents/PRE-FLIGHT-CHECKLIST.md](./context/agents/PRE-FLIGHT-CHECKLIST.md)

---

## MCP Server Configuration

```json
// .mcp.json (if using MCP tools for development)
{
  "mcpServers": {
    "context": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-filesystem", "./context"]
    }
  }
}
```

---

*Last updated: 2024*
