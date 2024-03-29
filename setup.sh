#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Function to update and upgrade system packages
update_system() {
    echo "Updating and upgrading system packages..."
    apt-get update && apt-get upgrade -y
}

# Function to create a new user with sudo privileges
create_user() {
    read -p "Enter the username for the new user account: " username
    adduser --disabled-password --gecos "" "$username"
    usermod -aG sudo "$username"
    echo "$username has been created and added to the sudo group."
}

# Function to install Cockpit
install_cockpit() {
    echo "Installing Cockpit..."
    apt-get install cockpit -y
    systemctl enable --now cockpit.socket
    echo "Cockpit installation completed. Access it via http://your_server_ip:9090."
}

# Function to install Docker
install_docker() {
    echo "Installing Docker..."
    apt-get install apt-transport-https ca-certificates curl software-properties-common -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    apt-get install docker-ce -y
    systemctl start docker
    systemctl enable docker
    echo "Docker installation completed."
}

# Function to deploy Portainer
deploy_portainer() {
    echo "Deploying Portainer..."
    docker volume create portainer_data
    docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always \
        -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
    echo "Portainer deployed. Access it via http://your_server_ip:9000."
}

# Function to setup SSH Public Key Authentication
setup_ssh() {
    echo "Configuring SSH for enhanced security..."
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    systemctl restart sshd
    echo "SSH has been configured to disallow root login and require public key authentication."
    echo "IMPORTANT: Proceed to paste the public SSH key for $username."
}

# Function to capture and set up the user's SSH public key
configure_ssh_key() {
    mkdir -p /home/"$username"/.ssh
    chmod 700 /home/"$username"/.ssh
    echo "Please paste the public SSH key for $username:"
    read -r sshKey
    echo "$sshKey" > /home/"$username"/.ssh/authorized_keys
    chmod 600 /home/"$username"/.ssh/authorized_keys
    chown -R "$username":"$username" /home/"$username"/.ssh
    echo "SSH key for $username has been configured."
}

# Main script execution
echo "Beginning the setup process..."
update_system
create_user
install_cockpit
install_docker
deploy_portainer
setup_ssh
configure_ssh_key
echo "Setup process completed. Please verify all installations and configurations."
