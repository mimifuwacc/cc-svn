---
name: cc-svn
description: AI-driven parallel development workspace manager using SVN. MANDATORY for all code modification tasks. Enforces branch-before-edit workflow: create workspace branches FIRST, then implement. Prevents accidental edits to trunk. Use for features, bug fixes, refactoring, experiments - ANY task that edits code. This is the ONLY approved workflow for code changes.
---

# cc-svn: AI-Driven SVN Workspace Manager

A skill for managing parallel development workflows using SVN. This enables AI agents to work on multiple tasks simultaneously without conflicts, similar to Git worktrees but optimized for AI-driven development.

## Why This Skill Exists

When working with AI agents, traditional Git branching becomes cumbersome:
- Creating branches for every task is slow
- Worktrees add overhead
- AI agents need isolated spaces to work in parallel

SVN's cheap copy feature allows us to create branches instantly (constant-time operation), and each workspace is completely isolated. Perfect for AI-driven parallel development.

## Directory Structure

```
project-root/
├── .svn-repo/              # Local SVN repository
├── trunk/                  # Main development line
├── workspaces/             # Task-specific workspaces
│   ├── feature-auth/
│   └── fix-bug-123/
└── .workspace-state.json   # Tracks active workspaces
```

## Core Principles

1. **BRANCH FIRST, IMPLEMENT SECOND**
   - This is the most critical rule
   - Before writing ANY code, create a workspace branch
   - No exceptions, no shortcuts
   - If you catch yourself editing files without a branch, stop immediately

2. **Every feature/bugfix gets its own workspace**
   - Never work directly in trunk
   - Each workspace is a branch + checkout
   - Workspaces are created instantly using SVN's cheap copy

2. **Parallel work is the default**
   - Multiple agents can work in different workspaces simultaneously
   - No conflicts between workspaces
   - Each workspace is isolated

3. **User confirmation before merging**
   - Always show diff before merging to trunk
   - User must approve changes
   - Manual conflict resolution if needed

4. **Clean up after completion**
   - Delete workspaces after successful merge
   - Keep workspace directory clean

## Workflow

### MANDATORY: Branch Before Implementation

**CRITICAL RULE: Never start implementing features, bug fixes, or any code changes without first creating a workspace branch.**

Before you write ANY code, you must:
1. Stop and recognize this is a code modification task
2. Create a workspace branch following the steps below
3. Only THEN begin implementation

**Detection checklist - Create a branch if the user asks for:**
- New features ("Implement X", "Add Y feature")
- Bug fixes ("Fix X bug", "This doesn't work")
- Code changes ("Modify X", "Update Y", "Change Z")
- Experiments ("Try X approach", "Test Y idea")
- Refactoring ("Refactor X", "Clean up Y")

**If you're about to edit a file and haven't created a workspace branch yet - STOP.**
Create the branch first, then proceed with implementation.

### Initial Setup (First Time Only)

When the user wants to start using this in a project:

1. Check if `.svn-repo` exists
2. If not, initialize the SVN repository:
   ```bash
   svnadmin create .svn-repo
   mkdir -p .svn-repo/trunk
   svn checkout file://$(pwd)/.svn-repo/trunk trunk
   ```
3. Import existing code if necessary:
   ```bash
   svn add ./*
   svn commit -m "Initial import"
   ```

### Starting a New Task

When the user requests a feature, bugfix, or any development work:

1. **Generate a workspace name** based on the task:
   - Features: `feature-<description>`
   - Bugfixes: `fix-<description>`
   - Experiments: `experiment-<description>`
   - Keep names descriptive but concise

2. **Create the branch** (instant operation):
   ```bash
   svn copy file://$(pwd)/.svn-repo/trunk \
             file://$(pwd)/.svn-repo/branches/<workspace-name> \
             -m "Create workspace for <task description>"
   ```

3. **Checkout the workspace**:
   ```bash
   svn checkout file://$(pwd)/.svn-repo/branches/<workspace-name> \
                 workspaces/<workspace-name>
   ```

4. **Update state file** (`.workspace-state.json`):
   ```json
   {
     "workspaces": {
       "<workspace-name>": {
         "created": "2025-01-15T10:30:00Z",
         "status": "active",
         "description": "<task description>"
       }
     }
   }
   ```

5. **Work in the workspace directory** (`workspaces/<workspace-name>/`)

### During Development

- All file operations happen in the workspace directory
- Commit frequently to the branch:
  ```bash
  cd workspaces/<workspace-name>
  svn commit -m "Progress update"
  ```

### Completing a Task

When the workspace work is done:

1. **Show changes** to the user:
   ```bash
   cd workspaces/<workspace-name>
   svn diff file://$(pwd)/../.svn-repo/trunk
   ```

2. **Ask for user confirmation**:
   - Show the diff summary
   - Ask: "Merge these changes to trunk?"
   - Wait for explicit approval

3. **If approved**, merge to trunk:
   ```bash
   cd trunk
   svn merge file://$(pwd)/../.svn-repo/branches/<workspace-name>
   svn commit -m "Merge <workspace-name>: <description>"
   ```

4. **Delete the workspace**:
   ```bash
   rm -rf workspaces/<workspace-name>
   svn delete file://$(pwd)/.svn-repo/branches/<workspace-name> -m "Remove merged branch"
   ```

5. **Update state file** to remove the workspace

### Listing Active Workspaces

When asked about current work:

```bash
cat .workspace-state.json
```

Or list workspace directories:
```bash
ls -la workspaces/
```

## When to Use This Skill

**MANDATORY: Always use this skill for ANY code modification:**
- Feature development ("Add X", "Implement Y", "Create Z feature")
- Bug fixes ("Fix X bug", "This is broken", "X doesn't work")
- Refactoring work ("Refactor X", "Clean up Y")
- Experimental changes ("Try X", "Test Y approach")
- ANY task that involves editing code files

**If the user asks you to modify code in ANY way, you MUST:**
1. Recognize this requires a workspace branch
2. Create the branch FIRST
3. Only then start implementation

**Trigger phrases - These ALWAYS require creating a branch:**
- "Implement [feature]"
- "Fix [bug]"
- "Add [functionality]"
- "Work on [task]"
- "Modify [code]"
- "Change [X]"
- "Update [Y]"
- "Try [approach]"
- "Experiment with [X]"
- "Create [feature]"

**When in doubt: Create a branch.** It's fast (constant-time) and safe.

## Common Patterns

### Pattern 1: Single Task

User: "Add user authentication"

You:
1. **STOP** - Recognize this is a code modification task
2. Create workspace `feature-user-auth` (CRITICAL - do this FIRST)
3. **THEN** Implement in `workspaces/feature-user-auth/`
4. Show diff and get approval
5. Merge to trunk
6. Clean up

**Key Point: Step 2 (branch creation) MUST happen before Step 3 (implementation).**

### Pattern 2: Parallel Tasks

User: "Add authentication and fix the login bug"

You:
1. Create `feature-auth` workspace
2. Create `fix-login-bug` workspace
3. Work on both (can spawn subagents for each)
4. Complete each independently with user approval

### Pattern 3: Task During Task

User: "Oh, also fix this bug while you're working"

You:
1. Create new workspace for the bug
2. Continue with current task
3. Handle bug fix in parallel

## Important Constraints

1. **BRANCH BEFORE EDITING** - Create workspace branch BEFORE making any code changes
2. **Never work directly in trunk** - Always use a workspace for any code modifications
3. **Always get user approval before merging** - No automatic merges
4. **Clean up workspaces** - Don't leave old workspaces around
5. **Keep workspace names descriptive** - Helps with organization
6. **Commit frequently** - Don't lose work

## Pre-Implementation Checklist

Before starting any implementation, verify:
- [ ] Have I created a workspace branch?
- [ ] Am I working in the workspace directory (not trunk)?
- [ ] Does the workspace name clearly describe the task?

If the answer to any of these is "NO", create the branch first.

## SVN Commands Reference

### Repository Management
```bash
# Create repository
svnadmin create .svn-repo

# Import existing code
svn checkout file://$(pwd)/.svn-repo/trunk trunk
```

### Branching
```bash
# Create branch (instant - cheap copy!)
svn copy file://$(pwd)/.svn-repo/trunk \
          file://$(pwd)/.svn-repo/branches/<name> \
          -m "Create branch"

# Checkout branch
svn checkout file://$(pwd)/.svn-repo/branches/<name> workspaces/<name>
```

### Merging
```bash
# See what will change
svn diff file://$(pwd)/.svn-repo/trunk

# Merge branch to trunk
cd trunk
svn merge file://$(pwd)/../.svn-repo/branches/<name>
svn commit -m "Merge branch"
```

### Cleanup
```bash
# Delete branch
svn delete file://$(pwd)/.svn-repo/branches/<name> -m "Remove branch"

# Remove workspace directory
rm -rf workspaces/<name>
```

## Troubleshooting

**Issue: Repository already exists**
- Check if `.svn-repo` exists
- If it does, use it instead of creating new

**Issue: Merge conflicts**
- Show conflicts to user
- Ask how to resolve
- Don't auto-resolve

**Issue: Workspace already exists**
- Check if task is same as existing workspace
- If yes, continue in existing workspace
- If no, create with different name (add suffix)

**Issue: Can't create branch**
- Ensure `.svn-repo` is properly initialized
- Check that trunk exists in repository
- Verify file:// URL paths are correct

## Scripts

The `scripts/` directory contains helper scripts:

- `init_repo.sh` - Initialize SVN repository
- `create_workspace.sh` - Create new workspace
- `merge_workspace.sh` - Merge workspace to trunk
- `list_workspaces.sh` - List active workspaces
- `cleanup_workspace.sh` - Remove workspace

Use these scripts when available, otherwise run SVN commands directly.
