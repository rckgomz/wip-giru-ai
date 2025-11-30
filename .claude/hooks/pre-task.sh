#!/bin/bash
# Pre-task hook: Runs before starting any implementation task
# Ensures context is loaded and prerequisites are met

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Giru Pre-Task Check ==="

# Check if PRE-FLIGHT-CHECKLIST exists
if [ ! -f "$PROJECT_ROOT/context/agents/PRE-FLIGHT-CHECKLIST.md" ]; then
    echo "WARNING: PRE-FLIGHT-CHECKLIST.md not found"
    echo "Please ensure context files are set up"
fi

# Check if CLAUDE.md exists
if [ ! -f "$PROJECT_ROOT/CLAUDE.md" ]; then
    echo "ERROR: CLAUDE.md not found - cannot proceed"
    exit 1
fi

# Check git status
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    echo "NOTE: You have uncommitted changes"
    git status --short
fi

# Display current branch
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
echo "Current branch: $BRANCH"

echo "=== Pre-Task Check Complete ==="
