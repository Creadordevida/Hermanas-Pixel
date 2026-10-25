# Informe de construcción — 0.9.0 candidata Android

## Alcance
- Base: 0.8.0 protegida por firmas SHA-256 (fuentes originales congeladas y recursos aprobados).
- Se conservan los 4 capítulos urbanos, personaje, controles e icono, con siete capítulos seleccionables ahora.
- Se han integrado 13 variantes de enemigos y sus recursos, 7 familias de obstáculos y ataques temáticos.
- Motor Flutter: escenas, colisiones, dos corazones, monedas, guardado, trampas y puntos de control.
- El mapa permite acceder a todos los capítulos, sin desbloqueo progresivo, para pruebas.

## Evidencia de calidad local
- `qa/verify_resources.py`: protección de recursos originales.
- `qa/verify_candidate_assets.py`: inventario y presencia de 117 recursos.
- `qa/release_gate.py`: base 0.8.0 intacta.
- `unittest`: 31 pruebas, incluidas configuración, resistencia, física, máscaras caninas, caras y siluetas de protagonistas, vestuario y tres ambientes escolares.
- NO se ha validado la jugabilidad ni se han capturado pantallas de un APK Android real aquí.

## Riesgos reconocidos antes de la prueba
1. Vestuario actualizado en ocho PNG reales con rostro/contorno originales protegidos, pero aún pendiente aprobación visual en el APK.
2. Colegio actualizado: pasillo, aula convencional y sala de informática ahora tienen fondos diferenciados y suelo compartido; todavía pendiente revisión visual in-game.
3. La duración de los capítulos se infiere de geometría y velocidad, pero no está medida jugando.
4. Los ciclos humanos se basan en cinco poses con variaciones; aún no son hojas de animación complejas verificadas al nivel SNES aprobado.
5. La salida y derrota de algunos enemigos usa desvanecimiento además de su pose final, cuya naturalidad debe probarse en Android.
6. La alternancia de fondos en un recorrido largo puede mostrar repetición visual; se deberá revisar con capturas del render real.
7. Un resultado verde en GitHub Actions confirma compilación y tests ejecutados, NO que la calidad gráfica o la jugabilidad estén aprobadas.

## Instrucciones de la puerta final
- Descargar del workflow el APK candidato y el artifact de capturas generadas por Flutter.
- Verificar en móvil: pantalla inicial/TWC, mapa, suelo inicial, 7 capítulos, todos los enemigos, proyectiles, vida, daño, muerte y escala de personajes, accesibilidad de plataformas, guardar/reanudar.
- No presentar como 0.9.0 definitiva hasta que esos aspectos y los gráficos estén aprobados.
