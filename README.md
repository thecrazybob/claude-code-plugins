# Claude Code Plugins

Laravel development plugins for [Claude Code](https://claude.ai/code).

## Available Plugins

### forge-cli

Debug and manage Laravel apps in production via Forge CLI **v2** and SSH. (Forge's v1 API — and with it CLI 1.x — is discontinued on 2026-07-31; this plugin targets `laravel/forge-cli` ^2.0.)

**Features:**
- v2 organization → server → site context model (`organization:switch`, `server:switch`)
- View production logs (application, deployment, PHP, Nginx, database, background processes)
- Run safe read-only commands on production, via `forge command` or direct SSH
- Check queue worker / Horizon / background-process health
- Debug production issues with Tinker over SSH
- Manage environment variables safely (explicit-filename `env:pull`/`env:push` workflow)
- PreToolUse guard hook that escalates destructive commands (deploy, env:push, restarts, remote migrations/SQL writes) to explicit user approval — Forge CLI v2 silently auto-confirms its own prompts when run non-interactively
- Reference docs for all 32 v2 commands and 15 source-verified gotchas

**Activates when mentioning:**
- "production logs", "debug production", "forge"
- "check production", "run on server", "production database"
- "deploy", "SSH to production", "server logs", "queue health"

## Installation

### Add Marketplace

```bash
/plugin marketplace add thecrazybob/claude-code-plugins
```

### Install Plugins

```bash
# Install forge-cli
/plugin install forge-cli@thecrazybob-plugins
```

### Or Install Locally (Development)

```bash
# Clone the repository
git clone git@github.com:thecrazybob/claude-code-plugins.git

# Add local marketplace
/plugin marketplace add ./claude-code-plugins

# Install from local
/plugin install forge-cli@thecrazybob-plugins
```

## Requirements

### forge-cli

- PHP 8.2+ and [Laravel Forge CLI](https://forge.laravel.com/docs/cli) v2 installed (`composer global require laravel/forge-cli`)
- Forge CLI authenticated (`forge login --token=...`) with an organization and server selected (`forge organization:switch`, `forge server:switch`)
- SSH access to your Forge servers (optional but recommended for complex debugging)

## License

MIT License - see [LICENSE](LICENSE) for details.

## Author

[Mohammed Sohail](https://github.com/thecrazybob)
