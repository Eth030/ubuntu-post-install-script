#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Define functions for each setup task
update_system() {
    echo "Updating and upgrading system packages..."
    apt-get update && apt-get upgrade -y
    echo "System update completed."
}

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

setup_firewall() {
    echo "Setting up the firewall..."
    ufw enable
    ufw default deny incoming
    ufw default allow outgoing
    echo "Firewall is configured and enabled."
}

install_fail2ban() {
    echo "Installing and configuring fail2ban..."
    apt-get install fail2ban -y
    systemctl enable fail2ban
    systemctl start fail2ban
    echo "fail2ban is installed and running."
}

install_cockpit() {
    echo "Installing Cockpit..."
    apt-get install cockpit -y
    systemctl enable --now cockpit.socket
    echo "Cockpit installed."
}

install_docker() {
    echo "Installing Docker..."
    apt-get install apt-transport-https ca-certificates curl software-properties-common -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    apt-get install docker-ce -y
    systemctl start docker
    systemctl enable docker
    echo "Docker installed."
}

deploy_portainer() {
    echo "Deploying Portainer..."
    docker volume create portainer_data
    docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
    echo "Portainer deployed."
}

# Add new setup functions here

# Display an interactive menu for the user
while true; do
    echo "Select an option:"
    echo "1) Update System"
    echo "2) Create New User"
    echo "3) Setup Firewall"
    echo "4) Install fail2ban"
    echo "5) Install Cockpit"
    echo "6) Install Docker"
    echo "7) Deploy Portainer"
    echo "8) Exit"
    read -p "Option: " option

    case $option in
        1) update_system ;;
        2) create_user ;;
        3) setup_firewall ;;
        4) install_fail2ban ;;
        5) install_cockpit ;;
        6) install_docker ;;
        7) deploy_portainer ;;
        8) break ;;
        *) echo "Invalid option selected. Please try again." ;;
    esac
done

echo "Setup process completed. Exiting."
