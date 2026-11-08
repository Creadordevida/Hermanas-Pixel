# Río Arga — estado comprobado RC7 (2026-11-08)

## Referencias vinculantes
- Referencia **aprobada por el usuario**: `docs/continuidad/referencias/rio_arga_concepto_aprobado_20261108.png` (SHA Git blob `7f10b75bc1bbe8c633ecb61ac157515df4bfa24e`). No sustituirla por ninguna propuesta posterior.
- Orden y metodología original: `docs/continuidad/RIO_ARGA_DESARROLLO.md`.
- Siete capítulos existentes 0–6 intactos. No APK, merge a main ni publicación.

## Hallazgo al reanudar
La inspección inicial fue incompleta: **ya existían** `lib/arga_platform_rules.dart`,
`test/arga_platform_rules_test.dart`, el documento de desarrollo y la imagen
aprobada. El modelo inicial añadido en esta conversación
(`lib/arga_crossing.dart` y `test/arga_crossing_test.dart`, commits
`a80108b` y `da2a162`) es redundante. **La fuente de verdad para el motor
se ha unificado en el modelo original `ArgaCourse`**. Los archivos redundantes
se conservan temporalmente, sin referencias en `main.dart`, hasta cerrar QA.

## Cambios comprobados y guardados
1. `lib/main.dart`: el índice QA 7, no seleccionable en el mapa normal, usa
   `ArgaCourse.landing` y `ArgaCourse.drowned`. Caída al río resta vida,
   checkpoint y reaparición; índices 0–6 usan el comportamiento previo.
   Integración física inicial `31460bb8`; unificación `e94e39b`.
2. `assets/images/arga_rc7/arga_concept_rc7_v1.webp`: **candidata no
   aprobada**, ilustración auxiliar, commit `0b026e7`. No reemplaza al concepto
   aprobado y **todavía no es parallax de tres capas**.
3. `assets/images/arga_rc7/arga_supports_rc7_v1.webp`: atlas candidato
   de orilla, roca, tronco y tablón con alpha, commit `2f72c45`.
4. `lib/main.dart` y `pubspec.yaml`: carga y dibujo de dos imágenes **solo
   cuando `qaStage:7`**; el mapa normal permanece con siete accesos. Commits
   `42f856d`, `59ed5f3` y refactor `e94e39b`.
5. `test/arga_rc7_real_render_test.dart`: solicita cinco capturas auténticas
   Flutter StagePainter 20:9 del tramo inicial. Commit `cc6db29`.
6. `.github/workflows/arga-rc7-qa.yml`: análisis, tests de plataforma,
   raster de cinco posiciones y guardado de evidencia en
   `qa/arga_rc7_flutter/` **solo si el job finaliza bien**. Commit `ba585c7`.

## Estado: NO validado
- La prueba automatizada específica del Arga aún no tiene resultado confirmado.
- No hay capturas reales revisadas visualmente del Arga.
- Fondo y soportes son una prueba auxiliar, no recursos finales aprobados.
- Faltan movimiento/hundimiento físico completo, agua animada, capas reales
  con parallax, nivel largo y revisión de ambos personajes.
- No activar el capítulo normalmente ni declararlo listo para RC7.

## Siguiente acción precisa
1. Ejecutar y consultar el workflow específico Arga. Corregir cualquier fallo
   del análisis, decoding, StagePainter o test, y revisar las cinco imágenes.
2. Comparar las capturas con la referencia original *aprobada* y construir
   fondos lejano/medio, agua móvil y elementos físicos independientes a partir
   de ella, sin personajes duplicados en el fondo.
3. Completar cinemática de tronco móvil, hundimiento de roca y checkpoints;
   validar aterrizajes de Miren y Sara y muerte real en cada hueco.
4. Ampliar por secciones y verificar una partida completa antes de habilitar
   capítulo 8 en el mapa.
