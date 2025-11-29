# Plan de Implementación - Clonación Flutter

## Resumen del Proyecto

Desarrollo de una aplicación Flutter multiplataforma (iOS/Android) para el juego de cartas "Clonación" de Crecer Creando, con backend PostgreSQL (Supabase) y arquitectura cliente-servidor.

---

## Fase 1: Infraestructura y Configuración ✅

### 1.1 Configuración Inicial ✅
- [x] Instalación de Flutter SDK
- [x] Configuración de dependencias base
- [x] Configuración de fuentes locales
- [x] Permisos de red en macOS/iOS

### 1.2 Base de Datos ✅
- [x] Conexión directa a PostgreSQL
- [x] Servicio de base de datos (`postgres_service.dart`)
- [x] Modelos de datos (Usuario, Partida, Carta, Jugador)
- [x] Métodos de serialización (fromJson/toJson)

### 1.3 Arquitectura Base ✅
- [x] Estructura de carpetas
- [x] Provider para manejo de estado
- [x] Tema neo-brutalista
- [x] Navegación con rutas nombradas

---

## Fase 2: Autenticación y Usuarios ⏳

### 2.1 Pantalla de Login/Registro ✅
- [x] Diseño de pantalla de inicio de sesión
- [x] Formulario de registro
- [x] Validación de campos
- [x] Opción "Jugar sin registrarse"
  - [x] Generar ID temporal
  - [x] Crear usuario guest en BD
  - [x] Sin rating ni estadísticas

### 2.2 Gestión de Sesión ✅
- [x] Almacenamiento de sesión (shared_preferences)
- [x] Auto-login si hay sesión activa
- [x] Logout
- [ ] Recuperación de contraseña (opcional)

### 2.3 Perfil de Usuario ❌
- [ ] Pantalla de perfil
- [ ] Mostrar estadísticas
- [ ] Editar avatar (futuro)
- [ ] Cambiar contraseña (futuro)

---

## Fase 3: Menú Principal y Navegación ⏳

### 3.1 Pantalla Principal ✅
- [x] Diseño neo-brutalista
- [x] Título y subtítulo
- [x] Botón "JUGAR"
- [x] Botón "RANKING GLOBAL" ✅
- [ ] Botón "RÉCORDS DE TIEMPO"
- [x] Botón "OPCIONES"
- [x] Botón "CERRAR SESIÓN"

### 3.2 Navegación ⏳
- [x] Ruta a lista de partidas
- [x] Ruta a ranking global ✅
- [ ] Ruta a récords de tiempo
- [x] Ruta a opciones
- [x] Botones de "volver atrás" en todas las pantallas

---

## Fase 4: Sistema de Ranking y Récords ✅

### 4.1 Ranking Global ✅
- [x] Pantalla de ranking ✅
- [x] Carga de datos desde PostgreSQL ✅
- [x] Ordenamiento por rating y victorias ✅
- [x] Diseño especial para top 3 ✅
- [x] Avatares circulares ✅
- [x] Pull-to-refresh ✅

### 4.2 Récords de Tiempo ✅
- [x] Pantalla de récords ✅
- [x] Tabs para 2j, 3j, 4j ✅
- [x] Carga de datos por categoría ✅
- [x] Formato de tiempo (mm:ss) ✅
- [x] Diseño responsive y compactado ✅
- [x] Modo oscuro ✅

### 4.3 Sistema Elo ❌
- [ ] Implementar cálculo de rating Elo
- [ ] K=40 para primeras 30 partidas
- [ ] K=20 a partir de partida 31
- [ ] Actualización de rating post-partida
- [ ] Manejo de partidas multi-jugador (2-4)

---

## Fase 5: Gestión de Partidas ✅

### 5.1 Lista de Partidas ✅
- [x] Pantalla de lista de partidas
- [x] Carga desde PostgreSQL
- [x] Diseño de item de partida
- [x] Fix de overflow ✅
- [x] Actualización automática cada 3 segundos
- [ ] Filtros (por número de jugadores, rating)
- [ ] Indicador de partidas llenas

### 5.2 Crear Partida ✅
- [x] Botón flotante "+"
- [x] Diálogo de creación
  - [x] Nombre de partida
  - [x] Número de jugadores (2-4)
  - [x] Rating mínimo/máximo
  - [x] Validación de campos
- [x] Inserción en BD
- [x] Navegación automática a sala de espera
- [x] Captura correcta de BuildContext para navegación ✅
- [x] Manejo robusto de errores ✅

### 5.3 Unirse a Partida ✅
- [x] Click en partida de la lista
- [x] Verificación de requisitos (rating, espacio)
- [x] Actualización de jugadores en BD
- [x] Navegación a sala de espera

### 5.4 Sala de Espera ✅
- [x] Mostrar jugadores unidos
- [x] Indicador de "esperando jugadores"
- [ ] Botón "Abandonar"
- [x] Inicio automático cuando se completa ✅
- [x] Polling cada 3 segundos para detectar cambios ✅
- [ ] Cuenta atrás antes de iniciar

---

## Fase 6: Lógica del Juego ⏳

### 6.1 Generación de Baraja ✅
- [x] Clase Baraja
- [x] Clase Carta
- [x] Generación de filas superiores (multiplicaciones)
- [x] Generación de filas medias (divisiones)
- [x] Generación de filas inferiores (resultados)
- [x] Corrección de bucle infinito con contador de seguridad ✅
- [x] Estrategia de fallback para restricciones imposibles ✅
- [ ] Validación exhaustiva de restricciones
- [ ] Tests unitarios

### 6.2 Reglas de Descarte ⏳
- [x] Implementación de las 8 reglas
- [x] Validación de match
- [ ] Tests de todas las combinaciones
- [ ] Optimización de performance

### 6.3 Sistema de Cartas ⏳
- [x] Widget de carta (CartaWidget)
- [x] Tema Clásico (grid)
- [x] Tema Moderno (SVG-based)
- [ ] Animaciones de flip
- [ ] Animaciones de descarte
- [ ] Highlight de matches

---

## Fase 7: Pantalla de Juego ⏳

### 7.1 Layout del Tablero ⏳
- [x] Estructura básica
- [x] Fila de información de jugadores
- [x] 4 montones de descarte
- [x] Mano del jugador (5 cartas)
- [x] Mazo restante
- [ ] Responsive design
- [ ] Adaptación a diferentes tamaños de pantalla

### 7.2 Interacción del Usuario ❌
- [ ] Drag & Drop de cartas
  - [ ] Inicio de arrastre
  - [ ] Seguimiento del dedo
  - [ ] Detección de zona de drop
  - [ ] Animación de retorno si inválido
- [ ] Robo de carta del mazo
  - [ ] Tap en mazo
  - [ ] Animación de flip
  - [ ] Colocación en hueco de mano

### 7.3 Validación de Descartes ❌
- [ ] Verificación en cliente
- [ ] Envío a servidor
- [ ] Respuesta del servidor
- [ ] Feedback visual:
  - [ ] Verde si válido (1 segundo)
  - [ ] Rojo + shake si inválido (0.6 segundos)
- [ ] Actualización de estado

### 7.4 Sistema de Penalizaciones ❌
- [ ] Contador de penalizaciones
- [ ] Penalización por descarte incorrecto:
  - [ ] 1er error: 4 segundos
  - [ ] 2do error: 6 segundos
  - [ ] 3er error: Eliminación
- [ ] Cuenta atrás animada
- [ ] Overlay de eliminación

### 7.5 Concurrencia ❌
- [ ] Manejo de descartes simultáneos
- [ ] Validación en servidor (orden de llegada)
- [ ] Halo rojo en montón ocupado
- [ ] Bloqueo temporal de montón
- [ ] Excepción de penalización si match válido

---

## Fase 8: Comunicación en Tiempo Real ❌

### 8.1 WebSockets / Realtime ❌
- [ ] Configuración de canal de partida
- [ ] Suscripción a eventos
- [ ] Broadcast de descartes
- [ ] Sincronización de estado
- [ ] Manejo de desconexiones

### 8.2 Eventos del Juego ❌
- [ ] Jugador se une
- [ ] Jugador abandona
- [ ] Carta descartada
- [ ] Carta robada
- [ ] Jugador eliminado
- [ ] Partida finalizada

---

## Fase 9: Finalización de Partida ❌

### 9.1 Condiciones de Victoria/Derrota ❌
- [ ] Victoria: descartar todas las cartas
- [ ] Derrota: 3 penalizaciones
- [ ] Derrota: abandonar partida
- [ ] Derrota: otro jugador gana

### 9.2 Overlays de Fin de Partida ❌
- [ ] Overlay de eliminación
  - [ ] Fondo rojo semi-transparente
  - [ ] Mensaje "Has sido eliminado"
  - [ ] Click para volver al menú
- [ ] Overlay de victoria
  - [ ] Fondo verde
  - [ ] Mensaje "¡Has ganado!"
  - [ ] Estadísticas de partida
- [ ] Overlay de derrota
  - [ ] Fondo naranja
  - [ ] Mensaje con ganador
  - [ ] Estadísticas

### 9.3 Actualización de Estadísticas ❌
- [ ] Cálculo de nuevo rating Elo
- [ ] Actualización de victorias/derrotas
- [ ] Actualización de mejor tiempo
- [ ] Guardado en BD
- [ ] Sincronización con todos los jugadores

---

## Fase 10: Opciones y Configuración ✅

### 10.1 Pantalla de Opciones ✅
- [x] Diseño de pantalla
- [x] Navegación desde menú principal

### 10.2 Selección de Tema de Cartas ✅
- [x] Vista previa de tema Clásico
- [x] Vista previa de tema Moderno
- [x] Selección y guardado
- [ ] Actualización en BD
- [x] Aplicación inmediata (guardado en SharedPreferences)

### 10.3 Modo Claro/Oscuro ✅
- [x] Toggle en opciones
- [x] Tema oscuro definido
- [x] Persistencia en SharedPreferences
- [x] Aplicación dinámica en toda la app
- [x] Persistencia en BD (Usuario) ✅

### 10.4 Configuración de Sonidos ⏳
- [x] Sonidos básicos (click/pop) ✅
- [ ] Toggle de sonidos
- [ ] Control de volumen
- [ ] Guardado de preferencias

### 10.5 Cambio de Contraseña ❌ (Futuro)
- [ ] Formulario de cambio
- [ ] Validación de contraseña actual
- [ ] Actualización en BD

### 10.6 Selección de Avatar ❌ (Futuro)
- [ ] Galería de avatares
- [ ] Selección y guardado
- [ ] Actualización en BD

---

## Fase 11: Sistema de Sonidos ⏳

### 11.1 Sonidos Básicos ✅
- [x] Sonido "pop" en menús ✅
- [ ] Sonido de descarte válido
- [ ] Sonido de descarte inválido
- [ ] Sonido de robo de carta

### 11.2 Sonidos de Eventos ❌ (Futuro)
- [ ] Inicio de partida
- [ ] Victoria
- [ ] Derrota
- [ ] Reparto de cartas
- [ ] Cuenta atrás

---

## Fase 12: Logging y Debugging ⏳

### 12.1 Logging en Cliente ⏳
- [x] Logs de conexión a BD
- [x] Logs de errores
- [ ] Logs de acciones del usuario
- [ ] Timestamp en formato Madrid
- [ ] Tag de plataforma [iOS]/[Android]
- [ ] Guardado en archivo local
- [ ] Limpieza al iniciar nueva partida

### 12.2 Logging en Servidor ❌
- [ ] Logs de todas las operaciones
- [ ] Timestamp, jugador, acción
- [ ] Almacenamiento en BD o archivo

---

## Fase 13: Testing y QA ❌

### 13.1 Tests Unitarios ❌
- [ ] Tests de generación de baraja
- [ ] Tests de reglas de descarte
- [ ] Tests de cálculo Elo
- [ ] Tests de modelos

### 13.2 Tests de Integración ❌
- [ ] Tests de flujo de partida completo
- [ ] Tests de concurrencia
- [ ] Tests de sincronización

### 13.3 Tests de UI ❌
- [ ] Tests de navegación
- [ ] Tests de formularios
- [ ] Tests de responsive design

---

## Fase 14: Optimización y Pulido ❌

### 14.1 Performance ❌
- [ ] Optimización de queries SQL
- [ ] Caché de datos frecuentes
- [ ] Lazy loading de imágenes
- [ ] Reducción de rebuilds

### 14.2 UX/UI ❌
- [ ] Animaciones suaves
- [ ] Transiciones entre pantallas
- [ ] Feedback táctil (haptics)
- [ ] Indicadores de carga
- [ ] Mensajes de error amigables

### 14.3 Accesibilidad ❌
- [ ] Soporte para lectores de pantalla
- [ ] Contraste de colores
- [ ] Tamaños de fuente ajustables
- [ ] Navegación por teclado (desktop)

---

## Fase 15: Deployment ❌

### 15.1 Preparación ❌
- [ ] Configuración de code signing (iOS)
- [ ] Configuración de keystore (Android)
- [ ] Iconos de app
- [ ] Splash screens
- [ ] Metadatos de stores

### 15.2 Publicación ❌
- [ ] Build de release iOS
- [ ] Build de release Android
- [ ] TestFlight (iOS)
- [ ] Google Play Internal Testing
- [ ] Revisión y correcciones
- [ ] Publicación final

---

## Progreso General

### Completado: ~50%
- ✅ Infraestructura base
- ✅ Conexión a BD
- ✅ Ranking global y Récords
- ✅ Modelos de datos
- ✅ Tema visual y Modo Oscuro (Persistente)
- ✅ Autenticación básica
- ✅ Opciones y Sonidos básicos
- ✅ **Gestión completa de partidas (Crear/Unirse/Sala de Espera)** ✨
- ✅ **Generación de baraja con fallback** ✨

### En Progreso: ~10%
- ⏳ Pantalla de juego (layout completo, falta interacción)
- ⏳ Lógica de validación en servidor

### Pendiente: ~40%
- ❌ Tiempo real (WebSockets)
- ❌ Drag & Drop de cartas
- ❌ Sistema de penalizaciones
- ❌ Condiciones de victoria
- ❌ Sonidos de juego avanzados
- ❌ Testing
- ❌ Deployment

---

## Prioridades Inmediatas

1.  **Interacción básica** - Drag & drop de cartas
2.  **Validación de descartes** - Cliente + servidor
3.  **Tiempo real** - WebSockets/Realtime
4.  **Sistema de Penalizaciones**
5.  **Condiciones de Victoria/Derrota**

---

## Notas de Implementación

### Decisiones Técnicas:
- **Base de datos:** PostgreSQL directo (sin SDK Supabase)
- **Estado:** Provider pattern
- **Navegación:** Named routes
- **Fuentes:** Empaquetadas localmente
- **Tema:** Neo-brutalista con colores vibrantes
- **Modo Oscuro:** Implementado con ThemeProvider y persistencia en BD
- **Sonidos:** SystemSound para feedback háptico/auditivo básico

### Consideraciones:
- Priorizar funcionalidad sobre estética en primeras fases
- Testing continuo de reglas de descarte
- Optimización de queries desde el inicio
- Documentación de decisiones importantes

---

## Recursos Necesarios

- [ ] Assets de sonido (para eventos específicos)
- [ ] Iconos de app (iOS/Android)
- [ ] Splash screens
- [ ] Avatares de usuario
- [ ] Documentación de API
- [ ] Guía de usuario

---

**Última actualización:** 2025-11-29
**Versión del plan:** 1.3
