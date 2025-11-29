-- =====================================================
-- SCRIPT DE CREACIÓN DE BASE DE DATOS - CLONACIÓN
-- Ejecutar en: Dashboard de Supabase > SQL Editor
-- =====================================================

-- Eliminar tablas si existen (¡CUIDADO! Esto borrará todos los datos)
DROP TABLE IF EXISTS partidas CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;

-- =====================================================
-- TABLA USUARIOS
-- =====================================================
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

-- =====================================================
-- TABLA PARTIDAS
-- =====================================================
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

-- =====================================================
-- ÍNDICES
-- =====================================================
CREATE INDEX idx_partidas_estado ON partidas(estado);
CREATE INDEX idx_usuarios_alias ON usuarios(alias);
CREATE INDEX idx_usuarios_rating ON usuarios(rating DESC);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) - POLÍTICAS DE ACCESO
-- =====================================================

-- Habilitar RLS en las tablas
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE partidas ENABLE ROW LEVEL SECURITY;

-- Políticas para la tabla usuarios
-- Todos pueden leer usuarios (para ranking, récords, etc.)
CREATE POLICY "Usuarios son visibles para todos"
    ON usuarios FOR SELECT
    TO authenticated, anon
    USING (true);

-- Usuarios anónimos pueden insertar (para "Jugar sin registrarse")
CREATE POLICY "Usuarios anónimos pueden crear perfil"
    ON usuarios FOR INSERT
    TO anon
    WITH CHECK (true);

-- Usuarios autenticados pueden actualizar su propio perfil
CREATE POLICY "Usuarios pueden actualizar su propio perfil"
    ON usuarios FOR UPDATE
    TO authenticated
    USING (auth.uid()::text = id);

-- Políticas para la tabla partidas
-- Todos pueden ver las partidas
CREATE POLICY "Partidas son visibles para todos"
    ON partidas FOR SELECT
    TO authenticated, anon
    USING (true);

-- Usuarios pueden crear partidas
CREATE POLICY "Usuarios pueden crear partidas"
    ON partidas FOR INSERT
    TO authenticated, anon
    WITH CHECK (true);

-- El creador puede actualizar su partida
CREATE POLICY "Creador puede actualizar su partida"
    ON partidas FOR UPDATE
    TO authenticated, anon
    USING (auth.uid()::text = creador_id OR true); -- Permitir actualizaciones para juego anónimo

-- =====================================================
-- DATOS DE PRUEBA (OPCIONAL)
-- =====================================================

-- Insertar usuarios de prueba
INSERT INTO usuarios (id, alias, avatar, rating, partidas_jugadas, victorias, derrotas) VALUES
    ('test_user_1', 'JugadorPro', 'default', 1800, 50, 35, 15),
    ('test_user_2', 'MenteMaestra', 'default', 2100, 120, 90, 30),
    ('test_user_3', 'CalcuRápido', 'default', 1650, 30, 18, 12),
    ('test_user_4', 'Novato2024', 'default', 1450, 10, 4, 6);

-- Insertar partidas de prueba
INSERT INTO partidas (id, nombre, creador_id, num_jugadores_objetivo, rating_min, rating_max, estado) VALUES
    ('partida_test_1', 'Partida Rápida', 'test_user_1', 2, 0, 3000, 'esperando'),
    ('partida_test_2', 'Solo Expertos', 'test_user_2', 4, 1800, 3000, 'esperando'),
    ('partida_test_3', 'Principiantes Bienvenidos', 'test_user_3', 3, 0, 1600, 'esperando');

-- =====================================================
-- VERIFICACIÓN
-- =====================================================

-- Verificar que las tablas se crearon correctamente
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('usuarios', 'partidas');

-- Verificar que los índices se crearon
SELECT indexname, tablename 
FROM pg_indexes 
WHERE schemaname = 'public' 
AND tablename IN ('usuarios', 'partidas');

-- Contar registros
SELECT 'usuarios' as tabla, COUNT(*) as registros FROM usuarios
UNION ALL
SELECT 'partidas' as tabla, COUNT(*) as registros FROM partidas;
