#!/usr/bin/env bash
# PreToolUse guard for the forge-cli plugin.
# Reads the hook payload on stdin and escalates destructive production
# commands to an explicit user approval ("ask"). Forge CLI v2 auto-confirms
# its own prompts when run without a TTY, so the harness is the only gate.
set -u

input=$(cat)

cmd=""
if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || cmd=""
fi
if [ -z "$cmd" ] && command -v python3 >/dev/null 2>&1; then
  cmd=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command","") or "")' 2>/dev/null) || cmd=""
fi
[ -z "$cmd" ] && exit 0

has() { printf '%s' "$cmd" | grep -qE "$1"; }
hasi() { printf '%s' "$cmd" | grep -qiE "$1"; }

FORGE='(^|[;&|[:space:]])forge[[:space:]]+'
reason=""

if has "${FORGE}deploy([[:space:]]|$)"; then
  reason="'forge deploy' triggers a production deployment"
elif has "${FORGE}env:push([[:space:]]|$)"; then
  reason="'forge env:push' replaces the site's production .env file"
elif has "${FORGE}(nginx|php|database|background-process|daemon):restart([[:space:]]|$)"; then
  reason="service restart on a production server (Forge CLI v2 auto-confirms this when run non-interactively)"
elif has "${FORGE}ssh:configure([[:space:]]|$)"; then
  reason="'forge ssh:configure' adds an SSH key to the production server"
fi

# Remote-execution vectors: direct ssh or forge command
if [ -z "$reason" ] && has "(^|[;&|[:space:]])ssh[[:space:]]|${FORGE}command([[:space:]]|$)"; then
  if has 'artisan[[:space:]]+migrate' && ! has 'artisan[[:space:]]+migrate:status'; then
    reason="running database migrations on production"
  elif has 'artisan[[:space:]]+db:(seed|wipe)'; then
    reason="seeding or wiping the production database"
  elif hasi '(mysql|psql)' && hasi '(^|[^a-z_])(delete|update|drop|truncate|insert|alter)([^a-z_]|$)'; then
    reason="mutating SQL against the production database"
  fi
fi

if [ -n "$reason" ]; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"Destructive production operation: %s. Confirm with the user before proceeding."}}\n' "$reason"
fi
exit 0
