# Bloque G — Integración pre-APK, 30/10/2026

Repositorio privado: `Creadordevida/Hermanas-Pixel`.
Rama: `work/revision-visual-20261028-continuidad`; PR #5 abierta en borrador.
Versión declarada en `pubspec.yaml`: `0.9.1-rc.3+34`.
**Estado: PENDIENTE DE VALIDACIÓN. NO es candidata aprobada ni APK lista.**

## Qué se implementó en G
1. **Prueba estática desfasada corregida** (`qa/test_visual_revision_contract.py`). El selector de frames clásicos reside en `lib/classic_enemy_pose.dart`, no en una rama de `main.dart` como suponían dos tests. Los nuevos asserts verifican la fuente activa, la anticipación, el reposo, la caída y la interoperabilidad de los sprites.
2. **Pose de rival caída auditada**. El sexto PNG `rival_5.png` existe; `main.dart` ya lo cargaba, `export_sprite_bounds.py` ya exportaba su recorte y los tests Dart del bloque F ya contemplaban índice 5: NO se alteró ese código correcto. Se añadió la comprobación cruzada al test Python. `qa/verify_candidate_assets.py` ahora incluye los tres PNG de sexto fotograma `rival_5`, `referee_5`, `breakdancer_5`.
3. **Puerta física integradora** (`qa/verify_integration_before_apk.py --strict`). Comprueba archivos PNG reales y tamaños, los 27 paneles escolares, los 9 paneles de danza con SHA frente a su manifiesto, los 6 cercados de fútbol y fuentes, los 6 atlas nuevos, las 23 poses clásicas, `sprite_bounds.g.dart`, carga Dart de sexto frame y generadores de compilación. Emite `qa/PREAPK_INTEGRATION_G.json`. Es una comprobación de bytes/estructura, NO de calidad artística.
4. **Secuencia del workflow invertida** (`.github/workflows/build.yml`). El job `qa-graficos-flutter` se ejecutará PRIMERO y el job `android-apk-candidato` declara `needs: qa-graficos-flutter`: pruebas de render REAL y verificación técnica bloquean el gasto de compilar si fallan. Permanece solamente `workflow_dispatch`, NO se inició.
5. Ambos jobs ejecutan el control integrador de G después de regenerar los recursos. La comprobación crítica de los 9 PNG de danza (C) sigue activa en ambos.

## Estado de los siete bloques, basado en árbol remoto y código
| Bloque | Realmente confirmado | Sigue bloqueando cierre |
|---|---|---|
| A portada | Logo TWC real presente, portada original conservada, código adaptativo | **No existe** `assets/images/title_wide_20x9.png`; aprobación/render 16:9 a 20:9 pendiente |
| B colegio | 27 PNG existentes, bug de mesas/PC fuera de aula corregido | Repeticiones artísticas y render en movimiento/Flutter pendientes |
| C danza | Generador proporcional y QA SHA en Git; 9 PNG antiguos aún presentes | Ejecutar regeneración y validar bytes y render auténtico; promover PNG definitivos a la rama |
| D fútbol | Generador diversificado y QA actualizada; 6 PNG antiguos presentes | Regeneración definitiva, uniones y capturas reales Flutter pendientes |
| E seis enemigos | IA y hitboxes preparadas | **NO existe** `assets/images/enemies_new/` en rama; seis atlas finales y aprobación artística; flags siguen false |
| F cuatro clásicos | 23 poses originales reconocidas, árbitro hit corregido, script de retoque no destructivo | Revisión artística de candidatos y capturas StagePainter pendientes |
| G integración | Puertas de validación y orden QA→APK implementados en Git | Python de checkout actual y Dart/Flutter no ejecutados aquí; no Android |

## Evidencia efectivamente obtenida
- Consultas a GitHub de PR #5, manifiestos fuente, workflows y scripts actuales; comprobación textual de ruta de carga de sexto fotograma del rival, exportador y pruebas ya correctas.
- `qa/test_visual_revision_contract.py` y `qa/verify_candidate_assets.py` corregidos y persistidos. Nuevos archivos Python de G creados en rama y recuperados mediante API, comprobando estructura textual y su presencia.
- Revisión del árbol remoto: 27 paneles del colegio, 9 paneles de danza y 6 PNG de fútbol presentes; directorio `enemies_new` y panorama 20:9 ausentes.
- Último historial de Actions: **183 ejecuciones, última 2026-10-28 21:24 UTC**. NO se inició ninguna durante G.

## Qué NO se ha verificado
- No se ha ejecutado el nuevo `qa/verify_integration_before_apk.py` dentro de un checkout de la rama actual; tampoco `python -m unittest discover` sobre ese checkout. No confundir comprobación estática del código con ejecución de Python actual.
- No hay SDK Flutter/Dart disponible en el contenedor local de esta sesión: sin `flutter analyze`, `flutter test`, capturas auténticas StagePainter ni APK.
- No se ha inspeccionado ni aprobado arte panorámico y seis atlas inexistentes.
- La puerta bloqueante de `qa/next_version_preflight.py --strict-assets` permanece expresamente activa; **NO saltársela para conseguir APK**.

## Próxima acción permitida
El usuario debe revisar bloque G. Antes de cualquier compilación: completar el arte A y E, regenerar y subir los recursos finales C/D, ejecutar las comprobaciones locales posibles, y después **solicitar autorización expresa** para el workflow manual. NO fusionar PR #5 sin orden.

Este cierre es documental y de integración de código, no una firma artística ni funcional Android.
