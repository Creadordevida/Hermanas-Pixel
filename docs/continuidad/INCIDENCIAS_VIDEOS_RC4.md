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

## VÍDEO 002 — Colegio, «Screenrecorder-2026-10-30-15-54-23-632.mp4» (~29,4 s)

### RC4-002 — Arquitectura interior del colegio: calidad baja y repetición excesiva (P1 ALTA)
**Observación del usuario:** después de muchas correcciones, las paredes siguen «fatal»; el paisaje móvil detrás de las ventanas es una mejora que SÍ funciona.
**Evidencia del vídeo:** paredes beige planas, huecos/ventanales y sombras/siluetas oscuras repetidos, encadenados como módulos idénticos. Bibliotecas, taquillas y carteles aparecen, pero no solucionan la calidad del conjunto.
**Criterio de solución:** rehacer de forma sustancial la arquitectura interior (pilares, muros, materiales, transiciones y variedad real de biblioteca, aulas y pasillo), conservar paralaje exterior, calidad de sprites y objetos aprobados. No aprobar por cambiar colores, desplazar cortes o superar pruebas de hashes. Comparar secuencias reales de 5 o más módulos en Flutter y en móvil.
**Estado:** REGISTRADO, NO CORREGIDO.

## VÍDEO 003 — Calle Estafeta, «Screenrecorder-2026-10-30-15-56-04-448.mp4» (~36,9 s)

### RC4-003A — Turista: arte muy por debajo del estándar SNES (P1 ALTA)
**Observación del usuario:** calidad «pésima»; el fotograma muestra figura procedimental muy esquemática frente a la protagonista detallada.
**Criterio de solución:** REHACER atlas completo, no retoques cosméticos. Cuerpo, rostro, perspectiva, gesto, material, volumen, iluminación y cuatro fotogramas diferenciados de cada acción; coherencia con la escala/detalle de Miren y Sara. Conservar comportamiento si sirve. No considerarlo resuelto sin verlo correr/atacar/recibir impacto y caer en Flutter.
**Estado:** REGISTRADO, NO CORREGIDO.

### RC4-003B — Corredor de San Fermín: arte muy por debajo del estándar SNES (P1 ALTA)
**Observación del usuario:** figura se ve artificial y desproporcionada frente a la protagonista; calidad «pésima».
**Criterio de solución:** rehacer desde una base artística coherente con los sprites originales, atuendo de corredor reconocible, secuencias reales de movimiento y pivotes estables; ensayar acercamiento, advertencia, ataque, esquiva y derrota. No usar el atlas procedimental previo como arte aceptado.
**Estado:** REGISTRADO, NO CORREGIDO.

### RC4-003C — Fondo de Calle Estafeta: mejora arquitectónica pendiente (P1 ALTA)
**Observación del usuario:** fondo visual y perspectiva aún inadecuados; problema conocido y pendiente desde antes de RC4. No confundir con fallo de enemigos.
**Criterio de solución:** escena de Estafeta más coherente y nítida con identidad de la calle, profundidad, geometría y movimiento de cámara sin estiramientos ni retales repetidos; mantener física y circulación. Comparación visual de RC4 con la siguiente APK.
**Estado:** REGISTRADO, NO CORREGIDO.

## VÍDEO 004 — Escuela de danza, «Screenrecorder-2026-10-30-15-59-02-915.mp4» (~22 s)

### RC4-004 — La variedad prometida en la academia de danza no se aprecia (P1 ALTA)
**Observación:** el usuario NO considera malo el nivel gráfico de los interiores de danza; aprecia que el paisaje se mueve detrás de las ventanas. Lo rechazado es la repetición continua del mismo mural: ventanas, pilares, lámparas, cuadros, barras. En el vídeo aparece un piano y otros elementos distintos puntualmente, pero una gran parte del recorrido sigue pareciendo igual.
**Causa técnica confirmada en el código GitHub (30/10/2026):**
- `tools/build_interiors_parallax_twc.py`: `DANCE_PANEL_VARIANTS=3`; tres zonas `foyer/studio/stage`, cada una recortada de UN mismo original por zona; recortes `sw=1200, sh=390`, `left=(0,236,472)[variant]`. Dos recortes vecinos comparten 964 px de los 1200 originales = **80,3% de solapamiento horizontal**. Esto preserva proporción pero NO crea nuevas estancias.
- `lib/interiors_parallax_twc.dart`: `interiorVariantsPerRoomTWC=3`, `interiorModuleVariantTWC` devuelve `index%3` para danza; teselas físicas de 880 px, por tanto **la secuencia de 3 módulos se repite cada 2640 unidades** dentro de cada zona de 10.500/15.000/11.000 unidades.
- `tools/build_dance_panels_twc.py` solo llama a `make_wall('dance',zone,variant)` nueve veces; las comprobaciones de proporciones y SHA **no miden variedad artística ni exposición de repeticiones durante gameplay**.
**Qué PRESERVAR:** aspecto de paredes y suelo de alta calidad, barras de danza, buena iluminación, cielo/arbolado exterior en paralaje .30/.56, pivotes de los personajes y elementos interesantes como el piano.
**Qué HACER DE VERDAD:** diseñar e incorporar **secuencias arquitectónicas distinguibles, nuevas composiciones espaciales y transiciones** para las zonas foyer/studio/stage, no simples recortes del mismo mural ni alternancia de 3 paneles solapados. Distribuir elementos únicos con lógica arquitectónica y espacios de descanso; no introducir objetos sin sentido solo para aparentar diversidad; conservar escala proporcional.
**Criterios de aceptación:** (1) recorrido grabado con varias pantallas por zona, sin patrón evidente de 3 módulos recurrentes; (2) comparación lateral por puntos de mundo entre RC4 y nueva APK, mostrando cambios arquitectónicos reales; (3) continuidad de juntas y parallax en ventanas; (4) mismo nivel pixel-art que escenas aprobadas; (5) 16:9 y pantalla panorámica corregida según RC4-001; (6) validación real Flutter/Android, no solo test de PNG únicos.
**Estado:** CAUSA IDENTIFICADA EN CÓDIGO + VÍDEO INSPECCIONADO, CORRECCIÓN NO IMPLEMENTADA.

## VÍDEO 005 — Colegio, «Screenrecorder-2026-10-30-16-00-26-909.mp4» (36,08 s)

**Candidata evaluada:** 0.9.1 RC4 probada en móvil, NO corregida. Fotogramas inspeccionados a ~3–36 s, con acercamiento a la cabeza del matón y comprobación de las cinco poses PNG originales \`assets/images/enemies/bully_0..4.png\`.

### RC4-005A — Robot de limpieza: base aprovechable, acabado insuficiente (P1 ALTA)

**Usuario:** de los seis enemigos nuevos, el robot es el de mejor calidad, bastante por encima del turista y del corredor de San Fermín, pero aún inferior a Miren y Sara. **No equiparar esta valoración relativa con aprobación.**
**Vídeo:** robot bajo, turquesa, silueta legible, rasgos todavía demasiado esquemáticos, menor riqueza de volumen/detalle y distinto acabado frente a la protagonista de alta fidelidad.
**Acción exigida:** pulir a partir de su mejor diseño, no sustituirlo automáticamente por arte peor; revisar forma, detalle, color/materiales, sombreado, escala y animación de espera/patrulla/alerta/impacto/derrota. Comparar cada pose con protagonistas a la **escala real del juego**.
**Aceptación:** sprite real y atlas mejorado, render StagePainter y vídeo del móvil muestran calidad coherente con el estándar de Miren y Sara, sin perder la silueta que funciona. No bastan variaciones numéricas ni hashes PNG.
**Estado:** REGISTRADO, NO CORREGIDO / NO APROBADO.

### RC4-005B — Colegio: plantas poligonales, sombras desenfocadas y paredes incoherentes (P1 ALTA; amplía RC4-002)

**Usuario:** plantas visiblemente geométricas/poligonales, paredes de calidad muy baja y fondo desenfocado; la composición conjunta es «espantosa».
**Vídeo:** se observan plantas con hojas triangulares, estructura repetitiva de marcos y ventanales beige, siluetas oscuras con apariencia de manchas fuera de foco en las ventanas, taquillas que contrastan bruscamente con los fondos y bibliotecas repetidas. Los paisajes exteriores se mueven correctamente en paralaje: **NO destruir ese avance**.
**Acción exigida:** reconstruir artísticamente las paredes y espacios escolares y sustituir vegetación/siluetas abstractas por vegetación detallada y elementos plausibles. Comprobar si el aparente desenfoque procede de resolución del origen, recorte, compositado o escala; NO limitarse a aumentar resolución o recolorear. Dar identidad diferenciada a pasillo, biblioteca, aulas y taquillas; mantener paralaje exterior.
**Aceptación:** recorrido real de varias pantallas con paredes nítidas, plantas pixel-art creíbles y zonas distinguibles; sin paneles/beige repetidos ni manchas oscuras difusas; comparativa RC4→siguiente versión en móvil y pantalla completa.
**Estado:** REGISTRADO, NO CORREGIDO (misma línea de trabajo que RC4-002).

### RC4-005C — Matón («bully»): pelo/gorra prácticamente no reconocible (P1 ALTA; defecto concreto de personaje clásico)

**Usuario:** «no se le ve el pelo o la gorra lo que sea que lleve».
**Vídeo:** en carrera/encuentro el matón con mochila roja muestra cabeza con parte superior casi desnuda, algo que contrasta con el resto del sprite.
**Comprobación de recursos reales:** las cinco poses originales \`bully_0.png\` a \`bully_4.png\` tienen alfa y cabeza visible. En \`bully_0.png\` hay un **pequeño copete/mancha oscura**, no una gorra identificable; a escala de partida el peinado se pierde y parece que falte parte de la cabeza. Las cajas alfa reportadas para \`bully_0..3\` comienzan en (6,6), sin prueba de que el motor haya recortado la parte superior. El selector de animación emplea \`classicEnemyFrame(kind:'bully',...)\` con las cinco poses. **No atribuir con certeza al escalado o recorte del motor sin comparar cada PNG en StagePainter.**
**Acción exigida:** revisar diseño de cabeza, peinado o eventual gorra según caracterización final, y redibujar coherentemente los cinco fotogramas si el original es incompleto. Conservar cuerpo, mochila, proporciones y detalles que sí funcionan. Verificar pivotes, transparencia, distinción del pelo y continuidad fotograma a fotograma.
**Aceptación:** primer plano comparativo PNG originales/candidatos + captura real en el juego: cabello o prenda de cabeza claramente reconocible en reposo, marcha, ataque, impacto y derrota sin desaparecer entre poses.
**Estado:** REGISTRADO, NO CORREGIDO.

**Regla común:** Esta ronda recoge observaciones; no modificar sprites ni compilar otra APK hasta que el usuario cierre la lista. No llamar «aprobado» al robot por ser el mejor de los provisionales.

## ACTUALIZACIÓN EXCLUSIVA RC5 — 30/10/2026 (RC4-001A/001B)

- **Estado verificado:** incidencias de fullscreen corregidas en código y **superadas en CI/Flutter real**, pero **NO confirmadas todavía en el Redmi Note 14**.
- **Versión:** `0.9.1-rc.5+36`; APK compilada desde `64fbe769ee62e8e8dd68e5575f0df9ec02319043`. GitHub Actions `41085018018`, SUCCESS.
- **Evidencia:** 15 capturas reales de portada, mapa y los 7 capítulos, en 16:9 / 19,5:9 / 20:9 (los 7 en 20:9), comparadas por dimensiones del render y diversidad de color en ambos extremos; ZIP descargable en la prerelease RC5.
- **Android:** orientación `sensorLandscape`, `resizeableActivity=true`, aspecto máximo `2.8` configurados y comprobados en el manifest de la build.
- **Entrega:** https://github.com/Creadordevida/Hermanas-Pixel/releases/tag/playtest-0.9.1-rc5-fullscreen
- **Documento:** `docs/continuidad/RC5_FULLSCREEN_VERIFICACION_2026-10-30.md`.
- **Condición para CERRAR de forma definitiva:** vídeo del usuario en Redmi Note 14 confirmando que portada, mapa y gameplay ocupan el área horizontal de extremo a extremo con controles funcionales. No declarar confirmación en dispositivo a partir de capturas de `flutter test`.
- **Resto de incidencias RC4-002...005:** SIN CAMBIOS. Mantenerlas en lista abierta para próxima ronda de arte.

## ORDEN DE CONTINUIDAD: RC4-001A/001B ES REQUISITO OBLIGATORIO DE LA SIGUIENTE VERSIÓN CON TODAS LAS MEJORAS

**Decisión del usuario:** la corrección de pantalla completa (PRIMER punto de la lista) debe conservarse e integrarse obligatoriamente en la próxima versión que reúna las mejoras de escenarios/enemigos, aunque se desarrolló de forma aislada en RC5. **No puede quedar fuera ni regresarse al render 800×450 con bandas**.

**Base técnica de partida ya integrada en la rama:** `lib/game_viewport_twc.dart`, cambios de `lib/main.dart`, `lib/adaptive_title_screen.dart`, y `tools/configure_android_landscape_twc.py`. Las pruebas `test/game_viewport_twc_test.dart` y `test/fullscreen_real_render_rc5_test.dart` deben conservarse y volver a ejecutarse al integrar las demás mejoras. Mantener mapa, selección, controles, cámara y los siete capítulos en fullscreen sin deformación. Integración de nuevas mejoras NO autoriza revertir el viewport dinámico.

**Criterio bloqueante de la futura APK autorizada:** conservar fullscreen en portada, mapa, selección y siete capítulos; probar proporciones 16:9, 19,5:9 y 20:9 con capturas auténticas de Flutter y comprobación posterior en Redmi Note 14. La RC5 pasó CI/Flutter, pero sigue pendiente de confirmar físicamente en móvil. Si el usuario detecta un problema en RC5, corregirlo e incluir la solución más reciente antes de esa APK.

**IMPORTANTE:** el usuario ha prohibido producir o iniciar otras APK/Actions de compilación hasta nueva autorización expresa. Registrar e implementar las mejoras posibles sin APK mientras tanto.

**Actualización RC4-002 y RC4-005B:** reconstrucción de 27 PNG en local y código preparados en GitHub, pero todavía PENDIENTE de transferencia binaria y validación Flutter/Android; véase `docs/continuidad/COLEGIO_RECONSTRUCCION_2026-10-30.md`. Los problemas NO se dan por corregidos en APK.
