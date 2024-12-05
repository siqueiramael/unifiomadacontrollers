#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Starting installation of UniFi and Omada Controllers${NC}\n"

# Update system
echo -e "${YELLOW}Updating system packages...${NC}"
sudo apt update && sudo apt upgrade -y

# Install required packages
echo -e "${YELLOW}Installing required packages...${NC}"
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Install Docker
echo -e "${YELLOW}Installing Docker...${NC}"
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Start and enable Docker
echo -e "${YELLOW}Starting and enabling Docker service...${NC}"
sudo systemctl start docker
sudo systemctl enable docker

# Install Docker Compose
echo -e "${YELLOW}Installing Docker Compose...${NC}"
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create docker-compose.yml
echo -e "${YELLOW}Creating docker-compose.yml...${NC}"
cat << 'EOF' > docker-compose.yml
version: '3'

services:
  unifi-controller:
    image: lscr.io/linuxserver/unifi-controller:latest
    container_name: unifi-controller
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Sao_Paulo
    volumes:
      - ./unifi-data:/config
    ports:
      - 3478:3478/udp
      - 10001:10001/udp
      - 8080:8080
      - 8443:8443
      - 1900:1900/udp
      - 8844:8843  # Changed port to avoid conflict with Omada
      - 8880:8880
      - 6789:6789
    restart: unless-stopped

  omada-controller:
    image: mbentley/omada-controller:latest
    container_name: omada-controller
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Sao_Paulo
      - MANAGE_HTTP_PORT=8088
      - MANAGE_HTTPS_PORT=8043
      - PORTAL_HTTP_PORT=8088
      - PORTAL_HTTPS_PORT=8843
      - SHOW_SERVER_LOGS=true
      - SHOW_MONGODB_LOGS=false
    volumes:
      - ./omada-data:/opt/tplink/EAPController/data
      - ./omada-logs:/opt/tplink/EAPController/logs
    ports:
      - "8088:8088"
      - "8043:8043"
      - "8843:8843"
      - "29810:29810/udp"
      - "29811:29811"
      - "29812:29812"
      - "29813:29813"
    restart: unless-stopped
EOF

# Create directories for data persistence
echo -e "${YELLOW}Creating data directories...${NC}"
mkdir -p unifi-data omada-data omada-logs
sudo chown -R 1000:1000 unifi-data omada-data omada-logs

# Start the containers
echo -e "${YELLOW}Starting the containers...${NC}"
sudo docker-compose up -d

# Show status
echo -e "\n${GREEN}Installation completed!${NC}"
echo -e "\nUniFi Controller will be available at:"
echo -e "https://your-server-ip:8443 (main interface)"
echo -e "https://your-server-ip:8844 (device inform)"
echo -e "\nOmada Controller will be available at:"
echo -e "https://your-server-ip:8043"
echo -e "\nPlease allow a few minutes for the services to fully start."
echo -e "\nInitial setup:"
echo -e "1. UniFi Controller: Access https://your-server-ip:8443"
echo -e "   - Follow the setup wizard to create your admin account"
echo -e "   - Note: Device inform port is now 8844"
echo -e "\n2. Omada Controller: Access https://your-server-ip:8043"
echo -e "   - Wait for initial setup to complete (may take a few minutes)"
echo -e "   - Create your admin account when prompted"