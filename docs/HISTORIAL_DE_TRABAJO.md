# Historial y registro de cambios
## 2026-10-28 — Estado recuperado de GitHub y vídeos
- PR #4 `Integrar paralaje aprobado TWC en fútbol, danza y colegio` fusionada. 55 archivos; base gráfica del capítulo 1 sin sustituir.
- CI #36: job Android exitoso, APK de prueba generado, artefacto ID 12833916176. No confundir «compilado» con «aprobado visualmente».
- Revisión de gameplay del usuario: portada, colegio, danza y fútbol; observaciones resumidas en `ESTADO_ACTUAL_PROYECTO.md`.
- Se creó rama `work/revision-visual-20261028-continuidad` para evitar perder el trabajo si se alcanza el límite de conversación. Estos documentos representan el **punto de recuperación**.
## Registro de ejecución (actualizar en cada hito)
| Hito | Estado | Evidencia |
|---|---|---|
| Identificar repositorio y PR | Confirmado | `Creadordevida/Hermanas-Pixel`, PR #4 |
| Documentar decisiones y tareas | En esta rama | Los tres archivos `docs/*` |
| Rediseñar capas del colegio | Pendiente | No hay PNG nuevos aprobados |
| Aumentar variedad de danza | Pendiente | No hay PNG nuevos aprobados |
| Resolver costura del fútbol | Pendiente | No hay capturas Android actualizadas |
| Revisar portada | Pendiente | Problema reportado en captura |
| Ejecutar QA gráfico y compilar nueva versión | Pendiente | No lanzar sin recursos nuevos |
## Regla para futuros GPT
No decir «terminado», «subido», «compilado», «aprobado» o «APK» salvo evidencia concreta para cada estado. Leer archivos y comparar historial del repo antes de modificar. Actualizar este registro después de cada commit, captura, test y acción CI. Nunca dejar avances importantes solo en la conversación.

## 2026-10-28 — Inicio de implementación visual (commit cbbe363)
- Primer cambio de código REAL, en la rama de trabajo: `tools/build_interiors_parallax_twc.py` deja de generar paisajes simplificados mediante figuras geométricas para colegio y danza; pasa a derivarlos de las panorámicas detalladas aprobadas de capítulo 1, conservando originales, proporciones, ciclo continuo y velocidades de cámara.
- **Importante: todavía no se han regenerado ni subido los PNG ni ejecutado Flutter/Android con este cambio.** Por ello los capítulos aún NO están resueltos y el APK de main sigue igual.
- Validación pendiente: ejecutar generador en copia con assets reales, verificar ruta de fuentes, pruebas Python y capturas en Android; inspeccionar si el cambio de calidad es suficiente. No considerar una aprobación artística automática.
- Pendiente todavía: uniones del colegio, variación arquitectónica de danza, integración del fútbol y portada.

## 2026-10-28 — Continuación: variedad danza + borde fútbol (código, no recursos compilados)
- Commit `521c5b7`: generador de danza `make_wall` utiliza tres ventanas de recorte mucho más separadas (0/385/770) del original de 1.672 px, en vez de encuadres separados 65 px. Busca evitar que reaparezcan de inmediato idénticos cuadros y puertas.
- Commit `0f331db`: generador de fútbol reemplaza máscara horizontal uniforme por contorno periódico irregular del perímetro deportivo, continuo en el bucle de 6.600 px. Conserva fondos y físicas.
- Modificación anterior `cbbe363`: paisajes visibles por ventanas de danza/colegio ahora derivados de los fondos detallados aprobados RC3 FIX2; **no se han regenerado los PNG**.
- **Estado real:** se han subido CAMBIOS DE GENERADORES a rama de revisión, NO imágenes resultantes, NO APK, NO pruebas Flutter/Android. Ningún capítulo resuelto ni aprobado; comprobar que generadores producen assets correctos, que cambios no empeoran uniones y que no hay imágenes fantasma.
- Siguiente: regenerar imágenes desde recursos originales, comparar capturas en múltiples cámaras y vídeos de Flutter, completar variación arquitectónica del colegio y portada; revisar calidad del fútbol y danza con usuario antes de fusionar.

## 2026-10-28 — Corrección de composición del colegio (implementación fuente)
- Commit `f91de794`: `tools/build_interiors_parallax_twc.py`, en `make_wall('school',zone,variant)`, ahora obtiene los paneles de la fuente real de cada sala (`SRCS['school'][zone]`) y no de los mismos dos trozos del pasillo repetidos en aulas e informática. Se retiró la junta falsa central y se dejó un montante de borde por módulo.
- Commit `ec86860b`: se actualizó `qa/test_interiors_twc.py` para exigir el nuevo contrato; el test viejo comprobaba exactamente el defecto (uso del pasillo para todas las salas).
- **Pendiente:** regenerar los PNG de colegio y danza; el código de Flutter sigue cargando los anteriores mientras no se publiquen assets. No se ha realizado CI de esta rama ni un APK de esta revisión. Los elementos singulares y suelo físico permanecen separados.
- **Riesgo a validar visualmente:** los paneles se recortan de ilustraciones enteras y pueden repetir pizarras/objetos emblemáticos que después se dibujan como hitos únicos; en ese caso hay que enmascararlos de los paneles repetibles antes de aprobar el colegio.

## 2026-10-28 — Portada: primer arreglo del código Flutter
- Commit `d5a05146`: en `lib/main.dart` se eliminó la copia del arte con desenfoque de 32 px usada para rellenar pantallas panorámicas; ahora se muestran márgenes de color neutro, conservando la portada nítida a proporción 800x450.
- Se suprimió el `Container` con fondo azul oscuro alrededor del logo The Wolf Company y se amplió moderadamente su área de presentación, sin modificar el PNG original.
- **Importante:** en pantallas panorámicas aún puede haber márgenes planos, aunque ya no bandas borrosas. La transparencia del PNG del logo y su contraste quedan por validar en Android. No declarar solucionada la portada hasta ver una captura real.
- Estado de trabajo global: cambios de `main.dart` y generadores únicamente en la rama; PNG originales aún no regenerados; NO hay APK de esta revisión y NO se han ejecutado pruebas Flutter.

## 2026-10-28 — Integración de regeneración de assets en compilación (commit d7652375)
- Workflow `.github/workflows/build.yml` ahora escucha commits de rama `work/revision-visual-20261028-continuidad` además de main.
- Antes de compilar, ejecuta generadores de colegio/danza y fútbol; publica recursos de revisión y contacto de 12 cámaras de fútbol como artefacto independiente. Regenera las imágenes también para las capturas Flutter; APK de la rama se diferencia claramente como `Miren-y-Sara-revision-visual-PR5-APK-PRUEBAS`.
- **La compilación NO queda aprobada por este commit:** hay que comprobar resultados CI, integridad de generación, imágenes efectivamente regeneradas, pruebas Flutter y Android. Si falla, leer logs antes de aplicar correcciones.

## 2026-10-28 — Prioridad visual antes de APK (instrucción del usuario)
- Commit `3198744f`: `.github/workflows/build.yml` vuelve a tener `push.branches: [main]`; la rama visual NO provoca nuevas compilaciones Android automáticas. El proceso de regeneración y futura publicación sigue preparado en el workflow para la etapa FINAL. Las ejecuciones anteriores que ya estaban iniciadas no se cancelan ni equivalen a validación.
- Commit `1fd83343`: se introdujeron molduras y zócalos sólidos y diferenciados por estancia en `tools/build_interiors_parallax_twc.py`, para dar continuidad arquitectónica entre módulos de colegio y danza sin transparencias de escena completa. No se altera física, suelo ni movimientos.
- **Estado:** el usuario exige terminar primero todas las mejoras visuales, posponiendo compilación e instalación Android hasta el final. Ningún capítulo aprobado visualmente. Persisten tareas de revisar duplicación de hitos singulares (pizarras/carteles), composiciones en ventanas y contacto entre niveles. Se necesitan vistas reales generadas, no basta con la inspección del código.

## 2026-10-28 — Nuevos enemigos aprobados y primera implementación lógica
- Usuario **aprueba expresamente** tres enemigos: robot de limpieza (colegio); aficionado rival con camiseta y bufanda (fútbol); turista borracho con gorra, cámara al cuello y botella (barrio).
- Commit `b92bf58f`: nuevo `lib/new_enemy_behaviors.dart`. Modelo puro y determinista de patrulla, detección, ventana de ataque, cadencia y derrota para los tres personajes; no conectado aún al bucle de combate, por no contar con sprites aprobados ni colisiones específicas.
- Commit `4ba1bc9b`: `test/new_enemy_behaviors_test.dart` con casos de patrulla a distancia, cooldown y derrota. **Pruebas escritas, no ejecutadas aún**; no presentar como superadas.
- Trabajos necesarios antes de activar enemigos: atlas pixel art coherente (espera, marcha, alerta, interacción, impacto, salida), revisión de escalas y pivote de suelo, integración de carga, ubicación por capítulo, golpes y ventanas, compatibilidad de balón/pirueta, pruebas Flutter y capturas. No reutilizar imágenes antiguas como si fueran los personajes nuevos.
- El usuario pide continuar además con mejoras visuales pendientes; compilación e instalación Android al final.

## 2026-10-28 — Mecánicas de los tres nuevos enemigos, segunda iteración
- Commit `e664c6b`: reemplazado ataque instantáneo por **anticipación visible**, ventana de impacto única al concluirla, posibilidad de esquivar antes del contacto, patrulla limitada y cancelación al recibir un golpe. Aún aislado del juego.
- Commit `cd48dfb`: pruebas revisadas para cubrir patrulla, evasión, un solo impacto y derrota. **No ejecutadas todavía**.
- Commit `1b960192`: contrato de diseño completo en `docs/NUEVOS_ENEMIGOS_CONTRATO_VISUAL_Y_MECANICO.md`. Mantiene requisitos de camiseta y bufanda rival, gorra/cámara/botella turista y robot colegio.
- **Pendiente:** imágenes pixel art auténticas y atlas, integración de `main.dart`, colisiones e interacción con Miren/Sara, QA visual de todos los capítulos. Sin APK nuevo, según petición del usuario.

## 2026-10-28 — Distribución de nuevos enemigos por capítulo
- Commit `e2abec24`: mapa `newEnemyAllowedStages` y función `plannedNewEnemySpawns` en `lib/new_enemy_behaviors.dart`, con aparición prevista solo en **colegio (robot, stage 6), fútbol (aficionado, stage 4), barrio (turista, stages 0–3)**. Posiciones deterministas con márgenes, sin activación hasta disponer de sprites.
- Commit `7c190ae7`: pruebas unitarias añadidas para distribución y separación. Aún **sin ejecutar**; el código no está conectado a `main.dart`.
- **Pendientes importantes:** sprites reales de 3 enemigos, integración en el juego, pruebas y verificación gráfica del colegio/danza/fútbol/portada. No generar APK antes de terminar cambios visuales, según orden del usuario. Ningún capítulo se declara cerrado.

## 2026-10-28 — Puerta visual independiente (sin APK)
- Commit `9bd6884f`: workflow `.github/workflows/revision_visual.yml` creado. Ejecuta generadores interiores/fútbol, pruebas Python y publica imágenes y vistas de 12 cámaras sin instalar ni compilar Android.
- Ejecución inicial: `https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/40740103491`, inicialmente en cola. **Resultado aún no verificado**.
- Al retomar, comprobar resultado de esta ejecución, leer logs, descargar e inspeccionar las vistas; identificar y corregir los defectos visuales restantes.
- Los tres enemigos solo cuentan con lógica aislada y tests escritos, no con sprites reales, integración ni prueba jugable.
- **No dar la versión por lista** hasta concluir sprites, integración y revisión de composición (colegio/danza/fútbol/portada), sin reutilizar atlas de enemigos anteriores como reemplazos.

## 2026-10-28 — TRES ENEMIGOS conectados al juego; pendientes de validación de arte/Flutter
- `20e7efec`: generador reproducible `tools/generate_new_enemy_sprites.py`, atlas de 6 poses y 4 fotogramas por pose para robot de limpieza, aficionado rival y turista. **Arte candidato procedural**, no aprobación SNES de alta fidelidad por el usuario.
- `3a384ff2`: los enemigos nuevos ya se registran en aparición por capítulo, se cargan sus hojas, se dibujan en coordenadas de mundo y ejecutan IA con anticipación. `7427b620`: daños de balón interrumpen ataque y derrota actualiza animación.
- `abefad4c`: nueva ruta de assets en pubspec; `c31861ef`: workflow de QA gráfico genera y publica los atlas; `9f0809c0`: workflow de APK final regenerará los nuevos atlas antes de compilar.
- **No afirmar terminado/validado** sin confirmar ejecución completa de QA gráfico y Flutter, revisar sprites reales y su coherencia, colisiones, ataques contra Miren/Sara, e interacción con pirueta de Sara, incluyendo probar versión final en Android.
- En caso de fallos GitHub, revisar últimas ejecuciones de la rama (p. ej. `40740792295`, `40740791903`) y sus logs. Mantener PR #5 en borrador; no fusionar por el mero éxito de los generadores.

## 2026-10-28 — Cierre de lagunas de integración de enemigos y nueva puerta Dart
- Commit `2b90e0cd`: `lib/main.dart` ahora programa al turista en todos los capítulos urbanos 0–3 (antes solo en 0, pese al contrato aprobado). Al finalizar aturdimiento, estado `hit` transiciona a `alert` antes de seguir simulando.
- Commit `0f25c1be`: se amplió la puerta visual sin APK para ejecutar Flutter 3.47.8, `flutter analyze --no-pub lib` y `flutter test test/new_enemy_behaviors_test.dart` tras generar todos los assets. Esto detecta errores de compilación Dart y mecánicas antes del último APK.
- Hasta la comprobación: QA visual anterior `40740951313` finalizó success, pero **no incluía necesariamente Flutter/análisis en ese momento**. Revisar nueva ejecución y si falla obtener el paso y arreglarlo.
- Arte de enemigos aún candidato; no hay conformidad artística ni pruebas físicas Android. No declarar completa la revisión.

## 2026-10-28 — Corregida la animación de bully del colegio (pendiente de vídeo real)
- Usuario informa que bully se animaba de forma incorrecta en el último vídeo del colegio. **El vídeo no está adjunto a este turno y no se ha podido inspeccionar visualmente**.
- Inspección del código encontró dos posibles causas concretas: el bully alternaba fotogramas de pasos con `foe.t` aun quieto; además se rotaba periódicamente con `sin(foe.t*8)`, provocando balanceo perpetuo.
- Commit `d25291e4`: `Enemy.lastRenderedX` detecta desplazamiento real, y bully utiliza `frame=0` en reposo, `1/2` al andar, `3` como anticipación de contacto y `4` al ser derrotado. Se eliminó la oscilación angular continua.
- Commit `ca319b7c`: prueba de regresión estática para garantizar reposo/marcha diferenciados y eliminación del balanceo. **Falta verificar CI y el vídeo o una nueva captura para confirmar la solución visual**. No afirmar resuelto en móvil.

## 2026-10-28 — Breakdancer: animación de bajada y subida del suelo
- Usuario observa en capítulo danza que `breakdancer` alternaba directamente estar erguido y tumbado, sin transición.
- Se comprobó `lib/main.dart`: con `foe.launched`, el renderizador asignaba siempre `frame=3` al breakdancer (pose en el suelo), aunque había fotogramas 1 y 2 de transición; el proyectil sale tras 0,75 s.
- Commit `3e7db825`: secuencia temporal 0→1→2→3→2→1 durante la preparación del ataque. Se conservan pies anclados al suelo y el lanzamiento posterior. Al terminar `foe.launched`, retoma animación de espera. La secuencia usa los dibujos existentes, **no añade dibujos nuevos**.
- Commit `d23afbb0`: nueva prueba de regresión del contrato en `qa/test_visual_revision_contract.py`.
- **Sin validación visual en vídeo o dispositivo aún**. Revisar coherencia de dibujos intermedios y la transición de recuperación en la siguiente ronda visual. No considerar resolución artística definitiva hasta visualizarla.

## 2026-10-28 — Sustitución del enemigo estatua por antiguo rey de Navarra
- Decisión explícita: conservar una **estatua viviente de antiguo rey de Navarra**, pero descartar el enemigo anterior (parecido al padre, verdoso, que arrojaba monedas). No representar necesariamente a un monarca histórico identificable sin referencias aprobadas.
- `7441228b`: nuevo generador `tools/generate_navarre_king.py` crea un atlas propio de 6 estados x 4 fotogramas: piedra, despertar, caminar, golpear suelo, impacto, derrotado. Contiene corona, manto, relieves de piedra, musgo y grietas. **El arte está marcado candidato, pendiente de inspección estética**.
- `9971e7ab`: `main.dart` cambia el enemigo antiguo por `navarre_king` en capítulos urbanos, carga nuevo atlas, lo representa a escala 84x116, se activa por cercanía, camina lentamente y golpea el suelo a corta distancia con aviso (~0,42 s); no dispara monedas. Código original del padre no se reutiliza.
- `d4b1a5c6`, `c63d67c5`: generación de atlas incluida en procesos visual y APK final. `2d330f2b`: test del contrato evita reintroducir la estatua anterior.
- Pendiente: confirmar CI con generación de imagen, analizar Flutter, revisar sprites reales, la transición pedestal/suelo, físicas de proximidad, animación de onda (actualmente el daño se calcula pero **no existe VFX de onda dibujado**), integración del golpe de Sara, versión móvil. **No declarar completamente terminado** ni aprobado hasta esas comprobaciones.

## 2026-10-28 — Rey de Navarra pasa a hito único y añade ataque visible
- `40b0e5bc`: eliminado `navarre_king` de apariciones aleatorias en Ayuntamiento y Plaza. Se coloca **una sola estatua** en el capítulo 3 (Plaza del Castillo) en 54% del recorrido, para preservar la lógica narrativa.
- En el render se dibuja una **onda física visible** durante el golpe de suelo, sin monedas. `e61d2005` ajusta el alfa a entero para Dart.
- `db2136c4`: tests contractuales para ubicación única y representación de onda. **Pendientes de verificación CI más reciente**.
- El atlas es candidato original procedimental, no se ha aprobado aún su acabado artístico; consultar la última ejecución de `Revision visual - recursos y controles (SIN APK)`. No montar APK ni fusionar PR #5 antes de QA visual y Flutter.

## 28/10/2026 — Bloqueo efectivo de los 4 enemigos de calidad rechazada
- Petición del usuario: **rehacer** robot, aficionado, turista y rey de Navarra para próxima versión; revisar **captura REAL del motor del juego** (no PNG aislado ni montaje).
- **No se dispone todavía de sprites rediseñados y verificados en captura real.** Por seguridad artística, commit `ec23966e`: constantes `newEnemyArtApproved=false` y `kingVisualApproved=false` impiden su aparición en partidas de la candidata, mientras se conservan IA/atlas para desarrollo. No afirmar que los cuatro estén solucionados: falta rediseñarlos, integrarlos y revisar juego renderizado.
- `a35d8c18`: test contractual refleja bloqueo de la estatua y otros tres hasta aprobación. Para desbloquear hay que reemplazar sprites procedimentales por arte de calidad, comprobar cada animación in-game y pasar QA; jamás levantar flags antes de ello.

## 2026-10-28 — Iteración gráfica de enemigos, SIN aprobación todavía
- `724fcb72`: añadidos contornos de un píxel nativo y detalles de iluminación, ropa, ojos, cuerpo y metal en `tools/generate_new_enemy_sprites.py` para robot, aficionado y turista.
- `e6d36501`: añadido contorno tallado uniforme al generador de la estatua del rey de Navarra.
- **Advertencia obligatoria**: son mejoras incrementales a dibujos procedimentales que fueron rechazados. No se puede afirmar que ya hayan alcanzado calidad SNES, ni que se haya revisado una captura REAL del juego, ni que estén aprobados. Las cuatro apariciones permanecen bloqueadas por `newEnemyArtApproved=false` y `kingVisualApproved=false`. No activar hasta redibujar sprites de calidad suficiente y revisar capturas reales del motor y sus animaciones.
- Existen ejecuciones recientes de GitHub fallidas; se requiere consultar los logs y corregirlas antes de entregar APK. Este progreso no equivale a terminar el encargo del usuario.

## Continuación trabajo de los 4 enemigos — revisión de animación y captura Flutter real
- `cd473a3b`: se distinguen los fotogramas de robot, aficionado y turista; el atlas deja de depender solo de copia del mismo fotograma.
- `61317187`: grietas progresivas al despertar y detalles diferenciados en movimiento/golpe/impacto/derrota para el rey.
- `af052514`: prueba geométrica sobre los 4 atlas generados: celdas no vacías, poses diferenciadas y variación entre fotogramas. **No equivale a juicio estético.**
- `ca6d7322`: nueva prueba Flutter que usa el `StagePainter` real del juego y captura 16 imágenes de los 4 enemigos, en las etapas correspondientes, al directorio `qa/rendered_from_flutter`. No confundir con capturas desde móvil/APK; es el render Flutter auténtico.
- `d520d52e`: se añade la captura al workflow Android y los PNG al artefacto de revisión. Pendiente ejecutar, descargar y **abrir cada captura real** para inspección artística. Los cuatro enemigos siguen bloqueados para partidas mediante la puerta de calidad hasta conseguir y aprobar el resultado.
- Pendiente prioritario: redibujo artístico profundo; los nuevos detalles no bastan para afirmar calidad SNES. Repetir diseño y captura hasta calidad suficiente. No publicar como terminado.

## 28/10/2026 — Rediseño geométrico en atlas reales, pendiente de inspección
- `1e52bff0`: nuevo trabajo sobre los tres atlas: figura humana con hombros/codos/pómulos/mandíbula, volúmenes y pliegues, cámara con óptica y robot con chasis curvo, visor, ruedas y reflejos.
- `cfd29005`: rey con rostro esculpido, barba, corona, coraza, emblema medieval, grebas y texturas de piedra.
- Generación CI y captura Flutter se han solicitado automáticamente tras los commits. **No confundir la revisión del código/generador con calidad artística demostrada.** Mantener la puerta de aceptación cerrada hasta poder abrir las capturas reales recién generadas de los cuatro, corregir defectos y superar las pruebas.

## 28/10/2026 — Seguimiento de los seis enemigos
- Se mantienen seis diseños en trabajo: cleaning_robot, rival_supporter, tipsy_tourist, navarre_king, estafeta_bull y sanfermin_runner. **Ninguno tiene todavía aprobación visual de captura real y los seis continúan con su flag artístico a false.**
- La CI 40769777925 ya compiló el APK Android; la auditoría Flutter estaba ejecutándose al comprobarlo. Un APK compilado no implica personajes aprobados.
- Corrección `adc93ffc`: la cuenta atrás de recuperación del toro no se reinicia durante el cooldown. Sin esta corrección, el aviso/pose quedaba forzado a cero entre embestidas.
- Los atlas de los seis son candidatos y deben contrastarse contra capturas reales de StagePainter. La siguiente acción técnica es recoger la ejecución completa, inspeccionar visualmente los fotogramas reales, documentar defectos por personaje y continuar redibujando. No levantar flags basándose en que el workflow termina en verde.

## 29/10/2026 — Retoma de trabajo artístico SIN ejecutar GitHub Actions
- `e85a9a3b`: los estados derrotados del toro y del corredor tienen ahora una silueta distinta, tumbada y anclada en suelo. Se elimina el desplazamiento del toro derrotado que podía llevar partes fuera de los límites de la celda.
- `74ee8b9f`: robot, aficionado y turista ya no usan el mismo muñeco vertical simplemente comprimido al perder: se introducen poses caídas diferenciadas.
- Son cambios reales de código fuente del generador y **no pruebas de calidad artística superadas**. Pendiente regeneración, inspección de PNG reales y capturas del StagePainter, sin lanzar Actions porque el usuario ordenó compilación únicamente bajo petición expresa y alertó del límite de almacenamiento.
- Los seis enemigos permanecen bloqueados en las partidas normales hasta superar revisión artística y técnica. Priorizar a continuación maestro gráfico de toro y corredor, y luego rey, robot, aficionado y turista.

## 29/10/2026 — Mejoras reales del bloque de seis enemigos, sin usar Actions
**Rama:** `work/revision-visual-20261028-continuidad`. No se ha tocado `main`.

### Sprites de seis enemigos: código del generador cambiado
- `df7fde51` — toro de Estafeta: musculatura, planos del morrillo, hocico y ollares, base de los cuernos, pezuñas y cambios de pose (alerta/carrera/ataque/impacto). Corredor: pliegues de vestimenta, cara, cabello, braceros y gestos de alerta/carrera/ataque; conserva blanco y rojo de San Fermín.
- `75534240` — rey de Navarra: hombreras pétreas con bisel, barba, nariz, relieve de cadenas navarras en el peto, marcas de cincel y poses diferenciadas de despertar, caminar, golpear y recibir un impacto. Derrota de cuatro grados progresivos de desplome y escombros.
- `aa879761` — robot: ventilación, rodillo, ruedas, torre óptica, cepillos y brazo de ataque. Aficionado: cara, pelo, detalles de camiseta, pliegues y extremidades en acción. Turista: camisa, sombrero, óptica de la cámara, cara, zancada y accesorios.

### Comportamiento e integración corregidos (sin afirmar prueba Android)
- `72d00905` — toro: 0,55 s de aviso real usando reloj separado (evita embestida instantánea al acercarse); embestida interrumpible al recibir impacto. Rey: interrupción del golpe de tierra cuando recibe daño. Corrección grave: turistas de capítulos 1–3 ya usan IA `tipsyTourist` y no `cleaningRobot`.
- `36895e21` — estado de reacción al impacto conservado durante recuperación; se cancela la anticipación de ataque.
- `c50e35d5` — fundido gradual y uniforme tras derrota para los seis sprites.
- `8097619a` — la captura REAL de Flutter, cuando se ejecute con autorización, comprobará las 6 fases por cada enemigo (36 vistas, no 24). Es prueba de `StagePainter`, no un montaje.
- `475e5d22` — nuevos tests de recuperación tras impacto.
- `a26b5cbf` — herramienta local que compara 6 atlas reales con los PNG originales de Miren y Sara, indicando explícitamente que no es una captura Flutter.

### Calidad: restricciones y pendientes
- NO se ha ejecutado ningún workflow GitHub Actions ni compilado Android en este bloque.
- NO se ha regenerado ni inspeccionado el nuevo atlas como imagen. Hasta ello no puede certificarse la calidad artística.
- **Las seis puertas `enemyArtValidated` siguen en `false`**: los enemigos no salen en partidas normales. No declararlos integrados plenamente para nueva versión.
- Validación pendiente: ejecutar generadores y QA Python localmente, comprobar 36 capturas reales Flutter y contrastar visualmente todos los estados con Miren y Sara; corregir cualquier irregularidad. Para activar y publicar es necesaria aprobación artística y pruebas técnicas con autorización del usuario para correr Actions.

## 29/10/2026 — Cuatro enemigos clásicos: breakdancer, bully, referee y rival
Encargo directo, rama `work/revision-visual-20261028-continuidad`, sin merge, APK ni GitHub Actions.

### Referencia realmente inspeccionada
- Sprites originales `assets/images/futbolista.png` y `assets/images/bailarina.png` (mayor riqueza de anatomía/rostros/volumen).
- PNG originales `assets/images/enemies/{breakdancer,bully,referee,rival}_0..4.png` y reacción adicional `breakdancer_5.png`, `referee_5.png` inspeccionados mediante GitHub. No confundir `rival` con `rival_supporter`.
- Estos cuatro conservan dibujos artísticos originales más ricos que los seis enemigos nuevos; rehacer sus siluetas con primitivas empeoraría el resultado.

### Trabajo de código y de arte subido a GitHub
- `f2df0d3d` + `bdb1c279`: nuevo selector `lib/classic_enemy_pose.dart` y `StagePainter` con secuencias de reposo, desplazamiento, ataque, impacto y derrota específicas para cada personaje; evita carreras en el sitio, cardazo fijo y rotación genérica del bailarín.
- `c9a45ff3`: nuevo restaurador de PNG genuinos `tools/refine_four_classic_enemies.py`, opera sobre imágenes reales, no sustituye caras/cuerpos por formas genéricas. Mejora color/separación, bordes, costuras, prendas, equipación/insignias y calzado; escala nativa x2 sin suavizado solo donde conviene, conserva original del bully a escala x1. Antes/después generado en `qa/art_review`; no es captura del juego.
- `792b9c7b`, `34e6e81b`, `9031b6b0`, `162d4b36`: se recuperan poses REALES de impacto `breakdancer_5` y `referee_5`, se cargan por el motor, se pulen 22 PNG y se calculan sus recortes reales en la próxima ejecución manual.
- `ceb6d192`: un golpe del balón o del peine cancela el ataque pendiente de árbitro y bailarín; no puede dispararse un proyectil después de haber recibido el impacto.
- `65a33866`: condiciones explícitas en Dart para evitar ambigüedad de análisis.
- `4116a20b`, `69a07fc0`: incorporación del generador y exportador de recortes a workflows YA MANUALES; no se han ejecutado.
- `d69ef3ec`, `9226a5aa`: QA técnica de integridad PNG, 22 poses y cuatro hojas originales/vs/revisadas.
- `d3b8c057`: tests de secuencia de animación pura (no ejecutados).
- `f4986a0e`, `fa4ee149`: capturador Flutter real de 24 escenas, diseñado para verificar seis estados de cuatro enemigos al autorizar ejecución.

### Pendiente: NO afirmar que el arte está aprobado
- No se ha ejecutado aquí el script de pulido ni se han regenerado/subido PNG binarios. Los cambios de código ya están en GitHub y el pipeline manual los aplicará antes del próximo build autorizado.
- No se ha podido ejecutar Flutter ni examinar capturas nuevas por la prohibición de usar Actions y la falta de SDK Flutter local en esta sesión. Las 24 capturas serán auténticas solo cuando se ejecute StagePainter.
- La comparación posterior de los PNG regenerados con Miren/Sara y la validación de colisiones/anatomía quedan PENDIENTES. No declarar que los cuatro enemigos alcanzaron ya la misma calidad artística ni que han sido probados en Android.

### Revisión final del mismo bloque
- `384f92b1` — se añade ventana de aviso de 0,36 segundos al ataque cuerpo a cuerpo de `rival` y `bully`. El golpe se aplica UNA vez al finalizar el aviso solamente si el jugador sigue al alcance y a nivel del suelo; saltar o golpear interrumpe. Sus signos de alerta se muestran con la animación actual del mundo.
- `03912d1f`, `018e7cb8` — los dibujos de aviso y ataque se seleccionan antes del daño y tienen tests puros dedicados.
- `1202e636` — captura real preparada para activar el estado de ataque del bully y del rival, no dibujar por error reposo en el caso de prueba.
- Estas mejoras son modificaciones verificadas por lectura del código en GitHub, todavía NO probadas ejecutando Flutter ni una partida.

## 29/10/2026 — Portada adaptable: corrección técnica, aprobación gráfica PENDIENTE
Encargo: corregir franjas laterales, logotipo TWC y botones sin alterar portada aprobada; cambios guardados exclusivamente en rama de desarrollo, sin Action ni APK.

### Defecto confirmado en código y en captura real anterior
- `lib/main.dart`: incluso en `Screen.title` se renderizaba `FittedBox(BoxFit.contain)` con contenido fijo 800×450; cualquier dispositivo más panorámico dejaba bandas laterales fuera del juego.
- Dentro de `_title()` el PNG se dibujaba con `BoxFit.fill`, peligro de deformación si cambian las proporciones.
- El logotipo se superponía como `twc_corporate_verified_091.png` sin garantizar que el archivo careciera de rectángulo de fondo.
- La captura REAL del dispositivo aportada en la conversación (1536×691) muestra un área central ~1229×691 y las franjas a ambos lados. No confundir esa captura ANTERIOR con una prueba del código nuevo.

### Cambios reales guardados
- `157524ac`: nuevo `lib/adaptive_title_screen.dart` con superficie panorámica 20:9 de borde a borde, sin escalar y sin recortar la composición 16:9 central; posicionamiento de botones y logotipo con transformada física única, estados habilitado/deshabilitado de Continuar.
- `84844512`: `main.dart` evita exclusivamente para portada el `FittedBox` heredado del gameplay; capítulos, mapas y demás interfaz siguen con su render anterior.
- `743d06b3`: PNG panorámico y logo de transparencia registrados en `pubspec.yaml` (ARCHIVOS BINARIOS AÚN NO PRESENTES).
- `0d816328`: `tools/extract_twc_title_logo.py` extrae TWC/sello desde PNG existente y elimina matte rectangular mediante alfa; si no puede conservar el sello, aborta con error en lugar de inventar logotipo.
- `377ef5cd`: `qa/verify_adaptive_title_art.py` exige panorama real sin réplica/espejo/desenfoque y **centro original idéntico píxel por píxel**, con costuras suaves y logotipo de transparencia. Bloquea la versión si falta el arte.
- `77ad2002`: tests de 16:9,18:9,19,5:9,20:9 y 19,5:9/20:9 en Android; verifican posición de hitboxes y Continuar desactivado.
- `b0fb6834`: captura real futura de las cuatro proporciones con `AdaptiveTitleScreen` en Flutter, sin fingir una captura Android.
- `e26c5c72`, `73813974`, `b017ab53`: QA y generación de logo integradas en workflows **manuales**; bloqueo por falta de panorama/arte de calidad antes de compilar APK. No se ha ejecutado ningún workflow.

### Pruebas realizadas
- Geometría calculada INDEPENDIENTEMENTE mediante Python local para 800×450, 900×450, 975×450, 1000×450 y 2340×1080: centro íntegro; rectángulos de botones dentro del centro y sin solapamiento; PASS. No equivale a test Flutter.
- Dos experimentos locales de prolongación con recortes de una captura anterior (no PNG original) dieron mosaicos/repeticiones artificiales; **descartados**, NO subidos a GitHub ni vendidos como solución.
- No se han regenerado PNG de logo ni panorama sobre los recursos originales: no se dispone del PNG grande del repositorio dentro del contenedor local; GitHub sí permite leer el código y guardar commits.
- **BLOQUEADOR PENDIENTE:** el recurso `assets/images/title_wide_20x9.png` debe contener laterales artísticos coherentes y preservar el PNG original en el centro. Sin imagen de ese nivel, la QA impide generar próxima versión; no declarar corrección definitiva completa.
- **BLOQUEADOR PENDIENTE:** ejecutar limpieza del sello y examinar PNG nuevo; revisar luego capturas Flutter auténticas a cuatro aspectos.

## 29/10/2026 — Colegio interior: se elimina la clonación real de aulas
Rama de trabajo: `work/revision-visual-20261028-continuidad`. Sin Actions, APK, merge a main ni assets binarios inventados.

**Defecto confirmado con imágenes auténticas:** en el artefacto previo de GitHub Actions `12841021198`, las tres imágenes `z0_panel_0..2`, `z1_panel_0..2` y `z2_panel_0..2` tenían diferencia media de píxel exactamente **0** dentro de su zona: se clonaba la misma imagen. El generador `make_wall` seleccionaba `crop_w=source_w=1320`, por lo que `left=0` para TODAS las variantes. Comprimía además 1320×480 hasta 880×278, deformando los originales.

**Cambios reales en código:**
- `1d1e3e43` — nueve recortes distintos por zona del arte escolar auténtico, desde el PNG fuente **a escala nativa 1:1**, preservando personajes, cristales y detalles.
- `2079cd16` — recorrido temático con pasillos, aulas de matemáticas y tecnología usando solamente las tres imágenes originales existentes; pasillos intermedios entre aulas.
- `e52b805e` — en `lib/interiors_parallax_twc.dart`: nueve variantes escolares permutadas sin repetir durante nueve módulos, frente a las tres variantes de danza que no se alteran. Distribuciones de muebles de seis tipos, incluyendo huecos abiertos.
- `635b4a70` — `lib/main.dart` carga y pinta esas nueve variantes, y sustituye el pupitre repetido cada 570 unidades por composiciones locales vinculadas a la sala.
- `4708eb06` — marcos físicos de puerta a intervalos de cuatro módulos escolares, además de los límites del pabellón. Todo a velocidad 1:1 mundo; no mueven el cielo.
- `8be6b0f6`, `066bb3aa` — reproductor Python para ver cambios reales de salón/ventanas, incluye una plancha de nueve encuadres verdaderos del colegio. No fingir que son capturas del motor Flutter.
- `d3aa2226` — QA para exigir nueve paneles distintos y comprobar procedencia de píxeles originales, ventanas transparentes y movimiento autónomo del exterior solo a través de ellas.
- `70f4b079` — tests Dart de composición, distribución de muebles y velocidades parallax .30 / .56 / 1.0.
- `d147f422` — 13 futuras capturas reales del motor `StagePainter` en corredor, aula, laboratorio y bordes.
- `32060baf` y `78f4db52` — QA incorporada a los workflows MANUALES; no fueron ejecutados.
- `84712f70` — conteo correcto del manifiesto: 35 imágenes escolares = 27 paneles + 3 fondos/portada de puerta + 5 objetos.

**Qué hemos comprobado ahora sin compilar:** revisión de los tres PNG fuente reales y del código, clonación exacta de las variantes anteriores; cálculo geométrico de las nueve posiciones de recorte 0,55,110,165,220,275,330,385,440 para originales de 1320px; las secuencias de sala visitan las nueve variaciones sin repetirlas prematuramente; seis patrones de mobiliario, con cuatro grupos sin mesas cada 14 módulos.

**Pendiente de validar y NO APROBADO AÚN:** ejecutar en un checkout real `python3 tools/build_interiors_parallax_twc.py`, `python3 -m unittest qa/test_interiors_twc.py`, `python3 tools/preview_interiors_twc.py`; inspeccionar hojas de contacto de la NUEVA generación, corregir si alguna unión visual desentona; ejecutar Flutter y 13 capturas de juego al autorizar pruebas. No se ha ejecutado el generador en esta sesión porque los PNG fuente del repositorio privado no están materializados localmente. El pipeline sí queda preparado para generarlos antes de cualquier APK futura.

### 29/10/2026 — Corrección adicional basada en los objetos reales del colegio
- Al abrir `mesa_aula.png` y `ordenador_aula.png` del artefacto GitHub previo `12841021198`, se comprobó que la extracción original dejaba **82.6%** del pupitre y **60.1%** del monitor con alfa significativo; los recursos incluían placas rectangulares de baldosas y pared azul, que daban el aspecto de collage.
- `a5db8a09`: `tools/build_interiors_parallax_twc.py` recorta ahora la silueta auténtica de la mesa (tapa, patas, papel, cuaderno y sombra ligera) y el monitor (pantalla, soporte, teclado y ratón), con transparencia real donde antes aparecían paredes y suelo. No se redibujó ni sustituyó el arte original.
- `915fa48e`: pruebas que rechazan una extracción con fondos rectangulares y exigen huecos transparentes entre las patas de la mesa y alrededor del monitor.
- Los dos **recursos PNG antiguos y los recortes mejorados** se inspeccionaron localmente, sobre fondo de comprobación ajedrezado: mejora perceptible de la silueta sin artefactos de fondo. Esto valida la operación de recorte sobre materiales existentes, NO una escena del juego ni la calidad completa del capítulo.
- Todos estos cambios se aplicarán cuando el generador vuelva a ejecutarse en el próximo proceso autorizado; no se han subido PNG regenerados ni ejecutado Android/Actions.
