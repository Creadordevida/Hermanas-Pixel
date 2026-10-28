# LAS AVENTURAS DE MIREN Y SARA — CAPÍTULO 1 RC3 V5

Fecha: 28 de octubre de 2026. Estado final de esta intervención: **NO APROBADO / NO TERMINADO**. No generar ZIP ni APK, no activar en producción.

## Qué se ha hecho de verdad

1. Se conserva una copia íntegra del proyecto que contiene la lógica del videojuego, sin modificar la RC2 original. Los cuatro PNG originales de los lugares emblemáticos mantienen su SHA256.
2. `lib/chapter_one_world_v4.dart`: se corrigen las ventanas verticales que truncaban parte de los parques y las vallas; las cuatro ilustraciones de 1672x941 ahora se muestran hasta y=790 en el laboratorio (antes y=690), sin reescribir los PNG. **Este recorte es experimental y no está aprobado visualmente como definitivo.**
3. Se pasa de nueve esquemas de mobiliario a nueve variantes por sectores en el recorrido y se protege el **ancho completo** del objeto, no únicamente la posición de su origen. El dibujo y el modelo Python aplican la misma regla.
4. `qa/ch1_world_v4_reference.py`: se sincroniza el simulador Python con estos cambios. Se ha producido una simulación de 61 fotogramas para la primera unión.
5. `qa/visual_audit_v5.py`: auditoría nueva de **111 posiciones de cámara** distribuidas por las 36.500 unidades. Se produce un contacto del mundo y un contacto de los siete finales de ilustraciones.
6. `qa/test_ch1_world_v5.py`: 12 comprobaciones nuevas. Se ejecutan **158 pruebas Python** y pasan. No equivalen a pruebas de Flutter.
7. `qa/acceptance_ch1_v4.py`: la puerta artística ahora mide **siete** bordes, protege los cuatro originales y exige además auditoría visual y ejecución Flutter/Android reales. Devuelve código **2 / BLOCKED** mientras no se cumplan todas las condiciones.
8. `.github/workflows/ch1-v5-sin-apk.yml`: preparado un flujo de auditoría **manual** sin APK, con pruebas Python y Flutter. No está subido al repositorio remoto ni se ha ejecutado; no se afirma ningún resultado en Flutter.

## Pruebas y resultado reproducible

- Python: `python -m unittest discover -s qa -p 'test_*.py' -q` => **158 tests OK**.
- Auditoría: `python qa/visual_audit_v5.py` => **111 cámaras**, más las siete costuras revisadas.
- Puerta: `python qa/acceptance_ch1_v4.py` => **código de salida 2**, `BLOCKED`.
- Las siete medidas RGB (heurística, no juicio artístico): edificio curvo **101,26**; primer conector **137,00**; paseo verde **96,65**; segundo conector **109,23**; cubierta blanca **89,80**; pérgola **120,69**; cohete **118,54**; umbral experimental **35**.
- En imágenes y vídeo se observa claramente el edificio y otras panorámicas acabando en bordes rectangulares, con salto de cielo detallado a cielo plano. Los tramos modulares siguen siendo demasiado genéricos.
- `flutter`/`dart` no están instalados en este entorno y no se dispone de dispositivo Android ejecutando esta copia: no se puede declarar compilación ni jugabilidad verificadas.

## Cinco trabajos originales: evaluación honesta

1. **Edificio curvo y conexión**: NO RESUELTO. Se ha mejorado el diagnóstico y el recorte, pero falta una terminación arquitectónica de calidad artística. Las propuestas generadas no han sido integradas ni aceptadas.
2. **Escenario completo de 36.500 unidades**: PARCIAL. Cámara y suelo físico están simulados; faltan módulos arquitectónicos completos y diversidad de paisaje para los tramos que antes eran fotos estiradas.
3. **Integración Flutter**: NO VERIFICADA. El renderizador nuevo permanece como laboratorio por `--dart-define=CHAPTER_ONE_WORLD_V4_LAB=true` y no sustituye por defecto al del proyecto.
4. **Personajes, saltos, enemigos, colisiones**: EXISTE LÓGICA CONSERVADA, PERO NO SE HA CERTIFICADO V5 EN EL MOTOR REAL. No modificar gameplay sin pasar las regresiones Flutter y Android.
5. **Auditoría artística/Android**: AUDITORÍA LOCAL EFECTUADA, **RECHAZADA**; Flutter/Android pendientes.

## Decisión de entrega

No activar experimental V4, no modificar la versión instalada ni afirmar que el capítulo 1 está terminado. Una arquitectura correcta de piezas y cámara no reconstruye por sí sola fachadas o árboles incompletos; se necesitan recursos de salida arquitectónica y paisajes modulares propios, revisados en vídeos genuinos. La prueba debe mantener sus bloqueos hasta esa reparación.

## Evidencias

- `qa/ch1_v5_audit/AUDITORIA_SIETE_BORDES.png`
- `qa/ch1_v5_audit/SECUENCIA_REAL_V5_SEIS_FRAMES.png`
- `qa/ch1_v5_audit/RECORRIDO_COMPLETO_MUESTREO.png`
- `qa/ch1_v5_audit/AUDITORIA_V5.json`
- `qa/ch1_world_v4_previews/PRIMERA_UNION_V4_DIAGNOSTICA_NO_APROBADA.mp4`
- `qa/ch1_world_v4_previews/PUERTA_ENTREGA.json`
- `qa/REGRESION_V5_158.txt`

Archivo de referencia maestro: `lib/neighborhood_scene_engine.dart`. Ninguna de las ilustraciones originales está reemplazada.
