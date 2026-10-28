# Las aventuras de Miren y Sara — RC3, capítulo 1 físico

**Entrega para GitHub / candidato de prueba Android.** No es un APK; GitHub Actions lo construye. No se ha afirmado aprobación de jugabilidad Android ni perfección artística.

## Qué cambia respecto a 0.9.1 RC2/V5

- En la partida habitual de **capítulo 1** el fondo se dibuja desde **72 teselas físicas de 512 × 380** (la última tiene 148 px), ubicadas en coordenadas absolutas y formando **36.500 unidades exactas de recorrido**. El fondo no se ancla a la pantalla ni se estira a lo largo de regiones.
- El fondo se construyó con elementos de la biblioteca original: cielo, colinas, árboles, farolas, bancos, maceteros y muros; también aparecen una vez los siete lugares/viñetas del barrio, especialmente el edificio curvo, paseo verde, cubierta blanca y cohete. Las cuatro ilustraciones originales siguen **intactas**, verificadas por SHA-256.
- Sara, Miren, enemigos, físicas, balones, colisiones, suelo y resto de capítulos conservan su lógica jugable anterior: no se han sustituido por un simulador.
- El motor Flutter real utiliza las imágenes incorporadas directamente en `main.dart` (`_neighborhoodPhysicalWorld`), no solo el prototipo Python. Para diagnósticos puede compararse con el fondo previo mediante `--dart-define=CH1_LEGACY_BACKGROUND=true`.
- Mecánica del portero ajustada a la última decisión: un balonazo lo elimina. El campo de fútbol no se ha reconstruido en esta entrega.

## Cómo subir el ZIP a GitHub (desde tu PC)

1. Conserva una copia de tu repositorio anterior; crea si puedes una rama `pruebas-capitulo1-rc3`.
2. **Descomprime el ZIP** y copia **todo su contenido** (incluidos `.github`, `assets`, `lib`, `qa`, `test`, `pubspec.yaml`) en la **raíz** del repositorio, sustituyendo los archivos anteriores. No copies el ZIP como un archivo dentro del repositorio ni añadas un nivel extra de carpeta.
3. En GitHub Desktop: **Commit** y **Push**. Abre **Actions** y ejecuta el flujo **«Miren y Sara RC3 - Capitulo 1 fisico - APK y auditoria»** si no ha empezado por el push.
4. Comprueba primero los pasos de Python, `flutter analyze`, `flutter test` y **Flutter build APK**. Si la compilación termina correctamente, descarga el artefacto APK y pruébalo en tu Android.
5. Para visualizaciones: los documentos y capturas generados están en `qa/ch1_rc3_tiles/`.

## Lista corta de prueba en Android

- [ ] El menú y la pantalla de elección funcionan.
- [ ] Carga el capítulo 1 sin pantalla en blanco ni falta de recursos.
- [ ] El edificio curvo se desplaza cuando Miren/Sara avanza.
- [ ] El suelo acompaña al personaje y no aparece una segunda acera.
- [ ] No se observa ninguna banda negra o hueco al cruzar límites de teselas.
- [ ] Saltar, aterrizar, lanzar balón, golpear enemigos y recoger monedas funcionan.
- [ ] Aparecen el paseo verde, la cubierta blanca y el cohete.
- [ ] Se puede completar el capítulo y guardar/continuar.
- [ ] Los capítulos 2–7 siguen arrancando.

## Pruebas ejecutadas aquí

- **162 pruebas Python**: superadas.
- `qa/check_ch1_physical_tiles.py`: integridad de 72 teselas y ancho, coordenadas, 4 originales protegidos, siete viñetas presentes: superado.
- Controles de recursos precompilación existentes: superados.
- Capturas de 16 posiciones y un vídeo de 12 segundos reproducidos desde las **imágenes realmente empaquetadas** con los sprites auténticos.

## Lo que falta verificar o mejorar

- **No se dispone del SDK Flutter ni de Android en el entorno de creación.** No afirmar que compilación, FPS, memoria y controles móviles ya estén probados: GitHub Actions y tu dispositivo harán esas pruebas.
- La continuidad técnica de teselas es exacta, pero **las entradas y salidas artísticas de las viñetas se han suavizado en la textura generada**. En algunos extremos puede verse transición de estilo; requiere tu juicio artístico en pantalla real.
- Los tramos largos comparten un vocabulario visual de árboles y jardines con variación reproducible. No están pintados manualmente como un nivel comercial de Rare; si resultan monótonos hay que enriquecer arte (sin tocar la cámara ni colisiones).
- Algunas auditorías antiguas V4/V5 se conservan en `qa/` para referencia, pero **miden el render experimental anterior y no la ruta activa de RC3**. Su antiguo workflow bloqueante se ha retirado de Actions.

## Arquitectura para nuestro futuro GPT

Regla no negociable: **mundo primero, cámara después**. Toda estructura jugable y visual necesita un intervalo/posición en coordenadas de mundo. Las ilustraciones grandes no se estiran temporalmente sobre kilómetros. Las fotos maestras se conservan aparte. Los tiles se generan una vez con una receta versionada; las pruebas recorren el ancho completo y confirman límites y preservación de recursos. Las pruebas Python no sustituyen Flutter/Android ni la valoración artística.

Comandos reproducibles:

```bash
python3 -m pip install pillow numpy
python3 tools/build_ch1_world_tiles.py
python3 qa/check_ch1_physical_tiles.py
python3 -m unittest discover -s qa -p 'test_*.py' -q
# En PC con Flutter instalado:
flutter pub get
flutter analyze lib test
flutter test test/chapter_one_world_tiles_test.dart test/asset_integrity_test.dart
```

**Nota:** regenerar el mundo genera de nuevo los 72 PNG a partir de las fuentes aprobadas; guarda una copia antes de regenerar si has editado una de esas teselas a mano.
