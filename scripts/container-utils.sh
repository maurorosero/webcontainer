#!/bin/bash

# Script de utilidades para contenedores (Podman/Docker)
# Detecta automáticamente qué sistema está disponible

# Variables globales
CONTAINER_ENGINE=""
COMPOSE_ENGINE=""
CONTAINER_CMD=""
COMPOSE_CMD=""

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

# Detectar motor de contenedores disponible
detect_container_engine() {
    log_debug "Detectando motor de contenedores..."
    
    # Verificar Podman
    if command -v podman >/dev/null 2>&1; then
        if podman info >/dev/null 2>&1; then
            CONTAINER_ENGINE="podman"
            CONTAINER_CMD="podman"
            log_info "✅ Podman detectado y funcionando"
            
            # Verificar podman-compose
            if command -v podman-compose >/dev/null 2>&1; then
                COMPOSE_ENGINE="podman-compose"
                COMPOSE_CMD="podman-compose"
                log_info "✅ podman-compose detectado"
            elif command -v docker-compose >/dev/null 2>&1; then
                COMPOSE_ENGINE="docker-compose"
                COMPOSE_CMD="docker-compose"
                log_warn "⚠️  Usando docker-compose con Podman"
            else
                log_warn "⚠️  No se encontró herramienta de compose"
            fi
            return 0
        else
            log_warn "⚠️  Podman instalado pero no funcionando"
        fi
    fi
    
    # Verificar Docker
    if command -v docker >/dev/null 2>&1; then
        if docker info >/dev/null 2>&1; then
            CONTAINER_ENGINE="docker"
            CONTAINER_CMD="docker"
            log_info "✅ Docker detectado y funcionando"
            
            # Verificar docker-compose
            if command -v docker-compose >/dev/null 2>&1; then
                COMPOSE_ENGINE="docker-compose"
                COMPOSE_CMD="docker-compose"
                log_info "✅ docker-compose detectado"
            elif docker compose version >/dev/null 2>&1; then
                COMPOSE_ENGINE="docker-compose-plugin"
                COMPOSE_CMD="docker compose"
                log_info "✅ Docker Compose Plugin detectado"
            else
                log_warn "⚠️  No se encontró herramienta de compose"
            fi
            return 0
        else
            log_warn "⚠️  Docker instalado pero no funcionando"
        fi
    fi
    
    log_error "❌ No se encontró ningún motor de contenedores funcionando"
    return 1
}

# Verificar dependencias
check_dependencies() {
    log_info "Verificando dependencias..."
    
    # Detectar motor de contenedores
    if ! detect_container_engine; then
        log_error "No se puede continuar sin un motor de contenedores"
        exit 1
    fi
    
    # Verificar herramientas adicionales
    local missing_tools=()
    
    if ! command -v yq >/dev/null 2>&1; then
        missing_tools+=("yq")
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        missing_tools+=("jq")
    fi
    
    if ! command -v curl >/dev/null 2>&1; then
        missing_tools+=("curl")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_warn "Herramientas faltantes: ${missing_tools[*]}"
        log_info "Instalación recomendada:"
        for tool in "${missing_tools[@]}"; do
            case "$tool" in
                yq)
                    log_info "  pip install yq"
                    ;;
                jq)
                    log_info "  apt install jq  # Ubuntu/Debian"
                    log_info "  dnf install jq  # Fedora/CentOS"
                    ;;
                curl)
                    log_info "  apt install curl  # Ubuntu/Debian"
                    log_info "  dnf install curl  # Fedora/CentOS"
                    ;;
            esac
        done
    fi
    
    log_info "✅ Dependencias verificadas"
}

# Obtener información del motor de contenedores
get_container_info() {
    case "$CONTAINER_ENGINE" in
        podman)
            podman info --format json
            ;;
        docker)
            docker info --format json
            ;;
    esac
}

# Listar contenedores
list_containers() {
    case "$CONTAINER_ENGINE" in
        podman)
            podman ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
            ;;
        docker)
            docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
            ;;
    esac
}

# Ejecutar comando en contenedor
exec_container() {
    local container_name="$1"
    shift
    local command="$*"
    
    case "$CONTAINER_ENGINE" in
        podman)
            podman exec "$container_name" $command
            ;;
        docker)
            docker exec "$container_name" $command
            ;;
    esac
}

# Obtener logs de contenedor
get_container_logs() {
    local container_name="$1"
    local lines="${2:-100}"
    
    case "$CONTAINER_ENGINE" in
        podman)
            podman logs --tail="$lines" "$container_name"
            ;;
        docker)
            docker logs --tail="$lines" "$container_name"
            ;;
    esac
}

# Verificar si contenedor está ejecutándose
is_container_running() {
    local container_name="$1"
    
    case "$CONTAINER_ENGINE" in
        podman)
            podman ps --format "{{.Names}}" | grep -q "^$container_name$"
            ;;
        docker)
            docker ps --format "{{.Names}}" | grep -q "^$container_name$"
            ;;
    esac
}

# Obtener IP de contenedor
get_container_ip() {
    local container_name="$1"
    
    case "$CONTAINER_ENGINE" in
        podman)
            podman inspect "$container_name" --format "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}"
            ;;
        docker)
            docker inspect "$container_name" --format "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}"
            ;;
    esac
}

# Crear red
create_network() {
    local network_name="$1"
    local subnet="${2:-172.20.0.0/16}"
    
    case "$CONTAINER_ENGINE" in
        podman)
            podman network create --subnet "$subnet" "$network_name" 2>/dev/null || true
            ;;
        docker)
            docker network create --subnet "$subnet" "$network_name" 2>/dev/null || true
            ;;
    esac
}

# Eliminar red
remove_network() {
    local network_name="$1"
    
    case "$CONTAINER_ENGINE" in
        podman)
            podman network rm "$network_name" 2>/dev/null || true
            ;;
        docker)
            docker network rm "$network_name" 2>/dev/null || true
            ;;
    esac
}

# Ejecutar compose
run_compose() {
    local action="$1"
    shift
    local args="$*"
    
    case "$COMPOSE_ENGINE" in
        podman-compose)
            podman-compose "$action" $args
            ;;
        docker-compose)
            docker-compose "$action" $args
            ;;
        docker-compose-plugin)
            docker compose "$action" $args
            ;;
    esac
}

# Wrapper para comandos directos de contenedores
container_restart() {
    local container_name="$1"
    case "$CONTAINER_ENGINE" in
        podman)
            podman restart "$container_name"
            ;;
        docker)
            docker restart "$container_name"
            ;;
    esac
}

container_logs() {
    local container_name="$1"
    local lines="${2:-100}"
    case "$CONTAINER_ENGINE" in
        podman)
            podman logs --tail="$lines" "$container_name"
            ;;
        docker)
            docker logs --tail="$lines" "$container_name"
            ;;
    esac
}

container_stop() {
    local container_name="$1"
    case "$CONTAINER_ENGINE" in
        podman)
            podman stop "$container_name"
            ;;
        docker)
            docker stop "$container_name"
            ;;
    esac
}

container_start() {
    local container_name="$1"
    case "$CONTAINER_ENGINE" in
        podman)
            podman start "$container_name"
            ;;
        docker)
            docker start "$container_name"
            ;;
    esac
}

container_rm() {
    local container_name="$1"
    case "$CONTAINER_ENGINE" in
        podman)
            podman rm "$container_name"
            ;;
        docker)
            docker rm "$container_name"
            ;;
    esac
}

container_exec() {
    local container_name="$1"
    shift
    local command="$*"
    case "$CONTAINER_ENGINE" in
        podman)
            podman exec "$container_name" $command
            ;;
        docker)
            docker exec "$container_name" $command
            ;;
    esac
}

# Wrapper para comandos de limpieza
container_image_prune() {
    case "$CONTAINER_ENGINE" in
        podman)
            podman image prune -f
            ;;
        docker)
            docker image prune -f
            ;;
    esac
}

container_volume_prune() {
    case "$CONTAINER_ENGINE" in
        podman)
            podman volume prune -f
            ;;
        docker)
            docker volume prune -f
            ;;
    esac
}

container_network_prune() {
    case "$CONTAINER_ENGINE" in
        podman)
            podman network prune -f
            ;;
        docker)
            docker network prune -f
            ;;
    esac
}

# Wrapper para comandos de run
container_run() {
    local args="$*"
    case "$CONTAINER_ENGINE" in
        podman)
            podman run $args
            ;;
        docker)
            docker run $args
            ;;
    esac
}

# Descargar imágenes automáticamente
pull_images() {
    local images=("$@")
    log_info "Descargando imágenes necesarias..."
    
    for image in "${images[@]}"; do
        log_info "Descargando: $image"
        case "$CONTAINER_ENGINE" in
            podman)
                podman pull "$image" || {
                    log_error "Error descargando $image"
                    return 1
                }
                ;;
            docker)
                docker pull "$image" || {
                    log_error "Error descargando $image"
                    return 1
                }
                ;;
        esac
    done
    
    log_info "✅ Todas las imágenes descargadas"
}

# Mostrar información del sistema
show_system_info() {
    log_info "Información del sistema de contenedores:"
    echo "=========================================="
    echo "Motor de contenedores: $CONTAINER_ENGINE"
    echo "Comando de contenedores: $CONTAINER_CMD"
    echo "Motor de compose: $COMPOSE_ENGINE"
    echo "Comando de compose: $COMPOSE_CMD"
    echo ""
    
    log_info "Versiones:"
    case "$CONTAINER_ENGINE" in
        podman)
            podman --version
            ;;
        docker)
            docker --version
            ;;
    esac
    
    case "$COMPOSE_ENGINE" in
        podman-compose)
            podman-compose --version
            ;;
        docker-compose)
            docker-compose --version
            ;;
        docker-compose-plugin)
            docker compose version
            ;;
    esac
}

# Detectar si Podman está en modo rootless
detect_rootless_mode() {
    if [[ "$CONTAINER_ENGINE" == "podman" ]]; then
        if podman info --format '{{.Host.Security.Rootless}}' 2>/dev/null | grep -q "true"; then
            log_info "Podman detectado en modo rootless"
            return 0
        else
            log_info "Podman detectado en modo root"
            return 1
        fi
    fi
    return 1
}

# Obtener puertos seguros para rootless
get_safe_ports() {
    if detect_rootless_mode; then
        # Usar puertos no privilegiados para rootless
        export CADDY_HTTP_PORT="${CADDY_HTTP_PORT:-8080}"
        export CADDY_HTTPS_PORT="${CADDY_HTTPS_PORT:-8443}"
        export CADDY_ADMIN_PORT="${CADDY_ADMIN_PORT:-2019}"
        log_info "Configurando puertos seguros para rootless: HTTP=$CADDY_HTTP_PORT, HTTPS=$CADDY_HTTPS_PORT"
    else
        # Usar puertos estándar para root
        export CADDY_HTTP_PORT="${CADDY_HTTP_PORT:-80}"
        export CADDY_HTTPS_PORT="${CADDY_HTTPS_PORT:-443}"
        export CADDY_ADMIN_PORT="${CADDY_ADMIN_PORT:-2019}"
        log_info "Configurando puertos estándar: HTTP=$CADDY_HTTP_PORT, HTTPS=$CADDY_HTTPS_PORT"
    fi
}

# Limpiar contenedores existentes del proyecto
cleanup_existing_containers() {
    local project_name="${1:-web}"
    log_info "Limpiando contenedores existentes del proyecto: $project_name"
    
    case "$CONTAINER_ENGINE" in
        podman)
            # Detener y eliminar contenedores del proyecto
            podman ps -a --filter "label=com.docker.compose.project=$project_name" --format "{{.Names}}" | while read -r container; do
                if [ -n "$container" ]; then
                    log_info "Eliminando contenedor: $container"
                    podman stop "$container" 2>/dev/null || true
                    podman rm "$container" 2>/dev/null || true
                fi
            done
            
            # Eliminar redes del proyecto
            podman network ls --filter "name=${project_name}_" --format "{{.Name}}" | while read -r network; do
                if [ -n "$network" ]; then
                    log_info "Eliminando red: $network"
                    podman network rm "$network" 2>/dev/null || true
                fi
            done
            ;;
        docker)
            # Detener y eliminar contenedores del proyecto
            docker ps -a --filter "label=com.docker.compose.project=$project_name" --format "{{.Names}}" | while read -r container; do
                if [ -n "$container" ]; then
                    log_info "Eliminando contenedor: $container"
                    docker stop "$container" 2>/dev/null || true
                    docker rm "$container" 2>/dev/null || true
                fi
            done
            
            # Eliminar redes del proyecto
            docker network ls --filter "name=${project_name}_" --format "{{.Name}}" | while read -r network; do
                if [ -n "$network" ]; then
                    log_info "Eliminando red: $network"
                    docker network rm "$network" 2>/dev/null || true
                fi
            done
            ;;
    esac
    
    log_info "✅ Limpieza de contenedores completada"
}

# Ejecutar compose con limpieza automática
run_compose_safe() {
    local action="$1"
    shift
    local args="$*"
    local project_name="${COMPOSE_PROJECT_NAME:-web}"
    
    # Limpiar contenedores existentes antes de ejecutar
    cleanup_existing_containers "$project_name"
    
    # Configurar puertos seguros
    get_safe_ports
    
    # Ejecutar compose
    log_info "Ejecutando: $COMPOSE_CMD $action $args"
    run_compose "$action" "$args"
}

# Inicializar sistema
init_container_system() {
    log_info "Inicializando sistema de contenedores..."
    
    # Detectar motor
    detect_container_engine
    
    # Verificar dependencias
    check_dependencies
    
    # Configurar puertos seguros
    get_safe_ports
    
    # Mostrar información
    show_system_info
    
    log_info "✅ Sistema de contenedores inicializado"
}

# Función principal (solo se ejecuta si el script se ejecuta directamente)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "$1" in
        init)
            init_container_system
            ;;
        info)
            show_system_info
            ;;
        check)
            check_dependencies
            ;;
        detect)
            detect_container_engine
            ;;
        *)
            echo "Uso: $0 {init|info|check|detect}"
            echo ""
            echo "Comandos disponibles:"
            echo "  init     - Inicializar sistema de contenedores"
            echo "  info     - Mostrar información del sistema"
            echo "  check    - Verificar dependencias"
            echo "  detect   - Detectar motor de contenedores"
            exit 1
            ;;
    esac
fi
