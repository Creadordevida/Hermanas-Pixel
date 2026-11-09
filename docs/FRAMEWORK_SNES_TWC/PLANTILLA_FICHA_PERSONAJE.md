# Ficha reutilizable de personaje — The Wolf Company

> Duplicar por personaje y conservar las casillas sin marcar hasta disponer de evidencia. Nunca inventar capturas, prompts, semillas, commits ni pruebas.

## Identidad y contrato visual

- ID interno / nombre / clase (protagonista, enemigo, NPC, animal, jefe):
- Juego / capítulo / posición de spawn:
- Referencia aprobada: ruta, fecha, persona que aprobó, SHA-256:
- Original intacto: ruta y SHA-256:
- Rasgos obligatorios (cara, pelo, ojos, silueta, ropa, paleta, herramienta, sombras):
- Escala respecto a protagonistas, orientación, ancla de pies/cuerpo, luz:
- Observaciones del usuario y límites de rediseño:

## Contrato de animación (extender, no limitar a seis estados)

| Estado y subestado | Frames | Duración/FPS | Pivote | Ataque/evento | QA visual | QA runtime |
| --- | ---: | --- | --- | --- | --- | --- |
| Reposo | | | | | ☐ | ☐ |
| Movimiento | | | | | ☐ | ☐ |
| Alerta/anticipación | | | | | ☐ | ☐ |
| Ataque activo | | | | | ☐ | ☐ |
| Recuperación | | | | | ☐ | ☐ |
| Impacto/interrupción | | | | | ☐ | ☐ |
| Derrota/caída | | | | | ☐ | ☐ |
| Otros (saltar, girar, lanzar...) | | | | | ☐ | ☐ |

- Atlas: ruta / ancho×alto / columnas×filas / RGBA / SHA-256:
- Proyectiles/efectos: ruta / SHA-256:
- Fases realmente accesibles en el código:
- Orígenes y derechos de uso; herramientas/modelos/prompts/semillas **solo si constan**:

## Integración y pruebas

- Rama y commit exacto:
- Rutas asset, loader, painter, máquina de estados, tests:
- Colisión y daño a Miren: resultado y evidencia:
- Colisión y daño a Sara: resultado y evidencia:
- Ataque, anticipación, recuperación, proyectil, impacto, derrota verdadera:
- `flutter analyze`: fecha / commit / resultado (o NO EJECUTADO):
- `flutter test`: tests concretos / fecha / resultado (o NO EJECUTADO):
- GitHub Actions: workflow y run URL/ID / resultado (o NO EJECUTADO):
- Captura **REAL**: archivo, test/comando, commit, viewport 20:9, fecha, estados fotografiados:
- Inspección humana de capturas A(referencia)/B(atlas)/C(runtime): resultado, problemas y correcciones:
- Android: versión/APK, dispositivo, fecha, resultado (o PENDIENTE):
- Aprobación visual final del usuario: fecha y evidencia (o PENDIENTE):

## Incidencias y cierre

| Fecha | Problema | Causa comprobada o hipótesis | Solución | Test que evita regresión | Commit |
| --- | --- | --- | --- | --- | --- |
| | | | | | |

- [ ] Original y referencias preservados
- [ ] Atlas RGBA completo, sin clipping/duplicados y todos los frames legibles
- [ ] Estados y ataques reales comprobados en motor con ambas protagonistas
- [ ] Captura verdadera generada **y vista**, no simulación
- [ ] Validación Android o limitación explícita
- [ ] Commit y rama remotos confirmados
- [ ] Documentación/backup actualizado

**Estado exacto:** CONCEPTO / ATLAS / INTEGRADO / QA FLUTTER / QA VISUAL / QA ANDROID / APROBADO / PENDIENTE.

**Siguiente microfase ejecutable:**
