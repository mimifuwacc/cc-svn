#!/bin/bash
# Merge a workspace back to trunk

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
    echo "ERROR: Usage: $0 <workspace-name>"
    echo ""
    echo "Example: $0 feature-user-auth"
    exit 1
fi

WORKSPACE_NAME="$1"
WORKSPACE_PATH="$WORKSPACES_PATH/$WORKSPACE_NAME"
BRANCH_URL="file://$REPO_PATH/branches/$WORKSPACE_NAME"

echo "Merging workspace: $WORKSPACE_NAME"
echo ""

# Check if workspace exists
if [ ! -d "$WORKSPACE_PATH" ]; then
    echo "ERROR: Workspace not found: $WORKSPACE_PATH"
    exit 1
fi

# Show changes
echo "Changes to be merged:"
echo "===================="
cd "$WORKSPACE_PATH"
# Use svn diff to show what changed in the workspace
svn status
echo ""
echo "Showing diff of workspace changes:"
svn diff
echo ""

# Ask for confirmation
read -p "Merge these changes to trunk? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Merge cancelled"
    exit 0
fi

# Merge to trunk
echo "Merging to trunk..."
cd "$PROJECT_ROOT/trunk"

# Update trunk first
echo "Updating trunk..."
svn update

# Merge the branch
svn merge "$BRANCH_URL"

# Commit the merge
echo "Committing merge..."
svn commit -m "Merge workspace: $WORKSPACE_NAME"

# Delete workspace directory
echo "Removing workspace directory..."
rm -rf "$WORKSPACE_PATH"

# Delete branch
echo "Deleting branch..."
svn delete "$BRANCH_URL" -m "Remove merged branch: $WORKSPACE_NAME"

# Update state file
echo "Updating state file..."
python3 - << EOF
import json

with open('$STATE_FILE', 'r') as f:
    state = json.load(f)

if '$WORKSPACE_NAME' in state['workspaces']:
    del state['workspaces']['$WORKSPACE_NAME']

with open('$STATE_FILE', 'w') as f:
    json.dump(state, f, indent=2)
EOF

echo ""
echo "Workspace merged successfully!"
echo "Workspace directory removed: $WORKSPACE_PATH"
