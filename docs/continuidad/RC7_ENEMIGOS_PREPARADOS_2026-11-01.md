# RC7 — preparación de enemigos para pruebas privadas (2026-11-01)

**Preparado, NO compilado y NO publicado.** Workflow manual: `.github/workflows/rc7-enemies-private-playtest.yml` (`workflow_dispatch` exclusivamente).

La próxima compilación privada debe pasar `--dart-define=TWC_GAMEPLAY_PLAYTEST=true`: `lib/main.dart` utiliza `isEnemyPlayableInBuild` para incluir los seis enemigos nuevos mientras su aprobación artística continúa marcada `false`. Este flag no constituye aprobación artística ni debe habilitarse en builds públicos.

Seis atlas en GitHub: `assets/images/enemies_new/{robot,supporter,tourist,navarre_king,estafeta_bull,sanfermin_runner}_atlas.png`. Cuatro clásicos: matón, árbitro, jugador rival y breakdancer ya tienen recursos y evidencias en `qa/enemy_verified_render/`.

**Gates antes de APK:** existencia de seis atlas, `flutter analyze --no-pub lib`, smoke tests y `flutter test --no-pub --dart-define=TWC_GAMEPLAY_PLAYTEST=true test/new_enemy_behaviors_test.dart test/new_enemy_hitboxes_test.dart test/classic_enemy_pose_test.dart test/enemy_gameplay_integration_test.dart`. La siguiente APK privada solo se construye si pasan.

**Fuentes visuales:** `qa/enemy_verified_render/README.md`, `docs/FRAMEWORK_SNES_TWC/05_ENEMIGOS_ILUSTRADOS_Y_COMBATE.md`. QA de enemigos: [41317694621](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41317694621) SUCCESS. El commit real de la nueva RC7 puede incluir cambios adicionales de otras conversaciones; volver a verificar head antes del lanzamiento. La RC6 no tiene estos seis enemigos habilitados salvo que su compilación tuviera el define.

**Restricciones:** no ejecutar workflow, no generar APK, no fusionar PR #5, no publicar a Google Play, no modificar diseño/sprites de los enemigos y no cambiar flags `enemyArtValidated`.

**Control de versión:** `0.9.1-rc.7+38`, prerelease `playtest-0.9.1-rc7-private` en repositorio privado, entregable APK con SHA256 y commit, cuando el usuario autorice compilar toda RC7.
