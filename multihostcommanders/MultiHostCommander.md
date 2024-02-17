### README for MultiHostCommander

------

#### Description

This script allows users to execute a set of commands on multiple Debian hosts via SSH. It reads commands and host details from user-provided files, streamlining batch operations on servers.

------

#### Usage

1. **Prepare Command File**: Create a text file containing the commands you want to execute on the Debian hosts. Each command should be on a separate line.
2. **Prepare Host File**: Create a text file listing the Debian hosts. Each host should be on a new line.
3. **Execute the Script**: Run the script by typing `./scriptname.sh` in the terminal. When prompted, enter the filenames for the command and host files.
4. **Output**: The script connects to each host via SSH and executes the provided commands, displaying the output for each host.

------

#### Requirements

- SSH key-based authentication must be set up for each target host.
- The script file should have executable permissions (`chmod +x multihostcommander.sh`).

------

#### Note

- Ensure that the command and host files are correctly formatted and the paths provided during the prompt are accurate.
- This script assumes that SSH key-based authentication is configured for all the target hosts.

------

#### Script File Permissions

To make the script executable, run:

```
chmod +x multihostcommander.sh
```
