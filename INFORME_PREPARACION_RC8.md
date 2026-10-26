# Las aventuras de Miren y Sara — informe de preparación RC8

**Fecha:** 26 de octubre de 2026  
**Versión corregida:** `0.9.0-rc.8+28`  
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
| 96 tests Python de QA | **96/96 correctos** |
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

En la versión corregida el APK se construye **después de analizar `lib` y antes
de analizar los tests**. Si una prueba falla, GitHub seguirá mostrando el error
pero conservará el APK, siempre que la compilación del juego haya funcionado.

## Qué sigue pendiente

Este equipo no dispone de Flutter, Dart ni emulador Android; por tanto, **no
se ha compilado aquí un APK ni ejecutado el juego en un dispositivo**. GitHub
Actions deberá ejecutar el análisis, las pruebas Flutter y la compilación.

El control artístico estricto registra **155 verificaciones pendientes**.
Esas verificaciones no deben confundirse con las pruebas automáticas ya
superadas: la RC8 se entrega para inspección y pruebas manuales, no como
aprobación artística final ni como publicación en Google Play.

El flujo compila y sube el APK de prueba antes del análisis de tests y de las
capturas; si posteriormente falla cualquiera de ellos, la ejecución quedará
marcada como fallida, pero el APK estará disponible para investigar.

## Instalación y retroalimentación

Seguir `INSTRUCCIONES_RC8_PRUEBAS.md` para copiar el proyecto a GitHub,
descargar el APK y compartir capturas o vídeos del juego **real**.
