---
name: merge
description: Merge a workspace branch back to trunk with user approval
---

# Merge SVN Workspace

You are merging a completed workspace branch back to trunk.

## Steps

1. **Get workspace name** from user or use current workspace

2. **Show changes to user** before merging:
   ```bash
   cd workspaces/<workspace-name>
   svn diff file://$(pwd)/../.svn-repo/trunk
   ```

3. **Ask for user confirmation**:
   - Show summary of changes (files added/modified/deleted)
   - Ask: "Merge these changes to trunk? (yes/no)"
   - Wait for explicit approval

4. **If approved**, merge to trunk:
   ```bash
   ./scripts/merge_workspace.sh "<workspace-name>"
   ```

5. **Clean up after successful merge**:
   - Remove workspace directory
   - Delete branch from repository
   - Update .workspace-state.json

6. **Confirm completion** to user

## Important Notes

- ALWAYS show diff before merging
- NEVER merge without user approval
- If there are conflicts, show them to user and ask how to resolve
- Don't auto-resolve conflicts
- Only proceed with merge after explicit user confirmation

## Error Handling

If merge conflicts occur:
- Stop and show conflicts to user
- Ask how to resolve each conflict
- Don't proceed until conflicts are resolved

If user rejects merge:
- Ask if they want to continue working in workspace
- Or if they want to abandon the changes
