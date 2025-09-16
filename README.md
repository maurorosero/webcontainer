# Sistema Web Local Completo con Traefik

Sistema completo para desarrollo web local con Traefik como proxy reverso, **dominios .local automáticos** (sin modificar /etc/hosts), gestión automática de aplicaciones externas y soporte para Podman/Docker.

## 🚀 Características Principales

- ✅ **Traefik**: Proxy reverso con SSL automático
- ✅ **Dominios .local**: Resolución automática sin modificar /etc/hosts
- ✅ **Podman/Docker**: Compatible con ambos sistemas (rootless/root)
- ✅ **Puertos No Privilegiados**: Funciona en modo rootless (8080, 8443, 8081)
- ✅ **DNS Local**: dnsmasq en contenedor con fallback automático
- ✅ **Configuración Automática**: Host configurado automáticamente
- ✅ **Restauración Completa**: Host restaurado a estado original
- ✅ **Aplicaciones Externas**: Publicación desde cualquier ubicación del sistema
- ✅ **Detección Automática**: Detecta automáticamente tipos de aplicación
- ✅ **Monitoreo**: Sistema de monitoreo y health checks

## 🏗️ Arquitectura del Sistema

```
Aplicaciones Externas → Detección → Contenedores → Traefik → Cliente
         (cualquier ubicación)        (automático)    (proxy SSL + DNS local)
```

## 📋 Requisitos

- **Podman** o **Docker**
- **systemd-resolved** (para DNS local)
- **yq** (para procesamiento YAML)
- **jq** (para procesamiento JSON)
- **curl** (para health checks)
- **git** (para control de versiones)

## 🚀 Inicio Rápido

### 1. Inicializar Sistema Completo

```bash
# Inicializar sistema completo (contenedores + DNS + host)
./scripts/web-manager.sh init
```

Este comando:
- Detecta automáticamente Podman o Docker
- Configura el host para DNS local automáticamente
- Inicia dnsmasq en contenedor
- Configura Traefik como proxy reverso
- Inicia todos los servicios

### 2. Verificar Sistema

```bash
# Verificar estado completo del sistema
./scripts/web-manager.sh status

# Verificar resolución DNS
nslookup whoami.local
```

### 3. Acceder a las Aplicaciones

- **Aplicaciones**: `https://*.local:8443`
- **Dashboard Traefik**: `http://localhost:8081`
- **HTTP directo**: `http://localhost:8080`

## 📁 Estructura del Proyecto

```
web/                                 # Plataforma web completa
├── scripts/                          # Scripts de gestión
│   ├── web-manager.sh               # Gestión principal del sistema
│   ├── setup-host.sh                # Configuración automática del host
│   ├── restore-host.sh              # Restauración del host
│   ├── container-utils.sh           # Utilidades de contenedores
│   └── discover-apps.sh             # Descubrir aplicaciones
├── config/                          # Configuraciones
│   ├── traefik.yml                  # Configuración de Traefik
│   ├── dynamic.yml                  # Configuración dinámica
│   ├── dnsmasq.conf                 # Configuración DNS local
│   └── app-registry.yml             # Registro de aplicaciones
├── logs/                            # Logs centralizados
├── data/                            # Datos persistentes
└── docs/                            # Documentación
```

## 🔧 Comandos Principales

### Gestión del Sistema

```bash
# Inicializar sistema completo
./scripts/web-manager.sh init

# Iniciar servicios
./scripts/web-manager.sh start

# Detener servicios
./scripts/web-manager.sh stop

# Reiniciar servicios
./scripts/web-manager.sh restart

# Verificar estado
./scripts/web-manager.sh status

# Ver logs
./scripts/web-manager.sh logs

# Limpiar sistema completo (restaura host)
./scripts/web-manager.sh clean

# Comandos de conveniencia
./scripts/web-manager.sh up          # Alias de start
./scripts/web-manager.sh down        # Alias de stop
```

### Gestión de Aplicaciones

```bash
# Descubrir aplicaciones en el sistema
./scripts/discover-apps.sh discover

# Escanear directorio específico
./scripts/discover-apps.sh scan /home/user 2
```

## 🌐 Tipos de Aplicaciones Soportadas

- **Node.js**: Detecta `package.json`
- **PHP**: Detecta `composer.json` o archivos PHP
- **Python**: Detecta `requirements.txt` o archivos Python
- **Rust**: Detecta `Cargo.toml`
- **Go**: Detecta `go.mod`
- **Docker**: Detecta `docker-compose.yml` o `Dockerfile`
- **Estático**: Detecta `index.html` o archivos estáticos

## 🔒 SSL y Seguridad

- **SSL Automático**: Traefik maneja SSL automáticamente
- **Dominios .local**: Resolución automática sin modificar /etc/hosts
- **Puertos No Privilegiados**: Funciona en modo rootless
- **Configuración Automática**: Host configurado automáticamente

## 🔄 Configuración del Host

El sistema configura automáticamente el host para DNS local:

**Al inicializar:**
- Configura systemd-resolved para usar dnsmasq
- Usa DNS del sistema como fallback automático
- Dominios .local se resuelven automáticamente

**Al limpiar:**
- Restaura systemd-resolved a configuración original
- Host vuelve a estado natural
- Sin rastros de configuración personalizada

## 📊 Monitoreo y Logs

```bash
# Verificar estado de servicios
./scripts/web-manager.sh status

# Ver logs de servicios
./scripts/web-manager.sh logs

# Verificar salud de contenedores
podman ps
```

## 🛠️ Solución de Problemas

### DNS Local

```bash
# Verificar resolución DNS
nslookup whoami.local

# Verificar configuración de systemd-resolved
resolvectl status

# Reconfigurar DNS local
./scripts/setup-host.sh
```

### Contenedores

```bash
# Verificar motor de contenedores
./scripts/container-utils.sh detect

# Verificar estado de contenedores (Podman/Docker automático)
./scripts/container-utils.sh ps

# Ver logs de contenedores (Podman/Docker automático)
./scripts/container-utils.sh logs web-traefik

# Reiniciar contenedor (Podman/Docker automático)
./scripts/container-utils.sh restart web-traefik

# Iniciar/Detener contenedor (Podman/Docker automático)
./scripts/container-utils.sh start web-traefik
./scripts/container-utils.sh stop web-traefik
```

### Traefik

```bash
# Verificar configuración de Traefik
curl http://localhost:8081/api/http/routers

# Verificar servicios
curl http://localhost:8081/api/http/services
```

## 🔄 Proceso Completo

### Inicialización

```bash
# 1. Limpiar sistema (si es necesario)
./scripts/web-manager.sh clean

# 2. Inicializar sistema completo
./scripts/web-manager.sh init

# 3. Verificar estado
./scripts/web-manager.sh status

# 4. Probar aplicación de ejemplo
curl -k https://whoami.local:8443
```

### Limpieza

```bash
# Limpiar sistema completo (restaura host)
./scripts/web-manager.sh clean
```

## 📚 Documentación Adicional

- [Guía de Configuración](docs/setup-guide.md)
- [Solución de Problemas](docs/troubleshooting.md)
- [Ejemplos](docs/examples/)

## 🤝 Contribuir

Para contribuir al proyecto:

1. Fork el repositorio
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

## 🆘 Soporte

Para soporte y preguntas:

- Consulta la documentación en `docs/`
- Revisa los logs en `logs/`
- Verifica el estado del sistema con `./scripts/web-manager.sh status`

---

**¡Disfruta desarrollando con dominios .local automáticos y sin modificar /etc/hosts!** 🎉