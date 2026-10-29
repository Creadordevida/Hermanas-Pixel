# Motor de escenarios SNES — reconstrucción verificable del sistema de Miren y Sara

**Estado:** contrato recuperado del código real de la rama `work/revision-visual-20261028-continuidad` el 29/10/2026. **No se ha ejecutado aquí Flutter ni Android.** Esta documentación no da por aprobados los interiores nuevos.

## 1. Fuentes de verdad (no reinventar la cámara)

- `lib/main.dart`: `viewW=800`, `viewH=450`, `groundY=390`, `stageWidth=36500`, `StagePainter._neighborhoodPhysicalWorld`, `_drawCh1Loop`, `_footballBackgroundTWC`, `_interiorBackgroundTWC` y `_actor`.
- `lib/chapter_one_world_tiles.dart`: **72 teselas**, `512px` por tesela, última tesela de `148px`; primer plano `36500×380`; cámara y selección de teselas visibles.
- `lib/chapter_one_camera_v3.dart`: `worldObjectScreenX(worldX,cameraX)=worldX-cameraX`, seguimiento `clamp(heroX-327,0,36500-800)` y conservación del aspecto natural de las ilustraciones. La definición de `WorldArtPlacement` es histórica/experimental: **no confundir** con el camino de producción actual.
- `lib/neighborhood_scene_engine.dart`: siete regiones de mundo contiguas y cuatro hitos únicos.
- `lib/football_parallax_twc.dart`: capas de fútbol .30/.56 y teselas cercanas de 1100px, seis clases de tesela.
- `lib/interiors_parallax_twc.dart`: interiores del colegio/danza; módulos físicos 880px, zonas `[0,10500,25500,36500]`, nueve variantes de colegio planeadas y tres de danza.
- `tools/build_ch1_world_tiles.py`, `tools/build_football_parallax_twc.py`, `tools/build_interiors_parallax_twc.py`: generadores reales; **no** sustituirlos por dibujos esquemáticos.
- `test/qa_render_capture_test.dart`: ejemplos de capturas auténticas de Flutter, de ambos lados de las uniones.

## 2. Matemática exacta del desplazamiento

Coordenada mundial del jugador `hero.x`. Cámara lógica con seguimiento horizontal:

```text
cameraX = clamp(hero.x - 327, 0, stageWidth - viewW)
screenX(worldObject) = worldX - cameraX
offset(far) = (cameraX * 0.30) mod 2200
offset(mid) = (cameraX * 0.56) mod 2020
offset(near) = cameraX
```

La cámara real suaviza el destino con `_ease(cameraX, target, dt*600)` en `lib/main.dart`; **el destino** anterior no es por sí solo el algoritmo completo de actualización. Probar aproximación y límites.

Los ciclos se dibujan **hasta cubrir el ancho de 800**: primero `x=-offset`, luego `x+=image.width`. Las teselas físicas se dibujan sólo cerca de la cámara y ancladas a su `worldX`, **no** se repiten fotos de edificios importantes. `FilterQuality.none` evita suavizados accidentales en el pixel art.

| Capa | Factor | Recurso real | Período en mundo |
|---|---:|---|---:|
| Lejana | 0.30 | `assets/images/chapter1/ch1_parallax/montanas_ciudad_ciclo.png` | `2200 / .30 ≈ 7333.33` |
| Intermedia | 0.56 | `assets/images/chapter1/ch1_parallax/arbolado_medio_ciclo.png` | `2020 / .56 ≈ 3607.14` |
| Física | 1.00 | `assets/images/chapter1/ch1_world_tiles/world_000..071.png` | **No es una foto repetida:** 36500px únicos |

**Nunca modificar las velocidades .30/.56/1.00 sin evidencia de una mejora real en el juego.**

### Capítulo 1: arquitectura comprobable

- 72 tiles a 512px: `71*512+148=36500`. La función `ch1PhysicalTileActualWidth(71)` usa el ancho **148**, no 512. No inventar píxeles al final.
- Cargar `ch1PhysicalVisibleTiles(cameraX)`: teselas junto al campo visible con un margen de un índice para evitar rendijas.
- `StagePainter._neighborhoodBackground` usa `_neighborhoodPhysicalWorld` como camino de producción por defecto; los fondos experimentales V3/V4 y el legado quedan **detrás de flags**, no son equivalentes.
- Regiones históricas del arte urbano: `[0,7200]` residencial, `[7200,9200]` conexión, `[9200,16200]` paseo, `[16200,18400]` conexión, `[18400,25400]` parque cubierto, `[25400,27600]` conexión, `[27600,36500]` parque cohete. Se usan para semántica del recorrido, no para repetir panoramas cada 800px.
- El suelo dibujado y las colisiones deben usar el **mismo `groundY=390`** para evitar pies flotantes o dobles pavimentos.

### Aplicación a fútbol

Las fórmulas del cielo y arbolado permanecen idénticas, con arte diferente. En el capítulo de fútbol: altura del fondo 386px; seis teselas cercanas de 1100px, con repetición de **módulos físicos** cada `6*1100=6600` unidades. No confundir repetición de **módulos de terreno** con clonación de un edificio único. Revisión visual final pendiente.

### Aplicación a interiores: sólo se mueve el exterior tras las ventanas

En colegio y danza primero se dibuja el paisaje **lejano .30** y el **intermedio .56**; luego el panel RGBA de pared **1.00**, que deja ver el fondo exclusivamente donde el alfa lo permite. Se dibujan objetos físicos en coordenadas de mundo; puertas en cambios de habitación, nunca atadas al parallax. Colegio `height=278`, danza `height=286`; `interiorModuleWidthTWC=880`. La variación del colegio se planifica con `(index*5+zone*2)%9`, de manera que los nueve índices se recorren antes de repetir. **Nueve hashes o recortes distintos no garantizan variedad artística**.

El generador actual mezcla planos del pasillo, matemáticas e informática. La calidad de las 27 composiciones definitivas sigue **no verificada** hasta ejecutar, revisar y comparar capturas reales con capítulo 1.

## 3. Errores históricos que este contrato debe bloquear

1. **Panorama estirado:** cambiar `x` e `y` por factores diferentes altera edificios y personajes. Conservar proporciones y recortar horizontalmente cuando sea preciso; nunca `BoxFit.fill` para arte aprobado.
2. **Edificio único clonado:** no repetir fachadas, coches o elementos reconocibles como si fueran tiles neutros.
3. **Fundido general de dos fotos:** produce fantasmas/superposiciones; la unión es **espacial**, apoyada en estructura real del mundo.
4. **Capas todas a velocidad 1:** destruye la profundidad; aplicar .30/.56/1.00.
5. **Suelo visual independiente del suelo físico:** provoca personajes flotantes; sincronizar `groundY`, puntos de apoyo, colisiones.
6. **Ventanas parallax falsas:** verificar con dos capturas donde se mantiene el muro quieto y se desplaza únicamente el exterior.
7. **Módulos diferentes sólo en nombre:** comparar recursos y composiciones a varias cámaras. Un PNG distinto no equivale a una clase diferente.
8. **QA que carga escenas falsas:** capturar con `StagePainter`, verificar que cambian las cámaras, las imágenes están cargadas y las vistas no son blancas.

## 4. Procedimiento para crear otro escenario sin reinventar el motor

1. Elegir la escala 800×450, un terreno a coordenada mundial 1:1 y límites de mundo.
2. Diseñar paisaje lejano cíclico y zona intermedia cíclica que **no** repitan monumentos únicos.
3. Crear tiles cercanos físicos con anchos nativos exactos; registrar último tile parcial.
4. Calcular `cameraX` únicamente a partir de la posición en el mundo; los mismos valores se usan para sprites, decorado, proyectiles y colisiones.
5. Si hay ventanas: convertir el mural en RGBA y definir alfa **sólo** en cristales; no volver transparente la pared.
6. Renderizar 3 cámaras en cada unión (antes, justo en la unión y después); inspeccionar también secuencias.
7. Ejecutar pruebas de tiling, huecos, movimiento relativo, posición de suelo y colisiones, y **abrir visualmente** los PNG.
8. Archivar `sha` del recurso, captura real del motor y defecto corregido; sólo entonces aprobar.

**Contraejemplos a conservar en repositorio:** `chapter_one_world_v4.dart` / `chapter_one_camera_v3.dart` contienen prototipos útiles para estudiar intentos anteriores, pero la rama de producción actual elige `_neighborhoodPhysicalWorld`. Antes de extraer uno de ellos, verificar qué ruta realmente se ejecuta.

## 5. Pruebas de aceptación

- `ch1PhysicalTileCount==72`, último ancho 148 y recorrido total 36500.
- Un objeto físico en x=1500 se muestra en pantalla x=700 si `cameraX=800`.
- Con `cameraX=1000`, el fondo lejano avanza 300px y el intermedio 560px: **no** desplazarlos 1000px.
- En ventanas: píxeles de muro idénticos al modificar sólo cámara exterior; los píxeles transparentes sí dejan ver una vista distinta.
- Capturas reales del motor en el inicio, mitad y fin de cada región, incluido entorno de las seis uniones.
- Comparación humana con la referencia del capítulo 1; los tests numéricos no bastan.

**Estado de prueba de este documento:** código consultado y fórmulas contrastables; no se ha ejecutado Flutter ni se certifican estéticamente los escenarios nuevos.
