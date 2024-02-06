# List all drives and their Device IDs
$drives = Get-WmiObject -Class Win32_DiskDrive | Select-Object DeviceID, Model
$index = 0
$drives | ForEach-Object { Write-Host "${index}: $($_.Model) - $($_.DeviceID)"; $index++ }

# Ask the user to select a drive by its index number
$selectedDriveIndex = Read-Host "Please select the drive number you want to check"

# Validate the input
if ($selectedDriveIndex -ge 0 -and $selectedDriveIndex -lt $drives.Count) {
    $selectedDrive = $drives[$selectedDriveIndex]
    Write-Host "You selected: $($selectedDrive.Model) - $($selectedDrive.DeviceID)"

    # Retrieve and display the SMART status for the selected drive
    $smartStatus = Get-WmiObject -Namespace root\wmi -Class MSStorageDriver_FailurePredictStatus | Where-Object {$_.InstanceName -like "*$($selectedDrive.DeviceID)*"}
    if ($smartStatus) {
        $smartStatus | Format-Table -AutoSize
    } else {
        Write-Host "No SMART status data found for the selected drive."
    }

    # Retrieve and display detailed SMART data for the selected drive (optional)
    $smartDetails = Get-WmiObject -Namespace root\wmi -Class MSStorageDriver_FailurePredictData | Where-Object {$_.InstanceName -like "*$($selectedDrive.DeviceID)*"}
    if ($smartDetails) {
        $smartDetails | Format-Table -AutoSize
    } else {
        Write-Host "No detailed SMART data found for the selected drive."
    }
} else {
    Write-Host "Invalid selection."
}
