---
name: merge
description: Merge a workspace branch back to trunk with user approval
---

# Merge SVN Workspace

You are merging a completed workspace branch back to trunk.

## Steps

1. **Verify current state** before any operations:
   ```bash
   pwd  # Confirm location
   ls -la workspaces/  # Verify workspace exists
   ```

2. **Navigate to workspace directory** and verify location:
   ```bash
   cd workspaces/<workspace-name> || exit 1
   pwd  # MUST show: .../workspaces/<workspace-name>
   svn status  # Check workspace status
   ```

3. **Get repository root path** (use absolute paths only):
   ```bash
   REPO_ROOT="$(cd ../.. && pwd)/.svn-repo"
   echo "Repository: $REPO_ROOT"
   ```

4. **Show changes to user** before merging:
   ```bash
   # Use absolute URL to avoid relative path issues
   svn diff file://$REPO_ROOT/trunk
   svn diff --summarize file://$REPO_ROOT/trunk  # Show file-level summary
   ```

5. **Ask for user confirmation**:
   - Show summary of changes (files added/modified/deleted)
   - Ask: "Merge these changes to trunk? (yes/no)"
   - Wait for explicit approval

6. **If approved**, prepare trunk for merge:
   ```bash
   # Navigate to trunk_checkout (NOT trunk directory)
   cd ../../trunk_checkout || exit 1
   pwd  # MUST show: .../trunk_checkout
   svn status  # Should be clean
   ```

7. **Update trunk before merging**:
   ```bash
   svn update
   svn status  # Verify update succeeded
   ```

8. **Perform merge** using absolute URL:
   ```bash
   # Use absolute URL with repository root
   svn merge file://$REPO_ROOT/branches/<workspace-name>
   ```

9. **Check merge results**:
   ```bash
   svn status  # Show merged changes
   svn status | grep -E "^[CM]"  # Check for conflicts (C) or merges (M)
   ```

10. **Handle conflicts if any**:
    - If conflicts exist (marked with 'C'), show them to user
    - Ask how to resolve each conflict
    - Don't proceed until conflicts are resolved
    - Use `svn resolved <file>` after manual resolution

11. **Commit merged changes**:
    ```bash
    svn status  # Final verification
    svn commit -m "Merge <workspace-name>: <description>"
    # Verify commit succeeded (should show revision number)
    ```

12. **Clean up after successful merge**:
    ```bash
    cd ..
    rm -rf workspaces/<workspace-name>
    svn delete file://$REPO_ROOT/branches/<workspace-name> -m "Remove merged branch"
    ```

13. **Update .workspace-state.json** to remove workspace

14. **Confirm completion** to user

## Important Notes

- **ALWAYS use absolute paths** for SVN URLs (no `../` in paths)
- **ALWAYS verify pwd** before each SVN operation
- **Use trunk_checkout** for merge operations (not trunk directory)
- **ALWAYS svn update** before merging
- **ALWAYS show diff** before merging
- **NEVER merge without user approval**
- **NEVER auto-resolve conflicts**
- **Check svn status** after each operation
- **Verify commit success** (should output revision number)

## Safety Checklist (Complete before each SVN command)

Before running ANY svn command:
- [ ] pwd shows correct directory
- [ ] svn status shows expected state
- [ ] Using absolute file:// URLs (no ../)
- [ ] In correct working copy (workspace or trunk_checkout)

## Error Prevention

### Common Errors and Solutions

**Error: URL contains '..' element**
```bash
# WRONG
svn merge file://$(pwd)/../.svn-repo/branches/feature

# RIGHT
REPO_ROOT="$(cd ../.. && pwd)/.svn-repo"
svn merge file://$REPO_ROOT/branches/feature
```

**Error: is not a working copy**
```bash
# WRONG
cd trunk  # This is not an SVN working copy

# RIGHT
cd trunk_checkout  # This is the SVN working copy
```

**Error: Commit failed (out of date)**
```bash
# Solution: Always update before committing
svn update
# Resolve any conflicts
svn commit -m "message"
```

**Error: Directory not found**
```bash
# Always verify directory exists before cd
ls -la workspaces/<workspace-name> || exit 1
cd workspaces/<workspace-name>
```

## Error Handling

If merge conflicts occur:
1. Stop immediately
2. Show `svn status` to list conflicts
3. Display conflict files to user
4. Ask how to resolve each conflict
5. Wait for user to manually resolve
6. Run `svn resolved <file>` after resolution
7. Don't proceed until all conflicts resolved

If user rejects merge:
1. Ask if they want to continue working in workspace
2. Or if they want to abandon the changes
3. Don't delete workspace without user confirmation

If SVN command fails:
1. Check current directory with `pwd`
2. Verify working copy with `svn status`
3. Check if using absolute paths
4. Show error message to user
5. Ask how to proceed
