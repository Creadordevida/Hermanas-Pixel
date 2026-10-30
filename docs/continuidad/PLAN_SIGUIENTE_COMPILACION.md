# REQUISITO CRÍTICO — Integración de danza en la siguiente compilación

**Registrado 30/10/2026 por orden del usuario. NO ejecutar la compilación sin autorización expresa.**

## Bloque C: NO confundirse entre código y PNG integrados

En la rama `work/revision-visual-20261028-continuidad` existe código que corrige deformaciones en los nueve paneles de danza y genera PNG nuevos, pero los nueve PNG revisados durante el bloque C **NO están aún confirmados como bytes persistentes en la rama**. La mera existencia de nueve PNG antiguos no cumple este requisito.

## Condiciones vinculantes antes de compilar APK

1. En cada checkout del workflow ejecutar **después** de `tools/build_interiors_parallax_twc.py` el generador `python3 tools/build_dance_panels_twc.py`. No reutilizar nueve PNG antiguos solo porque existan.
2. Ejecutar **obligatoriamente** `python3 -m unittest qa.test_dance_proportions`; si no se reconocen fuentes, geometría, RGB original, transparencia y nueve imágenes distintas, **detener workflow antes de flutter build apk**.
3. Aplicar el mismo proceso de regeneración y comprobación en el job independiente de capturas Flutter, para evitar que el APK y las capturas utilicen imágenes distintas.
4. El manifiesto `qa/interiors_twc_lab/DANCE_PANEL_GENERATION.json` registra los SHA256 de los nueve archivos realmente generados. Conservar temporalmente los nueve PNG de ese job dentro del artefacto de control (retención 1 día). **Un artefacto no equivale a un commit en Git**: promover y conservar los PNG definitivos en la rama tras superar inspección visual sigue PENDIENTE y debe verificarse por SHA.
5. Visualizar sala de entrada, estudio y escenario en **capturas auténticas StagePainter**, incluyendo transiciones y muestras con cámara distinta. No aprobar gráficos basándose exclusivamente en pruebas Python o en archivos presentes.
6. Respetar el resto de puertas: portada real y seis enemigos con atlas aprobados; no considerar el juego listo mientras sigan bloqueados.

**Ejecución actual:** workflow NO ejecutado, APK NO compilada, GitHub Actions NO iniciadas. Este documento es una puerta de seguridad, no una certificación de danza terminada.

## Bloque D: fútbol

Una vez aplicado este control, el trabajo autorizado pasa al campo de fútbol. Cambios futuros de arte deberán seguir el mismo orden: generar PNG real → verificar proporciones y uniones → inspeccionar render Flutter → guardar SHA y arte aprobado.

## BLOQUEANTE NUEVO — enemigos E (30/10/2026)
Los seis enemigos siguen DESACTIVADOS. Antes de la siguiente APK, los seis atlas deberán estar creados como arte real de calidad comparable a 0.7.1, subidos como archivos binarios a GitHub, y vinculados a capturas reales de Flutter con hashes. `qa/check_new_enemy_signoff.py` bloquea cualquier flag activado sin evidencia de atlas y render; `qa/next_version_preflight.py --strict-assets` continúa bloqueando la APK mientras falte alguno. Los generadores procedimentales actuales son experimentales, no sustituyen a la aprobación artística. Véase `docs/continuidad/BLOQUE_E_SEIS_ENEMIGOS_2026-10-30.md`.
