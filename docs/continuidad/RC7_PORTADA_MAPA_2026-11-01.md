# RC7 — portada y mapa: diagnóstico y corrección parcial basada en vídeo RC6

**Estado: NO CERRADO ARTÍSTICAMENTE. No compilar APK ni declararlo definitivo.**

## Causa demostrada en código
`lib/adaptive_title_screen.dart` renderizaba `title_cars_fixed_091.png` como `BoxFit.cover` ocupando todo el viewport, y después volvía a renderizar exactamente la misma fuente centrada como `BoxFit.contain`. `lib/main.dart` hacía lo mismo para `pamplona_aprobado.png`. Esta doble superposición generaba árboles, farolas, letras, edificios y leyendas duplicadas en las bandas laterales 19.5:9 y 20:9 vistas en vídeo RC6.

## Corrección realizada (parcial)
- Eliminada la segunda capa `cover` en ambas pantallas.
- Conservado el arte aprobado completo y sin deformación en región central 800×450, y los hitboxes del mapa centrados.
- Sustituido temporalmente el fondo lateral duplicado por dos colores sólidos distintos, uno para portada y otro para mapa. **Esto produce franjas de color visibles en 19.5:9/20:9 y NO cumple la exigencia de panorámica artística completa.** No darlo por resuelto visualmente.
- Se añadió `test/title_map_rc7_real_render_test.dart` y el workflow `.github/workflows/title-map-rc7-qa.yml` con seis capturas auténticas de portada/mapa 16:9, 19.5:9, 20:9 en `qa/title_map_rc7_flutter/`.
- La comprobación Flutter analyze y el test `adaptive_title_screen_test.dart` pasan. El test de fullscreen histórico `fullscreen_real_render_rc5_test.dart` asume dos widgets Image en el mapa; al retirar duplicado ya no es válido y debe actualizarse preservando una evaluación visual estricta.

## Diagnóstico de capturas reales
- `qa/title_map_rc7_flutter/title_20_9.png`: el título, figuras y botones originales se ven una sola vez, pero hay márgenes azul liso de ~100 px a izquierda y derecha.
- `qa/title_map_rc7_flutter/map_20_9.png`: las siete etiquetas y mapa originales no se duplican, pero hay márgenes azul oscuro de ~100 px a izquierda y derecha.
- Para terminar, se requieren extensiones panorámicas únicas, artísticamente coherentes, para cada diseño aprobado (o una composición equivalente) **sin duplicar ni reflejar elementos**; conservar el contenido/hitboxes 16:9 intactos. Dibujar bandas sólidas NO satisface el requerimiento.

## Protección
Ningún original aprobado se ha cambiado. Sin cambios a enemigos ni físicas, sin APK, sin merge. Antes de RC7, exigir revisión visual final de los seis fotogramas sin márgenes planos y test de áreas táctiles.
