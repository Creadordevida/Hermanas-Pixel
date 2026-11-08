# Río Arga — desarrollo del capítulo de plataformas

**Fecha de inicio:** 2026-11-08. **Rama:** `work/revision-visual-20261028-continuidad`. **PR:** #5.  
**Estado inicial:** referencia artística aprobada; nuevo capítulo aún no implementado ni jugable.  
**Capítulos 1–7:** deben permanecer intactos. **APK:** no generar sin autorización.

## Dirección artística vinculante
Imagen de concepto generada y aprobada por el usuario el 08-11-2026: paisaje ribereño de Pamplona, puente de piedra, abundante vegetación, corriente azul verdosa, espuma, roca y madera, Miren y Sara a escala jugable. La imagen es **referencia artística**, no una captura de Flutter ni un fondo único que pueda sustituir a las capas. Guardar original de la propuesta en `docs/continuidad/referencias/rio_arga_concepto_aprobado_20261108.png`.

## Arquitectura requerida
- Reutilizar `GameViewportTWC` y principios de cámara del capítulo 1: mundo horizontal sin estirar sprites, parallax lejano / vegetación media / primer plano físico.
- Diseño modular: río animado y tres planos visuales independientes; colisiones exclusivas para rocas, troncos y madera. Evitar un suelo invisible continuo.
- Agua peligrosa: caída por debajo de plataforma -> estado de muerte, pérdida de corazón/vida y respawn en checkpoint; sistema de guardado coherente.
- Tramos con progresión: fijos, móviles, hundibles y puntos seguros. Distancias de salto verificadas con física REAL de las dos protagonistas.
- No crear enemigos hasta recibir sus diseños; los actuales quedan protegidos.

## Procedimiento obligatorio
Inspeccionar → detectar → corregir → generar → ver resultado → probar → volver a corregir → validar. Trabajar en microtareas, cada una con commit y verificación GitHub. No confundir una imagen conceptual con una captura del motor. Proteger recursos aprobados y guardar SHA de originales.

## Fases y puertas de calidad
1. [ ] Inventariar código mínimo necesario, conservar referencia artística y baseline.
2. [ ] Modelo puro y tests de plataformas / huecos / caída / checkpoints.
3. [ ] Primer tramo funcional integrado sin alterar otros capítulos.
4. [ ] Capas visuales reales con parallax y río animado, no panorama monolítico.
5. [ ] Capturas reales Flutter 20:9: comparar a escala de juego con concepto aprobado.
6. [ ] Ampliar longitud y variedad; comprobar colisiones para Miren y Sara.
7. [ ] QA/CI, revisión visual y prueba en teléfono antes de versión.

## Estado verificable
Pendiente integrar código; no hay pruebas de gameplay Arga todavía. Documentar aquí después de cada fase el commit, los recursos, el resultado de QA y el siguiente paso.
