# Danza 0.9.1 — verificación real y revisión artística (31-10-2026)

**Estado: arte binario integrado en PR #5; 11 capturas Flutter StagePainter generadas, QA técnico success; revisión artística NO CERRADA.**

## Ejecución reproducible
- GitHub Actions [41202827876](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41202827876): **SUCCESS**.
- Importación del ZIP aprobado con SHA256 `d3127c7fbf33ff57a629e9bc05dcec9f38bb2de4adb2b21a38c1b7209ec222a2`, 5/5 recursos intactos.
- `flutter pub get`, `flutter analyze --no-pub lib` (0 incidencias), `flutter test --no-pub --dart-define=TWC_DANCE_HIFI_ART=true test/dance_hifi_real_render_test.dart` (1/1 test, 11 capturas) y verificador de dimensiones 1000x450 exitosos.
- Las cinco ilustraciones originales están versionadas en `assets/images/interiors_parallax/dance/hifi/`; no modificadas ni sobrescritas.
- Capturas reales 20:9 en `qa/dance_hifi_flutter/`, versionadas en GitHub. No son montajes PIL, no hay Android/APK.
- La etapa 5 obliga a seleccionar a **Sara** en la prueba, coherente con `StageData.forcedSara`; no forzar a Miren como protagonista seleccionada. Personajes secundarios aparecen en el motor como corresponda.

## Evidencias StagePainter
| Nombre | Mundo x | Objeto |
|---|---:|---|
| 01_recepcion | 500 | Recepción aprobada y continuidad |
| 02_pasillo | 7500 | Pasillo aprobado y continuación |
| 03_vestuario | 14600 | Vestuario original con espejos |
| 04_estudio | 22100 | Sala de danza con ventanales |
| 05_escenario | 30000 | Teatro/bambalinas |
| 06_transicion_recepcion_pasillo | 7000 | Unión zona 0→1 |
| 07_transicion_estudio_escenario | 29000 | Unión zona 3→4 |
| 08_pasillo_camara_60 | 7560 | Cámara desplazada 60 |
| 09_estudio_camara_60 | 22160 | Cámara desplazada 60 |
| 10_sara_estudio | 22100 | Sara en estudio |
| 11_sara_vestuario | 14600 | Sara en vestuario |

## Inspección visual de capturas auténticas
- **Corregido:** las cinco fuentes se cargan; no quedan grandes huecos de cielo urbano/fondo provisional tras los murales. Se reutilizan provisionalmente los 9 paneles físicos ya presentes **solo para continuidad de tramos no cubiertos**; las cinco composiciones HIFI originales se muestran intactas, una vez cada una, sin reflejo ni repetición de los originales.
- **Pendiente de calidad arquitectónica:** existen juntas con diferencia estilística entre el nuevo mural y el panel antiguo (recepción/estudio/pasillo/vestuario), y columnas que no siempre casan exactamente. No afirmar que equivalen a 27 paneles HIFI únicos del colegio.
- **Pendiente de paralaje en cristales:** las cinco fuentes son PNG **RGB opacas**, y por tanto en sus ventanas no se ve la capa `.30/.56` aunque el motor dibuja esas capas debajo. El movimiento de cámara sí cambia la vista 1:1; esto NO certifica paralaje exterior dentro de esos vitrales. No modificar RGB original; crear derivados alpha solo al identificar cristales con máscara auditada contra fuente.
- **Pendiente de variedad:** áreas del mundo de 36.500 unidades usan paneles históricos de danza; hay repetición del banco y paneles existentes. Planificar extensiones físicas únicas de cada ambiente; no aceptar un simple bucle del mural aprobado ni recrear el colegio con decorado de danza.
- **Protagonistas:** Sara es la selección forzada en etapa 5; conservar el comportamiento sin alterar físicas/controles.
- **Pruebas visuales**: revisadas cinco salas, dos transiciones y dos desplazamientos de cámara con imágenes *reales* de la ejecución. Las capturas de Sara pueden consultarse en Git.

## Lección reutilizable para siguientes capítulos
1. Preservar lámina maestra y recortes originales, SHA256 por archivo.
2. Subir un ZIP único a carpeta inbox, importador SHA-estricto, generar/instalar paneles sin tocar másters.
3. Cargar assets Flutter mediante rutas registradas en pubspec, mantener coordenadas físicas 1.00; solo exterior de ventanas a .30/.56. Prohibido usar imágenes RGB opacas y proclamar paralaje visible.
4. Prueba widget real `StagePainter` 1000x450 + selección de protagonista conforme a las reglas de capítulo.
5. Ejecutar en Actions sin Android. **Persistir imágenes mediante git commit, no upload-artifact**: la cuota Actions se agotó en run [41202462704](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41202462704) aunque las 11 capturas sí se generaron.
6. Inspeccionar visualmente todas las capturas, transición y cámara; NO confundir test pass con arte aprobado.
7. Commit de activos/evidencias en la rama PR, nunca merge, APK o publicación sin orden expresa.

## Estado de cierre
**NO marcar finalizado artísticamente** hasta resolver juntas, repetición y cristales/paralaje y volver a ejecutar/inspeccionar QA. La integración binaria y capturas de `StagePainter` están ya demostradas. No tocar colegio, enemigos ni controles/físicas.
