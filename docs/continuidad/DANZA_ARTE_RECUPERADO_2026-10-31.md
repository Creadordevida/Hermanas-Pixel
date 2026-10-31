# Danza 0.9.1 — recuperación exacta del arte aprobado (31-10-2026)

**Estado: ARTES RECUPERADAS Y RECORTADAS LOCALMENTE; NO INTEGRADAS NI VERIFICADAS EN FLUTTER.**

## Decisiones vinculantes
Cinco ambientes aprobados: recepción, pasillo, vestuario, estudio y escenario. Conservar composición y RGB de la lámina original, sin regeneración ni deformación. La lámina principal recuperada de la biblioteca de ChatGPT es `Academia de ballet en estilo SNES.png`, 2172×724, SHA256 `188261c047c7d848d1b4f9ac3b37975913cacd4730744f79b109b102a7b07072`.

## Regiones de recorte (x0,y0,x1,y1), sin redimensionar
| Archivo | Rectángulo | Tamaño | SHA256 |
|---|---|---|---|
| 01_recepcion.png | 0,0,693,338 | 693×338 | 0376b7999defb2c1e615867f0537ccd971b18fe645f30f7f05e7e79d9de20817 |
| 02_estudio.png | 704,0,1405,338 | 701×338 | 0b59f11e8c4a6efc8e85663bd6991ac0941dd0997bcb2b99641608f7cee92534 |
| 03_escenario.png | 1416,0,2172,338 | 756×338 | de16a6d8d3cc8c47badf61a01ca8f51db1d14bdb72d2d1a2fbf5895a96c96bb6 |
| 04_pasillo.png | 0,350,1168,724 | 1168×374 | 52529e61963d07c1f547da9e88178b8fa0692ff44e212a36db7f2f8f3369469e |
| 05_vestuario.png | 1180,350,2172,724 | 992×374 | 22f4984b96187bb65b430ef61448ceb6ff9f784bf2affce58f63d6064f8c9e46 |

En una ejecución local se comprobaron los cinco recortes por equivalencia exacta RGB con sus respectivas regiones maestras, y se preparó un ZIP de transferencia `DANZA_CINCO_ESCENAS_APROBADAS_091.zip` con cinco PNG y manifiesto. **Los PNG del ZIP no se han subido a esta rama.** Existe además una imagen individual de pasillo (2048×768) y otra de vestuario (1672×941) en la biblioteca; ambas se conservan como referencias artísticas, no se sustituyen sin inspección.

## Integración pendiente (NO declarar cerrada)
1. Transferir los cinco PNG maestros al repositorio, verificar SHA y protegerlos contra generadores heredados.
2. Adaptar `lib/interiors_parallax_twc.dart` y `lib/main.dart`: distribución de cinco ambientes; interiores físicos 1.00, paisaje visible tras ventanas 0.30/0.56, puertas y parquet continuos. No usar estiramiento, espejado, bucles de salas emblemáticas ni arcos artificiales.
3. Crear pruebas Flutter QA-only a partir de `test/school_hifi_real_render_test.dart` con capturas auténticas de `StagePainter` a 1000×450 (20:9): cinco escenas, conexiones, dos desplazamientos de cámara y protagonistas.
4. Inspeccionar imágenes obtenidas, iterar defectos, ejecutar analyze/tests, registrar ejecución SHA y evidencias.
5. No APK, merge, publicación, modificaciones a colegio, enemigos, física ni controles.

Este checkpoint documenta procedencia, decisiones y trabajo local realizado; **no implica que los recursos estén cargados por el juego**.