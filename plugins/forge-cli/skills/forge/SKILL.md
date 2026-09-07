---
name: forge
description: Manage Laravel Forge servers and sites with Forge CLI v2, the full Forge API, and SSH. Use for Forge deployments, logs, remote Artisan commands, environment files, databases, backups, domains, certificates, queues, and server resources. Includes the official OpenAPI schema for operations the CLI does not expose.
---

# Laravel Forge CLI and API (v2)

Manage Forge-provisioned servers from the command line: read logs, check service status, run remote commands, and manage environment files. This skill covers Forge CLI **v2** (the v1 API is discontinued 2026-07-31, which takes the v1 CLI with it).

Read only the reference needed for the task:

- [references/commands.md](references/commands.md) — all 34 public CLI commands, aliases, signatures, and headless behavior.
- [references/cli-help.md](references/cli-help.md) — exact CLI usage, argument/option definitions, and hidden framework commands.
- [references/api.md](references/api.md) — authentication, schema lookup, pagination, async completion, and refresh instructions.
- [references/api-operations.md](references/api-operations.md) — every operation in the official API snapshot; use for features absent from the CLI.
- [references/openapi.json](references/openapi.json) — full request/response schemas, parameters, enums, and permissions. Extract the relevant operation and referenced components; do not load the entire file by default.
- [references/gotchas.md](references/gotchas.md) — version-specific failure modes (G1–G15).

This is a standalone Agent Skill installable with `npx skills add thecrazybob/skills --skill forge`. Claude Code plugin packaging is optional; standalone installs do not include its PreToolUse hook. Use the CLI when it covers the task, the API for other supported operations, and SSH for server-side work. Never invent CLI subcommands from API operation names.

## Setup and context model

v2 scopes everything to an **organization → server → site** chain. Commands fail with "You have not selected an organization" until context is set.

```bash
# Install/upgrade (requires PHP 8.2+)
composer global require laravel/forge-cli

# Authenticate non-interactively (bare `forge login` prompts and can't be automated)
forge login --token="<api-token>"        # or: export FORGE_API_TOKEN=<token>

# Set context — required once per machine, persists in ~/.laravel-forge/config.json
forge organization:list
forge organization:switch <org-slug>     # WARNING: this clears the selected server (G3)
forge server:list
forge server:switch <server-name>
forge site:list
```

Selecting context is a local config write — safe to run freely. If a command unexpectedly complains about missing context, check `forge organization:current` and `forge server:current` first.

## Rules for running Forge CLI non-interactively

When running without a TTY, account for these CLI behaviors:

1. **Pass every positional argument explicitly** (`site`, `server`, `organization`, background-process id) and always pass `--command=` to `forge command`. Omitted arguments open interactive pickers that fail — or worse, silently proceed with a default.
2. **Never trust the exit code alone.** Unanswerable prompts print an error panel but **exit 0** (G1). After each command, also check output for `unexpected error`, `Error Message:`, or `You have not selected`.
3. **Confirmation prompts auto-answer YES.** All `*:restart` commands and env prompts execute immediately with no confirmation when run headlessly (G2). The CLI will not protect the user — so obtain authorization for the specific mutation before issuing it (list below). Existing explicit authorization in the conversation counts; do not ask again for the same action.
4. **Resource output is human-formatted** — no resource `--json` flag. `forge list --format=json` does describe the CLI command definitions. Strip noise when parsing (G4):
   ```bash
   forge site:list --no-ansi 2>&1 | grep -v '^\[' | grep -iv 'outdated version'
   ```
5. `database:shell` cannot be automated at all (G5) — query via SSH + tinker instead.
6. **The API rate-limits bursts hard** (`Too Many Requests`, also with exit 0 — G13). Space calls out and keep read retries bounded to three attempts, honoring rate-limit headers when using the API. Avoid parallel CLI calls that amplify the limit; do not automatically retry mutations.

## Safe read-only commands

Run these freely, no confirmation needed:

```bash
forge site:logs <site>                    # Laravel application log (add --follow to tail)
forge deploy:logs <site>                  # latest deployment output
forge php:logs / nginx:logs / database:logs
forge php:status                         # or nginx:status, database:status
forge background-process:list             # queue workers, Horizon, etc. (daemon:* aliases work)
forge background-process:status <id>
forge background-process:logs <id>
forge server:list / site:list / organization:list
```

## Running commands on the server: two paths

**`forge command` — for simple one-offs at the site root.** Reliable in v2 (the v1 "Event unresolvable" bug no longer occurs). Needs only the API token, no SSH key. Don't run two of these against the same site concurrently (G6).

```bash
forge command <site> --command="php artisan --version"
forge command <site> --command="php artisan queue:failed"
```

**Direct SSH — for anything complex.** Real exit codes, arbitrary paths, pipes, tails, parallelism. Get the IP from `forge server:list`.

```bash
# Detect deployment mode first (G11): zero-downtime sites keep code in /current
ssh forge@<ip> "ls /home/forge/<site>/current >/dev/null 2>&1 && echo zero-downtime || echo standard"

ssh forge@<ip> "cd /home/forge/<site> && php artisan route:list"          # standard
ssh forge@<ip> "cd /home/forge/<site>/current && php artisan route:list" # zero-downtime
ssh forge@<ip> "tail -200 /home/forge/<site>/storage/logs/laravel.log"

# Tinker: --execute only, double-escape backslashes, echo the output (G12)
ssh forge@<ip> "cd /home/forge/<site> && php artisan tinker --execute='echo App\\\\Models\\\\User::count();'"
```

Prefer `forge command` when one artisan command answers the question; switch to SSH the moment you need pipes, non-site paths, `tail -f`, tinker, or parallel probes across servers.

## Environment file workflow

`env:push` replaces the site's production `.env` — treat the whole flow with care, and obtain authorization before pushing unless already explicitly granted.

Always work in the scratchpad directory (never a project root — a default-named pull can collide with local files) and always pass an explicit filename, which skips every prompt and makes the local file selection explicit (G7):

```bash
cd <scratchpad-directory>
forge env:pull <site> ./prod.env
# edit ./prod.env with the available file editor
forge env:push <site> ./prod.env          # Production write — requires authorization
rm -f ./prod.env

# For config-cached sites, use the authorized deployment/cache refresh workflow:
ssh forge@<ip> "cd /home/forge/<site> && php artisan config:cache"
```
Long-lived queue, Horizon, and Octane processes also need their normal authorized restart/reload workflow; refreshing the config cache alone does not reload them.

Without a file argument, the CLI uses `.env.forge.<site-id>` for the selected site. If that file is moved, pass its new path explicitly when pushing; the site comes from the site argument, not from parsing the filename.

## Production mutations — require authorization

Before a mutation, verify its target and that the user authorized the action. Ask only if that authorization is missing. The optional Claude plugin hook may separately require tool approval; standalone installs have no hook. This applies equally to CLI commands, SSH, and API writes, including:

- `forge deploy <site>` — triggers a production deployment
- `forge env:push` — replaces the production .env
- `forge php:restart / nginx:restart / database:restart / background-process:restart` — service restarts (remember G2: these run unprompted headlessly)
- `forge ssh:configure` — adds an SSH key to the server
- API resource creation, updates, deletion, deployment triggers, and service actions
- Via SSH: `php artisan migrate`, `db:seed`, or raw SQL mutations (`DELETE`/`UPDATE`/`DROP`/`TRUNCATE`/`INSERT`/`ALTER`)

## Common debugging workflows

**Recent errors:**
```bash
forge site:logs <site>
ssh forge@<ip> "tail -200 /home/forge/<site>/storage/logs/laravel.log | grep -A5 'ERROR\|Exception'"
```

**Queue/worker health:**
```bash
forge background-process:list
forge background-process:logs <id>
forge command <site> --command="php artisan queue:failed"
forge command <site> --command="php artisan horizon:status"
```

**Deployment check:**
```bash
forge deploy:logs <site>
ssh forge@<ip> "readlink /home/forge/<site>/current"   # zero-downtime: active release
```
If `deploy:logs` errors with `cat: .../provision-*.output: No such file`, that's a known per-site CLI bug (G14) — fall back to SSH evidence or the Forge dashboard.

**Server resources:**
```bash
ssh forge@<ip> "df -h; free -m; top -bn1 | head -20"
```

Deploy scripts are not stored on the server — they live in the Forge dashboard/API. Provisioning and daemon logs are under `/home/forge/.forge/` on the server.
