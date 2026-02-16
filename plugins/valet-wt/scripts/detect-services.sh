#!/bin/bash
# Detect Laravel project services from composer.json and .env
# Run from the target project root: bash ${CLAUDE_PLUGIN_ROOT}/scripts/detect-services.sh

set -e

echo "=== Laravel Project Service Detection ==="
echo ""

# Database driver (prefer php artisan about for actual running config)
DB_CONNECTION="unknown"
if command -v php &> /dev/null && [ -f artisan ]; then
    DB_CONNECTION=$(php artisan about --json 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['drivers']['database'])" 2>/dev/null || echo "")
fi
if [ -z "$DB_CONNECTION" ] || [ "$DB_CONNECTION" = "unknown" ]; then
    # Fallback to .env if artisan is not available (e.g., before composer install)
    if [ -f .env ]; then
        DB_CONNECTION=$(grep "^DB_CONNECTION=" .env | cut -d '=' -f2- | sed "s/^[\"']//;s/[\"']$//" || echo "")
    elif [ -f .env.example ]; then
        DB_CONNECTION=$(grep "^DB_CONNECTION=" .env.example | cut -d '=' -f2- | sed "s/^[\"']//;s/[\"']$//" || echo "")
    fi
fi
DB_CONNECTION=${DB_CONNECTION:-sqlite}
echo "Database: $DB_CONNECTION"

# Check composer.json for packages
if [ ! -f composer.json ]; then
    echo "Error: No composer.json found in $(pwd)"
    exit 1
fi

check_package() {
    if grep -q "\"$1\"" composer.json; then
        echo "  [x] $2 ($1)"
        return 0
    else
        echo "  [ ] $2 ($1)"
        return 1
    fi
}

echo ""
echo "Packages:"
check_package "laravel/horizon" "Horizon" || true
check_package "laravel/scout" "Scout" || true
check_package "laravel/reverb" "Reverb" || true
check_package "laravel/pulse" "Pulse" || true
check_package "laravel/octane" "Octane" || true
check_package "laravel/pail" "Pail" || true
check_package "laravel/sanctum" "Sanctum" || true
check_package "predis/predis" "Redis (predis)" || true

# Check .env.example for service-specific env vars
echo ""
echo "Services in .env.example:"
ENV_FILE=".env.example"
[ ! -f "$ENV_FILE" ] && ENV_FILE=".env"

if [ -f "$ENV_FILE" ]; then
    grep -q "MEILISEARCH_HOST" "$ENV_FILE" 2>/dev/null && echo "  [x] Meilisearch" || echo "  [ ] Meilisearch"
    grep -q "REDIS_HOST" "$ENV_FILE" 2>/dev/null && echo "  [x] Redis" || echo "  [ ] Redis"
    grep -q "SCOUT_DRIVER" "$ENV_FILE" 2>/dev/null && echo "  [x] Scout driver configured" || echo "  [ ] Scout driver"
    grep -q "BROADCAST_CONNECTION" "$ENV_FILE" 2>/dev/null && echo "  [x] Broadcasting" || echo "  [ ] Broadcasting"
else
    echo "  No .env.example or .env found"
fi

# Check for frontend tooling
echo ""
echo "Frontend:"
if [ -f package.json ]; then
    grep -q '"vite"' package.json 2>/dev/null && echo "  [x] Vite" || echo "  [ ] Vite"
    grep -q '"concurrently"' package.json 2>/dev/null && echo "  [x] Concurrently" || echo "  [ ] Concurrently (needed for run.sh)"
else
    echo "  No package.json found"
fi

# Suggested run.sh processes
echo ""
echo "=== Suggested run.sh processes ==="
PROCS=""
if grep -q "\"laravel/horizon\"" composer.json 2>/dev/null; then
    PROCS="${PROCS}horizon:php artisan horizon,"
elif grep -q "QUEUE_CONNECTION" "${ENV_FILE:-/dev/null}" 2>/dev/null; then
    QUEUE_CONN=$(grep "^QUEUE_CONNECTION=" "${ENV_FILE}" | cut -d '=' -f2- | sed "s/^[\"']//;s/[\"']$//")
    if [ "$QUEUE_CONN" != "sync" ] && [ -n "$QUEUE_CONN" ]; then
        PROCS="${PROCS}queue:php artisan queue:listen --tries=1,"
    fi
fi

grep -q "\"laravel/reverb\"" composer.json 2>/dev/null && PROCS="${PROCS}reverb:php artisan reverb:start,"
PROCS="${PROCS}schedule:php artisan schedule:work,"
grep -q "\"laravel/pail\"" composer.json 2>/dev/null && PROCS="${PROCS}logs:php artisan pail --timeout=0,"
grep -q '"vite"' package.json 2>/dev/null && PROCS="${PROCS}vite:npm run dev,"

echo "${PROCS%,}" | tr ',' '\n' | while IFS=: read -r name cmd; do
    echo "  $name → $cmd"
done

echo ""
echo "Project: $(basename "$(pwd)")"
