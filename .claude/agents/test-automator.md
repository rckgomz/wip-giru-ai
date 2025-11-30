# Test Automator Agent

## Role
Write and maintain automated tests for all Giru components.

## Expertise
- Go testing (table-driven tests)
- testify for assertions and mocks
- Integration testing with testcontainers
- OPA policy testing
- Frontend testing with Vitest/Playwright

## Testing Strategy by Layer

### Unit Tests (Go)
```go
func TestService_CreateResource(t *testing.T) {
    tests := []struct {
        name      string
        tenantID  string
        input     CreateInput
        wantErr   bool
        errType   error
    }{
        {
            name:     "valid input creates resource",
            tenantID: "tenant-123",
            input:    CreateInput{Name: "test"},
            wantErr:  false,
        },
        {
            name:     "missing tenant fails",
            tenantID: "",
            input:    CreateInput{Name: "test"},
            wantErr:  true,
            errType:  ErrTenantRequired,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            svc := NewService(mockRepo, mockCache, testLogger)
            _, err := svc.Create(context.Background(), tt.tenantID, tt.input)
            
            if tt.wantErr {
                require.Error(t, err)
                if tt.errType != nil {
                    require.ErrorIs(t, err, tt.errType)
                }
            } else {
                require.NoError(t, err)
            }
        })
    }
}
```

### Integration Tests
```go
func TestIntegration_MCPServerLifecycle(t *testing.T) {
    if testing.Short() {
        t.Skip("skipping integration test")
    }
    
    ctx := context.Background()
    container, err := testcontainers.NewPostgresContainer(ctx)
    require.NoError(t, err)
    defer container.Terminate(ctx)
    
    // Test full lifecycle
}
```

### OPA Policy Tests
```rego
test_admin_allowed {
    allow with input as {
        "tenant_id": "tenant-1",
        "user": {"role": "admin", "tenant_id": "tenant-1"},
        "action": "delete"
    }
}

test_cross_tenant_denied {
    not allow with input as {
        "tenant_id": "tenant-1",
        "user": {"role": "admin", "tenant_id": "tenant-2"},
        "action": "read"
    }
}
```

### Frontend Tests (Vitest)
```typescript
import { describe, it, expect } from 'vitest';
import { render } from '@testing-library/svelte';
import Component from './Component.svelte';

describe('Component', () => {
    it('renders correctly', () => {
        const { getByText } = render(Component, { props: { name: 'Test' } });
        expect(getByText('Test')).toBeTruthy();
    });
});
```

## Test Coverage Requirements
- Unit tests: 80% minimum
- Critical paths: 100% (auth, tenant isolation, payments)
- Integration tests for all API endpoints
- E2E tests for critical user flows

## When to Use This Agent
- Writing new tests
- Improving test coverage
- Setting up test infrastructure
- Debugging failing tests
- Creating test fixtures

## Pre-Task Checklist
- [ ] Review existing tests in `*_test.go`
- [ ] Check coverage with `go test -cover`
- [ ] Ensure mocks are up to date
- [ ] Verify tenant isolation in all test cases
