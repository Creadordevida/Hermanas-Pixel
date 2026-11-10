# TWC — Pipeline obligatorio para crear personajes de calidad SNES

## Principio
**Arte de calidad desde el primer entregable.** El generador geométrico rápido es sólo un *placeholder* de programación: queda prohibido usarlo como sprite candidato de entrega. No confundir «PNG válido» con «personaje visualmente válido».

## Entrada obligatoria (contrato de arte)
Cada personaje nuevo tendrá una ficha con: identidad y capítulo, silueta inequívoca, referencias de personajes **ya aprobados del mismo juego**, dimensiones a escala frente a Miren/Sara, paleta limitada con volumen de luz/sombra, material (piel, ropa, piedra o metal), vista lateral coherente y animaciones requeridas con número de fotogramas y suelo/pivote constante. Una simple lista de rectángulos sin anatomía, texturas ni transiciones no puede considerarse diseño final.

## Flujo reproducible
1. **Diseño maestro de alta fidelidad:** dibujar/obtener las posturas clave al nivel de los sprites aprobados. Inspeccionar el PNG fuente real en resolución nativa, con fondo transparente. No reutilizar retratos ajenos ni inventar capturas. El generador de formas geométricas sólo es apto para pruebas técnicas.
2. **Atlas de animación:** poses idle/caminar/alerta/ataque/impacto/derrota (adaptar por especie); desplazamiento y anticipación reales; pivote común en el suelo, sin estiramientos, giros involuntarios ni fotogramas idénticos donde debería haber movimiento. Mantener trazabilidad del maestro gráfico.
3. **Validación automatizada:** celdas correctas, alfa, opacidad y contornos, celdas no vacías, variaciones reales entre poses, escala, referencia de suelo; pruebas de lógica de colisiones, daños, estados y apariciones en capítulo. Un test automático nunca «aprueba» por sí solo la belleza.
4. **Validación real en motor:** cargar el recurso en `StagePainter` o juego Flutter real, capturar en su capítulo real, proporción real junto a Miren/Sara; obtener secuencias de distintos fotogramas. La captura debe proceder del **render Flutter**, no de un montaje de Pillow ni de una imagen generada para aparentar un pantallazo.
5. **Inspección humana de todas las capturas:** abrir efectivamente los PNG resultantes, buscar anatomía y geometría rudimentaria, proporción, legibilidad, paleta, sombra, alineación y expresividad. Comparar contra la referencia aprobada. Documentar defectos concretos.
6. **Iteración correctiva:** ante cualquier fallo, **mejorar y repetir** (no descartar el personaje), desde el maestro hasta la captura real. No marcar aprobado, ni activar su aparición, ni incluirlo como terminado hasta que cumpla.

## Control de publicación por personaje
Registrar `source_verified`, `technical_pass`, `flutter_capture_exists`, `capture_inspected`, `art_approved`, `animation_approved`, `gameplay_pass`. Los siete valores deben estar respaldados por archivos/logs concretos. Un flag de calidad sólo se habilita después de esta evidencia; no introducir un `true` para forzar una build verde.

## Advertencias técnicas actuales
- `tools/generate_new_enemy_sprites.py` y `tools/generate_navarre_king.py` todavía usan dibujo procedimental; son material experimental, no origen artístico aprobado.
- `qa/check_new_enemy_artifacts.py` comprueba geometría, **no calidad artística**.
- `test/qa_new_enemy_real_render_test.dart` está destinado a producir capturas reales; su éxito y revisión de imágenes son condición independiente. No basta con que GitHub Actions marque `success`.
- El control afecta a **todos** los personajes del juego, no sólo a los cuatro nuevos enemigos: NPC, protagonistas alternativos, animales, jefes y personajes de fondo.
