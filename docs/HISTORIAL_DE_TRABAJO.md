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
