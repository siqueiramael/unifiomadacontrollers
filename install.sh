#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to display menu
show_menu() {
    clear
    echo -e "${GREEN}=== Instalação de Controladores UniFi/Omada ===${NC}"
    echo "1. Instalar UniFi Controller"
    echo "2. Instalar Omada Controller"
    echo "3. Instalar Ambos Controladores"
    echo "4. Configurar Certificado SSL (Let's Encrypt)"
    echo "5. Remover Controladores"
    echo "6. Sair"
}

# Function to install Docker and dependencies
install_dependencies() {
    echo -e "${YELLOW}Atualizando sistema e instalando dependências...${NC}"
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        certbot

    # Install Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${YELLOW}Instalando Docker...${NC}"
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        rm get-docker.sh
        sudo systemctl start docker
        sudo systemctl enable docker
    fi

    # Install Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${YELLOW}Instalando Docker Compose...${NC}"
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi
}

# Function to create necessary directories
create_directories() {
    local controller=$1
    echo -e "${YELLOW}Criando diretórios...${NC}"
    
    if [[ $controller == "unifi" || $controller == "both" ]]; then
        mkdir -p unifi-data
        sudo chown -R 1000:1000 unifi-data
    fi
    
    if [[ $controller == "omada" || $controller == "both" ]]; then
        mkdir -p omada-data omada-logs
        sudo chown -R 1000:1000 omada-data omada-logs
    fi
}

# Main installation function
install_controllers() {
    local choice=$1
    
    # Install dependencies first
    install_dependencies
    
    case $choice in
        1|"unifi")
            create_directories "unifi"
            ./generate-compose.sh "unifi"
            ;;
        2|"omada")
            create_directories "omada"
            ./generate-compose.sh "omada"
            ;;
        3|"both")
            create_directories "both"
            ./generate-compose.sh "both"
            ;;
    esac
    
    echo -e "${YELLOW}Iniciando containers...${NC}"
    sudo docker-compose up -d
    
    echo -e "\n${GREEN}Instalação concluída!${NC}"
    display_access_info $choice
}

# Function to display access information
display_access_info() {
    local choice=$1
    echo -e "\n${GREEN}Informações de Acesso:${NC}"
    
    if [[ $choice == 1 || $choice == 3 ]]; then
        echo -e "\nUniFi Controller:"
        echo -e "Interface principal: https://seu-dominio:8443"
        echo -e "Porta Inform: https://seu-dominio:8844"
    fi
    
    if [[ $choice == 2 || $choice == 3 ]]; then
        echo -e "\nOmada Controller:"
        echo -e "Interface principal: https://seu-dominio:8043"
    fi
    
    echo -e "\nAguarde alguns minutos para os serviços iniciarem completamente."
}

# Make remove-controllers.sh executable
chmod +x remove-controllers.sh

# Main menu loop
while true; do
    show_menu
    read -p "Escolha uma opção: " choice
    
    case $choice in
        1|2|3)
            install_controllers $choice
            ;;
        4)
            ./setup-ssl.sh
            ;;
        5)
            ./remove-controllers.sh
            ;;
        6)
            echo -e "${GREEN}Saindo...${NC}"
            exit 0
            ;;
        *)
            echo -e "${YELLOW}Opção inválida. Tente novamente.${NC}"
            sleep 2
            ;;
    esac
done