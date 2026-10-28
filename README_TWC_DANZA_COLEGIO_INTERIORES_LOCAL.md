# THE WOLF COMPANY — Experimento de interiores: danza y colegio

**Fecha:** 28/10/2026. **Estado:** candidatos locales para revisión, NO probados en Flutter/Android, **no subidos a GitHub**.

## Alcance

Se conserva sin cambios la jugabilidad del código base RC3 FIX2 y el prototipo local de fútbol. Solo se cambia el dibujo de los capítulos `stage == 5` (danza) y `stage == 6` (colegio). Se usan sus recursos originales, que NO se han sobrescrito.

**Capítulo de danza:** recepción, sala de ensayo con ventanales y barras, y escenario con cortinas y focos. El suelo de madera y las poses de Sara originales se mantienen.

**Colegio:** pasillo con taquillas, biblioteca como hito único, aulas con mesas y pizarra de matemáticas y zona de informática con monitores y pizarra propios. Los originales del colegio y todas las mecánicas se conservan.

El principal cambio respecto a las panorámicas de la versión anterior: las paredes ya no se mueven solo unos píxeles mientras el personaje recorre miles de unidades; ocupan posiciones de mundo 1:1. Las transiciones se resuelven con un marco físico en las posiciones x=10.500 y x=25.500, NO con fundidos semitransparentes de habitaciones enteras.

## Método de movimiento TWC

| Profundidad | Velocidad | Contenido en interiores |
| --- | ---: | --- |
| Lejos | 0,30 × velocidad de cámara | cielo, siluetas y edificios únicamente **a través de ventanas** |
| Intermedia | 0,56 × | árboles y paisaje intermedio tras los cristales |
| Mundo cercano | 1,00 × | muros, espejos, cortinas, taquillas, puertas, mesas, escenario, suelo |

Regla fundamental: **en un interior, las paredes y los muebles no son montañas lejanas**. Por tanto se mueven 1:1; el paisaje lejano solo existe detrás del cristal, donde es verosímil. Esto reutiliza el método documentado del capítulo 1 sin copiar ciegamente una composición exterior.

**Dimensiones:** mundo de 36.500; perspectiva jugable 800×450; suelo actual en Y=286 (danza) o Y=278 (colegio), mismo suelo y física que la base; 3 zonas de 0–10.500, 10.500–25.500 y 25.500–36.500. Cada módulo cercano tiene 880 px, 3 variaciones por sala. Los panoramas cíclicos miden 2.200 y 2.020 px, con periodos de mundo de ≈7.333 y ≈3.607 unidades. Los módulos cercanos recorren el espacio en coordenadas reales y no utilizan crossfades.

## Archivos y reproducción

- `lib/interiors_parallax_twc.dart`: contrato de capas, posiciones, zonas y módulos.
- `lib/main.dart`: selección de estos dos escenarios, carga de 29 imágenes, paredes, vistas y objetos singulares.
- `assets/images/interiors_parallax/{dance,school}/`: 29 PNG nuevos, no sustituyen imágenes aprobadas.
- `tools/build_interiors_parallax_twc.py`: generador reproducible y checksums de fuentes.
- `tools/preview_interiors_twc.py`: simulación de cámaras para inspección visual.
- `test/interiors_parallax_twc_test.dart`: cuatro tests Dart de límites, capas, zonas y cobertura física.
- `qa/test_interiors_twc.py`: doce pruebas Python adicionales.
- `qa/interiors_twc_lab/MANIFEST.json`: inventario y hashes de fuentes.

Para reproducir con Python: `python3 tools/build_interiors_parallax_twc.py` seguido de `python3 tools/preview_interiors_twc.py` y `python3 -m unittest discover -s qa -p 'test_*.py' -q`. Requiere Pillow y NumPy.

Para comprobar con Flutter, después de integrar los archivos en un repositorio de prueba: `flutter pub get`, `flutter analyze --no-pub lib test` y `flutter test test/interiors_parallax_twc_test.dart`. La compilación real, capturas de Flutter y pruebas en Android siguen pendientes.

## Auditoría visual local

- `qa/interiors_twc_lab/CONTACTO_SCHOOL_16_CAMARAS.jpg` (16 posiciones del colegio).
- `qa/interiors_twc_lab/CONTACTO_DANCE_16_CAMARAS.jpg` (16 posiciones de danza).
- `qa/interiors_twc_lab/VIDEO_MOVIMIENTO_SCHOOL_TWC.mp4`.
- `qa/interiors_twc_lab/VIDEO_MOVIMIENTO_DANCE_TWC.mp4`.
- Las cámaras antes/después de cada puerta (`*_10475.png`, `*_10530.png`, `*_25460.png`, `*_25560.png`) permiten inspeccionar uniones.

En estas vistas **NO** se simula una compilación de Flutter: son composiciones de los PNG reales preparados y los sprites del proyecto, dibujadas en Python según las coordenadas aprobadas. Se han revisado los mosaicos completos y los cambios de estancia y se ha eliminado un defecto inicial: repetición excesiva de carteles y pizarras del colegio.

## Regresiones y límites honestos

- **196 pruebas Python pasadas** en la copia de trabajo, 12 añadidas para interiores. Los tests heredados que exigían el antiguo fundido se han actualizado para exigir el nuevo motor, manteniendo los controles de recursos y física.
- La batería NO equivale a `flutter analyze`, compilación APK ni ejecución en móvil; estos tres puntos están pendientes.
- La composición conserva el detalle de los recursos originales. Aun así hay repetición de patrones de ventanas/taquillas y podría requerir variedad adicional tras probarlo en dispositivo.
- El movimiento de 0,30/0,56 es **más discreto en interiores**, porque solo se ve a través de cristales. La sensación principal de avance la producen las paredes, puertas y muebles al 100 %, como corresponde al espacio arquitectónico.
- La portada no se ha modificado. Tampoco se arreglaron aquí las imágenes fantasma del capítulo 1; siguen como asunto independiente.
- El parche **combinado** ya incluye el experimento local de fútbol. El parche **solo interiores** está basado en esa versión local de fútbol; si el repositorio aún tiene RC3 FIX2 sin fútbol, usar el combinado para evitar un `main.dart` inconsistente.

**Estado de entrega:** archivos preparados localmente para una futura rama de prueba. Ninguna escritura en GitHub realizada en esta entrega.
