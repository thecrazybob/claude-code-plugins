---
description: Generate setup/archive/run scripts for a Laravel project
argument-hint: "[project-path]"
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion, Glob
---

# /scripts Command

Generate `scripts/setup.sh`, `scripts/archive.sh`, `scripts/run.sh`, `.config/wt.toml`, and `.codex/environments/environment.toml` for a Laravel project. These scripts handle workspace setup, teardown, and service orchestration with full database driver support (MySQL, PostgreSQL, SQLite).

## Arguments

- `project-path` (optional): Path to the target Laravel project. Defaults to current working directory.

## Workflow

### Step 1: Determine Target Project Path

If `$ARGUMENTS` is provided, use it as the project path. Otherwise, use the current working directory.

Verify it's a Laravel project:
```bash
[ -f "$TARGET/artisan" ] && [ -f "$TARGET/composer.json" ]
```

### Step 2: Check for Existing Scripts

```bash
if [ -d "$TARGET/scripts" ] && [ -f "$TARGET/scripts/setup.sh" ]; then
    # Ask user: overwrite or skip
fi
```

Use AskUserQuestion if scripts already exist:
```
header: "Scripts Exist"
question: "This project already has scripts/. What would you like to do?"
options:
  - label: "Overwrite"
    description: "Regenerate all scripts from scratch"
  - label: "Cancel"
    description: "Keep existing scripts"
```

### Step 3: Detect Services

Run the detection script from the target project directory:
```bash
cd $TARGET
bash ${CLAUDE_PLUGIN_ROOT}/scripts/detect-services.sh
```

### Step 4: Detect Database Driver

```bash
php artisan about --json 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['drivers']['database'])" 2>/dev/null
```

Fallback to reading `DB_CONNECTION` from `.env` or `.env.example` if artisan isn't available.

### Step 5: Derive Project Name

```bash
PROJECT=$(bash ${CLAUDE_PLUGIN_ROOT}/scripts/detect-project-name.sh "$TARGET")
```

### Step 6: Generate scripts/setup.sh

Create `$TARGET/scripts/setup.sh` following the 17-step structure defined in the workspace skill (Part 1: setup.sh Structure). The script must:

- Include the `env_value()` helper function
- Use `WT_WORKSPACE_NAME` and `WT_ROOT_PATH` environment variables
- Derive the worktree key using the worktree key derivation pattern
- Detect DB driver at runtime from `.env` (not hardcoded)
- Include all three DB driver branches (pgsql, mysql, sqlite) using patterns from `references/database-drivers.md`
- Use macOS-compatible `sed -i ''` for .env updates
- Valet link with HTTP only (no `valet secure`)
- Generate app key if missing
- Run `php artisan optimize:clear`, `storage:link --force`, `migrate --seed --force`
- Output a summary at the end

### Step 7: Generate scripts/archive.sh

Create `$TARGET/scripts/archive.sh` following the archive.sh structure from the workspace skill. The script must:

- Include the `env_value()` helper function
- Same workspace name and worktree key derivation as setup.sh
- Kill Vite processes scoped to workspace directory (not all Vite processes)
- `valet unsecure` then `valet unlink`
- Detect DB driver at runtime and drop database using driver-specific commands
- Output a summary of what was removed

### Step 8: Generate scripts/run.sh

Create `$TARGET/scripts/run.sh` using `npx concurrently` with only the detected services from Step 3. Follow the run.sh structure from the workspace skill.

### Step 9: Generate .config/wt.toml

Create `$TARGET/.config/wt.toml` following the wt.toml structure from the workspace skill. This wires `setup.sh` and `archive.sh` into the worktrunk (`wt`) lifecycle:

```bash
mkdir -p $TARGET/.config
```

The generated file must:

- Use `post-start` (not `post-create`) so worktree creation is non-blocking
- Copy `vendor/` and `node_modules/` from `{{ primary_worktree_path }}` before running setup.sh
- Set `WT_ROOT_PATH={{ primary_worktree_path }}` when invoking setup.sh
- Include `pre-commit` hooks for `pint --dirty` and (if `phpstan.neon`/`phpstan.neon.dist` exists) `phpstan analyse`
- Include `pre-merge` hook for `php artisan test --parallel --compact`
- Include `pre-remove` hook for `bash scripts/archive.sh`
- Set `[list] url` to `http://{project}-{{ branch | sanitize }}.test` (replace `{project}` with the detected project name)

### Step 9.5: Update .gitignore

Append `/.worktrees/` to `$TARGET/.gitignore` if not already present:

```bash
if ! grep -q '^\/?\.worktrees' "$TARGET/.gitignore" 2>/dev/null; then
    echo "" >> "$TARGET/.gitignore"
    echo "# Worktrees" >> "$TARGET/.gitignore"
    echo "/.worktrees/" >> "$TARGET/.gitignore"
fi
```

### Step 10: Generate .codex/environments/environment.toml

Create `$TARGET/.codex/environments/environment.toml`:

```bash
mkdir -p $TARGET/.codex/environments
```

Embed the contents of `setup.sh` in the TOML `[setup] script` field as a multi-line string (`'''`).

### Step 11: Set Permissions

```bash
chmod +x $TARGET/scripts/setup.sh $TARGET/scripts/archive.sh $TARGET/scripts/run.sh
```

### Step 12: Display Summary

```
## Scripts Generated

| File | Description |
|------|-------------|
| `scripts/setup.sh` | Install deps, create DB, configure .env, migrate & seed |
| `scripts/archive.sh` | Stop processes, unlink Valet, drop DB |
| `scripts/run.sh` | Run dev services via concurrently |
| `.config/wt.toml` | Worktrunk hooks (setup, quality, teardown) |
| `.codex/environments/environment.toml` | Codex environment config |

### Detected Configuration

| Item | Value |
|------|-------|
| Project | $PROJECT |
| Database Driver | $DB_CONNECTION |
| Services | horizon, vite, ... |

### Usage

- **With worktrunk:** `wt switch --create my-branch` (setup.sh runs automatically via hooks)
- **Manual setup:** `WT_WORKSPACE_NAME=my-branch bash scripts/setup.sh`
- **Run services:** `bash scripts/run.sh`
- **Manual teardown:** `WT_WORKSPACE_NAME=my-branch bash scripts/archive.sh`
- **With /worktree:** Use `/worktree` which runs setup.sh automatically
```

## Error Handling

- If not a Laravel project (no `artisan`), exit with clear message
- If `php artisan about --json` fails, fall back to `.env`/`.env.example` detection
- If `detect-services.sh` fails, fall back to manual composer.json inspection
