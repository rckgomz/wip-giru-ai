# Giru - AI-First Development Workflow

This document defines the workflow for AI-assisted development on the Giru MCP Gateway project.

---

## Overview

Giru uses a **mandatory agent-driven development** approach where:
- Every task uses the appropriate AI agent based on domain
- Context is loaded before any coding begins
- Tasks are tracked in structured markdown files
- All work follows established patterns and conventions

---

## Workflow Phases

### Phase 1: Task Definition

1. **Create task file** in `.claude/tasks/active/`
2. **Define scope** using the task template
3. **Select agents** based on domain
4. **Choose working mode** (Autonomous or Guided)

### Phase 2: Context Loading

1. **Read `.claude/context/agents/PRE-FLIGHT-CHECKLIST.md`** (mandatory)
2. **Load agent context** for selected agent(s)
3. **Review domain documentation** if business logic involved
4. **Check existing patterns** before implementing

### Phase 3: Implementation

1. **Follow The Five Golden Rules** (from CLAUDE.md)
2. **Use agent-specific patterns** from context files
3. **Update task file** with progress
4. **Mark acceptance criteria** as completed

### Phase 4: Validation

1. **Run linters**: `task lint`
2. **Run tests**: `task test`
3. **Security check**: Verify tenant_id, ULID, deleted_at
4. **Code review** (if multi-domain or architectural)

### Phase 5: Completion

1. **Add implementation summary** to task file
2. **Move task** to `.claude/tasks/completed/`
3. **Update related documentation** if patterns changed
4. **Commit with proper message format**

---

## Working Modes

### Autonomous Mode

Use when requirements are clear and patterns are established.

**Characteristics:**
- Single-domain tasks
- Clear acceptance criteria
- Existing patterns to follow
- No architectural decisions needed

**Process:**
1. Load context
2. Implement following patterns
3. Validate
4. Complete

### Guided Mode

Use when decisions need to be made or requirements are unclear.

**Characteristics:**
- Multi-domain tasks
- Architectural decisions required
- New patterns being established
- Complex integrations

**Process:**
1. Load context
2. Propose approach
3. Get feedback/approval
4. Implement in phases
5. Review at each phase
6. Complete with documentation

---

## Agent Selection

### Domain Detection

When analyzing a task, identify all relevant domains:

| Domain | Keywords | Primary Agent |
|--------|----------|---------------|
| Backend | Go, API, handler, service | `backend-architect` |
| Database | SQL, migration, query, sqlc | `database-optimizer` |
| Policy | OPA, Rego, authorization, compliance | `policy-engineer` |
| Proxy | Envoy, routing, xDS, rate limit | `envoy-specialist` |
| Frontend | Svelte, UI, component, page | `frontend-developer` |
| Testing | test, coverage, mock | `test-automator` |
| Security | auth, tenant, permission | `security-auditor` |
| Performance | optimize, latency, throughput | `performance-engineer` |
| DevOps | Docker, K8s, deploy, CI/CD | `deployment-engineer` |

### Multi-Domain Tasks

When a task spans multiple domains:

1. Use `project-orchestrator` as primary agent
2. Load context for ALL relevant domains
3. Work in Guided Mode
4. Break into sub-tasks by domain
5. Coordinate integration points

---

## Task File Structure

### Template

```markdown
# Task: [Title]

## Metadata
- **ID**: GIRU-XXX
- **Type**: Feature | Bug | Tech Debt | Policy | Security
- **Priority**: Critical | High | Medium | Low
- **Working Mode**: Autonomous | Guided
- **Primary Agent**: [agent-name]
- **Secondary Agents**: [agent-names]

## Problem Statement

[Clear description of what needs to be done and why]

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Technical Context

- **Affected Domains**: [list]
- **Affected Files**: [list or patterns]
- **Dependencies**: [external services, packages]
- **Performance Requirements**: [if applicable]

## Implementation Plan

### Phase 1: [Name]
- [ ] Step 1
- [ ] Step 2

### Phase 2: [Name]
- [ ] Step 1
- [ ] Step 2

## Notes

[Any additional context, links, or considerations]

---

## Implementation Summary (added at completion)

### What Was Done
[Summary of changes]

### Files Changed
- `path/to/file.go` - [description]

### Testing
- [x] Unit tests added/updated
- [x] Integration tests (if applicable)
- [x] Policy tests (if applicable)

### Security Verification
- [x] tenant_id in all queries
- [x] ULID for IDs
- [x] deleted_at checks

### Notes for Future
[Any follow-up items or considerations]
```

### Example: Feature Task

```markdown
# Task: Implement Subscription API Endpoints

## Metadata
- **ID**: GIRU-042
- **Type**: Feature
- **Priority**: High
- **Working Mode**: Autonomous
- **Primary Agent**: backend-architect
- **Secondary Agents**: database-optimizer, test-automator

## Problem Statement

Clients need to create, read, update, and delete subscriptions through the REST API. This enables AI agents to be granted access to MCP servers and their tools.

## Acceptance Criteria

- [ ] POST /api/v1/subscriptions creates subscription
- [ ] GET /api/v1/subscriptions lists subscriptions for tenant
- [ ] GET /api/v1/subscriptions/:id returns single subscription
- [ ] PUT /api/v1/subscriptions/:id updates subscription
- [ ] DELETE /api/v1/subscriptions/:id soft-deletes subscription
- [ ] All endpoints require authentication
- [ ] All endpoints enforce tenant isolation
- [ ] OpenAPI spec updated
- [ ] Unit tests with 80%+ coverage

## Technical Context

- **Affected Domains**: Backend, Database
- **Affected Files**: 
  - `internal/api/rest/handlers/subscriptions.go`
  - `internal/api/rest/routes.go`
  - `db/queries/subscriptions.sql`
- **Dependencies**: Fiber, pgx, sqlc

## Implementation Plan

### Phase 1: Database Layer
- [ ] Add sqlc queries for CRUD operations
- [ ] Generate Go code with `task sqlc:generate`
- [ ] Test queries manually

### Phase 2: Handler Implementation
- [ ] Create handler struct with dependencies
- [ ] Implement Create handler
- [ ] Implement List handler
- [ ] Implement Get handler
- [ ] Implement Update handler
- [ ] Implement Delete handler
- [ ] Register routes

### Phase 3: Testing
- [ ] Write unit tests for each handler
- [ ] Test error cases
- [ ] Verify tenant isolation
- [ ] Check coverage

### Phase 4: Documentation
- [ ] Update OpenAPI spec
- [ ] Add curl examples
```

---

## Branch and Commit Workflow

### Starting a Task

```bash
# 1. Create feature branch
git checkout -b feat/giru-042-subscription-api

# 2. Create task file
touch tasks/active/GIRU-042-subscription-api.md

# 3. Load context and begin
```

### During Development

```bash
# Make atomic commits
git add -p
git commit -m "feat(api): add subscription create endpoint"

# Regular commits as you progress
git commit -m "feat(api): add subscription list endpoint"
git commit -m "test(api): add subscription handler tests"
```

### Completing a Task

```bash
# 1. Final validation
task lint
task test

# 2. Move task file
mv tasks/active/GIRU-042-subscription-api.md tasks/completed/

# 3. Create PR or merge
git push origin feat/giru-042-subscription-api
```

---

## Context Files Reference

### Agent Context Files

Located in `context/agents/`:

| File | Purpose |
|------|---------|
| `PRE-FLIGHT-CHECKLIST.md` | **MANDATORY** before any coding |
| `backend-context.md` | Go patterns, Fiber handlers |
| `database-context.md` | sqlc, migrations, PostgreSQL |
| `policy-context.md` | OPA, Rego patterns |
| `frontend-context.md` | Svelte patterns |
| `testing-context.md` | Test strategies |

### Domain Documentation

Located in `context/domains/`:

| File | Purpose |
|------|---------|
| `mcp-protocol.md` | MCP JSON-RPC details |
| `multi-tenancy.md` | Tenant isolation patterns |
| `subscriptions.md` | Subscription model |
| `credentials.md` | Vault/credential management |

### Architecture Decisions

Located in `context/architecture/`:

| File | Purpose |
|------|---------|
| `tech-stack.md` | Technology choices |
| `three-layer-arch.md` | Envoy/OPA/Control Plane |
| `database-design.md` | Schema decisions |
| `api-design.md` | REST API conventions |

### Implementation Patterns

Located in `context/patterns/`:

| File | Purpose |
|------|---------|
| `handler-pattern.md` | Fiber handler structure |
| `service-pattern.md` | Business logic layer |
| `repository-pattern.md` | Data access layer |
| `error-handling.md` | Error patterns |

---

## Validation Commands

### Before Commit

```bash
# Run all checks
task validate

# Or individually:
task lint           # All linters
task test           # All tests
task policy:test    # OPA policy tests
task fmt            # Format code
```

### Security Validation

```bash
# Check for UUID usage (should be empty)
grep -r "uuid.New" internal/

# Check tenant_id in queries (should be in ALL)
grep -r "tenant_id" db/queries/

# Check deleted_at in SELECT queries
grep -r "deleted_at IS NULL" db/queries/
```

---

## Common Workflows

### Adding a New API Endpoint

1. **Task file**: Create in `tasks/active/`
2. **Agent**: `backend-architect` + `database-optimizer`
3. **Context**: Load `backend-context.md`, `database-context.md`
4. **Implementation**:
   - Add sqlc query
   - Generate code
   - Create handler
   - Register route
   - Write tests
5. **Validation**: lint, test, security check

### Adding a New OPA Policy

1. **Task file**: Create in `tasks/active/`
2. **Agent**: `policy-engineer` + `security-auditor`
3. **Context**: Load `policy-context.md`
4. **Implementation**:
   - Create policy file
   - Add unit tests
   - Test with sample inputs
   - Document policy
5. **Validation**: `task policy:test`

### Adding a New UI Feature

1. **Task file**: Create in `tasks/active/`
2. **Agent**: `frontend-developer` + `ui-ux-designer`
3. **Context**: Load `frontend-context.md`
4. **Implementation**:
   - Create component
   - Add to route
   - Handle loading/error states
   - Write tests
5. **Validation**: `task test:ui`

### Debugging an Issue

1. **Agent**: `error-detective` + domain expert
2. **Context**: Load relevant domain context
3. **Process**:
   - Reproduce issue
   - Identify root cause
   - Create minimal fix
   - Add regression test
   - Verify fix

---

## Integration with Issue Tracking

### GitHub Issues

```markdown
# In task file
- **GitHub Issue**: #123
- **Related Issues**: #100, #115

# In commit
fix(api): resolve subscription timeout (#123)
```

### Linear (if used)

```markdown
# In task file
- **Linear ID**: GIRU-123
- **Linear URL**: https://linear.app/giru/issue/GIRU-123
```

---

## Tips for Effective AI-First Development

### DO

- Load context before starting
- Follow The Five Golden Rules
- Use appropriate agents for each domain
- Break complex tasks into phases
- Commit frequently with good messages
- Update task file as you progress
- Ask for clarification when uncertain

### DON'T

- Skip the PRE-FLIGHT-CHECKLIST
- Ignore linter warnings
- Write queries without tenant_id
- Use UUID instead of ULID
- Commit without running tests
- Leave task files incomplete
- Mix multiple concerns in one task

---

*Last updated: 2024*
