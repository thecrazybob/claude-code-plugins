# Forge API operation index

Generated from [openapi.json](openapi.json). See [api.md](api.md) for authentication, lookup, and refresh instructions.

279 operations across 160 paths. Schema SHA-256: `44b1f9cf5eb0f3879fe63e31a52dee5ec9c8a45fb9849a5daddfd124d5bca931`.

Paths are relative to `https://forge.laravel.com/api`. Read the operation and referenced schemas before constructing a request; API operations are not CLI subcommands.

## Background Processes

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| GET | /orgs/{organization}/servers/{server}/background-processes | organizations.servers.background-processes.index | List background processes | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/background-processes | organizations.servers.background-processes.store | Create background process | async | server:create-daemons |
| DELETE | /orgs/{organization}/servers/{server}/background-processes/{backgroundProcess} | organizations.servers.background-processes.destroy | Delete background process | async | server:delete-daemons |
| GET | /orgs/{organization}/servers/{server}/background-processes/{backgroundProcess} | organizations.servers.background-processes.show | Get background process | sync | server:view |
| PUT | /orgs/{organization}/servers/{server}/background-processes/{backgroundProcess} | organizations.servers.background-processes.update | Update background process | async | server:create-daemons |
| GET | /orgs/{organization}/servers/{server}/background-processes/{backgroundProcess}/log | organizations.servers.background-processes.log.show | Get background process log | sync | server:create-daemons |

## Backups

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| GET | /orgs/{organization}/servers/{server}/database/backups | organizations.servers.database.backups.index | List backup configurations | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/database/backups | organizations.servers.database.backups.store | Create backup configuration | async | server:create-backups |
| DELETE | /orgs/{organization}/servers/{server}/database/backups/{backupConfiguration} | organizations.servers.database.backups.destroy | Delete backup configuration | async | server:delete-backups |
| GET | /orgs/{organization}/servers/{server}/database/backups/{backupConfiguration} | organizations.servers.database.backups.show | Get backup configuration | sync | server:view |
| PUT | /orgs/{organization}/servers/{server}/database/backups/{backupConfiguration} | organizations.servers.database.backups.update | Update backup configuration | async | server:create-backups |
| GET | /orgs/{organization}/servers/{server}/database/backups/{backupConfiguration}/instances | organizations.servers.database.backups.instances.index | List backups | sync | server:create-backups |
| POST | /orgs/{organization}/servers/{server}/database/backups/{backupConfiguration}/instances | organizations.servers.database.backups.instances.store | Create backup | async | server:create-backups |
| DELETE | /orgs/{organization}/servers/{server}/database/backups/{backupConfiguration}/instances/{backup} | organizations.servers.database.backups.instances.destroy | Delete backup | async | server:delete-backups |
| GET | /orgs/{organization}/servers/{server}/database/backups/{backupConfiguration}/instances/{backup} | organizations.servers.database.backups.instances.show | Get backup | sync | server:create-backups |
| POST | /orgs/{organization}/servers/{server}/database/backups/{backupConfiguration}/instances/{backup}/restores | organizations.servers.database.backups.instances.restores.store | Create a database restore from backup | async | server:create-backups |

## Commands

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/commands | organizations.servers.sites.commands.index | List commands | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/sites/{site}/commands | organizations.servers.sites.commands.store | Create command | async | site:manage-commands |
| DELETE | /orgs/{organization}/servers/{server}/sites/{site}/commands/{command} | organizations.servers.sites.commands.destroy | Delete command | sync | site:manage-commands |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/commands/{command} | organizations.servers.sites.commands.show | Get command | sync | server:view |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/commands/{command}/output | organizations.servers.sites.commands.output.show | Get command output | sync | server:view |

## Databases

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| PUT | /orgs/{organization}/servers/{server}/database/password | organizations.servers.database.password.update | Update the password for the database | sync | server:manage-services |
| GET | /orgs/{organization}/servers/{server}/database/schemas | organizations.servers.database.schemas.index | List database schemas | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/database/schemas | organizations.servers.database.schemas.store | Create database schema | async | server:create-databases |
| POST | /orgs/{organization}/servers/{server}/database/schemas/synchronizations | organizations.servers.database.schemas.synchronizations.store | Update database schemas | async | server:create-databases |
| DELETE | /orgs/{organization}/servers/{server}/database/schemas/{database} | organizations.servers.database.schemas.destroy | Delete database schema | async | server:delete-databases |
| GET | /orgs/{organization}/servers/{server}/database/schemas/{database} | organizations.servers.database.schemas.show | Get database schema | sync | server:view |
| GET | /orgs/{organization}/servers/{server}/database/users | organizations.servers.database.users.index | List database users | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/database/users | organizations.servers.database.users.store | Create database user | async | server:create-databases |
| DELETE | /orgs/{organization}/servers/{server}/database/users/{databaseUser} | organizations.servers.database.users.destroy | Delete database user | async | server:delete-databases |
| GET | /orgs/{organization}/servers/{server}/database/users/{databaseUser} | organizations.servers.database.users.show | Get database user | sync | server:view |
| PUT | /orgs/{organization}/servers/{server}/database/users/{databaseUser} | organizations.servers.database.users.update | Update database user | async | server:create-databases |

## Deployments

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| GET | /orgs/{organization}/servers/{server}/deployments | organizations.servers.deployments.index | List server deployments | sync | server:view |
| DELETE | /orgs/{organization}/servers/{server}/sites/{site}/deploy-key | organizations.servers.sites.deploy-key.destroy | Delete deploy key | sync | site:manage-deploys |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/deploy-key | organizations.servers.sites.deploy-key.show | Get deploy key | sync | site:manage-deploys |
| POST | /orgs/{organization}/servers/{server}/sites/{site}/deploy-key | organizations.servers.sites.deploy-key.store | Create deploy key | async | site:manage-deploys |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/deployments | organizations.servers.sites.deployments.index | List deployments | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/sites/{site}/deployments | organizations.servers.sites.deployments.store | Create deployment | async | site:manage-deploys |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/deployments/deploy-hook | organizations.servers.sites.deployments.deploy-hook.show | Get the deployment trigger URL | sync | site:manage-deploys |
| PUT | /orgs/{organization}/servers/{server}/sites/{site}/deployments/deploy-hook | organizations.servers.sites.deployments.deploy-hook.update | Update deployment trigger URL | sync | site:manage-deploys |
| DELETE | /orgs/{organization}/servers/{server}/sites/{site}/deployments/push-to-deploy | organizations.servers.sites.deployments.push-to-deploy.destroy | Delete push to deploy configuration | async | site:manage-deploys |
| POST | /orgs/{organization}/servers/{server}/sites/{site}/deployments/push-to-deploy | organizations.servers.sites.deployments.push-to-deploy.store | Create push to deploy configuration | async | site:manage-deploys |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/deployments/script | organizations.servers.sites.deployments.script.show | Get deployment script | sync | server:view |
| PUT | /orgs/{organization}/servers/{server}/sites/{site}/deployments/script | organizations.servers.sites.deployments.script.update | Update deployment script | sync | site:manage-deploys |
| DELETE | /orgs/{organization}/servers/{server}/sites/{site}/deployments/status | organizations.servers.sites.deployments.status.destroy | Update deployment state | async | site:manage-deploys |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/deployments/status | organizations.servers.sites.deployments.status.show | Get deployment status | sync | server:view |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/deployments/{deployment} | organizations.servers.sites.deployments.show | Get deployment | sync | server:view |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/deployments/{deployment}/log | organizations.servers.sites.deployments.log.show | Get deployment output | sync | site:manage-deploys |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/webhooks | organizations.servers.sites.webhooks.index | List site webhooks | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/sites/{site}/webhooks | organizations.servers.sites.webhooks.store | Create site webhook | async | site:manage-notifications |
| DELETE | /orgs/{organization}/servers/{server}/sites/{site}/webhooks/{deploymentWebhook} | organizations.servers.sites.webhooks.destroy | Delete site webhook | async | site:manage-notifications |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/webhooks/{deploymentWebhook} | organizations.servers.sites.webhooks.show | Get site webhook | sync | server:view |

## Firewall Rules

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| GET | /orgs/{organization}/servers/{server}/firewall-rules | organizations.servers.firewall-rules.index | List server firewall rules | sync | server:manage-network |
| POST | /orgs/{organization}/servers/{server}/firewall-rules | organizations.servers.firewall-rules.store | Create server firewall rule | async | server:manage-network |
| DELETE | /orgs/{organization}/servers/{server}/firewall-rules/{rule} | organizations.servers.firewall-rules.destroy | Delete server firewall rule | async | server:manage-network |
| GET | /orgs/{organization}/servers/{server}/firewall-rules/{rule} | organizations.servers.firewall-rules.show | Get server firewall rule | sync | server:manage-network |

## Integrations

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| DELETE | /orgs/{organization}/servers/{server}/sites/{site}/integrations/horizon | organizations.servers.sites.integrations.horizon.destroy | Delete Laravel Horizon integration | async | server:delete-daemons |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/integrations/horizon | organizations.servers.sites.integrations.horizon.show | Get Laravel Horizon integration status | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/sites/{site}/integrations/horizon | organizations.servers.sites.integrations.horizon.store | Create Laravel Horizon integration | async | server:create-daemons |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/integrations/inertia | organizations.servers.sites.integrations.inertia.show | Get Inertia integration status | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/sites/{site}/integrations/inertia | organizations.servers.sites.integrations.inertia.store | Create Inertia integration | async | server:create-daemons |
| DELETE | /orgs/{organization}/servers/{server}/sites/{site}/integrations/laravel-maintenance | organizations.servers.sites.integrations.laravel-maintenance.destroy | Delete Laravel Maintenance integration | async | site:manage-commands |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/integrations/laravel-maintenance | organizations.servers.sites.integrations.laravel-maintenance.show | Get Laravel Maintenance integration status | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/sites/{site}/integrations/laravel-maintenance | organizations.servers.sites.integrations.laravel-maintenance.store | Create Laravel Maintenance integration | async | site:manage-commands |
| DELETE | /orgs/{organization}/servers/{server}/sites/{site}/integrations/laravel-scheduler | organizations.servers.sites.integrations.laravel-scheduler.destroy | Delete Laravel Scheduler integration job | async | server:delete-schedulers |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/integrations/laravel-scheduler | organizations.servers.sites.integrations.laravel-scheduler.show | Get Laravel Scheduler integration job | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/sites/{site}/integrations/laravel-scheduler | organizations.servers.sites.integrations.laravel-scheduler.store | Create Laravel Scheduler integration job | async | server:create-schedulers |
| DELETE | /orgs/{organization}/servers/{server}/sites/{site}/integrations/octane | organizations.servers.sites.integrations.octane.destroy | Delete Laravel Octane integration | async | server:delete-daemons |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/integrations/octane | organizations.servers.sites.integrations.octane.show | Get Laravel Octane integration status | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/sites/{site}/integrations/octane | organizations.servers.sites.integrations.octane.store | Create Laravel Octane integration | async | server:create-daemons |
| DELETE | /orgs/{organization}/servers/{server}/sites/{site}/integrations/pulse | organizations.servers.sites.integrations.pulse.destroy | Delete Laravel Pulse integration | async | server:delete-daemons |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/integrations/pulse | organizations.servers.sites.integrations.pulse.show | Get Laravel Pulse integration status | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/sites/{site}/integrations/pulse | organizations.servers.sites.integrations.pulse.store | Create Laravel Pulse integration | async | server:create-daemons |
| DELETE | /orgs/{organization}/servers/{server}/sites/{site}/integrations/reverb | organizations.servers.sites.integrations.reverb.destroy | Delete Laravel Reverb integration | async | server:delete-daemons |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/integrations/reverb | organizations.servers.sites.integrations.reverb.show | Get Laravel Reverb integration status | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/sites/{site}/integrations/reverb | organizations.servers.sites.integrations.reverb.store | Create Laravel Reverb integration | async | server:create-daemons |

## Logs

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| DELETE | /orgs/{organization}/servers/{server}/logs/{key} | organizations.servers.logs.destroy | Delete server log content | async | server:manage-logs |
| GET | /orgs/{organization}/servers/{server}/logs/{key} | organizations.servers.logs.show | Get server log content | sync | server:manage-logs |

## Monitors

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| GET | /orgs/{organization}/servers/{server}/monitors | organizations.servers.monitors.index | List server monitors | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/monitors | organizations.servers.monitors.store | Create server monitor | async | server:create-monitors |
| DELETE | /orgs/{organization}/servers/{server}/monitors/{monitor} | organizations.servers.monitors.destroy | Delete server monitor | async | server:delete-monitors |
| GET | /orgs/{organization}/servers/{server}/monitors/{monitor} | organizations.servers.monitors.show | Get server monitor | sync | server:view |

## Nginx

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| GET | /orgs/{organization}/servers/{server}/nginx/templates | organizations.servers.nginx.templates.index | List Nginx templates | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/nginx/templates | organizations.servers.nginx.templates.store | Create Nginx template | sync | server:manage-nginx-templates |
| DELETE | /orgs/{organization}/servers/{server}/nginx/templates/{nginxTemplate} | organizations.servers.nginx.templates.destroy | Delete Nginx template | sync | server:manage-nginx-templates |
| GET | /orgs/{organization}/servers/{server}/nginx/templates/{nginxTemplate} | organizations.servers.nginx.templates.show | Get Nginx template | sync | server:view |
| PUT | /orgs/{organization}/servers/{server}/nginx/templates/{nginxTemplate} | organizations.servers.nginx.templates.update | Update Nginx template | sync | server:manage-nginx-templates |

## Organizations

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| GET | /orgs | organizations.index | List organizations | sync | organization:view |
| GET | /orgs/{organization} | organizations.show | Get organization | sync | organization:view |
| GET | /orgs/{organization}/server-credentials | organizations.server-credentials.index | List server credentials | sync | credential:view |
| GET | /orgs/{organization}/server-credentials/{credential} | organizations.server-credentials.show | Get server credential | sync | credential:view |
| GET | /orgs/{organization}/server-credentials/{credential}/regions/{region}/vpcs | organizations.server-credentials.vpcs.index | List VPCs | sync | credential:view |
| POST | /orgs/{organization}/server-credentials/{credential}/regions/{region}/vpcs | organizations.server-credentials.vpcs.store | Create a new VPC | sync | server:create |
| GET | /orgs/{organization}/server-credentials/{credential}/regions/{region}/vpcs/{vpcId} | organizations.server-credentials.vpcs.show | Get VPC | sync | server:view |

## Providers

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| GET | /providers | providers.index | List providers | sync |  |
| GET | /providers/{provider} | providers.show | Get provider | sync |  |
| GET | /providers/{provider}/regions | providers.regions.index | List provider regions | sync |  |
| GET | /providers/{provider}/regions/{providerRegion} | providers.regions.show | Get provider region | sync |  |
| GET | /providers/{provider}/regions/{providerRegion}/sizes | providers.regions.sizes.index | List provider region sizes | sync |  |
| GET | /providers/{provider}/regions/{providerRegion}/sizes/{providerSize} | providers.regions.sizes.show | Get provider region size | sync |  |
| GET | /providers/{provider}/sizes | providers.sizes.index | List provider sizes | sync |  |
| GET | /providers/{provider}/sizes/{providerSize} | providers.sizes.show | Get provider size | sync |  |

## Recipes

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| GET | /forge-recipes | forge-recipes.index | List Forge's recipes | sync |  |
| GET | /forge-recipes/{forgeRecipe} | forge-recipes.show | Get Forge recipe | sync |  |
| POST | /forge-recipes/{forgeRecipe}/runs | forge-recipes.runs.store | Create Forge recipe run | async |  |
| GET | /orgs/{organization}/recipes | organizations.recipes.index | List organization recipes | sync | recipe:view |
| POST | /orgs/{organization}/recipes | organization.recipes.store | Create recipe | sync | recipe:manage |
| DELETE | /orgs/{organization}/recipes/{recipe} | organizations.recipes.destroy | Delete recipe | sync | recipe:manage |
| GET | /orgs/{organization}/recipes/{recipe} | organizations.recipes.show | Get recipe | sync | recipe:view |
| PUT | /orgs/{organization}/recipes/{recipe} | organizations.recipes.update | Update recipe | sync | recipe:manage |
| GET | /orgs/{organization}/recipes/{recipe}/runs | organizations.recipes.runs.index | List recipe runs | sync | recipe:view |
| POST | /orgs/{organization}/recipes/{recipe}/runs | organizations.recipes.runs.store | Create recipe run | async | recipe:manage |
| GET | /orgs/{organization}/recipes/{recipe}/runs/{log} | organizations.recipes.runs.show | Get recipe run | sync | recipe:view |
| GET | /orgs/{organization}/teams/{team}/recipes | organizations.teams.recipes.index | List team recipes | sync | recipe:view |
| POST | /orgs/{organization}/teams/{team}/recipes | organizations.teams.recipes.store | Share recipe with the team | sync | recipe:view, recipe:manage |
| DELETE | /orgs/{organization}/teams/{team}/recipes/{recipe} | organizations.teams.recipes.destroy | Delete a recipe share | sync | recipe:view, recipe:manage |

## Redirect Rules

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/redirect-rules | organizations.servers.sites.redirect-rules.index | List site redirect rules | sync | site:manage-redirects |
| POST | /orgs/{organization}/servers/{server}/sites/{site}/redirect-rules | organizations.servers.sites.redirect-rules.store | Create site redirect rule | async | site:manage-redirects |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/redirect-rules/export | organizations.servers.sites.redirect-rules.export | Get site redirect rules as CSV | sync | site:manage-redirects |
| POST | /orgs/{organization}/servers/{server}/sites/{site}/redirect-rules/import | organizations.servers.sites.redirect-rules.import | Create site redirect rules from CSV | async | site:manage-redirects |
| PUT | /orgs/{organization}/servers/{server}/sites/{site}/redirect-rules/reorder | organizations.servers.sites.redirect-rules.reorder | Update site redirect rule order | async | site:manage-redirects |
| DELETE | /orgs/{organization}/servers/{server}/sites/{site}/redirect-rules/{redirectRule} | organizations.servers.sites.redirect-rules.destroy | Delete site redirect rule | async | site:manage-redirects |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/redirect-rules/{redirectRule} | organizations.servers.sites.redirect-rules.show | Get site redirect rule | sync | site:manage-redirects |

## Roles

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| GET | /orgs/{organization}/roles | organizations.roles.index | List roles | sync | organization:view |
| POST | /orgs/{organization}/roles | organizations.roles.store | Create role | sync | organization:manage |
| DELETE | /orgs/{organization}/roles/{role} | organizations.roles.destroy | Delete role | sync | organization:manage |
| GET | /orgs/{organization}/roles/{role} | organizations.roles.show | Get role | sync | organization:view |
| PUT | /orgs/{organization}/roles/{role} | organizations.roles.update | Update role | sync | organization:manage |
| GET | /orgs/{organization}/roles/{role}/permissions | organizations.roles.permissions.index | List role permissions | sync | organization:view |
| GET | /permissions | permissions.index | List permissions | sync |  |
| GET | /permissions/{permission} | permissions.show | Get permission | sync |  |
| GET | /predefined-roles | predefined-roles.index | List predefined roles | sync |  |
| GET | /predefined-roles/{role} | predefined-roles.show | Get predefined role | sync |  |

## SSH Keys

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| GET | /orgs/{organization}/servers/{server}/key | organizations.servers.key.show | Get server public SSH key | sync | server:view |
| PUT | /orgs/{organization}/servers/{server}/key | organizations.servers.key.update | Update server public SSH key | sync | server:delete |
| GET | /orgs/{organization}/servers/{server}/ssh-keys | organizations.servers.ssh-keys.index | List server SSH keys | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/ssh-keys | organizations.servers.ssh-keys.store | Create server SSH key | async | server:create-keys |
| DELETE | /orgs/{organization}/servers/{server}/ssh-keys/{key} | organizations.servers.ssh-keys.destroy | Delete server SSH key | async | server:delete-keys |
| GET | /orgs/{organization}/servers/{server}/ssh-keys/{key} | organizations.servers.ssh-keys.show | Get server SSH key | sync | server:view |

## Scheduled Jobs

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| GET | /orgs/{organization}/servers/{server}/scheduled-jobs | organizations.servers.scheduled-jobs.index | List server scheduled jobs | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/scheduled-jobs | organizations.servers.scheduled-jobs.store | Create scheduled job | async | server:view |
| DELETE | /orgs/{organization}/servers/{server}/scheduled-jobs/{job} | organizations.servers.scheduled-jobs.destroy | Delete scheduled job | async | server:view |
| GET | /orgs/{organization}/servers/{server}/scheduled-jobs/{job} | organizations.servers.scheduled-jobs.show | Get scheduled job | sync | server:view |
| GET | /orgs/{organization}/servers/{server}/scheduled-jobs/{job}/output | organizations.servers.scheduled-jobs.outputs.show | Get scheduled job output | sync | server:view |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/scheduled-jobs | organizations.servers.sites.scheduled-jobs.index | List site scheduled jobs | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/sites/{site}/scheduled-jobs | organizations.servers.sites.scheduled-jobs.store | Create site scheduled job | async | server:view |
| DELETE | /orgs/{organization}/servers/{server}/sites/{site}/scheduled-jobs/{job} | organizations.servers.sites.scheduled-jobs.destroy | Delete site scheduled job | async | server:view |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/scheduled-jobs/{job} | organizations.servers.sites.scheduled-jobs.show | Get site scheduled job | sync | server:view |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/scheduled-jobs/{job}/output | organizations.servers.sites.scheduled-jobs.outputs.show | Get site scheduled job output | sync | server:view |

## Security Rules

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/security-rules | organizations.servers.sites.security-rules.index | List site security rules | sync | site:manage-security |
| POST | /orgs/{organization}/servers/{server}/sites/{site}/security-rules | organizations.servers.sites.security-rules.store | Create site security rule | async | site:manage-security |
| DELETE | /orgs/{organization}/servers/{server}/sites/{site}/security-rules/{securityRule} | organizations.servers.sites.security-rules.destroy | Delete site security rule | async | site:manage-security |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/security-rules/{securityRule} | organizations.servers.sites.security-rules.show | Get site security rule | sync | site:manage-security |
| PUT | /orgs/{organization}/servers/{server}/sites/{site}/security-rules/{securityRule} | organizations.servers.sites.security-rules.update | Update site security rule | async | site:manage-security |

## Server Credentials

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| GET | /orgs/{organization}/teams/{team}/server-credentials | organizations.teams.server-credentials.index | List team server credentials | sync | credential:view |
| POST | /orgs/{organization}/teams/{team}/server-credentials | organizations.teams.server-credentials.store | Create a new server credential share | sync | credential:manage, credential:view |
| DELETE | /orgs/{organization}/teams/{team}/server-credentials/{credential} | organizations.teams.server-credentials.destroy | Delete a server credential share | sync | credential:manage, credential:view |

## Servers

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| GET | /orgs/{organization}/events | organizations.events.index | List organization events | sync | server:view |
| GET | /orgs/{organization}/servers | organizations.servers.index | List servers | sync | server:view |
| POST | /orgs/{organization}/servers | organizations.servers.store | Create server | async | server:create |
| GET | /orgs/{organization}/servers/archives | organizations.servers.archives.index | List archived servers | sync | server:view |
| POST | /orgs/{organization}/servers/archives | organizations.servers.archives.store | Create an archived server | async | server:archive |
| DELETE | /orgs/{organization}/servers/archives/{server} | organizations.servers.archives.destroy | Delete archived server | async | server:archive |
| DELETE | /orgs/{organization}/servers/{server} | organizations.servers.destroy | Delete server | async | server:delete |
| GET | /orgs/{organization}/servers/{server} | organizations.servers.show | Get server | sync | server:view |
| PUT | /orgs/{organization}/servers/{server} | organizations.servers.update | Update server | sync | server:manage-meta |
| POST | /orgs/{organization}/servers/{server}/actions | organizations.servers.actions.store | Create server action | async | server:manage-services |
| POST | /orgs/{organization}/servers/{server}/background-processes/{backgroundProcess}/actions | organizations.servers.background-processes.actions.store | Perform an action on a server background process | async | server:create-daemons |
| GET | /orgs/{organization}/servers/{server}/events | organizations.servers.events.index | List server events | sync | server:view |
| GET | /orgs/{organization}/servers/{server}/events/{event} | organizations.servers.events.show | Get server event | sync | server:view |
| GET | /orgs/{organization}/servers/{server}/events/{event}/output | organizations.servers.events.output.show | Get server event output | sync | server:view |
| GET | /orgs/{organization}/servers/{server}/network | organizations.servers.network.show | Get server network | sync | server:view |
| PUT | /orgs/{organization}/servers/{server}/network | organizations.servers.network.update | Update server network | async | server:manage-network |
| GET | /orgs/{organization}/servers/{server}/php/cli-version | organizations.servers.php.cli-version.show | Get PHP CLI version | sync | server:view |
| PUT | /orgs/{organization}/servers/{server}/php/cli-version | organizations.servers.php.cli-version.update | Update PHP CLI version | async | server:manage-php |
| GET | /orgs/{organization}/servers/{server}/php/max-execution-time | organizations.servers.php.max-execution-time.show | Get server PHP max execution time | sync | server:view |
| PUT | /orgs/{organization}/servers/{server}/php/max-execution-time | organizations.servers.php.max-execution-time.update | Update server PHP max execution time | async | server:manage-php |
| GET | /orgs/{organization}/servers/{server}/php/max-upload-size | organizations.servers.php.max-upload-size.show | Get server PHP max upload size | sync | server:view |
| PUT | /orgs/{organization}/servers/{server}/php/max-upload-size | organizations.servers.php.max-upload-size.update | Update server PHP max upload size | async | server:manage-php |
| DELETE | /orgs/{organization}/servers/{server}/php/opcache | organizations.servers.php.opcache.destroy | Delete PHP OPcache config | async | server:manage-php |
| GET | /orgs/{organization}/servers/{server}/php/opcache | organizations.servers.php.opcache.show | Get server PHP OPcache status | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/php/opcache | organizations.servers.php.opcache.store | Create PHP OPcache config | async | server:manage-php |
| GET | /orgs/{organization}/servers/{server}/php/site-version | organizations.servers.php.site-version.show | Get PHP site version | sync | server:view |
| PUT | /orgs/{organization}/servers/{server}/php/site-version | organizations.servers.php.site-version.update | Update PHP site version | async | server:manage-php |
| GET | /orgs/{organization}/servers/{server}/php/versions | organizations.servers.php.versions.index | List PHP versions for server | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/php/versions | organizations.servers.php.versions.store | Install new PHP version | async | server:manage-php |
| DELETE | /orgs/{organization}/servers/{server}/php/versions/{phpVersion} | organizations.servers.php.versions.destroy | Delete installed PHP version | async | server:manage-php |
| GET | /orgs/{organization}/servers/{server}/php/versions/{phpVersion} | organizations.servers.php.versions.show | Get PHP version | sync | server:view |
| PUT | /orgs/{organization}/servers/{server}/php/versions/{phpVersion} | organizations.servers.php.versions.update | Update installed PHP version | async | server:manage-php |
| GET | /orgs/{organization}/servers/{server}/php/versions/{phpVersion}/configs/cli | organizations.servers.php.versions.configs.cli.show | Get PHP version CLI config | sync | server:view |
| PUT | /orgs/{organization}/servers/{server}/php/versions/{phpVersion}/configs/cli | organizations.servers.php.versions.configs.cli.update | Update PHP version CLI config | async | server:manage-php |
| GET | /orgs/{organization}/servers/{server}/php/versions/{phpVersion}/configs/fpm | organizations.servers.php.versions.configs.fpm.show | Get PHP version FPM config | sync | server:view |
| PUT | /orgs/{organization}/servers/{server}/php/versions/{phpVersion}/configs/fpm | organizations.servers.php.versions.configs.fpm.update | Update PHP version FPM config | async | server:manage-php |
| GET | /orgs/{organization}/servers/{server}/php/versions/{phpVersion}/configs/pool | organizations.servers.php.versions.configs.pool.show | Get PHP version pool config | sync | server:view |
| PUT | /orgs/{organization}/servers/{server}/php/versions/{phpVersion}/configs/pool | organizations.servers.php.versions.configs.pool.update | Update PHP version pool config | async | server:manage-php |
| POST | /orgs/{organization}/servers/{server}/services/mysql/actions | organizations.servers.services.mysql.actions.store | Perform MySQL action | async | server:manage-services |
| POST | /orgs/{organization}/servers/{server}/services/nginx/actions | organizations.servers.services.nginx.actions.store | Perform Nginx action | async | server:manage-services |
| POST | /orgs/{organization}/servers/{server}/services/php/actions | organizations.servers.services.php.actions.store | Perform PHP action | async | server:manage-services |
| POST | /orgs/{organization}/servers/{server}/services/postgres/actions | organizations.servers.services.postgres.actions.store | Perform Postgres action | async | server:manage-services |
| POST | /orgs/{organization}/servers/{server}/services/redis/actions | organizations.servers.services.redis.actions.store | Perform Redis action | async | server:manage-services |
| POST | /orgs/{organization}/servers/{server}/services/supervisor/actions | organizations.servers.services.supervisor.actions.store | Perform Supervisor action | async | server:manage-services |
| GET | /orgs/{organization}/teams/{team}/servers | organizations.teams.servers.index | List team servers | sync | server:view |
| POST | /orgs/{organization}/teams/{team}/servers | organizations.teams.servers.store | Create a new server share | sync | server:view, team:create |
| DELETE | /orgs/{organization}/teams/{team}/servers/{server} | organizations.teams.servers.destroy | Delete a server share | sync | server:view, team:create |

## Sites

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| GET | /orgs/{organization}/servers/{server}/sites | organizations.servers.sites.index | List sites for server | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/sites | organizations.servers.sites.store | Create site | async | site:create |
| POST | /orgs/{organization}/servers/{server}/sites/balancer | organizations.servers.sites.storeOnBalancer | Create site on a load balancer | async | site:create |
| DELETE | /orgs/{organization}/servers/{server}/sites/{site} | organizations.servers.sites.destroy | Delete site | async | site:delete |
| PUT | /orgs/{organization}/servers/{server}/sites/{site} | organizations.servers.sites.update | Update site | async | site:create |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/certificates | organizations.servers.sites.certificates.index | List site certificates | sync | site:meta |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/composer/credentials | organizations.servers.sites.composer.credentials.index | Get composer credentials for the site | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/sites/{site}/composer/credentials | organizations.servers.sites.composer.credentials.store | Create composer credentials for the site | async | server:manage-packages |
| DELETE | /orgs/{organization}/servers/{server}/sites/{site}/composer/credentials/{repository} | organizations.servers.sites.composer.credentials.destroy | Delete composer credentials for the site | async | server:manage-packages |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/composer/credentials/{repository} | organizations.servers.sites.composer.credentials.show | Get composer credential for the site | sync | server:view |
| PUT | /orgs/{organization}/servers/{server}/sites/{site}/composer/credentials/{repository} | organizations.servers.sites.composer.credentials.update | Update composer credentials for the site | async | server:manage-packages |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/domains | organizations.servers.sites.domains.index | List domains | sync | site:meta |
| POST | /orgs/{organization}/servers/{server}/sites/{site}/domains | organizations.servers.sites.domains.store | Create domain | async | site:meta |
| DELETE | /orgs/{organization}/servers/{server}/sites/{site}/domains/{domainRecord} | organizations.servers.sites.domains.destroy | Delete domain | async | site:meta |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/domains/{domainRecord} | organizations.servers.sites.domains.show | Get domain | sync | site:meta |
| PATCH | /orgs/{organization}/servers/{server}/sites/{site}/domains/{domainRecord} | organizations.servers.sites.domains.update | Update domain | async | site:meta |
| POST | /orgs/{organization}/servers/{server}/sites/{site}/domains/{domainRecord}/actions | organizations.servers.sites.domains.actions.store | Create domain action | async | site:meta |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/domains/{domainRecord}/certificate | organizations.servers.sites.domains.certificate.show | Get active domain certificate | sync | site:meta |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/domains/{domainRecord}/certificates | organizations.servers.sites.domains.certificates.index | List domain certificates | sync | site:meta |
| POST | /orgs/{organization}/servers/{server}/sites/{site}/domains/{domainRecord}/certificates | organizations.servers.sites.domains.certificates.store | Create domain certificate | async | site:manage-ssl |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/domains/{domainRecord}/certificates/active | organizations.servers.sites.domains.certificates.active | Get active domain certificate | sync | site:meta |
| DELETE | /orgs/{organization}/servers/{server}/sites/{site}/domains/{domainRecord}/certificates/{certificate} | organizations.servers.sites.domains.certificates.destroy | Delete domain certificate | async | site:manage-ssl |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/domains/{domainRecord}/certificates/{certificate} | organizations.servers.sites.domains.certificates.show | Get domain certificate | sync | site:meta |
| POST | /orgs/{organization}/servers/{server}/sites/{site}/domains/{domainRecord}/certificates/{certificate}/actions | organizations.servers.sites.domains.certificates.actions.store | Create domain certificate action | async | site:meta |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/domains/{domainRecord}/configurations | organizations.servers.sites.domains.configurations | Get domain DNS configuration | sync | site:meta |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/domains/{domainRecord}/nginx | organizations.servers.sites.domains.nginx.show | Get domain Nginx configuration | sync | server:view |
| PUT | /orgs/{organization}/servers/{server}/sites/{site}/domains/{domainRecord}/nginx | organizations.servers.sites.domains.nginx.update | Update domain Nginx configuration | async | site:manage-nginx |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/environment | organizations.servers.sites.environment.show | Get .env content | sync | server:view |
| PUT | /orgs/{organization}/servers/{server}/sites/{site}/environment | organizations.servers.sites.environment.update | Update .env content | async | site:manage-environment |
| PUT | /orgs/{organization}/servers/{server}/sites/{site}/git | organizations.servers.sites.git.update | Update Git repository | async | site:manage-project |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/healthcheck | organizations.servers.sites.healthcheck.show | Get healthcheck endpoint | sync | site:manage-project |
| PUT | /orgs/{organization}/servers/{server}/sites/{site}/healthcheck | organizations.servers.sites.healthcheck.update | Update healthcheck endpoint | sync | site:manage-project |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/heartbeats | organizations.servers.sites.heartbeats.index | List heartbeats | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/sites/{site}/heartbeats | organizations.servers.sites.heartbeats.store | Create heartbeat | sync | site:manage-heartbeats |
| DELETE | /orgs/{organization}/servers/{server}/sites/{site}/heartbeats/{heartbeat} | organizations.servers.sites.heartbeats.destroy | Delete heartbeat | sync | site:manage-heartbeats |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/heartbeats/{heartbeat} | organizations.servers.sites.heartbeats.show | Get heartbeat | sync | server:view |
| PUT | /orgs/{organization}/servers/{server}/sites/{site}/heartbeats/{heartbeat} | organizations.servers.sites.heartbeats.update | Update heartbeat | sync | site:manage-heartbeats |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/load-balancing-nodes | organizations.servers.sites.load-balancing-nodes.index | List load balancing nodes | sync | site:manage-project |
| PUT | /orgs/{organization}/servers/{server}/sites/{site}/load-balancing-nodes | organizations.servers.sites.load-balancing-nodes.update | Update load balancing nodes | async | site:manage-project |
| DELETE | /orgs/{organization}/servers/{server}/sites/{site}/logs/application | organizations.servers.sites.logs.application.destroy | Delete site log content | async | server:manage-logs |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/logs/application | organizations.servers.sites.logs.application.show | Get site log content | sync | server:manage-logs |
| DELETE | /orgs/{organization}/servers/{server}/sites/{site}/logs/nginx-access | organizations.servers.sites.logs.nginx-access.destroy | Delete Nginx access log content | async | server:manage-logs |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/logs/nginx-access | organizations.servers.sites.logs.nginx-access.show | Get Nginx access log content | sync | server:manage-logs |
| DELETE | /orgs/{organization}/servers/{server}/sites/{site}/logs/nginx-error | organizations.servers.sites.logs.nginx-error.destroy | Delete Nginx error log content | async | server:manage-logs |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/logs/nginx-error | organizations.servers.sites.logs.nginx-error.show | Get Nginx error log content | sync | server:manage-logs |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/nginx | organizations.servers.sites.nginx.show | Get Nginx configuration | sync | server:view |
| PUT | /orgs/{organization}/servers/{server}/sites/{site}/nginx | organizations.servers.sites.nginx.update | Update Nginx configuration | async | site:manage-nginx |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/npm/credentials | organizations.servers.sites.npm.credentials.index | Get NPM credentials for the site | sync | server:view |
| POST | /orgs/{organization}/servers/{server}/sites/{site}/npm/credentials | organizations.servers.sites.npm.credentials.store | Create NPM credentials for the site | async | server:manage-packages |
| DELETE | /orgs/{organization}/servers/{server}/sites/{site}/npm/credentials/{registry} | organizations.servers.sites.npm.credentials.destroy | Delete npm credentials for the site | async | server:manage-packages |
| GET | /orgs/{organization}/servers/{server}/sites/{site}/npm/credentials/{registry} | organizations.servers.sites.npm.credentials.show | Get NPM credential for the site | sync | server:view |
| PUT | /orgs/{organization}/servers/{server}/sites/{site}/npm/credentials/{registry} | organizations.servers.sites.npm.credentials.update | Update NPM credentials for the site | async | server:manage-packages |
| GET | /orgs/{organization}/sites | organizations.sites.index | List sites for Organization | sync | server:view |
| GET | /orgs/{organization}/sites/{site} | organizations.sites.show | Get site | sync | server:view |
| GET | /sites | sites.index | List sites | sync | server:view |

## Storage Providers

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| GET | /orgs/{organization}/storage-providers | organizations.storage-providers.index | List storage providers | sync | storage:manage |
| POST | /orgs/{organization}/storage-providers | organizations.storage-providers.store | Create storage provider | sync | storage:manage |
| DELETE | /orgs/{organization}/storage-providers/{storageConfiguration} | organizations.storage-providers.destroy | Delete storage provider | sync | storage:manage |
| GET | /orgs/{organization}/storage-providers/{storageConfiguration} | organizations.storage-providers.show | Get storage provider | sync | storage:manage |
| PUT | /orgs/{organization}/storage-providers/{storageConfiguration} | organizations.storage-providers.update | Update storage provider | async | storage:manage |

## Teams

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| GET | /orgs/{organization}/teams | organizations.teams.index | List teams | sync | team:view |
| POST | /orgs/{organization}/teams | organizations.teams.store | Create team | sync | team:create |
| DELETE | /orgs/{organization}/teams/{team} | organizations.teams.destroy | Delete team | sync | team:delete |
| GET | /orgs/{organization}/teams/{team} | organizations.teams.show | Get team | sync | team:view |
| PUT | /orgs/{organization}/teams/{team} | organizations.teams.update | Update team | sync | team:create |
| GET | /orgs/{organization}/teams/{team}/invites | organizations.teams.invites.index | List team invitations | sync | team:view |
| POST | /orgs/{organization}/teams/{team}/invites | organizations.teams.invites.store | Create team invite | async | team:create |
| DELETE | /orgs/{organization}/teams/{team}/invites/{invitation} | organizations.teams.invites.destroy | Delete team invitation | sync | team:delete |
| GET | /orgs/{organization}/teams/{team}/invites/{invitation} | organizations.teams.invites.show | Get team invitation | sync | team:view |
| GET | /orgs/{organization}/teams/{team}/members | organizations.teams.members.index | List team members | sync | team:view |
| DELETE | /orgs/{organization}/teams/{team}/members/{user} | organizations.teams.members.destroy | Delete team member | sync | team:delete |
| GET | /orgs/{organization}/teams/{team}/members/{user} | organizations.teams.members.show | Get team member | sync | team:view |
| PUT | /orgs/{organization}/teams/{team}/members/{user} | organizations.teams.members.update | Update team member | sync | team:create |

## User

| Method | Path | Operation ID | Summary | Processing | Permissions |
| --- | --- | --- | --- | --- | --- |
| GET | /me | me | Get user | sync | user:view |
| GET | /user | user.show | Get user | sync | user:view |
