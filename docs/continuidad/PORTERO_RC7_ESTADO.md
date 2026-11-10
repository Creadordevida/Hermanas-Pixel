# Portero — estado verificado 2026-11-10

## Estado vigente — listo en la rama de la próxima APK

El portero reconstruido está habilitado en la ruta normal del Campo de entrenamiento. El atlas final contiene 18 poses originales y seis reconstruidas. Las comprobaciones iniciales y el traspaso que figuran más abajo quedan como historial. Pendiente la prueba de la próxima APK en el Redmi Note 14.

Repositorio: Creadordevida/Hermanas-Pixel
Rama: work/revision-visual-20261028-continuidad
Objetivo: reemplazar los cinco sprites antiguos por atlas SNES 4x6 de 24 fotogramas, sin alterar la mecánica aprobada.

## Comprobaciones remotas
- lib/main.dart carga actualmente assets/images/enemies/goalkeeper_0.png a goalkeeper_4.png (bucle de cinco archivos, cerca de línea 679).
- El renderizado del portero sigue seleccionando frames individuales (cerca de líneas 2343-2380).
- La mecánica de embestida con aviso y un impacto se conserva (cerca de líneas 1519-1540).
- assets/images/enemies_new/goalkeeper_atlas.png: 404 en esta rama.
- test/goalkeeper_rc7_render_test.dart: 404 en esta rama.
- assets/images/enemies/goalkeeper_0.png: existe, blob 1d533a4ee0c85dcd9567f5c3b4f9b34d0c1a7a04.

## Estado
NO TERMINADO; no afirmar que el atlas nuevo está integrado ni validado en Flutter/Android. El trabajo artístico reportado en la conversación anterior no está respaldado en la ruta remota verificada.

## Próximas microfases
1. Recuperar el atlas 4x6 auténtico generado anteriormente, sin sustituirlo por dibujos de calidad inferior ni sobrescribir originales.
2. Confirmar transparencia, 24 fotogramas, apoyos, márgenes y calidad SNES a tamaño real.
3. Integrar carga y recorte de atlas en lib/main.dart conservando comportamiento de aviso, embestida, colisión y derrota.
4. Crear pruebas Flutter del portero con ambas protagonistas y seis capturas reales StagePainter 20:9.
5. Ejecutar CI, inspeccionar capturas, corregir y verificar presencia en compilación normal.
6. Actualizar este documento con hashes, commits y evidencias antes de declarar terminado.

No habilitar un recurso inexistente ni afirmar que una prueba no ejecutada ha pasado.

## Microfase 12 — fallo real de CI localizado (10 noviembre 2026)

- Workflow `Goalkeeper atlas candidate QA`, run [42760061458](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/42760061458), job 129643389777: **failure**, no atlas generado.
- `qa/check_goalkeeper_master_poses.py` procesó correctamente ready, idle_shift_a/b/c, shuffle y shuffle_step_a.
- El siguiente archivo en el orden del verificador es `qa/goalkeeper_rebuild_20261109/pose_shuffle_step_b_rgba.png`. Pillow 12.3.0 falló al decodificarlo con `OSError: unrecognized data stream contents when reading image file`.
- **Acción necesaria:** reparar o sustituir ese PNG con una imagen RGBA válida y conservar la fuente original para comparación. No activar `ImageFile.LOAD_TRUNCATED_IMAGES` ni silenciar errores de imagen: ocultaría defectos gráficos.
- Después repetir el verificador completo de 24 imágenes y la generación del atlas. Pueden existir otros PNG corruptos posteriores aún no evaluados.
- La integración Flutter y APK siguen pendientes; no afirmar éxito del QA.

## Microfase 13 — QA de recuperación: bloqueo visual real (10/11/2026)

- Diagnóstico completo run 42760445968: 18 PNG decodifican correctamente, 6 dañados: `shuffle_step_b`, `dive`, `dive_extension`, `hurt`, `defeat_side`, `defeated`. Se obtuvieron copias de recuperación **no aprobadas**.
- Nueva prueba run 42760558813: diagnóstico exitoso, pero `tools/build_goalkeeper_atlas.py` detiene el montaje por `ValueError: Clipped source: shuffle_step_b`. La copia recuperada no conserva margen íntegro. No debe promoverse a arte final ni disimularse el recorte.
- Workflow ajustado en `fa7d054` para subir diagnósticos incluso tras error. Se mantienen intactos los cinco sprites clásicos y las fuentes originales.
- Pendiente de cierre: redibujar/reponer los seis PNG dañados desde las referencias artísticas, comprobar pivotes y halos, construir atlas, integrar en Flutter, ejecutar pruebas y capturas 20:9. **Portero NO finalizado.**

## Microfase 14 — Inspección VISUAL de los 24 fotogramas (10/11/2026)

- Workflow **42760772911** terminó correctamente, generó `diagnostic_recovery/goalkeeper_24_pose_review_contact_sheet.png` y subió artefacto **13737198668**. La lámina se descargó y examinó visualmente, no solo por logs.
- Resultado visual: los 18 PNG válidos representan al mismo portero con pelo castaño, uniforme verde, pantalón blanco y guantes blancos; siluetas completas. **Seis imágenes están realmente cortadas y son inservibles como atlas final**:
  - `shuffle_step_b` (índice 06): solo cabeza y parte superior del torso, corte horizontal.
  - `dive` (índice 12): cabeza, brazos y parte superior del torso, falta cuerpo inferior.
  - `dive_extension` (índice 13): cabeza y brazos, resto cortado.
  - `hurt` (índice 16): primer plano de cabeza y torso, falta cuerpo inferior.
  - `defeat_side` (índice 22): cuerpo horizontal cortado a la altura del tronco.
  - `defeated` (índice 23): cuerpo horizontal cortado a la altura del tronco.
- **Decisión QA:** no activar las seis recuperaciones. Se necesitan seis fotogramas completos redibujados a partir de las poses vecinas, manteniendo el mismo rostro, uniforme, guantes, escala, perspectiva, pivote y pie de apoyo. No utilizar una simple copia de poses adyacentes como sustitución definitiva.
- Evidencia: [run 42760772911](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/42760772911), artefacto `goalkeeper-png-diagnostic-unapproved`. La lámina fue inspeccionada en la conversación del 10/11/2026.
- Estado: **18 poses visualmente aprovechables; 6 por redibujar; sin atlas definitivo, sin integración ni validación Flutter.**


## Microfase 15 — cierre de diagnóstico y puerta de calidad artística (10/11/2026)

- Historial Git examinado en run **42761334091**: los seis PNG dañados tienen un único blob histórico cada uno y **ninguno se decodifica estrictamente**. Cada archivo dañado pesa exactamente 786444 bytes. No hay copia intacta de esas rutas en el historial Git disponible.
- Se han creado seis **duplicados temporales** en `replacement_candidates/` sin sobrescribir los maestros. Son únicamente para verificar el pipeline; NO equivalen a seis poses nuevas.
- El atlas provisional completo 4×6 se generó en run **42762113247** y se examinó visualmente: las estiradas contienen repetición y la derrota no termina tumbada. **Rechazado como arte final.**
- La prueba técnica del atlas temporal pasó en run **42762512768**. El verde de CI confirma PNG/celdas/manifiesto, **no** fluidez, identidad, calidad SNES ni jugabilidad.
- `tools/audit_goalkeeper_art_quality.py` añade una puerta **independiente** de calidad: rechaza fotogramas idénticos y deja explícito que, incluso con 24 distintos, faltan revisión visual y Flutter. Ejecutar tras generar un atlas candidato definitivo; no confundirlo con CI técnico.
- Método vinculante: `docs/continuidad/METODO_ENEMIGOS_SNES_GPT_FUTURO.md`. Conservar referencia original verde/blanca, 4×6 con poses realmente diferentes, márgenes y pivotes; después integración y seis capturas auténticas `StagePainter` 1000×450, interacción Miren/Sara, derrota real, Android.
- **Siguiente acción:** crear seis dibujos genuinos que coincidan con la referencia aprobada (no clones ni una nueva identidad); validar individualmente; sustituir los duplicados temporales SOLO en un nuevo atlas de revisión. Mantener el portero clásico activo hasta terminar QA.
- **Estado:** no terminado, no habilitado en APK.


## TRASPASO A CHATGPT WORK — 10/11/2026 (punto de recuperación)

**Prioridad:** completar el portero con la metodología artística aprobada, no generar más diagnósticos ni duplicados. El usuario cambia a Work para terminar el trabajo. Esta sección resume TODO lo realizado después de la microfase 15. **No se ha integrado un atlas definitivo ni se ha validado el portero nuevo en Flutter.**

### Estado confirmado en GitHub

- Repositorio `Creadordevida/Hermanas-Pixel`, rama `work/revision-visual-20261028-continuidad`, PR #5. Verificar HEAD antes de editar: pueden existir cambios concurrentes de otros capítulos.
- `qa/goalkeeper_rebuild_20261109/pose_{nombre}_rgba.png`: 24 fuentes, **18 decodificables y 6 corruptas** (`shuffle_step_b`, `dive`, `dive_extension`, `hurt`, `defeat_side`, `defeated`). Auditoría del historial Git: sin blobs históricos íntegros para esas seis rutas. No sobrescribir originales.
- `tools/diagnose_goalkeeper_pngs.py`, `tools/audit_goalkeeper_history.py`, `tools/goalkeeper_visual_review.py`: diagnóstico, historial y lámina de inspección.
- `tools/goalkeeper_replacement_candidates.py`: genera **duplicados provisionales** en `qa/goalkeeper_rebuild_20261109/replacement_candidates/`. No son arte aprobado.
- `tools/build_goalkeeper_atlas.py`: monta atlas 4×6 de celdas 256×256 (1024×1536). Con `GOALKEEPER_USE_TEMPORARY_SUBSTITUTES=1` genera `goalkeeper_atlas_4x6_candidate_temporary_rgba.png` y manifiesto sin tocar los maestros.
- `tools/audit_goalkeeper_art_quality.py`: comprueba duplicados exactos. Ejecución **42765849937**: **REJECTED**, parejas de índices cero-basados `[[5,6],[12,14],[13,15],[16,17],[20,23],[21,22]]`; atlas SHA-256 `c7f3635ec62e0d4189b091b7c40fa7557f0eeb97a26cf16c1aef6c922f915cb9`. Esta puerta falla deliberadamente para el atlas temporal; no confundir workflow verde con aprobación.
- Workflow técnico `.github/workflows/goalkeeper-atlas-candidate-qa.yml`: ejecución **42762512768**, éxito; posteriores **42765849780** y **42766112840**, éxito. Solo validan formato/celdas/manifiesto, no arte.
- Workflow diagnóstico `.github/workflows/goalkeeper-png-diagnostic.yml`: ejecución **42765849937**, éxito global porque la puerta artística tiene `continue-on-error: true`; el paso de auditoría artística **falló correctamente** al detectar duplicados. Los logs también muestran fallo esperado al intentar el atlas no temporal con originales corruptos.
- `lib/goalkeeper_animation.dart`: controlador aislado de seis filas; corrección en commit `3d39bb94` para que las cuatro columnas de estirada sean alcanzables durante la ventana de ataque original de 0,27–0,75 s.
- `test/goalkeeper_animation_contract_test.dart`: nueva prueba de las cuatro columnas de estirada en commit `29dcc4ab`. **No hay ejecución Flutter verificada de esta prueba.**
- `.github/workflows/goalkeeper-animation-contract.yml`: workflow **solo manual**, creado en commit `aff1dd98`, para `flutter analyze` y `flutter test test/goalkeeper_animation_contract_test.dart`. No se ha ejecutado; no declararlo verde.
- `lib/main.dart`: **continúa cargando cinco PNG clásicos** `assets/images/enemies/goalkeeper_0.png`…`_4.png`. El nuevo controlador **no está conectado** al renderizado. El combate existente del portero tiene aviso, ventana de daño `foe.t >= .34 && foe.t < .52`, golpe único mediante `biteApplied`, final de ataque a `.75` s y recuperación de 2,7 s. Preservar física, daño y colisiones.
- `assets/images/enemies_new/goalkeeper_atlas.png`: no existía en la última inspección; verificar antes de integrar. **La APK actual NO contiene el nuevo atlas validado.**

### Referencia artística y prohibiciones

- Fuente vinculante: las **18 poses originales intactas**, no las láminas generadas después. Personaje de pelo castaño, camiseta verde con detalles blancos, pantalón blanco, guantes blancos; respetar exactamente silueta, proporciones, paleta, luz, contornos, escala, pies y expresión de las fuentes reales. Las láminas posteriores creadas en la conversación son **ilustraciones de propuesta, NO fuentes transparentes ni aprobaciones**; una primera alteró la equipación a amarillo/negro y fue rechazada.
- **No usar copias de poses adyacentes como arte final.** Rehacer únicamente las seis dañadas con animaciones diferenciadas; estirada con transición real, derrota terminando completamente tumbado, sin amputaciones ni invasión de celdas.
- Seguir `docs/continuidad/METODO_ENEMIGOS_SNES_GPT_FUTURO.md` y `docs/FRAMEWORK_SNES_TWC/MANUAL_MAESTRO_PERSONAJES_SNES.md`. Verificar la ruta exacta del segundo al comenzar. Atlas RGBA 4×6 es base, no límite absoluto.
- No sustituir activos clásicos, activar flags de aprobación, publicar APK ni afirmar «terminado» antes de pruebas reales.

### Secuencia exacta para Work (autorizada, sin detenerse a pedir «continúa»)

1. Leer este estado y la metodología. Recuperar **18 PNG buenos** y atlas temporal real desde GitHub/artefactos. Revisar identidad visual de las poses completas a tamaño jugable.
2. Reconstruir **seis PNG genuinos**, cada uno con identidad aprobada y transparencia limpia; conservar archivos dañados y guardar nuevos derivados con manifiesto, hashes y comparativas. Revisar cada pose antes de integrar. Evitar generar pósteres con títulos en lugar de sprites.
3. Crear atlas candidato con 24 poses realmente distintas; comprobar alfa, recortes, pivotes, márgenes, proporciones, alineación, siluetas y `tools/audit_goalkeeper_art_quality.py`. Corregir hasta que el control no detecte duplicados; eso no basta para aprobación visual.
4. Integrar el atlas en `lib/main.dart` usando `goalkeeperAtlasFrame` y el recorte correcto por celda. Respetar la temporización del ataque, golpe único, movimiento, derrota y colisiones existentes. Mantener un modo de prueba aislado hasta validar.
5. Ejecutar `flutter analyze`, prueba de contrato y pruebas de interacción con **Miren y Sara**. Obtener **seis capturas reales de `StagePainter` 1000×450 (20:9)**, incluyendo reposo, aviso, estirada, impacto y derrota real; inspeccionar capturas y corregir.
6. Verificar aparición en capítulo correcto, escala respecto a protagonistas, espejo izquierda/derecha, colisiones, interrupción, transición y pose final tumbada. Conservar evidencias y commits por microfase; solo entonces habilitar arte para próxima APK y probarla en Android.
7. Actualizar este archivo con hashes, commits, runs, capturas y estado REAL. No confundir éxito técnico con validación artística o prueba en móvil.

**Última acción guardada antes del traspaso:** workflow manual `aff1dd98`; auditoría artística integrada `9673fcfb`; corrección de controlador `3d39bb94` y prueba `29dcc4ab`. **Bloqueo principal: seis dibujos genuinos aún NO creados.**

**Estado final del traspaso: EN PROGRESO / NO LISTO PARA RC8 O SIGUIENTE APK.**

## Microfase 16 — seis poses reconstruidas (10/11/2026)

Revisadas las 18 fuentes intactas antes de generar. Las seis poses nuevas de paso cruzado, arranque, extensión, impacto, caída de lado y derrota tendida conservan la equipación verde/blanca, el pelo castaño y los guantes. La hoja fuente tiene SHA-256 `4d660f5de1cdb1522adcef65e94cf0f976f011c26af3bdeea492e921bff079a4`. Los seis PNG RGBA y los hashes individuales están en [rebuilt_poses](../../qa/goalkeeper_rebuild_20261109/rebuilt_poses/manifest.json). Se aisló cada silueta por alfa, con una única escala relativa de 2,35 frente a las fuentes originales y margen transparente. Se revisaron los seis recortes completos. Se preservaron los maestros dañados y las 18 fuentes intactas.

Siguiente microfase: empaquetar las 18 originales y las 6 reconstruidas, revisar pivote y auditar 24 fotogramas. Integración Flutter pendiente en este punto.

## Microfase 17 — atlas íntegro y auditado (10/11/2026)

El atlas `assets/images/enemies_new/goalkeeper_atlas.png` tiene 1024 × 1536 píxeles y 24 celdas RGBA de 256 × 256. SHA-256 `568b3f5de285ac962b26d90ca4c2b3d62c469b4b517377a5d8c79a113320cd11`. Montado con `GOALKEEPER_USE_REBUILT_POSES=1 python tools/build_goalkeeper_atlas.py` y documentado en el manifiesto del atlas reconstruido. La auditoría obtuvo 24 fotogramas y cero pares duplicados. Los 24 conservan un margen de al menos 12 px, alfa binario y pivote (128, 244). Tres poses en vuelo están elevadas 9, 14 y 10 px. Se inspeccionó la hoja a escala de juego, incluidos guantes, calzado y caída tendida. Los clásicos y las fuentes originales siguen disponibles.

Siguiente microfase: conectar carga y reloj del atlas en Flutter bajo la puerta de pruebas y comprobar el combate.

## Microfase 18 — integración y combate en Flutter (10/11/2026)

El candidato se carga en el campo de entrenamiento mediante la entrada de QA. `StagePainter` recorta la celda del controlador por estado y tiempo, conserva el pivote del suelo e invierte la imagen al cambiar el sentido. Las cuatro poses de impacto preceden a la caída cuando el primer proyectil agota la vida. Se mantiene la ventana de daño de 0,34 a 0,52 s, un golpe por embestida, el final a 0,75 s y el tiempo de recuperación anterior.

Flutter 3.47.8 pasó seis pruebas de contrato y una prueba de escena con ambas protagonistas. El widget comprobó el aviso, la transición por los cuatro fotogramas de estirada, el daño único, la esquiva por salto y la interrupción con balón de Miren y peine de Sara. El análisis de los cuatro archivos Dart modificados no encontró incidencias. Se revisaron doce capturas auténticas de 1000 × 450, seis por protagonista. Se comprobó el apoyo en la pista, el espejo y la pose tumbada completa.

Siguiente microfase: habilitar la ruta normal, repetir las pruebas y conservar las capturas.

## Microfase 19 — ruta normal y capturas archivadas (10/11/2026)

Se habilitó el atlas por la puerta artística de la compilación normal y se retiró la excepción para QA. La prueba inicia una partida desde la portada, entra por el mapa al capítulo 5 y comprueba la aparición real del portero y la decodificación del atlas. En ese capítulo la ruta normal selecciona a Miren. La misma escena reproduce los combates en ambos sentidos con Miren y Sara en condiciones controladas.

Ocho pruebas pasaron en Flutter 3.47.8 con la configuración normal. Incluyen el contrato de las 24 celdas, la prueba de escena y la comprobación de disponibilidad normal del entrenador. El análisis de los cuatro archivos Dart terminó sin incidencias. La prueba adicional de combate del entrenador se detiene en la espera de `resourcesReady` (línea 20). El mismo fallo se reprodujo en el commit de partida `4635068e899d32bf17e16a47512f8553cfe55a2c`. Queda registrado como incidencia previa fuera del alcance del portero.

Las doce capturas son PNG originales de 1000 × 450 obtenidos del widget real con `GOALKEEPER_QA_OUTPUT`. Se revisaron los apoyos, el espejo de la silueta, la estirada y la pose final tendida.

| Momento | Miren | Sara |
| --- | --- | --- |
| Reposo | [PNG](../../qa/goalkeeper_rebuild_20261109/stagepainter/miren_01_reposo.png) | [PNG](../../qa/goalkeeper_rebuild_20261109/stagepainter/sara_01_reposo.png) |
| Desplazamiento | [PNG](../../qa/goalkeeper_rebuild_20261109/stagepainter/miren_02_desplazamiento.png) | [PNG](../../qa/goalkeeper_rebuild_20261109/stagepainter/sara_02_desplazamiento.png) |
| Aviso | [PNG](../../qa/goalkeeper_rebuild_20261109/stagepainter/miren_03_aviso.png) | [PNG](../../qa/goalkeeper_rebuild_20261109/stagepainter/sara_03_aviso.png) |
| Estirada | [PNG](../../qa/goalkeeper_rebuild_20261109/stagepainter/miren_04_estirada.png) | [PNG](../../qa/goalkeeper_rebuild_20261109/stagepainter/sara_04_estirada.png) |
| Impacto del proyectil | [PNG](../../qa/goalkeeper_rebuild_20261109/stagepainter/miren_05_impacto.png) | [PNG](../../qa/goalkeeper_rebuild_20261109/stagepainter/sara_05_impacto.png) |
| Derrota | [PNG](../../qa/goalkeeper_rebuild_20261109/stagepainter/miren_06_derrota.png) | [PNG](../../qa/goalkeeper_rebuild_20261109/stagepainter/sara_06_derrota.png) |

Commits verificados de las microfases previas: reconstrucción `6f627427b0d29386f756f94e3beb70ce53526aa1`, atlas `092ed6bc2c66a667752d58db0c6e940d00a8455f`, integración en QA `adab15442a9d817cbc7b76a27c6081caff0ec684`. La activación y las evidencias se guardan juntas en el commit de esta entrada. Pendiente en Android: aspecto, cadencia, legibilidad del aviso y control táctil durante el combate.
