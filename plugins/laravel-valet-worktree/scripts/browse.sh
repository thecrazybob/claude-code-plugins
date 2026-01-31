#!/bin/bash
# browse - Open the current Laravel project in browser
# Worktree-aware: reads APP_URL from .env if available
#
# Usage: browse
#
# Add to your shell config:
#   source ${CLAUDE_PLUGIN_ROOT}/scripts/browse.sh

function browse() {
    # If .env exists, use APP_URL (works for worktrees and regular projects)
    if [ -f .env ]; then
        url=$(grep -E "^APP_URL=" .env | cut -d '=' -f 2- | tr -d '"' | tr -d "'")
        if [ -n "$url" ]; then
            open "$url"
            return
        fi
    fi

    # Fallback: basename approach (original behavior)
    url="https://$(basename "$(pwd)").test"
    open "$url"
}
