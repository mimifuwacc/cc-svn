#!/bin/bash
# Create a new workspace for parallel development

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
REPO_PATH="$PROJECT_ROOT/.svn-repo"
WORKSPACES_PATH="$PROJECT_ROOT/workspaces"
STATE_FILE="$PROJECT_ROOT/.workspace-state.json"

if [ -z "$1" ]; then
    echo "ERROR: Usage: $0 <workspace-name> [description]"
    echo ""
    echo "Example: $0 feature-user-auth 'Add user authentication'"
    exit 1
fi

WORKSPACE_NAME="$1"
DESCRIPTION="${2:-No description provided}"
BRANCH_URL="file://$REPO_PATH/branches/$WORKSPACE_NAME"
WORKSPACE_PATH="$WORKSPACES_PATH/$WORKSPACE_NAME"

echo "Creating workspace: $WORKSPACE_NAME"
echo "Description: $DESCRIPTION"
echo ""

# Validate workspace name (no spaces, special chars)
if [[ ! "$WORKSPACE_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "ERROR: Invalid workspace name. Use only letters, numbers, hyphens, and underscores."
    exit 1
fi

# Check if workspace already exists
if [ -d "$WORKSPACE_PATH" ]; then
    echo "WARNING: Workspace already exists: $WORKSPACE_PATH"
    echo "Skipping creation"
    exit 0
fi

# Ensure repository exists
if [ ! -d "$REPO_PATH" ]; then
    echo "ERROR: SVN repository not found at $REPO_PATH"
    echo "Run init_repo.sh first"
    exit 1
fi

# Create branches directory if it doesn't exist
echo "Ensuring branches directory exists"
svn mkdir "file://$REPO_PATH/branches" -m "Create branches directory" 2>/dev/null || echo "Branches directory already exists"

# Create branch using cheap copy
echo "Creating branch (instant operation)"
svn copy "file://$REPO_PATH/trunk" "$BRANCH_URL" \
    -m "Create workspace for: $DESCRIPTION"

# Checkout the workspace
echo "Checking out workspace to: $WORKSPACE_PATH"
svn checkout "$BRANCH_URL" "$WORKSPACE_PATH"

# Update state file
echo "Updating workspace state"
if [ -f "$STATE_FILE" ]; then
    # Use Python to update JSON
    python3 - << EOF
import json
from datetime import datetime

with open('$STATE_FILE', 'r') as f:
    state = json.load(f)

state['workspaces']['$WORKSPACE_NAME'] = {
    'created': datetime.utcnow().isoformat() + 'Z',
    'status': 'active',
    'description': '$DESCRIPTION'
}

with open('$STATE_FILE', 'w') as f:
    json.dump(state, f, indent=2)
EOF
else
    echo "WARNING: State file not found, creating new one"
    cat > "$STATE_FILE" << EOF
{
  "version": "1.0",
  "repository_path": "$REPO_PATH",
  "workspaces": {
    "$WORKSPACE_NAME": {
      "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
      "status": "active",
      "description": "$DESCRIPTION"
    }
  }
}
EOF
fi

echo ""
echo "Workspace created successfully!"
echo ""
echo "Workspace: $WORKSPACE_PATH"
echo "Branch: $BRANCH_URL"
echo ""
echo "Start working in: cd $WORKSPACE_PATH"
echo "Commit changes: svn commit -m 'Your message'"
