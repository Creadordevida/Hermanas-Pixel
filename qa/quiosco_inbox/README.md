# Bandeja de importación del Quiosco RC7 — Plaza del Castillo

Subir aquí el fichero **QUIOSCO_RC7_SUBIR_GITHUB_2.zip**, sin extraer, en la rama
`work/revision-visual-20261028-continuidad` del PR #5.

El workflow `.github/workflows/quiosco-rc7-only.yml` valida el SHA256 fijo,
39 archivos WebP de 960×390, un único maestro del quiosco, y ejecuta
Flutter/StagePainter para 18 vistas y 38 uniones en tres relaciones de aspecto.
Las imágenes y pruebas se guardan en GitHub si la QA pasa.

**IMPORTANTE:** este es arte **candidato**. No está aprobado ni activado
para builds Android normales. Si las uniones/repeticiones no cumplen
el estándar de Estafeta/Ayuntamiento, hay que corregir y repetir la integración.

No genera APK ni fusiona PR.
