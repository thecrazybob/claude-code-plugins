#!/bin/bash
# detect-project-name.sh
# Detects the project name from composer.json or falls back to directory name
#
# Usage: ./detect-project-name.sh [path]
# Returns: Project name (lowercase, suitable for domains/databases)
#
# Note: Skips generic names like "laravel/laravel" and uses directory name instead

set -e

PROJECT_PATH="${1:-.}"

# Get directory name as fallback
if [ "$PROJECT_PATH" = "." ]; then
    DIR_NAME=$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]')
else
    DIR_NAME=$(basename "$PROJECT_PATH" | tr '[:upper:]' '[:lower:]')
fi

# Try to get name from composer.json
if [ -f "$PROJECT_PATH/composer.json" ]; then
    COMPOSER_NAME=$(jq -r '.name // empty' "$PROJECT_PATH/composer.json" 2>/dev/null)
    if [ -n "$COMPOSER_NAME" ]; then
        # Skip generic laravel/laravel name
        if [ "$COMPOSER_NAME" = "laravel/laravel" ]; then
            echo "$DIR_NAME"
            exit 0
        fi

        # Extract part after the slash (vendor/package -> package)
        PROJECT_NAME=$(echo "$COMPOSER_NAME" | cut -d'/' -f2)
        if [ -n "$PROJECT_NAME" ]; then
            echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]'
            exit 0
        fi
    fi
fi

# Fallback to directory name
echo "$DIR_NAME"
