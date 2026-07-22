# MultiHostCommander

`multihostcommander.sh` sends a local command file to a remote shell on each SSH host in a host file. It continues after individual failures and prints a final success/failure summary.

## Safety defaults

- SSH batch mode is enabled, so jobs fail instead of hanging on password prompts.
- Existing host keys must already be trusted by default.
- Use `--accept-new` to trust previously unseen keys while still rejecting changed keys.
- The command file is streamed over standard input rather than embedded in an SSH command string, preserving multiline scripts and reducing quoting problems.

## Requirements

- Bash 4 or newer on the control host
- OpenSSH client
- SSH key-based authentication for each target
- A compatible remote shell; `sh` is the default

## Input files

`hosts.txt`:

```text
# Web tier
admin@web01.example.com
admin@web02.example.com
```

`commands.sh`:

```sh
hostname
uname -r
df -h /
```

Blank lines and comments in the host file are ignored. Duplicate hosts are removed.

## Usage

```bash
chmod +x multihostcommander.sh
./multihostcommander.sh \
  --hosts hosts.txt \
  --commands commands.sh
```

Trust new host keys during first use:

```bash
./multihostcommander.sh \
  --hosts hosts.txt \
  --commands commands.sh \
  --accept-new
```

Use Bash remotely and increase the connection timeout:

```bash
./multihostcommander.sh \
  --hosts hosts.txt \
  --commands commands.sh \
  --shell bash \
  --connect-timeout 20
```

Review command files carefully before running them across multiple systems. The utility intentionally executes the complete file on every listed host.
