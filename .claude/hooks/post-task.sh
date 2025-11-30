#!/bin/bash
# Post-task hook: Runs after completing an implementation task
# Validates the implementation and prepares for review

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Giru Post-Task Validation ==="

# Run tests if available
if [ -f "$PROJECT_ROOT/go.mod" ]; then
    echo "Running Go tests..."
    cd "$PROJECT_ROOT"
    go test -race -short ./... || {
        echo "ERROR: Tests failed"
        exit 1
    }
fi

# Check for TODO/FIXME comments
echo "Checking for unresolved TODOs..."
TODOS=$(grep -rn "TODO\|FIXME\|XXX" --include="*.go" --include="*.ts" --include="*.svelte" "$PROJECT_ROOT" 2>/dev/null | grep -v "_test.go" | head -10 || true)
if [ -n "$TODOS" ]; then
    echo "Found TODO/FIXME comments:"
    echo "$TODOS"
    echo ""
fi

# Verify no debug code
echo "Checking for debug code..."
DEBUG_PATTERNS='fmt\.Print|console\.log|debugger'
DEBUG_FOUND=$(grep -rn "$DEBUG_PATTERNS" --include="*.go" --include="*.ts" --include="*.svelte" "$PROJECT_ROOT" 2>/dev/null | grep -v "_test" | head -5 || true)
if [ -n "$DEBUG_FOUND" ]; then
    echo "WARNING: Debug code found:"
    echo "$DEBUG_FOUND"
fi

# Check coverage (if coverage file exists)
if [ -f "$PROJECT_ROOT/coverage.out" ]; then
    echo "Checking test coverage..."
    COVERAGE=$(go tool cover -func=coverage.out | grep total | awk '{print $3}' | tr -d '%')
    if (( $(echo "$COVERAGE < 80" | bc -l) )); then
        echo "WARNING: Coverage is below 80% ($COVERAGE%)"
    else
        echo "Coverage: $COVERAGE%"
    fi
fi

echo ""
echo "=== Post-Task Checklist ==="
echo "[ ] All tests pass"
echo "[ ] No hardcoded secrets"
echo "[ ] Tenant isolation verified"
echo "[ ] Error handling complete"
echo "[ ] Documentation updated"
echo ""
echo "=== Post-Task Validation Complete ==="
