---
name: workspace
description: |
  Manages Laravel workspace scripts and git worktrees with Valet. Activates when the user mentions:
  - "worktree", "work tree", "new worktree", "create worktree"
  - "create setup scripts", "generate archive script", "create run.sh"
  - "scaffold workspace scripts", "create Codex environment"
  - "valet worktree", "cleanup worktree", "finish worktree"
  - "branch workflow", "feature branch setup", "parallel development"
---

# Laravel Workspace & Worktree Skill

This skill covers two related workflows:
1. **Script Generation** — Generate `setup.sh`, `archive.sh`, `run.sh`, and Codex environment config for a Laravel project
2. **Worktree Management** — Create isolated development environments using git worktrees, powered by those generated scripts

---

## Part 1: Script Generation

Generate setup, archive, and run scripts for Laravel applications. Scripts support MySQL, PostgreSQL, and SQLite databases, detect project services from composer.json and .env, and include Conductor/Codex worktree integration.

### What Gets Generated

| File | Purpose |
|---|---|
| `scripts/setup.sh` | Install deps, create DB, configure .env, migrate & seed |
| `scripts/archive.sh` | Stop processes, unlink Valet, drop DB, clean up |
| `scripts/run.sh` | Run detected dev services (horizon, queue, vite, etc.) via concurrently |
| `.codex/environments/environment.toml` | Codex environment config embedding the setup script |

### Detection Workflow

Before generating scripts, inspect the target project to determine:

**Database driver** — Run `php artisan about --json` and read `drivers.database` to determine what the project actually uses. Display this in the detection summary shown to the user.
- `pgsql` → PostgreSQL commands (psql, createdb, dropdb, pg_isready)
- `mysql` → MySQL commands (mysql, mysqladmin)
- `sqlite` → File-based (touch database file, rm to clean)

This is more reliable than reading `.env.example` or `.env` because the actual running config may differ.

**IMPORTANT — Dynamic scripts:** The generated setup.sh and archive.sh scripts must detect the DB driver **at runtime** by reading `DB_CONNECTION` from `.env` after the copy step. Do NOT hardcode a single driver. Include all driver branches (pgsql, mysql, sqlite) in every generated script.

**Project name** — Derive via `${CLAUDE_PLUGIN_ROOT}/scripts/detect-project-name.sh`. Use lowercase, hyphenated form for Valet domains and underscored form for database names.

**Services** — Run `${CLAUDE_PLUGIN_ROOT}/scripts/detect-services.sh` from the target project root, or scan `composer.json` `require` keys and `.env.example` for:

| Service | Detection | Impact |
|---|---|---|
| Horizon | `laravel/horizon` in composer.json | Add to run.sh, check Redis connectivity |
| Meilisearch/Scout | `laravel/scout` + `MEILISEARCH_HOST` in .env | Add fallback to null driver if unreachable |
| Redis | `REDIS_HOST` in .env or `predis/predis` in composer.json | Add connectivity check |
| Reverb | `laravel/reverb` in composer.json | Add `reverb:start` to run.sh |
| Pulse | `laravel/pulse` in composer.json | Note in setup output |
| Octane | `laravel/octane` in composer.json | Use `octane:start` instead of `serve` in run.sh |
| Pail | `laravel/pail` in composer.json | Add `pail --timeout=0` to run.sh |

**Frontend** — Check `package.json` for Vite (default) or other build tools.

### setup.sh Structure

Follow this order exactly:

1. **Tool checks** — Verify php, composer, npm, valet exist (DB CLI tools checked later based on driver)
2. **Workspace name** — `CONDUCTOR_WORKSPACE_NAME` fallback to `basename $PWD`
3. **Codex worktree key** — Extract from path if inside `~/.codex/worktrees/<id>/`
4. **Root path** — `CONDUCTOR_ROOT_PATH` fallback to `$(dirname "$0")/..`
5. **Install dependencies** — `composer install` with retry, `npm install`
6. **Setup .env** — Copy from root path or `.env.example`, handle broken symlinks
7. **Valet link** — `{project}-{worktree_key}.test`, HTTP only (no `valet secure`)
8. **Detect DB driver** — Read `DB_CONNECTION` from `.env` (after copy), default to `sqlite`
9. **Create database** — Branch on driver: pgsql (createdb), mysql (CREATE DATABASE), sqlite (touch file). See `references/database-drivers.md`
10. **Update .env** — DB_DATABASE, APP_URL, SESSION_DOMAIN, SESSION_SECURE_COOKIE, SANCTUM_STATEFUL_DOMAINS
11. **Service checks** — Disable unreachable services (e.g., Scout → null driver)
12. **App key** — Generate if missing
13. **Cache clear** — `php artisan optimize:clear`
14. **Storage link** — `php artisan storage:link --force`
15. **Vite port** — Configure from `CONDUCTOR_PORT` if available
16. **Migrate & seed** — `php artisan migrate --seed --force`
17. **Summary output** — URL, database name/path, next steps

### archive.sh Structure

1. **Workspace name & variables** — Same derivation as setup.sh
2. **Stop processes** — Kill Vite processes scoped to workspace directory
3. **Valet cleanup** — `valet unsecure` (backwards compat) then `valet unlink`
4. **Drop database** — Driver-specific commands (see `references/database-drivers.md`)
5. **Summary output** — What was removed

### run.sh Structure

Use `npx concurrently` with named, color-coded processes. Only include detected services:

```bash
npx concurrently -k \
    -n "horizon,schedule,logs,vite" \
    -c "#93c5fd,#c4b5fd,#fb7185,#fdba74" \
    "php artisan horizon" \
    "php artisan schedule:work" \
    "php artisan pail --timeout=0" \
    "npm run dev"
```

Common process mappings:
- Horizon → `php artisan horizon` (requires Redis)
- Queue (no Horizon) → `php artisan queue:listen --tries=1`
- Scheduler → `php artisan schedule:work`
- Logs → `php artisan pail --timeout=0`
- Vite → `npm run dev`
- Reverb → `php artisan reverb:start`

### environment.toml Structure

```toml
# THIS IS AUTOGENERATED. DO NOT EDIT MANUALLY
version = 1
name = "{project-name}"

[setup]
script = '''
{contents of setup.sh}
'''
```

### Key Patterns

#### .env Manipulation Helper

Include this function in both setup.sh and archive.sh:

```bash
env_value() { grep "^$1=" .env | cut -d '=' -f2- | sed "s/^[\"']//;s/[\"']$//"; }
```

#### .env Key Update Pattern (macOS-compatible sed)

```bash
if grep -q "^KEY=" .env; then
    sed -i '' "s/^KEY=.*/KEY=value/" .env
else
    echo "KEY=value" >> .env
fi
```

#### Worktree Key Derivation

```bash
WORKTREE_KEY="$WORKSPACE_NAME"
if [[ "$PWD" =~ /worktrees/([^/]+)/ ]]; then
    WORKTREE_KEY="${BASH_REMATCH[1]}"
fi
WORKTREE_KEY=$(echo "$WORKTREE_KEY" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9-' '-')
WORKTREE_KEY="${WORKTREE_KEY#-}"
WORKTREE_KEY="${WORKTREE_KEY%-}"
if [ -z "$WORKTREE_KEY" ]; then
    WORKTREE_KEY="$WORKSPACE_NAME"
fi
```

#### Database Naming

Sanitize hyphens to underscores for all DB drivers. Validate before use:
```bash
DB_NAME=$(echo "{project}_{workspace}" | tr '-' '_')
if [[ ! "$DB_NAME" =~ ^[a-zA-Z0-9_]+$ ]]; then
    echo "Error: Invalid database name '$DB_NAME'"; exit 1
fi
```

**Note:** The `scripts/setup.sh` version uses `{project}_{workspace}` (2 parts). The `.codex/environments/environment.toml` version uses `{project}_{workspace}_{worktree}` (3 parts) because Codex worktrees need unique databases per worktree. Match the convention to the target.

#### Vite Process Killing (archive.sh)

Kill only Vite processes scoped to the current workspace directory:
```bash
WORKSPACE_DIR="$(pwd)"
VITE_KILLED=0
for pid in $(pgrep -f "node.*vite" 2>/dev/null); do
    if lsof -p "$pid" 2>/dev/null | grep -q "$WORKSPACE_DIR"; then
        kill "$pid" 2>/dev/null && VITE_KILLED=$((VITE_KILLED + 1)) || true
    fi
done
```

### File Permissions

After generating scripts, make them executable:
```bash
chmod +x scripts/setup.sh scripts/archive.sh scripts/run.sh
```

### Reference Files

- **`references/database-drivers.md`** — Complete database setup/teardown commands for MySQL, PostgreSQL, and SQLite with connectivity checks, creation, and cleanup

---

## Part 2: Worktree Management

### Overview

This skill manages git worktrees for Laravel projects served by Laravel Valet. It creates isolated development environments where each feature branch gets its own:
- Directory (in `.worktrees/`)
- Valet domain (`projectname-branchname.test`)
- Database (`projectname_branchname`)
- Vite dev server instance

This enables parallel work on multiple features without switching branches or corrupting shared state.

### Initial Flow

**ALWAYS start by checking for existing worktrees:**

```bash
git worktree list
```

#### If worktrees exist:

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

#### If no worktrees exist:

Proceed directly to asking for the branch name.

### Setup Workflow (Scripts-Based)

**Pre-requisite:** The project must have `scripts/setup.sh`. If missing, generate scripts first using the `/scripts` command or the script generation workflow in Part 1.

#### Step 1: Get Branch Name

Use AskUserQuestion:

```
header: "Branch Name"
question: "What branch name do you want to create for this worktree?"
```

**Sanitize the branch name:**
```bash
SANITIZED_BRANCH=$(echo "$BRANCH" | tr '/' '-' | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
```

#### Step 2: Detect Project Name

```bash
PROJECT=$(${CLAUDE_PLUGIN_ROOT}/scripts/detect-project-name.sh)
```

#### Step 3: Detect Base Branch

```bash
BASE_BRANCH=$(git config init.defaultBranch 2>/dev/null || echo "main")
git show-ref --verify --quiet refs/heads/$BASE_BRANCH || BASE_BRANCH="master"
```

#### Step 4: Check for Scripts

```bash
if [ ! -f scripts/setup.sh ]; then
    # Inform user and trigger /scripts generation first
fi
```

#### Step 5: Create Worktree

```bash
git worktree add .worktrees/$SANITIZED_BRANCH -b $BRANCH $BASE_BRANCH
```

#### Step 6: Copy Scripts

```bash
cp -r scripts/ .worktrees/$SANITIZED_BRANCH/scripts/
```

#### Step 7: Run setup.sh

```bash
cd .worktrees/$SANITIZED_BRANCH
CONDUCTOR_WORKSPACE_NAME=$SANITIZED_BRANCH \
CONDUCTOR_ROOT_PATH=$(cd ../.. && pwd) \
bash scripts/setup.sh
```

This single command replaces the old 15 inline steps (Valet link, .env config, DB creation, dependencies, migrations, etc.).

#### Step 8: Fix Vite Configuration (if needed)

Check if `vite.config.js` or `vite.config.ts` has CORS settings. If missing, add:

```javascript
server: {
    host: 'localhost',
    cors: true,
}
```

#### Step 9: Setup Warp Launch Configuration

Skip if `~/.warp/` doesn't exist.

```bash
mkdir -p ~/.warp/launch_configurations

WORKTREE_PATH="$(pwd)"
sed -e "s|{{WORKTREE_PATH}}|$WORKTREE_PATH|g" \
    -e "s|{{WORKTREE_NAME}}|$SANITIZED_BRANCH|g" \
    ${CLAUDE_PLUGIN_ROOT}/templates/laravel-worktree.yaml \
    > ~/.warp/launch_configurations/laravel-worktree.yaml
```

#### Step 10: Display Summary

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

**IMPORTANT:** All subsequent work must use the worktree directory:
`.worktrees/$SANITIZED_BRANCH/`
```

### Finishing Workflow

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

#### Option A: Create PR

1. Gather task info (optional)
2. Commit changes
3. Push and create PR: `git push -u origin HEAD && gh pr create --fill`
4. After PR is merged, cleanup using `archive.sh` then git cleanup:
   ```bash
   cd .worktrees/$SANITIZED_BRANCH
   CONDUCTOR_WORKSPACE_NAME=$SANITIZED_BRANCH bash scripts/archive.sh
   cd ../..
   git worktree remove .worktrees/$SANITIZED_BRANCH --force
   git branch -D $BRANCH
   ```

#### Option B: Transfer to Main

1. Merge with no-commit: `git merge .worktrees/$SANITIZED_BRANCH --no-commit --no-ff`
2. If conflicts, help resolve them
3. Cleanup using archive.sh + git cleanup (same as above)

#### Option C: Abandon

1. Confirm with user (destructive action)
2. Run archive.sh then git cleanup (same as above)

### Quick Reference

| Item | Pattern |
|------|---------|
| Worktree path | `.worktrees/{sanitized-branch}/` |
| Domain | `{project}-{sanitized-branch}.test` |
| Database | `{project}_{sanitized_branch}` |
| Protocol | HTTP only (no SSL) |
| Setup | `bash scripts/setup.sh` |
| Teardown | `bash scripts/archive.sh` + git cleanup |
| Services | `bash scripts/run.sh` |

### Variable Naming

| Variable | Description | Example |
|----------|-------------|---------|
| `$BRANCH` | Original branch name | `feature/user-auth` |
| `$SANITIZED_BRANCH` | Filesystem-safe version | `feature-user-auth` |
| `$PROJECT` | Project name | `myproject` |
| `$BASE_BRANCH` | Main branch | `main` or `master` |

### Troubleshooting

See `references/troubleshooting.md` for common issues including:
- 401 Unauthorized errors
- Cookie/session issues
- CORS and Vite errors
- Mixed content warnings
- Database connection problems

### Important Notes

1. **Always use HTTP** — Valet secure causes Vite mixed content issues
2. **Database names use underscores** — MySQL doesn't like hyphens in unquoted identifiers
3. **Kill existing Vite** — Port conflicts cause silent failures
4. **Storage link with --force** — Overwrites existing symlinks safely
5. **Work from worktree directory** — All commands after setup must run from `.worktrees/$SANITIZED_BRANCH/`
6. **Scripts must exist** — Generate with `/scripts` before creating worktrees
