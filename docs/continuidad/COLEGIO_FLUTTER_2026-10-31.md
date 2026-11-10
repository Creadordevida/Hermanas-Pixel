# Colegio HIFI 0.9.1 — verificación Flutter del 31-10-2026

**Proyecto:** Las aventuras de Miren y Sara · The Wolf Company  
**Repositorio:** `Creadordevida/Hermanas-Pixel`  
**Rama:** `work/revision-visual-20261028-continuidad` · **PR:** [#5](https://github.com/Creadordevida/Hermanas-Pixel/pull/5)  
**Estado:** integración de arte en Flutter y 20:9 verificada en Actions; compilación Android, dispositivo físico, merge y publicación deliberadamente NO ejecutados.

## Procedencia, protección del arte aprobado

- Maestro cinco habitaciones: [school_five_scenes_master.png](https://github.com/Creadordevida/Hermanas-Pixel/blob/work/revision-visual-20261028-continuidad/assets/images/school_hifi/school_five_scenes_master.png), dimensiones 1448×1086 y SHA256 `4370a461007d4e96bef60da32e827995301f41f7d1662fec9749da739d72bc9b`. Se conserva idéntico.
- Archivo de procedencia: [ZIP original aprobado](https://github.com/Creadordevida/Hermanas-Pixel/blob/work/revision-visual-20261028-continuidad/qa/school_inbox/COLEGIO_REFERENCIA_EXACTA_27_PANELES_Y_VENTANAS_MOVILES.zip), SHA256 `c9579acf7ba154cfaaa31ffd237bacb50d7a723000bbea278f0123008e2dee78`. Se conserva.
- 27 paneles del colegio (3 zonas × 9 variaciones) de 880×278 y [su manifiesto](https://github.com/Creadordevida/Hermanas-Pixel/blob/work/revision-visual-20261028-continuidad/qa/school_hifi_lab/SCHOOL_HIFI_MANIFEST.json); [suelo específico corregido](https://github.com/Creadordevida/Hermanas-Pixel/blob/work/revision-visual-20261028-continuidad/assets/images/ground/stage_6_hifi.png). Las pruebas comparan los RGB de **cada píxel** de los 27 paneles contra el ZIP original, sin redibujos ni sustituciones.
- Único ajuste del material gráfico: opacidad alfa del cristal (`alpha=166` en huecos originales y conservación de travesaños oscuros). La alteración se reproduce y audita con [preview_school_window_alpha.py](https://github.com/Creadordevida/Hermanas-Pixel/blob/work/revision-visual-20261028-continuidad/tools/preview_school_window_alpha.py). El paisaje exterior utiliza los dos activos persistentes de [paralaje escolar](https://github.com/Creadordevida/Hermanas-Pixel/tree/work/revision-visual-20261028-continuidad/assets/images/interiors_parallax/school): velocidades 0,30 y 0,56, con paredes/mobiliario a 1,00.

## Capturas auténticas del motor Flutter

**Origen de captura:** `test/school_hifi_real_render_test.dart` monta el `HermanasGame` real, renderiza su `StagePainter` (fase 6), hace `RenderRepaintBoundary.toImage()`, convierte a PNG y guarda cada imagen en `qa/school_hifi_flutter`. Superficie de **1000×450 píxeles (20:9)**. No son composiciones de Pillow ni imágenes originales presentadas como juego.

| Vista | Mundo x | Evidencia |
|---|---:|---|
| Pasillos | 500 | [01_pasillo.png](https://github.com/Creadordevida/Hermanas-Pixel/blob/work/revision-visual-20261028-continuidad/qa/school_hifi_flutter/01_pasillo.png) |
| Zona de taquillas | 1350 | [02_taquillas.png](https://github.com/Creadordevida/Hermanas-Pixel/blob/work/revision-visual-20261028-continuidad/qa/school_hifi_flutter/02_taquillas.png) |
| Biblioteca | 3880 | [03_biblioteca.png](https://github.com/Creadordevida/Hermanas-Pixel/blob/work/revision-visual-20261028-continuidad/qa/school_hifi_flutter/03_biblioteca.png) |
| Aula de pupitres | 11000 | [04_aula_pupitres.png](https://github.com/Creadordevida/Hermanas-Pixel/blob/work/revision-visual-20261028-continuidad/qa/school_hifi_flutter/04_aula_pupitres.png) |
| Informática | 26000 | [05_informatica.png](https://github.com/Creadordevida/Hermanas-Pixel/blob/work/revision-visual-20261028-continuidad/qa/school_hifi_flutter/05_informatica.png) |
| Transición pasillo → aula | 10525 | [06_paso_a_aula.png](https://github.com/Creadordevida/Hermanas-Pixel/blob/work/revision-visual-20261028-continuidad/qa/school_hifi_flutter/06_paso_a_aula.png) |
| Transición aula → informática | 25525 | [07_paso_a_informatica.png](https://github.com/Creadordevida/Hermanas-Pixel/blob/work/revision-visual-20261028-continuidad/qa/school_hifi_flutter/07_paso_a_informatica.png) |
| Pasillo, cámara +60 | 560 | [08_pasillo_movimiento_60.png](https://github.com/Creadordevida/Hermanas-Pixel/blob/work/revision-visual-20261028-continuidad/qa/school_hifi_flutter/08_pasillo_movimiento_60.png) |
| Biblioteca, cámara +60 | 3940 | [09_biblioteca_movimiento_60.png](https://github.com/Creadordevida/Hermanas-Pixel/blob/work/revision-visual-20261028-continuidad/qa/school_hifi_flutter/09_biblioteca_movimiento_60.png) |
| Sara en el aula | 11000 | [10_sara_aula.png](https://github.com/Creadordevida/Hermanas-Pixel/blob/work/revision-visual-20261028-continuidad/qa/school_hifi_flutter/10_sara_aula.png) |
| Sara en biblioteca | 3880 | [11_sara_biblioteca.png](https://github.com/Creadordevida/Hermanas-Pixel/blob/work/revision-visual-20261028-continuidad/qa/school_hifi_flutter/11_sara_biblioteca.png) |

## Comparación artística y anomalías corregidas

- **Referencia → juego:** se conservan las cinco escenas, colores, mobiliario, puertas, ventanas, cartelería, libreros y orden de familias de habitación. La comprobación no se limita a hashes: se inspeccionaron las vistas de juego. El suelo corregido ocupa el espacio caminable de forma continua; ventanas y mobiliario están anclados al plano de muros.
- **Captura Flutter bloqueada:** la primera implementación agotaba diez minutos al rasterizar/exportar. Se aisló la rasterización PNG y el I/O en la zona asincrónica real con tiempos por fase. Ahora las capturas terminan; [test corregido](https://github.com/Creadordevida/Hermanas-Pixel/blob/work/revision-visual-20261028-continuidad/test/school_hifi_real_render_test.dart).
- **Ventanas opacas/celestes:** se corrigió el alfa de los 27 paneles manteniendo RGB aprobado y mostrando la arquitectura/paisaje original con el fondo que se mueve.
- **Paisaje persistente:** los activos reales de fondo lejano y arbolado medio, antes generados pero no guardados, ahora se incluyen en los commits de QA y Git.
- **Módulos repetidos:** se ordenaron las nueve variaciones por zona para evitar yuxtaponer mapas y carteles idénticos de manera artificial, sin descartar paneles.
- **Marcos de transición duplicados:** se desactivó el arco gris genérico de 120 px en el colegio HIFI porque ocultaba la arquitectura aprobada; se conservó para otros escenarios.
- **Miren y Sara:** el test elige ambas protagonistas mediante un parámetro solo de QA, comprueba `StagePainter.selected` y guarda imágenes reales. No se han cambiado sus movimientos, controles, físicas ni habilidades.

## Pruebas y alcance

- Ejecución QA-only final: [**41192357433**](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41192357433).
- Comprobación de 30/30 ficheros binarios originales antes de adaptar alfa; verificación estricta de 27 PNG, las cinco familias y RGB exactos contra el ZIP original.
- `flutter analyze --no-pub lib` sin incidencias.
- `flutter test --reporter expanded --no-pub test/school_hifi_real_render_test.dart`: 11 capturas de `StagePainter`, dimensiones 1000×450, brillo y hashes distintos, comprobación de selección de protagonista.
- Prueba de movimiento: con cámara desplazada +60 px, los muros alineados permanecen iguales (`0,00` de diferencia); el cristal muestra cambios del paisaje (pasillo `3,47`; biblioteca `9,34`). Valores de la ejecución de nueve capturas anterior; el run de once vuelve a ejecutarla.
- **No realizado por mandato del usuario:** compilación Android, APK, test gráfico en móvil físico, merge en `main` ni publicación. La captura de widget Flutter no sustituye la comprobación futura en hardware real; las bandas blancas de texto en capturas de test son tipografía del entorno de pruebas.
- **No tocado:** assets de enemigos, habilidades, controles y físicas de protagonistas.

## Referencias rápidas

- [PR #5](https://github.com/Creadordevida/Hermanas-Pixel/pull/5)
- [Workflow exclusivo Flutter / sin Android](https://github.com/Creadordevida/Hermanas-Pixel/blob/work/revision-visual-20261028-continuidad/.github/workflows/school-hifi-only.yml)
- [Verificador estricto de paneles](https://github.com/Creadordevida/Hermanas-Pixel/blob/work/revision-visual-20261028-continuidad/qa/check_school_hifi_twc.py)
- [Carpeta de capturas de juego](https://github.com/Creadordevida/Hermanas-Pixel/tree/work/revision-visual-20261028-continuidad/qa/school_hifi_flutter)
