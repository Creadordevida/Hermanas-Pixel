# Las aventuras de Miren y Sara — informe de preparación RC8

**Fecha:** 26 de octubre de 2026  
**Versión:** `0.9.0-rc.8+27`  
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

## Qué sigue pendiente

Este equipo no dispone de Flutter, Dart ni emulador Android; por tanto, **no
se ha compilado aquí un APK ni ejecutado el juego en un dispositivo**. GitHub
Actions deberá ejecutar el análisis, las pruebas Flutter y la compilación.

El control artístico estricto registra **155 verificaciones pendientes**.
Esas verificaciones no deben confundirse con las pruebas automáticas ya
superadas: la RC8 se entrega para inspección y pruebas manuales, no como
aprobación artística final ni como publicación en Google Play.

El flujo compila y sube el APK de prueba antes de la comprobación exhaustiva
de capturas; si posteriormente falla la revisión visual, la ejecución quedará
marcada como fallida, pero el APK estará disponible para investigar.

## Instalación y retroalimentación

Seguir `INSTRUCCIONES_RC8_PRUEBAS.md` para copiar el proyecto a GitHub,
descargar el APK y compartir capturas o vídeos del juego **real**.
