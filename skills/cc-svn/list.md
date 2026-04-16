---
name: list
description: List all active SVN workspaces
---

# List SVN Workspaces

You are listing all active SVN workspaces in the current project.

## Steps

1. **Verify current location**:
   ```bash
   pwd  # Should be project root
   ```

2. **Get repository root path** (use absolute paths):
   ```bash
   REPO_ROOT="$(pwd)/.svn-repo"
   echo "Repository: $REPO_ROOT"
   ```

3. **Check if repository exists**:
   ```bash
   ls -la .svn-repo 2>/dev/null || echo "No SVN repository found"
   ```

4. **List workspaces** using the script:
   ```bash
   bash ./scripts/list_workspaces.sh
   ```

5. **If script doesn't work**, use manual methods with absolute paths:
   ```bash
   # List workspace directories
   ls -la workspaces/ 2>/dev/null || echo "No workspaces directory"

   # Check state file
   cat .workspace-state.json 2>/dev/null || echo "No state file"

   # List SVN branches using absolute URL
   svn ls file://$REPO_ROOT/branches/ 2>/dev/null || echo "No branches"
   ```

6. **Display results** in a user-friendly format:
   - Workspace name
   - Creation date
   - Status (if available)
   - Description (if available)

7. **If no workspaces exist**, inform user

8. **Provide next steps**:
   - How to create a new workspace
   - How to work in existing workspace
   - How to merge completed workspace

## Important Notes

- **ALWAYS use absolute file:// URLs** for SVN operations
- **Verify repository exists** before listing branches
- **Show multiple information sources** for completeness
- Check both filesystem (workspaces/) and SVN (branches/)

## Safety Checklist

- [ ] pwd shows project root
- [ ] Using absolute file:// URLs
- [ ] Repository path verified

## Output Format

Present information in a clear, organized way:
```
Active Workspaces:
==================
• feature-user-auth (created: 2025-01-15)
  Status: active
  Description: Add user authentication

• fix-login-bug (created: 2025-01-16)
  Status: active
  Description: Fix login timeout issue
```

## Error Prevention

### Common Errors and Solutions

**Error: No such file or directory**
```bash
# Check if repository exists first
ls -la .svn-repo || echo "Repository not found"
```

**Error: Relative path issues**
```bash
# WRONG
svn ls file://$(pwd)/.svn-repo/../branches/

# RIGHT
REPO_ROOT="$(pwd)/.svn-repo"
svn ls file://$REPO_ROOT/branches/
```

**Error: Permission denied**
```bash
# Check directory permissions
ls -la workspaces/
```

## Error Handling

If repository doesn't exist:
- Inform user that SVN is not initialized
- Offer to initialize repository
- Guide to run init script

If workspaces directory doesn't exist:
- Inform user no workspaces created yet
- Offer to create first workspace
- Show how to use create skill

If SVN command fails:
- Check if repository path is correct
- Verify using absolute URLs
- Show error message to user
- Suggest alternative methods
