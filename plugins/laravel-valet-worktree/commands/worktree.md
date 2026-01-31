---
description: Create a new Laravel worktree with Valet, DB, and Warp config
argument-hint: "[branch-name]"
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion, Glob
---

# /worktree Command

Create a new git worktree for a Laravel project served by Laravel Valet.

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

### Step 4: Create Worktree

```bash
git worktree add .worktrees/$SANITIZED_BRANCH -b $BRANCH $BASE_BRANCH
```

### Step 5: Link with Valet (HTTP only)

```bash
cd .worktrees/$SANITIZED_BRANCH
valet link $PROJECT-$SANITIZED_BRANCH
```

**IMPORTANT:** Do NOT run `valet secure`. HTTP avoids Vite mixed content issues.

### Step 6: Configure Environment

```bash
cp ../../.env .env
```

Update these values in `.env`:

| Key | Value |
|-----|-------|
| `APP_URL` | `http://$PROJECT-$SANITIZED_BRANCH.test` |
| `SESSION_DOMAIN` | `$PROJECT-$SANITIZED_BRANCH.test` |
| `SESSION_SECURE_COOKIE` | `false` |
| `DB_DATABASE` | `${PROJECT}_${SANITIZED_BRANCH}` (use underscores for MySQL) |

**For SANCTUM_STATEFUL_DOMAINS**, append the worktree domain if it exists.

### Step 7: Create Database

```bash
DB_NAME=$(echo "${PROJECT}_${SANITIZED_BRANCH}" | tr '-' '_')
mysql -u root -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
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

Check if `vite.config.js` or `vite.config.ts` has CORS settings. If missing, add:

```javascript
server: {
    host: 'localhost',
    cors: true,
}
```

### Step 12: Run Migrations

```bash
php artisan migrate:fresh --seed
```

### Step 13: Setup Warp Launch Configuration

```bash
mkdir -p ~/.warp/launch_configurations

WORKTREE_PATH="$(pwd)"
sed -e "s|{{WORKTREE_PATH}}|$WORKTREE_PATH|g" \
    -e "s|{{WORKTREE_NAME}}|$SANITIZED_BRANCH|g" \
    ${CLAUDE_PLUGIN_ROOT}/templates/laravel-worktree.yaml \
    > ~/.warp/launch_configurations/laravel-worktree.yaml
```

### Step 14: Display Summary

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
2. **Start Vite:** Run `npm run dev` (or use the Warp layout)
3. **Open in browser:** Run `browse` or visit the URL above

### Useful Commands

| Command | Description |
|---------|-------------|
| `browse` | Open project in browser |
| `opendb` | Open database in GUI |
| `p` | Run tests |
| `a` | php artisan shortcut |

**IMPORTANT:** All subsequent work must use the worktree directory:
`.worktrees/$SANITIZED_BRANCH/`
```

## Error Handling

- If worktree already exists, offer to enter it instead of creating
- If Valet link fails, suggest running `valet install`
- If MySQL fails, check if MySQL is running
- If branch already exists, offer to use existing branch
