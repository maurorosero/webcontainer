# Ejemplo: Agregar Nueva Aplicación

Este ejemplo te muestra cómo agregar una nueva aplicación al sistema WebDevs con Traefik.

## 🚀 Método: Editar docker-compose.yml

La forma más directa de agregar aplicaciones es editando el archivo `docker-compose.yml` y reiniciando los servicios.

### Ejemplo 1: Aplicación Node.js

#### Crear Aplicación de Prueba

```bash
# Crear directorio de aplicación
mkdir -p /tmp/my-nodejs-app
cd /tmp/my-nodejs-app

# Crear package.json
cat > package.json << EOF
{
  "name": "my-nodejs-app",
  "version": "1.0.0",
  "description": "Aplicación Node.js de ejemplo",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

# Crear archivo principal
cat > index.js << EOF
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
    res.json({
        name: 'my-nodejs-app',
        description: 'Aplicación Node.js de ejemplo',
        status: 'running',
        timestamp: new Date().toISOString()
    });
});

app.get('/health', (req, res) => {
    res.json({ status: 'healthy' });
});

app.listen(port, '0.0.0.0', () => {
    console.log(\`Aplicación ejecutándose en puerto \${port}\`);
});
EOF
```

### Agregar Node.js al docker-compose.yml

Agrega este servicio al archivo `docker-compose.yml`:

```yaml
services:
  # ... servicios existentes ...
  
  my-nodejs-app:
    image: node:18-alpine
    container_name: web-my-nodejs-app
    hostname: my-nodejs-app
    working_dir: /app
    volumes:
      - /tmp/my-nodejs-app:/app
    command: sh -c "npm install && npm start"
    networks:
      - web-dev-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.my-nodejs-app.rule=Host(`my-nodejs-app.local`)"
      - "traefik.http.routers.my-nodejs-app.entrypoints=web,websecure"
      - "traefik.http.routers.my-nodejs-app.tls=true"
      - "traefik.http.services.my-nodejs-app.loadbalancer.server.port=3000"
```

### Reiniciar Servicios para Node.js

```bash
# Reiniciar servicios para aplicar cambios
./scripts/web-manager.sh restart
```

### Acceder a la Aplicación Node.js

- **URL**: [https://my-nodejs-app.local:8443](https://my-nodejs-app.local:8443)
- **Health Check**: [https://my-nodejs-app.local:8443/health](https://my-nodejs-app.local:8443/health)

## 🚀 Ejemplo 2: Aplicación PHP

### Crear Aplicación PHP

```bash
# Crear directorio de aplicación
mkdir -p /tmp/my-php-app
cd /tmp/my-php-app

# Crear archivo principal
cat > index.php << EOF
<?php
header('Content-Type: application/json');

\$data = [
    'name' => 'my-php-app',
    'description' => 'Aplicación PHP de ejemplo',
    'status' => 'running',
    'timestamp' => date('c'),
    'php_version' => phpversion()
];

echo json_encode(\$data, JSON_PRETTY_PRINT);
?>
EOF

# Crear archivo de salud
cat > health.php << EOF
<?php
header('Content-Type: application/json');
echo json_encode(['status' => 'healthy']);
?>
EOF
```

### Agregar PHP al docker-compose.yml

```yaml
services:
  # ... servicios existentes ...
  
  my-php-app:
    image: php:8.2-apache
    container_name: web-my-php-app
    hostname: my-php-app
    volumes:
      - /tmp/my-php-app:/var/www/html
    networks:
      - web-dev-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.my-php-app.rule=Host(`my-php-app.local`)"
      - "traefik.http.routers.my-php-app.entrypoints=web,websecure"
      - "traefik.http.routers.my-php-app.tls=true"
      - "traefik.http.services.my-php-app.loadbalancer.server.port=80"
```

### Reiniciar Servicios para PHP

```bash
./scripts/web-manager.sh restart
```

### Acceder a la Aplicación PHP

- **URL**: [https://my-php-app.local:8443](https://my-php-app.local:8443)
- **Health Check**: [https://my-php-app.local:8443/health.php](https://my-php-app.local:8443/health.php)

## 🚀 Ejemplo 3: Sitio Web Estático

### Crear Sitio Estático

```bash
# Crear directorio de aplicación
mkdir -p /tmp/my-static-site
cd /tmp/my-static-site

# Crear archivo principal
cat > index.html << EOF
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mi Sitio Estático</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
        }
        .info {
            background-color: #e8f4f8;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Mi Sitio Estático</h1>
        <div class="info">
            <h3>Información del Sitio</h3>
            <p><strong>Nombre:</strong> Mi Sitio Estático</p>
            <p><strong>Descripción:</strong> Sitio web estático de ejemplo</p>
            <p><strong>Estado:</strong> Funcionando</p>
            <p><strong>Timestamp:</strong> <span id="timestamp"></span></p>
        </div>
        <p>¡Este es un sitio web estático servido a través de Traefik con certificados SSL automáticos!</p>
    </div>
    
    <script>
        document.getElementById('timestamp').textContent = new Date().toISOString();
    </script>
</body>
</html>
EOF
```

### Agregar Sitio Estático al docker-compose.yml

```yaml
services:
  # ... servicios existentes ...
  
  my-static-site:
    image: nginx:alpine
    container_name: web-my-static-site
    hostname: my-static-site
    volumes:
      - /tmp/my-static-site:/usr/share/nginx/html
    networks:
      - web-dev-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.my-static-site.rule=Host(`my-static-site.local`)"
      - "traefik.http.routers.my-static-site.entrypoints=web,websecure"
      - "traefik.http.routers.my-static-site.tls=true"
      - "traefik.http.services.my-static-site.loadbalancer.server.port=80"
```

### Reiniciar Servicios para Sitio Estático

```bash
./scripts/web-manager.sh restart
```

### Acceder al Sitio Estático

- **URL**: [https://my-static-site.local:8443](https://my-static-site.local:8443)

## 🔍 Verificar Aplicaciones

### Listar Contenedores Activos

```bash
# Ver todos los contenedores activos
./scripts/container-utils.sh ps
```

### Verificar Estado del Sistema

```bash
# Verificar estado completo del sistema
./scripts/web-manager.sh status

# Verificar salud de servicios
./scripts/web-manager.sh health
```

### Ver Logs de Aplicaciones

```bash
# Ver logs de aplicación específica
./scripts/container-utils.sh logs web-my-nodejs-app

# Ver logs de Traefik
./scripts/container-utils.sh logs web-traefik
```

## 🗑️ Limpiar Aplicaciones

### Eliminar Aplicación

Para eliminar una aplicación:

1. **Editar `docker-compose.yml`** y eliminar el servicio
2. **Reiniciar servicios** con `./scripts/web-manager.sh restart`

```bash
# Reiniciar servicios después de eliminar servicio
./scripts/web-manager.sh restart
```

### Limpiar Sistema Completo

```bash
# Limpiar recursos del sistema
./scripts/web-manager.sh clean
```

## 🛠️ Solución de Problemas

### Aplicación No Accesible

```bash
# Verificar estado de contenedores
./scripts/web-manager.sh health

# Ver logs de aplicación específica
./scripts/container-utils.sh logs web-my-nodejs-app

# Verificar configuración de Traefik
./scripts/container-utils.sh logs web-traefik
```

### DNS No Resuelve

```bash
# Verificar DNS local
nslookup my-nodejs-app.local

# Reconfigurar DNS automáticamente
./scripts/setup-host.sh

# Verificar estado de dnsmasq
./scripts/container-utils.sh logs web-dnsmasq
```

### Puerto en Uso

```bash
# Verificar puertos en uso
netstat -tlnp | grep :3000

# Cambiar puerto en docker-compose.yml
# Editar la configuración del servicio y reiniciar
./scripts/web-manager.sh restart
```

## 📚 Próximos Pasos

1. **Explorar más tipos de aplicación**: Prueba con Rust, Go, etc.
2. **Personalizar configuración**: Edita archivos en `config/`
3. **Crear aplicaciones reales**: Desarrolla tus propias aplicaciones
4. **Configurar monitoreo**: Usa los comandos de `web-manager.sh`

---

**¡Disfruta desarrollando con dominios .local automáticos y certificados SSL sin warnings!** 🎉
