# Windows Physical Disk Health Check

`smart-status-check.ps1` is an interactive PowerShell utility that displays Windows Storage health information and reliability counters for a selected physical disk.

## Data sources

The script uses the built-in Windows Storage module:

- `Get-PhysicalDisk` for inventory, health, operational status, bus type, media type, and size
- `Get-StorageReliabilityCounter` for controller-reported temperature, wear, power-on hours, error counters, latency maxima, and cycle counts

These counters are related to SMART/device telemetry but are not a raw decoder for every vendor-specific SMART attribute.

## Requirements

- Windows 10/11 or Windows Server with the Storage module
- Windows PowerShell 5.1 or PowerShell 7+
- Administrative PowerShell recommended for the broadest controller access

## Usage

Interactive selection:

```powershell
.\smart-status-check.ps1
```

Select a disk non-interactively by the displayed index:

```powershell
.\smart-status-check.ps1 -DiskIndex 0
```

## Exit codes

- `0` — the selected disk is reported healthy
- `1` — enumeration, platform, or command failure
- `2` — invalid selection or Windows reports a degraded/non-OK disk state

## Limitations

- USB bridges, RAID controllers, virtual disks, and some vendor drivers may not expose reliability counters.
- Missing counters do not prove a disk is healthy.
- Windows health status should be considered alongside backups, vendor diagnostics, event logs, and application-level symptoms.
- Replace failing or suspect media promptly; this utility is not a substitute for current backups.
