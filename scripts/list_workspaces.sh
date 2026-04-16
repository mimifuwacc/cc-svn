#!/bin/bash
# List all active workspaces

set -e

# Find project root (look for .svn-repo directory)
CURRENT_DIR="$(pwd)"
while [[ ! -d "$CURRENT_DIR/.svn-repo" && "$CURRENT_DIR" != "/" ]]; do
    CURRENT_DIR="$(dirname "$CURRENT_DIR")"
done

if [[ "$CURRENT_DIR" == "/" ]]; then
    echo "ERROR: Could not find project root (no .svn-repo directory found)"
    exit 1
fi

PROJECT_ROOT="$CURRENT_DIR"
STATE_FILE="$PROJECT_ROOT/.workspace-state.json"
WORKSPACES_PATH="$PROJECT_ROOT/workspaces"

echo "Active Workspaces"
echo "===================="
echo ""

# Check if state file exists
if [ -f "$STATE_FILE" ]; then
    python3 - << EOF
import json
from datetime import datetime

with open('$STATE_FILE', 'r') as f:
    state = json.load(f)

workspaces = state.get('workspaces', {})

if not workspaces:
    print("No active workspaces found")
else:
    for name, info in workspaces.items():
        status = info.get('status', 'unknown')
        desc = info.get('description', 'No description')
        created = info.get('created', 'Unknown')
        print(f"[{name}]")
        print(f"  Status: {status}")
        print(f"  Description: {desc}")
        print(f"  Created: {created}")
        print()
EOF
else
    echo "WARNING: State file not found"
fi

# Also list workspace directories
echo "Workspace directories:"
if [ -d "$WORKSPACES_PATH" ]; then
    for dir in "$WORKSPACES_PATH"/*/; do
        if [ -d "$dir" ]; then
            name=$(basename "$dir")
            echo "  $dir"
        fi
    done
else
    echo "  (No workspaces directory found)"
fi

echo ""
echo "Repository: $PROJECT_ROOT/.svn-repo"
