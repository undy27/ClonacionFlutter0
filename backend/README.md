# Game Server Backend

Backend del juego de cartas multijugador en Dart.

## Desarrollo Local

### Requisitos
- Dart SDK 3.0+

### Instalación
```bash
cd backend
dart pub get
```

### Ejecutar en desarrollo
```bash
dart run bin/server.dart
```

El servidor estará disponible en `http://localhost:8080`

### Endpoints

- `GET /health` - Health check
- `GET /rooms` - Lista de salas disponibles
- `WS /ws` - WebSocket para conexión de clientes

## Docker

### Construir la imagen
```bash
docker build -t game-server ./backend
```

### Ejecutar contenedor
```bash
docker run -p 8080:8080 game-server
```

### Con Docker Compose
Desde la raíz del proyecto:
```bash
docker-compose up backend
```

## Protocolo WebSocket

### Cliente → Servidor

**Crear Sala**
```json
{
  "type": "CREATE_ROOM",
  "roomId": "unique-id",
  "roomName": "Mi Partida",
  "maxPlayers": 4
}
```

**Unirse a Sala**
```json
{
  "type": "JOIN",
  "roomId": "unique-id",
  "playerId": "user-id",
  "alias": "Jugador1"
}
```

**Iniciar Juego**
```json
{
  "type": "START_GAME"
}
```

**Jugar Carta**
```json
{
  "type": "PLAY_CARD",
  "cardIndex": 0,
  "pileIndex": 2
}
```

**Robar Carta**
```json
{
  "type": "DRAW_CARD"
}
```

### Servidor → Cliente

**Estado del Juego**
```json
{
  "type": "GAME_STATE",
  "state": {
    "roomId": "...",
    "status": "playing",
    "players": [...],
    "myHand": [...],
    "discardPiles": [[...], [...], [...], [...]],
    "remainingDeckSize": 34,
    "currentTurn": "Jugador2"
  }
}
```

**Error**
```json
{
  "type": "ERROR",
  "message": "No es tu turno"
}
```

**Fin del Juego**
```json
{
  "type": "GAME_OVER",
  "winner": {
    "id": "...",
    "alias": "Ganador"
  }
}
```
