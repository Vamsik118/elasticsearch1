#!/bin/bash
set -e

echo "Updating package lists..."
sudo apt-get update -y

echo "Installing prerequisite packages..."
sudo apt-get install     apt-transport-https     ca-certificates     curl     gnupg-agent     software-properties-common -y

echo "Adding Docker's official GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

echo "Verifying Docker GPG key fingerprint..."
sudo apt-key fingerprint 0EBFCD88

echo "Setting up Docker stable repository..."
sudo add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/ubuntu    $(lsb_release -cs)    stable" -y

echo "Updating package lists again for Docker..."
sudo apt-get update -y

echo "Installing Docker CE, CLI, and Containerd..."
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

echo "Installing Docker Compose..."
DOCKER_COMPOSE_VERSION="1.27.4" # Using a known version, can be updated
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Applying system configurations for Elasticsearch..."
sudo sysctl -w vm.max_map_count=262144
# sudo swapoff -a # Disabling swap is a common recommendation but can be host-specific. Uncomment if needed.
sudo ulimit -n 65535 # Set max open files. Better to set this permanently in /etc/security/limits.conf for a production system.
sudo sysctl -w net.ipv4.tcp_retries2=5

echo "Creating data directory for Elasticsearch Node 2..."
sudo mkdir -p /var/enc/db/elasticsearch2/data
sudo chown -R 1000:1000 /var/enc/db/elasticsearch2/data # Assuming Elasticsearch runs as UID 1000 in container

echo "Starting Elasticsearch Node 2 using docker-compose..."
sudo docker-compose -f elasticsearch-two-compose.yml up -d

echo "---------------------------------------------------------------------"
echo "Node 2 (elasticsearch-two) startup initiated."
echo "Elasticsearch Node 2 will be available at http://<this_host_ip>:9200"
echo "Ensure ./elasticsearch-two-compose.yml, ./elasticsearch-one-config.yml, and ./log4j2.properties are in the same directory as this script."
echo "---------------------------------------------------------------------"
