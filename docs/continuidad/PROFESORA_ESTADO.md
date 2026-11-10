# Profesora del Colegio — renovación

**Estado vigente.** El atlas nuevo está habilitado en la ruta normal del Colegio y preparado en la rama para la próxima APK. Pendiente la comprobación en Android físico.

## Microfase 1 — diagnóstico y contrato visual

Base verificada `a7383d5d7cc88432043a00d02b9a8fe0044e6dd4`. La ruta normal abre El colegio y crea 14 profesoras. En Flutter se probaron la goma y la derrota al tercer impacto con Miren y Sara. Cinco PNG actuales, cuatro poses de pie con la misma base de piernas y una derrota fija. El motor alterna fotogramas de pie durante el reposo, reutiliza uno en impacto y muestra la goma saliendo hacia el lado opuesto al brazo. La hoja aprobada `reference/profesora_colegio_arte_aprobado.png` fija gafas, moño castaño, traje morado, blusa blanca, tacones y examen con F roja.

El atlas candidato consta de 24 poses RGBA orientadas a la derecha. Se conserva la profesora como enemiga estática de proyectil y se dibujan apoyos distintos cuando prepara o ejecuta el lanzamiento.

| Fila | Poses | Contrato de juego |
| --- | --- | --- |
| 0 Reposo | 4 | Apoyo fijo, gesto de espera |
| 1 Preparación | 4 | Anticipación durante los 0,75 s anteriores a la suelta |
| 2 Suelta | 4 | Goma desde la mano en la primera pose y continuación del gesto |
| 3 Recuperación | 4 | Vuelve a la guardia durante la recarga |
| 4 Impacto | 4 | Retroceso y aturdimiento visibles |
| 5 Derrota | 4 | Desequilibrio, rodilla, caída y cuerpo apoyado en el suelo |

Se mantienen tres impactos para derrotarla, 3,6 s de recarga y los puntos de aparición. Siguiente acción: comparar los dibujos con el original, componer el atlas y auditar celdas y pivotes antes de activarlo.

## Microfase 2 — atlas candidato

Se revisaron las tres hojas fuente y el atlas completo a escala de juego. La hoja dedicada a la recuperación mantiene el examen bajo y enlaza el gesto de lanzamiento con el reposo. Las tres fuentes RGBA se conservan en WebP sin pérdida, junto con el [manifiesto](../../qa/teacher_rc7/manifest.json), el [montador](../../qa/teacher_rc7/build_atlas.py) y los [textos de procedencia](../../qa/teacher_rc7/sources/prompts.md).

`assets/images/enemies_new/teacher_atlas.png` tiene SHA-256 `6dc7a0f5f6309445d9cfe1b7e9bddd3808b858abeaced0cf6c1cc89d2c833019`. Son 24 celdas RGBA de 256 × 256, con margen transparente, pivote fijo (128, 236), 24 siluetas únicas y el cuerpo completo en la derrota. La mano de suelta está a 59 px hacia delante y 93 px sobre el suelo. Los cinco PNG clásicos quedan conservados. Siguiente acción: cargar el atlas en la escena de pruebas, comprobar aviso, goma, esquiva y caída con las dos protagonistas.

## Microfase 3 — integración y prueba en el motor

La entrada de vista previa carga el atlas candidato en `StagePainter` y usa el mismo reloj de preparación que el combate. La goma aparece al entrar en la primera pose de suelta, en las coordenadas de los dedos y con el espejo correcto. La trayectoria inicial desciende para permitir la esquiva desde la nueva altura de la mano. Se conservan los 195 px/s horizontales, el aviso de 0,75 s, los 3,6 s de recarga y los tres impactos. Un golpe durante el aviso interrumpe la suelta.

La prueba de widget entra por Nueva partida y selecciona El colegio. Con balón y peine comprueba los cuatro fotogramas de aviso, la suelta en ambas direcciones, un corazón de daño, la esquiva con el botón de salto, la interrupción, el impacto y la derrota completa al tercer golpe. La prueba pasó en Flutter 3.47.8. Se revisaron las capturas en contexto, incluido el nuevo signo de aviso de píxel sobre la cabeza. Siguiente acción: activar la ruta normal, repetir la prueba sin vista previa y archivar las capturas.

## Microfase 4 — ruta normal y evidencia final

`enemyArtValidated['teacher']` queda activo y se elimina la entrada temporal de vista previa. La prueba normal inicia Nueva partida, selecciona El colegio y comprueba las 14 apariciones del nivel, el atlas decodificado y el combate de ambas protagonistas en ambos sentidos. Pasaron 15 pruebas en Flutter 3.47.8: la escena de la profesora, integridad de recursos y regresión de selección de poses del portero y de los clásicos. El análisis de los tres archivos Dart modificados terminó sin incidencias.

Se revisaron catorce capturas originales de `StagePainter` de 1000 × 450 obtenidas con `TEACHER_QA_OUTPUT`.

| Momento | Miren | Sara |
| --- | --- | --- |
| Reposo | [PNG](../../qa/teacher_rc7/stagepainter/miren_01_reposo.png) | [PNG](../../qa/teacher_rc7/stagepainter/sara_01_reposo.png) |
| Aviso | [PNG](../../qa/teacher_rc7/stagepainter/miren_02_aviso.png) | [PNG](../../qa/teacher_rc7/stagepainter/sara_02_aviso.png) |
| Suelta de la goma | [PNG](../../qa/teacher_rc7/stagepainter/miren_03_suelta.png) | [PNG](../../qa/teacher_rc7/stagepainter/sara_03_suelta.png) |
| Recuperación | [PNG](../../qa/teacher_rc7/stagepainter/miren_04_recuperacion.png) | [PNG](../../qa/teacher_rc7/stagepainter/sara_04_recuperacion.png) |
| Impacto | [PNG](../../qa/teacher_rc7/stagepainter/miren_05_impacto.png) | [PNG](../../qa/teacher_rc7/stagepainter/sara_05_impacto.png) |
| Inicio de caída | [PNG](../../qa/teacher_rc7/stagepainter/miren_06_caida.png) | [PNG](../../qa/teacher_rc7/stagepainter/sara_06_caida.png) |
| Derrota completa | [PNG](../../qa/teacher_rc7/stagepainter/miren_07_derrota.png) | [PNG](../../qa/teacher_rc7/stagepainter/sara_07_derrota.png) |

Commits de continuidad: `5377375` (diagnóstico), `990ed9c` (atlas y fuentes) y `a228be9` (integración y combate en vista previa). La activación normal y las capturas están en el commit de esta entrada. Pendiente en Redmi Note 14: lectura del aviso a distancia de juego, esquiva con controles táctiles y caída completa en la próxima APK.
