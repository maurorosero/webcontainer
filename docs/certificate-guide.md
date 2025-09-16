# Guía de Certificados SSL Válidos

Esta guía explica cómo funciona el sistema de certificados SSL válidos que no generan warnings en el navegador.

## 🔒 Conceptos Básicos

### ¿Qué es una CA Local?

Una **Autoridad Certificadora (CA) Local** es una entidad que emite certificados SSL para tu entorno de desarrollo local. A diferencia de los certificados autofirmados, los certificados emitidos por una CA local son **válidos** y no generan warnings en el navegador.

### ¿Por qué Certificados Válidos?

- ✅ **Sin warnings**: El navegador acepta los certificados sin mostrar warnings
- ✅ **Seguridad real**: Certificados firmados por una CA válida
- ✅ **Desarrollo profesional**: Entorno de desarrollo idéntico a producción
- ✅ **Automatización**: Generación y renovación automática

## 🏗️ Arquitectura del Sistema

```
CA Local → Certificado Wildcard → Caddy → Navegador (Sin Warnings)
```

### Componentes

1. **CA Local**: Autoridad certificadora instalada en el sistema
2. **Certificado Wildcard**: `*.local.dev` válido para todos los subdominios
3. **Instalación Automática**: CA se instala automáticamente en el sistema operativo
4. **Integración con Caddy**: Caddy usa certificados válidos automáticamente

## 📁 Estructura de Certificados

```
certs/
├── ca/                           # Autoridad certificadora
│   ├── ca.key                   # Clave privada de la CA (4096 bits)
│   ├── ca.crt                   # Certificado de la CA
│   ├── serial                   # Archivo de serialización
│   ├── index.txt                # Archivo de índice
│   └── openssl.cnf             # Configuración OpenSSL para CA
└── sites/                       # Certificados por sitio
    └── *.local.dev/             # Certificado wildcard válido
        ├── cert.pem             # Certificado
        ├── key.pem              # Clave privada
        ├── fullchain.pem        # Cadena completa
        ├── cert.p12             # Certificado PKCS#12
        └── openssl.cnf         # Configuración OpenSSL
```

## 🚀 Configuración Automática

### Inicialización del Sistema

```bash
# Inicializar sistema completo de certificados
./scripts/cert-manager.sh init
```

Este comando ejecuta automáticamente:

1. **Crear directorios**: Estructura de certificados
2. **Generar CA**: CA local con clave de 4096 bits
3. **Generar certificado wildcard**: `*.local.dev` válido por 1 año
4. **Instalar CA**: Instala la CA en el sistema operativo
5. **Configurar DNS**: Configura DNS local para `*.local.dev`
6. **Configurar Caddy**: Configura Caddy para usar certificados válidos

### Verificación Automática

```bash
# Verificar certificados
./scripts/cert-manager.sh verify

# Verificar CA instalada
./scripts/verify-ssl.sh verify-ca

# Verificar certificado específico
./scripts/verify-ssl.sh verify-browser myapp.local.dev
```

## 🔧 Configuración Manual

### Generar CA Manualmente

```bash
# Generar solo la CA
./scripts/cert-manager.sh generate-ca
```

### Generar Certificado Wildcard Manualmente

```bash
# Generar solo el certificado wildcard
./scripts/cert-manager.sh generate-wildcard
```

### Instalar CA Manualmente

```bash
# Instalar CA en el sistema
./scripts/cert-manager.sh install-ca
```

## 🌐 Soporte Multiplataforma

### Linux

#### Debian/Ubuntu
```bash
# Instalación automática
sudo cp certs/ca/ca.crt /usr/local/share/ca-certificates/local-dev-ca.crt
sudo update-ca-certificates
```

#### RedHat/CentOS/Fedora
```bash
# Instalación automática
sudo cp certs/ca/ca.crt /etc/pki/ca-trust/source/anchors/local-dev-ca.crt
sudo update-ca-trust
```

#### Arch Linux
```bash
# Instalación automática
sudo cp certs/ca/ca.crt /etc/ca-certificates/trust-source/anchors/local-dev-ca.crt
sudo trust extract-compat
```

### macOS

```bash
# Instalación automática
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain certs/ca/ca.crt
```

### Windows

**Instalación Manual**:
1. Abrir `certs/ca/ca.crt` en el navegador
2. Instalar en "Autoridades de certificación raíz de confianza"
3. Reiniciar el navegador

## 🔄 Renovación Automática

### Verificar Expiración

```bash
# Verificar certificados
./scripts/cert-manager.sh verify

# Renovar si es necesario
./scripts/cert-manager.sh renew
```

### Configuración de Renovación

Los certificados se renuevan automáticamente cuando:

- **Certificado wildcard**: Expira en menos de 30 días
- **CA**: Expira en menos de 1 año

### Renovación Manual

```bash
# Renovar certificados
./scripts/cert-manager.sh renew

# Regenerar certificado wildcard
./scripts/cert-manager.sh generate-wildcard
```

## 🔍 Verificación de Certificados

### Verificar CA

```bash
# Verificar CA instalada
./scripts/verify-ssl.sh verify-ca

# Verificar CA válida
openssl verify -CAfile certs/ca/ca.crt certs/ca/ca.crt
```

### Verificar Certificado Wildcard

```bash
# Verificar certificado wildcard
openssl x509 -in certs/sites/*.local.dev/cert.pem -noout -subject -issuer -dates

# Verificar cadena completa
openssl verify -CAfile certs/ca/ca.crt certs/sites/*.local.dev/cert.pem
```

### Verificar en Navegador

```bash
# Verificar certificado específico
./scripts/verify-ssl.sh verify-browser myapp.local.dev

# Verificar todos los certificados
./scripts/verify-ssl.sh verify-all
```

## 🛠️ Solución de Problemas

### Problema: "Certificado no válido" en navegador

**Causa**: CA no instalada en el sistema

**Solución**:
```bash
# Reinstalar CA
./scripts/cert-manager.sh install-ca

# Verificar instalación
./scripts/verify-ssl.sh verify-ca
```

### Problema: "CA no encontrada"

**Causa**: CA no generada o eliminada

**Solución**:
```bash
# Regenerar CA
./scripts/cert-manager.sh generate-ca

# Reinstalar CA
./scripts/cert-manager.sh install-ca
```

### Problema: "Certificado expirado"

**Causa**: Certificados no renovados

**Solución**:
```bash
# Renovar certificados
./scripts/cert-manager.sh renew

# Regenerar certificado wildcard
./scripts/cert-manager.sh generate-wildcard
```

### Problema: "DNS no resuelve"

**Causa**: DNS local no configurado

**Solución**:
```bash
# Configurar DNS local
./scripts/cert-manager.sh setup-dns

# Verificar DNS
nslookup local.dev
```

## 🔒 Seguridad

### Claves de Certificados

- **CA**: Clave de 4096 bits (máxima seguridad)
- **Wildcard**: Clave de 2048 bits (equilibrio seguridad/rendimiento)
- **Almacenamiento**: Claves almacenadas localmente en `certs/`

### Validez de Certificados

- **CA**: Válida por 10 años
- **Wildcard**: Válido por 1 año (renovación automática)
- **Alcance**: Solo para `*.local.dev` y `localhost`

### Aislamiento

- **CA Local**: Solo para desarrollo local
- **No Exposición**: CA no se expone a internet
- **Contenedores**: Certificados montados en contenedores

## 📊 Monitoreo

### Verificar Estado

```bash
# Estado de certificados
./scripts/cert-manager.sh verify

# Estado de CA
./scripts/verify-ssl.sh verify-ca

# Estado de aplicaciones
./scripts/verify-ssl.sh verify-all
```

### Generar Reportes

```bash
# Reporte de certificados
./scripts/verify-ssl.sh report

# Reporte de descubrimiento
./scripts/discover-apps.sh report
```

## 🔄 Backup y Restauración

### Backup de Certificados

```bash
# Backup completo del sistema
./scripts/web-manager.sh backup

# Backup solo de certificados
cp -r certs/ backups/certs-$(date +%Y%m%d_%H%M%S)/
```

### Restauración de Certificados

```bash
# Restaurar sistema completo
./scripts/web-manager.sh restore /path/to/backup

# Restaurar solo certificados
cp -r /path/to/backup/certs/ ./
./scripts/cert-manager.sh install-ca
```

## 📚 Referencias Técnicas

### OpenSSL

- **Configuración CA**: `certs/ca/openssl.cnf`
- **Configuración Wildcard**: `certs/sites/*.local.dev/openssl.cnf`
- **Comandos**: `openssl req`, `openssl x509`, `openssl verify`

### Caddy

- **Configuración**: `caddy/Caddyfile`
- **Certificados**: Montados en `/certs/`
- **Comandos**: `caddy reload`, `caddy validate`

### Sistema Operativo

- **Linux**: `/usr/local/share/ca-certificates/`, `/etc/pki/ca-trust/`
- **macOS**: Keychain del sistema
- **Windows**: Autoridades de certificación raíz

---

**Los certificados SSL válidos te permiten desarrollar con la misma seguridad que en producción, sin warnings en el navegador.**
