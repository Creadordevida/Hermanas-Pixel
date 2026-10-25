# Informe de reconstrucción RC4: evidencia y límites

**Estado: TRABAJO TÉCNICO EJECUTADO — VALIDACIÓN ARTÍSTICA Y ANDROID PENDIENTES.**

## Hallazgos de RC3

1. La misma panorámica de 1320 píxeles se repetía 27 veces a lo largo de un mundo de 36.500 unidades: aunque sin espejo, esto repetía fachadas y monumentos.
2. La ilustración de danza colocaba ventanas y barras sobre el tramo y=0..286, pero debajo aparecía una superficie de madera vertical de calidad insuficiente para el suelo.
3. Algunas poses enemigas tenían distintos márgenes transparentes; el dibujo se centraba respecto al lienzo, no respecto al cuerpo. Un fotograma tumbado podía parecer desplazado.
4. Los trajes RC3 no satisfacen el criterio de ropa redibujada: NO se declaran resueltos.

## Correctivos incorporados

- `lib/main.dart`: renderizado por capas lejanas, cercanas y suelo físico. Monumentos y panoramas lejanos se mantienen dentro del ancho de su imagen y no se repiten automáticamente.
- `assets/images/ground/stage_*.png` y `assets/images/mid/stage_*.png`: imágenes usadas DIRECTAMENTE por Flutter, generadas a partir de fondos existentes. Manifiestos con hashes y bordes comprobados.
- `assets/images/scenes/ballet_refined.png`: suelo de danza derivado de la ilustración aprobada y ventana/estudio originales. El archivo `ballet.png` se preserva.
- `lib/sprite_bounds.g.dart`: puntos de recorte de las 50 poses, obtenidos de los PNG realmente cargados por Flutter; el dibujado usa estos recortes.
- `qa/test_layered_qa.py`, `qa/test_enemy_anchors.py`: nuevas pruebas y pruebas negativas. Los cambios de tamaño por transparencia o bordes modificados activan controles.
- `qa/verify_layered_scenes.py` y `qa/scene_metrics_vnext.py`: métricas de los verdaderos tiles, no de los panoramas que ya no se repiten.

## Puertas de calidad

- Integridad de 0.8.0 y del arte aprobado: automatizable.
- Integridad de todos los assets realmente cargados: automatizable.
- Coherencia matemática de suelos, bordes, escala y recortes: automatizable.
- Dibujos completos, ropa natural, sombras, variedad de escenarios: **pendiente de inspección artística**.
- Capturas procedentes del renderizador Flutter: **pendientes de GitHub**.
- Recorrido Android, animaciones, colisiones, dificultad y 5 min: **pendientes de prueba en móvil**.

El contador de pruebas NO es un indicador de calidad artística. Conservar `release_gate.py --strict` como bloqueo de aprobación final.
