# Cierre integral PR5 — control de siete bloques

**29/10/2026.** Este informe es el estado REAL del repositorio; no constituye aprobación del juego. Rama de desarrollo `work/revision-visual-20261028-continuidad`, main intacta.

## Regla de cierre

- **COMPLETADO**: recurso en GitHub, generado y examinado, prueba motor real, sin defecto crítico, evidencia firmada.
- **PENDIENTE DE VALIDACIÓN**: código o generador preparado, prueba no realizada o arte aún sin inspeccionar.
- **BLOQUEADO**: falta un archivo imprescindible o una condición explícita de publicación.
- **Nunca** marcar un bloque completado porque únicamente existe un commit o un test sin ejecutar.

## Estado actual por bloques

| Bloque | Código y herramientas | Prueba/recurso que falta | Estado |
|---|---|---|---|
| A Portada | Geometría adaptable, botones, recuperación marca TIKU, extracciones y QA | `title_wide_20x9.png` y `twc_title_mark_clean.png` **no figuran en el árbol GitHub**; revisar Flutter 16:9-20:9 | **BLOQUEADO** |
| B Colegio | 27 variantes planificadas, variedad de muebles, puertas, máscaras; corregido render Python que aún pintaba pizarras duplicadas | `z2_panel_8.png` y demás paneles nuevos no regenerados/confirmados; vistas de Flutter y juicio visual frente a capítulo 1 | **PENDIENTE DE VALIDACIÓN** |
| C Danza | Generador de 3 variantes por estancia, fondos con parallax | Revisar panoramas regenerados en múltiples cámaras y una secuencia animada | **PENDIENTE DE VALIDACIÓN** |
| D Fútbol | Generador de 3 capas y unión orgánica | Comprobar fondos reales y 12 cámaras en Flutter sin líneas horizontales | **PENDIENTE DE VALIDACIÓN** |
| E Seis enemigos nuevos | Generadores de atlas, IA, golpe y derrota; capturas de QA preparadas | Los atlas nuevos no están guardados como PNG finales en la rama; 6 banderas `enemyArtValidated=false` | **BLOQUEADO** |
| F Cuatro clásicos | Poses y animaciones nuevas, retoque Python de 22 PNG, tests | Ejecutar retoque, inspeccionar comparativas y motor real | **PENDIENTE DE VALIDACIÓN** |
| G Integración | Tests Dart/Python, pruebas de carga, autosave, físicas y salud existentes | Regresión integral y pruebas Android reales tras autorización | **PENDIENTE DE VALIDACIÓN** |

## Fallos reparados durante este encargo maestro

1. `93fcec3a`: se eliminan pizarras/estanterías duplicadas del PREVIEW Python que ya se habían eliminado del render de Flutter.
2. `725b0556`: YAML manual de revisión corregido para que genere realmente el colegio y **después** audite los recursos, en lugar de plegar ambos comandos.
3. `07a3dd0b`: nuevo `qa/next_version_preflight.py`, inventario de los siete bloques con archivos reales y bloqueos expresos.
4. `e96eab9e`, `08152e58`: preflight incorporado a pipelines manuales y supresión del artifact redundante de dependencias.
5. `92ec29bf`, `c8cc5b19`: artefactos manuales con retención de un día para reducir consumo de los 0,5 GB de GitHub Actions.
6. `d5b40e0b`: pruebas unitarias preparadas para los bloqueos del preflight (sin ejecutar).
7. `b8f85295`, `0a6cbc70`, `c170632f`: método reutilizable `docs/FRAMEWORK_SNES_TWC` para el futuro GPT.

## Evidencias y ejecución

- **Verificado desde la API de GitHub**: existencia y contenido de los archivos anteriores, ausencia de assets bloqueantes del árbol, branch y commits. 
- **NO ejecutado en esta sesión**: scripts que necesitan el checkout y PNG originales, Flutter, pruebas de la suite Python de GitHub, Android, Actions y APK.
- **No realizado**: activación de seis enemigos sin calidad inspeccionada, síntesis de panorama falsa, aprobaciones ficticias.
- El nuevo preflight escribe `qa/NEXT_VERSION_PREFLIGHT.json` en el checkout y puede ejecutarse localmente con `python3 qa/next_version_preflight.py`; `--strict-assets` abortará si falta arte indispensable. Su resultado nunca sustituye la inspección estética.

## Cómo continuar sin perder progreso

1. Obtener un checkout completo de la rama y ejecutar los generadores Python, sin Actions.
2. Resolver primero el arte panorámico real de portada y las seis ilustraciones enemigas, actualmente bloqueantes.
3. Regenerar 27 escenas del colegio, revisar **cada una** en imagen y tramos contiguos antes de firmar calidad.
4. Verificar también danza/fútbol y los 22 sprites clásicos.
5. Ejecutar tests Python y capturas de Flutter LOCALMENTE; corregir defectos observados.
6. Sólo al autorizar el usuario, ejecutar una ronda de Android y verificar en dispositivo.
7. Registrar hash de recursos aprobados y la evidencia; terminar la versión sin mezclar incompletos.

**Nota:** no es posible prometer que todo está cerrado mientras falte el arte, sus capturas auténticas o una prueba Android. El repositorio está preparado para seguir cerrando, no aprobado aún para publicación.