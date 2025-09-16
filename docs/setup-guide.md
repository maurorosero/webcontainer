# Guía de Configuración del Sistema Web Local

Esta guía te ayudará a configurar el sistema web local completo con certificados SSL válidos y gestión de aplicaciones externas.

## 📋 Requisitos Previos

### Software Requerido

- **Podman** o **Docker** (uno de los dos)
- **OpenSSL** (para certificados)
- **yq** (`pip install yq`)
- **jq** (para procesamiento JSON)
- **curl** (para verificaciones)

### Permisos Requeridos

- **Permisos de administrador** (sudo) para instalar la CA en el sistema
- **Acceso de escritura** a `/etc/hosts` para configuración DNS

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
# Inicializar todo el sistema (contenedores + certificados + DNS)
./scripts/web-manager.sh init
```

Este comando ejecutará automáticamente:

1. **Detección de contenedores**: Detecta Podman o Docker
2. **Creación de directorios**: Estructura completa del proyecto
3. **Generación de certificados**: CA local y certificado wildcard
4. **Instalación de CA**: Instala la CA en el sistema operativo
5. **Configuración DNS**: Configura DNS local para `*.local.dev`
6. **Configuración Caddy**: Configura Caddy con certificados válidos
7. **Inicio de servicios**: Inicia todos los servicios

### Paso 3: Verificar Instalación

```bash
# Verificar estado completo del sistema
./scripts/web-manager.sh status

# Verificar certificados SSL
./scripts/cert-manager.sh verify

# Verificar DNS local
nslookup local.dev
```

## 🔧 Configuración Manual (Opcional)

### Variables de Entorno

Copia el archivo de ejemplo y personaliza:

```bash
cp env.example .env
```

Edita `.env` con tus preferencias:

```bash
# Configuración de puertos
CADDY_HTTP_PORT=80
CADDY_HTTPS_PORT=443

# Configuración de dominios
BASE_DOMAIN=local.dev

# Configuración de certificados
CERT_CA_VALIDITY_DAYS=3650
CERT_WILDCARD_VALIDITY_DAYS=365
```

### Configuración de Red

El sistema crea automáticamente una red Docker/Podman:

- **Nombre**: `web-dev-network`
- **Subnet**: `172.20.0.0/16`
- **Gateway**: `172.20.0.1`

### Configuración de Certificados

Los certificados se generan automáticamente en:

- **CA**: `certs/ca/ca.crt`
- **Wildcard**: `certs/sites/*.local.dev/cert.pem`

## 🌐 Publicación de Aplicaciones

### Aplicación Node.js

```bash
# Aplicación en /home/user/myapp con package.json
./scripts/publish-app.sh publish /home/user/myapp myapp
```

### Aplicación React

```bash
# Aplicación React en /opt/react-app
./scripts/publish-app.sh publish /opt/react-app react-app react-app.local.dev
```

### Aplicación PHP

```bash
# Aplicación PHP en /var/www/myapp
./scripts/publish-app.sh publish /var/www/myapp myapp myapp.local.dev 80 "Mi App PHP"
```

### Aplicación Python

```bash
# Aplicación Python en /srv/myapp
./scripts/publish-app.sh publish /srv/myapp myapp myapp.local.dev 8000 "Mi App Python"
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
./scripts/web-manager.sh logs caddy
```

### Gestión de Certificados

```bash
# Verificar certificados
./scripts/cert-manager.sh verify

# Renovar certificados
./scripts/cert-manager.sh renew

# Reinstalar CA
./scripts/cert-manager.sh install-ca
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

## 🛠️ Solución de Problemas

### Problemas de Certificados

```bash
# Verificar CA instalada
./scripts/verify-ssl.sh verify-ca

# Reinstalar CA
./scripts/cert-manager.sh install-ca

# Verificar certificado específico
./scripts/verify-ssl.sh verify-browser myapp.local.dev
```

### Problemas de Contenedores

```bash
# Verificar motor de contenedores
./scripts/container-utils.sh detect

# Verificar estado de contenedores
./scripts/web-manager.sh health

# Limpiar recursos
./scripts/web-manager.sh cleanup
```

### Problemas de DNS

```bash
# Verificar DNS local
nslookup local.dev

# Reconfigurar DNS
./scripts/cert-manager.sh setup-dns
```

## 🔒 Seguridad

### Certificados SSL

- **CA Local**: Autoridad certificadora instalada en el sistema
- **Certificados Wildcard**: `*.local.dev` válidos para todos los subdominios
- **Sin Warnings**: El navegador aceptará los certificados sin mostrar warnings
- **Renovación Automática**: Los certificados se renuevan automáticamente

### Red Aislada

- **Red Interna**: Solo servicios internos pueden comunicarse
- **Sin Exposición**: Solo Caddy expone puertos al host
- **Aislamiento**: Aplicaciones ejecutándose en contenedores aislados

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

**¡Disfruta desarrollando con certificados SSL válidos y sin warnings en el navegador!** 🎉
