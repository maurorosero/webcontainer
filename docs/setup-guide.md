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

### Aplicación Node.js

```bash
# Aplicación en /home/user/myapp con package.json
./scripts/publish-app.sh publish /home/user/myapp myapp myapp.local 3000 "Mi App Node.js" "/health"
```

### Aplicación React

```bash
# Aplicación React en /opt/react-app
./scripts/publish-app.sh publish /opt/react-app react-app react-app.local 3000 "Mi App React" "/"
```

### Aplicación PHP

```bash
# Aplicación PHP en /var/www/myapp
./scripts/publish-app.sh publish /var/www/myapp myapp myapp.local 80 "Mi App PHP" "/health.php"
```

### Aplicación Python

```bash
# Aplicación Python en /srv/myapp
./scripts/publish-app.sh publish /srv/myapp myapp myapp.local 8000 "Mi App Python" "/health"
```

## 🔍 Descubrimiento de Aplicaciones

### Escanear Sistema Completo

```bash
# Descubrir todas las aplicaciones en el sistema
./scripts/discover-apps.sh discover
```

### Escanear Directorio Específico

```bash
# Escanear directorio específico con profundidad máxima
./scripts/discover-apps.sh scan /home/user 2
```

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

### Gestión de Aplicaciones

```bash
# Listar aplicaciones publicadas
./scripts/publish-app.sh list

# Verificar estado de aplicaciones
./scripts/publish-app.sh check

# Despublicar aplicación
./scripts/publish-app.sh unpublish myapp
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

1. **Publicar tu primera aplicación**: Usa `./scripts/publish-app.sh publish`
2. **Configurar monitoreo**: Usa `./scripts/monitor-apps.sh`
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
