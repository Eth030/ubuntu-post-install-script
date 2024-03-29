# Ubuntu 22.04 VPS Setup Script

This repository contains an automated setup script (`setup.sh`) designed for newly provisioned Ubuntu 22.04 virtual private servers (VPS). The script streamlines the initial configuration process, enhancing security and installing essential tools with minimal user interaction. It's ideal for developers, sysadmins, and anyone looking to quickly prepare a secure and functional server environment.

## Features

- **User Creation**: Adds a new user with sudo privileges, ensuring secure operations without the root user.
- **SSH Hardening**: Configures SSH to disable root login and password authentication, promoting the use of SSH keys for a more secure connection.
- **Software Installations**:
  - **Cockpit**: Provides a web-based graphical interface for server management.
  - **Docker**: Installs Docker, enabling containerization and application isolation.
  - **Portainer**: A lightweight Docker management UI, making container management simpler.

## Usage

To run the setup script on your Ubuntu 22.04 server, execute the following command (ensure you have `curl` or `wget` installed):

```bash
bash <(curl -s https://raw.githubusercontent.com/your_username/your_repository/main/setup.sh)
```

Or, if you prefer `wget`:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/your_username/your_repository/main/setup.sh)
```

## Security Notice

Before executing the script, review its contents to ensure its safety and applicability to your environment. Running scripts from the internet carries risks, and precautions should be taken.
