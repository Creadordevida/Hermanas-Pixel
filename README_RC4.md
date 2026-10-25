# Las aventuras de Miren y Sara — 0.9.0 RC4

**Candidata técnica para GitHub y pruebas de regresión; NO APROBADA ARTÍSTICAMENTE.**

Partimos de la RC3 real y conservamos la versión 0.8.0 como base artística protegida. La RC4 no sustituye a la 0.8.0 como referencia visual.

## Cambios efectivamente integrados en el juego

- Fondos ahora compuestos por un paisaje lejano que solo se desplaza dentro de la propia ilustración, una capa cercana de mobiliario y vegetación con tiles derivados del mismo pixel art, y suelo original a velocidad de mundo. No hay espejado ni repetición de coches, Ayuntamientos o quioscos completos.
- Siete texturas auténticas de suelo con bordes que coinciden; nuevas capas cercanas en cada capítulo; transición entre pasillo, aula e informática del colegio **una vez por nivel**.
- Para danza, se construyó un nuevo fondo a partir de los espejos y barras originales y un suelo de parquet horizontal extraído de la ilustración aprobada de la bailarina rival. El fondo antiguo se conserva sin alteraciones.
- Reajuste de la visibilidad de Ayuntamiento y quiosco para que la capa cercana no tape sus fachadas hasta una altura artificial.
- Para todos los enemigos humanos y criaturas: 50 recortes de alfa visibles calculados automáticamente y usados al dibujar cada fotograma, con anclaje constante y escala basada en la pose base. Elimina la variación de posición causada por márgenes transparentes, sin inventar miembros ausentes.
- El mapa aprobado de Pamplona se conserva exacto, con zonas seleccionables sobre sus rótulos originales.

## Verificación

```bash
python3 qa/verify_resources.py
python3 qa/verify_candidate_assets.py
python3 qa/verify_layered_scenes.py
python3 qa/scene_metrics_vnext.py
python3 -m unittest discover -s qa -p 'test_*.py'
python3 qa/release_gate.py --strict
```

**ATENCIÓN:** la última orden `--strict` debe bloquear la aprobación artística hasta disponer de evidencias reales de Flutter y Android y aprobación del arte. Las anteriores prueban integridad y contratos técnicos, no calidad artística definitiva.

GitHub Actions genera un APK **candidato** si análisis Dart, pruebas Flutter y compilación funcionan; el informe de aprobación estricta es un artefacto aparte. La comprobación Android la realiza el usuario.

## Problemas no resueltos todavía

- Los ocho gráficos de vestuario especial mantienen el acabado RC3; se rechazó un intento de traje redibujado por no alcanzar la calidad aprobada. No se han sustituido silenciosamente por otro diseño.
- 27 de los 50 fotogramas de enemigos tocan su borde de imagen. El anclaje se ha corregido, pero **puede seguir faltando parte del dibujo**; revisión artística de cada pose pendiente.
- Las piezas cercanas se repiten como tiles, al estilo de los plataformas SNES. Su continuidad matemática no garantiza variedad artística suficiente durante cinco minutos. Revisar capturas reales y recorrido.
- Este entorno no dispone de Flutter ni emulador Android: compilación y ejecución quedan pendientes de GitHub y del teléfono.

Si esas pruebas muestran errores de arte o jugabilidad, la candidata RC4 no está aprobada. Se corrige sobre la copia de desarrollo conservando los originales.

## Trabajo posterior a RC4 (no entregado como versión aprobada)

- **5 corazones por protagonista** ya integrados en código y HUD, con pruebas automáticas nuevas. Consultar `qa/INFORME_CAMBIO_CINCO_CORAZONES.md`.
- La nueva candidata sigue pendiente de completar los trajes, revisar los fotogramas dañados y validar las escenas en Android.
