# Portada y mapa 20:9 — reparación RC8 (2026-11-08)

## Causa comprobada
En RC7, la portada se pintaba centrada con `AspectRatio(800/450)` y fondo lateral uniforme; el mapa se pintaba dentro de `SizedBox(width:800,height:450)` con fondo uniforme. El contenido jugable utilizaba `GameViewportTWC` y sí aprovechaba la pantalla real. El problema era específico de los menús, no del modo inmersivo Android.

## Arte original y procedencia
- Portada recibida del usuario: PNG de 1098×617 (adjunto 2026-11-08).
- Mapa aprobado recibido: PNG de 1672×941.
- Se ampliaron únicamente sus laterales mediante edición generativa y posterior composición del contenido central original a la altura de la salida panorámica.
- Los nuevos archivos (1870×841; proporción próxima a 20:9) son `assets/images/title_wide_20x9_approved.webp` y `assets/images/worldmap/pamplona_wide_20x9_approved.webp`.
- Los originales `title_cars_fixed_091.png` y `worldmap/pamplona_aprobado.png` permanecen intactos. Los WebP son candidatos hasta inspección de capturas auténticas.
- Centro preservado desde los PNG suministrados por el usuario, ajustado a la altura de la panorámica, con transición de 32 píxeles en cada unión. No equivale a identidad byte por byte con el PNG previo del repositorio, cuya descarga privada estaba bloqueada.

## Integración
- `AdaptiveTitleScreen`: una sola imagen panorámica `BoxFit.cover` ocupa todo el viewport, sin segundo bitmap central ni franjas de `ColoredBox`. Los hitboxes siguen calculados a partir de la composición aprobada de 800×450.
- `HermanasGame._map`: fondo panorámico único; los hitboxes originales de 1672×941 se transforman con escala basada en altura y desplazamiento horizontal centrado, sin estirar ilustración. Menú y contador se sitúan respecto del mismo espacio de arte.
- Los parámetros QA `qaTitle`/`qaMap` evitan cargar escenas/enemigos ajenos a esta prueba; no se usan en la aplicación normal.
- `test/title_map_rc7_real_render_test.dart` produce capturas reales del render de Flutter a 800×450, 975×450 y 1000×450, espera la decodificación del panorama específico y rechaza laterales cromáticamente uniformes a 20:9.
- `.github/workflows/title-map-rc7-qa.yml` ejecuta análisis, tests y registra imágenes de Flutter bajo `qa/title_map_rc7_flutter/` solo si todo pasa.

## Criterio de aceptación
1. Flutter analyze y testWidgets en verde.
2. Capturas reales 20:9 con paisaje a ambos extremos (sin barras y sin duplicación).
3. Botones de partida, continuación, capítulos y menú pulsables sobre el elemento dibujado.
4. Inspección humana de las seis capturas del motor y prueba final en Redmi Note 14.
5. No afirmar aprobado definitivamente ni preparar APK hasta completar esos controles.

## Aprendizaje reutilizable
No confundir `BoxFit.contain` sobre un fondo plano con soporte panorámico. Los menús exigen arte perimetral extra, un único bitmap canónico, transformación de controles en el mismo sistema de coordenadas y captura del widget **real** como evidencia.
## Resultado de QA real (08-11-2026)
- Ejecución `42462533678`: **SUCCESS**. Flutter analyze, pruebas de geometría y botones, y seis capturas auténticas de Flutter superadas. Ver https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/42462533678.
- Capturas guardadas bajo `qa/title_map_rc7_flutter/` (title/map en 16:9, 19.5:9 y 20:9), con prueba cromática de ambos extremos a 20:9.
- Los seis recursos PNG de QA se han verificado por su SHA en la rama tras el push del propio workflow.
- **Falta aceptación visual humana y prueba en Redmi Note 14.** No sustituye la inspección de la siguiente APK.

## Revisión tras feedback visual del usuario
- El usuario aprobó expresamente el mapa 20:9 y la ampliación lateral de la portada, pero señaló barras blancas bajo **Continuar** y un parche rectangular de pavimento en la zona baja.
- Las barras pertenecían al `Text('Sin partida guardada')` superpuesto a la imagen: se eliminó; el botón desactivado conserva su estado funcional.
- La comparación del PNG fuente con la captura real permitió localizar el parche en la región donde Flutter superponía `twc_title_mark_clean.png`, no en la panorámica. Se quitó esa imagen opaca y se mantuvo la marca tipográfica transparente de TWC. Ningún píxel de la panorámica aprobada ni el mapa fue alterado.
- QA real repetida con éxito en ejecución `42463124002`: analyze, botones, seis capturas y guardado Git, incluida `qa/title_map_rc7_flutter/title_20_9.png`. **Pendiente aprobación visual de esta nueva captura por el usuario.**

## Segunda corrección fina tras captura del usuario
- Se observó todavía una banda de baldosas claras bajo la figura del padre, aunque las antiguas manchas habían desaparecido. El WebP panorámico local en esa región presenta pavimento continuo; se identificó la última capa superpuesta de marca `g.logo` como fuente residual.
- Se retiró la totalidad del sello/texto TWC overlay de la portada (no se elimina de ningún otro lugar del juego). La marca volverá solo con un recurso de transparencia verificada. La imagen panorámica, el mapa y las zonas táctiles no se han modificado.
- Ejecución QA `42463692214`: pruebas y guardado de capturas auténticas **SUCCESS**. Nueva `qa/title_map_rc7_flutter/title_20_9.png` disponible para aceptación visual del usuario.
