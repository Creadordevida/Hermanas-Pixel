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
