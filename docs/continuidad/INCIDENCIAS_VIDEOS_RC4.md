# Incidencias de vídeo — RC4 Android → próxima candidata

**Lista ABIERTA**. El usuario comunicará fallos mediante vídeos y observaciones. Registrar cada problema con una corrección verificable antes de implementar; no compilar ni cerrar lista sin su orden. APK de comparación: 0.9.1-rc.4+35, compilada en commit `c08ba00283775b99593ff426e8d4bd2130d35307`, run 41071927964.

## VÍDEO 001 — «Screenrecorder-2026-10-30-15-53-34-17.mp4» (33,32 s)

**Fecha:** 30/10/2026. **Prioridad global: CRÍTICA / P0**, por afectar toda la experiencia, no a un capítulo. Análisis de fotogramas de 10, 14, 19, 25 y 31 s. Vídeo original 1080 × 2400 (orientación vertical del archivo).

**Prueba visual inequívoca:** desde la portada y hasta gameplay se ve una estrecha franja horizontal en el centro y grandes barras negras por encima y por debajo. En el vídeo, los píxeles activos están aproximadamente entre filas **957–1442**, ancho de franja ~1080 px, alto ~486 px; la relación 1080:486 = **20:9**, como si la actividad horizontal apareciera dentro de una grabación/pantalla vertical de 1080 × 2400. Dentro de esa franja, la propia composición 16:9 deja **más márgenes laterales**. El aspecto de los personajes se conserva, pero se desperdicia área. En el vídeo se distingue tanto al empezar (10 s) como jugando (25 s). No inferir sin comprobar el estado real de la rotación del teléfono: puede intervenir política de orientación o letterboxing del sistema además de Flutter.

### RC4-001A — PORTADA NO OCUPA PANTALLA (P0)
- **Observado:** franja estrecha centrada con enormes barras negras externas; el título no ocupa el ancho de la franja, aparecen bordes laterales.
- **Esperado:** videojuego en paisaje horizontal que aproveche el panel completo del dispositivo; composición original intacta: personajes, título, botones y logo, sin estirar ni recortar elementos esenciales.
- **Causa código comprobada:** `lib/adaptive_title_screen.dart` usa `BoxFit.contain` para `assets/images/title_cars_fixed_091.png` en RC4; no existe panorámica 20:9 aprobada. El workflow `.github/workflows/playtest-091.yml` ejecuta `flutter create --no-overwrite --platforms=android`; no hay `android/app/src/main/AndroidManifest.xml` propio versionado que defina de forma explícita la orientación nativa. `lib/main.dart` solicita landscape mediante `SystemChrome.setPreferredOrientations`, pero el vídeo muestra gran letterboxing exterior. **La causa exacta del letterboxing externo no está demostrada aún; comprobar orientación de ventana/actividad en Android y la configuración del móvil.**
- **Plan técnico:** (a) fijar e inspeccionar configuración nativa Android de actividad horizontal y modo pantalla completa compatible con el dispositivo; no depender solo de solicitud Dart si se observa letterboxing; (b) título realmente adaptable a 16:9, 19.5:9 y 20:9 usando arte panorámico adicional legítimo o una composición de fondo integrada, manteniendo el núcleo original sin deformar y botones alineados con la misma transformación de coordenadas; sin espejos, borrones ni bandas negras como sustituto.
- **Aceptación obligatoria:** grabación REAL del móvil completamente horizontal, portada llena de esquina a esquina sin negro exterior ni franjas laterales; proporciones normales; todos los botones y logo visibles y pulsables; portada en 16:9 y 20:9. Comparar lado a lado con RC4.

### RC4-001B — PARTIDA NO OCUPA PANTALLA (P0)
- **Observado:** el problema persiste en mapa y juego, incluso al mover a Miren; marco horizontal pequeño con bandas negras exteriores y zonas laterales sin escenario.
- **Esperado:** cámara, fondo, suelo, personajes, HUD y controles ocupan toda la ventana horizontal útil; sin recortar partes jugables ni alterar escala/colisiones.
- **Causa código comprobada:** `lib/main.dart` define `viewW=800`, `viewH=450` (16:9) y presenta **todas** las pantallas no portada con `Center(child:FittedBox(fit:BoxFit.contain,child:SizedBox(width:viewW,height:viewH,child:_screen())))`. En 20:9 la razón de aspecto no coincide; `contain` deja bandas laterales. A esto se suma la anomalía exterior de orientación del vídeo.
- **Plan técnico:** (a) resolver orientación/viewport nativo como RC4-001A; (b) reemplazar la caja fija por **viewport de mundo adaptable**: mantener escala vertical del mundo/animaciones, ampliar los metros visibles horizontalmente (450 unidades de alto → ~1000 unidades de ancho en 20:9), ajustar cámara, render de capas de parallax, clipped backgrounds, HUD y posiciones/áreas de toque a bordes reales del viewport. No usar `BoxFit.fill` ni estirar 800×450 a 20:9, ni hacer `BoxFit.cover` sacrificando controles o personaje.
- **Aceptación obligatoria:** capturas y vídeo REALES de 16:9, 19.5:9 y 20:9 con fondo, suelo y cámara llenando la pantalla; Miren y Sara en proporción correcta; HUD y controles tocables y completamente visibles; saltos, colisiones, interacción con balón/peine y seguimiento de cámara no alterados; pantalla sin grandes barras negras ni márgenes laterales vacíos. Comparar escenas idénticas de RC4 y candidata nueva.

**Estado de ambas incidencias: DIAGNOSTICADAS EN VÍDEO + CAUSAS PARCIALES LOCALIZADAS EN CÓDIGO; CORRECCIÓN NO IMPLEMENTADA.** El usuario sigue enumerando incidencias; no iniciar nueva compilación ni marcar como resueltas por cambiar una sola propiedad gráfica.

## Registro siguiente
Esperar más vídeos y anotaciones del usuario. No mezclar dos problemas de orientación nativa y adaptación Flutter con un mero cambio de tamaño CSS/BoxFit.
