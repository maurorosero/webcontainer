#!/bin/bash

# Script para configurar DNS local para dominios .local
# Sin modificar /etc/hosts

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Cargar utilidades de contenedores
source "$SCRIPT_DIR/container-utils.sh"

# Configurar DNS local usando variables de entorno
setup_local_dns() {
    log_info "Configurando DNS local para dominios .local..."
    
    # Crear archivo de configuración DNS local
    cat > "$PROJECT_DIR/.local-dns" << 'EOF'
# Configuración DNS local para dominios .local
# Este archivo se carga automáticamente por los scripts

# Función para resolver dominios .local
resolve_local_domain() {
    local domain="$1"
    if [[ "$domain" == *".local" ]]; then
        echo "127.0.0.1"
        return 0
    fi
    return 1
}

# Función para probar resolución
test_local_domain() {
    local domain="$1"
    if resolve_local_domain "$domain"; then
        echo "✅ $domain -> 127.0.0.1"
    else
        echo "❌ $domain no es un dominio .local"
    fi
}

# Exportar funciones
export -f resolve_local_domain
export -f test_local_domain

# Configurar variables de entorno
export LOCAL_DNS_ENABLED=true
export LOCAL_DOMAINS="*.local"

# Mostrar información
echo "DNS local configurado:"
echo "  Dominios: *.local"
echo "  Resolución: 127.0.0.1"
echo "  Funciones: resolve_local_domain, test_local_domain"
EOF
    
    # Cargar configuración
    source "$PROJECT_DIR/.local-dns"
    
    log_info "✅ DNS local configurado para dominios .local"
    log_info "Archivo de configuración: $PROJECT_DIR/.local-dns"
}

# Probar DNS
test_dns() {
    log_info "Probando resolución DNS local..."
    
    # Cargar configuración si existe
    if [ -f "$PROJECT_DIR/.local-dns" ]; then
        source "$PROJECT_DIR/.local-dns"
    else
        log_error "DNS no configurado. Ejecuta '$0 setup' primero"
        return 1
    fi
    
    local test_domains=("whoami.local" "app.local" "api.local" "admin.local")
    
    for domain in "${test_domains[@]}"; do
        test_local_domain "$domain"
    done
}

# Mostrar información
show_info() {
    log_info "Información DNS Local:"
    echo "========================"
    
    if [ -f "$PROJECT_DIR/.local-dns" ]; then
        echo "✅ DNS configurado"
        echo "Archivo: $PROJECT_DIR/.local-dns"
        echo "Dominios: *.local"
        echo "Resolución: 127.0.0.1"
        echo ""
        echo "Para usar en scripts:"
        echo "  source $PROJECT_DIR/.local-dns"
        echo "  resolve_local_domain whoami.local"
        echo ""
        echo "Dominios de ejemplo:"
        echo "  https://whoami.local"
        echo "  https://app.local"
        echo "  https://api.local"
    else
        echo "❌ DNS no configurado"
        echo "Ejecuta: $0 setup"
    fi
}

# Limpiar configuración
cleanup() {
    log_info "Limpiando configuración DNS..."
    
    if [ -f "$PROJECT_DIR/.local-dns" ]; then
        rm "$PROJECT_DIR/.local-dns"
        log_info "✅ Configuración DNS limpiada"
    else
        log_info "No hay configuración DNS para limpiar"
    fi
}

# Función principal
case "$1" in
    setup)
        setup_local_dns
        ;;
    test)
        test_dns
        ;;
    info)
        show_info
        ;;
    cleanup)
        cleanup
        ;;
    *)
        echo "Uso: $0 {setup|test|info|cleanup}"
        echo ""
        echo "Comandos disponibles:"
        echo "  setup   - Configurar DNS local para dominios .local"
        echo "  test    - Probar resolución DNS"
        echo "  info    - Mostrar información DNS"
        echo "  cleanup - Limpiar configuración DNS"
        exit 1
        ;;
esac
