#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to setup SSL for UniFi Controller
setup_unifi_ssl() {
    local domain=$1
    
    echo -e "${YELLOW}Configurando SSL para UniFi Controller...${NC}"
    
    # Create SSL directory
    mkdir -p ssl/unifi
    
    # Generate certificate
    sudo certbot certonly --standalone -d $domain
    
    # Copy and convert certificates
    sudo cp /etc/letsencrypt/live/$domain/fullchain.pem ssl/unifi/
    sudo cp /etc/letsencrypt/live/$domain/privkey.pem ssl/unifi/
    
    # Convert to PKCS12 format for UniFi
    sudo openssl pkcs12 -export \
        -in ssl/unifi/fullchain.pem \
        -inkey ssl/unifi/privkey.pem \
        -out ssl/unifi/keystore \
        -name unifi \
        -password pass:aircontrolenterprise
    
    # Set permissions
    sudo chown -R 1000:1000 ssl/unifi
    
    echo -e "${GREEN}Certificado SSL configurado para UniFi Controller${NC}"
}

# Function to setup SSL for Omada Controller
setup_omada_ssl() {
    local domain=$1
    
    echo -e "${YELLOW}Configurando SSL para Omada Controller...${NC}"
    
    # Create SSL directory
    mkdir -p ssl/omada
    
    # Generate certificate
    sudo certbot certonly --standalone -d $domain
    
    # Copy certificates
    sudo cp /etc/letsencrypt/live/$domain/fullchain.pem ssl/omada/tls.crt
    sudo cp /etc/letsencrypt/live/$domain/privkey.pem ssl/omada/tls.key
    
    # Set permissions
    sudo chown -R 1000:1000 ssl/omada
    
    echo -e "${GREEN}Certificado SSL configurado para Omada Controller${NC}"
}

# Function to setup auto-renewal
setup_renewal() {
    echo -e "${YELLOW}Configurando renovação automática dos certificados...${NC}"
    
    # Create renewal script
    cat << 'EOF' > renew-certs.sh
#!/bin/bash

# Renew certificates
certbot renew --quiet

# Restart containers to apply new certificates
docker-compose restart
EOF

    chmod +x renew-certs.sh
    
    # Add to crontab
    (crontab -l 2>/dev/null; echo "0 0 1 * * /home/project/renew-certs.sh") | crontab -
    
    echo -e "${GREEN}Renovação automática configurada${NC}"
}

# Main menu
echo -e "${GREEN}=== Configuração de Certificado SSL ===${NC}"
echo "1. Configurar SSL para UniFi Controller"
echo "2. Configurar SSL para Omada Controller"
echo "3. Configurar SSL para ambos"
echo "4. Voltar"

read -p "Escolha uma opção: " choice

case $choice in
    1)
        read -p "Digite o domínio para o UniFi Controller: " domain
        setup_unifi_ssl $domain
        setup_renewal
        ;;
    2)
        read -p "Digite o domínio para o Omada Controller: " domain
        setup_omada_ssl $domain
        setup_renewal
        ;;
    3)
        read -p "Digite o domínio para o UniFi Controller: " unifi_domain
        read -p "Digite o domínio para o Omada Controller: " omada_domain
        setup_unifi_ssl $unifi_domain
        setup_omada_ssl $omada_domain
        setup_renewal
        ;;
    4)
        exit 0
        ;;
    *)
        echo -e "${YELLOW}Opção inválida${NC}"
        exit 1
        ;;
esac

echo -e "\n${GREEN}Configuração SSL concluída!${NC}"
echo -e "Lembre-se de reiniciar os containers para aplicar as alterações:"
echo -e "docker-compose restart"