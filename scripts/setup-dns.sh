#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/container-utils.sh"

log_info "Configurando DNS local con dnsmasq..."

# Verificar que dnsmasq esté ejecutándose
if ! is_container_running "web-dnsmasq"; then
    log_error "dnsmasq no está ejecutándose. Inicia los servicios primero."
    exit 1
fi

# Usar el puerto expuesto de dnsmasq
DNSMASQ_HOST="127.0.0.1"
DNSMASQ_PORT="5354"

log_info "Usando dnsmasq en $DNSMASQ_HOST:$DNSMASQ_PORT"

# Crear archivo de configuración para systemd-resolved
RESOLVED_CONF_DIR="/etc/systemd/resolved.conf.d"
RESOLVED_CONF_FILE="$RESOLVED_CONF_DIR/90-local-dev.conf"

sudo mkdir -p "$RESOLVED_CONF_DIR"

cat << EOF | sudo tee "$RESOLVED_CONF_FILE"
[Resolve]
DNSStubListener=yes
DNS=$DNSMASQ_HOST:$DNSMASQ_PORT
Domains=~local
EOF

log_info "Archivo de configuración de systemd-resolved creado en $RESOLVED_CONF_FILE"

# Reiniciar systemd-resolved
sudo systemctl restart systemd-resolved

log_info "✅ DNS local configurado para resolver *.local a $DNSMASQ_HOST:$DNSMASQ_PORT"
log_info "Verifica la configuración con 'resolvectl status'"
log_info "Prueba con: nslookup whoami.local"
