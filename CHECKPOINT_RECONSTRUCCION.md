# Cómo recuperar el trabajo técnico del capítulo 1

Estado: **RC7 en desarrollo, pendiente de Flutter y Android**. Este archivo no acredita aprobación visual.

Base exacta:
1. `Las_aventuras_de_Miren_y_Sara_0.9.0_RC6_ENEMIGOS_ESCENARIOS_GITHUB.zip`, Library `libfile_d3157f6355908191af50fe3700cf6c0c`.
2. Aplicar encima `Parche_RC6_PORTADA_Y_CAPITULOS_QA_CORREGIDOS.zip`, Library `libfile_ae43209cb4048191ad78c072e6f460c0`.
3. Aplicar encima el contenido del checkpoint RC7, conservando intactos los demás archivos del juego.

Archivos añadidos/cambiados en RC7:
- `assets/images/chapter1/residential_curve.png`
- `assets/images/chapter1/green_promenade.png`
- `assets/images/chapter1/white_canopy.png`
- `assets/images/chapter1/rocket_park.png`
- `assets/images/chapter1/park_props_atlas.png`
- `lib/chapter_one_layout.dart`
- `lib/main.dart`
- `pubspec.yaml`
- `test/qa_render_capture_test.dart`
- `qa/test_chapter_one_neighborhood.py`
- `.github/workflows/build.yml`
- `README_RC7_CAPITULO1.md`
- `assets/images/enemies_hifi/rat_sheet.png`
- `assets/images/enemies_hifi/cat_sheet.png`
- `lib/creature_sheet_bounds.dart`
- `qa/ENEMIES_HIFI_MANIFEST.json`
- `qa/test_hifi_rat_cat.py`
- `qa/test_enemy_anchors.py`
- `qa/test_vnext_engine.py`
- `test/asset_integrity_test.dart`
- `test/qa_creature_render_test.dart`
- `CASO_QA_2026-10-26_RATA_GATO.md`
- `assets/images/enemies_hifi/pigeon_flight_sheet.png`
- `lib/animal_sprite_bounds.dart`
- `qa/test_wildlife_quality.py`
- `qa/WILDLIFE_QA_MANIFEST.json`
- `test/wildlife_mechanics_test.dart`
- `test/qa_wildlife_render_test.dart`
- `CASO_QA_2026-10-26_PERROS_PALOMAS.md`
- `lib/jump_visuals.dart`
- `qa/JUMP_QA_MANIFEST.json`
- `qa/test_jump_visuals_quality.py`
- `test/jump_visuals_test.dart`
- `test/qa_jump_render_test.dart`
- `CASO_QA_2026-10-26_SALTOS_SOMBRAS.md`
- `assets/images/chapter45/` (ocho nuevos gráficos reales)
- `lib/activity_chapters.dart`
- `qa/ACTIVITY_SCENES_MANIFEST.json`
- `qa/test_activity_chapters.py`
- `qa/check_activity_flutter_captures.py`
- `CASO_QA_2026-10-26_CAMPO_DANZA.md`

El checkpoint conserva el estado de estos cambios; no es una entrega final ni contiene el proyecto completo. Las fotografías originales están guardadas aparte y fueron referencias de arte, no texturas directamente cargadas por el motor.
