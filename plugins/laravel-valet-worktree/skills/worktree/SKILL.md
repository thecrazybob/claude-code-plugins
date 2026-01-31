# Laravel Valet Worktree Skill

---
name: laravel-valet-worktree
description: |
  Manages git worktrees for Laravel projects served by Laravel Valet. Activates when the user mentions:
  - "worktree", "work tree", "new worktree", "create worktree"
  - "branch workflow", "feature branch setup"
  - "valet worktree", "valet link worktree"
  - "finish worktree", "cleanup worktree", "merge worktree"
  - "isolated branch", "parallel development"
---

## Overview

This skill manages git worktrees for Laravel projects served by Laravel Valet. It creates isolated development environments where each feature branch gets its own:
- Directory (in `.worktrees/`)
- Valet domain (`projectname-branchname.test`)
- Database (`projectname_branchname`)
- Vite dev server instance

This enables parallel work on multiple features without switching branches or corrupting shared state.

## Initial Flow

**ALWAYS start by checking for existing worktrees:**

```bash
git worktree list
```

### If worktrees exist:

Use AskUserQuestion to ask:

```
header: "Worktree Action"
question: "You have existing worktrees. What would you like to do?"
options:
  - label: "Set up new worktree"
    description: "Create a new worktree for a different feature branch"
  - label: "Finish existing worktree"
    description: "Complete work on a worktree (PR, merge, or abandon)"
```

### If no worktrees exist:

Proceed directly to asking for the branch name.

## Setup Workflow

### Step 1: Get Branch Name

Use AskUserQuestion:

```
header: "Branch Name"
question: "What branch name do you want to create for this worktree?"
```

**Sanitize the branch name for filesystem/domain use:**
- Replace `/` with `-`
- Replace spaces with `-`
- Convert to lowercase for domains

### Step 2: Detect Project Name

Get the project name from one of:
1. `composer.json` "name" field (after the `/`)
2. Parent directory name

```bash
# From composer.json
jq -r '.name // empty' composer.json | cut -d'/' -f2

# Fallback to directory name
basename "$(pwd)"
```

### Step 3: Detect Base Branch

```bash
# Try git config first
git config init.defaultBranch 2>/dev/null || echo "main"

# Or check which exists
git show-ref --verify --quiet refs/heads/main && echo "main" || echo "master"
```

### Step 4: Create Worktree

```bash
# Create the worktree directory and branch
git worktree add .worktrees/$SANITIZED_BRANCH -b $BRANCH $BASE_BRANCH
```

### Step 5: Link with Valet (HTTP only)

```bash
cd .worktrees/$SANITIZED_BRANCH
valet link $PROJECT-$SANITIZED_BRANCH
```

**IMPORTANT:** Do NOT run `valet secure`. HTTP avoids Vite mixed content issues.

### Step 6: Configure Environment

Copy and modify `.env`:

```bash
cp ../../.env .env
```

Update these values:

| Key | Value |
|-----|-------|
| `APP_URL` | `http://$PROJECT-$SANITIZED_BRANCH.test` |
| `SESSION_DOMAIN` | `$PROJECT-$SANITIZED_BRANCH.test` |
| `SESSION_SECURE_COOKIE` | `false` |
| `DB_DATABASE` | `${PROJECT}_${SANITIZED_BRANCH}` (underscores, not hyphens) |

**For SANCTUM_STATEFUL_DOMAINS**, append the worktree domain:

```bash
# If it exists, append
SANCTUM_STATEFUL_DOMAINS=localhost,127.0.0.1,...,$PROJECT-$SANITIZED_BRANCH.test
```

### Step 7: Create Database

```bash
mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${PROJECT}_${SANITIZED_BRANCH};"
```

### Step 8: Install Dependencies

```bash
composer install
npm install
```

### Step 9: Clear Caches

```bash
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
```

### Step 10: Create Storage Symlink

```bash
php artisan storage:link --force
```

### Step 11: Fix Vite Configuration (if needed)

Check if `vite.config.js` or `vite.config.ts` needs CORS fixes for worktree development:

```javascript
// In the server config section, ensure these exist:
server: {
    host: 'localhost',
    cors: true,
    // ... existing hmr config
}
```

**Only modify if these settings are missing.** This prevents CORS errors when the Vite dev server serves assets to a different domain.

### Step 12: Start Vite Dev Server

```bash
# Kill any existing Vite processes for this project
pkill -f "node.*vite" || true

# Start fresh (run in background or instruct user)
npm run dev
```

### Step 13: Run Migrations

```bash
php artisan migrate:fresh --seed
```

### Step 14: Setup Warp Launch Configuration

Generate a Warp terminal launch configuration for the worktree layout (3 panes: left for coding, right-top for Vite, right-bottom for commands).

**Template location:** `${CLAUDE_PLUGIN_ROOT}/templates/laravel-worktree.yaml`

**Warp config location:** `~/.warp/launch_configurations/`

```bash
# Create Warp launch_configurations directory if it doesn't exist
mkdir -p ~/.warp/launch_configurations

# Generate config from template (replace placeholders)
sed -e "s|{{WORKTREE_PATH}}|$WORKTREE_PATH|g" \
    -e "s|{{WORKTREE_NAME}}|$SANITIZED_BRANCH|g" \
    ${CLAUDE_PLUGIN_ROOT}/templates/laravel-worktree.yaml \
    > ~/.warp/launch_configurations/laravel-worktree.yaml
```

**Tell user:** Launch the worktree terminal layout with `Cmd+Ctrl+L` and select "Laravel Worktree". May need to restart Warp if config was just created.

### Step 15: Final Instructions

**CRITICAL REMINDER:**

After setup, ALL subsequent work MUST use the worktree path:
- **Worktree directory:** `.worktrees/$SANITIZED_BRANCH/`
- **URL:** `http://$PROJECT-$SANITIZED_BRANCH.test`
- **Warp layout:** Press `Cmd+Ctrl+L` and select "Laravel Worktree"

All file reads, edits, bash commands, and git operations must be executed from the worktree directory, NOT the main project directory.

**Useful helper commands:**

| Command | Description |
|---------|-------------|
| `browse` | Open project in browser (reads APP_URL from .env) |
| `opendb` | Open database in GUI client |
| `p` | Run tests (Pest/PHPUnit) |
| `pf <name>` | Run filtered test |
| `a` | `php artisan` shortcut |
| `tinker` | Interactive debugging (or `tinker "User::first()"`) |
| `aoc` | Clear all caches (`optimize:clear`) |

**Note:** The `browse` function in `scripts/browse.sh` is worktree-aware. Source it in your shell config:
```bash
source ${CLAUDE_PLUGIN_ROOT}/scripts/browse.sh
```

## Finishing Workflow

When the user wants to finish work on a worktree, use AskUserQuestion:

```
header: "Finish Worktree"
question: "How would you like to complete this worktree?"
options:
  - label: "Create PR"
    description: "Push branch and create a pull request on GitHub"
  - label: "Transfer to main"
    description: "Merge changes into main directory (no PR)"
  - label: "Abandon"
    description: "Discard all changes and remove worktree"
```

### Option A: Create PR

1. **Gather task info (optional):**
   ```
   header: "Task Number"
   question: "Enter a task/issue number to prefix the branch (or leave empty):"
   ```

2. **Commit changes:**
   ```bash
   cd .worktrees/$SANITIZED_BRANCH
   git add .
   git commit -m "feat: description of changes"
   ```

3. **Rename branch if task number provided:**
   ```bash
   git branch -m $BRANCH TASK-123/$BRANCH
   ```

4. **Push and create PR:**
   ```bash
   git push -u origin HEAD
   gh pr create --fill
   ```

5. **After PR is merged, cleanup:**
   ```bash
   # Stop services
   pkill -f "node.*vite.*$SANITIZED_BRANCH" || true

   # Unlink from Valet
   cd .worktrees/$SANITIZED_BRANCH
   valet unlink

   # Remove worktree
   cd ../..
   git worktree remove .worktrees/$SANITIZED_BRANCH --force

   # Delete local branch
   git branch -D $BRANCH

   # Drop database
   mysql -u root -e "DROP DATABASE IF EXISTS ${PROJECT}_${SANITIZED_BRANCH};"
   ```

### Option B: Transfer to Main

1. **Ensure main is up to date:**
   ```bash
   git checkout $BASE_BRANCH
   git pull
   ```

2. **Merge with no-commit:**
   ```bash
   git merge .worktrees/$SANITIZED_BRANCH --no-commit --no-ff
   ```

3. **If conflicts, help resolve them**

4. **Cleanup worktree:**
   ```bash
   pkill -f "node.*vite.*$SANITIZED_BRANCH" || true
   cd .worktrees/$SANITIZED_BRANCH && valet unlink
   cd ../..
   git worktree remove .worktrees/$SANITIZED_BRANCH --force
   git branch -D $BRANCH
   mysql -u root -e "DROP DATABASE IF EXISTS ${PROJECT}_${SANITIZED_BRANCH};"
   ```

### Option C: Abandon

1. **Confirm with user** (this is destructive)

2. **Full cleanup:**
   ```bash
   # Stop Vite
   pkill -f "node.*vite.*$SANITIZED_BRANCH" || true

   # Unlink Valet
   cd .worktrees/$SANITIZED_BRANCH
   valet unlink

   # Remove worktree and branch
   cd ../..
   git worktree remove .worktrees/$SANITIZED_BRANCH --force
   git branch -D $BRANCH

   # Drop database
   mysql -u root -e "DROP DATABASE IF EXISTS ${PROJECT}_${SANITIZED_BRANCH};"
   ```

## Quick Reference

| Item | Pattern |
|------|---------|
| Worktree path | `.worktrees/{sanitized-branch}/` |
| Domain | `{project}-{sanitized-branch}.test` |
| Database | `{project}_{sanitized_branch}` |
| Protocol | HTTP only (no SSL) |
| Migrations | `migrate:fresh --seed` |

## Variable Naming

| Variable | Description | Example |
|----------|-------------|---------|
| `$BRANCH` | Original branch name | `feature/user-auth` |
| `$SANITIZED_BRANCH` | Filesystem-safe version | `feature-user-auth` |
| `$PROJECT` | Project name | `scoutjobs` |
| `$BASE_BRANCH` | Main branch | `main` or `master` |

## Troubleshooting

See `references/troubleshooting.md` for common issues including:
- 401 Unauthorized errors
- Cookie/session issues
- CORS and Vite errors
- Mixed content warnings
- Database connection problems

## Important Notes

1. **Always use HTTP** - Valet secure causes Vite mixed content issues
2. **Database names use underscores** - MySQL doesn't like hyphens in unquoted identifiers
3. **Kill existing Vite** - Port conflicts cause silent failures
4. **Storage link with --force** - Overwrites existing symlinks safely
5. **Work from worktree directory** - All commands after setup must run from `.worktrees/$SANITIZED_BRANCH/`
