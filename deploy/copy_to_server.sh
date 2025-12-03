#!/bin/bash

# Configuración del Servidor
SERVER_IP="192.168.1.7"
SERVER_USER="root" # Usuario por defecto en unRaid, cámbialo si es diferente
REMOTE_PATH="/mnt/user/appdata/clonacion_flutter"

# Directorio base del proyecto (asumiendo que ejecutas este script desde la raíz del proyecto o desde deploy/)
# Si se ejecuta desde deploy/, subir un nivel.
if [ -d "../backend" ]; then
    cd ..
fi

echo "========================================================"
echo "Desplegando a unRaid ($SERVER_IP)"
echo "Ruta destino: $REMOTE_PATH"
echo "========================================================"

# 1. Crear directorio remoto si no existe
echo "Creating remote directory..."
ssh "$SERVER_USER@$SERVER_IP" "mkdir -p $REMOTE_PATH"

# 2. Copiar archivos de configuración
echo "Copying configuration files..."
scp deploy/docker-compose.yml "$SERVER_USER@$SERVER_IP:$REMOTE_PATH/"
scp deploy/.env "$SERVER_USER@$SERVER_IP:$REMOTE_PATH/"

# 3. Copiar carpeta backend
# Nota: Esto copiará todo el contenido. Si tienes carpetas pesadas como .dart_tool o build,
# podrías querer borrarlas localmente antes o usar rsync con exclusiones.
echo "Copying backend directory (this may take a while)..."
scp -r backend "$SERVER_USER@$SERVER_IP:$REMOTE_PATH/"

# 4. Limpiar artefactos de build en el servidor para evitar errores de Docker
echo "Cleaning remote build artifacts..."
ssh "$SERVER_USER@$SERVER_IP" "rm -rf $REMOTE_PATH/backend/.dart_tool $REMOTE_PATH/backend/.packages $REMOTE_PATH/backend/build $REMOTE_PATH/backend/pubspec.lock"

echo "========================================================"
echo "¡Copia completada con éxito!"
echo "========================================================"
echo "Siguientes pasos:"
echo "1. Accede a tu unRaid."
echo "2. Ve a la ruta $REMOTE_PATH"
echo "3. Configura el archivo .env si es necesario."
echo "4. Usa Docker Compose Manager para levantar el stack."
