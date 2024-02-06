## PowerShell Script for SMART Data Retrieval

### Description

This PowerShell script provides an easy and interactive way to retrieve SMART (Self-Monitoring, Analysis, and Reporting Technology) data from hard drives on a Windows system. It lists all connected drives and allows the user to select a drive by its index number. After selection, the script displays the SMART status and detailed SMART data for the chosen drive.

### Features

- **Drive Listing**: Automatically lists all physical drives connected to the system with their Device IDs and models.
- **Interactive Selection**: Users can select a drive by simply entering its index number.
- **SMART Status Retrieval**: Retrieves basic SMART status, indicating the health of the selected drive.
- **Detailed SMART Data**: Provides more in-depth SMART data for a comprehensive understanding of the drive's condition.
- **Error Handling**: Includes basic error handling for invalid selections and cases where SMART data is not available.

### Prerequisites

- Windows operating system.
- PowerShell (comes pre-installed on Windows).
- Administrative privileges might be required depending on the system's configuration.

### Usage

1. Download the `CheckSmartStatus.ps1` script.
2. Run PowerShell as an administrator.
3. Navigate to the script's location and execute it by entering `.\CheckSmartStatus.ps1`.
4. Follow the on-screen prompts to select a drive and view its SMART data.

### Notes

- The script's ability to retrieve SMART data depends on the system's hardware, drivers, and Windows version.
- In some cases, the script may not be able to retrieve SMART data due to limitations or lack of support from the system's storage controller or drivers.
- For comprehensive drive health monitoring, consider using specialized third-party tools like CrystalDiskInfo or GSmartControl.

### Release Notes

- Initial release: Basic functionality for listing drives and retrieving SMART data.
- Future updates may include enhanced compatibility, additional features, and improved error handling.
