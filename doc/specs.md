# Contexto y objetivo

    * El proyecto consiste en desarrollar una variante digital de Clonación, de Crecer Creando, un juego de cartas multijugador de cálculo mental y atención

# Mecánica del juego

## Características básicas del juego

    * Número de jugadores: 2 a 4
    * Número de cartas en la baraja: 52
    * Número de montones de descarte: 4
    * Mano inicial de cada jugador: 5 cartas
    * Mazo restante inicial de cada jugador: 19, 11 o 7 cartas (2, 3 o 4 jugadores)
    * Final de partida y ganador: gana el juego el jugador que se queda sin cartas

## Desarrollo de la partida

    * Se crea una baraja aleatoria de 52 cartas
    * Se reparten aleatoriamente 48 cartas entre todos los jugadores, boca abajo
    * Las 4 cartas restantes se disponen boca arriba en el tablero, conformando los 4 montones de descartes iniciales
    * Tras una cuenta atrás, se disponen boca arriba 5 cartas de cada jugador, que serán sus manos iniciales
    * En cualquier momento (no hay turnos de juego), cada jugador podrá descartar una carta de su mano visible sobre alguno de los 4 montones de descarte, siempre que su carta y la carta visible del montón cumplan las reglas de descarte
    * La carta descartada pasará a ser la nueva carta visible del montón de descarte
    * Tras el descarte de una carta, si al jugador todavía le quedara alguna carta boca abajo, se pondrá boca arriba la primera de ellas y pasará a formar parte de su mano
    * En el momento en que un jugador se queda sin cartas, se declara ganador y finaliza la partida


## Estructura de cada carta

Cada carta presenta información dispuesta en 3 filas: fila superior, fila del medio, fila inferior

    * Fila superior: Incluye una tripla de 3 pares ordenados, que representan en el juego 3 operaciones de multiplicación. Cada elemento del par ordenado es un número natural del 0 al 10.
    * Fila del medio: Incluye un par ordenado (i,j) que representa en el juego la división exacta i/j. i es un número natural entre 1 y 81, j es un número natural entre 1 y 9, con las restricciones de que i debe ser divisible exactamente por j (i mod j = 0) y que el cociente i/j debe ser un número natural entre 1 y 9.
    * Fila inferior: Incluye una tripla de números naturales del 0 al 99, que representan en el juego resultados de multiplicaciones
        
## Generación de la baraja

Antes del inicio de cada partida, el sistema generará una nueva baraja de juego

    * Filas superiores
        - Se crearán 110 pares ordenados de números que representan todas las combinaciones sin repetición de los números naturales del 0 al 10, tomados de 2 en 2; y exceptuando el par (10,10) y los pares (0,x) y (x,0) tales que x es impar. En total son 109 pares distintos (el orden importa).
        - Se crearán 46 pares ordenados de números aleatorios naturales del 0 al 10, con distribución uniforme, excluyendo el par (10,10) y los pares (0,x) y (x,0) tales que x es impar, y con la restricción adicional de que el producto de los dos elementos de cada par ordenado no coincida con el producto de los dos elementos de cualquiera de los otros 45 pares ordenados. Estos 46 pares ya se han generado anteriormente, por lo que estarán repetidos; su objetivo es aumentar la variabilidad de la baraja y la frecuencia de coincidencias durante la partida
        - Se reparten los 156 pares ordenados creados entre todas las cartas (3 pares ordenados para cada carta), asignándolos a la fila superior
        - La asignación se hará de forma aleatoria, con la restricción de que en una misma carta no coincidan dos pares ordenados que tengan los mismos dos elementos, en el mismo orden o con el orden cambiado
        - Ejemplo de fila superior: (3,2), (4,6), (5,5). Los pares ordenados representan las multiplicaciones 3x2, 4x6 y 5x5

    * Filas del medio
        - Se generan todos los pares ordenados (i,j) tales que cumplen todas estas reglas:
            * i es un número natural entre 1 y 81
            * j es un número natural entre 1 y 9
            * i/j tiene es una división exacta (es decir, tiene resto 0)
            * i/j es un número natural entre 1 y 9
        - De esos pares ordenados, se seleccionan aleatoriamente 52 de ellos y se asignan a cada carta de la baraja
        - Cada par (i,j) representa la división exacta i/j en el juego.
        - Ejemplo de fila media: (12,3). El par ordenado representa la división 12/3 (que resulta en 4)

    * Filas inferiores
        - Se creará una sublista de 42 elementos con todos los posibles resultados de multiplicar entre sí los números naturales del 0 al 10, excepto la multiplicación 10x10
        - Se creará una lista concatenando 4 veces la sublista
        - De esa lista concatenada de 168 elementos, se eliminarán 12 números escogidos al azar, con la restricción de que no se elimine el mismo número más de una vez
        - La lista final contiene 156 elementos, a cada carta se le asignarán 3 de ellos a la tripla de la fila inferior, de forma aleatoria y con la restricción de que no se le asigne a una misma carta 2 veces el mismo número
        - Ejemplo de fila inferior: 4, 10, 0. Representan resultados de multiplicaciones (por ejemplo, 2x2, 5x2, 0x3)


## Reglas de descarte

    1. El jugador podrá descartar una carta si hace match con alguna de las cartas de alguno de los 4 montones de descarte. Llamamos CartaMano a una carta en la mano visible del jugador. Llamamos CartaMontonDescarte a la carta visible en uno de los montones de descarte. El jugador puede descartar CartaMano sobre CartaMontonDescarte si se cumple alguna de estas condiciones:
        * En la fila superior de CartaMano hay una par ordenado (i,j) y en la fila superior de CartaMontonDescarte hay una par ordenado (x,y) tales que (i*j=x*y) AND (i,j)<>(x,y) AND (i,j)<>(y,x).
        * En la fila superior de CartaMano hay un par ordenado (i,j) y en la fila del medio de CartaMontonDescarte hay un par ordenado (m,n) tales que i*j=m/n (donde m/n es la división exacta)
        * En la fila superior de CartaMano hay un par ordenado (i,j) y en la fila inferior de CartaMontonDescarte hay un resultado z tales que i*j=z
        * En la fila superior de CartaMontonDescarte hay una pareja (i,j) y en la fila inferior de CartaMano hay un resultado z tales que i*j=z
        * En la fila del medio de CartaMano hay un par ordenado (m,n) (que representa m/n) y en la fila superior de CartaMontonDescarte hay un par ordenado (i,j) tales que i*j=m/n
        * En la fila del medio de CartaMano hay un par ordenado (m,n) (que representa m/n) y en la fila inferior de CartaMontonDescarte hay un resultado z tales que m/n=z
        * En la fila del medio de CartaMontonDescarte hay un par ordenado (m,n) (que representa m/n) y en la fila inferior de CartaMano hay un resultado z tales que m/n=z
        * En la fila del medio de CartaMano hay un par ordenado (m,n) (que representa m/n) y en la fila del medio de CartaMontonDescarte hay un par ordenado (i,j) tales que m/n=i/j


# Aspectos tecnológicos

## Stack tecnológico
    * Plataformas cliente: iOS y Android
    * Frontend: Flutter
    * Base de datos: Supabase
        - DATABASE_URL=postgresql://postgres.dwrzqqeabgrrornmyyum:ClonBD1111A4@aws-1-eu-west-1.pooler.supabase.com:6543/postgres

## Logging
    * Todas las operaciones en el servidor se registrarán en un fichero de log, indicando timestamp, jugador y acción
    * Las operaciones del cliente también se registrarán en un fichero de log
    * El fichero de log en los clientes se eliminará al empezar una nueva partida

## Arquitectura del código

### Clases
        
Como mínimo, se definirán las siguientes clases:

    * Usuario        
    * Baraja
    * Jugador
    * Carta
        El sistema dará soporte a distintos estilos visuales de cartas, que podrá seleccionar el usuario en el menú de Opciones. De momento implementaremos dos:
            - Tema Clásico:
                Diseño tipo grid con líneas divisorias:
                    1. Diseño visual: La carta utiliza un layout de CSS Grid 3×3 con las siguientes características:
                        - Padding uniforme de 5px en todos los bordes
                        - Línea divisoria horizontal a 2/3 de altura (ancho completo) separando resultados de operaciones
                        - Línea divisoria horizontal a 1/3 de altura (medio ancho) separando primera y segunda fila
                        - Línea divisoria vertical a 1/2 de ancho (altura 1/3) dividiendo el tercio medio
                        - Todas las líneas de 1-2px de grosor, color #333
                    2. Zona superior de la carta (filas 1 del grid):
                        - Primera multiplicación en columna 1, alineada a la izquierda
                        - Segunda multiplicación en columnas 2-3 (spanning), alineada a la derecha
                        - Los elementos de los pares se muestran separados por el signo "×" de multiplicación
                    3. Zona media de la carta (fila 2 del grid):
                        - División en columna 1, alineada a la izquierda
                        - El par ordenado (i,j) se muestra con símbolo de división ":"
                        - Tercera multiplicación en columnas 2-3 (spanning), alineada a la derecha
                    4. Zona inferior de la carta (fila 3 del grid):
                        - Los 3 resultados distribuidos horizontalmente con space-between
                        - Primer resultado pegado al borde izquierdo, último al derecho, medio centrado
                        - Padding superior adicional de 5px para centrado vertical dentro del tercio
                    5. Fuentes:
                        - El color de la fuente será negro
                        - Todas las fuentes (multiplicaciones, división y resultados) tendrán el mismo tamaño
                        - El tamaño de la fuente dependerá del tamaño de la carta
                        - El tamaño de la fuente intentará aprovechar al máximo el espacio que tenga disponible, sin desbordar la zona que tenga asignada

            - Tema Moderno (por defecto):
                - Diseño basado en el fichero SVG /assets/Carta2.svg.
                - El tamaño de la carta dependerá del tamaño de la pantalla del cliente
                - El color de la fuente será blanco
                - Las multiplicaciones estarán contenidas en los círculos interconectados azul oscuro
                - La división estará contenida en el círculo verde
                - Los resultados estarán contenidos en la zona inferior azul claro
                - Todas las fuentes (multiplicaciones, división y resultados) tendrán el mismo tamaño
                - El tamaño de la fuente dependerá del tamaño de la carta
                - Las operaciones estarán centradas dentro de la zona que las contiene, tanto horizontal como verticalmente
                - Teniendo en cuenta que la operación que ocupa más espacio es 10x10, el tamaño de la fuente será tal que la operación 10x10 quepa en uno de los círculos verdes interconectados, dejando un margen de 3 píxeles a izquierda y derecha
                - La división se indicará con el signo ":"
                - La multiplicación se indicará con el signo "×"

## Arquitectura de la base de datos

### Tabla usuarios
    Atributos:
        id : VARCHAR(255) PRIMARY KEY
        alias : VARCHAR(100) NOT NULL UNIQUE
        avatar : VARCHAR(255) DEFAULT 'default'
        rating : INTEGER DEFAULT 1500
        partidas_jugadas : INTEGER DEFAULT 0
        victorias : INTEGER DEFAULT 0
        derrotas : INTEGER DEFAULT 0
        mejor_tiempo_victoria : INTEGER
        mejor_tiempo_victoria_2j : INTEGER
        mejor_tiempo_victoria_3j : INTEGER
        mejor_tiempo_victoria_4j : INTEGER
        tema_cartas : VARCHAR(20) DEFAULT 'clasico'
        created_at : TIMESTAMP DEFAULT NOW()

### Tabla partidas
    Atributos:
        id : VARCHAR(255) PRIMARY KEY
        nombre : VARCHAR(255) NOT NULL
        creador_id : VARCHAR(255) REFERENCES usuarios(id)
        num_jugadores_objetivo : INTEGER NOT NULL
        rating_min : INTEGER NOT NULL
        rating_max : INTEGER NOT NULL
        estado : VARCHAR(50) DEFAULT 'esperando'
        ganador_id : VARCHAR(255)
        inicio_partida : TIMESTAMP
        created_at : TIMESTAMP DEFAULT NOW()

### Tabla avatares
    No implementar todavía

### Índices relevantes
    idx_partidas_estado ON partidas(estado)
    idx_usuarios_alias ON usuarios(alias)
    idx_usuarios_rating ON usuarios(rating DESC)

# Interfaz y casos de uso

## Reglas de diseño y estilo de interfaz
    * Estilo neo-brutalista
    * Extremadamente creativa, tanto como sea posible
    * Animaciones suaves
    * Páginas y botones coloridos
    * Tailwind CSS styles
    * Interfaz responsive
    * Titulo de la app: Clonación
    * Subtítulo de la app: Multiplica tu mente


## Menú de inicio de sesión/registro
    * Usuario
    * Password
    * Jugar sin registrarse
        Con esta opción, el usuario podrá jugar una partida simplemente introduciendo un nombre de usuario (que se mostrará a los otros jugadores durante el juego), sin contraseña. No tendrá rating Elo ni estadísticas de partidas ganadas/perdidas. Tampoco aparecerá en las tablas de ranking ni récords de tiempo.
    * Iniciar sesión
        Con esta opción, el usuario podrá iniciar sesión con su nombre de usuario y contraseña
    * Registro
        Con esta opción, el usuario podrá registrarse con un nombre de usuario y contraseña. De esta forma, tendrá un rating y estadísticas de partidas ganadas/perdidas. También aparecerá en las tablas de ranking y récords de tiempo.

## Menú principal
    Dentro de cada una de las siguientes opciones y de sus subopciones, habrá un botón con un signo de vuelta atrás, para volver al menú anterior
    * Jugar
        * Muestra las partidas creadas. Para cada partida se muestra esta información:
            - Creador de la partida
            - Nombre de la partida
            - Número de jugadores anotados / Número de jugadores objetivo
            - Rating medio de los jugadores unidos hasta el momento
        * Aspecto visual de la tabla de partidas creadas:
            - Diseño responsive adaptado a móviles y escritorio
            - Modo oscuro según preferencias del sistema
            - Filas alternadas con colores diferentes
            - Efecto hover en las filas
            - Bordes redondeados y sombras
            - Columnas optimizadas para diferentes tamaños de pantalla
            - Actualización automática cada 3 segundos 
        * Permite crear una nueva partida. El usuario deberá indicar el número de jugadores objetivo, el intervalo de rating admitido (entre 0 y 3000, por defecto) y el nombre de la partida
        * Número de jugadores objetivo=Número de jugadores anotados
    * Ranking global
        Se mostrará en una tabla:
            - Nombre del jugador
            - Posición en el ranking
                La posición en el ranking será en base al rating Elo, de mayor a menor, y, en caso de empate, por el número de victorias
            - Rating Elo
            - Partidas ganadas y perdidas
        
    * Récords de tiempo
        * Se muestran los récords de tiempo, desglosados en partidas de 2, 3 y 4 jugadores
        * Presentación visual:
            - Tablas independientes para cada categoría (2j, 3j, 4j)
            - Encabezado integrado en la tabla: primera fila con colspan={4} mostrando "2 Jugadores", "3 Jugadores" o "4 Jugadores"
            - Fondo destacado en encabezado: azul claro (#e3f2fd) en modo claro, gris oscuro (#333333) en modo oscuro
            - Texto del encabezado: centrado, tamaño 18px (móvil) / 24px (desktop), color azul (#1976d2)
            - Columnas: Posición, Jugador (con avatar circular), Tiempo (formato mm:ss), Wins
            - Diseño responsive adaptado a móviles y escritorio
            - Modo oscuro según preferencias del sistema
    * Opciones
        - Estilo de carta
            Se mostrará un ejemplo de carta para cada tema, el usuario seleccionará uno de ellos
            - Tema Clásico
            - Tema Moderno
        - Sonidos
            No implementar todavía
        - Modificar contraseña
            No implementar todavía
        - Avatar
            No implementar todavía
    * Cerrar sesión

## Competición

    * Se ha establecido un sistema de rating de tipo Elo, análogo al usado en ajedrez FIDE, pero adaptado para 2, 3 o 4 jugadores de la siguiente manera: al finalizar la partida, consideramos que el ganador ha jugado varias partidas distintas, una con cada uno de los perdedores. Por ejemplo, en el caso de partidas de 4 jugadores, ajustamos el rating del ganador 3 veces en base a su rating y el rating de sus rivales, considerando que ha conseguido 3 "victorias". En el caso de los perdedores, consideraremos que han obtenido una única derrota (contra el ganador), ajustando su nuevo rating en base a su antiguo rating y el antiguo rating del ganador
    * Se utilizará un K=40 (hasta 30 partidas) y K=20 (a partir de la 31)
    * Cada jugador partirá de una puntuación Elo inicial de 1500 puntos
    * Al finalizar cada partida se actualizará el rating de cada jugador en base a su resultado en la partida

## Juego

    * El aspecto visual del tablero de juego será este:
        - Fila superior (1)
            * Muestra la información de los jugadores en la partida, en disposición horizontal
                - Nombre del jugador
                - Cartas que ha descartado en la partida
                - Número de penalizaciones por descarte incorrecto
            * Muestra un botón de Abandonar
        - Fila 2: muestra los 2 primeros montones de descartes
        - Fila 3: muestra los 2 últimos montones de descartes
        - Fila 4: muestra las 3 primeras cartas de la mano del jugador
        - Fila 5: muestra las 2 últimas cartas de la mano del jugador y, separado un poco de la última carta de la mano, el mazo restante del jugador (mostrando el reverso de la carta superior)

    * El tamaño de las cartas será el máximo posible que permita la disposición señalada anteriormente y el tamaño de la pantalla, dejando márgenes mínimos por arriba, abajo, izquierda y derecha
    
    * Descartes del jugador usuario
        - Para descartar una carta, el jugador deberá pulsar sobre el mazo restante y arrastrarla hacia uno de los montones de descarte
        - El descarte finaliza cuando el jugador suelta la carta en una posición cercana a algún montón de descartes
        - Si no la suelta sobre una posición próxima al montón de descartes, la carta volverá a la mano del jugador
        - Durante el arrastre, la carta acompañará al dedo del jugador en toda la trayectoria
        - Después del descarte, en la posición de la mano en la que estaba la carta descartada, permanecerá un hueco hasta que el jugador robe una carta y la deposite en el hueco
        - Si el descarte es válido según las reglas de descarte: se destacarán las operaciones o resultados que emparejen con la carta superior del montón de descartes en verde durante 1 segundo
        - Si el descarte es inválido según las reglas de descarte: - La carta descartada "tiembla" durante 0.6 segundos, y se emite un sonido de descarte incorrecto durante ese tiempo. Después, la carta retorna a su posición original
        - Si el descarte es incorrecto, se incrementará en 1 el contador de penalizaciones por descarte incorrecto
        - Finalizado un descarte válido, el jugador podrá realizar un nuevo descarte
        - Finalizado un descarte inválido, el jugador podrá realizar un nuevo descarte cuando finalice el tiempo de penalización. Ese tiempo será de 4 segundos la primera vez, 6 segundos la segunda vez, 8 segundos la tercera vez. Esta penalización no se hará efectiva en un caso excepcional, que se expone en el apartado de "Concurrencia"
        - Durante la penalización por descarte incorrecto, se mostrará una cuenta atrás animada en el centro de la pantalla indicando los segundos de penalización restantes. Por ejemplo, para una penalización de 4 segundos, los mensajes son: "¡Descarte no válido!" (1 segundo), "3" (1 segundo), "2" (1 segundo), "1" (1 segundo), "¡Go!" (1 segundo)
            - El primer mensaje se muestra con fondo rojo y texto estático
            - Los mensajes numéricos y "¡Go!" se muestran con animación de difuminado y escala creciente (fadeInScale), con fondo verde
            - Cada mensaje permanece visible durante un segundo completo
            - Sistema de re-renderizado: Cada número de la cuenta atrás fuerza un nuevo renderizado mediante incremento de clave única para garantizar que la animación se reproduce en cada cambio
            - La cuenta atrás no se muestra si el descarte incorrecto es el tercero (el jugador es eliminado directamente)

    * Descarte de un jugador rival
        * La carta superior del montón de descartes correspondiente se rodea de un halo rojo durante 1 segundo, y el jugador usuario no podrá descartar sobre ese montón

    * Concurrencia en los descartes. El sistema debe considerar que dos o más jugadores pueden hacer un descarte sobre el mismo mazo casi simultáneamente. El comportamiento de servidor y clientes será el siguiente:
        - La determinación de la validez del descarte la hace el servidor, no los clientes
        - El servidor atenderá las peticiones por orden de llegada al servidor, no por orden de salida de los clientes
        - El servidor considerará como único descarte válido el primero, ya que, aunque el descarte de los siguientes jugadores podría ser válido con respecto a la nueva carta enviada por el primero de ellos, sería un descarte válido de casualidad, que no sería justo tener en cuenta
        - Sin embargo, tampoco sería justo penalizar ese caso, ya que el jugador probablemente no haya hecho la jugada con "mala intención", por lo que no se le aplicará la penalización de cuatro segundos, siempre y cuando su descarte fuese válido en el momento en que inició el descarte
        - Para que el servidor pueda distinguir esa última situación, en la comunicación cliente a servidor, el cliente enviará no solo la carta y el montón de descarte, sino también la información de si había match o no en el momento en que inició el descarte (desde el punto de vista del cliente)

    * Robo de carta
        * El jugador selecciona una carta de su mazo restante, pulsando sobre ella un breve lapso de tiempo, y la arrastra hacia el hueco que tenga libre en su mano
        * Al depositarla en el hueco, la carta gira sobre sí misma, mostrando la cara superior

    * Derrota
        Un jugador pierde la partida si se da uno de estos supuestos:
            - Abandona la partida: si el jugador pulsa el botón de Abandonar, automáticamente pierde la partida y regresa al menú principal
            - Algún otro jugador gana la partida
            - Derrota por máximo de penalizaciones: si el jugador hace más de 3 descartes incorrectos, automáticamente pierde la partida. El jugador eliminado ve un overlay permanente con el mensaje "Has sido eliminado" que le permite seguir visualizando la partida pero sin poder jugar. Puede hacer clic en cualquier lugar del overlay para volver al menú principal. Si la partida finaliza, este overlay se reemplaza por el overlay de finalización de partida. Detalles del overlay de eliminación:
                * Cuándo aparece: Cuando el jugador acumula 3 descartes incorrectos
                * Estilo visual:
                    - Fondo semi-transparente rojo oscuro (rgba(139, 0, 0, 0.95))
                    - Efecto de desenfoque (backdrop-filter: blur(5px))
                    - z-index: 10001 (superior a otros elementos del juego)
                    - Bordes redondeados (border-radius: 20px)
                    - Sombra pronunciada para destacar del fondo
                * Contenido:
                    - Título principal: "Has sido eliminado" (texto blanco, tamaño grande)
                    - Subtítulo: "Haz clic en cualquier lugar para volver al menú" (texto gris claro, tamaño menor)
                * Comportamiento:
                    - Permanente hasta que el jugador haga clic o la partida finalice
                    - Click en cualquier lugar del overlay → vuelve inmediatamente al menú principal
                    - El jugador puede seguir viendo la partida pero no puede interactuar con las cartas
                    - Si la partida termina, este overlay se reemplaza por el overlay de finalización
                * Prioridad: Se oculta automáticamente si `partidaFinalizada === true` para dar prioridad al mensaje de fin de partida

    * Victoria
        Un jugador gana la partida cuando ha descartado todas sus cartas o cuando el resto de jugadores han perdido por abandonar la partida o por alcanzar el máximo de penalizaciones

    * Finalización de partida
        - La partida finaliza en alguno de los siguientes supuestos:
            * No hay actividad durante 5 minutos
            * Uno de los jugadores gana la partida
        - Overlay de finalización de partida
            * Cuándo aparece: Cuando la partida termina (un jugador gana o todos excepto uno son eliminados)
            * Tipos de overlay:
                - Victoria (jugador ganador):
                    - Fondo semi-transparente verde (rgba(76, 175, 80, 0.95))
                    - Título: "¡Has ganado la partida!"
                - Derrota (jugadores no ganadores):
                    - Fondo semi-transparente naranja (rgba(255, 152, 0, 0.95))
                    - Título: "El jugador [X] ha ganado la partida", siendo [X] el nombre de usuario del jugador que ha ganado
            * Estilo visual común:
                - Efecto de desenfoque (backdrop-filter: blur(5px))
                - z-index: 10002 (superior al overlay de eliminación)
                - Bordes redondeados (border-radius: 20px)
                - Sombra pronunciada para destacar del fondo
            * Contenido común:
                - Subtítulo: "Haz clic en cualquier lugar para volver al menú" (texto gris claro)
            * Comportamiento:
                - Click en cualquier lugar → vuelve inmediatamente al menú principal
                - Auto-redirección al menú después de 3 segundos si no hay interacción
                - Reemplaza cualquier otro overlay visible (incluido el de eliminación)
                - Limpia automáticamente todas las animaciones y estados pendientes

## Sonidos
    * Durante la pulsación de alguna opción de menú: sonido tipo "pop"
    * Al depositar una carta en el mazo de descartes: no implementar todavía
    * Al depositar una carta en la mano: no implementar todavía
    * Al iniciar la partida: no implementar todavía
    * Victoria: no implementar todavía
    * Derrota: no implementar todavía
    * Reparto de cartas: no implementar todavía



