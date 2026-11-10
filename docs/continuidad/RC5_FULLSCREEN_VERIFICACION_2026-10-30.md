# RC5 FULLSCREEN — Corrección de regresión 16:9 / 19,5:9 / 20:9

Fecha 2026-10-30. Incidencias RC4-001A y RC4-001B.
Repositorio Creadordevida/Hermanas-Pixel; rama work/revision-visual-20261028-continuidad; PR #5 en borrador, SIN fusión.
**VERSIÓN**: 0.9.1-rc.5+36. **COMMIT EXACTO DE LA APK**: `64fbe769ee62e8e8dd68e5575f0df9ec02319043`.
**WORKFLOW**: `41085018018` — **COMPLETED/SUCCESS**.
https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41085018018
**RELEASE PRIVADA**: https://github.com/Creadordevida/Hermanas-Pixel/releases/tag/playtest-0.9.1-rc5-fullscreen
**APK**: `app-release.apk`, 142.235.507 bytes, asset de GitHub Release confirmado por API; enlace:
https://github.com/Creadordevida/Hermanas-Pixel/releases/download/playtest-0.9.1-rc5-fullscreen/app-release.apk
**CAPTURAS REALES FLUTTER**: `FULLSCREEN_RC5_FLUTTER_REAL.zip`, 12.388.904 bytes, en el mismo Release; contiene 15 PNG auténticos del motor, no dibujos reconstruidos.
**SHA256 APK**: fichero `FULLSCREEN_RC5_APK.sha256` publicado en la misma Release.

## Investigación histórica y causa identificada
- Primer prototipo (commit `9241768`, 24/10/2026) calculaba escala para 960×540 y usaba `FittedBox(BoxFit.fill)` dentro de caja de proporción fija. Desde RC2 25/10 (`50d9867`) existe `viewW=800` y `FittedBox(BoxFit.contain)`. En RC4 el juego sigue anclado a 800×450 16:9: se ve más estrecho que el dispositivo moderno 20:9. **No hay evidencia técnica de que una versión anterior implementara auténtico viewport 20:9 sin distorsión**; se recupera el objetivo funcional, no un algoritmo antiguo no demostrado.
- Portada RC4 `BoxFit.contain` sobre arte 16:9 producía márgenes, mientras el gameplay también se encajaba a 16:9. Android se generaba con `flutter create` y sin manifest nativo de landscape permanente.
- Las barras superiores/inferiores del vídeo vertical de RC4 podrían incluir orientación del capturador/dispositivo; no se atribuye toda esa área al FittedBox sin prueba Android física.

## Cambios realizados
1. `lib/game_viewport_twc.dart` calcula ancho lógico = 450×relación física; exactamente 800, 975, 1000 unidades para 16:9, 19,5:9 y 20:9. Altura fija 450; personajes/colisiones/controles mantienen tamaño vertical.
2. `lib/main.dart` actualiza `viewW` de acuerdo con el `LayoutBuilder`, redimensiona `SizedBox` del render y ajusta cámara y culling de los sprites; los mundos y capas se dibujan más lejos horizontalmente, no se hace `BoxFit.fill`.
3. Portada `lib/adaptive_title_screen.dart`: composición central aprobada 16:9 se mantiene completa, sin deformar, con pintura escénica en los márgenes horizontales; las posiciones táctiles siguen la transformación de la composición central. Extensiones laterales son un fallback escénico de prueba, no panorama nuevo firmado artísticamente.
4. Mapa 16:9 centrado en el viewport panorámico sin estirar mapa ni zonas de selección. Opciones de personaje centradas con el nuevo ancho de mundo.
5. `tools/configure_android_landscape_twc.py` interviene después de `flutter create`, exige actividad `sensorLandscape`, `resizeableActivity=true`, aspecto máximo 2,8, y reabre el `AndroidManifest.xml` para verificarlo.
6. `test/game_viewport_twc_test.dart` y `test/fullscreen_real_render_rc5_test.dart` prueban geometría y capturas REALES de portada/mapa/siete capítulos. `.github/workflows/fullscreen-rc5.yml` no llega a Gradle si las pruebas de pantalla fallan.
7. RC4 y su Release quedan intactas; se conservan los seis enemigos nuevos en modo pruebas; ninguna otra mejora gráfica de la lista de vídeos se ha modificado en esta APK.

## Evidencia automatizada de la ejecución final
- Análisis Dart PASS; 17 pruebas de IA/personajes PASS; 3 pruebas de geometría PASS; manifiesto Android corregido y verificado.
- Prueba de render REAL Flutter PASS: **15 capturas**:
  - 800×450: title_16_9, map_16_9, chapter1_16_9.
  - 975×450: title_19_5_9, map_19_5_9, chapter1_19_5_9.
  - 1000×450: title_20_9, map_20_9 y chapter1_20_9..chapter7_20_9.
- Cada captura verificó anchura/altura del `RenderRepaintBoundary` y, en gameplay, anchura lógica de `StagePainter`; los bordes izquierdo/derecho contienen múltiples colores reales (no bandas negras vacías). En el capítulo 7 a 20:9 se obtuvieron 29 grupos de color en ambos márgenes.
- ZIP completo de PNG y archivo SHA256 entregados junto con APK privada.
- **No se ha ejecutado emulador Android en este workflow**. `flutter test` prueba el motor Flutter, no la política real de ventanas de Xiaomi.

## Estado final exacto
**RC4-001A/RC4-001B: CORREGIDAS Y VERIFICADAS POR CI/FLUTTER; PENDIENTES DE CONFIRMACIÓN EN REDMI NOTE 14.** No decir «definitivamente solucionado en el móvil» hasta que el usuario instale RC5 y grabe portada/gameplay horizontal. Si quedan bandas nativas, analizar la ventana Android y su captura real antes de otra modificación.

La nueva APK incluye la misma base de contenido RC4 (con gráficos provisionales E y defectos del colegio/Estafeta/danza aún pendientes de otra versión). La prioridad exclusiva fue fullscreen; no se ha modificado el resto de la lista.

## Instalación y comparación
Descargar APK desde la Release privada, instalar sobre RC4 (versionCode 36 > 35); no desinstalar RC4 sin respaldar partidas. Probar con el móvil físicamente girado a paisaje, grabar portada, mapa y varios capítulos, comparar con RC4. Confirmar extremos sin negro y botones. Compartir vídeo para cerrar definitivamente.
