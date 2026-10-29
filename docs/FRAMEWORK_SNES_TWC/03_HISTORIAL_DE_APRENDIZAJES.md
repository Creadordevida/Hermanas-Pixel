# Cronología contrastada de aprendizajes y decisiones — TWC SNES

**Alcance:** `git log` de los archivos y `docs/HISTORIAL_DE_TRABAJO.md` inspeccionados el 29/10/2026. No equivale a auditar **todos** los archivos de **todas** las conversaciones. Los commits con títulos genéricos como «version x» sólo prueban que cambiaron archivos, **no** un hito artístico aprobado.

## Fases históricas recuperadas

| Fecha | Evidencia verificable | Qué se aprendió | Estado |
|---|---|---|---|
| 24 oct 2026 | `924176839b`: alta del material original; `ced6820e65`: nuevas hojas de personajes | Los sprites de Miren/Sara se convierten en referencia real, no en una descripción de estilo | PNG originales **recuperados** y visualizados; historia artística previa incompleta |
| 25 oct 2026 | `50d9867998` «0.9.0 RC2 pruebas Android»; `526b7fa4f0` «RC6 portada y capítulos QA» | La integración Android y las capturas requieren su propia prueba; los parches de portada no garantizan la adaptación | Commits **localizados**; verificar detalles antiguos antes de atribuirles soluciones |
| 26 oct 2026 | `ee07763914` «0.9.0 RC8» | Hubo múltiples iteraciones: no equiparar número de versión con calidad artística | Hito de historial, no aprobación automática |
| 27 oct 2026 | `4fac3095a1`, `329c3882b9` | Evolución del capítulo 1, experiencias V3/V4 y del entorno visual | Archivos experimentales conservados para estudiar decisiones; no ruta de producción |
| 28 oct 2026 | `e5cdc8a74b`: capítulo 1 `build_ch1_world_tiles.py` y contratos de cámara/teselas; `d769966c0d`: revisión de teselas | **Lección clave**: 72 piezas físicas, cámara 1:1 y capas .30/.56; evitar «fotografía congelada» o repetición de hitos | Código de producción actual inspeccionado; algunas pruebas anteriores reportadas en historial |
| 28 oct 2026 | `48a600313c`: primer sistema TWC fútbol/danza/colegio | Reutilizar el movimiento del capítulo 1 no implica que un interior conserve la variedad del exterior | Nuevos escenarios **pendientes de validación artística** |
| 28–29 oct 2026 | Historial de trabajo de seis enemigos y cuatro clásicos | La silueta y keyframes valen más que añadir líneas sobre un dibujo geométrico; el estado de ataque debe coincidir con la IA | Artísticas nuevas sin aprobar; no activar banderas |
| 29 oct 2026 | Auditoría del colegio y retoques en generador, `docs/AUDITORIA_ARTISTICA_COLEGIO_2026-10-29.md` | Tres archivos diferentes pueden mostrar el mismo aula; máscaras alfa malas hacen objetos pegados | Se corrigieron causas en código; **27 paneles nuevos sin inspección real** |
| 29 oct 2026 | `lib/adaptive_title_screen.dart`, `qa/verify_adaptive_title_art.py` | Escalar una ilustración 16:9 con `BoxFit.fill` o encajarla con franjas en 20:9 son fallos distintos | Código preparado; panorama definitivo **faltante** |
| 29 oct 2026 | `docs/FRAMEWORK_SNES_TWC/` y pruebas de siete puertas | Conservar métodos y pruebas sin mentir sobre capturas ni aprobación | Documentación inicial guardada; futuro GPT **no publicado** |

## Fracasos que NO deben olvidarse

### A. Prototipos de capítulo 1

Los archivos `lib/chapter_one_camera_v3.dart` y `lib/chapter_one_world_v4.dart` siguen en el repositorio. La función activa **por defecto** en `lib/main.dart` es `_neighborhoodPhysicalWorld`; los métodos experimentales están tras flags. Regla general: **inspeccionar la ruta real de producción antes de extraer una plantilla**.

Intentos identificados en comentarios históricos:
- Amplificar el fondo de una sola foto para cubrir una zona enorme sin arte suficiente.
- Fundir panoramas completos temporalmente, provocando fantasmas/cortes.
- Repetir coches, edificios o hitos únicos como tiles.
- Utilizar vegetación añadida para ocultar costuras.
- Escalar horizontal/verticalmente con proporciones distintas.

**Solución actual:** teselas físicas únicas a cámara 1:1; montaña/ciudad y arbolado sí cíclicos a .30/.56; continuidad medida en ambos lados de las uniones. No borrar prototipos antiguos hasta archivar sus contratos y sus fallos.

### B. Colegio y danza

El generador anterior del colegio calculaba `crop_w=source_w`; todos los offsets eran cero aunque se etiquetaran tres variantes. Se adoptaron ventanas espaciales distintas, composición por módulos y capas. El fallo **visual** permanece como riesgo porque las tres imágenes madre son arquitectónicamente parecidas: nueve recortes matemáticamente distintos no son nueve aulas distintas para el jugador. Requiere comparación humana con el capítulo 1.

### C. Animaciones enemigas

Los generadores iniciales de enemigos se basaban en formas simples, a menudo repetían poses y dejaban al personaje erguido tras perder. La elección de fotogramas según reloj, sin comprobar `moving`, producía caminar en el sitio. Se introdujo estado de IA, interrupción al daño y `hit`/derrota; los generadores siguen sin ganar automáticamente calidad artística.

### D. Portada

El marco fijo 800×450 dentro de `FittedBox.contain` deja bandas laterales en pantallas panorámicas. `BoxFit.fill` sobre la ilustración deforma proporciones. No es lícito solucionar ambas cosas generando un «screenshot falso», estirando o usando relleno borroso. Hace falta arte lateral genuino y pruebas de botones a varias resoluciones.

### E. Falsas evidencias

Un test de PNG que sólo comprueba dimensiones no valida anatomía, luces o integración. Un contacto de imágenes generado con Pillow no es una captura del motor. La existencia de un archivo de test Flutter no significa que se haya ejecutado. **Siempre etiquetar el tipo real de prueba**.

## Cómo investigar el historial restante (sin inventarlo)

1. Enumerar todos los commits por fecha y por rutas: `lib/main.dart`, `tools/build_ch1_world_tiles.py`, `assets/images/frames/*`, `test/*`, `docs/*`.
2. Para cada salto importante, consultar el `git show`/diff y recuperar si existen capturas o artefactos verdaderos; anotar el SHA exacto y qué se observa realmente.
3. Comparar el comportamiento de **producción**, no sólo el código de prototipos guardados.
4. Registrar cada intento con `hipótesis / cambio / captura / resultado / corrección / validación`.
5. Mantener una sección de «desconocido/no verificable» para commits de nombres genéricos, assets no recuperados o decisiones previas fuera del repositorio.
6. Agregar únicamente técnicas realmente verificadas al manual de plantillas del GPT. No convertir comentarios ni mensajes de chat en resultados de prueba.

## Índice de fuentes para continuar

- `docs/HISTORIAL_DE_TRABAJO.md` — historial operativo acumulado.
- `docs/AUDITORIA_ARTISTICA_COLEGIO_2026-10-29.md` — diagnóstico visual del colegio.
- `docs/CIERRE_INTEGRAL_PR5_2026-10-29.md` — bloqueos aún abiertos.
- `docs/FRAMEWORK_SNES_TWC/01_MOTOR_ESCENARIOS_PARALLAX.md` — matemáticas exactas del fondo.
- `docs/FRAMEWORK_SNES_TWC/02_PERSONAJES_ESTANDAR_MIREN_SARA.md` — patrones de personajes y evidencia real.
- `qa/test_snes_framework_contract.py` — comprobación reproducible de los parámetros y PNG originales.

**Evidencia de esta sesión:** lectura de GitHub y de algunos PNG reales. **No se han ejecutado** generadores de PNG, Flutter, Android ni Actions. La recuperación histórica debe ampliarse gradualmente sin retrasar el cierre de la versión del juego.
