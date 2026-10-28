# Hermanas Pixel — fútbol con paralaje TWC, candidata local (28/10/2026)

**Estado:** código integrado localmente, recursos generados y simulación revisada. **NO instalado, NO subido a GitHub, NO compilado ni probado todavía en Flutter/Android.** No equivale a una versión artística definitivamente aprobada por el usuario.

## Qué se ha hecho

El capítulo de fútbol (`stage == 4`) se renderiza con el mismo método que el capítulo 1 aprobado en RC3 FIX2, **pero con arte distinto y propio de las instalaciones deportivas**. Las panorámicas originales de entrada, entrenamientos y gradas son fuente de la composición, no fondos casi inmóviles ni escenas enteras que se funden entre sí.

- Montañas y ciudad deportiva: `montanas_ciudad_deportiva_ciclo.png`, **0,30× cámara**, 2.200 px en anillo, repite cada ≈7.333 unidades de mundo.
- Arbolado intermedio con alfa propia: `arbolado_deportivo_ciclo.png`, **0,56× cámara**, 2.020 px en anillo, repite cada ≈3.607 unidades.
- Valla, setos y borde del campo: **1,00× cámara**, seis piezas físicas 1.100 × 386 px, ciclo total de 6.600 unidades. Importante: no se estiran imágenes durante 10.500 o 15.000 unidades, ni hay fundido de fotos de pantalla completa. El módulo en pantalla siempre tiene `worldX − cameraX`.
- Se mantiene el suelo original `ground/stage_4.png` a su velocidad de mundo y todos los accesorios, enemigos, ataques y colisiones existentes.
- Los otros seis capítulos, incluida danza, conservan sus renderizadores.
- Los tres recursos originales del fútbol siguen **byte a byte idénticos** (SHA256 consignado en `MANIFEST.json`).
- Para evitar cargar 72 imágenes más al iniciar Android, se han reducido los recursos nuevos a **8 PNG** (2 fondos + 6 piezas cercanas), sin alterar las velocidades del paralaje.

## Dónde está el trabajo

- `lib/football_parallax_twc.dart`: contrato de coordenadas, velocidades, módulos y ciclos.
- `lib/main.dart`: importa el contrato, registra los recursos y activa `_footballBackgroundTWC()` **solo** en `stage == 4`.
- `pubspec.yaml`: registra los directorios nuevos.
- `assets/images/chapter45/football_parallax/`: ocho PNG y su `MANIFEST.json`.
- `tools/build_football_parallax_twc.py`: generador reproducible (requiere Pillow y NumPy). No altera las fuentes originales.
- `qa/test_football_parallax_twc.py`: seis pruebas específicas del método y de la separación de capítulos.
- `test/football_parallax_twc_test.dart`: dos pruebas Dart nuevas, **a ejecutar en GitHub cuando se autorice la integración**.
- `qa/football_twc_lab/`: capturas de doce puntos y vídeo de laboratorio de movimiento.

## Cómo validar más adelante (NO ejecutado todavía en GitHub)

1. Aplicar el parche sobre la versión actual de `main` con una rama nueva; **no sustituir `build.yml` por uno antiguo**. Añadir `test/football_parallax_twc_test.dart` a los Flutter tests de la CI existente.
2. `flutter pub get`
3. `flutter analyze lib test`
4. `flutter test test/football_parallax_twc_test.dart`
5. Ejecutar el resto de pruebas de CI y compilar el APK.
6. Comparar en Android el primer tercio, las zonas intermedias, los ciclos en x≈6.600 / 7.333 y el final. Revisar enemigos, césped, porterías, profundidad y rendimiento.

## Resultados conseguidos en este entorno

- `python3 -m unittest discover -s qa -p 'test_*.py' -q`: **184 comprobaciones OK** en la copia local.
- Se renderizaron **12 vistas** y un vídeo de movimiento por capas usando los PNG auténticos y el sprite aprobado de Miren.
- Un defecto visible de cambio de textura en la valla fue corregido antes de crear el paquete. El ciclo lejano fue suavizado y la diferencia media de color entre sus extremos cumple el control automatizado (menor de 12 por canal).
- **Pendiente:** compilación de Flutter, consumo de memoria en Android y calidad visual del juego en el teléfono. El vídeo del laboratorio usa una composición Pillow fiel a los recursos y velocidades, pero **no es una grabación de Flutter**.

## Aprobación y conservación

La técnica y las cifras están documentadas además en `docs/TWC_PARALLAX_2D_METODO_APROBADO_RC3_FIX2.md`. Este cambio no modifica la técnica ni los archivos originales del capítulo 1. El objetivo de esta candidatura es comprobar la **portabilidad de la técnica**, no dar por terminado todo el videojuego.
