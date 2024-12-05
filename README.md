# Guia de Instalação UniFi & Omada Controller

Este guia fornece instruções detalhadas para instalar os controladores UniFi e TP-Link Omada em um servidor Ubuntu 20.04 usando Docker, incluindo configuração de certificados SSL.

## Índice
- [Requisitos do Sistema](#requisitos-do-sistema)
- [Instalação Rápida](#instalação-rápida)
- [Instalação Detalhada](#instalação-detalhada)
  - [Preparação do Sistema](#preparação-do-sistema)
  - [Instalação dos Controladores](#instalação-dos-controladores)
  - [Configuração SSL](#configuração-ssl)
- [Portas Utilizadas](#portas-utilizadas)
  - [UniFi Controller](#unifi-controller)
  - [Omada Controller](#omada-controller)
- [Configuração Inicial](#configuração-inicial)
  - [UniFi Controller](#configuração-unifi)
  - [Omada Controller](#configuração-omada)
- [Manutenção](#manutenção)
  - [Atualização dos Controladores](#atualização-dos-controladores)
  - [Backup dos Dados](#backup-dos-dados)
  - [Renovação de Certificados](#renovação-de-certificados)
- [Remoção dos Controladores](#remoção-dos-controladores)
- [Resolução de Problemas](#resolução-de-problemas)
- [Perguntas Frequentes](#perguntas-frequentes)

## Requisitos do Sistema

- Ubuntu Server 20.04 LTS
- Mínimo 2GB RAM (4GB recomendado)
- Mínimo 20GB de espaço em disco
- Conexão com a internet
- Portas necessárias liberadas no firewall
- Domínio válido (para SSL)

## Instalação Rápida

```bash
git clone https://github.com/seu-usuario/unifi-omada-docker
cd unifi-omada-docker
chmod +x *.sh
./install.sh
```

## Instalação Detalhada

### Preparação do Sistema

1. **Atualização do Sistema**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Instalação de Dependências**
   ```bash
   sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
   ```

3. **Instalação do Docker**
   - O script `install.sh` instalará automaticamente o Docker e Docker Compose
   - Verificação da instalação:
     ```bash
     docker --version
     docker-compose --version
     ```

### Instalação dos Controladores

1. **Menu de Instalação**
   - Execute `./install.sh`
   - Opções disponíveis:
     1. Instalar UniFi Controller
     2. Instalar Omada Controller
     3. Instalar Ambos
     4. Configurar SSL
     5. Remover Controladores
     6. Sair

2. **Estrutura de Diretórios**
   ```
   /
   ├── unifi-data/     # Dados do UniFi Controller
   ├── omada-data/     # Dados do Omada Controller
   ├── omada-logs/     # Logs do Omada Controller
   ├── ssl/            # Certificados SSL
   │   ├── unifi/      # Certificados do UniFi
   │   └── omada/      # Certificados do Omada
   └── docker-compose.yml
   ```

### Configuração SSL

1. **Requisitos**
   - Domínio válido apontando para o servidor
   - Portas 80 e 443 liberadas

2. **Instalação do Certificado**
   ```bash
   ./setup-ssl.sh
   ```

3. **Renovação Automática**
   - Script `renew-certs.sh` configurado no crontab
   - Executa mensalmente
   - Reinicia containers automaticamente após renovação

## Portas Utilizadas

### UniFi Controller
- 3478/udp: STUN
- 8080: Portal HTTP
- 8443: Interface Web
- 8844: Porta Inform
- 8880: Portal HTTPS
- 6789: Descoberta de dispositivos
- 10001/udp: Descoberta de dispositivos

### Omada Controller
- 8088: Portal HTTP
- 8043: Interface Web
- 8843: Portal HTTPS
- 29810/udp: Descoberta de dispositivos
- 29811-29813: Comunicação com dispositivos

## Configuração Inicial

### Configuração UniFi
1. Acesse https://seu-dominio:8443
2. Aguarde a inicialização (pode levar alguns minutos)
3. Siga o assistente de configuração
4. Configure a porta Inform como 8844

### Configuração Omada
1. Acesse https://seu-dominio:8043
2. Aguarde a inicialização (pode levar alguns minutos)
3. Crie sua conta de administrador
4. Configure a rede inicial

## Manutenção

### Atualização dos Controladores
```bash
# Atualizar imagens
docker-compose pull

# Reiniciar containers
docker-compose down
docker-compose up -d
```

### Backup dos Dados
```bash
# UniFi
tar -czf unifi-backup.tar.gz unifi-data/

# Omada
tar -czf omada-backup.tar.gz omada-data/ omada-logs/
```

### Renovação de Certificados
- Automática: Configurada no crontab
- Manual: Execute `./renew-certs.sh`

## Remoção dos Controladores

1. Execute `./remove-controllers.sh`
2. Selecione o controlador a ser removido
3. Escolha se deseja remover os dados
4. Confirme a remoção

## Resolução de Problemas

### Problemas Comuns

1. **Conflito de Portas**
   - Verifique se as portas estão em uso:
     ```bash
     sudo netstat -tulpn | grep LISTEN
     ```
   - Ajuste as portas no docker-compose.yml

2. **Erro de Certificado SSL**
   - Verifique os logs:
     ```bash
     docker-compose logs unifi-controller
     docker-compose logs omada-controller
     ```
   - Reexecute setup-ssl.sh

3. **Controlador Não Inicia**
   - Verifique os requisitos de sistema
   - Verifique os logs dos containers
   - Reinicie os containers

## Perguntas Frequentes

1. **Como acessar os logs?**
   ```bash
   # UniFi Controller
   docker-compose logs -f unifi-controller

   # Omada Controller
   docker-compose logs -f omada-controller
   ```

2. **Como fazer backup?**
   - Use os comandos da seção [Backup dos Dados](#backup-dos-dados)
   - Mantenha backups regulares
   - Armazene em local seguro

3. **Como atualizar os controladores?**
   - Use os comandos da seção [Atualização dos Controladores](#atualização-dos-controladores)
   - Faça backup antes de atualizar
   - Verifique as notas de versão

4. **Como transferir para outro servidor?**
   1. Faça backup dos dados
   2. Instale no novo servidor
   3. Restaure os backups
   4. Atualize DNS se necessário