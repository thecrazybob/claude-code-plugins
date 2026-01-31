---
description: Create a PR from the current worktree branch
allowed-tools: Bash, AskUserQuestion
---

# /worktree-pr Command

Create a pull request from the current worktree branch.

## Pre-flight Checks

1. **Verify we're in a worktree:**
   ```bash
   TOPLEVEL=$(git rev-parse --show-toplevel 2>/dev/null)
   ```
   If the path does NOT contain `.worktrees/`, warn the user and exit:
   ```
   You're not in a worktree directory. This command should be run from within a worktree.
   Current directory: $PWD
   ```

2. **Get current branch:**
   ```bash
   BRANCH=$(git branch --show-current)
   ```

## Workflow

### Step 1: Show Current State

Display the current changes:
```bash
git status
git diff --stat
```

If there are no changes (nothing to commit, nothing staged), inform the user:
```
No changes detected. Nothing to commit or push.
```
And exit.

### Step 2: Ask for Task/Issue Number (Optional)

Use AskUserQuestion:
```
header: "Task Number"
question: "Enter a task/issue number to prefix the commit (e.g., SCOUT-123), or leave empty to skip:"
options:
  - label: "No task number"
    description: "Create PR without task prefix"
  - label: "Enter task number"
    description: "I'll provide a task/issue number"
```

If they choose to enter a task number, use AskUserQuestion again to get it.

### Step 3: Stage Changes

```bash
git add .
```

### Step 4: Create Commit

Generate a commit message based on the changes. If task number provided, prefix it:

```bash
# With task number
git commit -m "$(cat <<'EOF'
TASK-123: feat: description of changes

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"

# Without task number
git commit -m "$(cat <<'EOF'
feat: description of changes

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

### Step 5: Push Branch

```bash
git push -u origin HEAD
```

### Step 6: Create Pull Request

```bash
gh pr create --fill
```

If `--fill` doesn't produce a good title/body, use:
```bash
gh pr create --title "feat: description" --body "$(cat <<'EOF'
## Summary
- Brief description of changes

## Test Plan
- How to test

Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

### Step 7: Display Result

Output the PR URL and remind about cleanup:

```
## Pull Request Created

PR URL: https://github.com/owner/repo/pull/123

### After PR is Merged

Run `/worktree-cleanup` to:
- Remove the worktree directory
- Unlink from Valet
- Drop the database
- Delete the local branch
```

## Error Handling

- If `gh` is not installed, provide installation instructions
- If not authenticated with GitHub, run `gh auth login`
- If push fails (branch already exists on remote), offer to force push or pull first
- If PR creation fails (PR already exists), provide the existing PR URL
