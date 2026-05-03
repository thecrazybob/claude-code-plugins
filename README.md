# Claude Code Plugins

Laravel development plugins for [Claude Code](https://claude.ai/code).

## Available Plugins

### forge-cli

Debug and manage Laravel apps in production via Forge CLI and SSH.

**Features:**
- View production logs (application, deployment, PHP-FPM, Nginx)
- Run safe read-only commands on production
- Check queue and Horizon status
- Debug production issues with Tinker
- Manage environment variables safely

**Activates when mentioning:**
- "production logs", "debug production", "forge"
- "check production", "run on server", "production database"
- "deploy", "SSH to production", "server logs"

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

- [Laravel Forge CLI](https://forge.laravel.com/docs/cli) installed (`composer global require laravel/forge-cli`)
- Forge CLI authenticated (`forge login`)
- SSH access to your Forge servers

## License

MIT License - see [LICENSE](LICENSE) for details.

## Author

[Mohammed Sohail](https://github.com/thecrazybob)
