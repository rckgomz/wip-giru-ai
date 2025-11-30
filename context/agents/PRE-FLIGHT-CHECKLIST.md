# PRE-FLIGHT CHECKLIST

**MANDATORY: Complete this checklist before any implementation task.**

## 1. Context Loading

### Required Reading
- [ ] **CLAUDE.md** - The Five Golden Rules and agent matrix
- [ ] **SCAFFOLD.md** - Relevant sections for current task
- [ ] **AI_WORKFLOW.md** - Workflow phases and conventions

### Domain-Specific Context
Load based on task domain:

| Domain | Required Files |
|--------|---------------|
| Backend/Go | SCAFFOLD.md#core-concepts, TECH_STACK.md |
| Database | SCAFFOLD.md#database-strategy, db/migrations/ |
| OPA/Policies | SCAFFOLD.md#opa-policy-engine, policies/ |
| Envoy | SCAFFOLD.md#envoy-gateway, envoy/ |
| Frontend | SCAFFOLD.md#web-ui-strategy, web/src/ |
| MCP | MCP_PROTOCOL_RESEARCH.md, internal/mcp/ |

## 2. The Five Golden Rules Reminder

### Backend (Go) - CRITICAL
```
1. IDs: ulid.Make().String() - NEVER uuid.New()
2. Multi-Tenant: tenant_id in EVERY query
3. Errors: Check ALL errors - NEVER ignore with _
4. Money: int64 cents - NEVER float
5. Soft Delete: deleted_at IS NULL in ALL SELECTs
```

### Database - CRITICAL
```
1. ALL tables: tenant_id, created_at, updated_at, deleted_at
2. Primary keys: CHAR(26) for ULIDs
3. ALL SELECTs: Include deleted_at IS NULL
4. NEVER query across tenants without authorization
5. Money: DECIMAL(10,2), cents in application
```

### OPA Policies - CRITICAL
```
1. ALWAYS: default allow := false
2. EVERY policy: Verify tenant_id matches
3. Role hierarchy: admin > manager > user
4. Audit: Log all authorization decisions
5. Isolation: Never expose cross-tenant data
```

### Frontend (Svelte) - CRITICAL
```
1. State: Svelte 5 runes ($state, $derived, $effect)
2. Types: Full TypeScript - NEVER any
3. API: Include tenant context header
4. Auth: Check on EVERY protected route
5. Errors: User-friendly messages, log technical details
```

## 3. Task Understanding

Before implementing, verify:

- [ ] **Clear Objective**: What exactly needs to be done?
- [ ] **Acceptance Criteria**: How will success be measured?
- [ ] **Scope Boundaries**: What is NOT included?
- [ ] **Dependencies**: What must exist first?
- [ ] **Affected Components**: What will this change impact?

## 4. Existing Code Review

- [ ] Search for similar implementations in codebase
- [ ] Review related tests for expected behavior
- [ ] Check for existing utilities/helpers to reuse
- [ ] Identify patterns used in similar code

## 5. Security Considerations

- [ ] Will this handle user input? → Validate all inputs
- [ ] Will this access data? → Verify tenant isolation
- [ ] Will this store secrets? → Use Vault/encrypted storage
- [ ] Will this expose data? → Check authorization
- [ ] Will this create logs? → No sensitive data in logs

## 6. Implementation Plan

Create mental model before coding:

1. **Entry Point**: Where does the request come in?
2. **Data Flow**: How does data move through the system?
3. **Validation**: Where are inputs validated?
4. **Business Logic**: Where is the core logic?
5. **Persistence**: How is data stored/retrieved?
6. **Response**: What is returned to the caller?

## 7. Test Strategy

Plan tests before implementing:

- [ ] **Unit Tests**: Isolated function tests
- [ ] **Integration Tests**: Component interaction tests
- [ ] **Tenant Isolation Tests**: Verify no cross-tenant access
- [ ] **Error Cases**: Test failure scenarios
- [ ] **Edge Cases**: Boundary conditions

## 8. Ready Check

Final verification before starting:

| Check | Status |
|-------|--------|
| Context loaded | [ ] |
| Golden rules reviewed | [ ] |
| Task understood | [ ] |
| Existing code reviewed | [ ] |
| Security considered | [ ] |
| Implementation planned | [ ] |
| Test strategy defined | [ ] |

---

**Once all checks pass, proceed with implementation following AI_WORKFLOW.md phases.**
