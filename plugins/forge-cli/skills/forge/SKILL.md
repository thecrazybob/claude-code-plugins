---
name: forge-cli
description: Debug and manage Laravel applications in production via Laravel Forge CLI and direct SSH. Activates when the user mentions production logs, debug production, forge, check production, run on server, production database, deploy, SSH to production, server logs, remote artisan, production error, or tinker production.
version: 1.2.0
---

# Laravel Forge CLI

## Overview

Laravel Forge CLI allows managing Forge-provisioned servers from the command line. Use it for debugging production issues, checking logs, and running safe read-only commands.

## Setup

```bash
# Install globally
composer global require laravel/forge-cli

# Authenticate (opens browser)
forge login

# List available servers/sites
forge server:list
forge site:list
```

### PHP 8.4 Deprecation Warnings

Forge CLI triggers deprecation warnings with PHP 8.4. Create an alias to suppress them:

```bash
# Add to ~/.zshrc or ~/.bashrc
alias forge='php -d error_reporting="E_ALL & ~E_DEPRECATED" $(which forge)'
```

## Safe Read-Only Commands

These commands are safe to run without confirmation:

### View Logs

```bash
# Application logs (Laravel logs)
forge site:logs <site>

# Deployment logs
forge deploy:logs <site>

# PHP-FPM logs
forge php:logs

# Nginx logs
forge nginx:logs
```

### Status Checks

```bash
forge php:status
forge nginx:status
forge database:status
forge server:list
forge site:list
```

### Site Information

```bash
forge site:info <site>
```

## Direct SSH (Recommended for Complex Tasks)

The `forge command` subcommand has a known bug ("Event unresolvable"). Use direct SSH instead:

### Get Server IP

```bash
forge server:list
# Note the IP address for your server
```

### Run Remote Commands

> **Note:** If zero-downtime deployments are enabled, replace `/home/forge/<site>` with `/home/forge/<site>/current` in all commands below.

```bash
# Basic structure
ssh forge@<server-ip> "cd /home/forge/<site> && <command>"

# Examples:
# Check PHP version
ssh forge@<ip> "php -v"

# Run artisan commands (read-only)
ssh forge@<ip> "cd /home/forge/<site> && php artisan --version"
ssh forge@<ip> "cd /home/forge/<site> && php artisan route:list"
ssh forge@<ip> "cd /home/forge/<site> && php artisan config:show app"

# Check queue status
ssh forge@<ip> "cd /home/forge/<site> && php artisan queue:monitor"

# View recent logs
ssh forge@<ip> "tail -100 /home/forge/<site>/storage/logs/laravel.log"
```

### Tinker (Read-Only Queries)

```bash
# IMPORTANT: Use echo to see output, escape backslashes
ssh forge@<ip> "cd /home/forge/<site> && php artisan tinker --execute='echo App\\Models\\User::count();'"

# Query examples
ssh forge@<ip> "cd /home/forge/<site> && php artisan tinker --execute='echo App\\Models\\User::where(\"email\", \"like\", \"%@example.com\")->count();'"

# Get recent records
ssh forge@<ip> "cd /home/forge/<site> && php artisan tinker --execute='print_r(App\\Models\\User::latest()->first()->toArray());'"
```

## Destructive Operations (Require Confirmation)

These commands are blocked by the safety hook and require explicit user confirmation:

### Deployment

```bash
forge deploy <site>              # Triggers deployment
forge deploy:reset <site>        # Resets deployment script
```

### Environment Changes

**Always use `env:pull` and `env:push` for environment changes** - never edit `.env` directly via SSH with `sed` or `echo` (error-prone, no backup).

> **CRITICAL: Do NOT rename or copy the `.env.forge.<id>` file!**
>
> Forge CLI internally tracks the original `.env.forge.<site-id>` filename created by `env:pull`. Renaming it (e.g., `mv .env.forge.* .env`) or copying it (`cp .env.forge.* .env`) breaks this tracking and causes `env:push` to fail with:
> `"The environment variables for that site have not been downloaded."`
>
> **Edit the `.env.forge.<site-id>` file directly, then push.**

> **CRITICAL: Always use the scratchpad directory for env:pull/env:push operations!**
>
> The `forge env:pull` command creates files in the current working directory. If run from a project root, this can **overwrite the local `.env` file** and cause data loss.
>
> **ALWAYS `cd` to the scratchpad directory first** before running `env:pull` or `env:push`.

```bash
# 1. FIRST: Change to the scratchpad directory (REQUIRED)
cd <scratchpad-directory>

# 2. Pull current .env to scratchpad
#    Creates .env.forge.<site-id> in current working directory
forge env:pull <site>
# Output: Environment Variables Written To [.env.forge.3023104]

# 3. Edit the .env.forge.<site-id> file DIRECTLY with your changes
#    DO NOT rename or copy it — Forge tracks the original filename internally
#    - Add new variables
#    - Update existing values
#    - Remove obsolete variables

# 4. Push back to production (DESTRUCTIVE)
#    Forge will prompt: "Would You Like Update The Site Environment File
#    With The Contents Of The File [.env.forge.<id>] (yes/no)"
#    Pipe "yes" to confirm non-interactively
echo "yes" | forge env:push <site>

# 5. Clean up scratchpad files
rm -f .env.forge.*

# 6. Clear config cache on the server
ssh forge@<ip> "cd /home/forge/<site> && php artisan config:clear"
```

**Example workflow:**

```bash
# ALWAYS start by changing to scratchpad
cd <scratchpad-directory>

# Pull example.com .env to scratchpad
forge env:pull example.com
# Output: Environment Variables Written To [.env.forge.3023104]

# Edit the pulled file directly (DO NOT rename)
# Use the Edit tool to add/modify variables in .env.forge.3023104

# Push back (pipe "yes" for non-interactive confirmation)
echo "yes" | forge env:push example.com

# Clean up scratchpad
rm -f .env.forge.*

# Clear config cache on server
ssh forge@<ip> "cd /home/forge/example.com && php artisan config:clear"
```

**Common mistake — DO NOT do this:**
```bash
# WRONG: Renaming breaks Forge's internal file tracking
mv .env.forge.3023104 .env
forge env:push example.com  # FAILS: "environment variables not downloaded"

# WRONG: Copying also breaks it
cp .env.forge.3023104 .env
forge env:push example.com  # FAILS: same error
```

**Why use the scratchpad:**
- **Prevents overwriting local project `.env`** - critical safety measure
- Creates an isolated workspace for production env changes
- Scratchpad is session-specific and auto-cleaned
- Keeps production credentials out of project directories

**Why this workflow is safer:**
- Creates a local backup you can review before pushing
- Avoids shell escaping issues with special characters
- Prevents accidental concatenation or corruption
- Easy to diff changes before pushing

### Database Operations via SSH

```bash
# These are BLOCKED - require confirmation:
ssh forge@<ip> "... php artisan migrate"
ssh forge@<ip> "... php artisan db:seed"
ssh forge@<ip> "mysql -e 'DELETE FROM ...'"
ssh forge@<ip> "mysql -e 'UPDATE ...'"
ssh forge@<ip> "mysql -e 'DROP ...'"
ssh forge@<ip> "mysql -e 'TRUNCATE ...'"
```

## Deployment Script Location

**The deploy script is NOT stored on the server.** It's managed via:
- Forge web dashboard: Sites → [site] → Deployments → Deploy Script
- Forge API

When Forge deploys, it sends the script remotely and executes it. Deployment logs and provisioning scripts are stored in `/home/forge/.forge/`:

```
/home/forge/.forge/
├── provision-*.sh          # Provisioning scripts (server setup)
├── provision-*.output      # Provisioning output logs
├── daemon-*.log            # Daemon/worker logs
└── scheduled-*.log         # Scheduled task logs
```

## Deployment Modes

Forge supports two deployment modes:

### Standard Deployment (Default)

Site deployed directly to `/home/forge/<site>/`:

```
/home/forge/<site>/
├── app/
├── public/
├── storage/
├── .env
└── ...
```

Use `/home/forge/<site>` for commands.

### Zero-Downtime Deployment (Optional)

When enabled, Forge uses Envoyer-style releases:

```
/home/forge/<site>/
├── current -> releases/20240115120000  # Symlink to active release
├── releases/
│   ├── 20240115120000/                 # Current release
│   ├── 20240114100000/                 # Previous release
│   └── ...
├── storage/                            # Shared storage
└── .env                               # Shared environment
```

Use `/home/forge/<site>/current` for commands.

**How to detect which mode:** Check if a `current` symlink exists:
```bash
ssh forge@<ip> "ls -la /home/forge/<site>/current 2>/dev/null || echo 'Standard deployment (no /current symlink)'"
```

## Common Debugging Workflows

### 1. Check Recent Errors

```bash
# Via Forge CLI
forge site:logs <site>

# Via SSH (more control)
ssh forge@<ip> "tail -200 /home/forge/<site>/storage/logs/laravel.log | grep -A5 'ERROR\|Exception'"
```

### 2. Check Queue Health

```bash
# Horizon status
ssh forge@<ip> "cd /home/forge/<site> && php artisan horizon:status"

# Failed jobs count
ssh forge@<ip> "cd /home/forge/<site> && php artisan tinker --execute='echo DB::table(\"failed_jobs\")->count();'"

# Recent failed jobs
ssh forge@<ip> "cd /home/forge/<site> && php artisan queue:failed"
```

### 3. Check Database State

```bash
# Record counts
ssh forge@<ip> "cd /home/forge/<site> && php artisan tinker --execute='echo App\\Models\\User::count();'"

# Check specific record
ssh forge@<ip> "cd /home/forge/<site> && php artisan tinker --execute='print_r(App\\Models\\User::find(1)?->toArray());'"
```

### 4. Check Deployment Status

```bash
# Recent deployment log
forge deploy:logs <site>

# Check site directory
ssh forge@<ip> "ls -la /home/forge/<site>"

# For zero-downtime: check current release symlink
ssh forge@<ip> "readlink /home/forge/<site>/current"
```

### 5. Check Server Resources

```bash
ssh forge@<ip> "df -h"           # Disk space
ssh forge@<ip> "free -m"         # Memory
ssh forge@<ip> "top -bn1 | head -20"  # CPU/processes
```

## Known Issues & Gotchas

1. **`forge command` is broken** - Use direct SSH instead
2. **`forge logs` doesn't exist** - Use `forge site:logs`
3. **Interactive commands don't work** - `forge ssh`, `forge tinker` can't be automated
4. **Escape backslashes in tinker** - Use `App\\Models\\User` not `App\Models\User`
5. **Use `echo` in tinker** - Output won't show without it
6. **PHP 8.4 warnings** - Use the alias with error suppression
7. **Wrong path** - Check deployment mode first; use `/current` symlink only for zero-downtime deployments
8. **Never edit .env via SSH** - Don't use `sed`, `echo >>`, or direct edits on production `.env`. Use `forge env:pull` → edit locally → `forge env:push` instead (safer, creates backup, avoids shell escaping issues)
9. **CRITICAL: env:pull/env:push in wrong directory** - ALWAYS `cd` to the scratchpad directory before running `forge env:pull` or `forge env:push`. Running from a project root will overwrite the local `.env` file!
10. **CRITICAL: Never rename `.env.forge.*` files** - Forge CLI tracks the original `.env.forge.<site-id>` filename internally. Renaming it (e.g., `mv .env.forge.* .env`) breaks tracking and `env:push` will fail. Edit the `.env.forge.<site-id>` file directly.

