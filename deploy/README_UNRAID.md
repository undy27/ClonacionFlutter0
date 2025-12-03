# Despliegue en Servidor unRaid (Backend WebSockets)

Esta guía te ayudará a desplegar el servidor del juego (Backend para WebSockets) en tu servidor unRaid utilizando Docker Compose.
**Nota:** La base de datos está alojada en Supabase, por lo que no se despliega aquí.

## Requisitos Previos en unRaid

1.  **Plugin "Docker Compose Manager"**: Instálalo desde la pestaña "Apps" (Community Applications) en unRaid.
2.  **Acceso a Terminal**: Para copiar archivos.

## Pasos de Instalación

### 1. Preparar los Archivos

Copia la carpeta `backend` y los archivos de `deploy` a tu servidor unRaid (ej: `/mnt/user/appdata/clonacion_flutter`).

Estructura final:
```
/mnt/user/appdata/clonacion_flutter/
├── docker-compose.yml
├── .env
└── backend/
    ├── Dockerfile
    ├── pubspec.yaml
    ├── pubspec.lock
    ├── analysis_options.yaml
    ├── bin/
    │   └── server.dart
    └── lib/
        └── ... (código del backend)
```

### 2. Configurar Variables de Entorno

1.  Edita el archivo `.env` en tu servidor si necesitas cambiar el puerto (por defecto 8080).
2.  Asegúrate de que `SERVER_PORT` no esté en conflicto con otros servicios.

### 3. Desplegar

Desde unRaid (Docker -> Docker Compose):
1.  Añade proyecto `clonacion_flutter`.
2.  Selecciona la ruta.
3.  Haz clic en "Compose Up".

### 4. Acceso desde Internet

Necesitas hacer accesible el puerto de WebSockets.

**Opción A: Abrir Puertos**
*   Router: Puerto externo `8080` -> IP unRaid: `8080` (TCP).

**Opción B: Reverse Proxy (Recomendado)**
*   Usa Nginx Proxy Manager en unRaid.
*   Apunta un dominio (ej: `ws.tudominio.com`) a tu IP pública.
*   Redirige a IP unRaid puerto `8080`.
*   **Importante:** Activa "Websockets Support" en Nginx Proxy Manager.

## Configuración de la App Flutter

1.  Abre `src/lib/config/server_config.dart`.
2.  Actualiza la URL del servidor de WebSockets (`ws://...` o `wss://...`) con tu IP pública o dominio.
3.  La configuración de Supabase (DB) se mantiene igual si ya funciona.
4.  Recompila la app.
