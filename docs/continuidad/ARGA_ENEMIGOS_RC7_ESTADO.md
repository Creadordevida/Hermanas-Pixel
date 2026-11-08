# Enemigos del Río Arga — aprobación artística y continuidad (2026-11-08)

## Orden vinculante
El propietario ha aprobado las cuatro láminas conceptuales de seis poses:
1. **Cangrejo de río**: acercarse lateralmente y atacar con ambas pinzas.
2. **Pescador**: acercarse y atacar lanzando su caña/anzuelo.
3. **Niño gamberro**: lanzar piedras redondeadas del río.
4. **Trucha**: salir del agua y saltar hacia Miren y Sara.

La estética, identidad facial/anatómica, silueta, paleta, ropa, complementos y sombreado de las imágenes aprobadas son vinculantes. No generar sustitutos procedimentales de baja fidelidad.

## Fuentes aprobadas protegidas
Los originales de evaluación, convertidos a WebP **sin pérdida** y con transparencia, están en:
- `docs/continuidad/referencias/arga_enemigos_aprobados_20261108/cangrejo_seis_poses_aprobadas.webp` — Git blob `2ceb16c7c0ee435ee5860a1a2c233f32cd87793d`
- `docs/continuidad/referencias/arga_enemigos_aprobados_20261108/pescador_seis_poses_aprobadas.webp` — Git blob `e33247cc3c56e08760ff404de87ebc087922575a`
- `docs/continuidad/referencias/arga_enemigos_aprobados_20261108/gamberro_seis_poses_aprobadas.webp` — Git blob `15697c4bd9bb24cdf64268500fba6a1536fc907e`
- `docs/continuidad/referencias/arga_enemigos_aprobados_20261108/trucha_seis_poses_aprobadas.webp` — Git blob `6a3837cbcadbc8dc8aa1012f23bcdc6e4138cf77`

Todas son 2172×724 px y representan **conceptos para aprobación**, no atlas de producción. La transferencia binaria se verificó con `git hash-object` local contra los SHA devueltos por GitHub. No sobrescribir originales, tampoco reemplazar imágenes anteriores de otros enemigos.

## Poses aprobadas (orden de izquierda a derecha)
| Enemigo | 1 | 2 | 3 | 4 | 5 | 6 |
| --- | --- | --- | --- | --- | --- | --- |
| Cangrejo | Reposo | Caminar lateral | Alerta | Pinzazo | Impacto | Derrota invertido |
| Pescador | Reposo | Caminar | Caña alta | Lanzamiento | Impacto | Derrota sentado |
| Gamberro | Reposo | Correr | Apuntar | Lanzamiento | Impacto | Derrota sentado |
| Trucha | Nadar | Acelerar | Preparar salto | Salto ofensivo | Impacto | Boca arriba |

## Diagnóstico previo a separar fotogramas
- Los cuatro PNG de origen tienen transparencia RGBA.
- **No se debe cortar a ciegas en seis rectángulos de 362 px**: hay elementos cerca o sobre límites de celda, especialmente la caña del pescador, la piedra y la cola de trucha. Cortar directamente puede amputar complementos y repite defectos ya corregidos en otros enemigos.
- Trabajar mediante máscaras alfa y extracción de siluetas; cuando una pose invada otra columna, ampliar o reconstruir exclusivamente esa pose sin alterar diseño aprobado.
- Alinear base de pies en humanos/cangrejo; preservar la base acuática de la trucha como un efecto separado. Normalizar tamaño **tras** inspeccionar la escala real de Miren y Sara; no inventar tamaño de colisión.

## Estado real
- **COMPLETADO**: concepto artístico, aprobación del usuario, copia sin pérdida en GitHub, comprobación de integridad de los cuatro originales. Commit de incorporación `460d9b5`.
- **PENDIENTE**: extracción limpia de cada pose, intermedios de animación, ataques/proyectiles, integración del motor `qaStage:7`, pruebas físicas, capturas reales `StagePainter` 20:9 y evaluación visual a escala de juego.
- **RESTRICCIONES**: sin gastos en GitHub Actions, sin instalación Flutter por ahora, no activar Arga en el mapa ni desplegar APK. No declarar terminado ningún enemigo sin verlo funcionar.

## Siguiente microtarea
Crear y verificar una extracción conservadora del **cangrejo** (seis máscaras sin amputaciones), medir siluetas y apoyo; solo entonces crear secuencias de fotogramas intermedios y registrar una captura de revisión. Continuar después con los otros tres conservando la referencia.

## Microtarea 2 — inspección de máscaras (2026-11-08)
- Se ensayó una reordenación de poses del cangrejo mediante edición visual.
  **DESCARTADA** por introducir ruido de píxeles sueltos en áreas transparentes.
  No se guardó como sprite definitivo ni se sobrescribió el original aprobado.
- Nuevo comprobador de solo lectura `scripts/check_arga_enemy_atlases.py`,
  commit `ad9a7e7`. Marca visualmente las celdas cuyo contenido opaco
  llega a menos de 8 px del borde de un sexto (362 px) de lámina.
- Resultado de análisis alfa efectuado sobre los cuatro originales locales:
  cangrejo celdas **3, 4, 5**; pescador **1–6**; gamberro **2, 3, 4, 6**;
  trucha **1–5** requieren inspección de recorte y/o accesorios.
  Estos son **avisos de seguridad**, no demostración de amputación; no cortar
  los atlas por sextos sin resolución del conflicto.
- Siguiente acción: aislar siluetas por transparencia y recuperar las partes
  que atraviesan límites. Empezar por cangrejo, comparar cada una de sus
  seis poses con la imagen aprobada, y solo aprobar el atlas cuando esté limpio.
  No hay integración a Flutter ni cambio en capítulos existentes.

## Microtarea 3 — cangrejo, reposo aislado (2026-11-08)
- Extraída una versión candidata del primer estado (reposo frontal), con
  separación amplia y transparencia, a partir de la imagen artística aprobada.
- **Solo candidata, no validada para juego**, 1024×1024: 
  `assets/images/arga_rc7/enemies_candidates/cangrejo_reposo_aislado_candidate.webp`,
  Git blob `57a64a1de1c021723d2242ba87d376b9a63d80ee`,
  commit `27053b0`. Integridad de subida verificada mediante SHA Git.
- Falta comparar cuantitativamente la silueta y paleta con la pose 1 de la
  referencia, reducir al tamaño real sin suavizar píxeles, alinear los pies
  y crear los otros cinco estados limpios. No registrar este fotograma como
  aprobado ni usarlo en `StagePainter` aún.

## Microtarea 4 — poses aisladas de movimiento y ataque (2026-11-08)
- Dos candidatos **sin sustituir originales** guardados en commit `f06a479`:
  - `assets/images/arga_rc7/enemies_candidates/cangrejo_caminar_aislado_candidate.webp`
    — Git blob `5ba0830c536218156829477796a3bdffff9bfc13`.
  - `assets/images/arga_rc7/enemies_candidates/cangrejo_ataque_aislado_candidate.webp`
    — Git blob `edfc77fd5cdd9dabd3899fb0373c24f78f4a3113`.
- Ambos archivos son **1254×1254 RGBA con alpha** y la máscara opaca visible
  queda dentro del lienzo: caminar bbox (181,399)-(1067,930);
  ataque bbox (164,398)-(1089,899). Reposo previo también 1254×1254,
  bbox (188,374)-(1066,914). SHA Git local y remoto coincide en ambos.
- Comparación artística visual preliminar: postura lateral y pinzas claras,
  mismo cangrejo rojizo de referencia; no hay ratificación final de
  proporcionalidad ni escala en StagePainter. Los tres siguen **CANDIDATOS**.
- Faltan estados de alerta, impacto y derrota, así como los intermedios;
  el objetivo siguiente es completar estos tres conservando imagen original,
  limpiar efectos ajenos al cuerpo y después definir atlas homogéneo sin cortes.

## Microtarea 5 — seis estados clave aislados (2026-11-08)
- Completadas las **seis imágenes individuales candidatas** del cangrejo
  en `assets/images/arga_rc7/enemies_candidates/`:
  `cangrejo_{reposo,caminar,alerta,ataque,impacto,derrota}_aislado_candidate.webp`.
- Tres imágenes nuevas en commit `3dfdc2f`: alerta blob
  `f6de3a4e2e55264036de2db0ad2734fa09f7caec`,
  impacto `f27932502854e0dbc8f230a2d73e9558aefeaa14`,
  derrota `ae3f782352156190ac00cbb1c46d24d2f01107ab`.
  SHAs de GitHub verificados contra `git hash-object` local.
- Las seis son 1254×1254 con máscaras opacas interiores (umbral alpha 64);
  bboxes: reposo (188,374)-(1066,914), caminar (181,399)-(1067,930),
  alerta (234,288)-(970,967), ataque (164,398)-(1089,899),
  impacto (312,332)-(922,925), derrota (216,370)-(1037,929).
  Ninguna silueta recorta los bordes del lienzo.
- **Sin integrar**: son imágenes aisladas de evaluación. Todavía deben
  compararse a píxel/paleta con la referencia vinculante, homogeneizar escala
  y línea de suelo, eliminar de los cuerpos los efectos de impacto que se
  quieran animar aparte, crear intermedios y comprobar el atlas final en juego.
- Próximo paso exacto: inspección comparativa de las seis poses a igual escala,
  formar atlas de producción solo cuando sean uniformes, luego programar
  aproximación lateral, ventana de pinzazo y daño; no alterar los siete capítulos
  existentes. Después, proceder con pescador, gamberro y trucha.

## Microtarea 6 — contrato físico del cangrejo, aislado (2026-11-08)
- `lib/arga_crab_behavior.dart`: máquina de estados pura Dart
  `idle / sideways / warning / pinch / hurt / defeated`, basada en
  `lib/four_enemy_behaviors.dart` (método probado en enemigos anteriores).
  Distancia de aproximación 215, aproximación lateral 36 u/s, alcance de
  pinza 66, aviso visible 0,55 s, golpe a 0,12 s del gesto, recuperación 1,8 s,
  patrulla limitada a 100 px de su apoyo de origen.
- El golpe solo es válido si **ambos están en la misma superficie**
  (`onSameSupport`), personaje a altura alcanzable y delante de las pinzas.
  Se entrega como máximo una vez. Impacto recibido cancela el ataque;
  derrota congela definitivamente el movimiento.
- `test/arga_crab_behavior_test.dart`: cuatro pruebas de aviso/impacto único,
  huecos y altura, interrupción/derrota y límite de patrulla.
- Commits `c5d082b`, `62445a9`, `81b6d0d`. **No ejecutados en Dart/Flutter**
  por las restricciones acordadas; no se ha conectado aún este módulo a
  `main.dart`, no hay enemigos activados en stage 7 ni se modificó 0–6.
- **Próximo paso**: normalización conservadora de seis imágenes del cangrejo,
  revisión comparativa con diseño aprobado, fotogramas intermedios y conexión
  exclusiva al prototipo QA stage 7; después captura real de `StagePainter`
  cuando Flutter vuelva a estar disponible.

## Microtarea 7 — cangrejo conectado solo al Arga QA (2026-11-08)
- **Hallazgo de revisión**: en `lib/main.dart`, el aterrizaje físico dentro
  de stage 7 recorría solo `ArgaCourse.surfaces` (nueve primeros apoyos)
  aunque el curso largo tiene 135. Corregido a `allSurfaces` en
  `e541f97`; prueba de aterrizajes generados añadida en `9de719c`.
  **Este cambio aún requiere ejecución en Flutter**.
- El cangrejo limita su patrulla a los bordes interiores de su roca;
  el módulo puro Dart recibe `minX` y `maxX`, prueba de seguridad en
  `test/arga_crab_behavior_test.dart`. Commits `c9ca12b`, `f411004`.
- Se declara `assets/images/arga_rc7/enemies_candidates/` en pubspec
  (`f389ada`) y se cargan sus seis imágenes **solo si qaStage==7**.
  `lib/main.dart` instancia un cangrejo en la segunda roca (x 375),
  usa su máquina de estados para acercarse, avisar y pinzar, y lo dibuja
  con la pose correspondiente y `FilterQuality.none`. La posición visible
  se alinea al tope físico usando bboxes medidos de las seis candidatas.
  Commit `9c3637a`.
- El daño de pinza se cancela si Miren o Sara no están en la misma roca.
  El modelo no se ha añadido a los índices 0–6 ni al mapa de capítulos.
- `test/arga_rc7_real_render_test.dart` exige ahora decodificar las seis
  imágenes del cangrejo y comprueba instancia en el prototipo; commit
  `a62780e`.
- **ESTADO**: código y recursos de prototipo conectados, pero NO compilados,
  NO ejecutados y NO validados por captura real, porque Flutter se mantiene
  aplazado y GitHub Actions bloqueado por presupuesto 0. La calidad artística
  y escala final permanecen como CANDIDATAS. No liberar al mapa normal.
- **Siguiente acción**: ampliar pruebas de física del cangrejo, validar el
  acceso correcto a sprites en QA y aplicar el mismo proceso al pescador,
  sin declarar terminado ninguno hasta prueba real.

## Microtarea 8 — pescador, lógica inicial aislada (2026-11-08)
- Se conserva aprobada la lámina de seis poses del pescador. Sin separar todavía
  la caña o el hilo, porque atraviesan bordes de celda y no queremos amputarlos.
- `lib/arga_fisher_behavior.dart`: se ha añadido el contrato puro Dart
  `idle / walk / warning / cast / hurt / defeated`; alcance de detección
  280 px, aviso 0,75 s, lanzamiento al segundo 0,19 de la acción,
  un único evento de anzuelo por ataque, recuperación 2,7 s.
  Se cancela el aviso si pierde la línea de visión, al recibir impacto
  interrumpe el ataque y tras derrota no actúa ni sale de su roca.
  Commit `7dd8f54`.
- `test/arga_fisher_behavior_test.dart` (commit `56b8b4`):
  aviso y único lanzamiento, cancelación por pérdida de visibilidad,
  interrupción por daño y derrota.
- **PENDIENTE**: extraer seis siluetas limpias (incluida la caña completa),
  proyectil/anzuelo con trayectoria visible y colisiones, integración solo
  `qaStage:7`, capturas reales y tests ejecutados. No existe aún pescador
  activo en juego.
- Restricciones sin cambios: no Flutter local, Actions bloqueado sin gasto,
  ningún capítulo normal afectado.

## Microtarea 9 — daño y derrota del cangrejo (2026-11-08)
- Conexión QA en `lib/main.dart`: disparos de Miren o Sara que alcancen
  la silueta física del cangrejo interrumpen su ataque; tras **dos impactos**
  pasa a pose de derrota y deja de atacar. Las balas impactadas se desactivan
  para evitar doble daño. Commit `3cbffdb`.
- Test de juego programado en `test/arga_rc7_real_render_test.dart`:
  lanza dos proyectiles de jugador al cangrejo de QA y comprueba
  `argaCrabHits==2` y `ArgaCrabPose.defeated`. Commit `67cad7d`.
- **SIN VERIFICAR EN FLUTTER**: el test está añadido, pero no ejecutado
  y no hay captura real. Imagen, animación y hitbox requieren ajuste a
  tamaño definitivo antes de declarar completado.

## Microtarea 10 — pescador, dos poses gráficas aisladas (2026-11-08)
- Extraídos para evaluación los estados de **reposo** y **lanzamiento de caña**
  conservando sombrero, rostro, chaleco, bolsa y caña completa.
- Archivos CANDIDATOS (no definitivos) bajo
  `assets/images/arga_rc7/enemies_candidates/`:
  `pescador_reposo_aislado_candidate.webp` (blob
  `d16f8cf5f00fc298743a8afa94b2d37251784d99`) y
  `pescador_lanzamiento_aislado_candidate.webp` (blob
  `515c87a6df945f4e806b3080b0b565786eb2515e`).
  Ambos son 1254×1254 WebP sin pérdida, máscaras visibles interiores:
  reposo bbox (319,134)-(922,1093); lanzamiento
  bbox (94,284)-(1163,1076). Se ha verificado lectura de ambos
  archivos tras regenerar la conversión de lanzamiento.
- Commit de dos candidatos `c656ce8`; commit de corrección conservadora
  de conversión `5a47723`. Los originales aprobados siguen intactos.
- Falta caminar, alerta, impacto y derrota; preservar longitud completa
  de caña y línea, escala igual entre seis estados y separar anzuelo
  como proyectil. No integrados en StagePainter todavía.

## Microtarea 11 — pescador, seis poses clave aisladas (2026-11-08)
- Se han aislado y guardado sin sobrescribir originales los seis estados
  gráficos del pescador: `reposo, caminar, alerta, lanzamiento, impacto,
  derrota` (prefijo `pescador_`, sufijo `_aislado_candidate.webp`).
- Cuatro imágenes añadidas en `43cd781`; sus Git blobs son:
  caminar `54e467b0a92b6e67eb1b543b02bb2639c2c3ec98`,
  alerta `1cfe2df1f3c3c5d8e73a4c3c57c06d83f5664eb9`,
  impacto `d2a0634229785065269ff52992cf3a5722a3bf5a`,
  derrota `60cb2bab458eedf1dfd51906e3872e56906cfa72`.
- Todos se decodificaron localmente como WebP 1254×1254, sin recortes en
  bordes. Bboxes opacas (alpha >= 64):
  reposo (319,134)-(922,1093);
  caminar (305,160)-(952,1094);
  alerta (356,71)-(885,1141);
  lanzamiento (94,284)-(1163,1076);
  impacto (315,124)-(993,1130);
  derrota (166,283)-(1107,1018).
  Integridad de cada subida verificada por SHA Git.
- **CANDIDATAS**: aún falta homogeneizar escala y apoyos de pies, obtener
  fotogramas intermedios, desacoplar hilo/anzuelo de la caña al lanzar y
  comprobar fotograma real en StagePainter. No inventar proyectil sustituto
  sin preservar el aspecto aprobado; no activar al pescador en el mapa.

## Microtarea 12 — niño y trucha: comportamiento aislado (2026-11-08)
- Nuevo `lib/arga_stone_boy_trout_behavior.dart` (commit `6eeae1c`):
  niño gamberro con reposo, carrera limitada a la roca, aviso previo de
  0,48 s, lanzamiento de una piedra por acción, interrupción por daño y
  derrota; trucha con nado, aviso de 0,45 s, salto balístico desde el agua
  hacia la protagonista, un solo impacto por salto, regreso al agua y
  enfriamiento.
- Test `test/arga_stone_boy_trout_behavior_test.dart` (commit `b19c873`)
  cubre lanzamiento único, límites de patrulla del niño, salto de la
  trucha y estado terminal de derrota.
- Los originales artísticos aprobados del niño y la trucha siguen
  protegidos en `docs/continuidad/referencias/arga_enemigos_aprobados_20261108/`.
  **Aún no** tienen poses aisladas, efectos ni proyectiles integrados.
- Las pruebas Dart no se han ejecutado por las restricciones acordadas;
  NO confundir lógica de prototipo con enemigo terminado.

## Corrección de identidad obligatoria (2026-11-08)
- Inspección visual de los PNG de origen detectó que **gamberro y trucha
  estaban intercambiados** de nombre en el primer commit de referencias.
  Reparados los dos caminos aprobados mediante intercambio de blobs,
  **sin alterar los píxeles** ni modificar la aprobación artística, en
  commit `65c2ce1`: gamberro = `15697c4bd9bb24cdf64268500fba6a1536fc907e`,
  trucha = `6a3837cbcadbc8dc8aa1012f23bcdc6e4138cf77`.
- Esta corrección precede cualquier extracción de los dos personajes.
  Las cuatro referencias artísticas quedan correctamente identificadas.

## Microtarea 13 — niño y trucha, primeros recursos candidatos (2026-11-08)
- Cuatro poses aisladas en transparencias individuales, verificadas visualmente
  contra sus fuentes **correctamente identificadas** y guardadas en commit
  `292a59f`, sin sobrescribir originales:
  - `gamberro_reposo_aislado_candidate.webp` — Git blob `6972ed933d87df5e36ecb36cf465d9ea78324723`
  - `gamberro_lanzamiento_aislado_candidate.webp` — Git blob `fc171a6bb4b3a66b9c9fdf40187b0a1cd8441264`
  - `trucha_nado_aislado_candidate.webp` — Git blob `293379c1fdc372ad7b28210ecf96e794a84d3170`
  - `trucha_salto_aislado_candidate.webp` — Git blob `3e94c4976dd06bf48f2a7338499b4a11c2aee585`
- Ruta para los cuatro: `assets/images/arga_rc7/enemies_candidates/`.
  Formato 1254×1254 WebP **sin pérdida**, máscaras de transparencia y
  SHA Git remoto idéntico al local. Las figuras y los efectos quedan
  dentro del lienzo sin amputaciones visibles.
- **No definitivas**: restan carrera/alerta/impacto/derrota del niño y
  acelerar/preparar salto/impacto/derrota de la trucha; armonizar escala,
  pivotes y efectos independientes; después integrar colisiones en QA stage 7.
  Todavía no se han compilado ni probado en el motor.

## Microtarea 14 — niño gamberro, seis poses aisladas (2026-11-08)
- Cuatro poses adicionales añadidas en commit `54d569e`:
  - `gamberro_correr_aislado_candidate.webp` — `77cda45f7d4f9066fbe852ba3a78fc62af14f051`
  - `gamberro_alerta_aislado_candidate.webp` — `0221548ec5ec03e1fb6975842b00da6561e5355d`
  - `gamberro_impacto_aislado_candidate.webp` — `e68d2b7cd550bf4e14d6ac8392e58a2c58ea5a0f`
  - `gamberro_derrota_aislado_candidate.webp` — `157818305a6e2b9dbd834716b56d807904dab68b`
- Junto a reposo y lanzamiento (microtarea 13), son **seis imágenes
  candidatas sin recortes visibles**, WebP lossless 1254×1254,
  comprobadas visualmente y con identidad coherente. Conservada la lámina
  aprobada; ningún capítulo 0–6 afectado.
- **PENDIENTE**: fotogramas intermedios, trayectoria y colisión de piedra,
  regularizar escala y pivote, conexión al prototipo QA y pruebas ejecutadas.

## Microtarea 15 — trucha, seis poses aisladas (2026-11-08)
- Cuatro poses adicionales guardadas en commit `8386cb5`:
  - `trucha_acelerar_aislado_candidate.webp` — `b225a6a488c240c9f35001a607496dda616ba82d`
  - `trucha_alerta_aislado_candidate.webp` — `47ed321241891499baf264f6c5d9f1021db28705`
  - `trucha_impacto_aislado_candidate.webp` — `3f29b05a85ed096f7f5547e7eb8af8194e508575`
  - `trucha_derrota_aislado_candidate.webp` — `f9aa612a6fc8fb945a7627607825890976866690`
- Con nado y salto (microtarea 13), la trucha tiene seis estados
  individuales CANDIDATOS, comprobados por inspección visual,
  WebP 1254×1254 sin pérdida, transparencias y SHA íntegros.
  La lámina aprobada original no ha cambiado.
- **ESTADO GLOBAL**: los cuatro enemigos del Arga (cangrejo, pescador,
  gamberro y trucha) tienen seis poses clave candidatas cada uno (**24**).
  Los cuatro requieren homogeneizar escala/pivotes, animación intermedia,
  efectos y juego real; solo el cangrejo tiene integración inicial
  exclusiva QA stage 7, NO validada. Los otros tres no se han integrado.
- **SIGUIENTE**: unificar criterios de pivote/escala respecto a Miren y
  Sara; preparar proyectil de piedra, anzuelo y salpicadura; continuar
  conexiones de QA por separado y pruebas sin iniciar Actions.

## Microtarea 16 — auditoría repetible de 24 poses (2026-11-08)
- Añadido `scripts/check_arga_24_candidates.py` en commit `02c0676` y confirmado en GitHub (blob `5009f70210a0a84cf36563c410f26ccd302f9af8`). Es un comprobador **de solo lectura**, sin generación ni reemplazo de los originales o candidatos.
- Exige 24 archivos WebP de 1254×1254 con canal alfa, silueta opaca interior y fondo transparente; informa bbox, altura, anchura y variación vertical por enemigo para preparar normalización de escala y pivotes. No confunde diferencias deliberadas de salto/derrota con fallos automáticos.
- **Ejecutado**: comprobación sintáctica `python3 -m py_compile` del script local. **No ejecutado** todavía contra los 24 WebP: este entorno no tiene el checkout binario de la rama; no se declara PASS de imágenes. Tampoco se ha ejecutado Dart/Flutter ni Actions.
- **Siguiente acción concreta**: ejecutar `python3 scripts/check_arga_24_candidates.py` en un checkout con Pillow y las 24 imágenes; revisar las medidas y cada pose frente a sus cuatro láminas aprobadas, normalizar pivotes sin perder caña/piedras/aletas y después integrar pescador, niño y trucha exclusivamente en QA stage 7. No activar para APK ni mapa sin capturas reales.

## Microtarea 17 — anzuelo del pescador en módulo aislado (2026-11-08)
- Código nuevo `lib/arga_hook_projectile.dart` (commit `39ea03b`, Git blob `17359f2afe503a98f3f2dbd528a09f40383ed5b7`): lanzamiento balístico con gravedad, arco, vida máxima de 1,4 s, desactivación al caer al agua, `cancel()` y un único impacto en rectángulo de personaje. La velocidad horizontal se limita a ±195 u/s y la vertical inicial es -185 u/s. **Son valores de prototipo** que necesitan revisar alcance/escala frente a Miren y Sara.
- `test/arga_hook_projectile_test.dart` (commit `c0aaa2d`, blob `a86fd28d9e37f6de879badb23f041d097ca5bc69`): cinco casos escritos para vuelo, esquiva, impacto único, cancelación y caducidad.
- Ambos archivos se volvieron a leer desde GitHub. **NO ejecutados con Dart/Flutter** (SDK aplazado); no se ha representado el anzuelo en `StagePainter` ni enlazado el evento `ArgaFisherMotion.update` al proyectil. No atribuir aprobación visual ni combate probado. La colisión es muestreada en posición final, por lo que queda pendiente ensayo de barrido en frames lentos.
- Sin cambios en capítulos 0–6, workflows (permanecen manuales), arte aprobado ni APK.
- **Siguiente microtarea**: conectar el evento de lanzamiento al anzuelo solo bajo `qaStage:7`, garantizar cancelación al derrotar al pescador y crear prueba de integración; después inspeccionar render real y solucionar alcance, pixel art, pivotes y trayectoria antes de activar el enemigo.
