# Ayuntamiento RC7 — 2026-11-04 — integración preparada, arte candidato

## Estado comprobado
- `lib/main.dart`: nuevo renderizador condicional de 39 paneles para stage=1, anclado a velocidad física 1:1. El suelo `ground_1`, colisiones y física no se tocan. No se cargan los antiguos `scene_1`/`mid_1` cuando RC7 está habilitado.
- `test/ayuntamiento_rc7_real_render_test.dart`: 18 capturas StagePainter auténticas para 800×450, 975×450 y 1000×450; 6 posiciones con dos parejas de cámara +60.
- `test/ayuntamiento_rc7_all_joins_render_test.dart`: las 38 transiciones en 20:9.
- `test/ayuntamiento_rc7_contract_test.dart`: cobertura 39×960 sobre `stageWidth` 36500, suelo y arte activado en la ejecución de QA.
- `tools/import_ayuntamiento_rc7_zip.py`: importador del ZIP exacto con hashes SHA256 individuales, geometría y fachada principal una sola vez.
- `.github/workflows/ayuntamiento-rc7-only.yml`: camino ZIP → comprobación SHA → `pubspec.yaml` → análisis Flutter → 18+38 capturas → regresiones → commit de resultados en PR5; sin APK ni merge.

## Arte local pendiente de transferencia a GitHub
- Archivo: `AYUNTAMIENTO_RC7_PANELES_PARA_GITHUB.zip`, SHA256: `e93b3e0c400fe5d9268299f665eecbca6f5e087255fe5989c00b2d3690a74d1a`, tamaño: 8.703.389 bytes.
- Contiene 39 WebP de 960×390, 1 imagen maestra de 1170×390 para el selector, manifiesto SHA256 y una vista compuesta de cinco tramos.
- Fachada histórica principal estilizada en posición de mundo 17920, una aparición.
- Los demás edificios son **composiciones artísticas candidatas**, con 40 motivos base y adaptaciones. No son una reproducción georreferenciada de edificios verificables del entorno de la plaza; algunos elementos visuales se reutilizan. Se requiere inspección visual y posibles correcciones antes de aprobar.
- Se descartó la idea de utilizar collages con UI falsa como recursos o capturas del juego.

## Puerta de publicación
**NO LISTO PARA RC7** hasta que el ZIP se incorpore en `qa/ayuntamiento_inbox/AYUNTAMIENTO_RC7_PANELES_PARA_GITHUB.zip`, GitHub Actions complete sin errores, se inspeccionen efectivamente las capturas auténticas y se determine si la fidelidad artística y uniones son suficientes. El flag `TWC_AYUNTAMIENTO_RC7_ART` permanece apagado por defecto; jamás promover automáticamente arte candidato sin inspección.

## Protecciones
Sin cambios en enemigos, sprites, control, física, colegio, danza, capítulo 1 ni Estafeta. No APK. PR #5 abierto y sin fusión.
