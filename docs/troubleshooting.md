# Solución de Problemas

Esta guía te ayudará a resolver problemas comunes del sistema web local.

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

# Ver logs de Caddy específicamente
./scripts/web-manager.sh logs caddy

# Ver logs de aplicación específica
./scripts/web-manager.sh logs app-registry
```

## 🔒 Problemas de Certificados SSL

### Error: "Certificado no válido" en el navegador

**Síntomas**: El navegador muestra warnings de certificado no válido

**Solución**:
```bash
# Verificar CA instalada
./scripts/verify-ssl.sh verify-ca

# Reinstalar CA si es necesario
./scripts/cert-manager.sh install-ca

# Verificar certificado específico
./scripts/verify-ssl.sh verify-browser myapp.local.dev
```

### Error: "CA no encontrada"

**Síntomas**: Error al verificar certificados

**Solución**:
```bash
# Regenerar CA
./scripts/cert-manager.sh generate-ca

# Regenerar certificado wildcard
./scripts/cert-manager.sh generate-wildcard

# Reinstalar CA
./scripts/cert-manager.sh install-ca
```

### Error: "Certificado expirado"

**Síntomas**: Certificados expirados

**Solución**:
```bash
# Renovar certificados
./scripts/cert-manager.sh renew

# Regenerar certificado wildcard
./scripts/cert-manager.sh generate-wildcard
```

## 🐳 Problemas de Contenedores

### Error: "No se encontró motor de contenedores"

**Síntomas**: Error al detectar Podman o Docker

**Solución**:
```bash
# Verificar motor de contenedores
./scripts/container-utils.sh detect

# Verificar que Docker/Podman esté ejecutándose
docker info  # o podman info

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
./scripts/container-utils.sh logs web-myapp  # Usa el wrapper automático
```

### Error: "Red no encontrada"

**Síntomas**: Contenedores no pueden comunicarse

**Solución**:
```bash
# Crear red manualmente
docker network create --subnet 172.20.0.0/16 web-dev-network

# O con Podman
podman network create --subnet 172.20.0.0/16 web-dev-network

# Reiniciar servicios
./scripts/web-manager.sh restart
```

## 🌐 Problemas de DNS

### Error: "Dominio no resuelve"

**Síntomas**: No se puede acceder a `*.local.dev`

**Solución**:
```bash
# Verificar DNS local
nslookup local.dev

# Reconfigurar DNS
./scripts/cert-manager.sh setup-dns

# Verificar /etc/hosts
cat /etc/hosts | grep local.dev
```

### Error: "DNS no configurado"

**Síntomas**: Dominios no resuelven correctamente

**Solución**:
```bash
# Configurar DNS manualmente
echo "127.0.0.1 local.dev" | sudo tee -a /etc/hosts
echo "127.0.0.1 *.local.dev" | sudo tee -a /etc/hosts

# O usar el script
./scripts/cert-manager.sh setup-dns
```

## 📱 Problemas de Aplicaciones

### Error: "Aplicación no publicada"

**Síntomas**: Aplicación no accesible a través de Caddy

**Solución**:
```bash
# Verificar aplicaciones publicadas
./scripts/publish-app.sh list

# Verificar estado de aplicaciones
./scripts/publish-app.sh check

# Republicar aplicación
./scripts/publish-app.sh publish /path/to/app app-name
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

## 🔧 Problemas de Caddy

### Error: "Caddy no responde"

**Síntomas**: Caddy no está funcionando

**Solución**:
```bash
# Verificar estado de Caddy
docker ps | grep caddy  # o podman ps | grep caddy

# Reiniciar Caddy
docker restart web-caddy  # o podman restart web-caddy

# Ver logs de Caddy
./scripts/container-utils.sh logs web-caddy  # Usa el wrapper automático
```

### Error: "Configuración de Caddy inválida"

**Síntomas**: Error al cargar configuración

**Solución**:
```bash
# Verificar configuración
docker exec web-caddy caddy validate --config /etc/caddy/Caddyfile

# Recargar configuración
docker exec web-caddy caddy reload --config /etc/caddy/Caddyfile

# Reiniciar Caddy
./scripts/web-manager.sh restart
```

## 🗂️ Problemas de Archivos y Permisos

### Error: "Permisos denegados"

**Síntomas**: No se puede escribir en directorios

**Solución**:
```bash
# Verificar permisos
ls -la scripts/
ls -la certs/
ls -la config/

# Corregir permisos
chmod +x scripts/*.sh
chmod 755 certs/
chmod 755 config/
```

### Error: "Archivo no encontrado"

**Síntomas**: Archivos de configuración faltantes

**Solución**:
```bash
# Verificar estructura de directorios
ls -la
ls -la config/
ls -la certs/

# Recrear archivos faltantes
./scripts/web-manager.sh init
```

## 🔄 Problemas de Rendimiento

### Error: "Servicios lentos"

**Síntomas**: Respuesta lenta del sistema

**Solución**:
```bash
# Verificar uso de recursos
docker stats  # o podman stats

# Limpiar recursos
./scripts/web-manager.sh cleanup

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
docker system prune -f  # o podman system prune -f

# Reiniciar servicios
./scripts/web-manager.sh restart
```

## 🆘 Recuperación de Emergencia

### Sistema Completamente Roto

```bash
# Detener todo
./scripts/web-manager.sh stop

# Limpiar recursos
./scripts/web-manager.sh cleanup

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

### Reinstalar CA

```bash
# Regenerar CA
./scripts/cert-manager.sh generate-ca

# Reinstalar CA
./scripts/cert-manager.sh install-ca

# Regenerar certificados
./scripts/cert-manager.sh generate-wildcard
```

## 📞 Obtener Ayuda

### Información del Sistema

```bash
# Información completa del sistema
./scripts/web-manager.sh status
./scripts/container-utils.sh info
./scripts/cert-manager.sh verify
```

### Logs Detallados

```bash
# Logs del sistema
./scripts/web-manager.sh logs

# Logs de certificados
tail -f logs/certificates/*.log

# Logs de aplicaciones
tail -f logs/applications/*.log
```

### Reportes

```bash
# Generar reporte de certificados
./scripts/verify-ssl.sh report

# Generar reporte de descubrimiento
./scripts/discover-apps.sh report
```

---

**Si sigues teniendo problemas, revisa los logs y verifica que todas las dependencias estén instaladas correctamente.**
