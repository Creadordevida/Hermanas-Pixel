# TWC SNES Game Creator — metodología en construcción

**Propósito:** extraer herramientas y decisiones técnicas **comprobadas** de *Las aventuras de Miren y Sara* para ayudar a crear en el futuro otros juegos originales de estética Super Nintendo. Esto NO es todavía un GPT listo para publicar.

## Biblioteca prioritaria recuperada del código auténtico

1. **[01 — Escenarios, cámara y parallax](01_MOTOR_ESCENARIOS_PARALLAX.md):** 36500 unidades, 72 teselas físicas 512px (última 148), seguimiento a 327px, velocidades .30/.56/1, fórmulas de recorte, exteriores por ventanas, suelos y controles de calidad. **NO** simplificar o sustituir por un fondo estático.
2. **[02 — Personajes: estándar Miren y Sara](02_PERSONAJES_ESTANDAR_MIREN_SARA.md):** tamaños exactos de PNG originales y frames, SHAs, método de escala del motor, anclaje de pies, selección de poses y por qué los enemigos geométricos fracasaron. **NO** asumir que los PNG `run_0` están activos porque existen.
3. **[03 — Historial de aprendizajes](03_HISTORIAL_DE_APRENDIZAJES.md):** cronología contrastada con commits históricos, decisiones fallidas, pruebas y huecos de evidencia por recuperar.
   - **[04 — Lecciones tempranas](04_LECCIONES_TEMPRANAS.md):** auditorías de octubre anteriores a los cambios más recientes (animales, saltos, sombras, objetos, móvil) y el método de prototipo de escenario corto, con evidencias históricas diferenciadas de pruebas actuales.
4. **[Protocolo de aceptación visual](PROTOCOLO_ACEPTACION_VISUAL.md):** niveles de evidencia distintos: archivo real, render del motor, dispositivo y aprobación humana.
5. **[Errores y soluciones](ERRORES_Y_SOLUCIONES.md):** antipatrones concretos encontrados durante el desarrollo.
6. **[Regresión de referencia](../../qa/test_snes_framework_contract.py):** prueba de sólo stdlib para vigilar que el capítulo 1 y los PNG originales no cambien sin revisar.
7. **[Exportador de procedencia](../../tools/export_twc_snes_knowledge.py):** crea/compara un inventario SHA256 de los archivos fuente reales y dimensiones de PNG con `--write` y `--check`. Requiere un checkout completo; **aún no se ha ejecutado ni se ha generado su manifiesto**.

**Invariante estratégica:** el conocimiento validado es un activo versionado. No basta con añadir un resumen en una conversación; cada solución crítica debe tener código fuente, parámetros, evidencia, commit, ejemplo y prueba recuperables desde GitHub.

**Límite de lo recuperado:** hemos consultado el historial visible de GitHub y los recursos clave, pero no auditado todas las iteraciones antiguas ni todos los fotogramas; **ningún documento afirma lo contrario**. La siguiente ronda histórica debe ampliar commits antiguos y materiales de prueba, sin distraerse del cierre de la versión.

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
- [Transferencia binaria GitHub](TRANSFERENCIA_BINARIA_GITHUB.md): subida exacta de PNG grandes a la rama con SHA verificado, independiente de Actions.
