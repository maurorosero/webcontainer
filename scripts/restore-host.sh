#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/container-utils.sh"

log_info "Restaurando configuración original del host..."

# 1. Eliminar configuración personalizada de systemd-resolved
RESOLVED_CONF_FILE="/etc/systemd/resolved.conf.d/90-local-dev.conf"
if [ -f "$RESOLVED_CONF_FILE" ]; then
    log_info "Eliminando configuración personalizada de DNS..."
    sudo rm -f "$RESOLVED_CONF_FILE"
    log_info "✅ Archivo de configuración eliminado"
else
    log_info "✅ No hay configuración personalizada que eliminar"
fi

# 2. Reiniciar systemd-resolved para restaurar configuración original
log_info "Reiniciando systemd-resolved para restaurar configuración original..."
sudo systemctl restart systemd-resolved
log_info "✅ systemd-resolved restaurado a configuración original"

# 3. Verificar configuración restaurada
log_info "Verificando configuración restaurada..."
if resolvectl status | grep -q "127.0.0.1:5354"; then
    log_warn "⚠️  Configuración personalizada aún activa"
else
    log_info "✅ DNS restaurado a configuración original del sistema"
fi

log_info "🎉 Host restaurado a configuración original"
log_info "DNS ahora usa la configuración natural del sistema"
