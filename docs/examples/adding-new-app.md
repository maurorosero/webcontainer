# Ejemplo: Agregar Nueva Aplicación

Este ejemplo te muestra cómo agregar una nueva aplicación al sistema web local.

## 🚀 Ejemplo 1: Aplicación Node.js

### Crear Aplicación de Prueba

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

### Publicar Aplicación

```bash
# Publicar aplicación
./scripts/publish-app.sh publish /tmp/my-nodejs-app my-nodejs-app my-nodejs-app.local.dev 3000 "Mi Aplicación Node.js" "/health"
```

### Acceder a la Aplicación

- **URL**: https://my-nodejs-app.local.dev
- **Health Check**: https://my-nodejs-app.local.dev/health

## 🚀 Ejemplo 2: Aplicación React

### Crear Aplicación React

```bash
# Crear aplicación React con Vite
npm create vite@latest /tmp/my-react-app -- --template react
cd /tmp/my-react-app
npm install
```

### Modificar para Desarrollo

```bash
# Modificar vite.config.js para permitir acceso externo
cat > vite.config.js << EOF
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    host: '0.0.0.0',
    port: 3000
  }
})
EOF
```

### Publicar Aplicación

```bash
# Publicar aplicación React
./scripts/publish-app.sh publish /tmp/my-react-app my-react-app my-react-app.local.dev 3000 "Mi Aplicación React" "/"
```

### Acceder a la Aplicación

- **URL**: https://my-react-app.local.dev

## 🚀 Ejemplo 3: Aplicación PHP

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

### Publicar Aplicación

```bash
# Publicar aplicación PHP
./scripts/publish-app.sh publish /tmp/my-php-app my-php-app my-php-app.local.dev 80 "Mi Aplicación PHP" "/health.php"
```

### Acceder a la Aplicación

- **URL**: https://my-php-app.local.dev
- **Health Check**: https://my-php-app.local.dev/health.php

## 🚀 Ejemplo 4: Aplicación Python

### Crear Aplicación Python

```bash
# Crear directorio de aplicación
mkdir -p /tmp/my-python-app
cd /tmp/my-python-app

# Crear requirements.txt
cat > requirements.txt << EOF
flask==2.3.3
EOF

# Crear archivo principal
cat > app.py << EOF
from flask import Flask, jsonify
import datetime

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        'name': 'my-python-app',
        'description': 'Aplicación Python de ejemplo',
        'status': 'running',
        'timestamp': datetime.datetime.now().isoformat(),
        'python_version': '3.x'
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF
```

### Publicar Aplicación

```bash
# Publicar aplicación Python
./scripts/publish-app.sh publish /tmp/my-python-app my-python-app my-python-app.local.dev 5000 "Mi Aplicación Python" "/health"
```

### Acceder a la Aplicación

- **URL**: https://my-python-app.local.dev
- **Health Check**: https://my-python-app.local.dev/health

## 🚀 Ejemplo 5: Sitio Web Estático

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
        <p>¡Este es un sitio web estático servido a través de Caddy con certificados SSL válidos!</p>
    </div>
    
    <script>
        document.getElementById('timestamp').textContent = new Date().toISOString();
    </script>
</body>
</html>
EOF
```

### Publicar Aplicación

```bash
# Publicar sitio estático
./scripts/publish-app.sh publish /tmp/my-static-site my-static-site my-static-site.local.dev 80 "Mi Sitio Estático" "/"
```

### Acceder a la Aplicación

- **URL**: https://my-static-site.local.dev

## 🔍 Verificar Aplicaciones

### Listar Aplicaciones Publicadas

```bash
# Listar todas las aplicaciones
./scripts/publish-app.sh list
```

### Verificar Estado de Aplicaciones

```bash
# Verificar estado de todas las aplicaciones
./scripts/publish-app.sh check
```

### Verificar Certificados SSL

```bash
# Verificar certificado específico
./scripts/verify-ssl.sh verify-browser my-nodejs-app.local.dev

# Verificar todos los certificados
./scripts/verify-ssl.sh verify-all
```

## 🗑️ Limpiar Aplicaciones

### Despublicar Aplicación

```bash
# Despublicar aplicación específica
./scripts/publish-app.sh unpublish my-nodejs-app
```

### Limpiar Contenedores

```bash
# Limpiar recursos del sistema
./scripts/web-manager.sh cleanup
```

## 🛠️ Solución de Problemas

### Aplicación No Accesible

```bash
# Verificar estado de contenedores
./scripts/web-manager.sh health

# Ver logs de aplicación específica
./scripts/container-utils.sh logs web-my-nodejs-app  # Usa el wrapper automático

# Verificar configuración de Caddy
docker exec web-caddy caddy config --config /etc/caddy/Caddyfile
```

### Certificado No Válido

```bash
# Verificar certificados
./scripts/cert-manager.sh verify

# Reinstalar CA
./scripts/cert-manager.sh install-ca

# Verificar certificado específico
./scripts/verify-ssl.sh verify-browser my-app.local.dev
```

### Puerto en Uso

```bash
# Verificar puertos en uso
netstat -tlnp | grep :3000

# Usar puerto diferente
./scripts/publish-app.sh publish /path/to/app app-name domain 3001
```

## 📚 Próximos Pasos

1. **Explorar más tipos de aplicación**: Prueba con Rust, Go, etc.
2. **Configurar monitoreo**: Usa `./scripts/monitor-apps.sh`
3. **Personalizar configuración**: Edita archivos en `config/`
4. **Crear aplicaciones reales**: Desarrolla tus propias aplicaciones

---

**¡Disfruta desarrollando con certificados SSL válidos y sin warnings en el navegador!** 🎉
