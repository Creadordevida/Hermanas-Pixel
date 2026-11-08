# Arga — auditoría de 96 fotogramas (08/11/2026)

**Alcance:** inspección visual de los cuatro atlas candidatos originales 4×6 (24 fotogramas cada uno), métricas de alfa y siluetas por cada celda mediante `qa/audit_arga_atlas_frames.py`, prueba preexistente de márgenes y diversidad `qa/check_arga_candidate_atlas.py`, más capturas reales de `StagePainter` ya conservadas en `qa/arga_rc7_flutter/`.

**No equivale a:** aprobación final de arte, QA Android, visionado temporal de 96 fotogramas a velocidad real ni autorización de distribuir atlas. Los recursos originales no se han modificado. En producción se mantienen condicionados a `TWC_ARGA_ATLAS_QA=true`.

## Hallazgos técnicos reproducibles

| Atlas candidato | Celdas ocupadas/24 | Pares adyacentes con cambio de silueta/18 | Sin píxeles alfa 255 | Fotogramas con >500 píxeles alfa tenue fuera de silueta |
|---|---:|---:|---:|---:|
| Cangrejo v1 q95 | 24 | 18 | 24 | 24 |
| Pescador v2 q95 | 24 | 18 | 24 | 11 |
| Gamberro v2 lossless | 24 | 18 | 24 | 22 |
| Trucha v3 lossless | 24 | 18 | 24 | 8 |

- Cada imagen mide 1024×1536; celdas de 256×256; `qa/check_arga_candidate_atlas.py` devuelve PASS en las cuatro.
- Canal alfa: rango 0–254 en todos los atlas. No hay alfa 255 en ninguna de las 96 celdas. `254/255` es prácticamente opaco y, aislado, **no demuestra defecto visible**.
- Se han comprobado las 72 transiciones adyacentes dentro de las seis filas de cada atlas mediante máscaras alfa>=128: ninguna es idéntica; cambios de silueta mínimos: cangrejo 869, pescador 460, gamberro 253, trucha 886 píxeles. No garantiza fluidez temporal.
- Las zonas de alfa entre 1 y 63 fuera del rectángulo sólido expandido 8px son una **alerta, no prueba de fallo**: pueden ser restos de fondo, halos, agua, destellos, líneas de acción o salpicaduras. Prohibido eliminarlas indiscriminadamente.
- Variación del apoyo visual dentro de la misma fila (margen inferior de silueta alfa>=128): cangrejo 0–11px, pescador 0–11px, gamberro 0–8px, trucha 0–15px. La trucha no se apoya en suelo, por lo que ese margen no es un pivote de pies. Pescador y niño requieren comprobar estabilidad en reproducción real antes de aprobar.

## Observación directa de cada atlas completo

- **Cangrejo:** 6 filas distingibles: reposo, avance lateral, alerta con pinzas elevadas, pinzamiento, impacto con chispas, derrota boca arriba. El último estado no conserva apoyo de patas por diseño. Siluetas completas a vista general; la fila de impacto es la más propensa a contaminación tenue.
- **Pescador:** reposo, marcha con botas, aviso, lanzamiento de caña, reacción y derrota sentado con caña en suelo. Caída no parece amputada a vista general. Algunas diferencias de reposo son pequeñas, pero medibles; evaluar su fluidez y el asentamiento de botas al reproducirlas.
- **Niño:** reposo, carrera, aviso, lanzar piedra, impacto y derrota sentado; vestimenta y rostro se mantienen reconocibles en las seis filas. Posibles trazos de fondo oculto/tenue alrededor de celdas; requiere composición sobre varios fondos antes de decidir si son visibles.
- **Trucha:** nado, aceleración con agua, alerta y curvatura, salto con salpicadura, impacto y derrota horizontal. Conserva la identidad de pez en las 24 celdas; los efectos acuáticos son necesarios y no se deben confundir con contaminación. La caída y la altura solo pueden aprobarse viendo el movimiento renderizado.

## Resultado y siguiente microfase

**Resultado:** estructura 4×6, presencia, variación alfa>=128 y primera revisión ocular de 96 poses **COMPROBADAS**. La calidad final de 96 fotogramas como animación jugable **NO APROBADA**.

1. Superponer cada atlas sobre un fondo real oscuro y otro claro, para discriminar halos de efectos legítimos; conservar efectos con identidad.
2. Renderizar secuencias de reproducción continuas (no solo pose suelta) para ver pies, cambios de escala, curvatura y caídas; corregir solo celdas concretas defectuosas.
3. Revisar las 96 celdas en tamaño objetivo respecto a Miren y Sara; validar alfa y fidelidad con la imagen aprobada.
4. Ejecutar Flutter QA tras cualquier cambio; no activar los atlas en versión jugable, no APK ni merge sin cierre formal.

`qa/audit_arga_atlas_frames.py --summary <cuatro rutas>` reproduce métricas; `qa/audit_arga_atlas_frames.py <rutas>` imprime los 96 registros detallados.

## Contraste con capturas verdaderas de Flutter

Se han abierto y examinado las capturas ya existentes `qa/arga_rc7_flutter/crab_pinch_frame_2.png`, `fisher_cast_frame_3.png`, `boy_throw_frame_2.png` y `trout_pose_frame_3.png` (1000×450, motor `StagePainter`, no imágenes conceptuales). Las cuatro siluetas conservan detalle visible a escala de partida y los fotogramas examinados no muestran grandes rectángulos de fondo incrustados ni amputación obvia. El niño aparece lanzando piedra con Miren cerca; el pescador extiende la caña desde la roca; el cangrejo pinza frente a Miren; la trucha se arquea sobre la plataforma del río. **Limitación:** son cuatro fotogramas representativos, no una reproducción completa ni revisión de los píxeles con contraste amplificado. Los bloques blancos del HUD corresponden presumiblemente al texto Ahem del test y requieren verificación específica si se van a usar estas capturas como aceptación de UI.

- 08/11 siguiente microfase de animación: `test/arga_all_96_frames_render_test.dart` (`6e8c371`) obliga a `StagePainter` a pintar las 24 celdas de cada uno de los cuatro atlas y compara firmas de píxeles en regiones locales a intervalos de 1/9 s, sin guardar 96 PNG ni alterar fuentes. Incluido en workflow (`444c3e7`) y ejecutado por trigger `9b59766`, run `42515650427`: **pendiente**. Sirve para detectar fotogramas renderizados idénticos, no para certificar suavidad estética, contactos de pies ni halos.

- El primer CI `42515650427` permaneció prolongadamente en lectura de imágenes del test 96; se corrigió el manejo de futuros de imagen con `tester.runAsync` (`c325387`) para evitar esperas bajo el reloj falso de `flutter_test`. Segunda ejecución `42516024803` solicitada en `0f5a32d`, quedó a la espera de la anterior por grupo de concurrencia. Hasta concluir la segunda, estado de test 96 renderizado **pendiente**, sin declarar QA final.

- Diagnóstico confirmado por log CI: `42515650427` **FAILURE** a las 8 min por `TimeoutException`, cuatro tests 96-frame quedaron bloqueados en espera asíncrona de imagen; **no** fueron fallos de contenido del atlas. Corrección `c325387` usa `tester.runAsync` para lectura del `RenderRepaintBoundary`; la segunda ejecución `42516024803` ha comenzado. Pendiente resultado nuevo.

- 08/11 validación concluida: segundo GitHub Actions `42516024803` **SUCCESS** con el test corregido `test/arga_all_96_frames_render_test.dart`: 4 pruebas widget, una por enemigo, fuerzan seis filas × cuatro fotogramas a 9 fps de selector y comparan píxeles reales de `StagePainter` en región local; **96/96 renders comprobados**, 72 comparaciones consecutivas en motor distintas. Además vuelven a pasar análisis de Dart, pruebas de movimiento/combate de Miren y Sara y capturas 20:9. La primera ejecución `42515650427` falló solo por timeout de captura bajo fake-async (resuelto en `c325387`). **Límite explícito:** transiciones forzadas con posición fija no equivalen a vídeo de partida Android ni prueban subjetivamente suavidad, pivotes o halos. Atlas siguen QA-only, recursos aprobados intactos, sin APK ni merge.

- 08/11 preparación release: `lib/main.dart` commit `125216b` habilita **octavo capítulo Río Arga** en rama de próxima versión (`twcArgaNextVersionEnabled=true`), carga atlas y fondos en app normal, acceso nuevo botón de mapa y guardado 0..7; deja intactos siete capítulos previos. Test de selección `test/arga_next_version_map_entry_test.dart` (`db1abcf`), workflow `ea63e75`, ejecución `42517083475` disparada por `883ed27`: **pendiente**. No hay APK ni merge ni validación Android. Si el mapa o el arranque normal fallan, corregir antes de aceptar release.

- CI integración Arga `42517083475` **FAILURE** exclusivamente en test de mapa: pantalla `_chooseScreen` intentaba cargar `assets/images/scenes/arga.png` (inexistente) al seleccionar capítulo 8; Flutter registró asset missing. Se sustituyó por recurso real `assets/images/arga_rc7/arga_far_rc7_candidate.webp` en `lib/main.dart` commit `5665ffc`, preservando siete capítulos. Nuevo run `42517410292` disparado por `c8fe46f`: **pendiente**. Las pruebas de combate y 96 renders pasaron antes de ese punto.

- Integración de capítulo 8 validada: CI `42517410292` **SUCCESS** con `arga_next_version_map_entry_test.dart`: aparece botón `8 · RÍO ARGA`, contador 0/8, selección cambia `stage=7` y crea cuatro enemigos; carga fondo de selección real corregido `5665ffc`. Revalidó 96 fotogramas y combate de ambas protagonistas. Para inspeccionar composición visual de mapa sin inventar imagen, test ampliado en `2164b82` para guardar `qa/arga_rc7_flutter/arga_next_version_map.png`, workflow `9faf12d`, ejecución activada por `06d54d5`: resultado/captura pendiente.
