# Enemigos ilustrados y combate: método reutilizable

Aplicable a juegos de fantasía, ciencia ficción u otra temática con estética SNES. Los personajes y las medidas concretas de Miren y Sara son ejemplos, no requisitos universales.

## Contrato de arte
Guardar por separado la referencia aprobada, la hoja fuente, los PNG de producción, sus hashes, el mapa de estados y la aprobación del resultado. No sustituir una referencia por dibujos procedimentales. Las ediciones que creen nuevas poses deben identificarse; una aprobación de identidad no aprueba automáticamente su animación.

## Escala y apoyo
Medir la altura opaca del reposo canónico. Escala = altura visible deseada / altura opaca original. Aplicar esa misma escala isotrópica a todas las poses, aunque una postura agachada ocupe menos altura. Anclar los apoyos al suelo. No usar la altura del lienzo transparente como altura corporal, ni estirar cada pose hasta llenar una celda.

## Animación vinculada al comportamiento
El movimiento debe activar marcha solo mientras la lógica realmente desplaza al personaje. Anticipación e impacto usan su propio reloj, no el tiempo de existencia del enemigo. Distribuir todos los fotogramas dentro de su ventana real. La derrota avanza y se limita al último fotograma: no vuelve a empezar. Un fotograma girado no equivale a una nueva pose anatómica de baile o caída.

## Pruebas por capas
1. Integridad: fuentes exactas, alfa, celdas completas, hashes protegidos, sin duplicados exactos.
2. Lógica aislada: ventanas de ataque, recuperación, límites y distribución.
3. Partida real: ejecutar ticker, daño y colisiones; probar protagonistas/proyectiles, interrupción, evasión y derrota.
4. Render real: cargar exactamente los fondos y sprites activos; capturar motor y revisar a tamaño de juego.
5. Aprobación humana: comparar referencia, recurso integrado y resultado. No convertir tests verdes en aprobación estética.
6. Dispositivo: una captura Flutter de escritorio no verifica rendimiento o GPU Android.

## Errores confirmados en este caso
- Transparencia de atlas contada como altura corporal: enemigos demasiado pequeños. Corregido con altura opaca canónica.
- Temporizador general en ataques: omitía fotogramas y desordenaba anticipación. Corregido con reloj de fase.
- Rey mostraba marcha fuera del rango de movimiento: igualar condición visual y física.
- Poses del bailarín eran rotaciones del reposo: necesitan apoyos dibujados, no trucos de giro.
- Generación suplementaria con miembros adicionales: descartada, nunca integrada.
- Pruebas visuales sin fondos completos: cargar los recursos de la configuración real, incluidas alternativas de opciones gráficas.
- Cuota de artefactos Actions agotada: guardar pruebas compactas en Git; mantener una paleta GIF común evita repetir el fondo completo en cada fotograma.
- I/O de capturas en reloj simulado: rasterización y escritura deben ejecutarse dentro de tester.runAsync.

## Referencias ejecutables
- tools/build_approved_enemy_art.py y tools/install_illustrated_enemy_candidates.py
- tools/verify_enemy_art.py y qa/enemy_art_20261031/locked_asset_hashes.json
- test/enemy_gameplay_integration_test.dart
- test/qa_new_enemy_real_render_test.dart y test/qa_four_classic_enemy_render_test.dart
- .github/workflows/enemy-qa-only.yml
- qa/enemy_verified_render/

Los GIF de este expediente son secuencias de estados controlados renderizados por StagePainter; no son grabaciones de una partida ni imágenes conceptuales.
