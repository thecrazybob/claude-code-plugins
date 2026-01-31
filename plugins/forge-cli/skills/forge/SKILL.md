---
name: forge-cli
description: Debug and manage Laravel applications in production via Laravel Forge CLI and direct SSH. Activates when the user mentions production logs, debug production, forge, check production, run on server, production database, deploy, SSH to production, server logs, remote artisan, production error, or tinker production.
version: 1.0.0
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

```bash
# Basic structure
ssh forge@<server-ip> "cd /home/forge/<site>/current && <command>"

# Examples:
# Check PHP version
ssh forge@<ip> "php -v"

# Run artisan commands (read-only)
ssh forge@<ip> "cd /home/forge/<site>/current && php artisan --version"
ssh forge@<ip> "cd /home/forge/<site>/current && php artisan route:list"
ssh forge@<ip> "cd /home/forge/<site>/current && php artisan config:show app"

# Check queue status
ssh forge@<ip> "cd /home/forge/<site>/current && php artisan queue:monitor"

# View recent logs
ssh forge@<ip> "tail -100 /home/forge/<site>/current/storage/logs/laravel.log"
```

### Tinker (Read-Only Queries)

```bash
# IMPORTANT: Use echo to see output, escape backslashes
ssh forge@<ip> "cd /home/forge/<site>/current && php artisan tinker --execute='echo App\\Models\\User::count();'"

# Query examples
ssh forge@<ip> "cd /home/forge/<site>/current && php artisan tinker --execute='echo App\\Models\\User::where(\"email\", \"like\", \"%@example.com\")->count();'"

# Get recent records
ssh forge@<ip> "cd /home/forge/<site>/current && php artisan tinker --execute='print_r(App\\Models\\User::latest()->first()->toArray());'"
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

```bash
# 1. Pull current .env to local file
#    Creates .env.forge.<random-id> in current working directory
forge env:pull <site>
# Output: Environment Variables Written To [.env.forge.2922612]

# 2. Edit the local .env.forge.* file with your changes
#    - Add new variables
#    - Update existing values
#    - Remove obsolete variables

# 3. Rename to .env for pushing (forge env:push reads from .env)
mv .env.forge.* .env

# 4. Push the updated .env back to production (DESTRUCTIVE)
forge env:push <site>

# 5. Clean up and clear config cache on the server
rm .env
ssh forge@<ip> "cd /home/forge/<site>/current && php artisan config:clear"
```

**Example workflow:**

```bash
# Pull scoutjobs.ai .env (creates .env.forge.<id> in cwd)
forge env:pull scoutjobs.ai

# Rename for editing
mv .env.forge.* .env

# Edit locally (safer than SSH, easy to review)
code .env  # or vim .env

# Push back
forge env:push scoutjobs.ai

# Clean up local file and clear cache
rm .env
ssh forge@91.98.234.156 "cd /home/forge/scoutjobs.ai/current && php artisan config:clear"
```

**Why this is safer:**
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

## Zero-Downtime Deployment Path

Forge uses Envoyer-style zero-downtime deployments:

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

**Always use `/home/forge/<site>/current`** for commands, not `/home/forge/<site>` directly.

## Common Debugging Workflows

### 1. Check Recent Errors

```bash
# Via Forge CLI
forge site:logs <site>

# Via SSH (more control)
ssh forge@<ip> "tail -200 /home/forge/<site>/current/storage/logs/laravel.log | grep -A5 'ERROR\|Exception'"
```

### 2. Check Queue Health

```bash
# Horizon status
ssh forge@<ip> "cd /home/forge/<site>/current && php artisan horizon:status"

# Failed jobs count
ssh forge@<ip> "cd /home/forge/<site>/current && php artisan tinker --execute='echo DB::table(\"failed_jobs\")->count();'"

# Recent failed jobs
ssh forge@<ip> "cd /home/forge/<site>/current && php artisan queue:failed"
```

### 3. Check Database State

```bash
# Record counts
ssh forge@<ip> "cd /home/forge/<site>/current && php artisan tinker --execute='echo App\\Models\\User::count();'"

# Check specific record
ssh forge@<ip> "cd /home/forge/<site>/current && php artisan tinker --execute='print_r(App\\Models\\User::find(1)?->toArray());'"
```

### 4. Check Deployment Status

```bash
# Recent deployment log
forge deploy:logs <site>

# Check current release
ssh forge@<ip> "ls -la /home/forge/<site>/current"
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
7. **Wrong path** - Always use `/current` symlink, not the site root
8. **Never edit .env via SSH** - Don't use `sed`, `echo >>`, or direct edits on production `.env`. Use `forge env:pull` → edit locally → `forge env:push` instead (safer, creates backup, avoids shell escaping issues)

## ScoutJobs-Specific

```bash
# Server: scoutjobs.ai production
# Site: scoutjobs.ai

# Quick checks
forge site:logs scoutjobs.ai
ssh forge@<ip> "cd /home/forge/scoutjobs.ai/current && php artisan horizon:status"

# Check job listings
ssh forge@<ip> "cd /home/forge/scoutjobs.ai/current && php artisan tinker --execute='echo App\\Models\\JobListing::count();'"
```
