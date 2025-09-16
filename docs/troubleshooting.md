# Solución de Problemas

Esta guía te ayudará a resolver problemas comunes del sistema web local con Traefik.

## 🔍 Diagnóstico General

### Verificar Estado del Sistema

```bash
# Verificar estado completo del sistema
./scripts/web-manager.sh status

# Verificar salud de servicios
./scripts/web-manager.sh health

# Verificar sistema completo
./scripts/web-manager.sh verify
```

### Verificar Logs

```bash
# Ver logs de todos los servicios
./scripts/web-manager.sh logs

# Ver logs de Traefik específicamente
./scripts/web-manager.sh logs traefik

# Ver logs de dnsmasq específicamente
./scripts/web-manager.sh logs dnsmasq

# Ver logs de aplicación específica
./scripts/web-manager.sh logs app-registry
```

## 🌐 Problemas de DNS Local

### Error: "Dominio no resuelve"

**Síntomas**: No se puede acceder a `*.local`

**Solución**:
```bash
# Verificar DNS local
nslookup whoami.local

# Verificar configuración de systemd-resolved
resolvectl status

# Reconfigurar DNS automáticamente
./scripts/setup-host.sh

# Verificar que dnsmasq esté ejecutándose
./scripts/container-utils.sh ps | grep dnsmasq
```

### Error: "DNS no configurado"

**Síntomas**: Dominios `.local` no resuelven correctamente

**Solución**:
```bash
# Verificar configuración de systemd-resolved
cat /etc/systemd/resolved.conf.d/90-local-dev.conf

# Reconfigurar DNS automáticamente
./scripts/setup-host.sh

# Reiniciar systemd-resolved
sudo systemctl restart systemd-resolved

# Probar resolución
nslookup whoami.local
```

### Error: "dnsmasq no responde"

**Síntomas**: dnsmasq no está funcionando

**Solución**:
```bash
# Verificar estado de dnsmasq
./scripts/container-utils.sh ps | grep dnsmasq

# Reiniciar dnsmasq
./scripts/container-utils.sh restart web-dnsmasq

# Ver logs de dnsmasq
./scripts/container-utils.sh logs web-dnsmasq
```

## 🐳 Problemas de Contenedores

### Error: "No se encontró motor de contenedores"

**Síntomas**: Error al detectar Podman o Docker

**Solución**:
```bash
# Verificar motor de contenedores
./scripts/container-utils.sh detect

# Verificar que Docker/Podman esté ejecutándose
./scripts/container-utils.sh info

# Reiniciar servicio si es necesario
sudo systemctl start docker  # o podman
```

### Error: "Contenedor no está ejecutándose"

**Síntomas**: Aplicación no accesible

**Solución**:
```bash
# Verificar estado de contenedores
./scripts/web-manager.sh health

# Reiniciar servicios
./scripts/web-manager.sh restart

# Ver logs de contenedor específico
./scripts/container-utils.sh logs web-myapp
```

### Error: "Red no encontrada"

**Síntomas**: Contenedores no pueden comunicarse

**Solución**:
```bash
# Verificar redes existentes
./scripts/container-utils.sh network ls

# Crear red manualmente si es necesario
./scripts/container-utils.sh network create web-dev-network 172.25.0.0/16

# Reiniciar servicios
./scripts/web-manager.sh restart
```

### Error: "Puerto ya en uso"

**Síntomas**: Puerto ya está siendo usado por otro proceso

**Solución**:
```bash
# Verificar puertos en uso
netstat -tlnp | grep :8080
netstat -tlnp | grep :8443
netstat -tlnp | grep :8081

# Detener servicios conflictivos
./scripts/web-manager.sh down

# Reiniciar servicios
./scripts/web-manager.sh up
```

## 🔒 Problemas de SSL/TLS

### Error: "Certificado no válido" en el navegador

**Síntomas**: El navegador muestra warnings de certificado no válido

**Solución**:
```bash
# Verificar configuración de Traefik
./scripts/container-utils.sh logs web-traefik

# Reiniciar Traefik
./scripts/container-utils.sh restart web-traefik

# Verificar que Traefik esté generando certificados automáticamente
curl -k https://whoami.local:8443
```

### Error: "Traefik no genera certificados"

**Síntomas**: Traefik no está generando certificados SSL automáticamente

**Solución**:
```bash
# Verificar configuración de Traefik
cat config/traefik.yml

# Verificar logs de Traefik
./scripts/container-utils.sh logs web-traefik

# Reiniciar Traefik
./scripts/container-utils.sh restart web-traefik
```

## 📱 Problemas de Aplicaciones

### Error: "Aplicación no publicada"

**Síntomas**: Aplicación no accesible a través de Traefik

**Solución**:
```bash
# Verificar aplicaciones publicadas
./scripts/publish-app.sh list

# Verificar estado de aplicaciones
./scripts/publish-app.sh check

# Republicar aplicación
./scripts/publish-app.sh publish /path/to/app app-name app-name.local 3000 "Mi Aplicación" "/health"
```

### Error: "Tipo de aplicación no detectado"

**Síntomas**: Error al detectar tipo de aplicación

**Solución**:
```bash
# Verificar archivos indicadores
ls -la /path/to/app/

# Publicar con parámetros específicos
./scripts/publish-app.sh publish /path/to/app app-name domain port "description" "/health"
```

### Error: "Puerto no disponible"

**Síntomas**: Puerto ya en uso

**Solución**:
```bash
# Verificar puertos en uso
netstat -tlnp | grep :3000

# Usar puerto diferente
./scripts/publish-app.sh publish /path/to/app app-name domain 3001
```

## 🔧 Problemas de Traefik

### Error: "Traefik no responde"

**Síntomas**: Traefik no está funcionando

**Solución**:
```bash
# Verificar estado de Traefik
./scripts/container-utils.sh ps | grep traefik

# Reiniciar Traefik
./scripts/container-utils.sh restart web-traefik

# Ver logs de Traefik
./scripts/container-utils.sh logs web-traefik
```

### Error: "Configuración de Traefik inválida"

**Síntomas**: Error al cargar configuración

**Solución**:
```bash
# Verificar configuración
cat config/traefik.yml

# Verificar configuración dinámica
cat config/dynamic.yml

# Reiniciar Traefik
./scripts/web-manager.sh restart
```

### Error: "Dashboard de Traefik no accesible"

**Síntomas**: No se puede acceder al dashboard de Traefik

**Solución**:
```bash
# Verificar que Traefik esté ejecutándose
./scripts/container-utils.sh ps | grep traefik

# Verificar puerto del dashboard
netstat -tlnp | grep :8081

# Acceder al dashboard
curl http://localhost:8081
```

## 🗂️ Problemas de Archivos y Permisos

### Error: "Permisos denegados"

**Síntomas**: No se puede escribir en directorios

**Solución**:
```bash
# Verificar permisos
ls -la scripts/
ls -la config/
ls -la logs/

# Corregir permisos
chmod +x scripts/*.sh
chmod 755 config/
chmod 755 logs/
```

### Error: "Archivo no encontrado"

**Síntomas**: Archivos de configuración faltantes

**Solución**:
```bash
# Verificar estructura de directorios
ls -la
ls -la config/
ls -la logs/

# Recrear archivos faltantes
./scripts/web-manager.sh init
```

## 🔄 Problemas de Rendimiento

### Error: "Servicios lentos"

**Síntomas**: Respuesta lenta del sistema

**Solución**:
```bash
# Verificar uso de recursos
./scripts/container-utils.sh stats

# Limpiar recursos
./scripts/web-manager.sh clean

# Reiniciar servicios
./scripts/web-manager.sh restart
```

### Error: "Memoria insuficiente"

**Síntomas**: Contenedores se detienen por falta de memoria

**Solución**:
```bash
# Verificar memoria disponible
free -h

# Limpiar contenedores no utilizados
./scripts/container-utils.sh system prune

# Reiniciar servicios
./scripts/web-manager.sh restart
```

## 🆘 Recuperación de Emergencia

### Sistema Completamente Roto

```bash
# Detener todo
./scripts/web-manager.sh down

# Limpiar recursos
./scripts/web-manager.sh clean

# Reinicializar sistema completo
./scripts/web-manager.sh init
```

### Restaurar desde Backup

```bash
# Listar backups disponibles
ls -la backups/

# Restaurar desde backup específico
./scripts/web-manager.sh restore backups/20240115_103000
```

### Restaurar configuración del host

```bash
# Restaurar DNS del host a configuración original
./scripts/restore-host.sh

# Reinicializar sistema
./scripts/web-manager.sh init
```

## 📞 Obtener Ayuda

### Información del Sistema

```bash
# Información completa del sistema
./scripts/web-manager.sh status
./scripts/container-utils.sh info
```

### Logs Detallados

```bash
# Logs del sistema
./scripts/web-manager.sh logs

# Logs de Traefik
tail -f logs/traefik/traefik.log

# Logs de aplicaciones
tail -f logs/applications/*.log
```

### Reportes

```bash
# Generar reporte de descubrimiento
./scripts/discover-apps.sh report
```

---

**Si sigues teniendo problemas, revisa los logs y verifica que todas las dependencias estén instaladas correctamente.**