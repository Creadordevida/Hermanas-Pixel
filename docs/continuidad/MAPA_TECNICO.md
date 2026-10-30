# Mapa técnico
Juego: pubspec.yaml (0.9.1-rc.3+34), lib/main.dart (StagePainter), lib/chapter_one_world_tiles.dart (72 teselas, mundo 36500), lib/interiors_parallax_twc.dart, lib/football_parallax_twc.dart, lib/adaptive_title_screen.dart, lib/new_enemy_behaviors.dart, lib/classic_enemy_pose.dart.
Arte: assets/images/chapter1/, assets/images/interiors_parallax/school/ (27 paneles presentes), assets/images/interiors_parallax/dance/, assets/images/chapter45/football_parallax/, assets/images/enemies/.
Bloqueos: assets/images/title_wide_20x9.png, assets/images/twc_title_mark_clean.png y assets/images/enemies_new/ ausentes en árbol auditado.
Generadores: tools/build_interiors_parallax_twc.py, tools/build_football_parallax_twc.py, tools/generate_new_enemy_sprites.py, tools/refine_four_classic_enemies.py.
QA: qa/next_version_preflight.py (presencia, no calidad), test/, .github/workflows/.
Conocimiento reutilizable: docs/FRAMEWORK_SNES_TWC/README.md, 01_MOTOR_ESCENARIOS_PARALLAX.md, 02_PERSONAJES_ESTANDAR_MIREN_SARA.md, ERRORES_Y_SOLUCIONES.md y PROTOCOLO_ACEPTACION_VISUAL.md.
Método: 800×450, groundY=390, 36500 unidades, parallax .30/.56/1.00; preservar arquitectura y originales. Un futuro GPT para fantasía/ciencia ficción requiere herramientas, pruebas y ejemplos reales; estos documentos no son aún un GPT entrenado.