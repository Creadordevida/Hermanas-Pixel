# Estafeta RC7 — integración protegida, arte candidato (1 noviembre 2026)

**Estado:** CAMBIO DE MOTOR INTEGRADO, ARTE BINARIO AÚN NO INTEGRADO NI APROBADO; sin Android/APK, sin merge.

## Código real

- `9096875`: `lib/main.dart` carga por flag `TWC_ESTAFETA_RC7_ART` 39 paneles WebP `960x390` y los dibuja en mundo físico a velocidad 1:1. El antiguo fondo `scene_2` con paralaje `0.014` y `mid_2` no se usa en la nueva rama de pintura. La bandera es falsa por defecto para conservar una versión instalable sin assets ausentes. No se altera ningún otro escenario, física o enemigo.
- `b6e29f6`: contrato geométrico y puerta de seguridad.
- `3c9f752`: test de 12 capturas auténticas del `StagePainter` en 800x450, 975x450 y 1000x450, 4 posiciones; no se ha ejecutado.

## Arte disponible fuera del repositorio

Se han producido 4 ilustraciones maestras y 39 módulos de 960x390 a partir de ellas mediante script reproducible. Todos tienen tamaños/hashes distintos y suman 6.21MB. Se ha construido un ZIP de 19.3MB con maestros, 39 WebP, generador, manifiesto SHA-256 y control visual. Se ha inspeccionado el mosaico de 10 piezas: las uniones de tejados/fachadas aún presentan cortes. Algunas composiciones repiten motivos a lo largo del recorrido: no se pueden presentar como escenas finales aprobadas.

**Limitación material:** las piezas binarias WebP del contenedor todavía NO se han transferido a la rama. No declarar integración de arte, pruebas ni acabado. `pubspec.yaml` NO referencia la carpeta ausente. Conservar bandera apagada.

## Puerta de finalización

1. Revisar y corregir las uniones a nivel de fachada/arquitectura con art original no espejado ni duplicado.
2. Incorporar exactamente los 39 WebP corregidos y sus hashes al repositorio; añadir el directorio al `pubspec.yaml`.
3. Activar flag solo para QA, ejecutar `flutter analyze`, prueba de contrato y `test/estafeta_rc7_real_render_test.dart` y persistir 12 PNG reales.
4. Inspeccionar movimiento de cámara y anclaje del suelo; iterar arte y código.
5. Revisión artística del usuario y futura prueba física Android cuando se autorice una APK.

No confundir imágenes conceptuales, contacto PIL, pruebas Dart, capturas StagePainter y prueba Android.
