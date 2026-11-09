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
