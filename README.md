# Claude Code Plugins

Laravel development plugins for [Claude Code](https://claude.ai/code).

## Available Plugins

### laravel-valet-worktree

Git worktrees with Laravel Valet, databases, and Warp terminal config. Enables parallel development on multiple feature branches with isolated environments.

**Features:**
- Create isolated worktrees with dedicated domains (`project-branch.test`)
- Auto-configure databases (`project_branch`)
- Setup Warp terminal layouts
- Manage environment variables for worktree domains
- Clean up worktrees and associated resources

**Commands:**
- `/worktree [branch]` - Create a new worktree
- `/worktree-pr` - Create a PR from the current worktree
- `/worktree-cleanup` - Clean up a worktree and its resources

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
# Install laravel-valet-worktree
/plugin install laravel-valet-worktree@thecrazybob-plugins

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
/plugin install laravel-valet-worktree@thecrazybob-plugins
```

## Requirements

### laravel-valet-worktree

- [Laravel Valet](https://laravel.com/docs/valet) installed and configured
- MySQL running locally
- [Warp](https://www.warp.dev/) terminal (optional, for launch configurations)
- [jq](https://stedolan.github.io/jq/) for JSON parsing

### forge-cli

- [Laravel Forge CLI](https://forge.laravel.com/docs/cli) installed (`composer global require laravel/forge-cli`)
- Forge CLI authenticated (`forge login`)
- SSH access to your Forge servers

## Shell Helpers

The worktree plugin includes a `browse` function that opens the current project in the browser (worktree-aware):

```bash
# Add to ~/.zshrc or ~/.bashrc
source ~/.claude/plugins/laravel-valet-worktree/scripts/browse.sh

# Usage
browse  # Opens http://project-branch.test (reads from .env)
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Author

[Mohammed Sohail](https://github.com/thecrazybob)
