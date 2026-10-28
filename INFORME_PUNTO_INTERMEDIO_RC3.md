# Hermanas Pixel · Capítulo 1 · Punto de recuperación intermedio RC3

Fecha: 2026-10-28. Estado: trabajo PARCIAL, revisión con usuario pendiente. **No instalar, no compilar como versión aprobada, no generar ZIP.**

## Objetivo y fuentes técnicas

Cambiar la representación del capítulo 1 de «una ilustración estirada conceptualmente a 7200 unidades» a «escenarios construidos por objetos y piezas anclados a coordenadas de mundo, con cámara y suelo consistentes». La SNES utiliza tilemaps y capas de desplazamiento independientes; para mapas largos se actualizan regiones según avanza la cámara (SNESdev Wiki: https://snes.nesdev.org/wiki/Tilemaps; https://snes.nesdev.org/wiki/Scrolling_a_large_map; https://snes.nesdev.org/wiki/Mode_7). No replicar el hardware, sino sus principios.

## Cambios incorporados en la copia de trabajo

1. `lib/chapter_one_layout.dart`: las cuatro zonas donde aparecen monedas, enemigos y obstáculos ya **derivan sus límites** de los hitos de `lib/neighborhood_scene_engine.dart`. Eliminada la segunda tabla de 8300/17300/26400 que contradecía la tabla visual de 7200/9200/etc. La tabla antigua de 7 regiones sigue siendo la que usa el renderer RC2, sin alterar los demás capítulos.
2. `lib/chapter_one_camera_v3.dart`: cámara pura que transforma coordenadas del mundo, posición natural de una ilustración (1672 × 380/690 = 920,81 unidades, no 7200), detección de huecos sin rellenarlos engañosamente.
3. `lib/main.dart`: dibujante experimental activable solo mediante `--dart-define=CHAPTER_ONE_WORLD_V3_LAB=true`. Sitúa el edificio en una única posición del mundo sin estirar. Cuando la ilustración acaba se ve un aviso de ARTE PENDIENTE que bloquea la aprobación; no incorpora automáticamente las transiciones antiguas. Por defecto el juego sigue usando RC2 y los otros capítulos no cambian.
4. `test/chapter_one_camera_v3_test.dart`: cinco verificaciones Dart previstas para CI (sin ejecutar todavía por falta de SDK local).
5. `qa/test_single_world_v3.py` y `qa/test_preview_ch1_v3.py`: 11 verificaciones Python adicionales, incluidas comparación de posiciones reales en 120 píxeles, hashes, límites, cobertura, suelo y personaje.
6. `qa/preview_ch1_v3.py`: simulación del primer tramo con Sara y los gráficos auténticos del proyecto; produce vídeo de 31 fotogramas, 4 capturas y métricas reproducibles. No pretende certificar el motor Flutter.
7. `qa/test_chapter_one_neighborhood.py`: actualizado para comprobar las cuatro localizaciones desde la tabla única, en lugar de exigir una tabla duplicada (esto provocó tres fallos iniciales). Sigue comprobando integridad y unicidad.

## Evidencia y autocrítica

- 130 pruebas Python existentes y nuevas: superadas (`qa/RESULTADO_REGRESION.txt`). No equivale a aprobación artística ni Flutter.
- Render de 4 cámaras (0,40,80,120), inspeccionado: el edificio se desplaza con la cámara, Sara mantiene posición dentro del mundo, suelo continuo dentro del tramo corto. El personaje y los fondos usan recursos reales.
- Una prueba de desplazamiento de 120 unidades comprueba que los píxeles de arquitectura avanzan exactamente 120 píxeles (restando el marco de captura y sin contar a Sara).
- Una imagen original de 1672×941 se representa a anchura natural ~920,81 unidades para 380 de altura escénica. En cámara 120 no falta arte; en cámara 600 faltan 479,19 píxeles que deben **construirse**, no fingirse. Esta transición queda RECHAZADA, no aprobada.
- Todavía no se han construido ni comprobado las conexiones, el mapa completo de 36.500 unidades, las capas finales ni una compilación Flutter. La simulación no reproduce toda la física del juego. La portada y fauna no se han modificado.

## Archivos congelados

`qa/ch1_legacy_art_sha256.json` conserva SHA-256 de las cuatro imágenes originales. La copia de trabajo se encuentra en `/mnt/data/hermanas_ch1_RC3_midpoint`. La RC2 completa está guardada en Biblioteca y es la base recuperable. Los cambios se pueden reproducir sustituyendo únicamente los archivos de código/QA descritos, sin reempaquetar todo el proyecto.

## Pendiente para segunda mitad

- Diseñar y verificar un **sistema modular de piezas jugables y decorativas**: suelo, vallas, árboles independientes y siluetas lejanas; las ilustraciones originales funcionan como hitos una sola vez.
- Crear la salida arquitectónica real del edificio curvo y llegar al paseo verde **sin árbol partido, fachada truncada ni fundido**; revisar TODOS los fotogramas de la conexión y rechazar fallos.
- Expandir a los cuatro hitos y al recorrido total, definiendo los encuentros y obstáculos desde el mapa único, sin rellenar 80% con el mismo jardín.
- Crear QA automatizado de visibilidad, occlusión y transiciones, más secuencias de gameplay auténticas del motor Flutter.
- Instalar/ejecutar Flutter en CI con pruebas específicas; luego Android y verificación del juego. No declarar aprobado hasta gameplay satisfactorio.

**Decisión pendiente del usuario en el punto intermedio:** confirmar que mantenemos arquitectura de piezas+objetos, originales intactos, y priorizamos antes de ampliar el capítulo una primera conexión sin defectos visuales. Sin ZIP a petición.
