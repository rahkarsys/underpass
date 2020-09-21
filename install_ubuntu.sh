#!/bin/bash

# The commands in this script are meant to be ran by root.

# Add Ansible Repo and Install Ansible
sudo apt update
sudo apt upgrade -y
sudo apt install -y software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible git

# Clone Repo
git clone -b stage https://github.com/gabotronix/underpass.git /opt/underpass

# Install Ansible Roles
sudo ansible-galaxy install -r /opt/underpass/ansible/requirements.yml

# Run Ansible Playbook
cd /opt/underpass
sudo ansible-playbook install.yml

# Install Underpass
echo -e "===================================================="
echo -e "Installing Underpass\n"
echo -e "===================================================="
cd /opt/underpass
DockerNetwork=`docker network ls | grep -c underpass`
if [ $DockerNetwork != 1 ]; then
    sudo docker network create underpass --subnet 172.20.0.0/24
    sudo docker-compose up -d
else
    sudo docker-compose up -d
fi

# Enumerate Web UI's and Ports
WhichDockerCompose=`which docker-compose | grep -c /usr`
DockerPS=`docker ps | grep -c dante`
if [ $WhichDockerCompose != 1 ]; then
    echo -e "Installation failed. Please run the installer again."
    exit 1
elif [ $DockerPS != 1 ]; then
    echo -e "Installation failed. Please run the installer again."
    exit 1
else
    echo -e "Initializing Containers..."
    sleep 20
    PublicIP=$(curl -4 ifconfig.co 2>/dev/null)
    echo -e "\n\n===================================================="
    echo -e "Configure Your Underpass Web Panels:"
    echo -e "===================================================="
    echo -e "\nConfigure Portainer @ http://$PublicIP:9000\n"
    echo -e "Configure Pritunl VPN @ https://$PublicIP:4433\n"
    echo -e "Configure Heimdall @ http://$PublicIP:85/users\n"
    echo -e "View Server Load @ http://$PublicIP:19999\n"
    echo -e "----------------------------------------------------"
fi
