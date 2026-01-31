---
description: Clean up a worktree (Valet, database, git branch)
allowed-tools: Bash, AskUserQuestion
---

# /worktree-cleanup Command

Clean up a worktree and all associated resources (Valet domain, database, git branch).

## Pre-flight Checks

1. **Detect current context:**
   ```bash
   TOPLEVEL=$(git rev-parse --show-toplevel 2>/dev/null)
   ```

2. **Check if in worktree or main project:**
   - If path contains `.worktrees/`: We're in a worktree
   - Otherwise: We're in the main project

## Workflow

### If in a Worktree

1. **Extract worktree info:**
   ```bash
   WORKTREE_PATH=$(pwd)
   SANITIZED_BRANCH=$(basename "$WORKTREE_PATH")
   BRANCH=$(git branch --show-current)
   PROJECT=$(${CLAUDE_PLUGIN_ROOT}/scripts/detect-project-name.sh ../..)
   ```

2. **Confirm cleanup:**
   Use AskUserQuestion:
   ```
   header: "Confirm Cleanup"
   question: "This will permanently delete the worktree '$SANITIZED_BRANCH' and all associated resources. Continue?"
   options:
     - label: "Yes, clean up"
       description: "Remove worktree, Valet link, database, and local branch"
     - label: "Cancel"
       description: "Keep everything as-is"
   ```

3. **If confirmed, proceed to cleanup steps below**

### If in Main Project

1. **List existing worktrees:**
   ```bash
   git worktree list
   ```

2. **If no worktrees exist:**
   ```
   No worktrees found. Nothing to clean up.
   ```
   Exit.

3. **If worktrees exist, ask which to clean up:**
   Use AskUserQuestion with worktree names as options:
   ```
   header: "Select Worktree"
   question: "Which worktree do you want to clean up?"
   options:
     - label: "$WORKTREE_1"
       description: "Branch: $BRANCH_1"
     - label: "$WORKTREE_2"
       description: "Branch: $BRANCH_2"
     # ... etc
   ```

4. **Confirm the selection:**
   Use AskUserQuestion:
   ```
   header: "Confirm Cleanup"
   question: "This will permanently delete '$SELECTED_WORKTREE'. Continue?"
   options:
     - label: "Yes, clean up"
       description: "Remove worktree, Valet link, database, and local branch"
     - label: "Cancel"
       description: "Keep everything as-is"
   ```

## Cleanup Steps

Execute these in order:

### Step 1: Kill Vite Processes

```bash
pkill -f "node.*vite.*$SANITIZED_BRANCH" || true
```

### Step 2: Unlink from Valet

```bash
cd $WORKTREE_PATH 2>/dev/null && valet unlink || true
```

Or if we know the domain:
```bash
valet unlink $PROJECT-$SANITIZED_BRANCH || true
```

### Step 3: Change to Main Project Directory

If currently in the worktree being deleted:
```bash
cd ../..
```

### Step 4: Remove Git Worktree

```bash
git worktree remove .worktrees/$SANITIZED_BRANCH --force
```

### Step 5: Delete Local Branch

```bash
git branch -D $BRANCH
```

Note: This may fail if the branch was never created (worktree used existing branch). That's OK.

### Step 6: Drop Database

```bash
DB_NAME=$(echo "${PROJECT}_${SANITIZED_BRANCH}" | tr '-' '_')
mysql -u root -e "DROP DATABASE IF EXISTS $DB_NAME;"
```

### Step 7: Update Warp Configuration (Optional)

If the Warp launch config was specifically for this worktree, it can be left as-is (will just fail to open that path) or removed:
```bash
# Optional: Remove if it was worktree-specific
# rm ~/.warp/launch_configurations/laravel-worktree.yaml
```

## Display Result

```
## Worktree Cleaned Up

| Resource | Status |
|----------|--------|
| Vite processes | Killed |
| Valet domain | Unlinked ($PROJECT-$SANITIZED_BRANCH.test) |
| Worktree | Removed (.worktrees/$SANITIZED_BRANCH/) |
| Git branch | Deleted ($BRANCH) |
| Database | Dropped (${PROJECT}_${SANITIZED_BRANCH}) |

You're now in the main project directory.
```

## Error Handling

- If worktree removal fails due to uncommitted changes, warn user and offer options:
  1. Force remove anyway (lose changes)
  2. Cancel and commit/stash first
- If database drop fails, the database may not exist (already cleaned up) - that's OK
- If Valet unlink fails, the link may not exist - that's OK
- If branch delete fails, branch may have been deleted already - that's OK
