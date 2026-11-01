# Actualización final — 2026-11-01

QA 41317694621 SUCCESS sobre ab5a640; veinte encuentros reales, 21 PNG protegidos y 240 capturas. Revisión de los diez enemigos completada, incluidos recorte corregido del robot y nuevas transiciones apoyadas del bailarín. La inspección de segunda tanda mencionada abajo ya está realizada. Falta la aprobación artística final del usuario, no otra ejecución técnica programada. Véase [galería](../enemy_verified_render/README.md). Ninguna prueba Android/APK realizada en esta orden.

# Revisión de enemigos — evidencia, no aprobación automática

La ejecución 41209274884 pasó análisis Flutter, pruebas de comportamiento/colisión/poses y capturas reales. Las capturas se inspeccionaron: robot, corredor, aficionado, turista, rey y toro tienen escala visible corregida y mantienen el suelo. Matón tiene cabeza y pies completos; árbitro uniforme completo y tarjeta; rival usa su PNG de derrota tumbado. No se cambia la aprobación artística del usuario.

Segunda tanda: sincronizar columnas de ataque con anticipación/impacto, locomoción real de los tres arquetipos, añadir reacción propia del matón (bully_5), comprobar lógica REAL del ticker con balón y peine para los diez enemigos, completar 24 muestras de cada clásico y cargar fondos de danza también cuando su opción HIFI está apagada. Se detectó un suplemento generado con anatomía incorrecta y dos zancadas redundantes: se descartó íntegramente, nunca se integró. El árbitro permanece quieto en su comportamiento real, por lo que no necesita nuevas zancadas artificiales. Se rehízo únicamente el impacto del matón.

## Referencias y derivados
- Robot: robot_master.png y robot_sheet_candidate.png, atlas assets/images/enemies_new/robot_atlas.png.
- Corredor: runner_sheet_candidate.png, atlas assets/images/enemies_new/sanfermin_runner_atlas.png.
- Otros cuatro: *_atlas_candidate.png, copiados byte a byte al directorio de recursos; no son conceptos usados en lugar de sprites.
- Matón: 0 reposo, 1/2 marcha, 3 empujón, 4 derrota, 5 impacto. Todos redibujados manteniendo la referencia; impacto procede de una edición separada. Árbitro: 0 reposo, 1 preparación, 2/3 tarjeta, 4 derrota, 5 impacto. Sin cambios a los originales archivados.
- locked_asset_hashes.json protege las seis hojas y los doce PNG clásicos contra sobrescritura. verify_enemy_art.py comprueba también transparencia, 24 celdas no vacías y ausencia de duplicados exactos; esto NO sustituye inspección artística.

## Cómo interpretar las pruebas
Los JPG son hojas de contacto de StagePainter real. Los GIF son secuencias de estados controlados renderizados por ese mismo motor, no vídeos de una partida ni capturas de Android. La prueba enemy_gameplay_integration_test.dart, por separado, ejecuta el ticker real: anticipación, ataque, proyectil, interrupción y derrota con ambas protagonistas. No se ha construido APK ni probado un dispositivo físico.

Los seis enemigos nuevos siguen protegidos por enemyArtValidated=false. TWC_GAMEPLAY_PLAYTEST permite probar su aparición sin confundir un ensayo con aprobación artística. No activar estas banderas como consecuencia automática de pruebas verdes.

## Aprendizaje reutilizable para GPT de juegos SNES
1. Separar referencia aprobada, recurso derivado, recurso integrado, prueba técnica y aprobación visual final.
2. Dimensionar por altura opaca canónica, no por lienzo transparente; misma escala en todas las poses, mantener relación de aspecto y apoyo.
3. Animar el ataque con su reloj de anticipación; una derrota se limita al último fotograma y no vuelve al primero.
4. No mover a un enemigo con una pose de reposo: la pose de marcha debe corresponder a desplazamiento real.
5. Rechazar anatomía incorrecta antes de integrar. Reutilizar lo válido y regenerar únicamente la pose defectuosa.
6. Verificar interacción con el bucle real además de pruebas puras y capturas del pintor.
7. Reutilizar cachés, agrupar verificaciones, guardar pruebas compactas en Git cuando la cuota de artefactos de Actions esté agotada.

Continúa pendiente la inspección del resultado de esta segunda tanda y la aprobación artística final del usuario; no declarar cerrado antes de comprobarla.
