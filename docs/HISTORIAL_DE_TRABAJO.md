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
