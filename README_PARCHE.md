# Parche RC6 — portada vacía y selección real de capítulos en QA

## Diagnóstico confirmado con el registro de GitHub #20

- Se guardó `titulo_090.png` de **4648 bytes**, pero el test exigía arbitrariamente `>5000` y falló por ello. El tamaño comprimido no certifica calidad, y la pantalla podría estar aún vacía porque `Image.asset` se carga de forma distinta de las `ui.Image` precargadas del motor.
- **Los cuatro PNG de vestuario se generaron y pasaron**. No se modifica esa prueba.
- El código de `HermanasGame` no tenía `didUpdateWidget`: la prueba de 30 capturas intentaba cambiar `qaStage` con un `GlobalKey` constante pero el estado seguía en la pantalla anterior. Esto invalidaba las supuestas capturas por capítulo.

## Solución

1. `lib/main.dart`: añade `didUpdateWidget` **solo para entradas QA**. Reutiliza los sprites ya decodificados y cambia de verdad mapa/capítulo/posición de cámara. No modifica gráficos ni mecánicas en Android (sin `qaStage` los parámetros siguen ausentes).
2. `test/qa_render_capture_test.dart`: espera a que portada y mapa realmente tengan cargados sus `RawImage`. Comprueba que el `StagePainter` corresponde al capítulo solicitado. Conserva la captura PNG exacta del renderizador Flutter.
3. En vez de exigir una cifra arbitraria de bytes, valida tamaño de imagen y riqueza mínima de colores muestreados en los píxeles RGBA; un fondo uniforme sigue suspendiendo.

**No se modifican** las imágenes, trajes, enemigos, colisiones, niveles ni el workflow `build.yml` que ya genera y publica el APK.

## Cómo instalar (GitHub Desktop)

Extrae este ZIP y copia `lib/` y `test/` en la RAÍZ del repositorio clonado, permitiendo reemplazar los **dos archivos**. Deberían aparecer **2 changed files**. Commit `Corregir render QA de portada y capitulos RC6` y **Push origin**. No subas una versión nueva del juego ni borres archivos.

## Verificación

Esta corrección se ha inspeccionado y comprobado por estructura. **No se ha ejecutado `flutter test` localmente** porque no está instalado Flutter en este entorno. La ejecución siguiente de GitHub debe producir las capturas del título, mapa y los siete capítulos. Si una escena resulta blanca/plana, seguirá fallando. La validación visual final sigue requiriendo revisar los PNG generados e instalar el APK en Android.
