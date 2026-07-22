[CmdletBinding()]
param(
    [ValidateRange(-1, 4096)]
    [int]$DiskIndex = -1
)

$ErrorActionPreference = 'Stop'

if ($env:OS -ne 'Windows_NT') {
    Write-Error 'This script requires Windows.'
    exit 1
}

foreach ($commandName in 'Get-PhysicalDisk', 'Get-StorageReliabilityCounter') {
    if (-not (Get-Command $commandName -ErrorAction SilentlyContinue)) {
        Write-Error "Required Storage module command is unavailable: $commandName"
        exit 1
    }
}

try {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    $isAdministrator = $principal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
    if (-not $isAdministrator) {
        Write-Warning 'Some controllers expose health counters only to an elevated PowerShell session.'
    }
} catch {
    Write-Verbose "Could not determine elevation status: $($_.Exception.Message)"
}

try {
    $disks = @(
        Get-PhysicalDisk |
            Sort-Object DeviceId, FriendlyName
    )
} catch {
    Write-Error "Unable to enumerate physical disks: $($_.Exception.Message)"
    exit 1
}

if ($disks.Count -eq 0) {
    Write-Error 'No physical disks were returned by the Windows Storage provider.'
    exit 1
}

Write-Host 'Available physical disks:'
for ($index = 0; $index -lt $disks.Count; $index++) {
    $disk = $disks[$index]
    $sizeGiB = if ($disk.Size) { [math]::Round($disk.Size / 1GB, 1) } else { 'Unknown' }
    Write-Host (
        '[{0}] {1} | {2} GiB | {3} | Health: {4}' -f
        $index,
        $disk.FriendlyName,
        $sizeGiB,
        $disk.BusType,
        $disk.HealthStatus
    )
}

if ($DiskIndex -lt 0) {
    $selection = Read-Host 'Select a disk index'
    $parsedIndex = 0
    if (-not [int]::TryParse($selection, [ref]$parsedIndex)) {
        Write-Error 'Disk selection must be an integer.'
        exit 2
    }
    $DiskIndex = $parsedIndex
}

if ($DiskIndex -lt 0 -or $DiskIndex -ge $disks.Count) {
    Write-Error "Disk index $DiskIndex is outside the valid range 0-$($disks.Count - 1)."
    exit 2
}

$selectedDisk = $disks[$DiskIndex]

Write-Host "`nSelected disk"
$selectedDisk |
    Select-Object DeviceId, FriendlyName, SerialNumber, Manufacturer, Model,
        MediaType, BusType, HealthStatus, OperationalStatus, Size |
    Format-List

try {
    $reliability = $selectedDisk | Get-StorageReliabilityCounter -ErrorAction Stop
    Write-Host 'Storage reliability counters'
    $reliability |
        Select-Object Temperature, TemperatureMax, Wear, PowerOnHours,
            ReadErrorsTotal, ReadErrorsCorrected, ReadErrorsUncorrected,
            WriteErrorsTotal, WriteErrorsCorrected, WriteErrorsUncorrected,
            ReadLatencyMax, WriteLatencyMax, FlushLatencyMax,
            StartStopCycleCount, LoadUnloadCycleCount |
        Format-List
} catch {
    Write-Warning (
        'Reliability counters are unavailable for this disk/controller: {0}' -f
        $_.Exception.Message
    )
}

$healthProblem = $selectedDisk.HealthStatus -and $selectedDisk.HealthStatus -ne 'Healthy'
$operationalProblem = @($selectedDisk.OperationalStatus) |
    Where-Object { $_ -notin @('OK', 'Online') }

if ($healthProblem -or $operationalProblem) {
    Write-Warning 'Windows reports a non-healthy or non-OK state for the selected disk.'
    exit 2
}

Write-Host 'Windows reports the selected disk as healthy.'
exit 0
