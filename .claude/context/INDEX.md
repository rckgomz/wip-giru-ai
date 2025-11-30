# Giru Context Index

Quick navigation to all context files for AI-assisted development.

## Core Documents

| Document | Purpose | When to Read |
|----------|---------|--------------|
| [CLAUDE.md](../../CLAUDE.md) | AI instructions, golden rules | Always first |
| [SCAFFOLD.md](../../SCAFFOLD.md) | Full project specification | Before any implementation |
| [AI_WORKFLOW.md](../AI_WORKFLOW.md) | Development workflow | Starting new tasks |

## Agent Profiles

Located in `.claude/agents/`:

| Agent | Domain | Use For |
|-------|--------|---------|
| [backend-architect](../agents/backend-architect.md) | Go services | API endpoints, business logic |
| [database-optimizer](../agents/database-optimizer.md) | PostgreSQL | Schema, queries, migrations |
| [policy-engineer](../agents/policy-engineer.md) | OPA/Rego | Authorization policies |
| [envoy-specialist](../agents/envoy-specialist.md) | Envoy proxy | Gateway configuration |
| [frontend-developer](../agents/frontend-developer.md) | Svelte/TS | Web UI components |
| [security-auditor](../agents/security-auditor.md) | Security | Code review, audits |
| [test-automator](../agents/test-automator.md) | Testing | Unit, integration tests |
| [mcp-integration](../agents/mcp-integration.md) | MCP protocol | Server connections |
| [devops-engineer](../agents/devops-engineer.md) | Infrastructure | Docker, CI/CD |
| [documentation-writer](../agents/documentation-writer.md) | Docs | API docs, guides |
| [code-reviewer](../agents/code-reviewer.md) | Quality | Code review |

## Architecture Decision Records

Located in `.claude/context/architecture/`:

| Document | Purpose | When to Read |
|----------|---------|--------------|
| [SCAFFOLD-INDEX.md](architecture/SCAFFOLD-INDEX.md) | Navigate SCAFFOLD.md by task | Finding specific implementation details |
| [ADR-001](architecture/ADR-001-identity-access-management.md) | Zitadel for Enterprise IAM, API keys for Community | Accepted |

## Context by Domain

### Backend Development
- `agents/PRE-FLIGHT-CHECKLIST.md` - Pre-coding checklist
- `SCAFFOLD.md#core-concepts` - Architecture overview
- `TECH_STACK.md` - Technology decisions

### Database
- `SCAFFOLD.md#database-strategy` - Schema patterns
- `db/migrations/` - Existing migrations
- `db/queries/` - sqlc query patterns

### Authorization
- `SCAFFOLD.md#opa-policy-engine` - Policy architecture
- `policies/` - Existing policies
- `policies/data/` - Policy data files

### Frontend
- `SCAFFOLD.md#web-ui-strategy` - UI architecture
- `web/src/lib/` - Component library
- `web/src/routes/` - Page routes

### MCP Integration
- `MCP_PROTOCOL_RESEARCH.md` - Protocol details
- `internal/mcp/` - MCP implementation

## Quick Reference

### The Five Golden Rules

**Backend (Go)**
1. IDs: `ulid.Make().String()`
2. Queries: Always include `tenant_id`
3. Errors: Never ignore with `_`
4. Money: `int64` cents
5. SELECTs: Include `deleted_at IS NULL`

**Database**
1. Tables: `tenant_id`, timestamps, `deleted_at`
2. PKs: `CHAR(26)` for ULIDs
3. Soft delete in all queries
4. No cross-tenant access
5. Money: `DECIMAL(10,2)`

## Task Management

- `../tasks/TASK_TEMPLATE.md` - Template for new tasks
- `../tasks/active/` - Current work
- `../tasks/backlog/` - Pending tasks
- `../tasks/completed/` - Finished tasks

## Hooks

Located in `.claude/hooks/`:
- `pre-task.sh` - Before starting implementation
- `pre-commit.sh` - Before committing code
- `post-task.sh` - After completing implementation
