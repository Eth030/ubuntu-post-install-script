#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "Beginning the setup process..."
echo "Updating and upgrading system packages..."
apt-get update && apt-get upgrade -y

# Create a new user
read -p "Enter the username for the new user account: " username
adduser $username
usermod -aG sudo $username
echo "$username has been created and added to the sudo group."

# Install Cockpit
echo "Installing Cockpit..."
apt-get install cockpit -y
systemctl enable --now cockpit.socket
echo "Cockpit installation completed. Access it via http://your_server_ip:9090."

# Install Docker
echo "Installing Docker..."
apt-get install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install docker-ce -y
systemctl start docker
systemctl enable docker
echo "Docker installation completed."

# Install Portainer
echo "Deploying Portainer..."
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
echo "Portainer deployed. Access it via http://your_server_ip:9000."

# Setup SSH Public Key Authentication
echo "Configuring SSH for enhanced security..."
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
echo "SSH has been configured to disallow root login and require public key authentication."

# Inform user about manual steps required for SSH key setup
echo "IMPORTANT: Ensure your public SSH key is copied to $username@your_server_ip:.ssh/authorized_keys"
echo "If connecting from Windows via PuTTY, convert your private key to PPK format using PuTTYgen and use it in your session."
echo "SSH service will be restarted. If you're disconnected, reconnect using your SSH key."

# Restart SSH to apply changes
systemctl restart sshd
echo "SSH service restarted. Configuration complete."

echo "Setup process completed. Review any manual steps required and verify installations."
