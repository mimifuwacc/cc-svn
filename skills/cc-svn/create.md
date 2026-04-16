---
name: create
description: Create a new SVN workspace branch for development work
---

# Create SVN Workspace

You are creating a new SVN workspace branch for parallel development.

## Steps

1. **Check if SVN repository exists**:
   ```bash
   ls -la .svn-repo 2>/dev/null || echo "Repository not initialized"
   ```

2. **If repository doesn't exist, initialize it**:
   ```bash
   ./scripts/init_repo.sh
   ```

3. **Generate workspace name** based on user's task description:
   - Features: `feature-<description>`
   - Bugfixes: `fix-<description>`
   - Experiments: `experiment-<description>`
   - Keep names descriptive but concise (use hyphens, no spaces)

4. **Create the workspace** using the script:
   ```bash
   bash ./scripts/create_workspace.sh "<workspace-name>" "<description>"
   ```
   - Workspace location: `workspaces/<workspace-name>/`
   - Reminder: All work should happen in the workspace directory
   - Never edit files directly in trunk

## Important Notes

- Workspaces are created instantly using SVN's cheap copy feature
- Each workspace is completely isolated from others
- Always work in the workspace directory, not trunk
- Commit frequently within the workspace to save progress

## Error Handling

If workspace already exists:
- Check if it's for the same task
- If yes, continue using existing workspace
- If no, suggest a different name (add timestamp or number)
