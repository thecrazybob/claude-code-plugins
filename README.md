# Skills

[![skills.sh](https://skills.sh/b/thecrazybob/skills)](https://skills.sh/thecrazybob/skills)

Agent skills for Laravel development, usable with Codex, Claude Code, and other agents supported by [skills.sh](https://skills.sh). Optional Claude Code plugin packaging is included.

## Forge

[Forge skill](plugins/forge-cli/skills/forge/SKILL.md): manage Laravel Forge with all **34 public CLI v2 commands**, the official OpenAPI schema covering **279 API operations across 160 paths**, and SSH workflows. The schema was retrieved on 2026-09-07; CLI references target v2.0.2.

- [CLI commands](plugins/forge-cli/skills/forge/references/commands.md) and [exact help, options, aliases, and framework commands](plugins/forge-cli/skills/forge/references/cli-help.md).
- [API usage and schema lookup](plugins/forge-cli/skills/forge/references/api.md), [complete operation index](plugins/forge-cli/skills/forge/references/api-operations.md), and [OpenAPI schema](plugins/forge-cli/skills/forge/references/openapi.json).
- Production logs, deployments, environment files, background processes, databases, backups, domains, certificates, and other API resources.

## Install with npx

```bash
# Install globally for both Codex and Claude Code:
npx skills add thecrazybob/skills --skill forge -g -a codex claude-code -y

# Or let the installer choose agents and scope interactively:
npx skills add thecrazybob/skills --skill forge

# Discover without installing:
npx skills add thecrazybob/skills --list
```

The skill name is `forge`; the optional Claude plugin is named `forge-cli`. No Claude plugin or separate npm package is required. The skills CLI discovers the existing `plugins/forge-cli/skills/forge` directory and installs its references and scripts with the skill.

[skills.sh listing](https://skills.sh/thecrazybob/skills/forge). Skills.sh indexes public skills automatically through `npx skills add` installation telemetry; there is no separate publish command. See the [skills.sh FAQ](https://skills.sh/docs/faq).

## Optional Claude Code plugin

In Claude Code:

```text
/plugin marketplace add thecrazybob/skills
/plugin install forge-cli@thecrazybob-plugins
```

The existing marketplace name `thecrazybob-plugins` and plugin name `forge-cli` remain stable. Plugin installs include a PreToolUse hook for selected production mutations. Standalone `npx skills` installs include the skill only, not this hook. The hook is not a security boundary and does not cover arbitrary API requests; the skill requires authorization for production mutations in either installation mode.

## Requirements

- PHP 8.2+ and Forge CLI v2 for CLI workflows: `composer global require laravel/forge-cli`.
- An authorized Forge API token; select an organization and server for CLI operations.
- SSH access for commands that operate over SSH.
- `curl` and `jq` for the documented API examples; Python 3 only for regenerating/checking the API index.

## Validate and refresh

See [the API reference](plugins/forge-cli/skills/forge/references/api.md#refresh-and-check-the-snapshot) for schema refresh instructions. Verify the bundled schema's references, operation coverage, and checksum:

```bash
python3 plugins/forge-cli/skills/forge/scripts/api-reference.py --check
```

## License

[MIT](LICENSE). By [Mohammed Sohail](https://github.com/thecrazybob).
