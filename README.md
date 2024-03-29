```
# Ubuntu 22.04 VPS Setup Script

This streamlined automation script is designed for the initial setup of Ubuntu 22.04 servers. It configures security settings and installs essential management tools.

## Features
- Non-root user creation with sudo privileges
- UFW firewall configuration for enhanced security
- SSH hardening by disabling root login and enforcing key-based authentication
- Fail2ban installation for additional SSH protection
- Optional installation of Cockpit, Docker, and Portainer for easy server management and containerization

## Quick Start
Execute the following command on your server as root:

```bash
bash <(curl -s https://raw.githubusercontent.com/Eth030/ubuntu-post-install-script/main/setup.sh)
```

## Instructions
Follow the on-screen prompts to:
- Specify the new user's name
- Paste the public SSH key for secure login
- Select optional software to install

## License
Distributed under the MIT License.
```
