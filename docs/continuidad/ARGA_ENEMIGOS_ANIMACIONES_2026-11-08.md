# Río Arga — continuidad de animaciones y QA (8 noviembre 2026)

Rama: `work/revision-visual-20261028-continuidad`. Capítulo experimental `stage == 7`, fuera del mapa normal. Conservar siete capítulos existentes; no habilitar GitHub Actions automáticas, generar APK, ni declarar finalizado sin capturas reales StagePainter y jugabilidad completa.

## Estado comprobado en código

Los cuatro enemigos **se dibujan y tienen lógica de ataque** en `lib/main.dart`, con máquina de estados separada:
- **Cangrejo:** `lib/arga_crab_behavior.dart`. Poses reposo, lateral, alerta, pinza, impacto, derrota. Se aproxima sobre la misma roca y ataca con pinzas. Tests en `test/arga_crab_behavior_test.dart`.
- **Pescador:** `lib/arga_fisher_behavior.dart`. Reposo, caminar, alerta, lanzamiento, impacto, derrota. Lanza anzuelo físico de `lib/arga_hook_projectile.dart`; la pose `walk` está definida pero su comportamiento actual permanece estacionario. Tests en `test/arga_fisher_behavior_test.dart`.
- **Niño gamberro:** `lib/arga_boy_behavior.dart`. Reposo, correr, alerta, lanzamiento, impacto, derrota. Lanza piedra física de `lib/arga_stone_projectile.dart`; `run` está definida pero no se activa. Tests en `test/arga_boy_behavior_test.dart`.
- **Trucha:** `lib/arga_trout_behavior.dart`. Nado, acelerar, alerta, salto, impacto, derrota; físicas y contacto aéreo. Se incorporó transición real nado→acelerar→alerta→salto (`fca9eaf`); test de cancelación (`50f83ed`); dibujo elevado 21 unidades de pantalla sin alterar hitbox (`1112222`). Tests actualizados (`cb24b1b`).

### Importante: seis estados NO equivalen a animación completa

Actualmente `StagePainter` selecciona **una imagen aislada por estado**. No existe todavía un atlas de varios fotogramas interpolados por estado para estos cuatro enemigos. Debe aplicarse la metodología aprobada para limpiador/músico: originales intactos; atlas con varias columnas por fila; alfa limpio y ninguna silueta invadiendo celdas; apoyos y escalas alineados; temporización de fotogramas; impacto/caída completos; comparación referencia→atlas→captura real.

## Orden de ejecución pendiente

1. Verificar visualmente las seis poses actuales y los originales de cada enemigo, empezando por trucha y cangrejo. Medir alfa, apoyos y tamaños; NO fabricar equivalencias o fotogramas sin inspección.
2. Crear **varios fotogramas distintos por estado**, preservando identidad aprobada, y empaquetar atlas de dimensiones estables. La cantidad de columnas se determina por movimiento real (no limitar a seis imágenes totales). Mantener PNG fuente.
3. Añadir selector temporal de fotogramas en `StagePainter` y probar transiciones, dirección, ciclo, interrupción, ataque, impacto y derrota sin recortes ni salto de posición.
4. Revisar anzuelo y piedra (actualmente círculos de QA), escalas y altura de trucha. No promover arte sin capturas auténticas 20:9.
5. Probar toda la travesía y caída mortal al agua con Miren y Sara; corregir huecos, checkpoints y respawn. Solo entonces habilitar acceso normal al Arga.

## Validación y cautelas

- Verificados en repositorio: archivos y commits nuevos. **No ejecutados:** `flutter test`, compilación Android, capturas StagePainter ni partida completa (Flutter/Dart no disponibles en este entorno).
- GitHub Actions se mantiene **manual** para evitar consumo de minutos.
- No se modificaron los otros capítulos; los cambios de `main.dart` son exclusivos de la representación de la trucha en `stage == 7`.
- No confundir avance técnico con aprobación artística o juego listo para próxima versión.

## Infraestructura de animación añadida (misma jornada)

- `lib/arga_sprite_atlas.dart`: reloj de animación determinista para atlas **4 columnas × 6 filas**; filas 0–2 cíclicas y 3–5 de una ejecución con último fotograma mantenido.
- `test/arga_sprite_atlas_test.dart`: tests de bucles, ataques, reinicio y valores inválidos. Guardado en `b0de161`.
- `lib/main.dart`: los cuatro pintores de enemigos del Arga pueden seleccionar una celda del atlas (`arga_crab_atlas`, `arga_fisher_atlas`, `arga_boy_atlas`, `arga_trout_atlas`) usando el estado y el tiempo. Commits `1ed4579` y `d404bd8`.
- **Compatibilidad:** mientras esos atlas no estén empaquetados/cargados, se dibujan las poses aisladas actuales. No se han inventado ni incorporado nuevos fotogramas.
- **Pendiente imprescindible:** crear los PNG atlas reales a partir del arte aprobado, registrar su carga y comparar 24 celdas por enemigo con capturas reales; reconsiderar el número de columnas por acción si cuatro resultan insuficientes. Esta infraestructura NO representa una animación acabada.
- No se han ejecutado tests Flutter/Dart ni Actions; no se ha modificado la visibilidad del capítulo.

## Microfase siguiente — selector tolerante a filas incompletas (2026-11-08)

- `lib/arga_sprite_atlas.dart` añade `activeFrames` (1–4) por fila, conservando el valor predeterminado de cuatro. Esto permite iterar sobre el arte sin seleccionar celdas vacías mientras se revisan fotogramas. Commit `e4c197b`.
- `test/arga_sprite_atlas_test.dart` añade escenarios con dos y un fotograma, bucle, retención del último y rangos inválidos. Commit `4f02cd2`.
- Verificada persistencia remota mediante consulta a GitHub. **Pruebas Dart/Flutter no ejecutadas** (aplazadas por acuerdo), no existe atlas artístico nuevo ni captura real.
- Siguiente microfase: auditar visualmente las seis poses aprobadas del cangrejo, alinear apoyos y producir intermedios auténticos antes de cargar un atlas. El parámetro opcional no sustituye esa tarea; no habilitar el capítulo normal.

## Microfase visual — inspección real del cangrejo (2026-11-08)

- Abiertas la lámina original aprobada y la pose candidata de reposo local. Se observan bandas horizontales de píxeles rojizos, manchas y prolongaciones externas al cuerpo, visibles incluso sobre transparencia; por tanto **no corresponde certificar esos archivos como atlas limpios**.
- Se generó una corrección exploratoria de la pose reposo con fondo alfa y sin bandas largas: `assets/images/arga_rc7/enemies_candidates/cangrejo_reposo_limpieza_v2_candidate.png` (1536×1024, bbox alfa >=128: 249,198 a 1288,836). La imagen mantiene diseño aproximado, pero el alfa tiene numerosas zonas semitransparentes y aún exige limpieza de contorno y revisión pixel-art; **NO aprobada ni conectada al motor**.
- Commit **solo local** `fa8f83d` (tras rebase). La subida Git HTTPS falló por ausencia de credenciales (`could not read Username`); **este PNG no está confirmado en GitHub**. Original y seis candidatos anteriores intactos. No confundir documento remoto con entrega del PNG.
- Siguiente microfase: limpiar alfa duro y comparar contorno/paleta con la referencia; guardar el PNG mediante transferencia binaria autorizada; después crear intermedios reales. No ejecutar Flutter/Actions ni habilitar Arga hasta QA completo.

## Microfase de transferencia recuperada — 2026-11-08

- Resuelto el bloqueo de autenticación Git HTTPS mediante la integración GitHub y transferencia binaria lossless WebP. El candidato `assets/images/arga_rc7/enemies_candidates/cangrejo_reposo_limpieza_v2_candidate.webp` está **en GitHub**: commit `34e018c`, blob `00dd63db0b682bc0cb8656e8324563ac3073bd20`, confirmado por lectura remota. No confundir con el PNG de ensayo local, que no fue subido.
- El WebP es una versión sin pérdida del PNG candidato. **No sustituye la pose original aprobada ni entra en el atlas cargado por el motor.** Sigue pendiente limpieza del borde semitransparente, correspondencia de paleta/silueta, línea de apoyo y aprobación visual.
- No se ejecutaron pruebas Flutter, Actions, APK ni render real.
- Siguiente microfase precisa: corregir borde alfa de esta pose, comparar a igual escala con la original y solo después construir los fotogramas intermedios; repetir las verificaciones con las otras cinco poses.

## Microfase de caminata — candidato visual transferido (2026-11-08)

- Revisado `cangrejo_caminar_aislado_candidate.webp`: estelas horizontales a la derecha del caparazón y pinza; no apto para atlas final sin corregir.
- Creada versión separada `assets/images/arga_rc7/enemies_candidates/cangrejo_caminar_limpieza_v2_candidate.webp`, WebP sin pérdida de la prueba de limpieza; mantiene la orientación lateral y elimina las bandas largas. Commit remoto `1484786`, blob `0f59ec2c27e14fc07a9a02416d8c5e983903c23c`.
- Ambos archivos son **candidatos**, no sprites finales; requieren comparar paleta, contorno duro, alfa, escala y pies con referencias, y después crear ciclos de varios fotogramas distintos. No hay integración StagePainter, pruebas Flutter ni aprobación final.
- Siguiente microfase: revisar y limpiar alerta, pinzazo, impacto y derrota; inspección conjunta de seis siluetas antes de normalizar celda y producir animación de locomoción. Mantener originales intactos.

## Microfase atlas de cangrejo — primer atlas 24 fotogramas (2026-11-08)

- Creado un **atlas candidato real** de seis filas de cuatro fotogramas: reposo, desplazamiento, alerta, ataque de pinzas, impacto y derrota. No es un atlas definitivo ni sustituto de referencia original.
- Archivo de revisión en GitHub: `assets/images/arga_rc7/enemies_candidates/cangrejo_atlas_4x6_v1_candidate_q95.webp`, commit `76741f1`, blob `0f7dfe8bf4aa56c3c52f36d7ee9b11b5bc6e6230`. Es una copia WebP Q95 con pérdida **solo para QA**; PNG generado 1024×1536 y versión WebP sin pérdida quedan locales, no incorporados al motor.
- Auditoría automatizada de la imagen generada: 24/24 celdas con contenido alfa ≥128; todas las cajas delimitadoras quedan dentro de su celda de 256×256 con margen ≥16 px. Se detectaron 323147 píxeles de alfa parcial bajo 128, por lo que el contorno requiere limpieza. No se ha comprobado todavía igualdad de paleta, anclaje exacto de pies ni diversidad de fotogramas en escala real del juego.
- **No habilitar** `arga_crab_atlas` todavía: no hay PNG definitivo integrado, ni Flutter / StagePainter 20:9, ni aprobación artística; originales aprobados y demás capítulos intactos.
- Próxima microfase: revisar diversidad y alineación de las 24 celdas, limpiar alfa y generar atlas de producción sin pérdida. Después integrar únicamente en QA stage 7 y ejecutar pruebas cuando se autorice Flutter. Continuar atlas de pescador, niño y trucha con idéntico proceso.

## Microfases cuatro atlas de prueba — 8 noviembre 2026

Se generaron **cuatro atlas candidatos de 24 fotogramas (4×6)** basados en las referencias aprobadas, preservando todas las láminas originales. No se debe confundir la existencia del atlas con calidad final o integración.

| Enemigo | Candidato QA en `assets/images/arga_rc7/enemies_candidates/` | Commit | Auditoría de cajas alfa (umbral 128) |
|---|---|---|---|
| Cangrejo | `cangrejo_atlas_4x6_v1_candidate_q95.webp` | `76741f1` | 24/24 celdas no vacías; márgenes ≥16 px; exceso de píxeles semitransparentes, falta revisar diversidad y apoyo |
| Pescador | `pescador_atlas_4x6_v2_candidate_q95.webp` | `4834077` | Segunda iteración: 24/24 celdas; sin cajas alfa tocando margen de 10 px. Caña y anzuelo requieren inspección visual frame a frame |
| Niño gamberro | `gamberro_atlas_4x6_v1_candidate_q95.webp` | `7d8ee8a` | 24/24 celdas; varias de impacto/lanzamiento con margen inferior de solo 8–9 px; ajustar apoyo/aire |
| Trucha | `trucha_atlas_4x6_v1_candidate_q95.webp` | `db5261f` | 24/24 celdas, pero varias poses altas cruzan o tocan borde superior/inferior; RECHAZADO para integración |

Los cuatro WebP subidos son **previsualizaciones Q95 con pérdida**, no PNG definitivos. Los PNG generados están locales; los atlas no se cargan en `StagePainter`. La segunda tentativa de trucha redujo siluetas pero introdujo fondo blanco semitransparente y fue descartada, no subida.

**Pendiente de máxima prioridad:** revisión visual comparativa con cada hoja aprobada; verificar 24 fotogramas realmente distintos por acción, limpiar halo alfa, alinear escala y pies, resolver recortes de trucha y márgenes del niño, exportar PNG final sin pérdida, cargar solo QA stage 7, ejecutar Dart/Flutter y capturas auténticas 20:9, comprobar daño/proyectiles y ambos personajes. Hasta entonces **ningún enemigo del Arga está terminado ni habilitado**. No se han lanzado Actions ni compilado APK.

## Corrección geométrica y QA repetible — 8 noviembre 2026

- **Trucha:** nueva composición 4×6 `assets/images/arga_rc7/enemies_candidates/trucha_atlas_4x6_v3_candidate_lossless.webp`, blob `328d3eb88c9db71c953778c85962e61b24e48ca1`, commit `55fb52a`. Resultado local: 24/24 celdas ocupadas; sin cajas opacas a menos de 15px de bordes; fondo exterior con alfa 0. Supera el recorte que invalidaba v1. NO se ha aprobado el arte, el alfa fino ni la animación en Flutter.
- **Niño gamberro:** nueva composición con margen ampliado, `assets/images/arga_rc7/enemies_candidates/gamberro_atlas_4x6_v2_candidate_lossless.webp`, blob `155f63cb82db4f445c6ae6e22554d77d36924052`, mismo commit `55fb52a`. 24 celdas, sin déficit de margen de 12px en el umbral alfa 128. Las primeras poses de reposo son muy parecidas; requiere inspección temporal a tamaño de juego.
- **QA reutilizable:** `qa/check_arga_candidate_atlas.py`, commit `cff556e`, comprueba 4×6, 24 imágenes no vacías, margen mínimo de 12px, y detecta duplicados contiguos exactos. Ejecución local: PASS para cangrejo v1, pescador v2, trucha v3, gamberro v2; FAIL para el gamberro v1 por márgenes. **No demuestra** suavidad de movimiento, ausencia de halos, apoyo estable, calidad visual o jugabilidad.
- Ambos nuevos WebP son **sin pérdida** (equivalentes en píxeles a sus PNG generados); no se han conectado al motor. Se mantienen referencias originales y versiones anteriores.
- Siguiente microfase: revisar alfa real y diversidad perceptible, normalizar apoyos, fabricar atlas final de producción y comprobarlo en `StagePainter` solo en QA stage 7. Flutter sigue aplazado, sin Actions/APK.

## Auditoría alfa — bloqueo de producción (2026-11-08)

Sobre los PNG generados de los cuatro atlas seleccionados (1024×1536 píxeles), el histograma del canal alfa reveló que **ningún píxel llega a alfa 255** (todos los píxeles visibles son parcialmente transparentes). Píxeles con alfa 1–127 / 128–254: cangrejo 323147 / 448247; pescador 180223 / 232862; gamberro v2 148222 / 222248; trucha v3 149472 / 212373.

Esto **bloquea los atlas como producción definitiva** aunque la geometría y diversidad básica pasen. A escala de juego pueden aparecer bordes suavizados/halos y la paleta mezclarse con el fondo. No pasar estas versiones a `assets/images/enemies_new/` ni al mapa normal; los WebP sin pérdida conservan fielmente esta limitación y los Q95 son solo previsualizaciones.

Próxima acción: obtener recortes de pixel art con alfa duro auténtico y bordes estables, revisar 24 celdas de cada uno frente a la referencia aprobada, luego integrar con `FilterQuality.none` y capturas StagePainter 20:9 antes de habilitar. Ninguna prueba Flutter ejecutada.

## Microfase: cuatro atlas conectados a QA Flutter (2026-11-08)

- Repositorio verificado como **público**; GitHub Actions Ubuntu estándar no consume minutos facturables en repositorios públicos (no se presupone gratuidad de runners grandes o almacenamiento ilimitado).
- `lib/main.dart`, commit `61d7b70`: `TWC_ARGA_ATLAS_QA=true` carga 4 atlas **candidatos** solo si `qaStage==7`; por defecto sigue dibujando las poses aisladas anteriores. Cangrejo/pescador usan WebP Q95 de revisión; gamberro v2/trucha v3 usan WebP sin pérdida. Se ajusta el anclaje visual del cangrejo y pescador para celdas 256×256; pendiente revisión en captura real.
- `test/arga_rc7_real_render_test.dart`, commit `ee82040`: con define QA exige decodificar los 4 atlas en dimensiones 1024×1536; conserva capturas reales y pruebas de físicas del Arga.
- `.github/workflows/arga-rc7-qa.yml`, commit `5e97814`: preparado para ejecutar pruebas Flutter y `StagePainter` 20:9 con los atlas mediante disparador manual en runner estándar Ubuntu, sin APK. **No ejecutado aún** porque la integración GitHub de esta sesión no expone disparo de workflows y no hay CLI autenticado.
- La auditoría alfa de los cuatro sigue BLOQUEANDO producción: esta integración opt-in es para poder observar y corregir errores reales, no para aprobar ni habilitar enemigos.
- Próximo paso: ejecutar manualmente el workflow `Río Arga RC7 - QA Flutter 20:9 sin APK` sobre la rama actual; inspeccionar logs y PNG reales, corregir iterativamente. No fusionar PR.

## QA Flutter auténtica con cuatro atlas — 2026-11-08

- Repositorio público; ejecución `42504613482` (commit `f1c6aa0`) falló **únicamente** en `test/arga_rc7_real_render_test.dart`: esperaba salto de trucha tras dos updates cuando el modelo exige swim→accelerate→warning→leap. Análisis Flutter y 29 tests puros superados.
- Test corregido **sin alterar físicas** en commit `90abd6d`; segundo disparo `285bb50`.
- Ejecución `42504800762` **SUCCESS**: instalación Flutter 3.47.8, `pub get`, `flutter analyze --no-pub lib`, 29 pruebas unitarias, prueba real `StagePainter` con `TWC_ARGA_ATLAS_QA=true`, ocho capturas 1000×450 y salto de trucha. Imágenes conservadas por CI en commit `e9b2eef`, carpeta `qa/arga_rc7_flutter/`.
- Inspección visual efectuada sobre `qa_340.png` (cangrejo en roca), `qa_810.png` (pescador + trucha en cauce), `qa_1250.png` (pescador junto a Miren), `qa_1950.png` (niño), `trout_leap_810.png` (salto real). Se distinguen las siluetas y se mantienen dentro del escenario, sin bandas horizontales largas visibles en esas tomas. La trucha aparece relativamente pequeña; escala y hitbox requieren comparación durante movimiento. No hay aprobación final.
- **Limitaciones:** imágenes puntuales no equivalen a revisar los 96 fotogramas ni a partida Android. Alfa parcial detectado previamente continúa sin corregir; ataques, transiciones y pies deben evaluarse secuencialmente en cámara. No activar atlas por defecto ni habilitar mapa Arga.
- **Próxima microfase:** captura controlada de varias fases temporales por enemigo en el render real (al menos alerta/ataque/impacto/derrota) y contraste con referencia; luego corrección de alfa y apoyo.

### Microfase QA del pinzazo: cuatro fotogramas StagePainter (08/11/2026)

- Prueba añadida: `test/arga_crab_attack_frames_render_test.dart`, ejecutada con `--dart-define=TWC_ARGA_ATLAS_QA=true`, sobre `HermanasGame(qaStage: 7, qaWorldX: 340)` y el cangrejo forzado a `ArgaCrabPose.pinch` con cuatro tiempos (`0/9` a `3/9` segundos). Capturas: `qa/arga_rc7_flutter/crab_pinch_frame_{0,1,2,3}.png` (1000×450).
- Ejecución `42505155653` **SUCCESS**: el render Flutter guardó los cuatro PNG auténticos; no son fotogramas de una partida Android. Capturas inspeccionadas individualmente: pinzas y postura cambian visiblemente, pies en la roca, pero el cuerpo del cangrejo queda parcialmente oculto detrás de Miren. Con esta cámara **no queda evaluada de forma completa la lectura del ataque ni la colisión**.
- Se detectó que el primer test comparaba listas de bytes con un matcher potencialmente insuficiente para asegurar diferencia de contenido. Se corrigió a `listEquals(samples[frame], samples[frame - 1]) == false` en commit `77981cb`. Cuarta ejecución estricta: `42505487355` **SUCCESS**; todas las comprobaciones de Flutter terminaron correctamente con igualdad de bytes contrastada.
- **Próxima microfase:** completar y registrar el resultado estricto; capturar pinzazo con personaje separado para inspección visual sin oclusión, y verificar impacto con test de juego. Mantener atlas como candidato; no declarar producción ni levantar la bandera de QA por defecto.

### Microfase de encuadre sin oclusión y región del cangrejo

- Commit `58d16d6`: `test/arga_crab_attack_frames_render_test.dart` mueve a Miren de `qaWorldX=340` a `230` y extrae RGBA solo del rectángulo de pantalla `(310,250)-(450,395)` para comprobar cuatro ataques `pinch`; excluye monedas e interfaz del criterio de diferencia. Conserva cuatro capturas auténticas. No cambia arte, físicas ni entrada al capítulo.
- Ejecución automatizada `42506624338` disparada en `1c054804`; estado pendiente de comprobar y documentar tras inspección de las nuevas imágenes.
