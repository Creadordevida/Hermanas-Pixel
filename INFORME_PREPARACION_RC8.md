# Las aventuras de Miren y Sara — informe de preparación RC8 REV3

**Fecha:** 26 de octubre de 2026  
**Versión corregida:** `0.9.0-rc.8+30`  
**Destino:** proyecto Flutter completo para GitHub y compilación de APK Android de **pruebas**.

## Mejoras incluidas para comprobar

- Capítulo 1: cuatro zonas ilustradas con decorados y uniones revisadas.
- Rata y gato: sprites de mayor detalle y animaciones mejoradas.
- Perros: variantes visuales, comportamiento y animaciones propias.
- Palomas: nuevas poses, despegue, vuelo, picado y aterrizaje.
- Miren y Sara: salto, caída, recepción y sombra anclada al suelo.
- Campo de entrenamiento: tres ambientes, capas y detalles propios.
- Escuela de danza: tres salas, elementos decorativos y ambientación propia.

## Comprobaciones realizadas en el entorno de preparación

| Control | Resultado |
| --- | --- |
| 102 tests Python de QA | **102/102 correctos** |
| Conservación de base 0.8.0 | **Correcto** |
| Integridad de gráficos originales | **30 elementos y 5 iconos Android correctos** |
| Escenas por capas | **Comprobación mecánica correcta** |
| Inventario de recursos candidatos | **137/137 referencias válidas** |
| Métricas técnicas de decorados | **Correctas**, no equivalen a aprobación artística |
| Sintaxis YAML del flujo GitHub Actions | **Válida** |

## Corrección de la primera compilación de GitHub

La primera ejecución de la RC8 superó el análisis del código de `lib`,
pero falló al analizar dos archivos de capturas de prueba:

- `test/qa_creature_render_test.dart`: el objeto devuelto por
  `findRenderObject()` no tenía el tipo estático adecuado para usar `toImage`.
  Se convierte expresamente a `RenderRepaintBoundary` antes de capturar.
- `test/qa_wildlife_render_test.dart`: se eliminó la segunda aserción `!`
  redundante, señalada por el analizador.

La siguiente ejecución, RC8 corregida (+28), **sí compiló el APK** y superó
`flutter analyze` y las pruebas de mecánicas, pero tardó 30 minutos y terminó
con cuatro pruebas visuales fallidas (dos uniformes, fauna y saltos):

- Los dos tests de uniformes daban una ventana de carga de sprites de solo
  20 segundos, frente a los 90 segundos que necesitaba la prueba general.
  Ahora cargan el conjunto de imágenes una sola vez, comparten la instancia
  de `HermanasGame` entre los dos escenarios y esperan hasta 90 segundos.
- La prueba de fauna agotó el timeout predeterminado de diez minutos; la de
  saltos tenía la misma operación de escritura de PNG fuera de
  `tester.runAsync`. Ahora **todo el render, la conversión y la escritura** se
  ejecuta dentro de `runAsync`, con tiempos límite individuales.
- Rata y gato recibieron también límites explícitos de operaciones asíncronas.
- Las cinco pruebas gráficas pesadas se ejecutan con concurrencia 1 para evitar
  competencia por memoria y CPU de decodificación.

**El flujo REV2 separa dos trabajos:** `android-apk-candidato` para construir y
probar lo instalable, y `qa-graficos-flutter` para las capturas. Cada trabajo
tiene su estado propio y el segundo tiene un plazo máximo explícito. Si el
trabajo visual falla, el APK sigue disponible y la ejecución global no recibe
una aprobación engañosa.

### Error adicional detectado en RC8 REV2 (+29)

La compilación del APK terminó bien y su archivo se publicó. Sin embargo,
`flutter analyze --no-pub test` detectó tres avisos
`unawaited_return_in_try_block` en las pruebas de saltos, uniformes y fauna.
Los tres procedían de `return file.length().timeout(...)` dentro de un
`try/finally`. Se corrigieron añadiendo `await` a esas devoluciones y se añadió
una prueba de regresión específica para los tres ficheros.

En **REV3**, tanto el análisis de `lib` como el de `test` y las pruebas de
mecánicas se ejecutan **antes** de iniciar `flutter build apk --release`.
Así una advertencia de nueve segundos no vuelve a desperdiciar seis minutos de
compilación. La QA gráfica sigue en su trabajo independiente.

## Qué sigue pendiente

Este equipo no dispone de Flutter, Dart ni emulador Android; por tanto, **no
se ha compilado aquí un APK ni ejecutado el juego en un dispositivo**. GitHub
Actions deberá ejecutar el análisis, las pruebas Flutter y la compilación.

El control artístico estricto registra **155 verificaciones pendientes**.
Esas verificaciones no deben confundirse con las pruebas automáticas ya
superadas: la RC8 se entrega para inspección y pruebas manuales, no como
aprobación artística final ni como publicación en Google Play.

El flujo analiza primero todo Dart, prueba las mecánicas y, solo después,
compila y sube el APK. Las capturas se realizan en un trabajo independiente
que depende de la compilación. Si este segundo trabajo falla, quedará visible
y el APK seguirá disponible para investigar.

## Instalación y retroalimentación

Seguir `INSTRUCCIONES_RC8_PRUEBAS.md` para copiar el proyecto a GitHub,
descargar el APK y compartir capturas o vídeos del juego **real**.
