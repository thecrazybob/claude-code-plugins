# valet-wt Plugin

Laravel workspace scripts and git worktrees with Valet, databases, and Warp config.

## Architecture: Script-First

This plugin follows a "generate scripts first, then use them" architecture. Instead of the LLM executing 15+ inline setup steps at runtime, worktree creation becomes a single `bash scripts/setup.sh` invocation.

### How Commands Relate

```
/scripts → generates setup.sh, archive.sh, run.sh, .config/wt.toml into the project
wt switch --create → automated via .config/wt.toml hooks (preferred)
/worktree → manual fallback: creates git worktree, copies scripts, runs setup.sh
/worktree-cleanup → runs archive.sh, then git worktree remove + branch delete
/worktree-pr → commits, pushes, creates PR (independent of scripts)
```

### Generated Files

| File | What It Does |
|------|-------------|
| `scripts/setup.sh` | Full workspace setup: deps, .env, Valet link, DB creation, migrations |
| `scripts/archive.sh` | Teardown: kill Vite, unlink Valet, drop DB |
| `scripts/run.sh` | Start dev services via `npx concurrently` |
| `.config/wt.toml` | Worktrunk hooks — wires setup/archive into `wt` lifecycle + quality gates |

Scripts are **dynamic** — they detect the DB driver at runtime from `.env`, so the same scripts work across MySQL, PostgreSQL, and SQLite environments.

With `.config/wt.toml`, worktrunk (`wt`) automates the full lifecycle:
- `wt switch --create` → copies deps + runs `setup.sh` (background)
- `wt merge` → runs Pint, PHPStan, and tests before merge
- `wt remove` → runs `archive.sh` before cleanup

### Environment Variables

Scripts accept these env vars for worktree context:

| Variable | Purpose | Example |
|----------|---------|---------|
| `WT_WORKSPACE_NAME` | Workspace identifier for domains/DBs | `feature-auth` |
| `WT_ROOT_PATH` | Path to main project (for .env copy) | `/Users/bob/Sites/myapp` |
| `WT_PORT` | Vite port override | `5174` |

## Plugin Structure

```
.claude-plugin/plugin.json    # Plugin manifest
commands/
  scripts.md                  # /scripts - generate workspace scripts
  worktree.md                 # /worktree - create worktree using scripts
  worktree-pr.md              # /worktree-pr - create PR from worktree
  worktree-cleanup.md         # /worktree-cleanup - cleanup using archive.sh
skills/workspace/SKILL.md     # Merged skill: script generation + worktree management
scripts/
  detect-project-name.sh      # Derive project name from composer.json or dir
  detect-services.sh          # Scan project for services (horizon, redis, etc.)
  browse.sh                   # Open project URL in browser
references/
  database-drivers.md         # MySQL/PostgreSQL/SQLite setup/teardown commands
  troubleshooting.md          # Common worktree issues and solutions
templates/
  laravel-worktree.yaml       # Warp terminal launch configuration template
```

## Development

### Testing Commands

1. **Test `/scripts`** on a Laravel project — should generate `scripts/setup.sh`, `scripts/archive.sh`, `scripts/run.sh`
2. **Test `/worktree`** — should detect scripts, create worktree, run `setup.sh`
3. **Test `/worktree-cleanup`** — should run `archive.sh` then git cleanup
4. **Test `/worktree-pr`** — should commit, push, and create PR

### Modifying Scripts

When updating script generation logic:
- Edit `skills/workspace/SKILL.md` for the generation patterns
- Edit `commands/scripts.md` for the command flow
- Update `references/database-drivers.md` for DB-specific commands
- Test with all three DB drivers (mysql, pgsql, sqlite)
