# Método TWC de reconstrucción de exteriores SNES — para reutilizar en futuros juegos y GPT personalizado

## Regla de éxito

**INSPECCIONAR → DETECTAR → CORREGIR → GENERAR → INTEGRAR → CAPTURAR → EXAMINAR → PROBAR → CORREGIR → VALIDAR.**

Este archivo recoge el método real empleado en Capítulo 1, Estafeta RC7, Ayuntamiento RC7 y Plaza del Castillo/Quiosco RC7. Es conocimiento transferible a un GPT creador de videojuegos de fantasía, ciencia ficción o cualquier temática; no depende de Pamplona ni de nombres de personajes.

### Proteger el motor existente

- Identificar índice real del escenario mediante `chapterNames` y `chapterScenes`, las claves `images['scene_$stage']`, `mid_$stage`, `ground_$stage` y la geometría del motor.
- Cambiar solo un escenario; preservar héroes, daño, colisiones, físicas, enemigos, otros niveles y mapas no relacionados.
- Arquitectura y objetos físicos a desplazamiento **1:1**: pantalla `x = worldX - cameraX`. Parallax exclusivamente en planos de fondo verdaderamente lejanos.
- Mantener `groundY` del juego para integrar los pies de los personajes.
- Nunca dibujar imágenes de vista completa duplicadas sobre el fondo nuevo; cuando se aprueba un arte, dejar de cargar recursos `scene_$stage` y `mid_$stage` obsoletos de ese capítulo.

### Transferencia de binarios ya resuelta

1. Componer arte continuo y extraer paneles de geometría fija; generar manifiesto con SHA256 de cada panel, `tile_count`, `tile_width`, `tile_height`, `world_width`, ubicación del hito único y SHA de maestro.
2. Empaquetar `assets/images/<capitulo_rc7>/...` en ZIP y verificar localmente integridad y SHA exacto del archivo.
3. Si el conector no transfiere binarios, crear `qa/<capitulo>_inbox/` y un workflow de GitHub Actions que se active **solo cuando se suba el ZIP**. Si falla el enlace, generar otra copia con nombre actualizado tanto en ZIP como en workflow, sin cambiar contenido ni SHA.
4. En GitHub, comprobar el SHA del ZIP **que se subió realmente** antes de importarlo; un hash mal copiado hizo fallar Ayuntamiento inicialmente.
5. Validar ZIP y todos sus archivos **antes** de escribir destinos. Declarar nuevo directorio en `pubspec.yaml`.
6. CI sin APK: `flutter analyze --no-pub lib`, contrato del nivel, 18 capturas genuinas de `StagePainter` en 800×450, 975×450 y 1000×450, 38 uniones si existen 39 paneles, seis comprobaciones de cámara desplazada +60, pruebas de regresión de niveles anteriores. Guardar evidencia raster auténtica en `qa/`.
7. Solo activar por defecto una vez que el importador, los recursos y las capturas de compilación normal estén verificados. Asegurar que ni siquiera un antiguo `--dart-define=...false` pueda ocultarlo.
8. Registrar URL de cada ejecución y commit; **no generar APK ni fusionar PR sin orden expresa**.

### La lección artística crítica de Quiosco RC7

**PASAR TODOS LOS TESTS NO SIGNIFICA APROBACIÓN ARTÍSTICA.** Un mundo de 37.440 px formado por unos 163 tramos de fachada derivados de solo **11 recortes únicos** tiene una densidad de repetición inaceptable para un exterior ambicioso, aunque una IA lo declare «terminado», las capturas existan y el motor lo renderice correctamente.

- No recortar fragmentos aleatorios que terminan en mitad de un edificio: provocan encuentros de fachadas, tejados y árboles físicamente imposibles.
- El quiosco de música debe aparecer una sola vez, sin escaleras o decoración del propio monumento repetidas fuera de su escena.
- Diseñar primero edificios/sectores completos, luego dividir con puntos de corte que respeten la arquitectura. Mantener una cantidad suficiente de arte original por tramo antes de construir recorridos largos.
- Revisar **todas las uniones visualmente**, no únicamente por número y dimensiones. Comparar inicio, centro, hito y final en fotogramas reales.
- No confundir «arte candidato», «integrado y probado», «listo para RC de prueba» y «arte definitivo aprobado». Esos estados deben indicarse por separado, con evidencia.
- Nunca utilizar montajes generativos de gameplay, paneles de estado o infografías como supuestas capturas reales de Flutter.

## Aplicación al futuro GPT especializado

El GPT futuro debe usar este documento como norma de ejecución y anexar su configuración, recursos aprobados, ejemplos, pruebas y flujos al repositorio. ChatGPT no garantiza que un GPT futuro lea automáticamente memoria de conversaciones; la fuente de conocimiento estable es el **repositorio/documentación versionados** que se le proporcione.

Actualizar este archivo cuando un método sea realmente probado en el motor. Las ilustraciones conceptuales no validan integración ni calidad.
