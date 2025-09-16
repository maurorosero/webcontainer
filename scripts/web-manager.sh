#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Cargar utilidades de contenedores
source "$SCRIPT_DIR/container-utils.sh"

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

# Inicializar sistema completo
init_complete_system() {
    log_info "Inicializando sistema web completo..."
    
    # 1. Configurar entorno automáticamente
    log_info "Paso 1: Configurando entorno automáticamente..."
    "$SCRIPT_DIR/setup-env.sh" setup
    
    # 2. Inicializar sistema de contenedores
    log_info "Paso 2: Inicializando sistema de contenedores..."
    init_container_system
    
    # 3. Crear directorios necesarios
    log_info "Paso 3: Creando directorios necesarios..."
    create_directories
    
    # 4. Configurar host para DNS local
    log_info "Paso 4: Configurando host para DNS local..."
    "$SCRIPT_DIR/setup-host.sh"
    
    # 5. Crear red Docker/Podman
    log_info "Paso 5: Creando red de contenedores..."
    create_network "web-dev-network" "172.20.0.0/16"
    
    # 6. Descargar imágenes necesarias
    log_info "Paso 6: Descargando imágenes necesarias..."
    pull_images "docker.io/library/traefik:v3.0" "docker.io/traefik/whoami:latest" "docker.io/library/alpine:latest"
    
    # 7. Iniciar servicios
    log_info "Paso 7: Iniciando servicios..."
    start_services
    
    # 8. Verificar sistema completo
    log_info "Paso 8: Verificando sistema completo..."
    verify_complete_system
    
    log_info "🎉 Sistema web completo inicializado exitosamente"
    log_info "Accede a: https://whoami.local:8443 (ejemplo)"
    log_info "Dashboard Traefik: http://localhost:8081"
    log_info "Los dominios .local se resuelven automáticamente"
    log_info "Host configurado automáticamente para DNS local"
}

# Crear directorios necesarios
create_directories() {
    log_info "Creando directorios necesarios..."
    
    # Directorios de Traefik
    mkdir -p "$PROJECT_DIR/logs/traefik"
    mkdir -p "$PROJECT_DIR/data/traefik"
    
    # Directorios de configuración
    mkdir -p "$PROJECT_DIR/config"
    
    # Directorios de aplicaciones
    mkdir -p "$PROJECT_DIR/logs/applications"
    mkdir -p "$PROJECT_DIR/logs/system"
    
    # Directorios de configuración
    mkdir -p "$PROJECT_DIR/config"
    
    # Directorios de backups
    mkdir -p "$PROJECT_DIR/backups/daily"
    mkdir -p "$PROJECT_DIR/backups/weekly"
    mkdir -p "$PROJECT_DIR/backups/monthly"
    
    # Directorios de documentación
    mkdir -p "$PROJECT_DIR/docs/examples"
    
    log_info "✅ Directorios creados"
}

# Verificar sistema completo
verify_complete_system() {
    log_info "Verificando sistema completo..."
    
    local all_ok=true
    
    # Verificar contenedores
    if ! check_services_health; then
        all_ok=false
    fi
    
    # Verificar configuración de Traefik
    if [ ! -f "$PROJECT_DIR/config/traefik.yml" ]; then
        log_error "❌ Configuración de Traefik no encontrada"
        all_ok=false
    fi
    
    # Verificar DNS local
    if ! nslookup "whoami.local" >/dev/null 2>&1; then
        log_warn "⚠️  DNS local no configurado"
        all_ok=false
    fi
    
    # Verificar Traefik
    if ! is_container_running "web-traefik"; then
        log_error "❌ Traefik no está ejecutándose"
        all_ok=false
    fi
    
    if [ "$all_ok" = true ]; then
        log_info "✅ Sistema completo verificado correctamente"
    else
        log_warn "⚠️  Algunos componentes tienen problemas"
    fi
}

# Iniciar servicios
start_services() {
    log_info "Iniciando servicios..."
    
    cd "$PROJECT_DIR"
    run_compose_safe up -d
    
    log_info "Esperando que los servicios estén listos..."
    sleep 15
    
    # Verificar estado de servicios
    check_services_health
}

# Detener servicios
stop_services() {
    log_info "Deteniendo servicios..."
    
    cd "$PROJECT_DIR"
    run_compose_safe down
    
    log_info "✅ Servicios detenidos"
}

# Reiniciar servicios
restart_services() {
    log_info "Reiniciando servicios..."
    
    cd "$PROJECT_DIR"
    run_compose restart
    
    log_info "✅ Servicios reiniciados"
}

# Verificar salud de servicios
check_services_health() {
    log_info "Verificando salud de servicios..."
    
    local services=("traefik" "app-registry" "dnsmasq" "whoami")
    local all_healthy=true
    
    for service in "${services[@]}"; do
        if is_container_running "web-$service"; then
            log_info "✅ $service está ejecutándose"
        else
            log_error "❌ $service no está ejecutándose"
            all_healthy=false
        fi
    done
    
    if [ "$all_healthy" = true ]; then
        log_info "✅ Todos los servicios están saludables"
    else
        log_warn "⚠️  Algunos servicios no están saludables"
    fi
}

# Mostrar estado de servicios
show_status() {
    log_info "Estado del sistema web completo:"
    echo "=================================="
    
    # Estado de contenedores
    echo ""
    log_info "Contenedores:"
    cd "$PROJECT_DIR"
    run_compose ps
    
    # Estado de certificados
    echo ""
    log_info "Certificados:"
    # Verificar configuración de Traefik
    if [ -f "$PROJECT_DIR/config/traefik.yml" ]; then
        log_info "✅ Configuración de Traefik encontrada"
    else
        log_error "❌ Configuración de Traefik no encontrada"
    fi
    
    # Estado de DNS
    echo ""
    log_info "DNS local:"
    if nslookup "local.dev" >/dev/null 2>&1; then
        log_info "✅ DNS local configurado"
    else
        log_warn "⚠️  DNS local no configurado"
    fi
}

# Mostrar logs de servicios
show_logs() {
    local service="$1"
    local lines="${2:-100}"
    
    if [ -z "$service" ]; then
        log_info "Mostrando logs de todos los servicios..."
        cd "$PROJECT_DIR"
        run_compose logs --tail="$lines" -f
    else
        log_info "Mostrando logs de $service..."
        get_container_logs "web-$service" "$lines"
    fi
}

# Limpiar recursos
cleanup() {
    log_warn "Limpiando recursos del sistema web..."
    
    cd "$PROJECT_DIR"
    
    # Detener y eliminar contenedores
    run_compose down --remove-orphans
    
    # Eliminar imágenes no utilizadas
    container_image_prune
    container_volume_prune
    container_network_prune
    
    log_info "✅ Limpieza completada"
}

# Backup completo del sistema
backup_complete_system() {
    local backup_dir="$PROJECT_DIR/backups/$(date +%Y%m%d_%H%M%S)"
    
    log_info "Creando backup completo del sistema en $backup_dir..."
    
    mkdir -p "$backup_dir"
    
    # Backup de configuraciones
    cp -r "$PROJECT_DIR/caddy" "$backup_dir/"
    cp -r "$PROJECT_DIR/certs" "$backup_dir/"
    cp -r "$PROJECT_DIR/config" "$backup_dir/"
    cp "$PROJECT_DIR/docker-compose.yml" "$backup_dir/"
    cp "$PROJECT_DIR/env.example" "$backup_dir/" 2>/dev/null || true
    
    # Backup de volúmenes Docker/Podman
    container_run --rm -v "$PROJECT_DIR/caddy/data:/data" -v "$backup_dir:/backup" \
        alpine tar czf /backup/caddy-data.tar.gz -C /data .
    
    log_info "✅ Backup completo creado en $backup_dir"
}

# Restaurar sistema completo
restore_complete_system() {
    local backup_dir="$1"
    
    if [ -z "$backup_dir" ]; then
        log_error "Debe especificar el directorio de backup"
        exit 1
    fi
    
    if [ ! -d "$backup_dir" ]; then
        log_error "Directorio de backup no encontrado: $backup_dir"
        exit 1
    fi
    
    log_warn "Restaurando sistema completo desde $backup_dir..."
    
    # Detener servicios
    stop_services
    
    # Restaurar configuraciones
    cp -r "$backup_dir/caddy" "$PROJECT_DIR/"
    cp -r "$backup_dir/certs" "$PROJECT_DIR/"
    cp -r "$backup_dir/config" "$PROJECT_DIR/"
    cp "$backup_dir/docker-compose.yml" "$PROJECT_DIR/"
    cp "$backup_dir/env.example" "$PROJECT_DIR/" 2>/dev/null || true
    
    # Restaurar volúmenes
    if [ -f "$backup_dir/caddy-data.tar.gz" ]; then
        container_run --rm -v "$PROJECT_DIR/caddy/data:/data" -v "$backup_dir:/backup" \
            alpine tar xzf /backup/caddy-data.tar.gz -C /data
    fi
    
    # Reiniciar servicios
    start_services
    
    log_info "✅ Sistema completo restaurado desde $backup_dir"
}

# Limpiar redes específicas
clean_networks() {
    local project_name="${1:-web}"
    log_info "🧹 Limpiando redes del proyecto: $project_name"
    
    case "$CONTAINER_ENGINE" in
        podman)
            # Listar y eliminar redes del proyecto
            podman network ls --filter "name=${project_name}_" --format "{{.Name}}" | while read -r network; do
                if [ -n "$network" ]; then
                    log_info "Eliminando red Podman: $network"
                    podman network rm "$network" 2>/dev/null || true
                fi
            done
            
            # Eliminar red específica si existe
            if podman network exists "${project_name}_web-dev-network" 2>/dev/null; then
                log_info "Eliminando red específica: ${project_name}_web-dev-network"
                podman network rm "${project_name}_web-dev-network" 2>/dev/null || true
            fi
            ;;
        docker)
            # Listar y eliminar redes del proyecto
            docker network ls --filter "name=${project_name}_" --format "{{.Name}}" | while read -r network; do
                if [ -n "$network" ]; then
                    log_info "Eliminando red Docker: $network"
                    docker network rm "$network" 2>/dev/null || true
                fi
            done
            
            # Eliminar red específica si existe
            if docker network ls --filter "name=${project_name}_web-dev-network" --format "{{.Name}}" | grep -q "${project_name}_web-dev-network"; then
                log_info "Eliminando red específica: ${project_name}_web-dev-network"
                docker network rm "${project_name}_web-dev-network" 2>/dev/null || true
            fi
            ;;
    esac
    
    log_info "✅ Redes limpiadas"
}

# Limpiar completamente el sistema (desinicializar)
clean_system() {
    log_info "🧹 Limpiando completamente el sistema..."
    
    # Detener y eliminar contenedores
    log_info "Deteniendo y eliminando contenedores..."
    run_compose_safe down -v
    
    # Limpiar redes específicamente
    clean_networks "web"
    
    # Limpiar directorios de datos
    log_info "Limpiando directorios de datos..."
    rm -rf logs/ data/ .env 2>/dev/null || true
    
    # Restaurar configuración del host
    log_info "Restaurando configuración del host..."
    "$SCRIPT_DIR/restore-host.sh"
    
    # Limpiar imágenes no utilizadas (opcional)
    log_info "Limpiando imágenes no utilizadas..."
    container_image_prune 2>/dev/null || true
    
    log_info "✅ Sistema completamente limpiado"
    log_info "Ejecuta '$0 init' para reinicializar desde cero"
}

# Detener servicios (down)
down_services() {
    log_info "⬇️  Deteniendo servicios..."
    
    cd "$PROJECT_DIR"
    run_compose_safe down
    
    log_info "✅ Servicios detenidos"
}

# Iniciar servicios (up)
up_services() {
    log_info "⬆️  Iniciando servicios..."
    
    # Verificar que el sistema esté inicializado
    if [ ! -f ".env" ]; then
        log_error "Sistema no inicializado. Ejecuta '$0 init' primero"
        exit 1
    fi
    
    cd "$PROJECT_DIR"
    run_compose_safe up -d
    
    log_info "Esperando que los servicios estén listos..."
    sleep 10
    
    # Verificar estado de servicios
    check_services_health
    
    log_info "✅ Servicios iniciados"
}

# Menú principal
case "$1" in
    init)
        init_complete_system
        ;;
    up)
        up_services
        ;;
    down)
        down_services
        ;;
    clean)
        clean_system
        ;;
    clean-networks)
        clean_networks "web"
        ;;
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs "$2" "$3"
        ;;
    health)
        check_services_health
        ;;
    cleanup)
        cleanup
        ;;
    backup)
        backup_complete_system
        ;;
    restore)
        restore_complete_system "$2"
        ;;
    verify)
        verify_complete_system
        ;;
    *)
        echo "Uso: $0 {init|up|down|clean|clean-networks|start|stop|restart|status|logs|health|cleanup|backup|restore|verify}"
        echo ""
        echo "Comandos disponibles:"
        echo "  init     - Inicializar sistema completo desde cero (contenedores + certificados + DNS)"
        echo "  up       - Iniciar servicios (requiere init previo)"
        echo "  down     - Detener servicios"
        echo "  clean    - Limpiar completamente el sistema (desinicializar)"
        echo "  clean-networks - Limpiar solo las redes del proyecto"
        echo "  start    - Iniciar todos los servicios"
        echo "  stop     - Detener todos los servicios"
        echo "  restart  - Reiniciar todos los servicios"
        echo "  status   - Mostrar estado completo del sistema"
        echo "  logs     - Mostrar logs [service] [lines]"
        echo "  health   - Verificar salud de servicios"
        echo "  cleanup  - Limpiar recursos del sistema"
        echo "  backup   - Crear backup completo del sistema"
        echo "  restore  - Restaurar sistema completo desde backup"
        echo "  verify   - Verificar sistema completo"
        echo ""
        echo "Ejemplos:"
        echo "  $0 init      # Inicializar desde cero"
        echo "  $0 up        # Iniciar servicios"
        echo "  $0 down      # Detener servicios"
        echo "  $0 clean     # Limpiar todo y volver a cero"
        echo "  $0 status    # Ver estado"
        echo "  $0 logs caddy 50"
        exit 1
        ;;
esac
