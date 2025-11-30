#!/bin/bash
# Pre-commit hook: Validates code before committing
# Runs linting, formatting, and basic checks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Giru Pre-Commit Validation ==="

# Go checks (if Go files changed)
GO_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.go$' || true)
if [ -n "$GO_FILES" ]; then
    echo "Checking Go files..."

    # Format check
    if command -v gofmt &> /dev/null; then
        UNFORMATTED=$(gofmt -l $GO_FILES)
        if [ -n "$UNFORMATTED" ]; then
            echo "ERROR: Unformatted Go files:"
            echo "$UNFORMATTED"
            echo "Run: gofmt -w <file>"
            exit 1
        fi
    fi

    # Vet check
    if command -v go &> /dev/null; then
        echo "Running go vet..."
        go vet ./... || exit 1
    fi
fi

# Rego policy checks (if policy files changed)
REGO_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.rego$' || true)
if [ -n "$REGO_FILES" ]; then
    echo "Checking Rego policies..."

    if command -v opa &> /dev/null; then
        for file in $REGO_FILES; do
            echo "  Checking $file..."
            opa check "$file" || exit 1
        done
    else
        echo "WARNING: OPA not installed, skipping policy checks"
    fi
fi

# TypeScript/Svelte checks (if frontend files changed)
TS_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(ts|svelte)$' || true)
if [ -n "$TS_FILES" ]; then
    echo "Checking TypeScript/Svelte files..."

    if [ -f "$PROJECT_ROOT/web/package.json" ]; then
        cd "$PROJECT_ROOT/web"
        if command -v npm &> /dev/null; then
            npm run check 2>/dev/null || echo "WARNING: Frontend check failed"
        fi
        cd "$PROJECT_ROOT"
    fi
fi

# Check for secrets
echo "Checking for potential secrets..."
SECRETS_PATTERN='(password|secret|api_key|apikey|token|private_key)\s*[:=]\s*["\047][^"\047]{8,}'
if git diff --cached | grep -iE "$SECRETS_PATTERN" > /dev/null 2>&1; then
    echo "WARNING: Potential secrets detected in commit"
    echo "Please review your changes for hardcoded credentials"
fi

# Check for tenant isolation in SQL
SQL_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(sql|go)$' || true)
if [ -n "$SQL_FILES" ]; then
    echo "Checking tenant isolation in queries..."
    # Look for SELECT without tenant_id (basic heuristic)
    for file in $SQL_FILES; do
        if grep -E 'SELECT.*FROM' "$file" | grep -v 'tenant_id' | grep -v '_test\.go' > /dev/null 2>&1; then
            echo "WARNING: $file may have queries without tenant_id"
            echo "Please verify tenant isolation"
        fi
    done
fi

echo "=== Pre-Commit Validation Complete ==="
