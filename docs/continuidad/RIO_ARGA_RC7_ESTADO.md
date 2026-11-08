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

## Tercera zona visual candidata (2026-11-08)
- Paisaje del tramo final: molino tradicional junto al Arga, arbolado y río
  continuo en la parte inferior; candidatos en
  `assets/images/arga_rc7/arga_far_mill_candidate.webp` y
  `arga_mid_mill_candidate.webp` (alpha), commit `9179765`.
- Transición QA entre vista urbana, tramo silvestre y molino; las imágenes
  son planos independientes y las plataformas conservan sus coordenadas y
  colisiones. Código `d9b9053`, test de carga `47a13d5`.
- La imagen original aprobada sigue siendo la referencia vinculante. Estas
  tres zonas son **candidatas** hasta comparar capturas Flutter reales.
- Conforme a la elección del propietario, la instalación de Flutter se
  **aplaza**; los scripts locales quedan preparados para más adelante.

## Variantes de apoyos y ajuste de píxeles (2026-11-08)
- Atlas alternativo alpha `assets/images/arga_rc7/arga_supports_rc7_v2_candidate.webp`
  guardado en `8b20c8a` (original intacto).
- Selección determinista de variantes sin modificar la geometría del salto,
  `lib/main.dart` commit `eaf3b19`; comprobación de carga `de5b4ff`.
- Diagnóstico de máscaras alpha al 20%: las primeras filas opacas en el
  atlas original son roca 257, tronco 280, tablón 296; en el alternativo son
  roca 281, tronco 280, tablón 293. El pintor ajusta cada recurso para colocar
  su primer píxel opaco sobre el tope de colisión, evitando pies flotantes.
- Estos recursos siguen siendo candidatos; las capturas auténticas continúan
  pendientes por decisión de aplazar Flutter y mantener GitHub Actions a 0 USD.

- Banco final ancho: dibujo por piezas de ~190 unidades para mantener escala
  pixel art coherente sin estirar una roca a 500 px; commit `1af79d4`.

## Progresión de dificultad — sin Flutter (2026-11-08)
- Curso por tres escalones: 24 apoyos ampliados fáciles (hueco medio aprox.
  65 px), 56 intermedios (75,5 px) y tramo final exigente (aprox. 84 px).
  Los checkpoints ampliados son rocas grandes y estables, sin hundirse ni
  desplazarse. Commit `05d40ee`.
- Simulación de las mismas reglas de generación: **135 apoyos totales**,
  final x=36.620, hueco máximo con deriva de troncos 118 px, sin saltos
  fuera del alcance plano calculado de ~148,9 px. Esto es comprobación
  numérica, no una prueba Flutter.
- Tests Dart para progresión ascendente y seguridad de checkpoints,
  commit `766af11` (sin ejecutar).
- Rocas hundibles: aviso visual de temblor entre 0,30 y 0,60 s de ocupación;
  corrección a desplazamiento entero para preservar pixel art. Commits
  `4986a28`, `8192748`.

## Preflight estático gratuito (2026-11-08)
- Nuevo `scripts/arga_static_preflight.py` (commit `9c22da3`) para revisar
  sin Flutter, GitHub Actions ni pagos: geometría y margen de saltos,
  progresión de dificultad, checkpoints seguros, orilla de salida, presencia
  de ocho WebP activos, firmas RIFF/WEBP, referencias del pintor y declaración
  de assets en `pubspec.yaml`.
- Revisión numérica **ejecutada independientemente** con los arrays recuperados
  del archivo real: 135 apoyos, 19 checkpoints, orilla final x=36.004–36.620,
  0 huecos inválidos, máximo salto requerido con deriva 118 px respecto a
  148,93 px de alcance plano, medias 65,125 / 75,5 / 83,844 px.
- Se comprobó que las ocho rutas de imágenes aparecen referenciadas en
  `lib/main.dart`. El preflight Python **se ha guardado pero todavía no se
  ha ejecutado sobre un checkout completo**; sus comprobaciones de cabecera
  WebP quedan pendientes. Ejecutarlo gratis con
  `python3 scripts/arga_static_preflight.py` desde una copia del repositorio.
- Sigue **sin** prueba Flutter, capturas reales, APK ni habilitación del
  capítulo en el mapa. Se mantienen intactos los límites de gasto de GitHub.

## Primera ejecución Flutter pública, sin APK (2026-11-08)
- Tras hacerse público el repositorio, se lanzó una única prueba deliberada de `arga-rc7-qa.yml` con marcador `.github/arga-qa-public-once.txt` (commit `0dcd17e`), run **42490249834**, job **128760844026**. El trigger de `push` se retiró inmediatamente en commit `d5d72af`; los 25 workflows siguen manuales.
- **GitHub Actions ahora sí inicia el runner estándar**: checkout, preparación Flutter 3.47.8 y `flutter pub get` terminaron correctamente. Esto confirma superado el bloqueo inicial de facturación para esta ejecución pública, no certifica facturación global.
- Resultado del job: `failure` en `flutter analyze --no-pub lib`, **solo warning** `unnecessary_non_null_assertion` en `lib/main.dart:2905:43`; tests físicos, ocho capturas y preservación de PNG quedaron `skipped`. Logs del job recuperados. No se generó APK.
- Corrección mínima aplicada a `lib/main.dart`: `alternate?alternateAtlas!:originalAtlas` → `alternate?alternateAtlas:originalAtlas`, commit `9021548`. No se modificaron hitboxes, arte, otros capítulos ni la lógica del nivel. **La corrección aún NO se ha revalidado en Flutter.**
- Siguiente paso: autorizar una segunda ejecución controlada del mismo QA sobre el nuevo HEAD, inspeccionar primero análisis/tests y después ocho capturas reales. No activar automáticamente el resto de Actions.

## Segunda ejecución Flutter pública y corrección de checkpoint (2026-11-08)
- Ejecución controlada [42490644673](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/42490644673), job `128762027854`: `flutter pub get` y **`flutter analyze --no-pub lib` superados** tras `9021548`.
- El paso de tests de física del Arga registró **10 casos correctos y 1 fallido**: `test/arga_platform_rules_test.dart:87`, «Checkpoint respawn is deterministic and never inside a river gap». Esperado `110.0`, obtenido `55.0`. El checkpoint inicial en x=0 sobrescribía `startX=110` al recorrer los checkpoints.
- Corrección mínima de `ArgaCourse.checkpointBefore`: `result = math.max(startX, s.x + 55);` en `lib/arga_platform_rules.dart`, commit `1b2c739f69ba8d11621d7db2f420213194f0dbad`, contenido remoto comprobado. **Esta corrección no se ha probado todavía en Flutter.**
- El workflow se restauró a `workflow_dispatch` exclusivamente (commit `87899db`), verificado en GitHub; no queda trigger `push`. No se generó APK ni se hizo merge.
- Las ocho capturas reales `StagePainter` siguen **sin generarse** porque el test fallido abortó la ejecución antes de la fase de render y guardado. Próxima acción: una sola ejecución manual/controlada del QA autorizada expresamente, comprobar todos los tests y ocho PNG; revisión visual posterior. No afirmar validación final del capítulo ni de sus enemigos.

## QA pública #56 y corrección del cargador de pescador (2026-11-08)
- Run [42490992815](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/42490992815), job `128763113558`: **Flutter analyze limpio y 11/11 tests físicos Arga correctos**, incluyendo reaparición al checkpoint. Prueba real de render fallida en `test/arga_rc7_real_render_test.dart:64` porque `images['arga_fisher_reposo']` era null. La fase de ocho PNG se omitió; no hay render verificado ni APK.
- Diagnóstico contrastado: las seis rutas `pescador_*_aislado_candidate.webp` existen en GitHub y las registra el mapa `paths` de `main.dart`, pero el filtro `neededForSchoolQA` para `qaStage==7` solo aceptaba `arga_crab_*`, no `arga_fisher_*`.
- Corregido `lib/main.dart` para permitir también `key.startsWith('arga_fisher_')` solo en QA stage 7; commit `9752f463495ad296552aabbc81a40c4eb49b6002`. La carga Android ordinaria no cambia.
- Se inició **una** comprobación posterior [42491177824](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/42491177824) sobre commit `5b872a5`; esperar sus pasos/logs antes de declarar aprobado. El trigger temporal fue restaurado a `workflow_dispatch` exclusivamente en `636b1c1`. Ningún APK ni merge.
