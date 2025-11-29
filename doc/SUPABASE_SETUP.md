# Configuración de Supabase

## Obtener la Anon Key

Para que la aplicación funcione correctamente con Supabase, necesitas obtener la **anon key** del proyecto:

### Pasos:

1. **Accede al Dashboard de Supabase:**
   - Ve a: https://app.supabase.com/project/dwrzqqeabgrrornmyyum/settings/api

2. **Encuentra la Anon Key:**
   - En la sección "Project API keys"
   - Busca: "anon" / "public"
   - Copia el valor completo de la clave

3. **Actualiza el archivo de configuración:**
   - Abre: `/src/lib/config/supabase_config.dart`
   - Reemplaza `'YOUR_ANON_KEY_HERE'` con la anon key que copiaste
   
   ```dart
   static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'; // Tu clave aquí
   ```

4. **Reinicia la aplicación:**
   ```bash
   flutter run -d macos
   ```

## Estructura de Base de Datos

La aplicación espera las siguientes tablas en Supabase:

### Tabla `usuarios`
```sql
CREATE TABLE usuarios (
    id VARCHAR(255) PRIMARY KEY,
    alias VARCHAR(100) NOT NULL UNIQUE,
    avatar VARCHAR(255) DEFAULT 'default',
    rating INTEGER DEFAULT 1500,
    partidas_jugadas INTEGER DEFAULT 0,
    victorias INTEGER DEFAULT 0,
    derrotas INTEGER DEFAULT 0,
    mejor_tiempo_victoria INTEGER,
    mejor_tiempo_victoria_2j INTEGER,
    mejor_tiempo_victoria_3j INTEGER,
    mejor_tiempo_victoria_4j INTEGER,
    tema_cartas VARCHAR(20) DEFAULT 'clasico',
    created_at TIMESTAMP DEFAULT NOW()
);
```

### Tabla `partidas`
```sql
CREATE TABLE partidas (
    id VARCHAR(255) PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    creador_id VARCHAR(255) REFERENCES usuarios(id),
    num_jugadores_objetivo INTEGER NOT NULL,
    rating_min INTEGER NOT NULL,
    rating_max INTEGER NOT NULL,
    estado VARCHAR(50) DEFAULT 'esperando',
    ganador_id VARCHAR(255),
    inicio_partida TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### Índices
```sql
CREATE INDEX idx_partidas_estado ON partidas(estado);
CREATE INDEX idx_usuarios_alias ON usuarios(alias);
CREATE INDEX idx_usuarios_rating ON usuarios(rating DESC);
```

## Verificación

Si todo está configurado correctamente:
- ✅ La app debería iniciar sin errores
- ✅ Deberías poder ver la lista de partidas (si existen en la BD)
- ✅ Deberías poder crear nuevas partidas
- ✅ Los datos se sincronizarán con Supabase

## Solución de problemas

### Error: "Invalid API key"
- Verifica que hayas copiado la anon key completa
- Asegúrate de no haber incluido espacios al principio o al final

### Error: "Failed to connect"
- Verifica que la URL del proyecto sea correcta
- Verifica tu conexión a Internet
- Verifica que los entitlements de red estén configurados (ya están)

### La app se cuelga al crear partida
- Verifica que las tablas existan en Supabase
- Verifica que la anon key tenga los permisos correctos
- Revisa los logs de Supabase en el dashboard
