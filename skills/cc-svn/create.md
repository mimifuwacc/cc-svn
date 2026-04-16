---
name: create
description: Create a new SVN workspace branch for development work
---

# Create SVN Workspace

You are creating a new SVN workspace branch for parallel development.

## Steps

1. **Verify current location**:
   ```bash
   pwd  # Should be project root
   ls -la .svn-repo 2>/dev/null || echo "Repository not initialized"
   ```

2. **If repository doesn't exist, initialize it**:
   ```bash
   ./scripts/init_repo.sh
   # Verify initialization succeeded
   ls -la .svn-repo/trunk
   ```

3. **Get repository root path** (use absolute paths):
   ```bash
   REPO_ROOT="$(pwd)/.svn-repo"
   echo "Repository: $REPO_ROOT"
   ```

4. **Generate workspace name** based on user's task description:
   - Features: `feature-<description>`
   - Bugfixes: `fix-<description>`
   - Experiments: `experiment-<description>`
   - Keep names descriptive but concise (use hyphens, no spaces)

5. **Check if workspace already exists**:
   ```bash
   ls -la workspaces/<workspace-name> 2>/dev/null && echo "Workspace exists"
   svn list file://$REPO_ROOT/branches/<workspace-name> 2>/dev/null && echo "Branch exists"
   ```

6. **Create the workspace** using absolute URLs:
   ```bash
   # Create branch using absolute URL
   svn copy file://$REPO_ROOT/trunk \
             file://$REPO_ROOT/branches/<workspace-name> \
             -m "Create workspace for <description>"
   # Verify branch creation succeeded (should show revision number)
   ```

7. **Checkout the workspace**:
   ```bash
   mkdir -p workspaces
   svn checkout file://$REPO_ROOT/branches/<workspace-name> \
                 workspaces/<workspace-name>
   # Verify checkout succeeded
   ls -la workspaces/<workspace-name>
   ```

8. **Verify workspace status**:
   ```bash
   cd workspaces/<workspace-name>
   pwd  # Confirm location
   svn status  # Should show clean working copy
   svn info  # Verify branch URL
   ```

9. **Update .workspace-state.json**:
   ```json
   {
     "workspaces": {
       "<workspace-name>": {
         "created": "2025-01-15T10:30:00Z",
         "status": "active",
         "description": "<description>"
       }
     }
   }
   ```

10. **Remind user of workspace location**:
    - All work should happen in `workspaces/<workspace-name>/`
    - Never edit files directly in trunk
    - Commit frequently to save progress

## Important Notes

- **ALWAYS use absolute file:// URLs** (no relative paths with ../)
- **ALWAYS verify pwd** before SVN operations
- **ALWAYS check if workspace exists** before creating
- **Verify each step succeeded** before proceeding
- Workspaces are created instantly using SVN's cheap copy feature
- Each workspace is completely isolated from others
- Always work in the workspace directory, not trunk
- Commit frequently within the workspace to save progress

## Safety Checklist (Complete before each SVN command)

Before running ANY svn command:
- [ ] pwd shows correct directory
- [ ] Using absolute file:// URLs
- [ ] Repository path is correct
- [ ] Previous step succeeded

## Error Prevention

### Common Errors and Solutions

**Error: Path contains '..' element**
```bash
# WRONG
svn copy file://$(pwd)/.svn-repo/trunk \
           file://$(pwd)/.svn-repo/../branches/feature

# RIGHT
REPO_ROOT="$(pwd)/.svn-repo"
svn copy file://$REPO_ROOT/trunk \
           file://$REPO_ROOT/branches/feature
```

**Error: Working copy already exists**
```bash
# Check first
ls -la workspaces/<workspace-name>
# If exists, ask user what to do
```

**Error: Repository not initialized**
```bash
# Check first
ls -la .svn-repo
# If missing, initialize first
./scripts/init_repo.sh
```

**Error: Branch already exists**
```bash
# Check first
svn list file://$REPO_ROOT/branches/<workspace-name>
# If exists, ask user to:
# - Use existing workspace
# - Choose different name
# - Delete old branch first
```

## Error Handling

If workspace already exists:
1. Check if it's for the same task
2. If yes, continue using existing workspace
3. If no, suggest a different name (add timestamp or number)
4. Ask user what they want to do

If SVN command fails:
1. Check current directory with `pwd`
2. Verify repository path exists with `ls -la .svn-repo`
3. Check if using absolute paths
4. Show error message to user
5. Ask how to proceed

If checkout fails:
1. Verify branch was created: `svn list file://$REPO_ROOT/branches/<workspace-name>`
2. Check workspaces directory exists: `ls -la workspaces`
3. Check permissions on workspaces directory
4. Show error to user and ask how to proceed
