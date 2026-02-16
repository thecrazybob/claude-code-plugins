# Worktree Troubleshooting Guide

Common issues when working with Laravel Valet worktrees and their solutions.

## Authentication & Session Issues

### 401 Unauthorized on API Requests

**Symptom:** API calls return 401 even when logged in, especially with Sanctum/SPA authentication.

**Cause:** The worktree domain is not in `SANCTUM_STATEFUL_DOMAINS`.

**Solution:**
```bash
# In .env, ensure the worktree domain is included:
SANCTUM_STATEFUL_DOMAINS=localhost,127.0.0.1,projectname-branch.test
```

Also verify:
```bash
php artisan config:clear
```

### Cookie Rejected / Session Not Persisting

**Symptom:** Login appears to succeed but user is immediately logged out, or session data is lost between requests.

**Cause:** `SESSION_DOMAIN` doesn't match the worktree domain.

**Solution:**
```bash
# In .env:
SESSION_DOMAIN=projectname-branch.test

# NOT the main project domain
# SESSION_DOMAIN=projectname.test  # WRONG
```

### Secure Cookie on HTTP

**Symptom:** Cookies not being set, authentication failing silently.

**Cause:** `SESSION_SECURE_COOKIE=true` but using HTTP.

**Solution:**
```bash
# In .env:
SESSION_SECURE_COOKIE=false
```

This is expected since we use HTTP to avoid Vite mixed content issues.

## Vite & Asset Issues

### White Page / JavaScript Not Loading

**Symptom:** Page loads but is blank, console shows CORS errors for Vite assets.

**Cause:** Vite dev server not configured for cross-origin requests.

**Solution:** Update `vite.config.js` or `vite.config.ts`:

```javascript
export default defineConfig({
    // ... plugins, etc.
    server: {
        host: 'localhost',  // Add this
        cors: true,         // Add this
        hmr: {
            host: 'localhost',
        },
    },
});
```

Then restart Vite:
```bash
pkill -f "node.*vite" && npm run dev
```

### Mixed Content Errors

**Symptom:** Console shows "Mixed Content: The page was loaded over HTTPS but requested an insecure resource."

**Cause:** Using `valet secure` with Vite dev server running on HTTP.

**Solution:** Don't use HTTPS for worktrees:
```bash
# If accidentally secured:
valet unsecure projectname-branch

# Ensure APP_URL uses http://
APP_URL=http://projectname-branch.test
```

### Assets 404 / Wrong Domain

**Symptom:** Assets return 404, or requests go to wrong domain.

**Cause:** `APP_URL` not updated, or Vite not running.

**Solution:**
```bash
# Verify APP_URL in .env:
APP_URL=http://projectname-branch.test

# Check Vite is running:
ps aux | grep vite

# If not running:
npm run dev
```

### Port Already in Use

**Symptom:** Vite fails to start with "Port 5173 is already in use."

**Cause:** Another Vite instance (from main project or another worktree) is running.

**Solution:**
```bash
# Kill all Vite processes
pkill -f "node.*vite"

# Or kill specific port
lsof -ti:5173 | xargs kill -9

# Then start fresh
npm run dev
```

### HMR (Hot Module Reload) Not Working

**Symptom:** Changes don't appear without manual refresh.

**Cause:** HMR websocket connecting to wrong host.

**Solution:** Ensure `vite.config.js` has:
```javascript
server: {
    hmr: {
        host: 'localhost',
    },
},
```

## Database Issues

### Connection Refused / Database Not Found

**Symptom:** "SQLSTATE[HY000] [1049] Unknown database" or connection refused.

**Cause:** Database wasn't created or wrong name in `.env`.

**Solution:**
```bash
# Check database name in .env uses underscores:
DB_DATABASE=projectname_branchname

# Create if missing:
mysql -u root -e "CREATE DATABASE IF NOT EXISTS projectname_branchname;"

# Verify it exists:
mysql -u root -e "SHOW DATABASES LIKE 'projectname%';"
```

### Migration Errors

**Symptom:** Migrations fail with table already exists or foreign key errors.

**Cause:** Partial migration state from failed previous run.

**Solution:**
```bash
# Fresh start (destructive):
php artisan migrate:fresh --seed

# Or drop and recreate database:
mysql -u root -e "DROP DATABASE projectname_branchname; CREATE DATABASE projectname_branchname;"
php artisan migrate --seed
```

## File & Dependency Issues

### Missing Vendor Directory

**Symptom:** "Class not found" errors, autoload failures.

**Cause:** `composer install` wasn't run in worktree.

**Solution:**
```bash
cd .worktrees/branch-name
composer install
```

### Missing Node Modules

**Symptom:** Vite won't start, npm scripts fail.

**Cause:** `npm install` wasn't run in worktree.

**Solution:**
```bash
cd .worktrees/branch-name
npm install
```

### Storage Link Broken

**Symptom:** Uploaded files 404, storage URLs broken.

**Cause:** Storage symlink missing or points to wrong location.

**Solution:**
```bash
cd .worktrees/branch-name
php artisan storage:link --force
```

### Config Cached with Old Values

**Symptom:** Environment changes not taking effect.

**Cause:** Config cache contains old values.

**Solution:**
```bash
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Or the nuclear option:
php artisan optimize:clear
```

## Git & Worktree Issues

### Worktree Locked

**Symptom:** "fatal: '$BRANCH' is already checked out" or worktree locked errors.

**Cause:** Worktree state is inconsistent.

**Solution:**
```bash
# List worktrees to see state:
git worktree list

# Prune stale worktrees:
git worktree prune

# Force remove if needed:
git worktree remove .worktrees/branch-name --force
```

### Branch Already Exists

**Symptom:** "fatal: A branch named 'X' already exists."

**Cause:** Branch exists but worktree doesn't (incomplete cleanup).

**Solution:**
```bash
# Check if it's a local branch:
git branch | grep branch-name

# Delete if unwanted:
git branch -D branch-name

# Then create worktree fresh
```

### Changes in Wrong Directory

**Symptom:** Commits appear on wrong branch, changes not visible in worktree.

**Cause:** Working in main directory instead of worktree.

**Solution:**
```bash
# Always verify you're in worktree:
pwd  # Should show .worktrees/branch-name

# Check current branch:
git branch --show-current

# All work must be in:
cd /path/to/project/.worktrees/branch-name
```

## Valet Issues

### Domain Not Resolving

**Symptom:** Browser shows "This site can't be reached" for worktree domain.

**Cause:** Valet link not created or DNS not resolving `.test` domains.

**Solution:**
```bash
# Verify link exists:
valet links

# Create if missing:
cd .worktrees/branch-name
valet link projectname-branch

# Restart Valet if DNS issues:
valet restart
```

### Wrong PHP Version

**Symptom:** Syntax errors or missing functions for code that works in main project.

**Cause:** Worktree using different PHP version.

**Solution:**
```bash
# Check PHP version:
valet which-php

# Isolate version for this site:
cd .worktrees/branch-name
valet isolate php@8.4

# Or use project-wide:
valet use php@8.4
```

## Quick Diagnostic Commands

Run these to diagnose most issues:

```bash
# From worktree directory:
cd .worktrees/branch-name

# Check you're in right place
pwd && git branch --show-current

# Check .env
grep -E "APP_URL|DB_DATABASE|SESSION_DOMAIN|SANCTUM" .env

# Check Valet
valet links | grep $(basename $(pwd))

# Check database
mysql -u root -e "SHOW DATABASES LIKE '$(grep DB_DATABASE .env | cut -d= -f2)';"

# Check dependencies
ls vendor/autoload.php && ls node_modules/.bin/vite

# Check Vite
ps aux | grep vite

# Clear everything
php artisan optimize:clear
```

## Prevention Checklist

Before starting work on a new worktree, verify:

- [ ] Working directory is `.worktrees/branch-name/`
- [ ] `APP_URL` starts with `http://` (not https)
- [ ] `SESSION_DOMAIN` matches the worktree domain
- [ ] `SESSION_SECURE_COOKIE=false`
- [ ] `SANCTUM_STATEFUL_DOMAINS` includes worktree domain
- [ ] `DB_DATABASE` uses underscores (not hyphens)
- [ ] Database exists in MySQL
- [ ] `composer install` completed
- [ ] `npm install` completed
- [ ] `php artisan storage:link --force` ran
- [ ] Vite is running (`npm run dev`)
- [ ] Config cache is cleared
