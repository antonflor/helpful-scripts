# KeyFlight — SSH Public Key Distributor

`keyflight.sh` installs an SSH public key on multiple remote hosts by invoking `ssh-copy-id` once per target. It accepts targets from arguments, a file, or an interactive prompt and reports failures without abandoning the remaining hosts.

## Requirements

- Bash 4 or newer
- OpenSSH client tools, including `ssh-copy-id`
- A local SSH key pair
- Password or other interactive authentication for initial key installation

Create an Ed25519 key when needed:

```bash
ssh-keygen -t ed25519
```

## Usage

Pass hosts directly:

```bash
./keyflight.sh admin@host1.example.com admin@host2.example.com
```

Use a specific public key and SSH port:

```bash
./keyflight.sh \
  --identity ~/.ssh/id_ed25519.pub \
  --port 2222 \
  admin@host1.example.com admin@host2.example.com
```

Read hosts from a file:

```bash
./keyflight.sh --hosts-file hosts.txt
```

The hosts file may contain blank lines, comments, and multiple whitespace-separated targets:

```text
# Production
admin@app01.example.com
admin@app02.example.com admin@app03.example.com
```

Duplicate targets are removed before processing. Run `./keyflight.sh --help` for all options.

## Notes

- Without `--identity`, `ssh-copy-id` selects the normal default public key.
- A single `--port` value applies to all targets. Use SSH config host aliases when targets require different ports or identities.
- Host-key verification and authentication behavior remain controlled by your OpenSSH configuration.
