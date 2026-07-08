# Forge CLI v2 Gotchas

Failure modes verified against v2.0.2 source and live runs. Numbered for reference.

## 1. Failures can exit 0 — never trust the exit code alone

When a required prompt can't be answered non-interactively (e.g. a site/server/org picker with the argument omitted, or `login` without `--token`), the CLI prints a boxed error panel and **exits 0**. Verified live twice.

After any forge command, also check stdout for failure text:

```bash
forge deploy:logs 2>&1 | grep -qiE "unexpected error|Error Message:|You have not selected" && echo "FAILED despite exit code"
```

(The CLI's own error text misspells "occured" — match on `unexpected error`, not the full sentence.)

Plain `abort()` failures (missing org context, invalid PHP version) do exit 1 correctly. The exit-0 problem is specific to unanswerable prompts.

## 2. Confirmation prompts silently auto-answer YES non-interactively

`confirm()` prompts default to `true` when STDIN isn't a TTY — which is always the case when an agent runs the CLI. So `nginx:restart`, `php:restart`, `database:restart`, and the `env:pull`/`env:push` file prompts **execute immediately with no confirmation**. (`background-process:restart` is worse: it has no confirm prompt at all and restarts unconditionally in every mode.) The CLI provides zero headless protection for destructive commands. Confirmation must happen at the conversation level, before the command is issued.

## 3. Organization context is not auto-selected

Only `forge login` auto-selects an organization (and only for single-org accounts). If the token predates v2 or the account has multiple orgs, every command fails with "You have not selected an organization" until you run `forge organization:switch <slug>`. And **switching organization clears the selected server** — always follow with `forge server:switch <name>`.

## 4. No machine-readable output

There is no `--json` flag anywhere. Lists render as Unicode box tables (`┌─┬─┐`); parse by column position. `--no-ansi` strips colors but keeps box-drawing, **and spinner control sequences (`[?25l`, cursor moves) still leak into captured output**, plus an `==> You Are Using An Outdated Version...` banner may append. Filter noise:

```bash
forge server:list --no-ansi 2>&1 | grep -v '^\[' | grep -iv 'outdated version'
```

Log output lines are prefixed with a `▕` glyph.

## 5. `database:shell` cannot be automated

It always prompts for the database user's password and there is no `--password` flag. Non-interactively it correctly aborts (exit 1). Query production databases via SSH + tinker/artisan instead.

## 6. Don't run parallel `forge command` against one site

v2 resolves the created command's ID by listing commands and taking the newest. Two concurrent invocations against the same site can grab each other's command. Serialize them; parallel across *different* sites is fine.

## 7. env file naming and prompts

- With the `file` argument omitted, `env:pull`/`env:push` use `<cwd>/.env.forge.<site-id>` — **never rename or copy that file**; the site ID is re-derived from the name and push fails after a rename.
- Passing an explicit file argument to both pull and push (`forge env:pull scoutjobs.ai ./prod.env` … `forge env:push scoutjobs.ai ./prod.env`) skips every prompt and sidesteps the naming trap entirely. Prefer this.
- Sites with config caching or queue workers won't see pushed env changes until `php artisan config:clear` (via SSH) or a redeploy.

## 8. Version-check network call on every invocation

Each run may fetch `packagist.org` (cached 24h) via a bare `file_get_contents` with no try/catch. In an offline/sandboxed environment this emits a PHP warning into the output you're parsing. If output looks corrupted offline, this is why; `--quiet` suppresses it.

## 9. Binary self-reports the wrong version

v2.0.2 prints `Forge CLI 2.0.1` from `--version` and nags "You Are Using An Outdated Version [v2.0.1]" — upstream forgot to bump `config/app.php` when tagging 2.0.2. Check the installed version with `composer global show laravel/forge-cli`, not the binary.

## 10. PHP deprecation-warning alias is obsolete

The v1-era `alias forge='php -d error_reporting="E_ALL & ~E_DEPRECATED" ...'` workaround is no longer needed — v2 (PHP 8.2+ floor) runs clean even on PHP 8.5 with full error reporting. The alias is harmless if it's still in your shell profile, but don't tell users to add it.

## 11. Zero-downtime deployment paths (unchanged from v1)

If the site uses zero-downtime deploys, code lives at `/home/forge/<site>/current/` (symlink to a release); `storage/` and `.env` stay shared at `/home/forge/<site>/`. Detect the mode before running SSH commands:

```bash
ssh forge@<ip> "ls /home/forge/<site>/current >/dev/null 2>&1 && echo zero-downtime || echo standard"
```

## 12. Tinker via SSH (unchanged from v1)

`forge tinker` is interactive-only. Use SSH with `--execute`, double-escape namespace backslashes, and wrap output in `echo`/`print_r` or you'll see nothing:

```bash
ssh forge@<ip> "cd /home/forge/<site> && php artisan tinker --execute='echo App\\\\Models\\\\User::count();'"
```

## 13. API rate limiting is aggressive and bursty

Firing several forge commands in quick succession reliably triggers `Too Many Requests` from the Forge API — observed after as few as 4-6 rapid calls. The failure exits 0 (verified live: `echo $?` after a real 429 prints `0`), so check for it explicitly and back off:

```bash
until forge background-process:logs 826788 --no-ansi > /tmp/out.txt 2>&1 \
      && ! grep -qi "too many requests\|unexpected error" /tmp/out.txt; do
  sleep 20
done
```

Space non-urgent calls out rather than batching them, and never run forge commands in parallel from multiple agents.

## 14. `deploy:logs` can be broken for a site (provision-file bug)

On some sites, `forge deploy:logs <site>` reproducibly fails with `cat: /home/forge/.forge/provision-<id>.output: No such file or directory` — the API resolves the "latest deployment log" to a provisioning artifact that no longer exists on the server. Retrying, using the numeric site ID, and `-vvv` all make no difference. When this hits, get deployment evidence another way: SSH (`readlink /home/forge/<site>/current`, recent app-log activity, `git log -1` in the site directory) or the Forge dashboard.

## 15. Useful environment variables

- `FORGE_API_TOKEN` — token without `forge login` (config-file token takes precedence if both exist)
- `FORGE_API_BASE` — undocumented API base-URL override, handy for pointing the CLI at a mock server in tests
