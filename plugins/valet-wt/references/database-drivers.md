# Database Driver Reference

Complete commands for each supported database driver in setup.sh and archive.sh scripts.

## PostgreSQL (DB_CONNECTION=pgsql)

### Required Tool Check

```bash
if ! command -v psql &> /dev/null; then
    echo "Error: psql command is not available"
    echo "Please ensure PostgreSQL is installed and the psql CLI is in your PATH"
    exit 1
fi
```

### Read Credentials from .env

```bash
DB_HOST=$(env_value DB_HOST)
DB_PORT=$(env_value DB_PORT)
DB_USERNAME=$(env_value DB_USERNAME)
DB_PASSWORD=$(env_value DB_PASSWORD)

DB_HOST=${DB_HOST:-127.0.0.1}
DB_PORT=${DB_PORT:-5432}
DB_USERNAME=${DB_USERNAME:-postgres}

if [ -n "$DB_PASSWORD" ]; then
    export PGPASSWORD="$DB_PASSWORD"
fi
```

### Connectivity Check

```bash
if pg_isready -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USERNAME}" &>/dev/null; then
    echo "PostgreSQL reachable at ${DB_HOST}:${DB_PORT}"
else
    echo "Error: Cannot connect to PostgreSQL at ${DB_HOST}:${DB_PORT}"
    exit 1
fi
```

### Create Database (setup.sh)

```bash
if psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USERNAME}" -tc \
    "SELECT 1 FROM pg_database WHERE datname = '${DB_NAME}'" | grep -q 1; then
    echo "Database already exists: $DB_NAME"
else
    if createdb -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USERNAME}" "${DB_NAME}"; then
        echo "Database created: $DB_NAME"
    else
        echo "Error: Failed to create database '${DB_NAME}'"
        exit 1
    fi
fi
```

### Drop Database (archive.sh)

```bash
if command -v dropdb &> /dev/null; then
    if dropdb -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USERNAME}" --if-exists "${DB_NAME}" 2>/dev/null; then
        echo "Database dropped: $DB_NAME"
    else
        echo "Failed to drop database (it may not exist or credentials may be incorrect)"
    fi
else
    echo "dropdb command not found, skipping database drop"
fi
```

---

## MySQL (DB_CONNECTION=mysql)

### Required Tool Check

```bash
if ! command -v mysql &> /dev/null; then
    echo "Error: mysql command is not available"
    echo "Please ensure MySQL is installed and the mysql CLI is in your PATH"
    exit 1
fi
```

### Read Credentials from .env

```bash
DB_HOST=$(env_value DB_HOST)
DB_PORT=$(env_value DB_PORT)
DB_USERNAME=$(env_value DB_USERNAME)
DB_PASSWORD=$(env_value DB_PASSWORD)

DB_HOST=${DB_HOST:-127.0.0.1}
DB_PORT=${DB_PORT:-3306}
DB_USERNAME=${DB_USERNAME:-root}
```

### Build MySQL Auth Args

Build reusable args as an array to handle passwords with special characters safely:

```bash
MYSQL_ARGS=("-h" "${DB_HOST}" "-P" "${DB_PORT}" "-u" "${DB_USERNAME}")
if [ -n "$DB_PASSWORD" ]; then
    MYSQL_ARGS+=("-p${DB_PASSWORD}")
fi
```

### Connectivity Check

```bash
if mysqladmin "${MYSQL_ARGS[@]}" ping &>/dev/null; then
    echo "MySQL reachable at ${DB_HOST}:${DB_PORT}"
else
    echo "Error: Cannot connect to MySQL at ${DB_HOST}:${DB_PORT}"
    exit 1
fi
```

### Create Database (setup.sh)

```bash
if mysql "${MYSQL_ARGS[@]}" -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '${DB_NAME}'" 2>/dev/null | grep -q "${DB_NAME}"; then
    echo "Database already exists: $DB_NAME"
else
    if mysql "${MYSQL_ARGS[@]}" -e "CREATE DATABASE \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null; then
        echo "Database created: $DB_NAME"
    else
        echo "Error: Failed to create database '${DB_NAME}'"
        exit 1
    fi
fi
```

### Drop Database (archive.sh)

```bash
if command -v mysql &> /dev/null; then
    if mysql "${MYSQL_ARGS[@]}" -e "DROP DATABASE IF EXISTS \`${DB_NAME}\`;" 2>/dev/null; then
        echo "Database dropped: $DB_NAME"
    else
        echo "Failed to drop database (credentials may be incorrect)"
    fi
else
    echo "mysql command not found, skipping database drop"
fi
```

---

## SQLite (DB_CONNECTION=sqlite)

### Required Tool Check

No external tools required. SQLite is built into PHP.

### Read Database Path from .env

```bash
DB_DATABASE_ENV=$(env_value DB_DATABASE)
if [ -z "$DB_DATABASE_ENV" ]; then
    DB_DATABASE_ENV="database/database.sqlite"
fi

# Resolve relative paths from project root
if [[ "$DB_DATABASE_ENV" != /* ]]; then
    SQLITE_PATH="$(pwd)/${DB_DATABASE_ENV}"
else
    SQLITE_PATH="$DB_DATABASE_ENV"
fi
```

### Create Database (setup.sh)

```bash
SQLITE_DIR=$(dirname "$SQLITE_PATH")
if [ ! -d "$SQLITE_DIR" ]; then
    mkdir -p "$SQLITE_DIR"
fi

if [ -f "$SQLITE_PATH" ]; then
    echo "SQLite database already exists: $SQLITE_PATH"
else
    touch "$SQLITE_PATH"
    echo "SQLite database created: $SQLITE_PATH"
fi
```

### Drop Database (archive.sh)

```bash
if [ -f "$SQLITE_PATH" ]; then
    rm -f "$SQLITE_PATH"
    echo "SQLite database removed: $SQLITE_PATH"
else
    echo "SQLite database not found at $SQLITE_PATH (already removed)"
fi
```

### Notes for SQLite

- No connectivity check needed
- No credential management needed
- Skip DB_HOST, DB_PORT, DB_USERNAME, DB_PASSWORD updates in .env
- The DB_DATABASE .env value is the file path, not a database name
- When using workspace isolation, append the workspace name to the filename:
  ```bash
  SQLITE_PATH="$(pwd)/database/database_${WORKSPACE_NAME}.sqlite"
  ```
  And update DB_DATABASE in .env to point to this file.

---

## Driver Detection

Detect the driver using `php artisan about --json` (most reliable — reflects actual running config):

```bash
DB_CONNECTION=$(php artisan about --json 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['drivers']['database'])" 2>/dev/null)
DB_CONNECTION=${DB_CONNECTION:-sqlite}
```

This is preferred over reading `.env.example` or `.env` because the actual config may differ from the example file (e.g., `.env.example` defaults to `sqlite` but the project uses `pgsql`).

Use this to branch into the correct setup/teardown commands.
