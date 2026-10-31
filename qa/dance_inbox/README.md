# Entrada del ZIP aprobado de danza 0.9.1

Subir **solo** `DANZA_CINCO_ESCENAS_APROBADAS_091.zip` a esta carpeta en la rama `work/revision-visual-20261028-continuidad`.

SHA256 requerido: `d3127c7fbf33ff57a629e9bc05dcec9f38bb2de4adb2b21a38c1b7209ec222a2`.

El push del ZIP activa automáticamente `.github/workflows/dance-hifi-only.yml`: importa los cinco PNG exactos, verifica sus hashes, analiza Flutter, intenta once capturas auténticas de StagePainter 1000×450 y SOLO en caso de éxito guarda los recursos y evidencias mediante commit. Sin APK, sin merge.

Si la prueba falla, el ZIP permanece en el repositorio y los logs de Actions indican el fallo. No declarar integración artística aprobada por el mero hecho de completar la subida.
