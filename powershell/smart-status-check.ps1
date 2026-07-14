# List all drives and their Device IDs
# (Get-CimInstance works in both Windows PowerShell 5.1 and PowerShell 7+)
$drives = @(Get-CimInstance -ClassName Win32_DiskDrive | Select-Object DeviceID, Model)
$index = 0
$drives | ForEach-Object { Write-Host "${index}: $($_.Model) - $($_.DeviceID)"; $index++ }

# Ask the user to select a drive by its index number
$selectedDriveIndex = Read-Host "Please select the drive number you want to check"

# Validate the input (Read-Host returns a string, so cast before comparing)
if ($selectedDriveIndex -match '^\d+$' -and [int]$selectedDriveIndex -lt $drives.Count) {
    $selectedDrive = $drives[[int]$selectedDriveIndex]
    Write-Host "You selected: $($selectedDrive.Model) - $($selectedDrive.DeviceID)"

    # Retrieve and display the SMART status for the selected drive
    $smartStatus = Get-CimInstance -Namespace root/wmi -ClassName MSStorageDriver_FailurePredictStatus -ErrorAction SilentlyContinue |
        Where-Object { $_.InstanceName -like "*$($selectedDrive.DeviceID.TrimStart('\', '.'))*" }
    if ($smartStatus) {
        $smartStatus | Format-Table -AutoSize
    } else {
        Write-Host "No SMART status data found for the selected drive."
    }

    # Retrieve and display detailed SMART data for the selected drive (optional)
    $smartDetails = Get-CimInstance -Namespace root/wmi -ClassName MSStorageDriver_FailurePredictData -ErrorAction SilentlyContinue |
        Where-Object { $_.InstanceName -like "*$($selectedDrive.DeviceID.TrimStart('\', '.'))*" }
    if ($smartDetails) {
        $smartDetails | Format-Table -AutoSize
    } else {
        Write-Host "No detailed SMART data found for the selected drive."
    }
} else {
    Write-Host "Invalid selection."
}
