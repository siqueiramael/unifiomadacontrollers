#!/bin/bash

# Function to generate docker-compose.yml
generate_compose() {
    local choice=$1
    echo "version: '3'" > docker-compose.yml
    echo "services:" >> docker-compose.yml
    
    if [[ $choice == "unifi" || $choice == "both" ]]; then
        cat << 'EOF' >> docker-compose.yml
  unifi-controller:
    image: lscr.io/linuxserver/unifi-controller:latest
    container_name: unifi-controller
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Sao_Paulo
    volumes:
      - ./unifi-data:/config
      - ./ssl/unifi:/config/cert
    ports:
      - 3478:3478/udp
      - 10001:10001/udp
      - 8080:8080
      - 8443:8443
      - 1900:1900/udp
      - 8844:8843
      - 8880:8880
      - 6789:6789
    restart: unless-stopped
EOF
    fi

    if [[ $choice == "omada" || $choice == "both" ]]; then
        cat << 'EOF' >> docker-compose.yml
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
      - ./ssl/omada:/opt/tplink/EAPController/cert
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
    fi
}