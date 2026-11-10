# Estafeta — reconstrucción RC7 (plan técnico auditado)

Estado: EN DESARROLLO; no validado visualmente, sin APK ni fusión.

## Hallazgo verificado en lib/main.dart

La rama actual dibuja Estafeta (stage 2) por la rama genérica de _background(): _backLayer(scene_2,1,0.014) y _midLayer(mid_2,1). El fondo principal no se mueve a velocidad de arquitectura y el plano intermedio se repite por módulos. El recurso antiguo se descarta como base artística, pero no se elimina hasta contar con reemplazo integrado y comprobado.

## Referencias técnicas

- Colegio stage 6: _interiorBackgroundTWC; planos lejanos 0.30/0.56; arquitectura fija a velocidad 1:1; recortes por zonas; paneles originales y sin superposiciones duplicadas.
- Capítulo exterior stage 0: _neighborhoodBackground; distinguir vistas lejanas y geometría del mundo; evitar repetir puntos singulares.
- QA: test/school_hifi_real_render_test.dart, test/qa_render_capture_test.dart; capturas StagePainter auténticas.

## Arquitectura objetivo

1. Dividir Estafeta en sectores de fachadas documentados mediante referencias reales; el diseño conceptual generado NO constituye una reproducción verificada de edificios concretos.
2. Crear paneles originales con baseline común, sin espejos, sin repetir fachadas ni alterar la física.
3. Dibujar fachadas y comercios con x_mundo - cameraX (factor 1.0). Reservar paralaje para tejados/cielo distantes, sin desplazar edificios anclados al pavimento.
4. Mantener ground_2 y las colisiones hasta validar visualmente el nuevo arte. No insertar suelo pintado adicional encima del suelo físico.
5. Cargar paneles originales desde assets declarados en pubspec y evitar duplicaciones de scene_2/mid_2. Proteger los PNG aprobados frente a generadores.
6. Añadir test dedicado con capturas de inicio, sectores, uniones, final y desplazamiento +60 en 16:9, 19.5:9 y 20:9; comprobar protagonistas y coincidencia suelo/pies.

## Criterios de aceptación

No cerrar hasta inspeccionar los PNG originales y las capturas reales del motor, comprobar continuidad en movimiento y confirmar que las fachadas corresponden a referencias reales de Estafeta. Sin modificaciones a otros capítulos, enemigos o física. Sin APK y sin merge.
