#!/bin/bash
# Initialize SVN repository for cc-svn workspace management

set -e

PROJECT_ROOT="$(pwd)"
# Convert to absolute paths to avoid '..' in SVN URLs
REPO_PATH="$(cd "$PROJECT_ROOT/.svn-repo" 2>/dev/null && echo "$(pwd)" || echo "$PROJECT_ROOT/.svn-repo")"
TRUNK_PATH="$PROJECT_ROOT/trunk"

echo "Initializing SVN repository for cc-svn..."

# Check if repository already exists
if [ -d "$REPO_PATH" ]; then
    echo "WARNING: Repository already exists at $REPO_PATH"
    echo "Skipping initialization"
    exit 0
fi

# Create repository
echo "Creating SVN repository at $REPO_PATH"
svnadmin create "$REPO_PATH"

# Create trunk directory structure
echo "Creating trunk directory structure"
mkdir -p "$REPO_PATH/trunk"

# Import trunk into repository
echo "Importing trunk to repository"
svn import "$REPO_PATH/trunk" "file://$REPO_PATH/trunk" -m "Initial trunk import"

# Checkout trunk
echo "Checking out trunk"
svn checkout "file://$REPO_PATH/trunk" "$TRUNK_PATH"

# Create workspaces directory
mkdir -p "$PROJECT_ROOT/workspaces"

# Create state file
cat > "$PROJECT_ROOT/.workspace-state.json" << EOF
{
  "version": "1.0",
  "repository_path": "$REPO_PATH",
  "workspaces": {},
  "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

echo ""
echo "SVN repository initialized successfully!"
echo ""
echo "Repository: $REPO_PATH"
echo "Trunk: $TRUNK_PATH"
echo "Workspaces: $PROJECT_ROOT/workspaces"
echo ""
echo "Ready to create workspaces!"
echo ""
echo "Next steps:"
echo "  1. Copy your project files to trunk/"
echo "  2. Run: svn add trunk/*"
echo "  3. Run: svn commit trunk/ -m 'Initial import'"
echo "  4. Create workspaces for your tasks"
