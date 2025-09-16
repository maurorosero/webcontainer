# Guía de Configuración del Sistema Web Local

Esta guía te ayudará a configurar el sistema web local completo con Traefik, dominios .local automáticos y gestión de aplicaciones externas.

## 📋 Requisitos Previos

### Software Requerido

- **Podman** o **Docker** (uno de los dos)
- **systemd-resolved** (para DNS local)
- **yq** (`pip install yq`)
- **jq** (para procesamiento JSON)
- **curl** (para verificaciones)

### Permisos Requeridos

- **Permisos de administrador** (sudo) para configurar systemd-resolved
- **Acceso de escritura** a `/etc/systemd/resolved.conf.d/` para configuración DNS

## 🚀 Instalación Paso a Paso

### Paso 1: Verificar Dependencias

```bash
# Verificar que tienes Podman o Docker
./scripts/container-utils.sh detect

# Verificar dependencias adicionales
./scripts/container-utils.sh check
```

### Paso 2: Inicializar Sistema Completo

```bash
# Inicializar todo el sistema (contenedores + DNS + host)
./scripts/web-manager.sh init
```

Este comando ejecutará automáticamente:

1. **Detección de contenedores**: Detecta Podman o Docker
2. **Creación de directorios**: Estructura completa del proyecto
3. **Configuración del host**: Configura systemd-resolved para DNS local
4. **Configuración DNS**: Configura dnsmasq en contenedor para `*.local`
5. **Configuración Traefik**: Configura Traefik con SSL automático
6. **Inicio de servicios**: Inicia todos los servicios
7. **Descarga de imágenes**: Descarga imágenes necesarias automáticamente

### Paso 3: Verificar Instalación

```bash
# Verificar estado completo del sistema
./scripts/web-manager.sh status

# Verificar DNS local
nslookup whoami.local

# Verificar configuración de systemd-resolved
resolvectl status
```

## 🔧 Configuración Manual (Opcional)

### Variables de Entorno

Copia el archivo de ejemplo y personaliza:

```bash
cp config.env.example .env
```

Edita `.env` con tus preferencias:

```bash
# Configuración de puertos (se ajustan automáticamente para rootless)
TRAEFIK_HTTP_PORT=80
TRAEFIK_HTTPS_PORT=443
TRAEFIK_DASHBOARD_PORT=8080

# Configuración de dominios
BASE_DOMAIN=local
WILDCARD_DOMAIN=*.local

# Configuración de DNS
DNS_AUTO_SETUP=true
DNS_BASE_DOMAIN=local
DNS_WILDCARD_ENABLED=true
```

### Configuración de Red

El sistema crea automáticamente una red Docker/Podman:

- **Nombre**: `web-dev-network`
- **Subnet**: `172.25.0.0/16`
- **Gateway**: `172.25.0.1`

### Configuración de DNS Local

El sistema configura automáticamente:

- **dnsmasq**: En contenedor, resuelve `*.local` a `127.0.0.1`
- **systemd-resolved**: Configurado para usar dnsmasq como DNS principal
- **Fallback DNS**: DNS del sistema como respaldo automático

## 🌐 Publicación de Aplicaciones

**Nota**: La funcionalidad de publicación de aplicaciones externas está en desarrollo. Por ahora, puedes usar el servicio de ejemplo `whoami` que viene incluido.

### Servicio de Ejemplo

El sistema incluye un servicio de ejemplo `whoami` que puedes usar para probar:

```bash
# Acceder al servicio de ejemplo
curl https://whoami.local:8443
```

### Configuración Manual de Aplicaciones

Para agregar aplicaciones personalizadas, puedes:

1. **Crear un contenedor personalizado** y agregarlo al `docker-compose.yml`
2. **Configurar las etiquetas de Traefik** para el enrutamiento
3. **Reiniciar los servicios** con `./scripts/web-manager.sh restart`

Ejemplo de configuración en `docker-compose.yml`:

```yaml
services:
  my-app:
    image: my-app:latest
    networks:
      - web-dev-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.my-app.rule=Host(`my-app.local`)"
      - "traefik.http.routers.my-app.entrypoints=web,websecure"
      - "traefik.http.routers.my-app.tls=true"
      - "traefik.http.services.my-app.loadbalancer.server.port=3000"
```

## 🔍 Gestión de Aplicaciones

### Verificar Aplicaciones Activas

```bash
# Verificar estado de contenedores
./scripts/container-utils.sh ps

# Ver logs de aplicaciones específicas
./scripts/container-utils.sh logs web-whoami
```

### Agregar Nuevas Aplicaciones

Para agregar nuevas aplicaciones al sistema:

1. **Editar `docker-compose.yml`** para agregar el nuevo servicio
2. **Configurar etiquetas de Traefik** para el enrutamiento
3. **Reiniciar servicios** con `./scripts/web-manager.sh restart`

## 📊 Monitoreo y Gestión

### Estado del Sistema

```bash
# Ver estado completo
./scripts/web-manager.sh status

# Verificar salud de servicios
./scripts/web-manager.sh health

# Ver logs
./scripts/web-manager.sh logs traefik
```

### Gestión de Contenedores

```bash
# Listar contenedores
./scripts/container-utils.sh ps

# Ver logs de contenedor específico
./scripts/container-utils.sh logs web-traefik

# Reiniciar contenedor
./scripts/container-utils.sh restart web-traefik
```

### Gestión de Servicios

```bash
# Listar contenedores activos
./scripts/container-utils.sh ps

# Ver logs de contenedor específico
./scripts/container-utils.sh logs web-traefik

# Reiniciar contenedor específico
./scripts/container-utils.sh restart web-traefik
```

## 💾 Backup y Restauración

### Crear Backup

```bash
# Crear backup completo del sistema
./scripts/web-manager.sh backup
```

### Restaurar Sistema

```bash
# Restaurar desde backup
./scripts/web-manager.sh restore /path/to/backup
```

### Limpiar Sistema Completo

```bash
# Limpiar todo (incluye restauración del host)
./scripts/web-manager.sh clean
```

## 🛠️ Solución de Problemas

### Problemas de DNS

```bash
# Verificar DNS local
nslookup whoami.local

# Reconfigurar DNS automáticamente
./scripts/setup-host.sh

# Verificar estado de dnsmasq
./scripts/container-utils.sh logs web-dnsmasq
```

### Problemas de Contenedores

```bash
# Verificar motor de contenedores
./scripts/container-utils.sh detect

# Verificar estado de contenedores
./scripts/web-manager.sh health

# Limpiar recursos
./scripts/web-manager.sh clean
```

### Problemas de Traefik

```bash
# Verificar logs de Traefik
./scripts/container-utils.sh logs web-traefik

# Reiniciar Traefik
./scripts/container-utils.sh restart web-traefik

# Verificar configuración
cat config/traefik.yml
```

## 🔒 Seguridad

### Certificados SSL

- **Traefik Automático**: Traefik gestiona automáticamente los certificados SSL
- **Sin Warnings**: El navegador aceptará los certificados sin mostrar warnings
- **Renovación Automática**: Los certificados se renuevan automáticamente

### Red Aislada

- **Red Interna**: Solo servicios internos pueden comunicarse
- **Sin Exposición**: Solo Traefik expone puertos al host
- **Aislamiento**: Aplicaciones ejecutándose en contenedores aislados

### DNS Local

- **Dominios .local**: Resolución automática sin modificar /etc/hosts
- **Fallback DNS**: DNS público como respaldo automático
- **Configuración Automática**: Host configurado automáticamente

## 📚 Próximos Pasos

1. **Probar el servicio de ejemplo**: Accede a `https://whoami.local:8443`
2. **Agregar tu primera aplicación**: Edita `docker-compose.yml` y reinicia servicios
3. **Personalizar configuración**: Edita archivos en `config/`
4. **Explorar documentación**: Revisa otros archivos en `docs/`

## 🆘 Soporte

Si encuentras problemas:

1. **Revisa los logs**: `./scripts/web-manager.sh logs`
2. **Verifica el estado**: `./scripts/web-manager.sh status`
3. **Consulta la documentación**: Revisa `docs/troubleshooting.md`
4. **Verifica dependencias**: `./scripts/container-utils.sh check`

---

**¡Disfruta desarrollando con dominios .local automáticos y certificados SSL sin warnings!** 🎉
