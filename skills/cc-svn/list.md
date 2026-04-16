---
name: list
description: List all active SVN workspaces
---

# List SVN Workspaces

You are listing all active SVN workspaces in the current project.

## Steps

1. **Check if repository exists**:
   ```bash
   ls -la .svn-repo 2>/dev/null || echo "No SVN repository found"
   ```

2. **List workspaces** using the script:
   ```bash
   ./scripts/list_workspaces.sh
   ```

3. **Display results** in a user-friendly format:
   - Workspace name
   - Creation date
   - Status (if available)
   - Description (if available)

4. **If no workspaces exist**, inform user

5. **Provide next steps**:
   - How to create a new workspace
   - How to work in existing workspace
   - How to merge completed workspace

## Alternative Methods

If script doesn't work, show manual alternatives:
- List workspace directories: `ls -la workspaces/`
- Check state file: `cat .workspace-state.json`
- List SVN branches: `svn ls file://$(pwd)/.svn-repo/branches/`

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
