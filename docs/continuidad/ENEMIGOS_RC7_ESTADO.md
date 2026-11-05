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
