# Estafeta RC7 — segunda generación de paneles (1 noviembre 2026)

## Resultado real de esta sesión

Se ha rehecho localmente el generador de 39 paneles que anteriormente cortaba las fachadas cada 320 px. La nueva composición crea primero un continuo de arquitectura a partir de 32 recortes delimitados aproximadamente por medianeras en las cuatro ilustraciones maestras. Después divide ese continuo en 39 paneles de 960×390. Esto evita que los límites **entre archivos** produzcan saltos adicionales de posición o escala; sin embargo, los encuentros entre distintas fachadas siguen necesitando inspección artística.

Pruebas locales sobre el nuevo lote: 39/39 WebP legibles, cada uno 960×390, hashes SHA-256 coincidentes con manifest.json; suma de WebP 7.209.382 bytes. La diferencia media RGB por canal de las dos columnas a ambos lados de las 38 juntas entre paneles es 21,3 (mínimo 7,8; máximo 51,4). **No se puede declarar que las costuras sean invisibles**. La reutilización de los 32 motivos es entre 6 y 8 veces por fuente: sigue siendo una limitación artística relevante.

**Arte empaquetado en el entorno de conversación:** ESTAFETA_RC7_RECONSTRUCCION_CORREGIDA.zip, que contiene las cuatro ilustraciones, los 39 paneles, el código generador y manifiesto. No está subido aún al repositorio. Si se integran los WebP deben copiarse en assets/images/estafeta_rc7, agregar dicho directorio a pubspec.yaml, ejecutar con TWC_ESTAFETA_RC7_ART=true y producir capturas StagePainter reales.

**Código ya en rama:** lib/main.dart implementa el motor opcional 1:1 y test/estafeta_rc7_real_render_test.dart prepara 12 capturas. Corregido test/estafeta_rc7_contract_test.dart para que no rechace el modo explícito de QA activado.

## Estado de aprobación

GENERADO: sí, en contenedor; COMPROBADO localmente: dimensiones, hashes y contacto gráfico; CARGADO EN GITHUB: no; FLUTTER: no ejecutado; ANDROID: no; ARTE DEFINITIVO: no; APROBACIÓN DE USUARIO DE LOS PANELES: no.

Se conservan intactos sprites, enemigos, física y resto de capítulos. Sin APK ni fusión de PR.
