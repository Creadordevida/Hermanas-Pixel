# Caso de aprendizaje: mejora 9 perros y mejora 11 palomas

**Fecha:** 26-10-2026. **Producto:** Las aventuras de Miren y Sara, RC7.
**Estado:** integrado en código y recursos, **NO aprobado visualmente**;
Flutter y APK Android pendientes. Guardar como material para el GPT futuro.

## Problema visible

1. Los perros cambiaban automáticamente entre caminar y correr según
   `foe.t%1>.5`, aunque estuvieran quietos, alertando o mordiendo. Existían
   ocho PNG por raza, pero el motor usaba casi siempre solo dos. Los dibujaba
   completos sobre una caja de 96×78 que incluía márgenes transparentes:
   su silueta medía apenas unos 38 px y terminaba lejos del suelo físico.
2. Las palomas aparecían suspendidas en el aire: los cuadros eran poses de
   caminar posadas sobre pavimento, pero la lógica sumaba siempre un
   desplazamiento vertical de -58 px. No había transición de despegue,
   batida de alas, planeo ni aterrizaje.

## Causas comprobadas

- **Incongruencia arte/motor:** tener fotogramas buenos no sirve si el motor
  no conecta cada pose con su verdadero estado jugable.
- **Pivote erróneo:** encajar el lienzo RGBA completo en una caja fija desplaza
  el suelo y empequeñece el perro. Distintas poses no deben autoajustarse a
  alturas distintas: se mantiene una única escala y se recorta solo alfa.
- **Falsa animación aérea:** cambiar fotogramas de un animal terrestre mientras
  la posición `y` está fijada arbitrariamente arriba no crea vuelo natural.
- **Fallo en primer atlas generado:** el primer intento de paloma tenía plumas
  que cruzaban divisores entre celdas. Fue **rechazado**; el atlas elegido
  tiene filas/columnas sin solapamiento alfa. Además, cada cuadro tenía patas
  en lugares distintos: por eso se midieron pivotes para compensar el salto.
- **Poses caninas duplicadas:** los PNG `hit` y `stunned` existentes son
  idénticos en píxeles. El motor ahora diferencia *impacto* mediante retroceso
  y *aturdimiento* mediante postura sentada/oscilación, sin modificar
  archivos originales. Queda pendiente validación visual real.

## Corrección en código y recursos

- `Enemy.advanceAnimal` introduce máquina de estados comprobable en pruebas
  sin depender del árbol de widgets. Avisa antes de la mordida (0,24 s),
  comprueba distancia/altura del personaje, golpea solo una vez y respeta
  enfriamiento. Incluye paradas naturales de patrulla.
- Los perros de tres razas se dibujan con los límites alfa reales medidos en
  `animal_sprite_bounds.dart`. Patas en `groundY`, altura de referencia fija,
  movimiento real enlazado a pose de zancada. Impacto y derrota son estados
  visuales expresos.
- La paloma comienza posada, despega al acercarse el jugador, vuela con altura
  progresiva, alterna batida/planeo, realiza un picado condicionado, puede
  aterrizar y cae por gravedad antes de desaparecer si es derrotada.
- Nueva hoja de ocho poses 4×2 con transparencia real. El cuerpo mantiene
  tamaño semejante al sprite posado usando 220 px de celda dibujada y pivotes
  por cuadro medidos en la región rosada de las patas. Es un **recurso del
  juego**, no una captura que acredite cómo se ve la pantalla.

## Puertas de calidad para próximos juegos SNES

1. Registrar todos los estados esperados de cada enemigo; comprobar que el
   motor use al menos una pose identificable para cada estado de combate.
2. Prohibir animaciones dependientes solo del reloj si el sprite no se mueve.
3. Exigir comprobación explícita de alfa, recorte y pivote de patas sobre suelo.
4. Un atlas debe superar test de ausencia de píxeles en divisores de celdas;
   ningún cuadro vacío ni duplicado. Rechazar y repetir si falla.
5. Los animales voladores deben cambiar **altitud con física propia** y usar
   fotogramas con alas; el estado posado solo puede usarse en el pavimento.
6. Los ataques de contacto necesitan preparación visual, momento de impacto,
   comprobación de alcance, recuperación y límite de daño por ataque.
7. Ejecutar capturas **del verdadero motor Flutter**, con las diferentes
   poses y en situación jugable; revisar proporciones frente a protagonistas,
   sombras, colisiones, solapes y fluidez. En móvil, revisar FPS y controles.
8. Una prueba Python verde no equivale a aprobación artística. No se etiqueta
   ilustración generada como captura del juego. Gate de entrega estricta sigue
   cerrado hasta capturas, inspección y prueba Android real.

## Evidencia real al 26-10-2026

- **87 pruebas Python correctas**; recursos esenciales, inventario y baseline
  0.8.0 íntegros. `qa/release_gate.py --strict` da **155 pendientes**.
- `test/wildlife_mechanics_test.dart`: escenarios de patrulla, alerta,
  mordisco único, altura del héroe, despegue, picado y aterrizaje.
- `test/qa_wildlife_render_test.dart`: 24 cuadros caninos + 9 palomas capturados
  por el propio `StagePainter` al ejecutarse en GitHub Actions.
- **No se han ejecutado** las pruebas Dart/Flutter ni las capturas aquí porque
  el SDK no está disponible. Ninguna captura Android ni visto bueno visual.

## Resultado exigido antes de cerrar

- Las 33 capturas Flutter deben existir, distinguir poses y mostrar pies al
  suelo, vuelo sin cortes/teletransporte y perro de tamaño coherente.
- Comprobar en un teléfono real persecución, daño diferido, ataque de paloma,
  colisiones y estabilidad del capítulo completo.
- Si alguna muestra defectos, volver a arte/código, guardar causa y repetir
  sin rebajar los tests. **No generar todavía ZIP final.**
