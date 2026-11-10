# Portero — estado verificado 2026-11-10

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
