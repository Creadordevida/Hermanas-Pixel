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
