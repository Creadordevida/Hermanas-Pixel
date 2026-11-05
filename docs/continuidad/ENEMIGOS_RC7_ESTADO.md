# Cuatro nuevos enemigos RC7 — punto de recuperación

Actualizado: 2026-11-05. Rama `work/revision-visual-20261028-continuidad`, PR #5 abierta en borrador, sin merge. HEAD comprobado antes de esta nota: `d0cab674ac1c5c60fe59c4d55d32a6ee91aeffd9`.

## Estado comprobado

Se recuperó en este entorno la carpeta local `/workspace/scratch/63076ad48d63/four_enemies` de la sesión anterior. NO confundir su existencia con integración en GitHub. Incluye referencia aprobada, cuatro hojas fuente, cuatro atlas, chancla verde, manifiesto SHA256, empaquetador, verificador, código y pruebas locales.

| Personaje | Destino y ataque | Evidencia actual | Pendiente |
|---|---|---|---|
| Limpiador | Danza; escoba | Hoja y atlas locales recuperados | Revisar poses, integrar, probar Flutter real |
| Músico | Danza; guitarra | Hoja y atlas locales recuperados | Revisar poses, integrar, probar Flutter real |
| Vecina | Salida de casa; chanclas verdes | Hoja, atlas y proyectil locales recuperados | Revisar poses, integrar, probar Flutter real |
| Entrenador rival | Fútbol; pizarra | Hoja y atlas locales recuperados | Revisar poses, integrar, probar Flutter real |

Prueba ejecutada: `python3 tools/verify_four_enemy_art.py` en la copia recuperada: FOUR_ENEMY_ART_PASS (hashes fuente/referencia, 96 celdas, alfa y diversidad de marcha). No equivale a revisión visual completa, prueba de movimiento ni aprobación final. Referencia aprobada abierta y examinada; no es captura del juego. Flutter/Dart no encontrados en PATH.

## Revalidación de recuperación (2026-11-05)

HEAD observado en PR #5: `e1a4919251d13f395f26fbeca902f63ca6566718`. El directorio local recuperado sigue accesible y se ha vuelto a ejecutar el verificador: FOUR_ENEMY_ART_PASS. La ruta remota `qa/recovery_four_enemies_20261105/` devuelve 404: respaldo todavía NO confirmado en GitHub. No se han ejecutado Flutter ni capturas reales en esta revalidación. Ninguno de los cuatro está validado como terminado.

Último avance de esta sesión: comprobación de recursos y registro de estado; no integración nueva. No confundir este commit documental con una mejora visible del juego.

## Texto breve para retomar tras interrupción

«Retoma los cuatro enemigos de Creadordevida/Hermanas-Pixel, rama work/revision-visual-20261028-continuidad, PR #5. Lee primero docs/continuidad/ENEMIGOS_RC7_ESTADO.md y comprueba el último commit. Ejecuta la siguiente acción pendiente en pasos pequeños; guarda y verifica cada avance en GitHub, actualiza el documento y continúa autónomamente. Conserva originales y no declares terminado sin comprobarlo en el juego.»

## Siguiente acción exacta

1. Conservar TODOS los archivos recuperados en `qa/recovery_four_enemies_20261105/`, sin sobrescribir `lib/main.dart` actual ni workflows activos. Verificar SHA Git de los binarios y commit en rama.
2. Revisar limpiador primero y comparar el parche local de main contra el main actual antes de integrar; conservar cambios concurrentes de escenarios.
3. Ejecutar pruebas y capturas reales del motor; corregir e iterar. No cerrar sin evidencia.

## Restricciones

No APK, merge ni publicación. Diseños vinculantes: la referencia recuperada `qa/enemy_art_20261104/approved_reference.png`. Conservar originales. Avances pequeños, commit verificable y actualización de esta nota. Los seis enemigos anteriores NO son esta tanda.

## Avance incremental comprobado — limpiador, 5 noviembre 2026

- Atlas del limpiador **ya presente** en GitHub: `assets/images/enemies_new/dance_cleaner_atlas.png`, blob SHA `be233dce6dcd673f4a03bb6e98b7a085787fad0d`, idéntico (git hash-object) al PNG local recuperado. Inspección visual del atlas 4×6: 24 celdas con reposo, marcha, aviso, barrido, impacto y caída; esto no sustituye animación real.
- Modelo de comportamiento conservado en `lib/four_enemy_behaviors.dart`, commit `11d58ac4983ca4654530480ccf807c1125d26872`.
- Pruebas unitarias del modelo conservadas en `test/four_enemy_behaviors_test.dart`, commit `fa41d8997e04c853f1467fe18a2206c1f151d538`.
- Verificador de arte local: `FOUR_ENEMY_ART_PASS`. No hay Flutter/Dart en este entorno: pruebas Dart y jugabilidad real **sin ejecutar**.
- Bloqueo pendiente de cierre: falta integrar el limpiador en el `lib/main.dart` **actual** sin pisar los escenarios de otros trabajos; comprobar registro del atlas y animaciones en pantalla, físicas de golpe, Miren y Sara, derrota y capturas reales `StagePainter`. Mantener bandera artística desactivada hasta validación. No está listo para RC7 aún.
- Referencia aprobada y hojas fuente siguen recuperadas localmente; su respaldo íntegro remoto no está confirmado. Los otros tres atlas no se han confirmado en la ruta examinada.

**Próxima acción exacta:** adaptar solo las rutas de carga/render y entidades del limpiador a la versión actual de `main.dart`, añadir test de juego real y ejecutar Flutter CI antes de habilitarlo en versión normal. No confundir dos commits preparatorios con integración terminada.

## Integración limpiador — segunda fase 2026-11-05

- Código motor actualizado en `lib/main.dart`: import del modelo, vida (2 impactos), carga de atlas, tres apariciones en Danza (18/54/83% del recorrido), animación por seis estados, golpe de escoba con aviso, reacción a pelota/peine y derrota. Commit `69f465c782801d7aa4ee1b8681b6efbe1381e0cc`.
- La bandera `enemyArtValidated['dance_cleaner']` sigue **false**: no aparece en la RC7 normal hasta que se valide el juego. El test usa `TWC_GAMEPLAY_PLAYTEST=true`.
- Prueba real en `test/dance_cleaner_rc7_gameplay_test.dart` para Miren y Sara (golpe, escape, interrupción y derrota), commit `19e37e68fd887f3b200086cb15711747c7e50c4d`.
- Workflow `.github/workflows/dance-cleaner-rc7-qa.yml` creado, commit `c8b02c7e22f56a0d7aa3434be9a44e5e97ba6948`. **Resultado Flutter y capturas todavía no verificados**. El listado de runs asociado al commit mostró otras tres ejecuciones pendientes, sin confirmar ejecución de este workflow.
- Siguiente acción: obtener resultado del workflow, corregir fallos, producir captura real StagePainter en Danza con el limpiador y habilitar la bandera únicamente si la comparación visual y ambas protagonistas pasan. El personaje sigue **pendiente de validación final**.

## Integración músico — 2026-11-05

- Atlas aprobado en GitHub sin modificación de contenido: `assets/images/enemies_new/guitar_musician_atlas.png`, blob SHA `a305e203b44e9ef8bd960039ccd9c926a4cc1000`, commit `e873f4308022c9da02b21b19ed8ea0467ff309ad`.
- Hoja original conservada en `qa/enemy_art_20261104/guitar_musician_source.png`, blob SHA `9eeb0e39c1e25aa539a981dc443d1b5127ceeb9a`, commit `e8b21da33d40e5ca2d6ae306a75bc3f2c84570be`.
- Integración `lib/main.dart`: carga atlas, dos golpes de vida, tres apariciones en Danza, ataque cuerpo a cuerpo con guitarra y aviso, daño/interrupción, seis filas de animación y caída, escala 138/159. Commit `1ecdc69872a8a14db73dba3bded208ffc1f3b732`.
- `test/guitar_musician_rc7_gameplay_test.dart` comprueba ambos personajes, ataque, huida, impacto, interrupción y derrota. Commit `fb52aaa54f92fd9cf09e0b287840915e439b0244`.
- Workflow `.github/workflows/guitar-musician-rc7-qa.yml`, commit `062b8cfd69ba1ec77a83f702e20503030c5c6045`. **Sin resultado de ejecución Flutter verificable**; tampoco hay capturas StagePainter. El arte está protegido con `enemyArtValidated['guitar_musician'] = false`, no visible en RC7 normal.
- Siguiente acción: ejecutar y revisar CI Flutter, comprobar visualmente el músico en Danza (Miren y Sara), iterar y solo entonces habilitarlo en la compilación normal. No declarar finalizado.

## Vecina — fase de recursos, 2026-11-05

- Siguiente personaje seleccionado: `slipper_neighbor`, salida de casa (stage 0), ataque con chancla verde. Modelo preparatorio ya existente en `lib/four_enemy_behaviors.dart` (alerta 0,75 s, alcance 390, impacto de tipo `slipper`, tres posiciones 16/48/78%).
- Recuperados del respaldo local anterior `slipper_neighbor_atlas.png`, `green_slipper.png` y `slipper_neighbor_source.png`; `tools/verify_four_enemy_art.py` devolvió `FOUR_ENEMY_ART_PASS` (verificación estática, no jugabilidad).
- Atlas y proyectil guardados y comprobados en la rama: `assets/images/enemies_new/slipper_neighbor_atlas.png` (blob `6358bddcd61280667ce5899be551bb221cb48101`) y `assets/images/enemies_new/green_slipper.png` (blob `188391abf76adf593fbbab2c9b4bb86a0a93a62d`). Commit `7aa2b2a9287f3d500e47be2fd33f003c58a7c865`.
- La hoja fuente `qa/enemy_art_20261104/slipper_neighbor_source.png` aún **no está respaldada en la rama** (archivo local grande); conservarla sin sustituirla. No se ha modificado `lib/main.dart` ni habilitado bandera visual en esta fase.
- **Siguiente acción:** integrar la vecina en el `main.dart` actual con aparición, render, animaciones, lanzamiento y colisión de la chancla, interrupción y derrota; añadir pruebas Miren/Sara, ejecutar Flutter CI y capturas auténticas StagePainter antes de habilitarla. **No terminada ni visible aún en RC7 normal.**

## Punto de recuperación incremental — CI limpiador, 2026-11-05

- Se revisó la configuración real de `.github/workflows/dance-cleaner-rc7-qa.yml` y el test `test/dance_cleaner_rc7_gameplay_test.dart`.
- Se añadió disparador `pull_request` para ejecutar el control al modificar código/test/workflow, conservando `push` y `workflow_dispatch`. Commit de código **`0bb6bfd4ad9d40fe79c9439b9e83c0aad5149d56`**, comprobado mediante lectura remota del archivo actualizado.
- Consulta posterior de runs asociados a ese commit: **lista vacía**. Esto NO demuestra éxito ni fallo de Flutter. No hay captura auténtica nueva ni validación de jugabilidad. La bandera del limpiador debe permanecer desactivada.
- **Próximo paso único:** comprobar si GitHub Actions ejecutó el workflow y, si no lo hizo, diagnosticar la activación sin modificar al mismo tiempo el juego; después examinar logs y reparar cualquier fallo concreto. Solo después revisar capturas StagePainter y habilitar el enemigo.
- **Estado:** limpiador integrado pero NO validado; músico integrado pero NO validado; vecina solo recursos; entrenador pendiente. No se ha generado APK ni realizado merge.

## Microfase CI limpiador — diagnóstico y reparación, 2026-11-05

- El workflow **sí se ejecutó**: run `42011710170`, job `127192711307`, resultado **failure** al analizar código. `flutter pub get` y la instalación de Flutter terminaron correctamente, pero las pruebas se saltaron por el error del analizador.
- Los logs localizaron el error raíz en `lib/four_enemy_behaviors.dart:33`: ternario mal formado `ranged?.75:kind=='guitar_musician'?.62:.52`, que generaba numerosos errores sintácticos.
- Corrección mínima de esa expresión a `ranged ? 0.75 : kind=='guitar_musician' ? 0.62 : 0.52`, commit **`54ec6571c2dabb1d8a765955700ba1a8561e3070`**. Sin tocar sprites, escenarios, `main.dart` ni banderas de publicación.
- Consulta inmediata de runs del nuevo commit: **todavía vacía**. La corrección se guardó, pero su resultado Flutter NO está validado. No hay captura StagePainter ni prueba jugable aprobada.
- **Siguiente acción única:** consultar GitHub Actions para el commit `54ec6571`; si falla, inspeccionar el log y reparar solo el fallo concreto. Si pasa, revisar capturas reales en Danza y comportamiento para Miren y Sara antes de habilitar el limpiador.

## Microfase verificada — limpiador CI verde, 2026-11-05

- La ejecución de la corrección `54ec6571` (#8, run `42012364991`) acabó **cancelled**, no constituye resultado válido.
- La siguiente ejecución sobre el commit documental `fb4556e98a58a2c2efb57e9a10541b72a6833a7d` **sí finalizó en success**: workflow **Dance cleaner RC7 real Flutter gameplay QA**, run **`42012417834`**, job **`127195558724`**.
- Pasos confirmados con resultado **success**: `flutter pub get`, `flutter analyze lib/main.dart lib/four_enemy_behaviors.dart test/four_enemy_behaviors_test.dart test/dance_cleaner_rc7_gameplay_test.dart`, `flutter test test/four_enemy_behaviors_test.dart` y `flutter test --dart-define=TWC_GAMEPLAY_PLAYTEST=true test/dance_cleaner_rc7_gameplay_test.dart`.
- **Estado del limpiador:** integración y test automatizado de motor superados; **validación visual auténtica y compilación RC7 normal todavía pendientes**. Mantener `enemyArtValidated['dance_cleaner']=false`. No dar por terminado.
- **Próxima microfase única:** generar y examinar capturas reales StagePainter 20:9 de Danza con limpiador, verificar escala/pies/animación frente a referencia aprobada, y registrar evidencia. Después decidir si se habilita; no tocar otros enemigos durante esa revisión.

## Microfase visual del limpiador — prueba preparada, 2026-11-05

- Reutilizada la técnica auténtica de `test/dance_hifi_real_render_test.dart`: `HermanasGame` real, `StagePainter`, `RepaintBoundary.toImage` y PNG 1000×450 (20:9). En Danza se respeta la selección obligatoria de Sara.
- Creado `test/dance_cleaner_rc7_render_test.dart`, commit **`48bbe15eb56e5fead372f5c4e8350ba43052d2a9`**. Con `TWC_GAMEPLAY_PLAYTEST=true`, sitúa un limpiador en escena y solicita `qa/dance_cleaner_flutter/01_sara_limpiador.png`.
- Actualizado `.github/workflows/dance-cleaner-rc7-qa.yml`, commit **`a9dd61640dfd71fbc20e7b834813339007a9239d`**, para ejecutar el test, verificar firma PNG/dimensiones y conservar la captura en la rama solo si supera QA. No se genera APK.
- Consulta inmediata de runs del commit del workflow: **ninguno devuelto aún**. No hay prueba ejecutada, PNG confirmado ni revisión visual en este punto. Evitar dar por finalizado o activar el limpiador.
- **Próxima acción exacta:** consultar el run de `a9dd61640`; si falla, leer el job y reparar el test de captura. Si pasa, recuperar `qa/dance_cleaner_flutter/01_sara_limpiador.png`, inspeccionarla visualmente y comparar diseño, escala, pies y sombreado con referencia aprobada.

## Microfase visual — primera captura examinada, 2026-11-05

- GitHub Actions run **`42015138923`** (#14) terminó con `flutter analyze`, modelos, gameplay y test de captura `StagePainter` en **success**; falló únicamente la validación de firma PNG escrita con escapes dobles. Corregida en commit `496b915571f9acfd87da5f4a00543b9a0067dec0`.
- Run **`42015736288`** (#16): los cuatro pasos Flutter/test incluidos, así como la captura y comprobación PNG (487377 bytes, 1000×450), fueron **success**. El job general falló al hacer `git push` de la captura con `non-fast-forward` por cambios concurrentes. No fue un fallo gráfico. Se añadió `git fetch` y `git rebase` antes del push al workflow en commit **`ada807042b1a6cd14912ba49072164cc2a4d2c64`**.
- A pesar del push rechazado de ese run, se comprobó **directamente en la rama** que existe `qa/dance_cleaner_flutter/01_sara_limpiador.png` (blob Git `6d4a2a2fe1da28f0ae2fb07bb59800ddcb376977`). Se abrió e inspeccionó la imagen real de 1000×450: Sara y limpiador aparecen en recepción de Danza, sin recortes ni flotación evidente; uniforme azul, bigote y escoba visibles. No equivale a revisión de animación.
- Se abrió e inspeccionó el atlas `assets/images/enemies_new/dance_cleaner_atlas.png` (blob `be233dce6dcd673f4a03bb6e98b7a085787fad0d`). La hoja muestra seis filas de poses. La referencia maestra `qa/enemy_art_20261104/approved_reference.png` todavía devuelve 404 en la rama, por lo que la comparación exacta con el arte aprobado sigue pendiente.
- **Estado:** primera evidencia visual real disponible y revisada; no hay secuencia en movimiento ni validación de todas las poses, no activar `enemyArtValidated['dance_cleaner']` aún.
- **Siguiente microfase:** capturar secuencia de barrido, golpe y derrota (StagePainter real), comparar escala/silueta/animaciones, confirmar fuente aprobada y decidir habilitación únicamente tras pasar revisión.

## Microfase seis fotogramas del limpiador — revisión 2026-11-05

- `test/dance_cleaner_rc7_render_test.dart` amplió la toma real `StagePainter` de 1 a 6 PNG 1000×450, commit **`64d5136aa010de8b6edcc2205b467ce62f50ac00`**; el workflow guarda/verifica las seis, commit **`01e9ea4bf6030cf11a55557efb69a5f5861a859f`**.
- Run **`42017125668`** (#24): **SUCCESS** en análisis, modelos, gameplay real, seis capturas, comprobación de dimensión/firma y guardado.
- Inspección visual de las seis capturas de rama: `02_ataque_t20.png` y `03_ataque_t45.png` muestran barrido de escoba conectado, sin recorte evidente; `04_ataque_t70.png` regresa a posición de reposo/marcha. La primera simulación de derrota `cleaner.hits=cleaner.hp` no mostraba caída, por lo que NO se dio por válida.
- Corregido test para disparar la **derrota auténtica** con el peine de Sara y exigir `cleaner.defeated==true`, commit **`64fe130388a1f0b69793aecab75abbb18d9ff925`**.
- Run **`42017646510`** (#27): análisis, modelos, gameplay, render y verificación de seis PNG **SUCCESS**. El job general falló en `git rebase` del paso final de guardado, por conflicto de imágenes binarias de ejecución PR, **no por Flutter ni por las poses**.
- Se recuperaron de la rama y se examinaron las nuevas `05_derrota_t08.png` (arrodillado) y `06_derrota_t28.png` (caído horizontalmente con escoba), blobs Git `76fa36f6fb90f4f8cd84e4d09e550f1ab98e6877` y `e2a2284c2a4627fbc87f2afc038b51034304cde5`. Ambas evidencias son imágenes auténticas de juego y no se observan amputaciones evidentes.
- El workflow se ajustó para que las ejecuciones `pull_request` validen sin hacer push binario; solo los eventos `push` conservan los PNG. Commit **`d95948b92288c0e35b49120a936e5ff587b974df`**, pendiente resultado de su nueva ejecución.
- **Estado:** pruebas automatizadas y seis capturas reales examinadas, con ataque y caída visibles. Sigue pendiente fuente artística maestra 404 y revisión definitiva de escalado/movimiento en dispositivo; mantener flag de publicación del limpiador desactivada y no afirmar que RC7 normal ya lo muestre.
- **Siguiente acción concreta:** verificar el nuevo workflow sin conflictos, recuperar la referencia maestra aprobada si es posible, decidir ajustes visuales y habilitación final solo con evidencia suficiente. Luego pasar al músico.

## Cierre técnico del limpiador para integrar en RC7 — 2026-11-05

**Estado actualizado prevalente sobre notas anteriores:** el limpiador `dance_cleaner` está **HABILITADO EN LA COMPILACIÓN NORMAL** de la rama de preparación RC7. No implica APK publicada ni ensayo en teléfono.

- `lib/main.dart`: `enemyArtValidated['dance_cleaner']=true`, commit **`b928be9691588e97768dea0599009a4caeeedf91`**. Se mantienen `guitar_musician` y `slipper_neighbor` desactivados.
- `test/dance_cleaner_rc7_release_test.dart`, commit **`44694b4927d25e9951aac980eed1e5cc4a5d8be3`**: sin `TWC_GAMEPLAY_PLAYTEST`, comprueba puerta de activación, etapa 5, tres posiciones 6570/19710/30295 y ausencia en otras etapas.
- Workflow amplió análisis y prueba de configuración normal, commit **`f3e919ba978dd09d5881f1ebff55d15ee502e7db`**.
- **GitHub Actions run `42018586860` (#36): SUCCESS completo**. Confirmados `flutter pub get`, análisis Dart, modelo de comportamiento, test de activación normal, gameplay con Miren/Sara, seis capturas reales `StagePainter` y verificación/guardado PNG. Job `127215350198`.
- Inspección artística: seis PNG reales en `qa/dance_cleaner_flutter/`, barrido y derrota visibles; sin recortes evidentes. La referencia maestra original sigue sin encontrarse en la ruta indicada, por lo que no se afirma comparación pixel a pixel con aquella. La versión RC7 requiere aún compilación APK y prueba física en Redmi Note 14 para verificar encuadre, rendimiento y controles reales.
- **Resultado:** limpiador **LISTO TÉCNICAMENTE PARA SER INCLUIDO EN RC7**, no para afirmar aceptación en dispositivo ni lanzamiento publicado. No hacer merge ni APK en esta microfase.
- **Siguiente enemigo:** músico `guitar_musician`: revisar CI y capturas reales antes de activar su bandera. Mantener metodología de microfases y puntos de recuperación.

## Cierre técnico del músico de guitarra para RC7 — 2026-11-05

**Estado prevalente:** `guitar_musician` **HABILITADO EN COMPILACIÓN NORMAL**, listo técnicamente para incluir en futura APK RC7. No implica aprobación física del dispositivo ni publicación.

- Atlas preservado `assets/images/enemies_new/guitar_musician_atlas.png` (blob `a305e203b44e9ef8bd960039ccd9c926a4cc1000`), hoja fuente conservada previamente en `qa/enemy_art_20261104/guitar_musician_source.png`. La referencia grupal maestra aprobada no ha podido contrastarse en su ruta documentada (404); no afirmar identidad pixel a pixel.
- Creado `test/guitar_musician_rc7_render_test.dart`, commit **`e00c0a5ef8a8bc8c4140346156087c494317d618`**: seis capturas auténticas de `StagePainter` (1000×450), ataque de guitarra y derrota provocada por peine de Sara; la prueba exige `musician.defeated==true` antes de fotografiar caída.
- Workflow de músico ampliado para seis capturas y guardado PNG, commit **`5d49898c2644c2ca738dec3c1063a927d1e625f8`**. Run **`42019154923`** (#6) SUCCESS en modelo, gameplay, render y archivos. Se inspeccionaron en la rama `01_sara_musico.png`, `02_guitarra_t20.png`, `03_guitarra_t45.png`, `05_derrota_t08.png`, `06_derrota_t28.png`: guitarra visible y sin cortes evidentes, pose de golpe y caída real al suelo.
- `lib/main.dart` habilitado: `enemyArtValidated['guitar_musician']=true`, commit **`1ab588473b62d7fdc082b650791e95f63dea490a`**; `dance_cleaner` sigue `true`, `slipper_neighbor` sigue `false`.
- Test específico `test/guitar_musician_rc7_release_test.dart`, commit **`f318d32d15d7a1d89b48fc480a577ccec2c60c1a`**: verifica sin `TWC_GAMEPLAY_PLAYTEST` activación normal y tres apariciones en Danza (12045/24455/33215 de ancho 36500). Workflow con `flutter analyze` añadido, commit **`af4574974d81f0f8da1e19588d1c5a7269763cfb`**.
- Run #12 **`42019862485`** falló solo por advertencia de prueba `unawaited_return_in_try_block`; corregida con `return await file.length()` en commit **`9c011fb153d2ffbde829d64bee41243b2e5a524e`**.
- **Validación FINAL:** GitHub Actions **`42020318892`** (#14), job `127222041473`, **SUCCESS completo**: `flutter pub get`, análisis Dart, test de versión normal, modelo, gameplay con Miren/Sara, seis capturas reales y verificación de seis PNG.
- **Resultado:** músico técnicamente **LISTO PARA RC7** junto con limpiador. Pendiente prueba de la APK futura en Redmi Note 14 y contraste con referencia grupal original si se recupera; no confundir con versión publicada. PR #5 continúa abierta, sin merge.
- **Siguiente enemigo recomendado:** vecina `slipper_neighbor`; integrar su lanzamiento de chancla verde, prueba y capturas antes de activarla. Trabajar en microfases y guardar evidencias.

## Cierre técnico de vecina con chancla verde para RC7 — 2026-11-05

**Estado actualizado prevalente:** `slipper_neighbor` **HABILITADA EN COMPILACIÓN NORMAL**, lista técnicamente para incluir en futura APK RC7. No implica aprobación en dispositivo ni publicación.

- Se constató que `lib/main.dart` ya cargaba atlas `assets/images/enemies_new/slipper_neighbor_atlas.png` y `green_slipper.png`, generaba tres apariciones de `slipper_neighbor` en etapa 0, usaba `FourEnemyMotion` para aviso/lanzamiento y creaba proyectil `kind:'slipper',fromEnemy:true`. Render mediante fila por pose y derrota; daño y colisión existentes.
- La prueba de combate `test/slipper_neighbor_rc7_gameplay_test.dart` ya se encontraba en GitHub al intentar crearla; se preservó sin sobrescritura. Se activó validación en PR en workflow mediante commit **`0cc54e2754fb87e6976443f1ad4c4036384e8a57`**. Run **`42021308493`** (#6) **SUCCESS** en análisis y combate real para Miren/Sara: un lanzamiento por ataque, esquiva, interrupción y derrota.
- Creado `test/slipper_neighbor_rc7_render_test.dart`, commit **`d2ac829ee699f0c5a251c5f64d33b238e8bdc961`**, con seis capturas `StagePainter` 1000×450 (20:9) de exterior salida de casa, aviso, lanzamiento, proyectil verde y derrota auténtica por peine. Workflow amplió render/validación/guardado, commit **`0d2060a82f08a323454faf146a976aae9571cf35`**.
- Run **`42021699403`** (#9), job `127225780950`: **SUCCESS** completo de análisis, gameplay, render y verificación de seis PNG. Capturas inspeccionadas directamente desde `qa/slipper_neighbor_flutter/`: personaje rubio con gafas/bata blanca y chanclas verdes, preparación, chancla verde volando hacia Sara, arrodillado y caída horizontal. Sin recortes evidentes.
- Bandera normal `enemyArtValidated['slipper_neighbor']=true` en `lib/main.dart`, commit **`7480ec3597ca0cd7376a0870b3449e7d31407200`**. Limpiador y músico continúan habilitados.
- Test `test/slipper_neighbor_rc7_release_test.dart`, commit **`e51adb3c45adce7c0c38566459c5006ca4e26b67`**: verifica con modo playtest desactivado la puerta normal, etapa 0, tres apariciones fraccionales y exclusión en otra etapa. Workflow final actualizado, commit **`b2f9041c4a6d3b0c82783cba653fb1355a8a8b19`**.
- **VALIDACIÓN FINAL:** GitHub Actions **`42022195350`** (#15), job `127227436264`, **SUCCESS** en `flutter pub get`, análisis de código, prueba de configuración normal, gameplay Miren/Sara, seis capturas reales y verificación PNG.
- **Resultado:** vecina **LISTA TÉCNICAMENTE PARA RC7** junto con limpiador y músico. Pendiente compilación APK y ensayo físico en Redmi Note 14; el original maestro grupal de diseños no se ha contrastado desde la ruta documentada. No se ha publicado APK ni fusionado PR.
- **Siguiente enemigo:** entrenador rival `rival_coach` del capítulo de fútbol: revisar arte, código, pruebas y capturas; mantener microfases y punto de recuperación antes de activarlo.
