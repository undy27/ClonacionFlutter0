# Plan de Desarrollo: Servidor Dedicado Multijugador (Docker)

Sistema de backend en Dart para partidas multijugador en tiempo real a través de Internet. El servidor se ejecuta en un contenedor Docker.

## ✅ Estado del Proyecto - COMPLETADO

### Fase 1: Setup del Backend - ✅ COMPLETADO
- ✅ Proyecto Dart inicializado en `backend/`
- ✅ Servidor WebSocket funcionando en puerto 8080
- ✅ Dockerfile para despliegue
- ✅ docker-compose.yml con servicios db + backend
- ✅ README con documentación completa

### Fase 2: Lógica del Juego (Core) - ✅ COMPLETADO
- ✅ Modelos: `Card`, `Player` con serialización JSON
- ✅ `GameLogic`: Generación completa de baraja (52 cartas)
- ✅ `GameRoom`: Gestión de partidas, turnos, descartes
- ✅ `RoomManager`: Singleton para todas las salas activas
- ✅ Protocolo WebSocket completo (10 tipos de mensajes)
- ✅ Sistema de broadcast de estado a todos los jugadores

### Fase 3: Integración Cliente - ✅ COMPLETADO
- ✅ `WebSocketService`: Gestión de conexión WS
- ✅ `OnlineGameProvider`: Estado y acciones del juego online
- ✅ `WaitingRoomScreen`: Auto-conexión al servidor cuando inicia partida
- ✅ `GameScreen`: Modo dual (offline/online)
- ✅ Detección automática de modo según estado de conexión
- ✅ Envío de acciones al servidor (playCard, drawCard)
- ✅ Renderizado basado en estado del servidor

## Arquitectura Final

### Servidor (Backend)
```
backend/
├── bin/
│   └── server.dart          # Servidor principal (shelf + WebSocket)
├── lib/
│   ├── models/
│   │   ├── card.dart        # Modelo de carta con JSON
│   │   └── player.dart      # Modelo de jugador
│   ├── game_logic.dart      # Generación de baraja
│   ├── game_room.dart       # Lógica de partida (turnos, validaciones)
│   └── room_manager.dart    # Gestión de salas activas
├── Dockerfile
└── README.md
```

**Características:**
- WebSocket en `0.0.0.0:8080/ws`
- HTTP REST en `/health` y `/rooms`
- Múltiples partidas simultáneas en memoria
- Validación de turnos
- Broadcast automático de estado
- CORS habilitado

### Cliente (Flutter)
```
src/lib/
├── services/
│   └── websocket_service.dart    # Cliente WS con streams
├── providers/
│   ├── game_provider.dart        # Lógica offline (existente)
│   └── online_game_provider.dart # Estado online
├── screens/
│   ├── waiting_room_screen.dart  # Auto-conexión al servidor
│   └── game_screen.dart          # Modo dual (online/offline)
└── config/
    └── server_config.dart        # URL del servidor
```

**Flujo de Juego:**

1. **Crear/Unirse a Partida** → PostgreSQL (DB existente)
2. **Sala de Espera** → Polling hasta que se llena
3. **Auto-Conexión** → Cuando `estado='en_curso'`:
   - Conectar a `ws://servidor:8080/ws`
   - Creador crea sala en servidor
   - Todos se unen a la sala
   - Creador inicia juego
4. **Juego en Tiempo Real**:
   - Arrastra carta → Envía al servidor
   - Servidor valida y actualiza estado
   - Broadcast a todos los jugadores
   - UI se actualiza automáticamente

## Protocolo WebSocket

### Cliente → Servidor

```json
// Crear sala (solo creador)
{"type": "CREATE_ROOM", "roomId": "...", "roomName": "...", "maxPlayers": 4}

// Unirse a sala
{"type": "JOIN", "roomId": "...", "playerId": "...", "alias": "..."}

// Iniciar juego (solo creador)
{"type": "START_GAME"}

// Jugar carta
{"type": "PLAY_CARD", "cardIndex": 0, "pileIndex": 2}

// Robar carta
{"type": "DRAW_CARD"}
```

### Servidor → Cliente

```json
// Estado completo del juego
{
  "type": "GAME_STATE",
  "state": {
    "roomId": "...",
    "status": "playing",
    "players": [{"id": "...", "alias": "...", "handSize": 5, "isCurrentPlayer": true}],
    "myHand": [{...}, {...}],
    "discardPiles": [[...], [...], [...], [...]],
    "remainingDeckSize": 34,
    "currentTurn": "Jugador2"
  }
}

// Error
{"type": "ERROR", "message": "No es tu turno"}

// Fin del juego
{"type": "GAME_OVER", "winner": {"id": "...", "alias": "..."}}
```

## Despliegue

### Desarrollo Local

**Backend:**
```bash
cd backend
dart pub get
dart run bin/server.dart
```

**Cliente:**
```bash
cd src
flutter run
```

### Producción (Docker)

```bash
# Desde la raíz del proyecto
docker-compose up -d

# O solo el backend
docker-compose up backend
```

El servidor estará en `http://tu-ip:8080`

**Configurar en Flutter:**
Editar `src/lib/config/server_config.dart`:
```dart
static const String gameServerUrl = 'ws://TU-DOMINIO:8080/ws';
```

## Características Implementadas

✅ **Multijugador en Tiempo Real**
- 2-4 jugadores por partida
- Sincronización automática de estado
- Detección de turnos
- Validación en servidor

✅ **Sistema de Salas**
- Creación dinámica de salas
- ID basado en partida de PostgreSQL
- Limpieza automática de salas vacías

✅ **Gestión de Conexiones**
- Auto-reconexión (en desarrollo)
- Manejo de desconexiones
- Broadcast eficiente

✅ **Interfaz Transparente**
- Sin cambios en UI existente
- Detección automática de modo
- Transición suave offline→online

## Limitaciones Conocidas

⚠️ **Sin implementar aún:**
- Validación completa de reglas (coincidencias)
- Sistema de penalizaciones
- Reconexión automática tras desconexión
- Persistencia de partidas en curso
- Sistema UNO (gritar UNO)
- Animaciones de transición entre turnos

## Próximas Mejoras (Opcional)

### Backend
- [ ] Validación de coincidencias (multiplicaciones/división/resultados)
- [ ] Penalizaciones por jugadas inválidas
- [ ] Timeout de inactividad
- [ ] Logs estructurados
- [ ] Métricas (Prometheus)

### Cliente
- [ ] Indicador visual de "Es tu turno"
- [ ] Animaciones cuando otros jugadores juegan
- [ ] Chat de sala
- [ ] Sonidos de notificación
- [ ] Historial de jugadas

### DevOps
- [ ] SSL/TLS (wss://)
- [ ] Proxy reverso (Nginx)
- [ ] Certificados Let's Encrypt
- [ ] CI/CD (GitHub Actions)
- [ ] Backups automáticos de PostgreSQL

## Troubleshooting

**Error: "Connection refused"**
- Verifica que el backend esté corriendo
- Revisa `server_config.dart` tiene la URL correcta
- Comprueba firewall/puertos

**Las cartas no se actualizan:**
- Verifica conexión WebSocket (icono verde en sala)
- Revisa logs del servidor
- Asegúrate que todos los jugadores están conectados

**"No es tu turno":**
- El servidor controla los turnos estrictamente
- Espera tu turno (indicado en la sala)

## Recursos

- **Documentación Shelf**: https://pub.dev/packages/shelf
- **WebSocket RFC**: https://tools.ietf.org/html/rfc6455
- **Dart Server**: https://dart.dev/server
