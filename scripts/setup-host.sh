#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/container-utils.sh"

log_info "Configurando host para DNS local..."

# Verificar que dnsmasq esté ejecutándose
if ! is_container_running "web-dnsmasq"; then
    log_error "dnsmasq no está ejecutándose. Inicia los servicios primero."
    exit 1
fi

# 1. Iniciar socket de Podman si no está activo
log_info "Verificando socket de Podman..."
if ! systemctl --user is-active podman.socket >/dev/null 2>&1; then
    log_info "Iniciando socket de Podman..."
    systemctl --user start podman.socket
    log_info "✅ Socket de Podman iniciado"
else
    log_info "✅ Socket de Podman ya está activo"
fi

# 2. Crear configuración de systemd-resolved
log_info "Configurando systemd-resolved..."
RESOLVED_CONF_DIR="/etc/systemd/resolved.conf.d"
RESOLVED_CONF_FILE="$RESOLVED_CONF_DIR/90-local-dev.conf"

sudo mkdir -p "$RESOLVED_CONF_DIR"

# Obtener DNS del sistema actual
CURRENT_DNS=$(resolvectl status | grep "DNS Servers:" | sed 's/.*DNS Servers: //' | tr -d ' ')

# Crear configuración con DNS del sistema como fallback
cat << EOF | sudo tee "$RESOLVED_CONF_FILE"
[Resolve]
DNSStubListener=yes
DNS=127.0.0.1:5354 $CURRENT_DNS
Domains=~local
EOF

log_info "✅ Archivo de configuración creado: $RESOLVED_CONF_FILE"

# 3. Reiniciar systemd-resolved
log_info "Reiniciando systemd-resolved..."
sudo systemctl restart systemd-resolved
log_info "✅ systemd-resolved reiniciado"

# 4. Verificar configuración
log_info "Verificando configuración..."
if resolvectl status | grep -q "127.0.0.1:5354"; then
    log_info "✅ DNS local configurado correctamente"
else
    log_warn "⚠️  Configuración de DNS puede no estar activa"
fi

log_info "🎉 Host configurado para DNS local"
log_info "Los dominios *.local ahora se resuelven automáticamente"
log_info "Si dnsmasq falla, DNS público seguirá funcionando"
