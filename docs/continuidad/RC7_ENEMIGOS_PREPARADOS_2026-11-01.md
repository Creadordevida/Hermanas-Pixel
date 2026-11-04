## 2026-11-04 — Enemigos preparados para la RC7 conjunta; recortes de producción corregidos

Auditado HEAD 886a4af259241efd3e68129a6c85e84f6ca848bf, PR #5 abierta sin merge. Los 21 PNG protegidos son idénticos por SHA Git a la entrega verificada del 1/11. El workflow manual rc7-enemies-private-playtest.yml ya habilita TWC_GAMEPLAY_PLAYTEST=true: los seis nuevos aparecerán en la prueba privada sin declarar aprobación artística.

Detectado y corregido un desajuste de entrega: la QA regeneraba sprite_bounds.g.dart, pero la compilación RC7 no lo hacía y el archivo comprometido tenía recortes antiguos. Exportadas localmente 59 poses desde los PNG REALES recuperados del HEAD actual; comprobados límites dentro de cada imagen. Añadido bully_5 al exportador. Guardados Dart/JSON regenerados y paso obligatorio de integridad de arte + exportación antes del análisis/tests/APK. Validada sintaxis Python/YAML, orden del pipeline y define de habilitación. No se modifican sprites, capítulos ni comportamientos.

Para que la siguiente versión muestre TODO: compilar el HEAD actualizado de la rama compartida después de integrar los capítulos de otros chats, conservar este paso de preparación y el define; ejecutar las pruebas conjuntas y revisar en Redmi Note 14. Las pruebas anteriores de enemigos siguen documentadas en 41317694621; esta revisión no equivale a una nueva prueba Flutter/Android de todos los capítulos actuales. Aprobación artística final pendiente. No se ha lanzado Actions ni generado APK en esta revisión.

# RC7 — preparación de enemigos para pruebas privadas (2026-11-01)

**Preparado, NO compilado y NO publicado.** Workflow manual: `.github/workflows/rc7-enemies-private-playtest.yml` (`workflow_dispatch` exclusivamente).

La próxima compilación privada debe pasar `--dart-define=TWC_GAMEPLAY_PLAYTEST=true`: `lib/main.dart` utiliza `isEnemyPlayableInBuild` para incluir los seis enemigos nuevos mientras su aprobación artística continúa marcada `false`. Este flag no constituye aprobación artística ni debe habilitarse en builds públicos.

Seis atlas en GitHub: `assets/images/enemies_new/{robot,supporter,tourist,navarre_king,estafeta_bull,sanfermin_runner}_atlas.png`. Cuatro clásicos: matón, árbitro, jugador rival y breakdancer ya tienen recursos y evidencias en `qa/enemy_verified_render/`.

**Gates antes de APK:** existencia de seis atlas, `flutter analyze --no-pub lib`, smoke tests y `flutter test --no-pub --dart-define=TWC_GAMEPLAY_PLAYTEST=true test/new_enemy_behaviors_test.dart test/new_enemy_hitboxes_test.dart test/classic_enemy_pose_test.dart test/enemy_gameplay_integration_test.dart`. La siguiente APK privada solo se construye si pasan.

**Fuentes visuales:** `qa/enemy_verified_render/README.md`, `docs/FRAMEWORK_SNES_TWC/05_ENEMIGOS_ILUSTRADOS_Y_COMBATE.md`. QA de enemigos: [41317694621](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41317694621) SUCCESS. El commit real de la nueva RC7 puede incluir cambios adicionales de otras conversaciones; volver a verificar head antes del lanzamiento. La RC6 no tiene estos seis enemigos habilitados salvo que su compilación tuviera el define.

**Restricciones:** no ejecutar workflow, no generar APK, no fusionar PR #5, no publicar a Google Play, no modificar diseño/sprites de los enemigos y no cambiar flags `enemyArtValidated`.

**Control de versión:** `0.9.1-rc.7+38`, prerelease `playtest-0.9.1-rc7-private` en repositorio privado, entregable APK con SHA256 y commit, cuando el usuario autorice compilar toda RC7.
