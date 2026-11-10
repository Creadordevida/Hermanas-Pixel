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
