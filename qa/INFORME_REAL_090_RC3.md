# Informe verificable de la candidata 0.9.0 RC3

## Estado

**CANDIDATA PARA PRUEBAS — NO APROBADA COMO SIGUIENTE VERSIÓN FINAL.** Se conserva intacta la referencia original v0.8.0.

## Controles ejecutados en el entorno de creación

- `python3 qa/verify_resources.py`: recursos originales 0.8.0 e iconos protegidos intactos.
- `python3 qa/verify_candidate_assets.py`: todas las 117 referencias del motor anterior se resuelven; añadido el mapa exacto aprobado (ruta del mapa reemplazada).
- `python3 qa/scene_metrics_vnext.py`: confirma por SHA256 la imagen de mapa aprobada, ausencia de espejado/estirado y presencia de metadatos de suelo. Señala seis panoramas sin empalme gráfico válido.
- `python3 -m unittest discover -s qa -p 'test_*.py'`: 40 pruebas locales superadas.
- `python3 qa/source_sanity.py`: delimitadores Dart equilibrados, **NO certifica sintaxis Dart**.
- `python3 qa/release_gate.py --strict`: BLOQUEADA; falta evidencia artística, compilación y Android.

## Cambios técnicos

1. Fondo: original 1320 × 480 a escala nativa; suelo alineado con offset por capítulo; cero inversiones horizontales automáticas de escenarios; preservado el suelo de losas.
2. Mapa: imagen exacta previamente aprobada y siete zonas de toque sobre los carteles integrados; botón MENÚ del arte original, contador dinámico.
3. Enemigos: escala derivada del `idle_0` de cada especie, independiente de dimensiones de pose; altura de colisión ajustada.
4. Protagonistas: escala común para los fotogramas de Miren, Sara y padre basada en su pose de espera.
5. Paloma: PNG de mayor detalle y silueta reconocible, con cinco estados que deben revisarse en Android.
6. Auditoría Flutter prevista: capturas de cada capítulo en cuatro puntos del recorrido y del selector.
7. GitHub Actions: analiza solamente `lib` y `test`, compila Android si pasa las pruebas y publica APK como artefacto de pruebas.

## Lo que no se puede certificar

- Las uniones y variedad suficientes a lo largo de cinco minutos siguen pendientes de fondos adicionales diseñados por capas y de revisión de capturas reales. Es la limitación principal; la simple eliminación del espejo no hace mágicamente natural el recorrido.
- El vestuario definitivo y algunas animaciones humanas siguen pendientes: no se han sustituido por el intento geométrico que se descartó.
- No se ha compilado ni jugado un APK Android desde el entorno de creación. GitHub y el teléfono deben confirmar el resultado.

**Regla de calidad:** No llamar versión final a esta RC3 hasta superar la revisión visual y jugable, y sustituir recursos artísticos que aún no alcanzan lo aprobado.
