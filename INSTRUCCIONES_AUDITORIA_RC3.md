# RC3 — corrección de diagnóstico de capturas Flutter

## Situación observada
- `android-apk-candidato`: pasa y genera APK.
- `Capturar mapa y chapter 1 (Flutter real)`: falla. El registro enviado **NO muestra** la excepción: está plegada en la línea 8 (triángulo ▶ antes de `Render Flutter REAL`).
- `qa/rendered_from_flutter/*.png`: no hay PNG porque la prueba de capturas terminó antes de escribirlos; es consecuencia, no causa confirmada.

## Archivos del parche
1. `test/qa_render_capture_test.dart`: amplía el máximo de carga inicial de recursos de 90 a 180 segundos, la espera de widgets de imagen de 100 a 240 intentos y añade marcas de progreso y de cada escena. No cambia el renderizador, el motor ni el APK.
2. `.github/workflows/build.yml`: ejecuta la captura con `--reporter expanded` para que el error se vea en GitHub, da más margen al paso y al trabajo de auditoría. La auditoría **sigue fallando** si falla el test: no se oculta ni desactiva ningún control.

## Aplicar
1. Descomprimir **el contenido** de este ZIP en la raíz del repositorio, sustituyendo exactamente los dos archivos indicados.
2. `Commit` y `Push` en GitHub Desktop.
3. Abrir Actions → `Miren y Sara RC3 - Capítulo 1 físico - APK y auditoría` → job de capturas.
4. Si falla, copiar el error del paso (usar el triángulo ▶ de la línea de test si aparece plegado): las nuevas marcas `QA_CARGA_RECURSOS`, `QA_INICIO_ESCENA` y `QA_CAPTURA_ERROR` permiten identificar el momento exacto.

## Qué se ha probado
- YAML analizado sin errores de estructura; siete comprobaciones estáticas del parche.
- 173 pruebas Python existentes: superadas en la copia FIX2.
- **No hay Flutter instalado en este entorno**; el resultado real del widget test solo podrá confirmarse en GitHub.

Este parche NO certifica que la prueba gráfica esté resuelta: aumenta el margen ante cargas lentas y hace visible la causa concreta cuando falle. Si el fallo es de otro tipo, el registro completo permitirá corregirlo sin tocar la jugabilidad.
