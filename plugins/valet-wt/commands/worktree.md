---
description: Create a new Laravel worktree with Valet, DB, and Warp config
argument-hint: "[branch-name]"
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion, Glob
---

# /worktree Command

Create a new git worktree for a Laravel project served by Laravel Valet. Uses generated `scripts/setup.sh` for environment setup instead of inline steps.

## Arguments

- `branch-name` (optional): The name for the new branch. If not provided, prompt using AskUserQuestion.

## Pre-flight Checks

1. **Verify not already in a worktree:**
   ```bash
   git rev-parse --show-toplevel 2>/dev/null
   ```
   If the path contains `.worktrees/`, warn the user they're already in a worktree and ask if they want to continue from the main project directory.

2. **Check for existing worktrees:**
   ```bash
   git worktree list
   ```
   If multiple worktrees exist, inform the user.

## Workflow

### Step 1: Get Branch Name

If `$ARGUMENTS` is provided, use it directly. Otherwise, use AskUserQuestion:

```
header: "Branch Name"
question: "What branch name do you want for this worktree?"
```

**Sanitize the branch name:**
```bash
SANITIZED_BRANCH=$(echo "$BRANCH" | tr '/' '-' | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
```

### Step 2: Detect Project Name

Use the helper script:
```bash
PROJECT=$(${CLAUDE_PLUGIN_ROOT}/scripts/detect-project-name.sh)
```

### Step 3: Detect Base Branch

```bash
BASE_BRANCH=$(git config init.defaultBranch 2>/dev/null || echo "main")
# Verify it exists
git show-ref --verify --quiet refs/heads/$BASE_BRANCH || BASE_BRANCH="master"
```

### Step 4: Check for Scripts

```bash
if [ ! -f scripts/setup.sh ]; then
    echo "scripts/setup.sh not found. Generating scripts first..."
fi
```

If `scripts/setup.sh` is missing, inform the user and trigger `/scripts` generation before proceeding. Do not continue without the scripts.

### Step 5: Create Worktree

```bash
git worktree add .worktrees/$SANITIZED_BRANCH -b $BRANCH $BASE_BRANCH
```

### Step 6: Copy Scripts

```bash
cp -r scripts/ .worktrees/$SANITIZED_BRANCH/scripts/
```

### Step 7: Run setup.sh

This single command replaces the old inline steps (Valet link, .env config, DB creation, dependencies, migrations, etc.):

```bash
cd .worktrees/$SANITIZED_BRANCH
CONDUCTOR_WORKSPACE_NAME=$SANITIZED_BRANCH \
CONDUCTOR_ROOT_PATH=$(cd ../.. && pwd) \
bash scripts/setup.sh
```

### Step 8: Fix Vite Configuration (if needed)

Check if `vite.config.js` or `vite.config.ts` has CORS settings. If missing, add:

```javascript
server: {
    host: 'localhost',
    cors: true,
}
```

**Only modify if these settings are missing.**

### Step 9: Setup Warp Launch Configuration

Skip if `~/.warp/` doesn't exist.

```bash
mkdir -p ~/.warp/launch_configurations

WORKTREE_PATH="$(pwd)"
sed -e "s|{{WORKTREE_PATH}}|$WORKTREE_PATH|g" \
    -e "s|{{WORKTREE_NAME}}|$SANITIZED_BRANCH|g" \
    ${CLAUDE_PLUGIN_ROOT}/templates/laravel-worktree.yaml \
    > ~/.warp/launch_configurations/laravel-worktree.yaml
```

### Step 10: Display Summary

Output a summary table:

```
## Worktree Created Successfully

| Item | Value |
|------|-------|
| Branch | $BRANCH |
| Directory | .worktrees/$SANITIZED_BRANCH/ |
| URL | http://$PROJECT-$SANITIZED_BRANCH.test |
| Database | ${PROJECT}_${SANITIZED_BRANCH} |

### Next Steps

1. **Open Warp layout:** Press `Cmd+Ctrl+L` and select "Laravel Worktree"
2. **Start services:** Run `bash scripts/run.sh` (or use the Warp layout)
3. **Open in browser:** Run `browse` or visit the URL above

### Useful Commands

| Command | Description |
|---------|-------------|
| `browse` | Open project in browser |
| `opendb` | Open database in GUI |
| `p` | Run tests |
| `a` | php artisan shortcut |
| `bash scripts/run.sh` | Start all dev services |

**IMPORTANT:** All subsequent work must use the worktree directory:
`.worktrees/$SANITIZED_BRANCH/`
```

## Error Handling

- If worktree already exists, offer to enter it instead of creating
- If Valet link fails, suggest running `valet install`
- If database creation fails, check if the DB server is running
- If branch already exists, offer to use existing branch
- If `scripts/setup.sh` fails, show the error output and suggest checking `references/troubleshooting.md`
