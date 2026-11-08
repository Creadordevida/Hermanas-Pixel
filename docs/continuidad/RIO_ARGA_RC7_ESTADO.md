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

7. `lib/main.dart`: mecánica efectiva del tronco móvil (arrastra al personaje), roca hundible (desciende tras el aviso) y reaparición correcta sobre checkpoints, commit `740bde1`.
8. `test/arga_rc7_real_render_test.dart`: pruebas de movimiento del tronco y hundimiento dentro del ticker Flutter, commit `2cf7972`.

9. `assets/images/arga_rc7/arga_far_rc7_candidate.webp` y `arga_mid_rc7_candidate.webp`: planos **candidatos** separados, skyline/puente y vegetación con alpha; commit `d3a8f61`. Se protegen y se compararán con la imagen original aprobada.
10. `lib/main.dart`: QA `stage==7` carga/dibuja planos lejanos y medios con velocidades distintas y apoyos a velocidad 1:1. Se eliminó la decodificación superpuesta del panorama descartado. Agua visible con pequeños brillos animados; commits `230fc64`, `47eee5e`, `c5ade03`.
11. `test/arga_rc7_real_render_test.dart`: comprueba ambas capas y ausencia del panorama antiguo duplicado, commit `3b26d23`.

12. `lib/arga_platform_rules.dart`: curso extendido determinísticamente hasta 36.500 unidades, huecos comprobables, variedad de tipos y checkpoints; orilla final sólida. Commits `9413b04`, `a31406c`.
13. `lib/main.dart`: renderiza todo el curso, no guarda checkpoints genéricos en huecos, añade monedas sobre apoyos y limita el desplazamiento de capas para que no aparezcan áreas vacías. Commits `c9455cd`, `233b9c1`, `caf5a26`, `51d2a08`.
14. `test/arga_platform_rules_test.dart`: tests de curso completo, checkpoints y llegada sobre suelo firme, commits `dc0846a`, `b9e995d`.
15. `test/arga_rc7_real_render_test.dart` y workflow: ocho capturas 20:9, desde inicio hasta zona final; commits `43d91b3`, `be0a122`.

16. Comprobación independiente de la geometría extendida: 140 apoyos, salida en x=36.630, salto plano 148,93 px, máximo hueco con deriva 106 px y 0 huecos inválidos. **Cálculo reproducido fuera de Flutter**, no QA de juego.
17. `assets/images/arga_rc7/arga_far_wild_candidate.webp` y `arga_mid_wild_candidate.webp`: segunda vista natural candidata, sin suelo falso, commit `46674a8`; `main.dart` mezcla progresivamente ambas zonas sin desplazar plataformas, commit `c32ca05`; test de decodificación `4540b92`.
18. Último check-run Arga observado `128697805328`: **failure en 2 s**, una anotación GitHub sin contenido recuperable mediante conexión; otros jobs fallan igualmente antes de ejecutar pasos. Requiere intervención para leer esa anotación o restaurar GitHub Actions.

## Bloqueo confirmado por captura del propietario (2026-11-08)
La anotación de GitHub Actions indica: "The job was not started because
recent account payments have failed or your spending limit needs to be
increased. Please check the 'Billing & plans' section..."
Esto explica el fallo en ~2 segundos y la ausencia de pasos y logs.
**No es un diagnóstico de error de Flutter ni de los tests.**
Requiere que el propietario revise facturación y límite de gasto de GitHub
Actions. No modificar el código para intentar sortear esta restricción.
Después de resolverlo, reejecutar `arga-rc7-qa.yml`, revisar ocho PNG
`StagePainter` 20:9 y corregir únicamente problemas efectivamente observados.

## Estado: NO validado
- El workflow de Arga **sí existe y se ejecuta** (identificado por check-run `arga-prototype`), pero aparece fallido a los pocos segundos y sin pasos/logs recuperables. Los workflows ajenos fallan del mismo modo. **No hay evidencia de compilación ni captura real**, y tampoco evidencia suficiente para atribuir el fallo al código. Revisar la anotación de GitHub Actions al disponer de ella.
- No hay capturas reales revisadas visualmente del Arga.
- Fondo, vegetación y soportes son una prueba auxiliar, no recursos finales aprobados. El agua tiene brillos dinámicos pero necesita validar su movimiento y continuidad real.
- Movimiento y hundimiento ya codificados, pero aún no verificados en Flutter; faltan agua animada, capas reales
  con parallax, nivel largo y revisión de ambos personajes.
- No activar el capítulo normalmente ni declararlo listo para RC7.

## Siguiente acción precisa
1. Consultar la anotación de error de GitHub Actions del job `arga-prototype`.
   La conexión actual no permite leerla y los logs devuelven `BlobNotFound`.
   Reanudar y corregir QA en cuanto el runner funcione; revisar las ocho imágenes.
2. Comparar las capturas con la referencia original *aprobada* y corregir
   las capas candidatas de fondo lejano, vegetación media y agua móvil, sin
   personajes duplicados ni artefactos en los límites del panorama.
3. Completar cinemática de tronco móvil, hundimiento de roca y checkpoints;
   validar aterrizajes de Miren y Sara y muerte real en cada hueco.
4. Revisar visualmente y completar variantes artísticas para los tramos largos
   (las capas actuales se fijan al agotar su recorrido para evitar huecos, pero
   no constituyen fondos definitivos de 36.500 px). Verificar una partida
   completa antes de habilitar capítulo 8 en el mapa.

## Alternativa gratuita acordada con el propietario (2026-11-08)
El propietario ha decidido **no asumir gasto adicional** para GitHub Actions.
Los presupuestos existentes de GitHub quedan **sin modificar**. El bloqueo
mostrado en Billing & licensing > Budgets and alerts incluye un presupuesto
Actions de 0 USD y estado `Usage blocked`. No recomendar eliminar presupuestos
ni ampliar límites sin autorización nueva.

Se han incorporado dos ejecutores locales:
- `scripts/run_arga_qa.ps1`: Windows/PowerShell, apropiado para un Lenovo con
  Flutter SDK instalado. Desde la raíz del repositorio ejecutar
  `powershell -ExecutionPolicy Bypass -File scripts/run_arga_qa.ps1`.
- `scripts/run_arga_qa.sh`: Linux/macOS con Flutter SDK en PATH. Ejecutar
  `bash scripts/run_arga_qa.sh`.

Ambos ejecutan `flutter pub get`, análisis de `lib`, pruebas de física y
capturas Flutter del Arga. Exigen ocho PNG reales de 1000x450 en
`qa/arga_rc7_flutter/`. No generan APK ni hacen push/merge; QA **aún no
se ha ejecutado** en ninguna máquina con Flutter.
Commits: `00bfd9f`, `1726ca4`.

**Próximo paso:** ejecutar uno de los scripts en una máquina con Flutter,
inspeccionar las ocho imágenes y corregir lo observado antes de activar el
capítulo. Puede realizarse sin suscripción adicional a GitHub.

## Avances adicionales sin coste (2026-11-08)
- QA local Windows: `scripts/run_arga_qa.ps1`, commit `00bfd9f`.
- QA local Unix: `scripts/run_arga_qa.sh`, commit `1726ca4`.
- Seguridad al caer: detener el tick tras muerte/reaparición para evitar recoger
  monedas o completar el capítulo en el mismo fotograma, commit `e9015de`.
- Reaparición al **alto real del checkpoint** (no siempre y=365), commit
  `a02e5be`.
- Casos de QA Flutter: una caída consume un corazón y reaparece; checkpoint
  avanzado a distinta altura, commits `659a24f`, `e37fdb5`, `83a2069`.
- Todo queda preparado, **no probado en Flutter** por ausencia de SDK local y
  bloqueo de GitHub Actions por presupuesto de 0 USD.
