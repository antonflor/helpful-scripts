# KeyFlight - SSH Key Distributor

## Overview

`keyflight.sh` is a simple Bash script that automates the process of copying your SSH key to multiple hosts. This is particularly useful for setting up password-less SSH logins to a list of servers or remote machines.

## Prerequisites

- SSH must be installed on your local machine.
- You should have generated an SSH key pair (`id_rsa` and `id_rsa.pub`) on your local machine.
- SSH server must be running on the target hosts.

## Installation

1. Clone this repository or download the `keyflight.sh` script directly.
2. Make the script executable:

```
chmod +x keyflight.sh
```

## Usage

Run the script and follow the prompt to enter the hostnames or IP addresses of the target machines:

```
./keyflight.sh
```

You will be asked to enter the hostnames or IP addresses, separated by space:

```
Enter the hostnames or IP addresses separated by space: host1.example.com host2.example.com
```

The script will then loop through each host and copy your SSH public key using `ssh-copy-id`. You may be prompted to enter the user's password for each host.

## Note

- The script assumes that the username on the remote hosts is the same as the username on the local machine. If this is not the case, modify the `ssh-copy-id` command accordingly.
- Ensure that the SSH public key (`~/.ssh/id_rsa.pub`) exists and is correctly configured on your local machine before running the script.

## License

This project is licensed under the MIT License.

## Contributing

Contributions are welcome. Please open an issue or submit a pull request with your changes.

## Acknowledgments

This script was created to simplify the process of managing SSH keys across multiple hosts.

```
Feel free to adjust the contents according to your project's specific deta
```
