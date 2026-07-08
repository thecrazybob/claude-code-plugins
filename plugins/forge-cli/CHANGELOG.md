# Changelog

## 2.0.0 — 2026-07-08

Rewritten for Laravel Forge CLI v2 (the v1 Forge API is discontinued 2026-07-31, which breaks CLI v1.x).

### Changed
- SKILL.md rewritten around v2's organization → server → site context model (`organization:switch`, `server:switch`, context stored in `~/.laravel-forge/config.json`).
- New "non-interactive rules" section: pass every argument explicitly, never trust exit codes alone (prompt failures exit 0), confirmation prompts silently auto-answer YES headlessly, API rate-limit backoff.
- Remote execution is now hybrid: `forge command` (reliable in v2; the v1 "Event unresolvable" bug no longer occurs) for simple site-root one-offs, direct SSH for tinker/tails/pipes/parallel work.
- Env workflow now recommends explicit filenames for `env:pull`/`env:push` (skips all prompts, avoids the `.env.forge.<id>` rename trap).
- Reference docs moved from plugin root into `skills/forge/references/` and linked from SKILL.md (progressive disclosure); rewritten from v2 source: full 32-command inventory with signatures/aliases/safety flags, and 15 verified gotchas.

### Added
- `hooks/hooks.json` + `scripts/guard-forge.sh`: PreToolUse hook that escalates destructive commands (`forge deploy`, `env:push`, `*:restart`, `ssh:configure`, remote migrations/seeds/mutating SQL) to explicit user approval. Needed because v2 auto-confirms its own prompts when run without a TTY.

### Removed
- Fictional commands that never existed in any CLI version (`site:info`, `server:info`, `server:reboot`, `deploy:reset`, `database:list`, `forge logs`).
- Stale guidance: "`forge command` is broken", PHP 8.4 deprecation-warning alias as required setup (no longer needed on v2).

## 1.2.0

Forge CLI v1 skill (safe read-only commands, SSH-first debugging, env:pull/push workflow).
