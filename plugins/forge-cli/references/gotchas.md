# Forge CLI Gotchas

## 1. PHP 8.4 Deprecation Warnings

**Problem:** Forge CLI triggers PHP deprecation warnings that clutter output.

**Solution:** Create an alias that suppresses deprecation warnings:

```bash
alias forge='php -d error_reporting="E_ALL & ~E_DEPRECATED" $(which forge)'
```

## 2. `forge command` is Broken

**Problem:** Running `forge command <server> "<command>"` fails with "Event unresolvable dependency".

**Solution:** Use direct SSH instead:

```bash
# Instead of:
forge command server "php artisan --version"

# Use:
ssh forge@<server-ip> "cd /home/forge/<site>/current && php artisan --version"
```

## 3. Wrong Command Names

**Problem:** Some intuitive command names don't exist.

| Wrong | Correct |
|-------|---------|
| `forge logs` | `forge site:logs <site>` |
| `forge deploy-log` | `forge deploy:logs <site>` |

## 4. Zero-Downtime Deployment Paths

**Problem:** Commands run in wrong directory.

**Solution:** Always use the `current` symlink:

```bash
# Wrong - this is the parent directory
/home/forge/example.com/

# Correct - this is the active release
/home/forge/example.com/current/
```

## 5. Tinker Output Requires Echo

**Problem:** Tinker commands via SSH don't show output.

**Solution:** Wrap output in `echo` or `print_r`:

```bash
# No output:
php artisan tinker --execute='User::count();'

# With output:
php artisan tinker --execute='echo User::count();'
```

## 6. Backslash Escaping in Tinker

**Problem:** Namespaces break in SSH commands.

**Solution:** Double-escape backslashes:

```bash
# Wrong:
php artisan tinker --execute='echo App\Models\User::count();'

# Correct:
php artisan tinker --execute='echo App\\Models\\User::count();'
```

## 7. Interactive Commands Can't Be Automated

**Problem:** Some Forge commands only work interactively.

**Commands that can't be automated:**
- `forge ssh` - Opens interactive SSH session
- `forge tinker` - Opens interactive tinker
- `forge database:shell` - Opens database CLI

**Solution:** Use non-interactive alternatives:

```bash
# Instead of forge tinker:
ssh forge@<ip> "cd /home/forge/<site>/current && php artisan tinker --execute='...'"

# Instead of forge database:shell:
ssh forge@<ip> "mysql -u forge -p<password> <database> -e 'SELECT ...'"
```

## 8. Site Names vs Server Names

**Problem:** Confusing which commands take site name vs server name.

**Site name commands:**
- `forge site:logs <site>`
- `forge deploy <site>`
- `forge env:pull <site>`

**Server name commands:**
- `forge server:info <server>`
- `forge ssh <server>`

**Tip:** Use `forge site:list` and `forge server:list` to see available names.

## 9. Log Paths

**Application logs:**
```
/home/forge/<site>/current/storage/logs/laravel.log
```

**Nginx logs:**
```
/var/log/nginx/<site>-access.log
/var/log/nginx/<site>-error.log
```

**PHP-FPM logs:**
```
/var/log/php<version>-fpm.log
```

## 10. Shared vs Release-Specific Paths

**Shared (persist across deployments):**
- `/home/forge/<site>/storage/` - Laravel storage
- `/home/forge/<site>/.env` - Environment file

**Release-specific (change each deploy):**
- `/home/forge/<site>/current/` - Current code
- `/home/forge/<site>/releases/` - All releases
