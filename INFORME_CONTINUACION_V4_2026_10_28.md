# Hermanas Pixel — capítulo 1 — continuación RC3 V4

**Fecha:** 2026-10-28. **Estado:** prototipo técnico avanzado, **NO APROBADO artísticamente**. **No se ha generado ZIP.** No habilitar como juego de producción sin pasar la puerta de entrega.

## Diagnóstico y técnica documentada

Como en los sistemas SNES (tilemaps con identificadores de piezas, varias capas, prioridades y coordenadas de scrolling), las superficies continuas del nivel se construyen por piezas repetibles, objetos y coordenadas globales. Las panorámicas concretas de lugares reales no se reutilizan ni estiran arbitrariamente.
Fuentes: https://snes.nesdev.org/wiki/Tilemaps y https://snes.nesdev.org/wiki/Mode_7 (redirección a Backgrounds).

## Cambios técnicos reales

1. `lib/chapter_one_world_v4.dart`: mundo de 36.500 unidades, cámara física, cuatro panorámicas protegidas más tres corredores únicos, dimensiones de imagen según fuente, posiciones **derivadas de la tabla de regiones anterior**; sin segunda tabla de coordenadas.
2. `lib/main.dart`: dibujante experimental de V4 habilitable solamente con `--dart-define=CHAPTER_ONE_WORLD_V4_LAB=true`, **deshabilitado por defecto** hasta la aprobación. Suelo original, muros y mobiliario de atlas como objetos del mundo, culling de cámara, capas distantes con paralaje de velocidad distinta, 77 siluetas arbóreas distantes, 87 objetos de primer/mid plano. La geometría del personaje y colisiones no ha sido reescrita.
3. `assets/images/chapter1/clouds_v4_experimental.png`: nubes como sprites extraídos de arte **nuevo**, no de las cuatro ilustraciones protegidas. Este recurso y los 12 recortes de `park_props_atlas.png` son elementos repetibles; los hitos arquitectónicos no.
4. `qa/ch1_world_v4_reference.py`: simulador Python con recursos auténticos, captura 23 posiciones de cámara y genera vídeo de 61 fotogramas de la **primera salida del edificio**. Este simulador es una referencia matemática; **no es un vídeo de Flutter**.
5. `qa/test_ch1_world_v4.py` añade 16 comprobaciones Python. Una detectó un fallo real de vegetación superpuesta a los hitos: se comprobaba el bloque y no cada objeto. Solucionado y comprobado.
6. `test/chapter_one_world_v4_test.dart` incorpora 4 tests Dart propuestos, que requieren ejecutarse con SDK Flutter.
7. `qa/acceptance_ch1_v4.py` bloquea explícitamente cualquier entrega sin arte y compilación comprobados.

## Verificación (resumen)

- **146 pruebas Python, todas pasan.** Esto verifica estructura, geometría, recursos, controles antiguos y que los detectores funcionan, no la calidad gráfica final.
- Archivo `qa/ch1_world_v4_previews/CONTACTO_23_CAMARAS_V4.png` incluye vistas representativas de principio a fin de capítulo. `PRIMERA_UNION_V4_DIAGNOSTICA_NO_APROBADA.mp4` muestra el corte del edificio en movimiento.
- Vista del tramo modular: 3.249 colores distintos en la banda superior muestreada, frente a 1 antes de insertar nubes y arbolado. Pasa control mínimo de detalle, **pero sigue siendo repetitivo y gráficamente muy inferior a los originales**.
- **Bloqueo visual fundamental:** fachada cortada al salir de la ilustración residencial (~x=921 mundo). El salto RGB medio medido es **97,12**, cuando la puerta de calidad exige menos de **35**. Los números son un detector heurístico, no sustituyen la revisión humana.
- Las siete pinturas existentes cubren en escala natural **8.380,41 de 36.500 unidades** (22,96%). El 77,04% exige piezas de entorno propias de calidad; la versión provisional solo ofrece arbustos, árboles, muros, nubes y lomas simples. La repetición es excesiva para entregar.
- No se ha ejecutado Flutter ni Android en este entorno: no está instalado el SDK. Los tests Dart se guardan, no se afirma que hayan pasado.
- Los hashes de las **cuatro ilustraciones originales** siguen coincidiendo con `qa/ch1_legacy_art_sha256.json`.

## Candidata de arte descartada

Se probó una ilustración nueva de unión con el edificio, `CANDIDATA_CONEXION_GENERADA_REVISION.png`. El ambiente es más detallado, pero el empalme produce **dobles ventanas, fachadas fantasma y cambios de edificio**. No está incorporada en código del juego ni altera el original. Se necesita un **extremo arquitectónico de verdad**, pintado para encajar píxel a píxel con la fachada original, sin fundido de edificios.

## Veredicto de calidad

`qa/ch1_world_v4_previews/PUERTA_ENTREGA.json`: **BLOCKED**. Los problemas de coordenadas, suelo y culling están mucho mejor controlados; el capítulo **NO está terminado ni listo para jugarse a la calidad solicitada**. Es preferible bloquearlo a entregar de nuevo un proyecto con fachadas partidas y paisajes genéricos.

## Siguiente ciclo imprescindible

- Diseñar terminación arquitectónica genuina en el borde original; **mantener el edificio curvo y las otras tres escenas aprobadas intactas**. Revisar fotogramas continuos, no solo fotos estáticas.
- Ampliar la biblioteca modular de arquitectura, setos, vallas y zonas urbanas/paseo, con combinaciones únicas por zona que eviten el mismo jardín repetido durante 36.500 unidades. No usar un árbol o humo para tapar costuras.
- Validar co-localización y animación de Sara/Miren, hitboxes, enemigos y suelo en el motor real; ejecutar tests Flutter y una compilación Android.
- Solo cuando estos controles estén realmente aprobados, activar V4 por defecto y preparar un ZIP (más adelante, con aprobación del usuario).

## Reproducción

```bash
python qa/ch1_world_v4_reference.py
python -m unittest discover -s qa -p 'test_*.py' -q
python qa/acceptance_ch1_v4.py  # Devuelve código 2 hasta superar los bloqueos
# Con Flutter disponible:
flutter test test/chapter_one_world_v4_test.dart
flutter run --dart-define=CHAPTER_ONE_WORLD_V4_LAB=true
```

Todo el trabajo queda en una copia del proyecto. No modificar RC2 original. No generar ZIP hasta orden expresa.
