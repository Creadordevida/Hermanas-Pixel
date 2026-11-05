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
