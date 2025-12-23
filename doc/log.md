# Log de Cambios - Proyecto Clonación Flutter

## 2025-12-11 a 2025-12-23

### Sesión 11: Refinamiento Visual, Sistema Elo, Feedback Háptico y Música

**Objetivo:** Mejorar la experiencia de usuario mediante refinamientos visuales, implementar el sistema de rating Elo, mejorar el feedback háptico, actualizar el sistema de avatares, añadir música de fondo y actualizar el icono de la app.

#### Cambios Realizados:

1. **Refinamiento Visual de Recuadros de Jugadores** (`lib/screens/game_screen.dart`)
   * Forzado uso de colores del modo oscuro independientemente del tema seleccionado
   * Fondo transparente para mostrar el tapete verde
   * Bordes aumentados para mejor visibilidad:
     - Jugador actual: 4px (azul primary)
     - Jugadores rivales: 2px (blanco semi-transparente)
   * Avatar con fondo gris oscuro (#2C2C2C)
   * Texto en gris claro (grey[300])
   * Padding horizontal reducido de 6px a 4px para evitar overflow en iPhone

2. **Sistema de Rating Elo** (`lib/providers/online_game_provider.dart`, `lib/services/postgres_service.dart`)
   * Implementado sistema Elo basado en FIDE adaptado para 2-4 jugadores
   * Lógica de cálculo:
     - Ganador juega "partidas virtuales" contra cada perdedor
     - Cada perdedor juega una sola partida contra el ganador
     - Factor K: 40 para primeras 30 partidas, 20 para partidas posteriores
     - Rating inicial: 1500 puntos
   * Métodos añadidos:
     - `_updateEloRatings()`: Actualiza ratings al finalizar partida
     - `_calculateEloRatings()`: Calcula nuevos ratings según sistema Elo
     - `PostgresService.updateUserStats()`: Actualiza BD con nuevos ratings y estadísticas
     - `PostgresService.getUsuarioById()`: Obtiene usuario por ID
   * Actualización automática al recibir evento `GAME_OVER`
   * Manejo de null safety con valores por defecto (1500 para rating, 0 para partidas)

3. **Mejoras en Feedback Háptico** (`lib/screens/game_screen.dart`)
   * Sistema de deduplicación para evitar feedback doble
   * Feedback háptico al tocar carta (onTapDown)
   * Feedback háptico al arrastrar carta (onDragStarted)
   * Ventana de deduplicación de 2 segundos
   * Variable de estado `_lastHapticTime` para tracking
   * Aplicado tanto a cartas de mano como al mazo

4. **Sistema de Avatares Actualizado** (`lib/utils/avatar_helper.dart`, `lib/models/usuario.dart`, `pubspec.yaml`)
   * Nuevos avatares añadidos:
     - ainara
     - amy (nuevo)
     - androide
     - cientifico
     - fx (nuevo, con manejo especial de mayúsculas)
   * Eliminado avatar: timida
   * Total de 5 avatares disponibles
   * Cada avatar con 4 estados:
     - Estado 0: Menú/ranking (*.0.png)
     - Estado 1: Ganando en solitario (*.1.png)
     - Estado 2: Ni ganando ni perdiendo (*.2.png)
     - Estado 3: Perdiendo en solitario (*.3.png)
   * Validación automática de avatares:
     - Si avatar guardado no existe, se asigna uno aleatorio
     - Métodos `_isValidAvatar()` y `_getRandomAvatar()` en Usuario

5. **Música de Fondo para Menús** (`lib/services/sound_manager.dart`, `lib/screens/home_screen.dart`, `lib/screens/options_screen.dart`)
   * Nuevo `AudioPlayer` dedicado para música de fondo
   * Archivo de música: `assets/musica/M.1.mp3`
   * Características:
     - Reproducción en bucle (ReleaseMode.loop)
     - Volumen al 50% para no interferir con efectos de sonido
     - Inicia automáticamente en HomeScreen
     - Se detiene al comenzar partida (GameScreen)
   * Control desde opciones:
     - Respeta configuración `musicEnabled` del ThemeProvider
     - Toggle en opciones inicia/detiene música inmediatamente
     - Parámetro `musicEnabled` en `playBackgroundMusic()`
   * Estado tracking con `_isMusicPlaying`

6. **Actualización de Icono de App** (`pubspec.yaml`, archivos de iconos)
   * Añadido paquete `flutter_launcher_icons: ^0.13.1`
   * Configuración:
     - Imagen fuente: `assets/icons/icon.1.png`
     - Generación para Android e iOS
     - `remove_alpha_ios: true` para compatibilidad iOS
   * Generados automáticamente todos los tamaños necesarios:
     - Android: múltiples densidades (mipmap)
     - iOS: múltiples tamaños (AppIcon.appiconset)
   * Comando ejecutado: `dart run flutter_launcher_icons`

#### Correcciones de Errores:

* **Fix async/null safety en Elo**: Listener de mensajes convertido a async, añadidos casts y valores por defecto para evitar errores de compilación
* **Fix imports duplicados**: Eliminado import duplicado de SoundManager en options_screen.dart

#### Archivos Creados:

1. `assets/musica/M.1.mp3` - Música de fondo para menús
2. `assets/icons/icon.1.png` - Nuevo icono de la app
3. `assets/avatars/amy/` - Nuevo avatar
4. `assets/avatars/fx/` - Nuevo avatar
5. Múltiples archivos de iconos generados en `android/` e `ios/`

#### Archivos Modificados:

1. `lib/screens/game_screen.dart` - Estilos de jugadores, feedback háptico, detener música
2. `lib/providers/online_game_provider.dart` - Sistema Elo, imports
3. `lib/services/postgres_service.dart` - Métodos para Elo (updateUserStats, getUsuarioById)
4. `lib/utils/avatar_helper.dart` - Lista de avatares, manejo de FX
5. `lib/models/usuario.dart` - Validación de avatares, asignación aleatoria
6. `lib/services/sound_manager.dart` - Música de fondo
7. `lib/screens/home_screen.dart` - Inicio de música, imports
8. `lib/screens/options_screen.dart` - Control de música desde opciones
9. `pubspec.yaml` - Directorio de música, flutter_launcher_icons, avatares

#### Notas Técnicas:

* **Sistema Elo**: Implementación matemáticamente correcta según especificaciones FIDE, adaptada para multijugador
* **Feedback Háptico**: Ventana de 2 segundos elegida tras pruebas para balance entre responsividad y prevención de duplicados
* **Música**: AudioPlayer separado permite control independiente de música y efectos de sonido
* **Avatares**: Sistema robusto que previene crashes si avatares son eliminados
* **Iconos**: flutter_launcher_icons automatiza generación de todos los tamaños necesarios

---

## 2025-11-29

### Sesión 10: Corrección Crítica de Gestión de Partidas y Generación de Baraja

**Objetivo:** Resolver el problema crítico donde el jugador creador no entraba a la sala de espera y el jugador que se unía quedaba bloqueado al intentar iniciar la partida.

#### Cambios Realizados:

1.  **Corrección de Bucle Infinito en `GameLogic.generarBaraja()`** (`lib/services/game_logic.dart`)
    *   Añadido contador de seguridad (`maxAttempts = 10000`) para evitar bucle infinito al generar 46 pares extra con productos únicos.
    *   Implementada estrategia de fallback que relaja la restricción si no se pueden generar suficientes pares únicos.
    *   Añadidos logs de progreso cada 10 pares generados.
    *   **Causa del bloqueo:** El algoritmo intentaba generar 46 pares con productos únicos, pero el espacio de productos posibles era limitado, causando bucle infinito.

2.  **Mejoras en Robustez de `PostgresService`** (`lib/services/postgres_service.dart`)
    *   **`createPartida`:** Añadido manejo robusto de errores con try-catch para obtener alias del creador, usando 'Unknown' como fallback.
    *   **`startPartida`:** Cambiado de conexión compartida a conexión dedicada para evitar bloqueos.
    *   Añadidos logs detallados con stack traces para diagnóstico.

3.  **Corrección de Flujo de Navegación** (`lib/screens/game_list_screen.dart` y `lib/widgets/create_game_dialog.dart`)
    *   **Problema identificado:** El `context` del diálogo se desmontaba antes de completar la navegación.
    *   **Solución:** Capturar el `context` del `GameListScreen` ANTES de abrir el diálogo y usarlo para la navegación.
    *   Modificado orden de ejecución: cerrar diálogo inmediatamente, luego navegar usando el contexto capturado.

4.  **Instrumentación Completa con Logs** 
    *   Añadidos logs detallados en `GameProvider.createPartida()`, `GameProvider.startPartida()`, y `_initializeLocalGame()`.
    *   Añadidos logs en `PostgresService.getPartidaById()` para trazar estado de partidas.
    *   Logs permitieron identificar exactamente dónde fallaba cada paso del flujo.

#### Problemas Resueltos:

*   ✅ **Jugador Creador no entraba a sala de espera:** Solucionado corrigiendo el flujo de navegación al capturar el contexto correcto.
*   ✅ **Jugador que se une quedaba bloqueado:** Resuelto al corregir el bucle infinito en generación de baraja.
*   ✅ **Diálogo de creación no se cerraba:** Corregido invirtiendo orden (cerrar diálogo antes de operaciones async).
*   ✅ **Conexiones de BD bloqueadas:** Solucionado usando conexiones dedicadas para operaciones críticas.

#### Flujo Completo Ahora Funcional:

1.  Jugador A crea partida → entra a sala de espera ✅
2.  Jugador B se une → entra a sala de espera ✅
3.  Partida inicia automáticamente → ambos ven tablero ✅

#### Notas Técnicas:

*   Se confirmó que el algoritmo de generación de baraja tiene limitaciones matemáticas (solo ~42 productos únicos posibles de 0-10), por lo que el fallback es necesario.
*   El uso de conexiones dedicadas aumenta ligeramente el overhead de SSL handshake pero evita condiciones de carrera.
*   La estrategia de captura de contexto es crucial en Flutter cuando se usan diálogos modales con navegación posterior.

---

### Sesión 9: Persistencia de Tema, Récords de Tiempo y Sonidos

**Objetivo:** Implementar la persistencia del modo oscuro en la base de datos, completar la pantalla de récords de tiempo con desglose por número de jugadores, y añadir feedback sonoro básico.

#### Cambios Realizados:

1.  **Persistencia de Tema en Base de Datos**
    *   **Modelo `Usuario`:** Añadido campo `isDarkMode` (booleano).
    *   **`PostgresService`:**
        *   Actualizado `initAuthTables` para añadir columna `is_dark_mode` si no existe.
        *   Implementado método `updateThemePreference`.
    *   **`ThemeProvider`:** Añadido método `syncFromUser` para sincronizar preferencia tras login.
    *   **`AuthScreen`:** Sincronización automática del tema al iniciar sesión.
    *   **`OptionsScreen`:** Actualización inmediata en BD al cambiar el switch.

2.  **Pantalla de Ranking y Récords** (`lib/screens/ranking_screen.dart`)
    *   Implementado `TabBar` con dos pestañas: "PUNTUACIONES" y "RÉCORDS TIEMPO".
    *   **Pestaña Récords:**
        *   Filtros interactivos para 2, 3 y 4 jugadores.
        *   Visualización de tiempos formateados (mm:ss).
        *   Corrección de unidad de tiempo (segundos vs milisegundos).
    *   **Diseño Compacto:**
        *   Reducción de márgenes, paddings y tamaños de fuente para maximizar información visible.
        *   Unificación visual entre listas de puntuaciones y récords.

3.  **Sistema de Sonidos**
    *   Implementado feedback sonoro usando `SystemSound.play(SystemSoundType.click)`.
    *   Añadido a:
        *   Todos los botones `CustomButton`.
        *   Switch de opciones.
        *   Pestañas de ranking.
        *   Filtros de jugadores.

#### Correcciones de Errores:
*   **Fix en `RankingScreen`:** Corregida visualización de "0m 0s" asumiendo que los datos en BD están en segundos.
*   **Fix de UI:** Centrado de mensaje "No hay récords" y ajustes de alineación.

#### Notas Técnicas:
*   Se optó por `SystemSound` para los sonidos de interfaz por ser una solución nativa y ligera que no requiere assets externos ni dependencias pesadas como `audioplayers` para interacciones básicas.

---

## 2025-11-28

### Sesión 8: Implementación de Modo Claro/Oscuro y Correcciones de Juego

**Objetivo:** Implementar la funcionalidad de modo claro/oscuro y corregir errores críticos en el flujo de creación y unión a partidas.

#### Cambios Realizados:

1.  **Gestión de Temas** (`lib/providers/theme_provider.dart`)
    *   Creado `ThemeProvider` para gestionar el estado del tema (claro/oscuro).
    *   Implementada persistencia usando `shared_preferences`.

2.  **Definición de Estilos** (`lib/theme/app_theme.dart`)
    *   Definido `darkTheme` manteniendo la estética Neo-Brutalista pero con paleta oscura.
    *   Colores oscuros: Fondo `#121212`, Superficie `#1E1E1E`, Texto blanco.
    *   Actualizado `lightTheme` para ser explícito.

3.  **Interfaz de Usuario** (`lib/screens/options_screen.dart`)
    *   Agregado interruptor (toggle) para "Modo Oscuro".
    *   Refactorizado para usar colores del tema actual (`Theme.of(context)`).

4.  **Configuración Global** (`lib/main.dart`)
    *   Inyectado `ThemeProvider` en el árbol de widgets.
    *   Configurado `MaterialApp` con `theme`, `darkTheme` y `themeMode`.

5.  **Correcciones Críticas de Juego** (`lib/providers/game_provider.dart` y `lib/services/postgres_service.dart`)
    *   **Jugadores Fantasma:** Implementada lógica para abandonar automáticamente cualquier partida anterior al crear una nueva.
    *   **Inicio Automático:** Permitido que cualquier jugador (no solo el creador) inicie la partida cuando está llena (2/2), solucionando el bloqueo en "Esperando jugadores".
    *   **Atomicidad:** Asegurado que `startPartida` en BD sea atómico para evitar condiciones de carrera.

#### Correcciones de Errores:
*   **Fix en `PostgresService`**: Corregido error de sintaxis (falta de llave de cierre) introducido en sesión anterior.
*   **Fix en `WaitingRoomScreen`**: Ahora muestra correctamente los nombres de los jugadores en lugar de IDs.

#### Notas Técnicas:
*   El modo oscuro afecta a menús e interfaces, pero no a las cartas del juego (según especificación).
*   La lógica de inicio de partida es ahora descentralizada en el cliente (cualquiera puede dispararla), pero centralizada en la BD (solo una actualización tiene éxito).

---

### Sesión 7: Implementación de Creación de Partida y Sala de Espera

**Objetivo:** Implementar el flujo completo de creación de una nueva partida, incluyendo la interfaz de usuario, la lógica en el provider y la persistencia en base de datos, así como la sala de espera previa al juego.

#### Cambios Realizados:

1.  **Diálogo de Creación** (`lib/widgets/create_game_dialog.dart`)
    *   Widget modal con formulario para:
        *   Nombre de la partida (validación de no vacío).
        *   Número de jugadores (Selector 2, 3, 4).
        *   Rango de Rating (RangeSlider 0-3000).
    *   Diseño consistente con el tema de la app.

2.  **Sala de Espera** (`lib/screens/waiting_room_screen.dart`)
    *   Pantalla que muestra:
        *   Información de la partida (Nombre, Jugadores, Rating).
        *   Lista de jugadores unidos (con avatares).
        *   Botón "COMENZAR PARTIDA" (solo visible para el creador).
    *   Lógica para iniciar la partida y navegar al juego.

3.  **Lógica de Juego** (`lib/providers/game_provider.dart`)
    *   Actualizado `createPartida` para usar `PostgresService` real.
    *   Actualizado `startPartida` para usar `PostgresService` real.
    *   Manejo de estado de carga (`isLoading`).
    *   Uso temporal de ID de usuario fijo ('user_1').

4.  **Integración en Lista de Partidas** (`lib/screens/game_list_screen.dart`)
    *   Botón flotante "+" ahora abre el `CreateGameDialog`.
    *   Navegación a `/waiting_room` tras crear la partida exitosamente.

5.  **Navegación** (`lib/main.dart`)
    *   Agregada ruta `/waiting_room`.

#### Correcciones de Errores:
*   **Fix en `GameScreen`**: Eliminada llamada a método inexistente `startGame` en `initState`. Agregado import `dart:math`.
*   **Fix en `GameProvider`**: Agregada lógica para asegurar que el usuario mock (`user_1`) exista en la base de datos antes de crear una partida, evitando errores de clave foránea (FK violation).

#### Notas Técnicas:
*   Se utiliza `DateTime.now().millisecondsSinceEpoch` para generar IDs temporales de partida hasta que la BD lo maneje automáticamente o se use UUID v4.
*   La lógica de reparto de cartas en `startPartida` sigue siendo local/mock hasta que se implemente la sincronización en tiempo real.

---

### Sesión 6: Implementación de Opciones > Estilo de Carta

**Objetivo:** Implementar la funcionalidad de selección de estilo de carta (Clásico vs Moderno) con vista previa y guardado de preferencias.

#### Cambios Realizados:

1. **Nueva Pantalla de Opciones** (`lib/screens/options_screen.dart`)
   - Pantalla principal de opciones con navegación a:
     - **Estilo de Carta** (implementado)
     - Sonidos (placeholder, deshabilitado)
     - Modificar Contraseña (placeholder, deshabilitado)
     - Avatar (placeholder, deshabilitado)
   - Diseño neo-brutalista consistente con el resto de la app
   - Botón de retroceso en AppBar

2. **Nueva Pantalla de Selección de Tema** (`lib/screens/card_theme_screen.dart`)
   - Dos opciones de tema:
     - **Tema Moderno** (por defecto): Diseño basado en círculos interconectados
     - **Tema Clásico**: Diseño tipo grid con líneas divisorias
   - Vista previa de carta de ejemplo para cada tema
   - Carta de ejemplo con datos representativos:
     - Multiplicaciones: 3×7, 10×4, 6×6
     - División: 24:8
     - Resultados: 21, 40, 36
   - Indicador visual de tema seleccionado:
     - Borde verde grueso (4px) para tema seleccionado
     - Icono de check verde
     - Sombra destacada
   - Guardado de preferencia en `SharedPreferences`
   - Feedback visual con SnackBar al guardar
   - Estado de carga mientras se recupera la preferencia guardada

3. **Navegación** (`lib/main.dart`)
   - Agregada ruta `/options` → `OptionsScreen()`
   - Agregada ruta `/card_theme` → `CardThemeScreen()`
   - Imports de las nuevas pantallas

4. **Conexión desde Menú Principal** (`lib/screens/home_screen.dart`)
   - Conectado botón "OPCIONES" a la ruta `/options`

5. **Actualización de Tema** (`lib/theme/app_theme.dart`)
   - Agregadas constantes de color faltantes:
     - `success`: Color(0xFF10B981) - Verde (mismo que secondary)
     - `warning`: Color(0xFFEF4444) - Rojo
     - `textPrimary`: Colors.black - Negro
     - `textSecondary`: Color(0xFF6B7280) - Gris

#### Características Técnicas:

- **Persistencia de Datos:**
  - Uso de `SharedPreferences` para guardar el tema seleccionado
  - Clave: `tema_cartas`
  - Valores: `'clasico'` o `'moderno'`
  - Carga automática al abrir la pantalla

- **Diseño Responsive:**
  - Vista previa de cartas con tamaño fijo (200×270)
  - Scroll vertical para pantallas pequeñas
  - Padding consistente de 24px

- **UX/UI:**
  - Transiciones suaves entre pantallas
  - Feedback inmediato al seleccionar tema
  - Indicadores visuales claros de selección
  - Opciones futuras mostradas con opacidad reducida (0.5)

---

### Sesión 5: Implementación de Ranking Global

**Objetivo:** Implementar la funcionalidad de ranking global con datos desde PostgreSQL.

#### Cambios Realizados:

1. **Nueva Pantalla** (`lib/screens/ranking_screen.dart`)
   - Pantalla completa de ranking global
   - Carga datos desde PostgreSQL vía `PostgresService`
   - Diseño especial para top 3:
     - 🥇 1er lugar: Medalla dorada
     - 🥈 2do lugar: Medalla plateada
     - 🥉 3er lugar: Medalla bronce
   - Información por jugador:
     - Posición en ranking
     - Avatar con inicial
     - Alias
     - Victorias/Derrotas
     - Rating Elo
   - Pull-to-refresh
   - Manejo de estados: loading, error, vacío

2. **Navegación** (`lib/screens/home_screen.dart`)
   - Conectado botón "RANKING GLOBAL" a `/ranking`

3. **Router** (`lib/main.dart`)
   - Agregada ruta `/ranking` → `RankingScreen()`

4. **Modelos** (`lib/models/partida.dart`)
   - Agregados métodos `fromJson()` y `toJson()`
   - Soporte para serialización desde PostgreSQL

---

### Sesión 4: Migración de Supabase SDK a PostgreSQL Directo

**Problema:** El SDK de Supabase requiere anon key, pero el usuario usa conexión directa a PostgreSQL (como en su backend Node.js).

#### Cambios Realizados:

1. **Dependencias** (`pubspec.yaml`)
   - ❌ Eliminado: `supabase_flutter: ^2.0.0`
   - ✅ Agregado: `postgres: ^2.6.0`

2. **Configuración** (`lib/config/supabase_config.dart`)
   - Reemplazada configuración de Supabase por PostgreSQL directo
   - Agregados parámetros: host, port, database, username, password
   - Connection string: `postgresql://postgres.dwrzqqeabgrrornmyyum:ClonBD1111A4@aws-1-eu-west-1.pooler.supabase.com:6543/postgres`

3. **Nuevo Servicio** (`lib/services/postgres_service.dart`)
   - Creado servicio de conexión directa a PostgreSQL
   - Usa `PostgreSQLConnection` (API de postgres 2.6.0)
   - Pool de conexiones automático
   - SSL habilitado para seguridad
   - Métodos implementados:
     - **Usuarios:** getUsuarioByAlias, createUsuario, updateTemaCartas
     - **Partidas:** getPartidasDisponibles, createPartida, updatePartidaEstado, startPartida, finalizarPartida
     - **Ranking:** getRankingGlobal, getRecordsTiempo

4. **Main** (`lib/main.dart`)
   - Eliminada inicialización de Supabase
   - Eliminado import de `supabase_flutter`
   - Eliminado import de `config/supabase_config.dart`
   - Función `main()` ahora es síncrona (no async)

5. **Pantalla de Ranking** (`lib/screens/ranking_screen.dart`)
   - Cambiado import de `supabase_service.dart` a `postgres_service.dart`
   - Cambiado `SupabaseService` por `PostgresService`

6. **Fix de Prepared Statements**
   - Agregado `allowReuse: false` a todas las queries
   - Soluciona error: "prepared statement already exists"

---

### Sesión 3: Fix de UI - Overflow en Lista de Partidas

**Problema:** Error de overflow de 30 píxeles en `partida_list_item.dart`.

#### Cambios Realizados:

1. **Archivo:** `lib/widgets/partida_list_item.dart`
   - Envuelto columna izquierda con `Expanded`
   - Agregado `overflow: TextOverflow.ellipsis` a textos
   - Agregado `maxLines: 1` para limitar altura
   - Agregado `SizedBox(width: 12)` entre columnas

---

### Sesión 2: Solución de Problemas de Permisos de Red en macOS

**Problema:** Google Fonts no podía descargar fuentes debido a permisos de red en macOS.

#### Cambios Realizados:

1. **Entitlements de macOS** (Permisos de Red)
   - Archivo: `macos/Runner/DebugProfile.entitlements`
   - Archivo: `macos/Runner/Release.entitlements`
   - Agregado: `<key>com.apple.security.network.client</key><true/>`

2. **Fuentes Locales** (Solución definitiva)
   - Descargadas fuentes localmente:
     - `fonts/SpaceMono-Regular.ttf`
     - `fonts/SpaceMono-Bold.ttf`
     - `fonts/LexendMega-Bold.ttf`
   - Actualizado `pubspec.yaml` para incluir fuentes como assets
   - Modificado `lib/theme/app_theme.dart` para usar fuentes locales
   - Modificado `lib/widgets/carta_widget.dart` para usar fuentes locales
   - **Eliminada dependencia de Google Fonts en tiempo de ejecución**

3. **Beneficios:**
   - ✅ No requiere conexión a Internet al iniciar
   - ✅ Mejor rendimiento (no descarga fuentes)
   - ✅ Evita problemas de permisos de red
   - ✅ Funciona offline

---

### Sesión 1: Instalación de Flutter y Dependencias Iniciales

**Objetivo:** Instalar Flutter y las dependencias necesarias para el proyecto.

#### Cambios Realizados:

1. **Instalación de Flutter SDK**
   - Instalado Flutter 3.38.3 vía Homebrew
   - Dart 3.10.1 incluido
   - DevTools 2.51.1

2. **Configuración de Dependencias** (`pubspec.yaml`)
   - Agregado: `supabase_flutter: ^2.0.0` (posteriormente reemplazado)
   - Ya existentes:
     - `provider: ^6.1.1`
     - `google_fonts: ^6.1.0`
     - `flutter_svg: ^2.0.9`
     - `uuid: ^4.3.3`
     - `intl: ^0.19.0`
     - `animate_do: ^3.3.2`
     - `shared_preferences: ^2.2.2`

---

## Arquitectura Actual

```
Flutter App
    ↓
PostgresService (postgres 2.6.0)
    ↓
PostgreSQL Directo (SSL)
    ↓
Supabase Database
```

**Ventajas:**
- ✅ No requiere anon key
- ✅ Conexión directa y rápida
- ✅ Control total con SQL
- ✅ Misma arquitectura que backend Node.js
- ✅ SSL habilitado

---

## Archivos Creados

1. `/lib/config/supabase_config.dart` - Configuración de PostgreSQL
2. `/lib/services/postgres_service.dart` - Servicio de base de datos
3. `/lib/screens/ranking_screen.dart` - Pantalla de ranking
4. `/fonts/SpaceMono-Regular.ttf` - Fuente local
5. `/fonts/SpaceMono-Bold.ttf` - Fuente local
6. `/fonts/LexendMega-Bold.ttf` - Fuente local
7. `/doc/SUPABASE_SETUP.md` - Guía de configuración (obsoleta)
8. `/doc/database_setup.sql` - Script SQL de creación de tablas
9. `assets/musica/M.1.mp3` - Música de fondo para menús
10. `assets/icons/icon.1.png` - Icono de la app

---

## Archivos Modificados

1. `pubspec.yaml` - Dependencias y fuentes
2. `lib/main.dart` - Eliminada init de Supabase, agregada ruta ranking
3. `lib/theme/app_theme.dart` - Fuentes locales
4. `lib/widgets/carta_widget.dart` - Fuentes locales
5. `lib/widgets/partida_list_item.dart` - Fix overflow
6. `lib/screens/home_screen.dart` - Navegación a ranking
7. `lib/models/partida.dart` - Métodos fromJson/toJson
8. `macos/Runner/DebugProfile.entitlements` - Permisos de red
9. `macos/Runner/Release.entitlements` - Permisos de red

---

## Estado Actual del Proyecto

### ✅ Completado:
- Instalación y configuración de Flutter
- Conexión directa a PostgreSQL
- Pantalla de ranking global funcional
- Fuentes locales empaquetadas
- Permisos de red en macOS
- Fix de UI en lista de partidas
- **Modo Claro/Oscuro**
- **Creación y Unión a Partidas (Fix)**
- **Sistema de Rating Elo**
- **Música de Fondo**
- **Feedback Háptico**
- **Sistema de Avatares**
- **Icono de App**

### 🚧 En Progreso:
- Lógica de juego en tiempo real (sincronización de movimientos)

### ⏳ Pendiente:
- Ver plan.md para lista completa de funcionalidades pendientes

---

## Problemas Conocidos y Soluciones

### 1. Google Fonts - Permisos de Red
- **Problema:** Error "Operation not permitted" al descargar fuentes
- **Solución:** Fuentes empaquetadas localmente

### 2. Supabase - Anon Key Requerida
- **Problema:** SDK requiere anon key
- **Solución:** Migración a conexión PostgreSQL directa

### 3. Prepared Statements Duplicados
- **Problema:** Error "prepared statement already exists"
- **Solución:** `allowReuse: false` en todas las queries

### 4. iOS Code Signing
- **Problema:** Error de provisioning profile al compilar para iPhone
- **Solución:** Ejecutar en macOS o simulador iOS

---

## Notas Técnicas

- **Versión de Flutter:** 3.38.3
- **Versión de Dart:** 3.10.1
- **Paquete PostgreSQL:** postgres 2.6.0
- **Base de Datos:** PostgreSQL en Supabase
- **Plataformas Soportadas:** macOS, iOS (con code signing), Android (pendiente configuración)

---
