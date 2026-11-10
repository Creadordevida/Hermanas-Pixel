# Ayuntamiento RC7 — integración Flutter y QA (04-11-2026)

**Rama:** `work/revision-visual-20261028-continuidad` · **PR:** #5 · **sin APK, sin merge**

## Qué está incorporado

- 39 paneles de `960×390` en `assets/images/ayuntamiento_rc7/`; `manifest.json` con SHA-256 y geometría.
- `consistorial_unico.webp` de `1170×390`, insertado una sola vez, comenzando en la coordenada de mundo `x=17920`. No se replica la fachada principal.
- Pintura del Ayuntamiento en `lib/main.dart`, `stage=1`, a velocidad de mundo **1:1**, sin sustituir `ground_1` ni modificar colisiones o enemigos.
- La opción `TWC_AYUNTAMIENTO_RC7_ART` está **activa por defecto** en compilaciones normales. Pantalla de selección del capítulo apunta al maestro nuevo. El sistema de carga no decodifica el fondo panorámico ni la franja `mid_1` antiguos cuando el arte RC7 está activo.
- `pubspec.yaml` registra `assets/images/ayuntamiento_rc7/`.
- ZIP original de procedencia conservado en `qa/ayuntamiento_inbox/AYUNTAMIENTO_RC7_SUBIR_GITHUB_2.zip`; importación estricta `tools/import_ayuntamiento_rc7_zip.py`.

## Evidencia automática auténtica

- [Integración del ZIP y 56 capturas reales](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41849017174): **SUCCESS**. Verificó 39/39 paneles, SHA, escena única, Flutter analyze, 18 fotogramas `StagePainter` en 800×450 / 975×450 / 1000×450 y 38 uniones 20:9.
- [QA de compilación normal, sin dart-define (push)](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41850919218): **SUCCESS**. Confirma que los recursos se muestran por defecto; verifica 18 capturas, seis movimientos de cámara +60 px, 38 capturas de uniones, contrato de Estafeta y regresión de portada.
- [QA de compilación normal (PR)](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41850932087): **SUCCESS**.

Las capturas están persistidas en `qa/ayuntamiento_rc7_flutter/` y `qa/ayuntamiento_rc7_joins/`, no son montajes ni imágenes generadas. Inspección visual manual realizada sobre escenas de x=1200, 9200, 18200 y 35700 y juntas 01, 18, 19, 20 y 38. La prueba automatizada cubre las 38 uniones, pero **no equivale a una inspección humana exhaustiva de todas ellas**.

## Riesgos/limitaciones, sin exagerar el cierre

- **Preparado técnicamente para incorporarlo a una APK de pruebas RC7**, pero la APK aún **NO** se ha compilado ni probado en un móvil.
- Fachada principal representativa, no levantamiento arquitectónico exacto de edificios vecinos. Las fachadas de acompañamiento proceden de material artístico candidato adaptado; ciertos patrones se reutilizan. Falta certificar una correspondencia fotográfica exhaustiva con el trazado real.
- El HUD presenta bloques blancos en capturas del motor de test; esto no certifica ni descarta el comportamiento de texto en hardware Android.
- No ha habido corrección manual de todos los motivos repetidos ni revisión visual individual exhaustiva de las 38 juntas. Si se exige **aprobación artística definitiva estricta**, aún debe completarse esa revisión y retocarse cualquier defecto detectado.
- Otros capítulos y enemigos no modificados como parte de esta tarea; PR permanece abierto, sin publicar.

## Política de versiones

Las nuevas versiones de prueba deben hacer visibles por defecto todos los cambios artísticos verificados. Los nuevos fondos del Ayuntamiento y Estafeta están activados en la rama sin `--dart-define`. La siguiente compilación Android debe basarse en el HEAD actualizado de esta rama, no en un commit anterior.

## Cierre de preparación de RC7 de prueba — 05/11/2026

**Resultado: preparado para incluir en la siguiente RC7 de prueba.** No equivale a publicación, validación física Android ni recreación arquitectónica definitiva.

- Se han revisado las **38 uniones del arte fuente**, componiendo por parejas las columnas izquierda/derecha de los 39 WebP originales; no se han visto huecos transparentes ni desplazamientos de base del pavimento. Algunas medianeras y cubiertas presentan diferencias estéticas y motivos reutilizados, que quedan documentados como limitación de la versión de prueba.
- Se han inspeccionado **capturas verdaderas** del inicio, tramos intermedios, Ayuntamiento único y final, incluidos 16:9, 19,5:9 y 20:9. No se han usado simulaciones de interfaz como prueba del motor.
- Commit `8677e918`: `twcAyuntamientoRC7ArtworkEnabled = true`, sin depender de `--dart-define`. Garantiza que futuras compilaciones no oculten el capítulo.
- Commit `d3e36c12`: test adicional con `TWC_AYUNTAMIENTO_RC7_ART=false` para demostrar que el antiguo interruptor ya no desactiva recursos integrados.
- [QA RC7 de Ayuntamiento final, ejecución 41983414515](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41983414515): **SUCCESS**, con 39 hashes y recursos, `flutter analyze`, contrato normal y prueba de protección del flag, regresión de portada y Estafeta, 18 capturas reales, seis pruebas de movimiento y 38 capturas de uniones.
- [QA RC7 de Estafeta ejecución 41983414602](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41983414602): **SUCCESS** después de los últimos cambios compartidos.

**Criterio de despliegue:** se permite compilar una futura APK RC7 cuando el usuario lo autorice; deberá utilizar el HEAD de esta rama. **No se ha compilado APK ni fusionado PR.** Si en pruebas físicas aparecen defectos del HUD o repeticiones molestas, se tratarán como incidencias de pulido visual de RC7 antes de publicar una versión definitiva.
