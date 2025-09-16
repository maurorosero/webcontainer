#!/bin/bash

# Script para configurar automáticamente el entorno
# Detecta si es rootless y configura puertos apropiados

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

# Detectar si Podman está en modo rootless
detect_rootless_mode() {
    if command -v podman >/dev/null 2>&1; then
        if podman info --format '{{.Host.Security.Rootless}}' 2>/dev/null | grep -q "true"; then
            return 0
        fi
    fi
    return 1
}

# Configurar variables de entorno
setup_environment() {
    log_info "Configurando variables de entorno..."
    
    # Crear archivo .env si no existe
    if [ ! -f "$PROJECT_DIR/.env" ]; then
        log_info "Creando archivo .env desde template..."
        cp "$PROJECT_DIR/config.env.example" "$PROJECT_DIR/.env"
    fi
    
    # Detectar modo rootless y configurar puertos
    if detect_rootless_mode; then
        log_info "Detectado Podman rootless - configurando puertos no privilegiados"
        
        # Actualizar .env con puertos seguros
        sed -i 's/^TRAEFIK_HTTP_PORT=.*/TRAEFIK_HTTP_PORT=8080/' "$PROJECT_DIR/.env"
        sed -i 's/^TRAEFIK_HTTPS_PORT=.*/TRAEFIK_HTTPS_PORT=8443/' "$PROJECT_DIR/.env"
        
        log_info "Puertos configurados: HTTP=8080, HTTPS=8443"
    else
        log_info "Modo root detectado - usando puertos estándar"
        
        # Actualizar .env con puertos estándar
        sed -i 's/^TRAEFIK_HTTP_PORT=.*/TRAEFIK_HTTP_PORT=80/' "$PROJECT_DIR/.env"
        sed -i 's/^TRAEFIK_HTTPS_PORT=.*/TRAEFIK_HTTPS_PORT=443/' "$PROJECT_DIR/.env"
        
        log_info "Puertos configurados: HTTP=80, HTTPS=443"
    fi
    
    # Cargar variables de entorno
    if [ -f "$PROJECT_DIR/.env" ]; then
        log_info "Cargando variables de entorno..."
        set -a
        source "$PROJECT_DIR/.env"
        set +a
    fi
    
    log_info "✅ Variables de entorno configuradas"
}

# Mostrar configuración actual
show_config() {
    log_info "Configuración actual:"
    echo "=========================================="
    
    if [ -f "$PROJECT_DIR/.env" ]; then
        echo "Variables de entorno:"
        grep -E "^(TRAEFIK_|NETWORK_|BASE_DOMAIN)" "$PROJECT_DIR/.env" | while read -r line; do
            echo "  $line"
        done
    else
        log_warn "Archivo .env no encontrado"
    fi
    
    echo ""
    echo "Modo de contenedores:"
    if detect_rootless_mode; then
        echo "  Podman rootless (puertos no privilegiados)"
    else
        echo "  Root mode (puertos estándar)"
    fi
}

# Función principal
case "$1" in
    setup)
        setup_environment
        ;;
    show)
        show_config
        ;;
    *)
        echo "Uso: $0 {setup|show}"
        echo ""
        echo "Comandos disponibles:"
        echo "  setup - Configurar automáticamente el entorno"
        echo "  show  - Mostrar configuración actual"
        exit 1
        ;;
esac
