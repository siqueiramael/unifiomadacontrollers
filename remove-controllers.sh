#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function to display menu
show_remove_menu() {
    clear
    echo -e "${RED}=== Remover Controladores ===${NC}"
    echo "1. Remover UniFi Controller"
    echo "2. Remover Omada Controller"
    echo "3. Remover Ambos Controladores"
    echo "4. Voltar"
}

# Function to remove UniFi Controller
remove_unifi() {
    echo -e "${YELLOW}Removendo UniFi Controller...${NC}"
    docker-compose stop unifi-controller
    docker-compose rm -f unifi-controller
    
    read -p "Deseja remover os dados do UniFi Controller? (s/N): " remove_data
    if [[ $remove_data =~ ^[Ss]$ ]]; then
        sudo rm -rf unifi-data
        sudo rm -rf ssl/unifi
        echo -e "${RED}Dados do UniFi Controller removidos${NC}"
    fi
}

# Function to remove Omada Controller
remove_omada() {
    echo -e "${YELLOW}Removendo Omada Controller...${NC}"
    docker-compose stop omada-controller
    docker-compose rm -f omada-controller
    
    read -p "Deseja remover os dados do Omada Controller? (s/N): " remove_data
    if [[ $remove_data =~ ^[Ss]$ ]]; then
        sudo rm -rf omada-data omada-logs
        sudo rm -rf ssl/omada
        echo -e "${RED}Dados do Omada Controller removidos${NC}"
    fi
}

# Main removal function
remove_controllers() {
    local choice=$1
    
    case $choice in
        1)
            remove_unifi
            ./generate-compose.sh "omada"
            ;;
        2)
            remove_omada
            ./generate-compose.sh "unifi"
            ;;
        3)
            remove_unifi
            remove_omada
            rm docker-compose.yml
            ;;
    esac
    
    if [[ -f docker-compose.yml ]]; then
        docker-compose up -d
    fi
    
    echo -e "${GREEN}Remoção concluída!${NC}"
}

# Main menu loop
while true; do
    show_remove_menu
    read -p "Escolha uma opção: " choice
    
    case $choice in
        1|2|3)
            remove_controllers $choice
            ;;
        4)
            exit 0
            ;;
        *)
            echo -e "${YELLOW}Opção inválida. Tente novamente.${NC}"
            sleep 2
            ;;
    esac
done