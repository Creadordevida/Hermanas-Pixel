# THE WOLF COMPANY — Método de movimiento 2D aprobado (RC3 FIX2)

**Estado:** patrón de desplazamiento y paisaje modular **aprobado visualmente por el usuario** en gameplay Android del 28/10/2026; NO equivale a aprobar todo el capítulo 1. **Versión de referencia:** Hermanas Pixel RC3 FIX2, commit base `0b4971b014128188228b2a8edf6f25a28fe8950b` (la documentación no modifica la mecánica). **Licencia de uso interno:** reutilizable como receta técnica en todos los escenarios y futuros juegos de The Wolf Company.

> **Regla de oro:** congelar el *comportamiento* (cámara en coordenadas de mundo + capas de paralaje en movimiento + piezas cercanas físicas), pero permitir cambiar *el arte* (barrio, ciudad, ciencia ficción, fantasía, bosque, desierto…). No confundir «la técnica del fondo está aprobada» con «todos los elementos gráficos de la RC3 FIX2 están aprobados».

## 1. Qué se aprobó exactamente

En el gameplay real, el usuario considera **perfecto el fondo modular ordinario**: montaña con textura y profundidad, ciudad a lo lejos, arbolado multicolor, vegetación, vallas y mobiliario que pasan a diferentes velocidades mientras avanza Miren/Sara. Es el resultado que debemos preservar en proyectos futuros.

**No aprobados y deliberadamente EXCLUIDOS del patrón:** las siete imágenes grandes de lugares reconocibles cuando se incorporan con bordes semitransparentes (edificios fantasma, cielos y árboles dobles); la portada 800×450 con franjas borrosas y el logotipo TWC demasiado pequeño. Esos defectos no pertenecen al método de paralaje y deberán corregirse aparte.

## 2. Arquitectura que sí funciona

En el capítulo 1 actual:

1. **Cámara:** `cameraX` es una posición de mundo. La posición horizontal en pantalla de un elemento físico es **`worldX - cameraX`**. El personaje sigue a la cámara con referencia aproximada de 327 px de pantalla, con límites en los extremos del capítulo.
2. **Capa lejana de montañas y ciudad**: una textura panorámica **2200×380 RGB**, en bucle, desplazada a **0,30×** el avance de la cámara.
3. **Capa intermedia de arbolado**: textura **2020×380 RGBA** (alfa real), independiente, en bucle, a **0,56×**.
4. **Capa física cercana:** decoración, vallas, árboles, bancos, jardines y mundo próximo repartidos en **72 piezas RGBA** de ancho 512 y alto 380 px (la última, 148 px), ancladas a `worldX` y desplazadas **1,00×**. Su velocidad NO debe copiar la de las montañas.
5. **Suelo, plataformas, enemigos y colisiones:** permanecen en sus coordenadas de mundo y no se definen en función de la posición relativa de la imagen. El suelo está separado del arte de cielo/horizonte.

La escena de **36.500 unidades** no se representa estirando una imagen; solo se pintan las piezas visibles (más vecinas) y el fondo lejanísimo se repite sin desplazarse al ritmo del suelo.

### Fórmulas del efecto

```text
x_en_pantalla_de_objeto = x_en_mundo - cameraX
fase_de_fondo_lejano   = (cameraX * 0.30) mod 2200
fase_de_arbolado_medio = (cameraX * 0.56) mod 2020
x_en_pantalla_de_tesela_i = 512*i - cameraX
```

Ejemplo verificable al avanzar la cámara **600 px de mundo**:

| Plano | Desplazamiento visible respecto a pantalla |
| --- | ---: |
| Montañas + ciudad | 180 px |
| Arbolado medio | 336 px |
| Decoración física + suelo | 600 px |

Esto crea profundidad sin inmovilizar el decorado. Las longitudes de repetición también son distintas:

- Fondo lejano: **2200 / 0,30 ≈ 7.333 unidades de mundo** (aproximadamente 1/5 del capítulo).
- Arbolado medio: **2020 / 0,56 ≈ 3.607 unidades**.

Sus repeticiones no coinciden constantemente; esa desincronización contribuye a la variedad.

### Orden de dibujo — indispensable

```text
color de cielo de seguridad
→ paisaje lejano cíclico (0,30×)
→ arbolado intermedio cíclico (0,56×, alfa)
→ piezas físicas transparentes del mundo (1,00×)
→ suelo jugable/colisiones/personajes/efectos según motor
```

La textura lejana debe enlazar el extremo derecho con el izquierdo sin cambios bruscos de horizonte o color. El cierre usado en RC3 FIX2 combina por solapamiento circular 220 px del final con el principio **durante la generación** (NO aplica fundidos cambiantes durante la partida). La capa de arbolado tiene extremos transparentes para evitar cortes rectangulares. Los otros elementos se colocan por coordenadas de mundo, no por un `progress` que estire fotografías.

## 3. Dónde está implementado (código fuente canónico)

| Archivo | Responsabilidad |
| --- | --- |
| `lib/main.dart` | `_drawCh1Loop(...)`, `_neighborhoodPhysicalWorld(...)` y orden real de capas. Fórmula de fase: `(cameraX*speed)%width`. |
| `lib/chapter_one_world_tiles.dart` | `ch1FarSpeed = 0.30`, `ch1MidSpeed = 0.56`, 72 teselas, anchos de ciclo, matemáticas de cámara y selección de teselas visibles. |
| `tools/build_ch1_parallax.py` | Receta reproducible para generar paisajes, arbolado y 72 piezas RGBA; semilla determinista `20261028`. |
| `assets/images/chapter1/ch1_parallax/montanas_ciudad_ciclo.png` | Fondo lejano **2200×380**. |
| `assets/images/chapter1/ch1_parallax/arbolado_medio_ciclo.png` | Arbolado medio **2020×380**. |
| `assets/images/chapter1/ch1_world_tiles/world_000.png` a `world_071.png` | Escenario cercano 1:1 con la cámara. |
| `qa/ch1_rc3_parallax/MANIFEST.json` | Metadatos reproducibles y muestras de posición de cámara. |
| `test/chapter_one_world_tiles_test.dart` | Comprobación Dart de 600→180/336/600, continuidad y anchos. |
| `qa/check_ch1_physical_tiles.py` | Integridad Python de cobertura y recursos; no sustituye la revisión artística. |
| `qa/test_twc_parallax_contrato.py` | Nueva protección contra cambios accidentales de esta receta aprobada. |

**Atención:** ejecutar `python3 tools/build_ch1_parallax.py` reconstruye las 72 teselas, incluidos los **siete hitos enteros con transparencias que AHORA ESTÁN RECHAZADOS**. No ejecutarlo sobre la rama estable para producir nuevas imágenes sin antes adaptar la sección `originals` del generador y revisar las salidas. Conservar maestros originales y comparar los fotogramas antes de sustituir arte aprobado.

## 4. Cómo convertir esta arquitectura en cualquier ambientación

Para **ciudad futurista**, **fantasía medieval**, **paisaje urbano** o **campo deportivo**:

- Sustituir los **PNG de las capas lejanas e intermedias** por otros con las mismas propiedades de ciclo, tamaño y alfa; conservar velocidad relativa, fórmula de desplazamiento y orden de capas.
- Sustituir las **piezas cercanas** por arquitectura, mobiliario y vegetación del nuevo tema, manteniendo su posición física 1:1 y su canal alfa.
- Construir los hitos únicos como **objetos completos independientes** sin cielo de origen ni máscaras de desvanecimiento sobre fachadas. Nunca superponer una fotografía de pantalla completa semitransparente como atajo.
- Mantener la cámara y la física comunes a todos los elementos jugables. No regresar al `maxPan * progress` para simular desplazamiento.
- Ajustar resolución, escala y anchos de panorámica solo de forma **deliberada**, actualizando contrato y revisando el efecto de repetición y sus límites antes de aprobar el cambio.

Lo esencial no son los colores de las montañas ni la lista de árboles: **el movimiento sincronizado de capas, el bucle sin costura y el mundo físico de primer plano**.

## 5. Contrato QA para futuros cambios

**Comprobar como mínimo:**

1. En el mundo del capítulo 1 hay **36.500 px**, 72 teselas de 512, última 148, todas colocadas sin huecos a velocidad 1:1.
2. Con desplazamiento de cámara de **600 px**, la capa de fondo se mueve **180**, el arbolado **336** y el suelo/primer plano **600**.
3. Los dos fondos cíclicos tienen extremos compatibles; grabar vídeo atravesando el retorno de ambos ciclos, sin saltos horizontales ni bandas visibles.
4. Observar vídeo de gameplay real: el paisaje cambia en **varios planos**, no permanece fijo ni avanza exactamente al ritmo del personaje.
5. No hay áreas de fachadas/cielo semi-transparentes sobre otras fachadas, aunque «pasen» las pruebas de código.
6. El `pubspec.yaml` incluye las carpetas nuevas; `flutter analyze`, `flutter test` y la compilación del APK deben pasar en GitHub; el móvil confirma comportamiento y fluidez.
7. Si una nueva estética altera los parámetros, crear una **nueva versión del contrato** y mostrar comparación ANTES/DESPUÉS. No modificar silenciosamente el patrón aprobado.

La prueba `qa/test_twc_parallax_contrato.py` verifica la **estructura mecánica**, no sustituye la revisión visual humana; mantener ambos controles.

## 6. Instrucción para futuro GPT de The Wolf Company

> **Método 2D obligatorio (salvo aprobación explícita de alternativa):** usa cámara en coordenadas de mundo, primer plano físico a 1:1, capas lejanas cíclicas a distintas velocidades con empalmes perfectos y elementos únicos de arquitectura separados. Para reproducir el efecto que aprobamos en Miren y Sara RC3 FIX2: capítulo de referencia 36.500 px; paisaje lejano 2200×380 a 0,30×; arbolado medio 2020×380 a 0,56×; teselas cercanas RGBA de 512×380 a 1,00×; ejemplo cameraX +600 => desplazamientos +180/+336/+600. El aspecto del arte puede ser urbano, fantasía o ciencia ficción, pero la matemática, el orden de planos y las pruebas de vídeo deben mantenerse o revisarse expresamente. No recuperes el antiguo sistema de panoramas inmóviles, fotos estiradas ni fundidos de edificios enteros. No apruebes un escenario solo porque Flutter compile o las pruebas Python pasen.**

## 7. Historial y alcance de esta aprobación

- **28/10/2026:** tras comparar vídeos del capítulo 1 y del fútbol, se integró el nuevo fondo detallado por paralaje en la RC3 FIX2.
- **28/10/2026:** el usuario revisó el gameplay Android y aprobó explícitamente **el fondo modular, su detalle y la sensación de movimiento de varias capas**; pidió conservarlo y documentarlo para futuros proyectos.
- **Pendientes no incluidos en esa aprobación:** portada y logo TWC, transiciones por alfa de las siete fotos/ilustraciones originales, jugabilidad completa del capítulo.

**Regla de conservación:** no sustituir este método por uno más simple para arreglar un defecto artístico. Mejorar el arte por separado, preservando la física del mundo y el movimiento aprobado.