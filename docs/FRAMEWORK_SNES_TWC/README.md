# TWC SNES Game Creator — metodología en construcción

**Propósito:** extraer herramientas y decisiones técnicas **comprobadas** de *Las aventuras de Miren y Sara* para ayudar a crear en el futuro otros juegos originales de estética Super Nintendo. Esto NO es todavía un GPT listo para publicar.

## Reglas no negociables

1. Una imagen conceptual, un sprite de origen, un atlas generado, una captura de Flutter y un fotograma de Android son pruebas distintas; no etiquetarlos como equivalentes.
2. **Arte real:** no declarar sprites o escenarios aprobados a partir de sus generadores, hashes o tests de dimensiones. Revisar a escala de juego y junto a los héroes.
3. **Composiciones a escala:** conservar relación de aspecto y puntos de contacto; evitar `BoxFit.fill` en ilustraciones.
4. **Profundidad:** fondo distante, vegetación media y escenario físico con velocidades diferentes. Ventanas sólo deben dejar ver los planos exteriores mediante alpha.
5. **Diversidad:** módulos diferentes deben serlo por composición y contenido, no únicamente por diferentes nombres de archivo o hashes.
6. **Pivotes:** pies, suelos y colisiones no deben variar de posición sin motivo al cambiar de pose.
7. **Versionado:** guardar todo en una rama; compilar sólo al autorizarlo, no en cada commit.
8. **Aprobación:** el mismo PNG revisado debe ser el que se carga en el juego; registrar su hash y observaciones.
9. **Separar evidencias:** `implementado`, `generado`, `capturado`, `inspeccionado`, `aprobado`, `verificado Android`.
10. **Prioridad:** terminar el juego actual antes de añadir funciones futuras al framework.

## Ciclo reutilizable

`inspect -> spec -> implement -> generate -> inspect pixels -> render in engine -> review at game scale -> amend -> sign off -> release`

En cada fase el proceso debe fallar cerrado: si no hay evidencia, el estado es **pendiente**, no aprobado.

## Componentes reutilizables existentes

| Elemento en Miren y Sara | Se puede generalizar | Pendiente |
|---|---|---|
| `tools/export_sprite_bounds.py` | Detección exacta de recortes y pivotes de PNG | Validar todos los fotogramas |
| `qa/check_new_enemy_artifacts.py` | Integridad técnica de atlases | Añadir evaluación visual humana |
| `lib/classic_enemy_pose.dart` | Máquina de estados visual/combate | Migrar a módulo independiente del juego |
| `tools/build_interiors_parallax_twc.py` | Capas de mundos y ventanas con máscara alfa | Verificar en capturas auténticas |
| `lib/adaptive_title_screen.dart` | Transformaciones comunes de fondos y hitboxes | Requiere panorama genuino |
| `qa/next_version_preflight.py` | Inventario objetivo antes de compilación | No sustituye la aprobación de arte |

## Estructura futura del GPT

- Instrucciones generales: criterios de arte, código, pruebas y honestidad de resultados.
- Conocimiento: contratos de sprites, físicas, niveles, interfaz y publicación.
- Herramientas: acceso autorizado a GitHub, generadores de recursos, renderizado real y comprobaciones.
- Plantillas: generador de personaje, enemigo, nivel, hoja de sprites, controles, pruebas y release.
- Ejemplos validados: arte original propio, capturas de motor y tests vinculados a commits.

**No convertir documentación específica de este videojuego en una garantía genérica de calidad.**