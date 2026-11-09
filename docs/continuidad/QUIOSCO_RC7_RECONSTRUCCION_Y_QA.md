# Quiosco RC7 / Plaza del Castillo — primera integración protegida

Rama: `work/revision-visual-20261028-continuidad`, PR #5. **NO APK, NO MERGE.**

## Hechos confirmados por código y pruebas

- Capítulo objetivo: índice 3 `Plaza del Castillo`, no etapa 1 (Ayuntamiento) ni 2 (Estafeta).
- Legado: `scene_3` con `_backLayer(...,0.014)` + franja `mid_3` repetida; el entorno se interpreta incorrectamente como plano lejano.
- Nuevo renderizador `_quioscoBackgroundRC7` en `lib/main.dart`: 39 paneles de 960×390, desplazamiento físico 1:1, `ground_3` y colisiones intactos.
- Flag `TWC_QUIOSCO_RC7_ART` **falso por defecto** hasta que existan todas las imágenes y capturas reales inspeccionadas.
- Prueba de código/contrato y regresiones: [GitHub Actions 41992232890](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41992232890) **SUCCESS**.
- Se ha creado el importador SHA-256 `tools/import_quiosco_rc7_zip.py` y el workflow `quiosco-rc7-only.yml` para repetir el proceso validado en colegio, Estafeta y Ayuntamiento.

## Referencia artística y alcance

El objeto único es el **quiosco de música de piedra**, con cúpula e interior azul, columnas jónicas, balaustrada, escalinatas y su entorno de Plaza del Castillo. No confundirlo con un puesto comercial de prensa. Referencia municipal: https://www.pamplona.es/sites/default/files/2019-01/elementos_no_vinculados_edificacion_2.pdf

Se ha generado en el entorno de conversación un primer archivo candidato ZIP de 39 paneles de 960×390 y un quiosco único a la coordenada 17920, con SHA-256 `579be9b94275b22dcc232d69a8304c00bbb459e914c768fa82c57a3ea475f606`.
Nombre exacto de subida: `QUIOSCO_RC7_SUBIR_GITHUB_2.zip` en `qa/quiosco_inbox/`.

## Calidad pendiente

Este arte es un **candidato inicial**, no una aprobación. El contacto de cinco sectores mostró fachadas/árboles repetidos y transiciones entre fragmentos que precisan revisión. El primer montaje que añadía personajes y un puesto de prensa repetidos fue rechazado y **NO debe subirse**. El ZIP posterior utiliza únicamente arquitectura de fondo y quiosco único, pero repite elementos de fachada y requiere correcciones después de ver los renders auténticos.

La importación automática valida integridad, produce 18 fotogramas `StagePainter` (16:9, 19,5:9, 20:9), verifica desplazamiento de cámara +60 y guarda 38 capturas de juntas; este proceso no implica aprobación artística. Solo después de inspeccionar y mejorar se activará por defecto en una compilación normal de RC7.

**Bloqueo material conocido:** el contenido binario generado en el contenedor no se puede pasar automáticamente a los argumentos de GitHub a través del conector actual; hay que subir una vez el ZIP preparado a `qa/quiosco_inbox/`. No pedir Work ni cambios adicionales al usuario hasta agotar el método establecido.

## Estado REAL tras importar y probar — 05/11/2026

El ZIP `QUIOSCO_RC7_SUBIR_GITHUB_2.zip` fue subido a la rama correcta. [GitHub Actions 41997368225](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41997368225) lo importó íntegramente con éxito y guardó 39 WebP, maestro único, `manifest.json`, 18 capturas reales en `qa/quiosco_rc7_flutter/` y 38 en `qa/quiosco_rc7_joins/`.

Se integró en `lib/main.dart` con `twcQuioscoRC7ArtworkEnabled=true` de manera permanente y sin opciones de desarrollo; se ajustó el selector del capítulo y se evitó cargar `scene_3` y `mid_3` antiguos en paralelo. La QA de compilación normal [41998345345](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41998345345) terminó en **SUCCESS**; verificó `flutter analyze`, contrato de visibilidad incluso con `TWC_QUIOSCO_RC7_ART=false`, 18 capturas reales en tres relaciones de aspecto, seis comprobaciones de cámara, 38 uniones y regresiones de Estafeta y portada. La QA anterior de Ayuntamiento [41998345315](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41998345315) también fue satisfactoria.

### Limitación artística identificada al VER los archivos auténticos

La primera versión del mundo emplea solo **11 ventanas de recorte de una única ilustración original** para construir unos **163 segmentos de fachada** a lo largo de 37.440 px; el quiosco de música aparece una vez en x=17.920. Esta construcción **repite balcones, farolas, terrazas, árboles y fragmentos de escalera** y causa cambios bruscos de arquitectura en cortes internos a los paneles. Se comprobó expresamente en capturas reales `800x450_1200.png`, `800x450_9200.png`, `800x450_18200.png` y `800x450_35700.png`, y en contactos de las 38 juntas de los WebP de origen.

**Decisión de calidad:** La importación y los controles de cámara/recursos están cerrados y el nuevo escenario se mostrará en una RC7 de prueba, pero **NO debe declararse «reconstrucción artística definitiva» ni «sin repeticiones»**. Faltan composiciones nuevas de fachada y un recorrido largo arquitectónicamente coherente para lograr el mismo nivel artístico exigido al capítulo. Se necesita ampliar la biblioteca de arte original del entorno y sustituir los segmentos redundantes; los 11 recortes actuales no son material suficiente. Esta limitación no la resuelven `flutter analyze` ni el mero conteo de 38 capturas: esos tests son técnicos.

Las ilustraciones, paneles infográficos o simulaciones generadas por IA durante la conversación **no son capturas StagePainter y no deben utilizarse como prueba de un juego terminado**. La única evidencia de render Flutter son las imágenes de las carpetas `qa/quiosco_rc7_flutter/` y `qa/quiosco_rc7_joins/`.

**Sin APK, sin publicar, sin fusionar PR #5.**

### Última verificación y criterio de salida (05/11/2026)

- [GitHub Actions 42000563223](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/42000563223): **SUCCESS**, ya con la activación normal del quiosco, las 56 capturas y la auditoría de repetición independiente. 
- [GitHub Actions Estafeta 42000563217](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/42000563217): **SUCCESS** en la misma rama.
- Herramienta de bloqueo artístico: `python3 tools/audit_quiosco_visual_repetition.py --strict`. Con el material actual registra 163 segmentos, 11 recortes únicos (6,75 %), hasta 22 repeticiones de un mismo recorte, y **falla intencionadamente** para impedir aprobar falsamente el arte definitivo. El modo sin `--strict` genera diagnóstico y permite QA técnica para una RC de pruebas.
- El capítulo es **utilizable en RC7 de prueba**, pero **NO cumple aún el requisito inicial de evitar repeticiones y cortes evidentes**. No hay aprobación artística final.


## 09/11/2026 — nueva orden artística del usuario (reconstrucción integral)

**Aprobado expresamente:** sustituir el montaje de fachadas repetidas y cortes internos por sectores amplios con arquitectura continua, destacar el quiosco de música como hito único y mantener tres capas de profundidad al estilo del capítulo 1. Conservar íntegros plataformas, enemigos, monedas, físicas, controles y restantes capítulos. No considerar el arte actual «terminado» ni activar piezas aisladas.

**Cambios guardados y comprobados en GitHub:** 
- `qa/quiosco_rc7_art_rebuild_plan.json`: seis sectores ordenados que cubren los 37.440 px, con monumento único x=17.920 y ancho 1.170; contrato de planos 0.30/0.56/1.0 y excepción explícita para anclar el quiosco a coordenadas del suelo. Estos números están en el MANIFIESTO actual, no implican que el nuevo dibujo esté generado.
- `tools/check_quiosco_rebuild_plan.py`: comprobador independiente que cruza los sectores, paneles y posición del hito con el manifiesto real. **Pendiente ejecutar en checkout completo**; crear el archivo no equivale a superar QA.
- Primera ilustración candidata de nuevas fachadas creada en esta conversación como PNG. **No está subida al repositorio, no está integrada y todavía no debe aparecer en una compilación.** No confundirla con capturas de StagePainter ni con arte aprobado.

**Estado fiel:** planificación versionada; **reconstrucción de imágenes, montaje por sectores, captura real, revisión en movimiento, ejecución Flutter y validación Android PENDIENTES**. El fondo RC7 existente sigue visible y conserva sus defectos. No declarar cierre ni generar APK automáticamente.

**Siguiente acción concreta:** crear la biblioteca de panorámicas originales distintas (no recortes reciclados), registrar sus hashes y subidas reales; recomponer sectores enteros ajustando líneas de cornisa, arcadas, árboles y perspectivas; recortar el maestro continuo en 39 paneles; auditar todas las uniones internas y las 38 interpanel; importar en Flutter; inspeccionar barrido real alrededor del quiosco y a lo largo del nivel; corregir y verificar regresiones antes de cambiar los recursos activos.

**Seguridad:** no fusionar PR #5, no ejecutar workflows manuales ni compilar APK sin orden específica.

## 09/11/2026 — constructor de nuevos fondos (continuación)

Guardados en GitHub y recuperados después de cada escritura:

- `tools/build_quiosco_sectors_candidate.py`: solo admite seis panoramas **originales** de anchura exacta por sector, altura 390 y píxeles opacos. Rechaza entradas ausentes, estiramientos implícitos, transparencias y archivos idénticos. Produce los 39 WebP sin escalado horizontal y conserva sin recomprimir el quiosco de música único del material validado. Su ZIP es **candidato** y no modifica el juego.
- `tools/audit_quiosco_candidate_seams.py`: comprueba geometría y fuentes diferenciadas del candidato y calcula diferencias de color entre 38 pares de bordes. La métrica no prueba continuidad arquitectónica interna, ni sustituye inspección artística o un vídeo de desplazamiento real.

**Situación:** faltan seis fuentes originales con anchuras (7200, 7200, 3520, 2880, 7200, 9440), todas por 390 px, para ejecutar el empaquetador. La primera imagen candidata generada en el chat no llena por sí sola un sector a resolución nativa, y NO se reutilizará/escalará para fingir variedad. El fondo actual del juego no se reemplaza. No se han ejecutado Flutter, Actions ni pruebas de integración en esta fase. Pendiente crear arte suficiente e importarlo después de validación.


## 09/11/2026 — Montador de arte nuevo (segunda fase)

Se ha subido a esta rama y comprobado por lectura remota `tools/build_quiosco_reconstruction.py` (commit `ab549dc912fcdfe92dc6c72f92a9f1ad0c54173d`). Lee seis panorámicas originales con dimensiones EXACTAS por sector según `qa/quiosco_rc7_art_rebuild_plan.json`, prohíbe escalar cada imagen, comprueba continuidad geométrica, rechaza archivos idénticos y genera 39 WebP lossless y un manifiesto de *staging* con SHA-256 y medidas orientativas de las cinco uniones entre sectores. Impide explícitamente escribir dentro de `assets/` y sobrescribir una carpeta de salida que contenga archivos. **No ha sido ejecutado aún con los seis panoramas definitivos**, ya que todavía no existen todos. No debe activarse el resultado automáticamente.

El candidato de fachadas creado en la conversación fue inspeccionado en 2172×724 píxeles; se ha producido un recorte de 2172×390, sin escalado, para evaluar proporciones de pantalla. Ambos siguen como **arte candidato en archivos de conversación, no importados en GitHub**. Esa ilustración es insuficiente para cubrir un sector de 7200 px y está prohibido estirarla o repetirla artificialmente hasta llenar el recorrido.

**Pendiente inmediato**: elaborar ilustraciones realmente distintas y completas para los seis sectores (7200, 7200, 3520, 2880, 7200, 9440 px de ancho respectivamente; altura 390), con composición arquitectónica coherente en cada límite; decidir por arte y captura el tratamiento del quiosco original en la zona central; después ejecutar montador y verificar vídeo/capturas auténticas de Flutter. Un diagnóstico de diferencias de píxel no sustituye revisión visual.

No se han cambiado `lib/main.dart`, assets activos, física, colisiones, protagonistas ni enemigos. Sin Flutter, sin APK, sin merge y sin certificación artística.


## 09/11/2026 — Conectores arquitectonicos A/B/C

Orden aprobada: cada segmento comparte un edificio con el anterior, evitando un duplicado al ensamblar. Implementado en tools/build_quiosco_reconstruction.py y configurado en qa/quiosco_rc7_art_rebuild_plan.json: cinco juntas A-B-C-A-B con franja de solapamiento de 256 pixeles. Cada imagen posterior debe comenzar con 256 pixeles identicos a los ultimos 256 de la anterior. El montador rechaza uniones diferentes y descarta la copia superpuesta, conservando una sola aparicion. El quiosco sigue siendo unico y permanece anclado en mundo.

Nueva prueba tools/test_quiosco_connector_overlap.py: compara una imagen sintetica continua con paneles ensamblados y comprueba que una junta alterada se rechaza. Prueba guardada pero EJECUCION PENDIENTE. Commit de prueba d900d55b7f118f5de97fef53983c3133609405e1.

ESTADO: codigo de ensamblaje en GitHub; faltan ilustraciones definitivas de seis sectores, ejecucion del montador, Flutter StagePainter, inspeccion del desplazamiento, regresiones y aprobacion visual del usuario. Los 39 paneles activos no se han cambiado. No APK, no fusionar PR.


## 09/11/2026 — Produccion de conectores a partir de piezas originales

La idea de compartir los edificios de entrada/salida se ha trasladado tambien a la fase de preparacion: `tools/prepare_quiosco_connector_sources.py` (commit `49bce794309ffd3962348143652159b783dd52c7`) acepta seis nucleos arquitectonicos realmente distintos y tres PNG de conectores A/B/C de 256x390. Genera las seis panoramicas esperadas por `tools/build_quiosco_reconstruction.py`; el montaje posterior elimina la franja compartida duplicada. Las transiciones entre cada nucleo y su conector aun requieren revision artistica; las uniones pixel-identicas entre piezas no garantizan que las cornisas, arboles o edificios queden bien dibujados.

Se ha guardado `tools/test_quiosco_connector_production.py` (commit `a0f972602590d216ae10dd31edf4880d550664df`), caso sintetico de tres nucleos + dos conectores que compara el raster final con el raster original para detectar columnas duplicadas/perdidas. **No consta ejecucion del test en el runner ni del nuevo pipeline con recursos definitivos.** Los seis nucleos originales de produccion aun no estan creados/subidos. No hay nuevas capturas reales StagePainter, ni arte final validado, ni APK; el codigo y PNG activos estan protegidos. Siguiente accion: producir arte original amplio con conexiones revisadas, ejecutar los dos tests, montar candidate y contrastar captura Flutter real.


## 09/11/2026 — Seguimiento de cierre y evidencia visual

Verificados los codigos de constructor de seis sectores y prueba sintetica. Se anade `tools/preview_quiosco_connector_seams.py` (commit `ba09be218a3ddad87bb4995679127e3e81188a45`) para generar a partir de PNG de origen reales cinco recortes de conexiones entre nucleos y conectores, ademas de cinco versiones marcadas con limites. Las imagenes son QA de recursos, NO capturas StagePainter. Prohibe escritura en assets activos y rechaza conectores cuyos 256 px compartidos no son identicos.

Limitacion comprobada en esta sesion: los seis nuevos nucleos de produccion NO estan en el repositorio ni en los archivos disponibles del entorno; solo existe un candidato antiguo insuficiente para cubrir la longitud. No se ha ejecutado el ensamblador con arte definitivo; no hay captura real del fondo nuevo ni aprobacion estetica. Existe captura autentica del fondo ANTERIOR `qa/quiosco_rc7_flutter/800x450_18200.png`, que NO demuestra la mejora. Los workflows Quiosco permanecen en modo manual por restriccion previa de presupuesto; no se han lanzado. No cambiar el fondo de RC7, no generar APK ni fusionar PR hasta contar con arte original, inspeccion del barrido en Flutter y autorizacion de version.

Siguiente accion concreta: elaborar y transferir los seis nucleos y conectores A/B/C, ejecutar test_quiosco_connector_production.py, prepare_quiosco_connector_sources.py, build_quiosco_reconstruction.py y preview_quiosco_connector_seams.py, inspeccionar las diez juntas internas/externas, luego StagePainter genuino y QA de juego.


## 09/11/2026 — Repositorio público: reanudación de QA gratuita

Confirmada visibilidad PUBLIC y permisos de escritura. GitHub indica que sus ejecutores estándar alojados son gratuitos para repositorios públicos (con límites de uso y almacenamiento). Se ha creado `.github/workflows/quiosco-connectors-qa.yml` en commit `d75c2ca96506348934a242f6c3b58c4028437207`; disparador por cambios específicos, una única batería ligera de pruebas Python, SIN APK y SIN otros workflows de desarrollo. Primera ejecución: https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/42618299825 . No confundir los tests de conectores con validación artística o capturas reales de StagePainter.

Los seis núcleos de arte final y los tres conectores finales siguen pendientes. No sustituir los 39 paneles activos hasta revisarlos en contexto y registrar pruebas genuinas del nuevo arte.


### Resultado verificado del workflow público (09/11/2026)

Ejecución GitHub Actions [42618299825](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/42618299825): **SUCCESS**, commit `d75c2ca96506348934a242f6c3b58c4028437207`. Pasaron instalación de Pillow, `tools/test_quiosco_connector_overlap.py`, `tools/test_quiosco_connector_production.py` y `tools/check_quiosco_rebuild_plan.py`. Es validación **técnica sintética y de geometría**, no prueba de recursos artísticos terminados ni visualización en Flutter. El repositorio está confirmado PUBLIC y los runners estándar no consumen minutos de la cuota privada. Mantener el flujo limitado a las rutas del Quiosco.

Se examinó visualmente en el entorno de conversación el arte candidato de fachadas `quiosco_fachadas_tramo_candidato_2172x390.png`: recorte de fachadas y soportales SIN cielo ni base de suelo completos, con escala de arquitectura grande y longitud insuficiente para el primer sector (7.200 px). No elevarlo a fondo de juego ni reutilizarlo en mosaico; sirven de referencia de estilo y posible fuente parcial. Arte nuevo integrado: NO. Capturas Flutter del nuevo montaje: NO.
