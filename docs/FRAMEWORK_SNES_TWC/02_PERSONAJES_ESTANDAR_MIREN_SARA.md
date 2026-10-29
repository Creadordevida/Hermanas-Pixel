# Estándar artístico de personajes — recuperación de Miren y Sara

**Nivel de evidencia:** imágenes `PNG` ORIGINALES consultadas directamente desde GitHub; cifras extraídas de sus cabeceras PNG reales; sistema de render localizado en `lib/main.dart`. La equivalencia artística de enemigos nuevos con estas protagonistas **todavía no se ha demostrado**.

## 1. Referencia inmutable, no reinterpretación geométrica

| Obra original | Tamaño PNG (px) | Git blob SHA | Uso |
|---|---:|---|---|
| `assets/images/futbolista.png` | 230×617 | `f71ccab4d32c7ebcd7b1bfbf95e76e73600916cf` | Referencia original de la protagonista mayor |
| `assets/images/bailarina.png` | 170×543 | `6b51d699b87f2cda6969a96928ee70065f3501e8` | Referencia original de la protagonista menor |
| `assets/images/frames/futbolista_idle_0.png` | 191×321 | `cba25c084bcb02227f69d103a9bc4c69fc4caa64` | Reposo auténtico en el motor |
| `assets/images/frames/bailarina_idle_0.png` | 165×259 | `82efaeca6c7c885e0558b5ca1dfb2742ed9bf12d` | Reposo auténtico en el motor |

Los originales `futbolista.png` y `bailarina.png` se añadieron inicialmente al repositorio en el commit `924176839b` (24/10/2026; comprobado en GitHub). En futuros proyectos sólo usar referencias autorizadas por sus creadores.

### Lo que muestran las dos ilustraciones reales examinadas

- **Rostro y cabello:** contorno legible, ojos verdes con luz, cabello rubio trabajado en mechones y capas, siluetas distintas.
- **Volumen:** luces en pelo/rostro/ropa, sombras en pliegues y pantalones, no simples bloques de color.
- **Identidad:** diferencias de estatura y complexión, prendas, zapatillas y accesorios que hacen reconocibles a cada personaje.
- **Píxel:** bordes nítidos y detalles controlados; preservar transparencia y dibujo original.
- **Coherencia:** piernas, brazos, ropa y peinado no deben cambiar arbitrariamente de volumen ni de color entre poses.

Estas observaciones son un **patrón de comparación**. No bastan para reproducir automáticamente el estilo: se necesita una revisión artística de cada fotograma.

## 2. Datos reales de los frames (nunca suponer canvas uniforme)

| Personaje | Estado original | Dimensiones PNG |
|---|---|---:|
| Miren/futbolista | idle_0 | 191×321 |
| Miren/futbolista | walk_0 | 219×320 |
| Miren/futbolista | run_0 | 56×87 |
| Miren/futbolista | jump_0 | 251×284 |
| Sara/bailarina | idle_0 | 165×259 |
| Sara/bailarina | walk_0 | 202×262 |
| Sara/bailarina | run_0 | 52×87 |
| Sara/bailarina | jump_0 | 217×249 |

**Lección importantísima:** hay PNG con resoluciones nativas radicalmente distintas. Nunca estirar cada estado por separado para llenar una caja arbitraria; eso provoca gigantismo, saltos de escala y pies que flotan. El motor de producción actual usa una altura base del `idle_0` y mantiene la **misma escala proporcional** para los demás estados.

## 3. Cómo las dibuja exactamente el motor

En `lib/main.dart`, `StagePainter._actor` selecciona según física verdadera:

```text
activo en capítulo de fútbol/danza + ataque reciente => attack_0
saltando (takeoff/rising/apex/falling)                => jump_0
aterrizando (impact/recovery)                        => idle_0
abs(c.vx)>15                                         => walk_0/walk_1
en reposo                                            => idle_0
```

**Hay PNG `run_0` en el repositorio, pero el selector actual NO los elige en este método**. No documentarlos como animación utilizada en juego sólo porque exista el archivo.

Altura lógica de dibujo normal:
- Padre: `134`.
- Futbolista: `124`.
- Bailarina: `112`.

```text
scale = standardHeight / idle_0.height
frameW = frame.width * scale
frameH = frame.height * scale
screenX = character.x - cameraX
```

El eje visual se ancla al suelo/plataforma; la sombra se proyecta a una altura física independiente del salto. Para salto se aplican pequeñas transformaciones de recuperación/estiramiento en `StagePainter`; la pose real de salto sigue siendo fundamental. Se usa `FilterQuality.none` al dibujar pixel art.

**Regla reutilizable:** el lienzo del fotograma no es su caja de colisión. Normalizar sólo para **visualizar** comparativas, no deformar el arte del personaje ni imponer un alto distinto en cada pose.

## 4. Por qué algunos primeros enemigos quedaron lejos del estándar

Según `docs/HISTORIAL_DE_TRABAJO.md` y el código de generadores:

1. Comenzar por **rectángulos y polígonos sin dibujo de volúmenes** no produce automáticamente anatomía creíble.
2. Añadir unas líneas y sombras sobre una silueta débil no alcanza el nivel de una protagonista de alta resolución.
3. Reutilizar una pose casi idéntica y trasladarla de posición no constituye una animación: mover miembros, distribución de peso y contacto con suelo.
4. Una derrota casi erguida no se lee como caída; necesita una silueta independiente reconocible.
5. Escalar cada frame al mismo rectángulo distorsiona proporciones; extraer alpha bbox y utilizar escala canónica.
6. Los tests de existencia de PNG/dimensiones/hash pueden ser correctos con una imagen artísticamente deficiente.
7. Los seis enemigos nuevos siguen con `enemyArtValidated=false`; sus atlas y animaciones **no están aprobados**.

No declarar que esos problemas están ya solucionados: sólo algunas correcciones técnicas y generadores están guardados.

## 5. Proceso reutilizable de creación de personaje desde cero

1. **Ficha de identidad y silueta**: rol, características visibles no sensibles, color de ropa, tamaño relativo a protagonista, 3 rasgos reconocibles.
2. **Prueba de estilo:** diseñar y revisar primero **reposo a escala real** junto a `futbolista_idle_0.png` y `bailarina_idle_0.png`. Si no alcanza el nivel, NO producir 24 frames a partir de ese arte.
3. **Modelo de volúmenes:** cabeza, tronco, articulaciones, pelo, ropa, zapato, luz dominante y sombras; alta fidelidad ANTES de variantes de pose.
4. **Hoja modelo:** paleta registrada, geometría de rostro y pelo, línea de suelo, pivote, ancho/alto lógico y colisión. Mantener rasgos iguales entre poses.
5. **Keyframes reales:** reposo, anticipación, movimiento, ataque, recibir impacto, derrota; cada estado debe diferir en anatomía y peso, no sólo desplazamiento.
6. **Inbetweens:** completar 3-4 frames por acción **después** de que cada keyframe crítico esté aprobado.
7. **Atlas y checksums:** generar PNG reales desde los dibujos, metadatos de alpha bbox; verificar que cada fotograma no se corta ni crece.
8. **Integración:** anclar con la altura de reposo, asociar las animaciones al estado físico/IA, comprobar capacidades de Miren y Sara, colisiones y ataque interrumpible.
9. **Captura real Flutter:** reposo, caminar, alerta, ataque, daño y derrota; comparar a la escala real del mundo junto a héroes, escenario y sombra.
10. **Aprobación:** inspección crítica visual; sólo se habilita el enemigo cuando su atlas, comportamiento y arte son satisfactorios. Luego probar Android cuando se autorice.

### Ficha de aceptación obligatoria

```yaml
personaje: ""
version_fuente: ""
png_fuente_sha256: ""
referencia_arte: [futbolista_idle_0, bailarina_idle_0]
escala_de_juego: ""
estados: [idle, locomotion, alert, attack, hit, defeated]
pivote_pies: ""
color_sombra: ""
test_alpha_y_recortes: pendiente
test_animacion_motor: pendiente
comparacion_visual_lado_a_lado: pendiente
prueba_colisiones: pendiente
aprobacion_artista: pendiente
prueba_android: pendiente
```

**No admitir `aprobado` si algún criterio esencial sigue en `pendiente`.** Una prueba automatizada puede comprobar integridad, **no juzga por sí sola** el parecido de calidad con Miren/Sara.

## 6. Código y materiales que sí conviene extraer como futuras plantillas

- `assets/images/frames/futbolista_idle_0.png` y `bailarina_idle_0.png`: *referencias autorizadas del proyecto*, no archivos para redistribuir libremente.
- `lib/main.dart` `StagePainter._actor`: pivote físico, escala canónica, sombra y lógica de estados.
- `lib/sprite_bounds.g.dart` / `tools/export_sprite_bounds.py`: alpha-bboxes de enemigos, detección de marcos truncados y SHA.
- `lib/classic_enemy_pose.dart`: selección de poses por estado, no por simple reloj.
- `test/qa_new_enemy_real_render_test.dart`, `test/qa_four_classic_enemy_render_test.dart`: preparación de capturas auténticas de Flutter. **No se consideran ya ejecutadas** por haber sido escritas.
- `docs/NUEVOS_ENEMIGOS_CONTRATO_VISUAL_Y_MECANICO.md`: especificación de IA y poses del proyecto.

## 7. Comprobaciones pendientes del conocimiento histórico

La pareja de PNG `idle_0` ha sido **visualizada** y se han verificado dimensiones de varios estados. **Todavía falta** inspección fotograma a fotograma de todas las hojas y todos los commits que condujeron a los diseños aprobados; los archivos originales pueden tener variaciones de resolución/alpha significativas. No completar desde suposiciones la historia de cada decisión.

Este documento describe **lo observado y lo implementado**, no promete que el futuro GPT consiga automáticamente la misma calidad artística.
