# Lecciones tempranas procedentes de la evolución del juego

**Origen:** decisiones y auditorías descritas en conversaciones del proyecto de 24–27/10/2026, contrastadas cuando ha sido posible con el repositorio. Su contenido describe **problemas reportados o propuestas históricas**; NO convierte los antiguos informes en pruebas actuales.

## 24 de octubre: identidad artística y condiciones del proyecto

- Aprobada la estética 16 bits estilo **Super Nintendo**, con prioridad Android y controles móviles.
- Protagonistas diferenciadas: **Miren**, futbolista, y **Sara**, bailarina. La referencia estética es su arte propio aprobado, no personajes genéricos de stock.
- Identidad del juego consolidada como **Las aventuras de Miren y Sara**.
- Implicación reusable: cualquier nuevo personaje necesita una ficha visual coherente con la historia, más las poses de reposo/acción; los nombres/rasgos no se improvisan.
- La calidad para móvil se juzga **a la escala a la que se juega**, no viendo el PNG ampliado a pantalla completa.

## 26 de octubre: auditoría previa de capítulos y enemigos

En una revisión anterior se señalaron estos defectos:

| Defecto comunicado | Qué debe preservar/validar un motor futuro |
|---|---|
| Fondo casi fijo, repetido o sin profundidad | cámara real por capas, mundo físico 1:1, ciclos lejanos adecuados |
| Cambios entre panoramas mediante fundidos | transiciones espaciales de arquitectura, no imágenes fantasma |
| Objetos/árboles cortados por un atlas | siluetas y alpha bbox reales, inspección de teselas y uniones |
| Cajas y monedas con patrones muy uniformes | variación perceptible sin romper jugabilidad |
| Sombra ovalada separada del suelo | proyección sobre plataforma/suelo físico, sin seguir al personaje durante un salto |
| Perro y paloma con movimientos pobres | IA de animales + keyframes auténticos, no traslación rígida |
| Saltos visualmente poco diferenciados | despegue, subida, ápice, caída, aterrizaje y recuperación |
| Rata plana o desproporcionada | altura/caja canónica por especie, volumen y relación de escala |
| Interfaz móvil superpuesta a la acción | áreas táctiles y arte revisados en resolución real |
| Título con legibilidad insuficiente | validación de texto, contraste y resolución con captura real |

Son **incidencias históricas diagnosticadas**, no necesariamente fallos que persisten hoy. Su utilidad para el GPT está en convertirlas en pruebas de regresión específicas y no perder estos criterios.

## 27 de octubre: decisión de estudiar y sistematizar la técnica SNES

Antes de rehacer por completo el escenario del capítulo 1 se exigió una revisión de las técnicas de desplazamiento clásico: mundo continuo, cámara por sectores, elementos independientes, escalas comunes y capas a diferentes velocidades.

Se propuso probar primero un **segmento corto de 2.500–4.000 unidades** antes de producir las 36.500 del capítulo. Esto es una **metodología de reducción de riesgo**; no consta aquí que se aprobase o ejecutase literalmente esa prueba como entrega definitiva.

La aportación duradera:
1. Validar una zona pequeña de arte **con la cámara real**.
2. Probar los dos bordes de un módulo y las velocidades relativas.
3. Corregir perspectiva y escala **antes** de ampliar el escenario.
4. Extender a nivel completo únicamente cuando el prototipo cumpla las pruebas artísticas.
5. Conservar los prototipos antiguos etiquetados como **no aprobados**, en lugar de confundirlos con la versión final.

## Distinción esencial: aprendizajes de conversación frente a código comprobado

- **Confirmado en fuente actual:** mundo 36.500, teselas 512, 72 tiles, cámara x−327, velocidades .30/.56/1, protagonista escalada desde idle, `StagePainter` real.
- **Relatado en auditorías históricas:** algunos defectos visuales de perros, paloma, rata, sombras, moneda, interfaz y fondos. Reabrir capturas reales si se quiere certificar que están reparados.
- **Propuesto pero no certificado:** prototipado exacto de 2.500–4.000 unidades antes de cada nueva fase.
- **Sin inspeccionar completamente aún:** conversaciones iniciales de diseño, cada revisión intermedia de sprites y todas las capturas/pruebas antiguas.

No transformar este archivo en un «aprobado» automático del producto. Es una guía de **qué revisar y por qué**, que complementa la fuente de código y los tests del framework.

## Regla práctica para el futuro GPT

Cuando el usuario diga «nuevo juego», iniciar con el contrato artístico, un personaje aprobado en reposo y un segmento real con cámara/parallax. Mostrar evidencia auténtica de cada hito. Antes de recorrer miles de unidades o dibujar docenas de enemigos, demostrar **primero** anatomía, integración, profundidad y animación con el motor de destino.

La creación de este conocimiento no debe retrasar el cierre de los siete bloques pendientes de *Las aventuras de Miren y Sara*.
