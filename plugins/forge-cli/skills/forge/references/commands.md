# Forge CLI v2 Command Reference

Verified against forge-cli v2.0.2 source (`app/Commands/`) and `forge list`. Every command is listed with its exact signature, the context it needs, what happens when run non-interactively with arguments omitted, and whether it mutates anything.

Global options on every command: `-h/--help`, `-q/--quiet`, `--silent`, `-n/--no-interaction`, `--ansi/--no-ansi`, `-v/-vv/-vvv`, `-V/--version`, `--env[=ENV]`.

**Golden rule: pass every positional argument and option explicitly.** Omitted arguments trigger Laravel Prompts pickers that either fail confusingly (exit code 0!) or silently pick a default. See [gotchas.md](gotchas.md) #1 and #2. (In `--help` output most of these arguments show as optional `[<arg>]` — they're written as required below because omitting them falls through to those prompts, which you must avoid.)

## Authentication

| Command | Signature | Notes | Mutates |
|---------|-----------|-------|---------|
| `login` | `forge login --token=<token>` | Without `--token`: interactive password prompt, fails non-interactively (exit 0!). Auto-selects the organization only if the account has exactly one. `FORGE_API_TOKEN` env var also works (config-file token wins if both present). | Local config only |
| `logout` | `forge logout` | Clears `~/.laravel-forge/config.json` | Local config only |

## Context: organization → server

All other commands require an active organization; most require an active server. Context lives in `~/.laravel-forge/config.json`.

| Command | Signature | Aliases | Mutates |
|---------|-----------|---------|---------|
| `organization:list` | `forge organization:list` | `org:list` | No |
| `organization:current` | `forge organization:current` | `org:current` | No |
| `organization:switch` | `forge organization:switch <slug-or-name>` | `org:switch` | Local config only — **also clears the selected server** |
| `server:list` | `forge server:list` | | No |
| `server:current` | `forge server:current` | `current` | No |
| `server:switch` | `forge server:switch <name-or-id>` | `switch` | Local config only |

## Sites, deploys, logs

| Command | Signature | Non-interactive behavior | Mutates |
|---------|-----------|--------------------------|---------|
| `site:list` | `forge site:list` | — | No |
| `site:logs` | `forge site:logs <site> [--follow]` | Site picker fails if `<site>` omitted | No |
| `deploy:logs` | `forge deploy:logs <site>` | Same | No |
| `deploy` | `forge deploy <site>` | Same | **Yes — triggers a deployment** |
| `open` | `forge open <site>` | Opens forge.laravel.com in browser | No |

`<site>` accepts the site name (e.g. `scoutjobs.ai`) or numeric ID.

## Remote execution

| Command | Signature | Non-interactive behavior | Mutates |
|---------|-----------|--------------------------|---------|
| `command` | `forge command <site> --command="<cmd>"` | If `--command` omitted, **silently runs an empty command** (text prompt defaults to `''`). Always pass it. | Depends on the command |
| `ssh` | `forge ssh <server> [--user=]` | Interactive session only — do not use for automation; use direct `ssh forge@<ip>` | — |
| `tinker` | `forge tinker <site>` | Interactive only — use SSH + `php artisan tinker --execute=` instead | — |

`forge command` runs at the site root, creates a Command resource, polls its status (`waiting → running → finished/failed`), then prints output. The v1 "Event unresolvable" bug no longer occurs in v2. Residual caveat: it resolves the created command's ID by listing and taking the newest — don't run multiple `forge command` invocations against the same site concurrently.

## Environment files

| Command | Signature | Non-interactive behavior | Mutates |
|---------|-----------|--------------------------|---------|
| `env:pull` | `forge env:pull <site> [file]` | With explicit `[file]`: no prompts. Without: writes `.env.forge.<site-id>` in cwd, and an "overwrite?" confirm **silently auto-answers yes** | Local file |
| `env:push` | `forge env:push <site> [file]` | With explicit `[file]`: no prompts. Without: reads `.env.forge.<site-id>` and the upload/delete confirms **silently auto-answer yes** | **Yes — replaces the site's production .env** |

## Services (per selected server)

| Command | Signature | Notes | Mutates |
|---------|-----------|-------|---------|
| `php:status` | `forge php:status [version]` | Version must be one of 5.6–8.5 or it aborts (exit 1) | No |
| `php:logs` | `forge php:logs [version]` | | No |
| `php:restart` | `forge php:restart [version]` | Confirm prompt **auto-answers yes** non-interactively | **Yes** |
| `nginx:status` | `forge nginx:status` | | No |
| `nginx:logs` | `forge nginx:logs [type=error]` | `type` is `error` or `access` | No |
| `nginx:restart` | `forge nginx:restart` | Confirm **auto-answers yes** | **Yes** |
| `database:status` | `forge database:status` | | No |
| `database:logs` | `forge database:logs` | | No |
| `database:restart` | `forge database:restart` | Confirm **auto-answers yes** | **Yes** |
| `database:shell` | `forge database:shell [db] [--user=forge]` | **Not automatable** — always prompts for a password with no flag alternative; aborts (exit 1) non-interactively | — |

## Background processes (formerly daemons)

`daemon:*` names still work as aliases.

| Command | Signature | Mutates |
|---------|-----------|---------|
| `background-process:list` | `forge background-process:list` | No |
| `background-process:status` | `forge background-process:status <id>` | No |
| `background-process:logs` | `forge background-process:logs <id> [--follow]` | No |
| `background-process:restart` | `forge background-process:restart <id>` | **Yes** |

## SSH key management

| Command | Signature | Mutates |
|---------|-----------|---------|
| `ssh:configure` | `forge ssh:configure <server> --key=<path> --name=<name> [--user=forge]` | Yes — adds a key to the server |
| `ssh:test` | `forge ssh:test <server> [--key=]` | No |

**`ssh:configure` danger:** if `--key` is omitted, the key-selection prompt defaults to its first option non-interactively — which is **"Create new key"** — so the command silently generates a brand-new local SSH keypair and uploads it to the production server. Always pass `--key`. (`--name` and `--user` have safe defaults: current OS username and `forge`.)

## Commands that do NOT exist (do not invent these)

`forge logs`, `forge site:info`, `forge server:info`, `forge server:reboot`, `forge deploy:reset`, `forge database:list` — none of these exist in v1 or v2. Use `site:list`/`server:list` tables, `site:logs`, and the Forge dashboard for anything else.
