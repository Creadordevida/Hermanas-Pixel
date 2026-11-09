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


### Prueba sobre pixeles de un recurso real (09/11/2026)

Se tomo en el entorno local el PNG candidato `quiosco_fachadas_tramo_candidato_2172x390.png` (recurso de arte generado anteriormente, NO captura del juego), se dividio en x=1170 dejando una franja compartida de 256 pixeles, y se reconstruyo un unico raster 2172x390 omitiendo la segunda copia. Se comprobo igualdad exacta byte a byte de los 2172x390 pixeles RGB del original y el resultado; PASS. Imagen probatoria local `quiosco_ensamblaje_real_prueba.png`, disponible como adjunto del chat, no en GitHub. Esto valida la operacion sobre pixeles reales del recurso candidato, pero NO demuestra que las composiciones nuevas sean distintas, ni que sus entradas/salidas encajen artisticamente, ni es captura de StagePainter. Tampoco sustituye los seis nuevos sectores que faltan.


## 09/11/2026 — Auditoria automatica de uniones internas

Nuevo `tools/audit_quiosco_connector_edges.py` commit `bb7a7272834b5d56479ff5dc568e32ce73a3bfc8`: inspecciona diez limites visuales reales entre los seis nucleos de fachadas y los cinco conectores, midiendo diferencias de columnas contiguas (media RGB, percentil 95, filas con salto >60). Marca uniones con cambios bruscos para revision manual, sin confundirlo con verificacion de identidad entre las dos copias del conector. Prueba sintetica `tools/test_quiosco_connector_edges.py`, commit `8ab7d1b9b3eb65e2ee0bec927b78df51a1ec6b8c`, comprueba que el sistema admite continuidad y rechaza cortes deliberados. Integrada en el workflow `quiosco-connectors-qa.yml` commit `7169e20952a60c5b7ea5a146bd2854b78235e470`, run https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/42619854509 . El umbral es una alerta tecnica, no certificacion visual; el arte definitivo sigue sin existir en la rama. No se han alterado recursos activos ni el motor Flutter.


## 09/11/2026 — Primera tanda nueva de arte original realmente producida

Se han generado imágenes originales de arquitectura de la Plaza del Castillo, examinadas manualmente y descartados borradores que contenían interfaces y personajes inexistentes. Se ha creado en el contenedor de conversación el archivo `quiosco_arte_curado.zip`, SHA-256 `c97d7f8b30f83bdd52a2490ac8f628be4b9d555a971cfe0eb3dd889d6110f297`, con tres PNG de 960x390 tomados a escala nativa de dos nuevos fondos ilustrados: `01_fachadas_entrada.png`, `02_quiosco_unico_referencia.png`, `03_fachadas_salida.png`, más un manifest con SHA de cada PNG y coordenadas de recorte. La vista conjunta se denomina `quiosco_tres_recursos_visuales_curados.png`. **Estas imágenes son recursos candidatos reales, no capturas del motor Flutter, y NO están transferidas todavía a GitHub.** Se incluye una sola vista de quiosco en el conjunto de tres imágenes, pero esa vista es referencia artística y no sustituye al WebP de quiosco aprobado en el motor. Estas tres muestras NO constituyen los seis panoramas finales, ni están ensambladas entre sí; no se debe cubrir el mundo de 37.440 px repitiéndolas. La versión activa permanece intacta.

Próxima acción necesaria: obtener los sectores completos con conectores A/B/C, importar sus PNG reales en la rama, auditar uniones, montar 39 paneles, generar capturas auténticas de StagePainter y revisar en movimiento. Distinguir cuidadosamente 'recurso artístico generado' de 'arte integrado y aprobado'.


## 09/11/2026 — Auditoría de los TRES recursos artísticos candidatos, resultado real

Se han abierto realmente los PNG del ZIP curado en la sesión y se han medido las dos juntas directas sin extrapolaciones: `01_fachadas_entrada` → `02_quiosco_unico_referencia`: salto medio RGB **95,10**, percentil 95 **172,58**, 267 de 390 filas con salto medio por fila mayor que 60. `02_quiosco_unico_referencia` → `03_fachadas_salida`: media **85,77**, percentil 95 **184,52**, 244 de 390 filas por encima de 60. Las tres piezas miden 960×390 y siguen siendo arte candidato, no capturas StagePainter. Resultado: **RECHAZAR UNIÓN DIRECTA**; el recorte del quiosco no comparte los conectores ni la escala/cornisa con los laterales. Se generó contacto visual real de las juntas en el entorno local: `quiosco_qa/uniones_reales_rechazadas.png`, y JSON de auditoría `quiosco_qa/auditoria_uniones_candidatos.json` (en conversación, no GitHub).

Herramienta reproducible `tools/audit_quiosco_curated_art.py` registrada en commit `c14751b9ff829fc32984b37b535679216fb9ce5c`, para auditar hashes, dimensiones y juntas a partir del mismo ZIP cuando esté disponible en checkout. **No ejecutada aún en Actions.** El objetivo sigue siendo ilustrar tramos completos distintos y compartir conectores A/B/C exactos; no construir un escenario largo estirando las tres muestras. No se modifica código Flutter ni fondos actuales; no existe captura real del fondo sustituido.


## 09/11/2026 — Primer tramo central nuevo y uniones por solapamiento sobre arte real

Creado en el entorno de trabajo un **tramo central limpio y continuo de 2172x390** a partir de `quiosco_arte_nuevo_panorama_2172x390.png` (ilustración de arte candidata, no gameplay). Se separó en `01_plaza_quiosco_izquierda.png` (1086x390) y `02_plaza_quiosco_derecha_conector_256.png` (1342x390), compartiendo exactamente los 256 píxeles de arquitectura que bordean x=1086. Se reconstruyó `03_tramo_central_ensamblado.png` (2172x390) descartando la segunda copia del solapamiento; comparación byte a byte contra el original: PASS. SHA256 del PNG ensamblado `6e9723a887f692265654243fd9fc4ed8ef14a1e4bf14fea6831fccb2b96df053`.

Archivos locales entregados al usuario: `quiosco_central_conectores_candidato.zip` (2 fuentes + ensamblado + manifest SHA256) y `quiosco_central_desplazamiento_recurso_real.gif` (recorte móvil del PNG real; NO StagePainter). Aún no transferidos a GitHub, puesto que el conector de contenidos de GitHub no admite transportar directamente PNG binarios locales. No usar el GIF como captura del juego. La franja central es un candidato visual de 2172 px, NO el escenario definitivo de 37440 px ni seis piezas completas. Tampoco sustituye al quiosco único aprobado existente en assets. No activar en RC, no reemplazar 39 paneles sin montaje completo y QA de gameplay.

Próxima tarea: transferir original a GitHub, producir restantes sectores de fachada distintos con extremos compatibles, revisar todas las uniones y obtener capturas auténticas de Flutter. No afirmar integración ni aprobación visual antes de dichas pruebas.


## 09/11/2026 — Prototipo panorámico de seis composiciones, inspección y decisión

Se ha construido localmente `quiosco_prototipo_artistico_20261109/panorama_prototipo_6_sectores.png` a partir de seis recortes de ilustraciones gráficas distintas (5 sectores sin quiosco y un único sector central con el monumento). Longitud real del prototipo **5.782 × 390**, no 37.440. Se generaron imágenes de cuatro puntos del recorrido (`contacto_4_recorridos.png`), un manifiesto con trazabilidad de recortes y un ZIP de trabajo (`quiosco_prototipo_seis_composiciones.zip`). El procedimiento usa una costura de contenido de 96 píxeles con desvanecimiento de 7 píxeles alrededor de una curva de menor error. Mediciones de diferencia inicial RGB de las cinco uniones: 71,69; 80,22; 81,08; 88,49; 74,79. **Ninguna de esas cifras permite aprobar la continuidad arquitectónica**; las uniones siguen mereciendo corrección visual. Se inspeccionó la hoja de contacto y se mantiene como **prototipo de composición experimental, NO APTO PARA INTEGRAR EN EL CAPÍTULO** hasta resolver transiciones y longitud. Estos artefactos están en la conversación, NO cargados en GitHub (limitación de transferencia binaria del conector).

El prototipo demuestra la disponibilidad de seis fuentes distintas, pero no garantiza que haya suficiente variedad para un mundo de 37.440 píxeles. No alargar mediante repetición ni estiramiento. Los assets de RC7, los controles y las colisiones quedan intactos. No existe ninguna nueva captura StagePainter del prototipo. La siguiente tarea es producir sectores amplios originales con bordes A/B/C comunes, transferirlos a GitHub y montar el mundo completo; entonces renderizar Flutter y comprobar las transiciones.


## 09/11/2026 — Captura Flutter REAL del recurso subido, aislada del juego (en ejecución)

Nueva prueba `test/quiosco_candidate_flutter_preview_test.dart` en commit `6332fbba6596238fb4836cbaff0552f579a92ce5`: lee el ZIP de seis sectores ya subido, verifica el PNG de 5782×390 y usa **un CustomPainter específico de QA** en Flutter para pintar el panorama de forma 1:1 en siete posiciones de cámara (0, 900, 1850, 2450, 3200, 4250, 4782). No utiliza StagePainter, no dibuja personajes, no es captura de partida ni modifica `lib/main.dart`. Workflow adaptado commit `8406371d8d5cb6f1d797912c7dba8244ccdb7b55` para ejecutar Flutter test, conservar PNG reales en un artefacto GitHub Actions, **sin APK, sin despliegue ni reemplazo**. Run: https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/42635975123 . No atribuir éxito antes de comprobar conclusión.

En el entorno local también se creó `quiosco_previsualizacion_candidato_7_vistas.png` directamente desde los píxeles del ZIP; es un contacto real del recurso, **NO una captura Flutter**. No existen todavía los seis fondos de producción de 37.440 px ni la revisión del gameplay en StagePainter.


### 09/11/2026 — Primera captura auténtica de Flutter del candidato gráfico (NO StagePainter)

**Verificado:** workflow https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/42637909799 **SUCCESS** (y repetición final https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/42638008924 **SUCCESS**). Con Flutter 3.47.8 y test `test/quiosco_candidate_flutter_preview_test.dart` fueron renderizados **siete PNG reales de Flutter** mediante `CustomPainter` QA aislado, de 1000×450, leyendo el panorama original de 5782×390 importado desde el ZIP. Cámaras en 0/900/1850/2450/3200/4250/4782, con artefacto `quiosco-six-sector-flutter-candidate-NOT-gameplay` (artefacto 13684590240 de la primera ejecución exitosa). Se descargó, abrió y verificó el ZIP de capturas; se creó en la conversación `quiosco_7_capturas_reales_flutter_candidato.png` con las siete imágenes genuinas y `quiosco_captura_flutter_real_candidato_x2450.png` recortada a la altura de arte 390 para evaluar el quiosco. **No son StagePainter ni partida de Miren y Sara**, sino render Flutter de un recurso candidato en cámara 1:1. La franja beige inferior de los originales corresponde al viewport QA 450 alto frente a arte 390; no es suelo del juego.

Inspección visual: la estructura del quiosco se distingue correctamente cerca de x=2450; el panorama conserva repetición de fachadas (las mismas mansardas/orieles se repiten entre zonas) y quedan por revisar las cinco uniones. Por ello el arte del prototipo **no puede sustituir todavía** los 39 tiles de 37.440 px. Pendiente nuevos sectores y verificación del render real del capítulo con StagePainter. No APK/no merge/no cambios en juego.


## 09/11/2026 — Fase de CAPTURAS StagePainter con el candidato de seis sectores

Se ha añadido una **inyección exclusivamente de QA**, optativa y nula en la compilación normal (`qaQuioscoPrototype`) al widget HermanasGame y a StagePainter, commit `3d700693d4e11219ea8a01028b9c7a0f3e13d7df`. Cuando una prueba la proporciona, el motor de stage 3 renderiza los píxeles del PNG candidato a 1:1 solo dentro de su pequeña extensión; en juego normal sigue utilizando los 39 WebP existentes sin cambios. Conserva suelo, sprites, físicas y enemigos normales. La imagen del candidato se carga desde el ZIP real previamente subido, sin simular el juego.

Prueba `test/quiosco_candidate_stage_painter_test.dart`, commit `1f94dcd4b7baef946dfebe08992d8f109d3f6610`: seis posiciones de personaje (1200,1850,2450,3250,4250,5350), tamaño 1000x450, identificación explícita del `StagePainter` en el árbol real de widgets y escritura de PNG genuinos. Pipeline en Actions, commit `b3161379230aff7f1535dd0723c6abd6ca482660`, run https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/42641693880, con publicación de capturas como artefactos. **El pipeline se ha lanzado; su resultado no puede darse por superado hasta recibir su conclusión.** Esta prueba no valida la continuidad de los 37.440 px (faltan sectores), ni aprueba arte, ni cambia el APK. No fusionar antes de arte definitivo y revisión humana.


## 09/11/2026 — Capturas auténticas de StagePainter del candidato (logro comprobado)

Corregido atasco de la QA: el test de etapa 3 intentaba cargar recursos de todos los capítulos; se añadió optimización **exclusiva si** `qaStage==3 && qaQuioscoPrototype != null` en `lib/main.dart`, commit `5dfb9fe70989d0bc993ce4d6b479babea43131e3`. El juego normal no usa ese parámetro y la carga habitual queda intacta.

Ejecución [42643160683](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/42643160683) **SUCCESS**: verificación SHA del ZIP, siete capturas Flutter del candidato, test `test/quiosco_candidate_stage_painter_test.dart` y publicación de seis fotogramas **reales de StagePainter** (1000×450), cámaras QA en posiciones de personaje 1200, 1850, 2450, 3250, 4250 y 5350. Artefacto GitHub `quiosco-candidate-ACTUAL-StagePainter-NOT-final`, ID `13685638339`. Descargado e inspeccionado en esta conversación; archivos: `quiosco_stagepainter_real_candidato.zip` y hoja de contacto `quiosco_stagepainter_seis_capturas_autenticas.png` (ambos locales del chat). **Son capturas reales con personaje, suelo, monedas, obstáculos y HUD del motor**, no imagen sintética ni montaje de gameplay.

Valoración visual observada: la arquitectura es más continua en varias zonas y el quiosco se distingue claramente al avanzar; hay **repeticiones de balcones/edificios** (algunos patrones persisten) y el mundo candidato sigue midiendo **5.782 px, no 37.440 px**. Los sprites y el suelo proceden del motor. Algunas zonas de la HUD de QA se ven como bloques claros; requiere revisión específica si también ocurre en una compilación normal y no presupone defecto del fondo. El arte todavía NO supera la puerta de aceptación artística y **no está activado en Android**. Las imágenes del artefacto no prueban el tramo completo ni la continuidad de sus 38 juntas.

Próxima acción: sustituir las fachadas repetidas con originales nuevos, completar 37.440 px de seis sectores distintos, usar conectores A/B/C realmente compatibles y repetir StagePainter (inicio, hito, finales, 38 uniones). No generar APK ni fusionar hasta verificar.

## 09/11/2026 — Reanudación de la ejecución, auditoría de cobertura

- Confirmada rama `work/revision-visual-20261028-continuidad` en `1ea751213f03e91616b4c9ac7b0981422a32dd42`, PR #5 abierta y sin fusionar.
- Recuperado y abierto el ZIP `qa/quiosco_inbox/quiosco_prototipo_seis_composiciones.zip`; el panorama verificable mide **5.782 × 390**, esto es el **15,443 %** del ancho requerido. **Quedan 31.658 píxeles horizontales de composición original**. No confundir los seis motivos visuales de este ZIP con seis sectores finales de 7.200/7.200/3.520/2.880/7.200/9.440 px.
- `tools/audit_quiosco_prototype_coverage.py` calcula esa brecha directamente desde los píxeles originales y detecta duplicados exactamente idénticos por ventanas de 256 px alineadas. En este prototipo no ha detectado ventanas idénticas en esa cuadrícula; **esto no descarta repetición artística** de fachadas, que sí se aprecia visualmente.
- Las seis capturas reales previas de StagePainter están documentadas en el artefacto `13685638339` de la ejecución `42643160683`; **no están guardadas como PNG en esta rama**. No afirmar nuevas capturas ni pruebas del arte final desde esta auditoría.
- Se mantiene el fondo de producción de 39 paneles y el quiosco único original, sin cambios en `lib/main.dart`, sprites, físicas, enemigos ni otros capítulos.

**Siguiente trabajo artístico imprescindible:** producir los seis núcleos panorámicos completos y distintos con las dimensiones indicadas en `qa/quiosco_rc7_art_rebuild_plan.json`, pintar tres conectores A/B/C compatibles, analizar las uniones internas y las 38 uniones de panel; solo entonces generar el ZIP de candidato, probarlo en StagePainter y considerar su activación. Los tests sintéticos de conectores no sustituyen esa intervención pictórica.

### Nueva aportación artística recuperable — fachadas de poniente

- Nuevo recurso original de edificios diferentes, generado tomando el prototipo como **referencia de estilo**, sin quiosco: `qa/quiosco_inbox/fachadas_poniente_original_candidato_1170x390.webp`.
- PNG matriz de 2172 × 724 completado sin márgenes blancos y convertido a WebP **1170 × 390** para prueba a escala de composición; SHA-256 del WebP: `2731eebdb99e39cddc57dd003d2028ca34166602c3152f986ac0a31ca135ac73`.
- Archivo binario guardado en commit `873f1be1e3dcf7109866ccef988a51306715b61b` y releído desde GitHub. Es **una fuente parcial nueva, no un sector final de 7200 px**. No hay duplicación del quiosco.
- Estado: **arte candidato, no aprobado, no incorporado a `assets/images/quiosco_rc7` ni probado en StagePainter**. Faltan los conectores A/B/C compatibles y la escala/composición con otros recursos, que debe revisarse visualmente antes de extenderlo.

### Segunda aportación — fachadas de oriente

- `qa/quiosco_inbox/fachadas_oriente_original_candidato_1170x390.webp`, SHA-256 `70a87a60523d8090284f0f0a518dee1256b015eac3924f36dc265f039c18acaf`, guardado en GitHub en `9c32799745bf84e3e042835843f61b8df9ca60d2`.
- Motivos de arquitectura diferentes respecto al prototipo y a la primera aportación; **no contiene quiosco**. La conversión de resolución fuente 2172 × 724 a 1170 × 390 utiliza calidad WebP 92 para transferencia, sin alterar recursos activos.
- **Revisión artística pendiente:** sus edificios aparecen a escala aparente mayor que en la primera aportación. Corregir esa discrepancia de altura de cornisa/arcada y diseñar una transición apropiada antes de componerla como núcleo del sector oriente. Ni dos imágenes de 1170 px ni un ensamblaje rápido constituyen un sector de 7200 px.

### Ajuste de escala y control visual real de ambas fachadas

- `qa/quiosco_inbox/fachadas_oriente_escala_v2_candidato_1170x390.webp` (commit `36e46394`): nueva versión que reduce los edificios e introduce cielo y explanada proporcionalmente similares a poniente. Conserva el anterior original.
- `qa/quiosco_inbox/fachadas_oriente_bordes_v3_candidato_1170x390.webp` (commit `daa5a37c`): edificios extendidos hasta los extremos, sin bandas laterales vacías, manteniendo un solo horizonte y sin quiosco. SHA-256 `c30011466a65ca1fd096e91a889a457050683a662fbbe49791406bc20a83fddc`.
- Se abrió una composición diagnóstica directa de los dos WebP **sin conectores**. Se comprueba visualmente un corte evidente entre fachadas, arcadas y pavimento: **NO APROBADO PARA INTEGRACIÓN**. No se confunde esta imagen comparativa con una captura de StagePainter.
- `tools/audit_quiosco_art_pair.py` mide los límites reales de dos recursos: diferencia RGB media **23,64**, desglosada en cielo **4,70**, tejados **19,19**, fachadas **47,97** y pavimento **36,68** (0 = idéntico). Los grandes saltos de fachada y pavimento exigen un conector arquitectónico y ajuste vertical, no mera concatenación. Esta herramienta es una alarma de QA, no una certificación artística.
- Siguiente microfase: diseñar un conector A que termine el edificio de poniente y abra el de oriente sin cortar pilares, tejados, arcadas ni pavimento; repetir la auditoría de su entrada/salida y solo entonces validar la unión en un candidato Flutter. El arte activo sigue intacto.

### Conector A — primer ensayo y descarte por pruebas (sin tocar producción)

- Se generó una panorámica nueva concebida como transición entre las fachadas reales de poniente y oriente. Se conserva la fuente en `qa/quiosco_inbox/conector_a_fuente_RECHAZADO_1170x390.webp` (commit `e134d285`), **expresamente rechazada como conector definitivo**.
- Se extrajo para la inspección un tramo de 256 × 390 px, conforme al ancho contractual A/B/C. El primer recorte x=510 puntuó **47,45** en la unión izquierda y **50,09** en la derecha, peor que la unión directa anterior de **23,64**. Los saltos principales fueron en fachadas y tejados; no se activó ni se incorporó al ensamblador.
- Se añadió `tools/search_quiosco_connector_crop.py`: recorre las 915 posiciones posibles de una fuente de 1170 px y compara ambas columnas exteriores con las imágenes vecinas originales. Mejor posición medida x=284: diferencias 37,47 y 34,58 (suma 72,05). **Sigue sin ser una unión satisfactoria**, porque la minimización cromática de dos columnas no garantiza continuidad de edificios.
- Diagnóstico: las fuentes visuales generadas independientemente no comparten exactamente los 256 px de solape previstos en `connector_system`. La solución correcta requiere pintar/editar el conector **sobre las columnas reales de los dos extremos**, preservar exactamente los bordes y después revisar la estructura del edificio y el suelo a ojo. No simular la continuidad con degradados o fundidos ni declarar la pieza terminada por tener baja diferencia numérica.
- Estado del capítulo: **candidato incompleto / nada cambiado en Flutter / sin capturas nuevas StagePainter**. Se conservan íntegramente los seis fotogramas reales anteriores y los originales del juego.

### Tercera panorámica original: teatro y espacio abierto

- Generado el recurso independiente `qa/quiosco_inbox/fachadas_teatro_espacio_abierto_candidato_1170x390.webp` (commit `fc9987f`), 1170 × 390 píxeles, SHA-256 `aafa884a621d0452a67c58d01952fc8228e88ae40a9f76fac2967990e9fddc22`. Tiene teatro de piedra, otra arquitectura de ladrillo y una abertura de plaza, sin repetir el quiosco.
- Comparación de las tres fuentes en el orden **poniente → teatro → oriente V3**, mediante columnas reales, sin fundido ni conectores: poniente→teatro **16,71 RGB** (cielo 6,58; tejados 7,96; fachadas 32,79; pavimento 26,65), teatro→oriente **21,50 RGB** (cielo 5,47; tejados 18,75; fachadas 40,75; pavimento 32,67).
- El nuevo orden mejora el salto numérico inicial entre las fachadas de poniente y oriente (23,64 RGB), pero **la inspección humana del montaje aún observa paredes, suelos y cubiertas cortados**. No supera la aceptación artística. No confundir la prueba de mosaico con imagen del juego ni incrementar ficticiamente la cobertura validada de 37.440 px.
- Los tres recursos originales quedan guardados para construir **núcleos distintos de futuros sectores**. Todavía deben retocarse las terminaciones y crear conectores A/B/C que conserven los píxeles de borde y sus estructuras, antes de activar tiles.

### Escala nativa y cuarta panorámica — avance de fuentes gráficas

- La comparación con el prototipo aprobado descubrió que las versiones de **1170 × 390** tenían edificios demasiado pequeños. Se corrigió el proceso: recorte vertical de las matrices **2172 × 724** a **2172 × 390**, sin cambiar la escala horizontal ni estirar texturas. Se ajustó para alinear aproximadamente el pavimento; permanecen diferencias de cubierta/arcada y siguen siendo candidatos.
- Fuentes nativas guardadas en commit `227142d81de45abd912a0d5df778648a28185e25`: `qa/quiosco_inbox/fachadas_poniente_nativas_2172x390_candidate.webp`, `fachadas_teatro_nativas_2172x390_candidate.webp` y `fachadas_oriente_nativas_2172x390_candidate.webp`. Total **6516 píxeles de nuevo arte de origen distinto**, no recorrido validado.
- Cuarta composición de galería con soportales y edificio palaciego de transición guardada en `qa/quiosco_inbox/fachadas_galeria_nativas_2172x390_candidate.webp`, commit `add0d5c2390b4d4eca64fbd80305175e4ec7e237`. Nuevo conjunto de cuatro fuentes = **8688 píxeles** originales distintos, aún **sin conectores aprobados** y sin sumar falsamente esa longitud al prototipo jugable.
- Control de bordes a escala nativa: poniente→teatro **12,74** RGB; teatro→oriente **28,46**; teatro→galería **18,11**; galería→oriente **34,64**. Es necesario revisar y pintar los empalmes arquitectónicos, no basta que cielo/colores coincidan.
- `tools/plan_quiosco_source_order.py` (commit `fba5831`) compara las 24 permutaciones de cuatro panoramas, sin repetir fuentes. Mejor suma de diferencias: **64,89** con galería→teatro→poniente→oriente (27,86 / 8,18 / 28,85). Pero los dos valores más altos aún representan cortes. Otro orden, teatro→poniente, tiene una unión muy baja de **8,18**, que fue inspeccionada visualmente; todavía no constituye aprobación.
- No se modifica `assets/images/quiosco_rc7`, ni `lib/main.dart`, ni jugadores, enemigos, mecánicas o otros capítulos. Las fuentes parciales siguen fuera del pipeline activo, y **no hay capturas StagePainter del nuevo conjunto**.

### Prueba StagePainter aislada para las cuatro fuentes nativas

- Se creó `test/quiosco_native_sources_stage_painter_test.dart` con cuatro WebP originales de 2172 × 390, ordenados **galería → teatro → poniente → oriente**, componiendo solo en memoria una banda QA de 8688 × 390. Comprueba explícitamente que el `CustomPaint` real del nivel 3 utiliza `StagePainter` y la instancia candidata; solicita ocho capturas a cámara x=700/2040/2390/4220/4700/6480/6800/8020. Nada de ello modifica el arte activo o el jugador.
- Workflow exclusivo `.github/workflows/quiosco-native-sources-qa.yml`, Flutter **3.47.8**, sin APK ni Actions de otros capítulos, artefacto previsto `quiosco-native-sources-REAL-StagePainter-NOT-final`.
- Se lanzó la ejecución [42656929927](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/42656929927) para el commit `6e186a7`. **Estado al documentar: en curso; no declarar superado ni reales las ocho capturas nuevas hasta recuperar y examinarlas.** La banda solo cubre 8688 de los 37440 px y contiene saltos artísticos conocidos, por lo que es una prueba del motor con candidatos, no una aceptación visual.

#### Resultado FINAL de esa ejecución, verificado posteriormente

- Run [42656929927](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/42656929927) **SUCCESS**. Artefacto `quiosco-native-sources-REAL-StagePainter-NOT-final` ID `13691574265`, ocho PNG de **1000 × 450**. Descargados, descomprimidos e inspeccionados realmente, no inferidos del nombre del pipeline.
- Capturas auténticas en x=700, 2040, 2390, 4220, 4700, 6480, 6800 y 8020. Son imágenes directas del `StagePainter` del juego con personaje, suelo, caja/obstáculos y controles; **no son ilustraciones generadas**. La hoja de contacto derivada, conservada en GitHub en `qa/quiosco_native_stagepainter/contacto_8_capturas_REALES_NO_FINAL.webp` (commit `8ba54a0`), es un mosaico de esas ocho capturas reales; SHA-256 `3036af450220888edfac47e73efe6ad2297acdd0eacdc8a57d42c6fc755e5bf1`.
- Inspección: mejora visible de detalle y escala de edificios respecto a los primeros paneles reducidos; plaza reconocible y más diversidad de tejados. **Defectos todavía visibles**: algunas uniones abruptas de edificios y suelo en la secuencia, HUD QA con barras/bloques claros que requieren comprobar si se reproducen en compilación normal, y el conjunto de 8688px no abarca el quiosco único en x=17920 ni los 37440px completos.
- Por ello el resultado es **VALIDADO SOLO COMO RENDER REAL DEL CANDIDATO PARCIAL**, no válido todavía como aprobación artística ni activación del fondo. Mantener `qaQuioscoPrototype` exclusivamente para pruebas; sin APK ni merge.

### Nuevas fuentes complementarias, seleccionadas con cautela

- Se produjeron otros dos diseños originales para el tramo posterior: una fila de edificios comerciales con soportales variados, y una plaza más abierta con árboles grandes y edificios de otro plano. Ambas fuentes están preservadas en GitHub en commit `f2f6ade40e25d9ba4d21a77a30cd8ec7275f7db9`.
- `qa/quiosco_inbox/fuente_comercios_2172x724_REESCALAR.webp`: **no incorporar aún**; el suelo y los edificios aparecen a cota/escala distinta respecto al conjunto de 390 px. Requiere preparación artística antes de añadirlo a las cuatro fuentes nativas ensayadas.
- `qa/quiosco_inbox/fuente_arboles_plaza_2172x724_CAPA_DISTANTE.webp`: **no incorporar como suelo cercano**; la plaza tiene escalones, bancos y profundidad visual ajenos a la geometría física del capítulo. Puede ser candidata para separar y revisar una capa de fondo lejano/intermedio a paralaje 0,30/0,56, nunca modificar plataformas/físicas.
- Conclusión: las fuentes complementarias amplían la biblioteca de motivos, pero **no aumentan aún los 8688 px renderizados/ensayados en StagePainter**. Las cuatro imágenes de 2172 × 390 siguen siendo el único candidato de esta tanda probado en el motor. No usar imágenes de arte generado como si fueran capturas auténticas.

### Quinta panorámica comercial y segundo StagePainter QA

- Se corrigió la escala y cota del pavimento en el diseño de comercios, y se preparó `qa/quiosco_inbox/fachadas_comercios_nativas_2172x390_candidate.webp` (commit `1caddab`), SHA-256 `e71550a96d1fd492de3afed77439f279acd14b5b1d485d405518af17a0817b3e`. Se preservó la anterior matriz 2172 × 724.
- `tools/plan_quiosco_source_order.py` ampliado (commit `d96ea0b`) para clasificar tanto la mínima suma como el menor salto máximo entre panoramas. Para cinco imágenes, 120 órdenes distintos: orden seleccionado para QA **teatro → poniente → comercios → galería → oriente**, diferencias medias RGB **8,18 / 11,76 / 16,54 / 34,64**. Las primeras tres uniones mejoran el candidato, pero la última sigue siendo un corte evidente y **NO ESTÁ APROBADA**.
- `test/quiosco_native_sources_stage_painter_test.dart` actualizado en `259411d` para componer cinco fuentes a escala nativa, **10.860 × 390**, y capturar 10 posiciones x=700/2040/2390/4220/4700/6480/6800/8900/9400/10200. Se reutiliza la misma inyección QA optativa sin editar `lib/main.dart` ni cambiar el fondo activo.
- Ejecución [42659332458](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/42659332458) lanzada. **En curso al escribir estas líneas**: esperar conclusión, descargar las imágenes y evaluar antes de declarar realmente probada la ampliación. Ni siquiera 10.860 px cubren los 37.440 px del capítulo.

#### Resultado de la ampliación a 10.860 píxeles

- La ejecución [42659332458](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/42659332458) terminó **SUCCESS** con Flutter 3.47.8; el test identificó el `StagePainter` real y produjo diez PNG de 1000 × 450. Artefacto de GitHub: `quiosco-native-sources-REAL-StagePainter-NOT-final`, ID `13691899237`. Fueron descargados y examinados, no son imágenes generadas de gameplay.
- Se archivó hoja de contacto auténtica en `qa/quiosco_native_stagepainter/contacto_10_capturas_REALES_NO_FINAL.webp` (commit `d9b4bf2`, SHA-256 `d7e6219fc51b3feda9acc71dc32c177f4bf1c17e79e89c52168e1c73a3335787`). Puntos de cámara: x=700, 2040, 2390, 4220, 4700, 6480, 6800, 8900, 9400, 10200.
- Inspección visual: la nueva zona de comercios es legible, el jugador/suelo/HUD se mantienen en las capturas y las fachadas muestran diversidad. Persisten bordes bruscos en algunas transiciones, especialmente galería→oriente, y bloques claros del HUD QA (sin atribuirlos al arte). El quiosco físico único queda fuera del alcance de estas capturas, porque se sitúa aproximadamente en x=17920.
- Estado autorizado: **probado en motor solo el prototipo parcial de 10.860 px**; los sectores faltantes, conectores A/B/C y barrido completo de los 37.440 px siguen pendientes. No se cambian sprites, físicas, `lib/main.dart`, 39 tiles productivos, ni otros capítulos; no APK ni merge.

### Prueba de una zona abierta como separación arquitectónica

- Se dibujó una nueva vista abierta con árboles, edificios de fondo, bancos y pavimento horizontal, preservada en `qa/quiosco_inbox/plaza_abierta_2172x390_CAPA_DISTANTE_NO_UNIR.webp` (commit `6106f6a`). No incluye quiosco.
- Prueba comparativa con las cinco fuentes de proximidad: la mejor de las 720 ordenaciones de seis vistas presenta un salto de **67,51 RGB** al conectar con la plaza abierta. Es peor que las transiciones vigentes: **descartada como panel cercano conectado**. Puede estudiarse como capa distante/intermedia separada a paralaje, sin modificar plataformas ni física.
- Los cinco panoramas próximos continúan siendo los únicos comprobados en StagePainter (10.860px), con el tramo oriente todavía pendiente de conectores compatibles. No incrementar cobertura ni marcar esta prueba como superada.
