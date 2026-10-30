# Estado operativo (corte auditado 2026-10-30)
Repositorio: Creadordevida/Hermanas-Pixel (privado).
Rama: work/revision-visual-20261028-continuidad.
HEAD de auditoría: cb8f93a582a3795ae8351c3075f600b6a5b313a0 (el commit documental posterior cambia HEAD).
PR #5: borrador, abierta, no fusionada.
main en la revisión: 8f08f39d4ad11ba2de0885816ac6793830d838d0.
pubspec.yaml: 0.9.1-rc.3+34 (versión declarada, NO APK aprobado).

| Bloque | Estado comprobado | Pendiente |
|---|---|---|
| Portada | Código adaptativo y tests escritos | Panorama title_wide_20x9.png AUSENTE; logo twc_title_mark_clean.png PRESENTE (SHA Git 5f7f4aa54e3a6212da65f7a024df4036bb69ee20, idéntico a twc_mark_from_tiku.png). Render Flutter real y aceptación artística PENDIENTES |
| Colegio | 27 paneles presentes. En 7c4e6dc se corrigen mesas en pasillos y PCs fuera de aula TIC, además del test con recortes desfasados. Fuentes originales verificadas por SHA; reproducción PIL local de 27 módulos, 27/27 únicos y verificación de píxeles 27/27 (NO son los PNG actuales recuperados de GitHub) | Calidad artística insuficientemente verificada: biblioteca/pizarras se repiten mucho; inspección de PNG actuales y 13 capturas auténticas Flutter pendiente. No aprobar todavía. |
| Danza | Paneles y generadores presentes | Variedad, uniones y movimiento reales |
| Fútbol | Capas y teselas presentes | Junta horizontal, continuidad, capturas reales |
| Seis enemigos nuevos | Lógica, generadores y tests en Git | Atlases finales ausentes en enemies_new; flags artísticos sin aprobar |
| Cuatro clásicos | Fuentes y herramientas de retoque presentes | Retoque generado, inspección y capturas reales |
| Integración | Flutter/Dart y QA existentes | Regresión, Android y aceptación; sin compilar por esta orden |

El informe docs/CIERRE_INTEGRAL_PR5_2026-10-29.md es histórico: sus 27 paneles escolares pendientes de subir SÍ están presentes el 30/10. Presencia no equivale a aprobación.
No se ejecutaron Python, Flutter, Actions ni Android en esta auditoría.
Actualización 30/10 — bloque A en curso: auditados lib/adaptive_title_screen.dart, qa/verify_adaptive_title_art.py, tools/extract_twc_title_logo.py, tests de geometría y pubspec.yaml. La imagen original title_cars_fixed_091.png existe (1.242.063 bytes, SHA Git 8246b4f06bc35bb4845de547e2091659ae93a61d), pero la conexión GitHub no entrega sus píxeles binarios a este entorno; por ello NO se han generado laterales nuevos ni se ha simulado una captura Flutter. En asset panorámico falta arte real. Los cuatro workflows revisados declaran solamente workflow_dispatch; no se han ejecutado. Pendiente acceder a los bytes del original y generar a escala nativa lateral original sin alterar el centro, inspeccionar y validar. Evitar repetir trabajos del logo ya existente.
Siguiente: terminar bloque A con una copia de los PNG reales accesible a herramientas de imagen y Flutter; después presentar evidencias al usuario y solicitar permiso para pasar al bloque B. No generar APK/Actions/merge.
## Bloque A: fuente original recuperada (30/10/2026)
ACTUALIZACION DE RECUPERACIÓN (30/10/2026, posterior al primer diagnóstico): se localizaron en la biblioteca de archivos los 159.496.519 bytes del ZIP `MIREN_Y_SARA_RC3_FIX2_PARALLAX_GITHUB_COMPLETO.zip`. Se extrajo `assets/images/title_cars_fixed_091.png` (1098×617, 1.242.063 bytes) y se verificó que su Git blob SHA1 es exactamente `8246b4f06bc35bb4845de547e2091659ae93a61d`, idéntico al asset de GitHub. También se recuperó `title_approved.png` y su SHA coincidió con GitHub. **Por tanto NO hace falta pedir al usuario que suba la portada**. Es posible trabajar localmente sobre los píxeles de origen; sigue faltando un panorama artístico aceptable y su integración. Un primer mosaico experimental de expansión 20:9 (1371×617) preservó el centro original píxel a píxel, pero se RECHAZÓ por duplicar fragmentos de letras y personajes en los laterales. NO se guardó en GitHub ni se marcó como válido. No se han ejecutado Flutter, Actions ni compilación APK. Si en otro chat el ZIP no está montado, localizarlo en la biblioteca de archivos y materializarlo. La limitación de acceso a blobs binarios grandes del conector GitHub continúa, pero NO impide recuperar este original desde el archivo histórico.

Bloque A: EN CURSO; ninguna aprobación definitiva de panorama ni render Flutter. Evitar falsos positivos basados en dimensiones de PNG.

### Auditoría y corrección del bloque B, 30/10/2026
- 3 originales exactos obtenidos de ZIP anterior; sus Git SHA coinciden con los objetos actuales de GitHub: `school.png` 2e3e9467, `school_classroom.png` 9c4bd502, `school_computers.png` c5c6ed16.
- Se reconstruyeron localmente 27 paneles con Pillow a partir de las fuentes legítimas siguiendo las fórmulas visibles del generador: 27/27 distintos, tamaños 880×278, posiciones de píxeles contrastadas y ventanas alfa; auditoría 0 fallos. **No son una descarga de los PNG de la rama, ni capturas Flutter, ni una aprobación artística.** Los PNG locales están en artefacto de conversación, no en GitHub.
- Corregido el BUG REAL en `lib/main.dart`: antes se dibujaban mesas y monitores por zona general y no por estancia real elegida por `interiorSchoolRoomTypeTWC`. Para los 31 módulos de aula inspeccionados, el modelo predice 7 pasillos que ya no reciben muebles, y 5 monitores menos fuera de aula TIC. Son cálculos locales del modelo, no test Flutter.
- Corregida `qa/test_interiors_twc.py`: esperaba offsets 125..330/0..440 de una versión antigua; el generador actual usa 145..325/65..440. La comprobación obsoleta discrepaba en 26/27 módulos. Se incorporó `test/school_furniture_source_test.dart`, preparado pero no ejecutado (Flutter/Dart no disponible en esta sesión).
- **BLOQUE B AÚN PENDIENTE DE VALIDACIÓN.** Al revisar las previsualizaciones locales se observa repetición artística de BIBLIOTECA y pizarras: 27 nombres distintos no demuestran 27 escenarios visualmente ricos. No sustituirlos por parches geométricos improvisados. Hace falta trabajar el arte final y luego capturar el StagePainter real. Se mantienen los originales, las 27 imágenes actuales y el pipeline sin reemplazar bytes no verificados.
- No se ha generado APK, lanzado GitHub Actions ni realizado merge. No pasar a C hasta oportunidad de revisión del usuario.


### Bloque C — Danza, 30/10/2026 (sin compilar)
- Autorizado explícitamente por usuario tras el bloque B; NO hay autorización para el bloque D ni para APK, Actions o merge.
- Orígenes legítimos exactos recuperados del archivo histórico y contrastados con GitHub actual por Git blob SHA: `dance_foyer.png` a0e98f69, `dance_studio.png` be8e3378, `dance_stage.png` f48659a6.
- DEFECTO VERIFICADO: el generador de danza comprimía un recorte 1672×545 a 1650×286 (escala X 0,9868 frente a escala Y 0,5248; anomalía 1,88×). Arcos y mobiliario se aplastaban verticalmente.
- CAMBIO DE CÓDIGO: `tools/build_interiors_parallax_twc.py` conserva relación de aspecto usando recortes auténticos 1200×390 → 880×286 (factor idéntico 0,7333), con tres encuadres por sala, sin espejos ni reemplazo del arte aprobado. `tools/build_dance_panels_twc.py` regenera SOLAMENTE los nueve PNG de danza, sin tocar los 27 paneles del colegio. `qa/test_dance_proportions.py` comprueba las 3 fuentes originales, nueve PNG, transparencia, proporciones y procedencia de píxeles. `tools/preview_interiors_twc.py` corrige un error real de indentación que impedía importar el visor.
- Evidencia LOCAL con originales recuperados: 9 PNG RGBA de 880×286 creados e inspeccionados, 9 hashes distintos, escala isotrópica exacta, alfa de zócalos opaca, 4 pruebas locales independientes satisfactorias. Contactos antes/después y archivo ZIP ofrecidos en conversación como ejemplos REALES de recursos PIL, NO capturas StagePainter.
- **NO afirmar integración de PNG en GitHub**: por límites del conector binario no se han subido los nueve PNG (aprox. 3,2 MiB en conjunto). Los nueve PNG activos de la rama aún son anteriores al parche; el juego seguirá mostrándolos hasta sustituirlos y confirmar hash. La nueva prueba de regresión del repositorio se ha escrito, pero NO ejecutado contra un checkout completo. NO Flutter ni Android; revisión artística final NO aprobada.
- **Estado C: PENDIENTE DE VALIDACIÓN / INTEGRACIÓN BINARIA.** Paso siguiente: subir 9 PNG exactos al mismo commit/rama mediante canal binario Git autenticado cuando esté disponible, ejecutar `python3 -m unittest qa/test_dance_proportions.py`, `flutter analyze`, `flutter test` y capturas auténticas StagePainter del capítulo 6. No bloquear el motor ni degradar arte previo para forzar cierre.
