# Las aventuras de Miren y Sara — RC3 FIX2 (solo capítulo 1)

**Base:** RC3 FIX1, que el usuario ya compiló e instaló correctamente en Android.
**Alcance:** sustitución del paisaje lejano **solo** del capítulo 1. Se conservan la cámara actual, los 36.500 píxeles de mundo, los 72 tiles cercanos, la geometría del suelo, la física, los enemigos, el menú y el resto de capítulos.

## Qué cambia y por qué

La RC3 inicial tenía la cámara y el primer plano correctamente anclados al mundo, pero las colinas lejanas eran planas y las nubes mostraban bordes rectangulares. Ahora se dibujan, de atrás hacia delante:

1. `montanas_ciudad_ciclo.png`: montaña, ciudad y cielo elaborados a partir de las porciones lejanas de las ilustraciones deportivas existentes. Textura circular de 2.200 px a velocidad `0.30 × cámara` (repetición cada ~7.333 unidades del mundo, aproximadamente 1/5 del capítulo).
2. `arbolado_medio_ciclo.png`: arbolado transparente procedente del atlas del propio capítulo, a velocidad `0.56 × cámara`.
3. `world_000.png` ... `world_071.png`: las 72 piezas RGBA físicas de 512 px (última pieza 148 px), a velocidad `1.0 × cámara`. Incluyen muros, jardines, mobiliario y las 7 escenas únicas colocadas en sus posiciones originales de la RC3.
4. Suelo, personajes, obstáculos, monedas y enemigos: **sin modificación de comportamiento**.

Se han sustituido los fondos RGB opacos anteriores por piezas RGBA, para permitir ver las capas detrás. Las cuatro ilustraciones originales **no se han cambiado en disco**. Las uniones de las vistas reconocibles conservan el tratamiento de mezcla existente, por lo que podrían necesitar mejoras artísticas futuras; no se promete haber eliminado todas las transiciones defectuosas.

## Para actualizar tu repositorio GitHub Desktop

**Opción A, parche (recomendada):** estando ya en RC3 FIX1, extrae `MIREN_Y_SARA_RC3_FIX2_PARALLAX_PARCHE.zip` directamente en la raíz del repositorio, con sustitución de archivos. Comprueba que `lib/main.dart`, `pubspec.yaml`, `lib/chapter_one_world_tiles.dart`, las 72 piezas y la carpeta `ch1_parallax/` están incluidos. Después realiza Commit + Push.

**Opción B, proyecto completo:** extrae `MIREN_Y_SARA_RC3_FIX2_PARALLAX_GITHUB_COMPLETO.zip` en la raíz del repositorio, sustituyendo el contenido.

En GitHub Actions, comprueba primero `art-and-coordinates` y `flutter-tests`, después `android-apk-candidato`. Esta edición incluye pruebas adicionales, pero **no se ha ejecutado Flutter ni Android en este entorno**. Si GitHub muestra algún error, conserva el log concreto.

## Evidencia y pruebas realizadas

- 173 pruebas Python pasan, incluyendo 8 controles específicos de paralaje y continuidad.
- Integridad de 72 tiles y último recorte de 148 px.
- 4 ilustraciones protegidas por hashes SHA256.
- Inventario de recursos: 137 referencias válidas.
- Continuidad del ciclo comprobada matemáticamente y mediante capturas a varias cámaras.
- Previews reales **del simulador con los assets que carga Flutter**, no capturas de ejecución Flutter: `qa/ch1_rc3_parallax/CONTACTO_15_CAMARAS.jpg` y `qa/ch1_rc3_parallax/SIMULACION_PARALLAX_RC3_FIX2.mp4`.
- Flutter Analyze, Flutter Test, compilación y Android: pendientes de ejecución en GitHub y dispositivo.

## Regeneración del arte si hace falta retocar

`python3 tools/build_ch1_parallax.py`

Requiere Pillow y NumPy, y no usa servicios externos. Produce de manera determinista los 72 tiles, dos capas de paralaje, la imagen de contacto y los frames diagnósticos. Después de regenerar, se puede borrar la carpeta `qa/ch1_rc3_parallax/frames/` para no incorporarla al ZIP.

## No se incluye en este cambio

No se han corregido la portada, sus márgenes ni el tamaño del logo de The Wolf Company. Tampoco se ha modificado el campo de fútbol. Estas solicitudes anteriores siguen anotadas para versiones específicas posteriores; el objetivo de FIX2 es una sola intervención comprobable: combinar movimiento de RC3 con un horizonte detallado.
