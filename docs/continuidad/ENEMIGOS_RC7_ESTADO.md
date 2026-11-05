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

## Siguiente acción exacta

1. Conservar TODOS los archivos recuperados en `qa/recovery_four_enemies_20261105/`, sin sobrescribir `lib/main.dart` actual ni workflows activos. Verificar SHA Git de los binarios y commit en rama.
2. Revisar limpiador primero y comparar el parche local de main contra el main actual antes de integrar; conservar cambios concurrentes de escenarios.
3. Ejecutar pruebas y capturas reales del motor; corregir e iterar. No cerrar sin evidencia.

## Restricciones

No APK, merge ni publicación. Diseños vinculantes: la referencia recuperada `qa/enemy_art_20261104/approved_reference.png`. Conservar originales. Avances pequeños, commit verificable y actualización de esta nota. Los seis enemigos anteriores NO son esta tanda.
