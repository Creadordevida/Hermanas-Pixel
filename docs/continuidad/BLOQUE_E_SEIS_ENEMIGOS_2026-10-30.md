# BLOQUE E — Seis enemigos nuevos (auditoría 30/10/2026)

**Estado: PENDIENTE DE VALIDACIÓN.** Enemigos aceptados como concepto: no rechazar ninguno. Arte generado por scripts geométricos anterior: **RECHAZADO ARTÍSTICAMENTE**, no activarlo.

## Fuentes y resultados comprobados
- Se consultó HEAD y PR #5; los seis atlas `assets/images/enemies_new/{robot,supporter,tourist,navarre_king,estafeta_bull,sanfermin_runner}_atlas.png` aún NO existían en la rama al comenzar E. El workflow actual puede generar candidatos procedimentales pero no másters artísticos aprobados.
- Se recuperaron referencias visuales originales ya creadas anteriormente: los sprites aprobados del juego dentro del ZIP histórico, y `Sprites de San Fermín: Toro y Corredor.png` de la biblioteca (1536×1024). Con OpenCV/Pillow se extrajeron localmente siete poses de cada uno para revisión. Se ensamblaron atlas de referencia 4×6: toro 1080×1152 y corredor 624×1260, conservados en el paquete de la conversación `TWC_E_Estafeta_referencias_artistas_PENDIENTES.zip`. **RECHAZADOS PARA GAMEPLAY**: algunas siluetas se cortan, las perspectivas cambian y los cuatro fotogramas por estado NO son animaciones independientes. Nunca sobrescribir los atlas jugables por esos prototipos.
- Lámina conceptual conjunta generada en conversación: NO es un sprite atlas usable ni captura real. Exige diseñar seis másters y animar cada personaje coherentemente.
- Transferencia BINARIA GitHub: el canal `files__read` + `mcp__GitHub__create_blob` ha transferido **con éxito un PNG real** 377.797 bytes; Git blob SHA `16671f5d374652cbd48c18dd2b385b587bc1ee40`, exacto al original. Se creó el blob objeto de prueba SIN añadirlo al árbol de la rama. Esto prueba la vía técnica para trasladar próximos atlas corregidos, y resuelve la antigua suposición de que el conector sólo aceptaba texto.

## Código y comportamiento corregidos
- `lib/new_enemy_hitboxes.dart` introduce hitboxes distintas para los seis conceptos; el toro ahora tiene 75px de semiancho y deja de usar una de 37px impropia de su silueta. `lib/main.dart` utiliza dichos límites al evaluar impactos de balón/pirueta.
- Robot, aficionado y toro ahora requieren dos impactos para quedar derrotados; así se representa realmente la reacción de daño antes del final. Rey conserva sus tres impactos.
- Corredor San Fermín: advertencia de 0,34 segundos antes del contacto, golpe sólo si sigue en alcance y protagonista en el suelo; alerta cancelable si salta o se aleja; recuperación y estado visual de impacto independientes.
- `test/new_enemy_hitboxes_test.dart` crea regresión de las seis zonas; `test/new_enemy_behaviors_test.dart` preexistente cubre IA de los tres personajes urbanos.
- `test/qa_new_enemy_real_render_test.dart` ahora carga fondos de Estafeta/Plaza, las tres capas de fútbol y los 27 módulos de colegio, además de los enemigos. Antes dibujaba sobre cielo vacío, sin escenario. Sigue sin ejecutarse: no hay Flutter en este entorno.
- Workflow manual `.github/workflows/build.yml` ejecutará las nuevas pruebas de lógica antes de la APK cuando el usuario lo autorice. `qa/check_new_enemy_signoff.py` impide encender flags sin evidencia del atlas exacto y su captura Flutter auténtica. Preflight estricto continúa exigiendo los seis aprobados.

## Qué falta realmente para COMPLETAR E
1. **Másters visuales** de calidad SNES comparable a la versión 0.7.1 de robot, aficionado, turista, rey, toro y corredor, a escala con protagonistas. No reciclar figuras procedimentales antiguas.
2. Atlas reales de 4 columnas × 6 filas por personaje, con al menos 2 idle, 4 marcha, 2 alerta, 3 ataque, 2 hit, 3 derrota; mismo pivote de suelo y silueta uniforme. El arte de referencia de Estafeta todavía NO pasa esto.
3. Incorporar los seis PNG definitivos por el canal GitHub binario probado, con sus hashes; generar los propios manifiestos artísticos sin falsas aprobaciones.
4. Ejecutar `python3 qa/check_new_enemy_artifacts.py`, `python3 qa/check_new_enemy_signoff.py`, Flutter analyze y tests, y capturas auténticas de cada pose con fondo real. Abrir, revisar, iterar, comparar a Miren y Sara.
5. Sólo después de las aprobaciones explícitas habilitar flags en `lib/main.dart`. Antes, NO declarar el bloque acabado ni una versión con seis enemigos integrada.

**No se ha construido APK, ejecutado Actions ni fusionado PR.** El próximo bloque F no debe empezar hasta informar al usuario y recibir su indicación.
