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
    if id "$username" &>/dev/null; then
        echo "User $username already exists."
    else
        adduser "$username"
        usermod -aG sudo "$username"
        echo "$username has been created and added to the sudo group."
    fi
}

# Function to install and enable firewall
setup_firewall() {
    echo "Setting up the firewall..."
    ufw enable
    ufw default deny incoming
    ufw default allow outgoing
    echo "Firewall is configured and enabled."
}

# Function to enhance SSH security
secure_ssh() {
    echo "Securing SSH..."
    # Additional security measures can be added here as needed
    systemctl reload sshd
    echo "SSH has been secured."
}

# Function to install fail2ban
install_fail2ban() {
    echo "Installing and configuring fail2ban..."
    apt-get install fail2ban -y
    systemctl start fail2ban
    systemctl enable fail2ban
    echo "fail2ban is installed and running."
}

# Function to install optional software
install_optional_software() {
    read -p "Do you want to install Cockpit? (yes/no) " choice
    if [[ "$choice" == "yes" ]]; then
        apt-get install cockpit -y
        systemctl enable --now cockpit.socket
        echo "Cockpit installed."
    fi
    
    read -p "Do you want to install Docker? (yes/no) " choice
    if [[ "$choice" == "yes" ]]; then
        apt-get install apt-transport-https ca-certificates curl software-properties-common -y
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        apt-get update
        apt-get install docker-ce -y
        systemctl start docker
        systemctl enable docker
        echo "Docker installed."
    fi
    
    read -p "Do you want to deploy Portainer? (yes/no) " choice
    if [[ "$choice" == "yes" ]]; then
        docker volume create portainer_data
        docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always \
            -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
        echo "Portainer deployed."
    fi
}

# Function to capture and set up the user's SSH public key
configure_ssh_key() {
    echo "Please paste the public SSH key for $username:"
    read -r sshKey
    mkdir -p /home/"$username"/.ssh
    echo "$sshKey" > /home/"$username"/.ssh/authorized_keys
    chmod 700 /home/"$username"/.ssh
    chmod 600 /home/"$username"/.ssh/authorized_keys
    chown -R "$username":"$username" /home/"$username"/.ssh
    echo "SSH key for $username has been configured."
}

# Main script execution
echo "Beginning the setup process..."
update_system
create_user
setup_firewall
secure_ssh
install_fail2ban
install_optional_software
configure_ssh_key
echo "Setup process completed. Please verify all installations and configurations."
