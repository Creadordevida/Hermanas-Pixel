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
| Colegio | 27 paneles z0..z2_panel_0..8 presentes; último commit cb8f93a | Revisión de PNG y capturas Flutter actuales; aprobación artística |
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
