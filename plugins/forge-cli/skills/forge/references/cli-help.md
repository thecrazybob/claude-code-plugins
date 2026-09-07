# Exact CLI help: Forge v2.0.2

Captured 2026-09-07 from `forge list --format=json`; public command names and aliases checked against [v2.0.2 source](https://github.com/laravel/forge-cli/tree/v2.0.2/app/Commands). Composer package version is v2.0.2, though the binary reports 2.0.1 (G9).

34 public Forge commands and 11 hidden framework/help commands. Aliases are alternate names, not additional commands. Brackets in usage indicate syntactically optional arguments; provide explicit resource arguments in automation. See [commands.md](commands.md) for context and side effects.

Refresh with `forge list --format=json` and compare against the matching release source. `forge help <command>` provides current local help without running that operation.

## Global options

| Option | Description |
| --- | --- |
| `--help` -h | Display help for the given command. When no command is given display help for the list command |
| `--silent`  | Do not output any message |
| `--quiet` -q | Only errors are displayed. All other output is suppressed |
| `--verbose` -v\|-vv\|-vvv | Increase the verbosity of messages: 1 for normal output, 2 for more verbose output and 3 for debug |
| `--version` -V | Display this application version |
| `--ansi`  | Force (or disable --no-ansi) ANSI output |
| `--no-ansi`  | Negate the "--ansi" option |
| `--no-interaction` -n | Do not ask any interactive question |
| `--env`  | The environment the command should run under |

## Public Forge commands

### command

Execute a CLI command

```text
forge command [--command [COMMAND]] [--] [<site>]
```

- Argument `site`: The site name. Default: `null`.
- Option `--command` : The command that should be executed. Default: `null`.

### deploy

Deploy a site

```text
forge deploy [<site>]
```

- Argument `site`: The site name. Default: `null`.

### login

Authenticate with Laravel Forge

```text
forge login [--token [TOKEN]]
```

- Option `--token` : Forge API token. Default: `null`.

### logout

Logout from Laravel Forge

```text
forge logout
```


### open

Open a site in forge.laravel.com

```text
forge open [<site>]
```

- Argument `site`: The site name. Default: `null`.

### ssh

Start an SSH session

```text
forge ssh [-u|--user [USER]] [--] [<server>]
```

- Argument `server`: The server name. Default: `null`.
- Option `--user` -u: The user to connect to the server as. Default: `null`.

### tinker

Tinker with a site

```text
forge tinker [<site>]
```

- Argument `site`: The site name. Default: `null`.

### background-process:list

List the background processes

```text
forge background-process:list
forge daemon:list
```

Aliases: `daemon:list`.


### background-process:logs

Retrieve the latest background process log messages

```text
forge background-process:logs [-f|--follow] [--] [<backgroundProcess>]
forge daemon:logs
```

Aliases: `daemon:logs`.

- Argument `backgroundProcess`: The background process ID. Default: `null`.
- Option `--follow` -f: Monitor the log changes in realtime. Default: `false`.

### background-process:restart

Restart a background process

```text
forge background-process:restart [<backgroundProcess>]
forge daemon:restart
```

Aliases: `daemon:restart`.

- Argument `backgroundProcess`: The background process ID. Default: `null`.

### background-process:status

Get the current status of a background process

```text
forge background-process:status [<backgroundProcess>]
forge daemon:status
```

Aliases: `daemon:status`.

- Argument `backgroundProcess`: The background process ID. Default: `null`.

### database:logs

Retrieve the latest database log messages

```text
forge database:logs
```


### database:restart

Restart the database

```text
forge database:restart
```


### database:shell

Start a database shell

```text
forge database:shell [--user [USER]] [--] [<database>]
```

- Argument `database`: The name of the database. Default: `null`.
- Option `--user` : The username of the database user to connect as. Default: `"forge"`.

### database:status

Get the current status of the database

```text
forge database:status
```


### deploy:logs

Retrieve the latest deployment log messages

```text
forge deploy:logs [<site>]
```

- Argument `site`: The site name. Default: `null`.

### env:pull

Download the environment file for the given site

```text
forge env:pull [<site> [<file>]]
```

- Argument `site`: The site name. Default: `null`.
- Argument `file`: File to write the environment variables to. Default: `null`.

### env:push

Upload the environment file for the given site

```text
forge env:push [<site> [<file>]]
```

- Argument `site`: The site name. Default: `null`.
- Argument `file`: File to upload the environment variables from. Default: `null`.

### nginx:logs

Retrieve the latest Nginx log messages

```text
forge nginx:logs [<type>]
```

- Argument `type`: The log type. Default: `"error"`.

### nginx:restart

Restart Nginx

```text
forge nginx:restart
```


### nginx:status

Get the current status of Nginx

```text
forge nginx:status
```


### organization:current

Determine your current organization

```text
forge organization:current
forge org:current
```

Aliases: `org:current`.


### organization:list

List the organizations

```text
forge organization:list
forge org:list
```

Aliases: `org:list`.


### organization:switch

Switch to a different organization

```text
forge organization:switch [<organization>]
forge org:switch
```

Aliases: `org:switch`.

- Argument `organization`: The organization name. Default: `null`.

### php:logs

Retrieve the latest PHP log messages

```text
forge php:logs [<version>]
```

- Argument `version`: The PHP version. Default: `null`.

### php:restart

Restart PHP

```text
forge php:restart [<version>]
```

- Argument `version`: The PHP version. Default: `null`.

### php:status

Get the current status of PHP

```text
forge php:status [<version>]
```

- Argument `version`: The PHP version. Default: `null`.

### server:current

Determine your current server

```text
forge server:current
forge current
```

Aliases: `current`.


### server:list

List the servers

```text
forge server:list
```


### server:switch

Switch to a different server

```text
forge server:switch [<server>]
forge switch
```

Aliases: `switch`.

- Argument `server`: The server name. Default: `null`.

### site:list

List the sites

```text
forge site:list
```


### site:logs

Retrieve the latest site log messages

```text
forge site:logs [-f|--follow] [--] [<site>]
```

- Argument `site`: The site name. Default: `null`.
- Option `--follow` -f: Monitor the log changes in realtime. Default: `false`.

### ssh:configure

Configure SSH key based secure authentication

```text
forge ssh:configure [--key [KEY]] [--name [NAME]] [--user [USER]] [--] [<server>]
```

- Argument `server`: The server name. Default: `null`.
- Option `--key` : The path to the public key. Default: `null`.
- Option `--name` : The key name on Forge. Default: `null`.
- Option `--user` : The server username. Default: `null`.

### ssh:test

Test the SSH key based secure authentication connection

```text
forge ssh:test [--key [KEY]] [--] [<server>]
```

- Argument `server`: The server name. Default: `null`.
- Option `--key` : The path to the private key. Default: `null`.


## Hidden framework and help commands

These ship with the framework; `app:*`, `make:*`, `schedule:*`, and `stub:*` are development/internal operations, not Forge API management commands. Prefer `forge list` and `forge help <command>` for discovery.

### _complete

Internal command to provide shell completion suggestions

```text
forge _complete [-s|--shell SHELL] [-i|--input INPUT] [-c|--current CURRENT] [-a|--api-version API-VERSION] [-S|--symfony SYMFONY]
```

- Option `--shell` -s: The shell type ("bash", "fish", "zsh"). Default: `null`.
- Option `--input` -i: An array of input tokens (e.g. COMP_WORDS or argv). Default: `[]`.
- Option `--current` -c: The index of the "input" array that the cursor is in (e.g. COMP_CWORD). Default: `null`.
- Option `--api-version` -a: The API version of the completion script. Default: `null`.
- Option `--symfony` -S: deprecated. Default: `null`.

### help

Display help for a command

```text
forge help [--format FORMAT] [--raw] [--] [<command_name>]
```

- Argument `command_name`: The command name. Default: `"help"`.
- Option `--format` : The output format (txt, xml, json, or md). Default: `"txt"`.
- Option `--raw` : To output raw command help. Default: `false`.

### list

List commands

```text
forge list [--raw] [--format FORMAT] [--short] [--] [<namespace>]
```

- Argument `namespace`: The namespace name. Default: `null`.
- Option `--raw` : To output raw command list. Default: `false`.
- Option `--format` : The output format (txt, xml, json, or md). Default: `"txt"`.
- Option `--short` : To skip describing commands' arguments. Default: `false`.

### app:build

Build a single file executable

```text
forge app:build [--build-version [BUILD-VERSION]] [--timeout [TIMEOUT]] [--] [<name>]
```

- Argument `name`: The build name. Default: `null`.
- Option `--build-version` : The build version, if not provided it will be asked. Default: `null`.
- Option `--timeout` : The timeout in seconds or 0 to disable. Default: `"300"`.

### app:install

Install optional components

```text
forge app:install [<component>]
```

- Argument `component`: The component name. Default: `null`.

### app:rename

Set the application name

```text
forge app:rename [<name>]
```

- Argument `name`: The new name. Default: `null`.

### make:command

Create a new command

```text
forge make:command [-f|--force] [--command [COMMAND]] [--test] [--pest] [--phpunit] [--] <name>
```

- Argument `name`: The name of the command. Default: `null`.
- Option `--force` -f: Create the class even if the console command already exists. Default: `false`.
- Option `--command` : The terminal command that will be used to invoke the class. Default: `null`.
- Option `--test` : Generate an accompanying Test test for the Console command. Default: `false`.
- Option `--pest` : Generate an accompanying Pest test for the Console command. Default: `false`.
- Option `--phpunit` : Generate an accompanying PHPUnit test for the Console command. Default: `false`.

### make:test

Create a new test class

```text
forge make:test [-f|--force] [-u|--unit] [--pest] [--phpunit] [--] <name>
```

- Argument `name`: The name of the test. Default: `null`.
- Option `--force` -f: Create the test even if the test already exists. Default: `false`.
- Option `--unit` -u: Create a unit test. Default: `false`.
- Option `--pest` : Create a Pest test. Default: `false`.
- Option `--phpunit` : Create a PHPUnit test. Default: `false`.

### schedule:finish

Handle the completion of a scheduled command

```text
forge schedule:finish <id> [<code>]
```

- Argument `id`: . Default: `null`.
- Argument `code`: . Default: `"0"`.

### schedule:run

Run the scheduled commands

```text
forge schedule:run [--whisper]
```

- Option `--whisper` : Do not output message indicating that no jobs were ready to run. Default: `false`.

### stub:publish

Publish all stubs that are available for customization

```text
forge stub:publish [--existing] [--force]
```

- Option `--existing` : Publish and overwrite only the files that have already been published. Default: `false`.
- Option `--force` : Overwrite any existing files. Default: `false`.
