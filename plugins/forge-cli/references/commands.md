# Forge CLI Command Reference

## Server Management

| Command | Description | Safe |
|---------|-------------|------|
| `forge server:list` | List all servers | Yes |
| `forge server:info <server>` | Show server details | Yes |
| `forge server:reboot <server>` | Reboot server | **No** |

## Site Management

| Command | Description | Safe |
|---------|-------------|------|
| `forge site:list` | List all sites | Yes |
| `forge site:info <site>` | Show site details | Yes |
| `forge site:logs <site>` | View application logs | Yes |

## Deployment

| Command | Description | Safe |
|---------|-------------|------|
| `forge deploy <site>` | Trigger deployment | **No** |
| `forge deploy:logs <site>` | View deployment logs | Yes |
| `forge deploy:reset <site>` | Reset deploy script | **No** |

## Environment

| Command | Description | Safe |
|---------|-------------|------|
| `forge env:pull <site>` | Download .env file | Yes |
| `forge env:push <site>` | Upload .env file | **No** |

## Services

| Command | Description | Safe |
|---------|-------------|------|
| `forge php:status` | PHP-FPM status | Yes |
| `forge php:logs` | PHP-FPM logs | Yes |
| `forge php:restart` | Restart PHP-FPM | **No** |
| `forge nginx:status` | Nginx status | Yes |
| `forge nginx:logs` | Nginx logs | Yes |
| `forge nginx:restart` | Restart Nginx | **No** |

## Database

| Command | Description | Safe |
|---------|-------------|------|
| `forge database:status` | Database status | Yes |
| `forge database:list` | List databases | Yes |

## SSH Commands

| Command | Description | Safe |
|---------|-------------|------|
| `forge ssh <server>` | Interactive SSH | N/A (interactive) |
| `forge command <server> "<cmd>"` | Run remote command | **Broken** |

## Broken/Avoid

- `forge command` - Has "Event unresolvable" bug, use direct SSH
- `forge logs` - Doesn't exist, use `forge site:logs`
- `forge tinker` - Interactive only, can't be automated
- `forge ssh` - Interactive only, can't be automated
