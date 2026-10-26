# Caso de aprendizaje: mejora 8, saltos y sombras

**Proyecto:** Las aventuras de Miren y Sara (RC7). **Fecha:** 26-10-2026.
**Estado:** código implementado y 91 tests Python correctos;
**pendiente de ejecutar Flutter y Android**, sin visto bueno artístico.

## Síntoma original

Miren y Sara usaban el mismo fotograma `jump_0` tanto al despegar como al caer.
No había preparación visual, gesto de contacto, amortiguación o recuperación.
La función `_actor` dibujaba un óvalo oscuro **en `c.y+3`** y otro aro curvo
amarillo **en `c.y+4`**. Como `c.y` subía con la física, ambos elementos
subían con el personaje: podían parecer una sombra flotante.

## Corrección aplicada

1. `Character` registra momento de salto, momento de aterrizaje y energía
   normalizada del impacto; `_tick` detecta aterrizaje solo al pasar realmente
   de estado aéreo a estado apoyado con velocidad descendente suficiente.
2. `jump_visuals.dart` determina **siete fases** mediante física y tiempos
   acotados: grounded, takeoff, rising, apex, falling, impact y recovery.
3. Se conservan **sin editar los 18 sprites aprobados** de Miren y Sara,
   incluidos trajes temáticos. Se usa salto real al subir, posición con botas
   hacia abajo al caer, inclinación sutil, compresión al tocar y rebote corto.
   Se añaden cuatro minipartículas discretas junto al pavimento.
4. La proyección de sombra se calcula por X de mundo y por la superficie
   horizontal **inferior a los pies**: pavimento o plataforma/obstáculo válido.
   El Y del óvalo y del aro amarillo sigue esa superficie, nunca el Y aéreo.
   Con la altura disminuyen opacidad y tamaño; nunca se desplazan hacia arriba
   juntos con la niña.
5. El parpadeo durante daño no borra la sombra: esta se dibuja antes del
   retorno anticipado de `_actor`, porque el contacto proyectado sigue
   existiendo aunque el sprite no sea visible temporalmente.

## QA preventiva obligatoria para el futuro GPT de juegos SNES

- Cualquier sombra de salto necesita dos coordenadas distintas: **X del
  personaje**, **Y del suelo de contacto**. Si ambas salen de posición aérea,
  el render falla aunque compile.
- El selector, halo, aura o segundo óvalo deben compartir proyección con la
  sombra, o estar expresamente identificados como efecto aéreo. Revisar
  TODOS los óvalos/arcos, no únicamente el primer `drawOval` encontrado.
- Registrar despegue y aterrizaje a partir de eventos físicos, no `time%...`.
- Aterrizar en plataforma requiere usar la superficie de la plataforma,
  no siempre `groundY`.
- Verificar fotos/render del **motor Flutter verdadero** en tierra, primer
  impulso, subida, ápice, caída, primer contacto y recuperación, para Miren y
  Sara con vestuario normal y temático.
- El efecto de compresión debe durar menos de 250ms y mantener los pies
  anclados; si la silueta se degrada, producir nuevos fotogramas coherentes
  con el personaje **antes de aprobar**.
- Proteger los PNG previamente aprobados con manifiesto SHA-256; una edición
  accidental en cabello, expresión, uniforme o silueta invalida la mejora.
- Distinguir siempre **prueba estática Python** de **prueba de render Flutter**,
  y esta a su vez de **prueba física en teléfono**. No falsificar capturas con
  ilustraciones generadas ni usar un verde de CI como aprobación artística.

## Evidencias / límites

- `qa/test_jump_visuals_quality.py` valida los 18 hashes protegidos, ausencia
  del antiguo óvalo desplazado, anclaje de sombra y obligatoriedad de CI.
- `test/jump_visuals_test.dart`: fases, duración, independencia de altura,
  sombras sobre plataformas y regresión de movimiento normal.
- `test/qa_jump_render_test.dart`: cuando Flutter corra, genera 30 PNG de
  verdad usando StagePainter: 28 fases y dos escenas con plataforma.
- **No hay SDK Flutter disponible en el entorno de esta sesión**, por tanto
  esas pruebas Dart y capturas aún no se han ejecutado.
- Tras inspeccionar visualmente los PNG reales puede requerirse añadir poses
  específicas de caída/aterrizaje. **No generar ZIP final antes del cierre de
  lista y QA visual/móvil.**
