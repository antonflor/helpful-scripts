# HAProxy Backend Connection Monitor

This Bash utility reads HAProxy backend `server` directives from configuration files, lets you select a backend, resolves its address when necessary, and displays matching established TCP connections for a limited period.

## Supported configuration form

The parser recognizes normal HAProxy server lines with an explicit port:

```text
server app01 192.0.2.20:8443 check
server app02 app02.example.com:8443 check ssl verify required
server app-v6 [2001:db8::20]:8443 check
```

Unix sockets and targets without an explicit port are skipped.

## Requirements

- Bash 4 or newer
- `ss` from `iproute2`
- `awk`, `getent`, and `sort`
- Read access to the HAProxy configuration files

## Usage

```bash
chmod +x haproxy-traffic-logging.sh
./haproxy-traffic-logging.sh
```

Monitor a different configuration directory or duration:

```bash
./haproxy-traffic-logging.sh \
  --config-dir /srv/haproxy \
  --duration 120 \
  --interval 2
```

The utility reports established TCP connection snapshots only. It does not modify HAProxy, capture packet payloads, or write a persistent log.

## Limitations

HAProxy configurations can use templates, runtime DNS, variables, maps, and included/generated files. This utility intentionally parses straightforward `server NAME ADDRESS:PORT` directives and is not a replacement for HAProxy's Runtime API, logs, or metrics.
