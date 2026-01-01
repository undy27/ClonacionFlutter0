# Solución para eliminar pausa en loop de M.2.wav

## Problema
El archivo `M.2.wav` tiene una pausa al hacer loop porque contiene silencio al inicio o al final del archivo.

## Soluciones

### Opción 1: Usar ffmpeg (Recomendado)

1. Instalar ffmpeg:
```bash
brew install ffmpeg
```

2. Ejecutar el script de procesamiento:
```bash
chmod +x process_audio.sh
./process_audio.sh
```

3. Reemplazar el archivo original:
```bash
mv src/assets/musica/M.2.processed.wav src/assets/musica/M.2.wav
```

### Opción 2: Usar Audacity (GUI)

1. Descargar e instalar [Audacity](https://www.audacityteam.org/)

2. Abrir `src/assets/musica/M.2.wav` en Audacity

3. Seleccionar todo (Cmd+A)

4. Ir a Effect > Noise Reduction and Repair > Truncate Silence
   - Configurar:
     - Minimum silence duration: 0.1 segundos
     - Threshold: -50 dB
     - Truncate to: 0 segundos

5. Ir a Effect > Noise Reduction and Repair > Normalize
   - Marcar "Remove DC offset"
   - Marcar "Normalize peak amplitude to -1.0 dB"

6. Exportar como WAV:
   - File > Export > Export as WAV
   - Sobrescribir `M.2.wav`

### Opción 3: Usar otro archivo de audio

Si las opciones anteriores son complicadas, considera:
- Usar solo `M.1.mp3` que ya funciona bien en loop
- Encontrar otro archivo de música que no tenga silencio al final
- Convertir `M.2.wav` a MP3 con compresión que elimine el silencio

## Verificación

Después de procesar el archivo, verifica que el loop sea seamless:
1. Abrir la app
2. Triple-tap en "OPCIONES"
3. Seleccionar "MÚSICA 2" en "MÚSICA DE FONDO"
4. Escuchar varios loops para confirmar que no hay pausa

## Notas técnicas

El código de `SoundManager` ya está configurado correctamente con:
- `ReleaseMode.loop` para loop continuo
- `PlayerMode.mediaPlayer` para mejor rendimiento
- `AudioContext` configurado para reproducción en background

El problema es exclusivamente del archivo de audio, no del código.
