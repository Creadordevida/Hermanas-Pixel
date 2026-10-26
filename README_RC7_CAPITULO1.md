# Las aventuras de Miren y Sara — capítulo 1 (RC7, trabajo técnico)

**Estado (26/10/2026): implementado en el código fuente, con pruebas técnicas locales superadas. Todavía NO aprobado visualmente ni probado en Android. No instalar como versión final.**

## Origen visual auténtico

Las cuatro fotografías del barrio, aportadas el 26/10/2026, guiaron cinco nuevos archivos gráficos que el código Flutter carga desde `assets/images/chapter1/`:

1. `residential_curve.png`: edificio blanco curvo con parque infantil.
2. `green_promenade.png`: paseo arbolado, colina y edificios del fondo.
3. `white_canopy.png`: parque con cubierta textil blanca.
4. `rocket_park.png`: cohete rojo con toboganes metálicos.
5. `park_props_atlas.png`: árboles de distintas variedades, arbustos, bancos, farolas y mobiliario **independiente**.

Son *recursos nuevos generados en estilo pixel art a partir de fotografías*, no capturas del motor. La imagen-mosaico «CAPÍTULO 1 - NUESTRO BARRIO» sigue siendo una **propuesta ilustrativa**, jamás evidencia del APK. La reproducción visual exacta no está garantizada.

## Ingeniería y jugabilidad

- El recorrido `0..36500` ahora se divide en cuatro zonas de mundo contiguas: `0..8300`, `8300..17300`, `17300..26400` y `26400..36500`.
- Cada zona usa un recurso panorámico exclusivo, sin bucle ni espejo. Se desplaza dentro de su rango local de imagen una sola vez y se funde gradualmente con el siguiente recurso al acercarse a la transición.
- El primer plano ya no usa la franja `mid/stage_0.png` cada 640 píxeles. Los objetos pequeños se dibujan por separado a velocidad de mundo `1.0`, con distribución determinista y eliminación por visibilidad.
- El suelo físico sigue gobernado por `groundY=390`; se conserva la textura aprobada `ground/stage_0.png`, que se renderiza en `y=380`, sin suelo doble añadido.
- Obstáculos, monedas, pequeñas plataformas y enemigos se distribuyen de manera reproducible dentro de cada zona y evitan los extremos de transición.
- Se conservan la portada aprobada, los protagonistas, los trajes y sprites RC6, el sistema de corazones y los otros seis capítulos.
- El mapa y los capítulos anteriores no se han rediseñado.

## Comprobaciones ejecutadas localmente

- `python3 -m unittest discover -s qa -p 'test_*.py'` → **75 pruebas correctas**.
- `qa/verify_resources.py` → recursos base íntegros.
- `qa/verify_layered_scenes.py` → estructura de capas verificada mecánicamente.
- `qa/verify_candidate_assets.py` → 137 referencias preexistentes correctas.
- `qa/release_gate.py` → baseline 0.8.0 intacta.
- `qa/scene_metrics_vnext.py` → comprobaciones de capas, sin aprobación artística.
- Nuevas pruebas negativas para duplicación de landmark y comprobación de atlas con transparencia.

## Lo que FALTA y no debe darse por superado

1. No se ha ejecutado `flutter analyze` ni `flutter test` en este entorno, porque no hay Flutter SDK.
2. El flujo de GitHub Actions ahora exige capturas del Flutter real del título, mapa, siete capítulos, cuatro zonas del barrio y ambos lados de sus tres uniones: si falla, el flujo no debe mostrar un verde engañoso.
3. Hay que **inspeccionar** las capturas por artefactos, tamaño de objetos, suelo y continuidad y ajustar los fondos si el motor muestra una degradación. Las pruebas automáticas no certifican estética.
4. Hay que jugar en móvil el capítulo completo, comprobar duración, velocidad, táctil, caídas FPS, colisiones, encuentros y transiciones, con Miren y Sara.
5. No se ha comparado fotograma a fotograma el mosaico conceptual con una captura Android; afirmar que se ve exactamente igual sería falso.

## Política de entrega

Conservar este trabajo como base de revisión RC7. **No publicar como versión aprobada ni generar el ZIP final mientras no se terminen y acepten las mejoras.**

## Actualización: rata y gato (26/10/2026)

Se han incorporado dos hojas RGBA nuevas de cinco estados cada una, utilizadas por el motor mediante `lib/creature_sheet_bounds.dart` y `assets/images/enemies_hifi/`. Las imágenes antiguas permanecen como evidencia de regresión. El caso y la causa del fallo de calidad se documentan en `CASO_QA_2026-10-26_RATA_GATO.md`, con nuevos tests que exigen poses diferentes y detalle visible. La generación de diez capturas de criaturas usando el StagePainter REAL se añade al flujo de GitHub. Estas capturas y las pruebas móviles **todavía no se han ejecutado**.

## Actualización: mejora 9 (perros) y 11 (palomas), 26/10/2026

- **Perros**: tres variantes con estados de patrulla, quietud, alerta, carrera,
  preparación visible de mordisco, impacto, aturdimiento y derrota. La pose
  depende del movimiento real y no del cambio walk/run basado en el reloj.
  Mordisco con aviso y contacto diferido, una vez por animación. Imágenes
  originales recortadas por alfa medido, escala fija y patas en `groundY`.
- **Palomas**: mantienen dibujos de suelo para caminar/posarse y una hoja nueva
  de ocho cuadros RGBA para despegue, batido, planeo, picado, golpe y caída.
  Altitud progresiva en vez de offset fijo; pivotes medidos en las patas de cada
  pose mantienen tamaño y posición del cuerpo coherentes.
- **QA**: **87 pruebas Python** locales correctas. Añadidas pruebas Dart de
  estados y 33 capturas Flutter obligatorias en CI: 24 caninas y 9 de palomas.
- **Pendiente**: sin SDK Flutter local no se ejecutaron `flutter analyze`,
  `flutter test` ni las capturas; sin teléfono, tampoco controles/FPS reales.
  La puerta estricta aún marca 155 comprobaciones pendientes. No hay ZIP final.

El aprendizaje reutilizable se conserva en
`CASO_QA_2026-10-26_PERROS_PALOMAS.md`.

## Actualización: mejora 8, salto y sombras (26/10/2026)

- Animación con fases explícitas: impulso, subida, ápice, caída con piernas
  extendidas, compresión al impacto y recuperación. Se emplean los sprites
  auténticos ya aprobados, sin repintar pelo, caras ni trajes.
- La fase depende de `hero.vy`, despegue y evento real de aterrizaje; la
  compresión varía con la velocidad del choque y dura menos de un cuarto de
  segundo. Las partículas del impacto quedan en el suelo.
- El óvalo oscuro **y** el aro dorado ya no siguen `c.y`: se proyectan al suelo
  o a la plataforma inmediatamente bajo las botas, con tamaño/transparencia
  atenuados por la altitud. El eje horizontal sí acompaña al personaje.
- Los 18 PNG aprobados de Miren/Sara (ropa normal y trajes) mantienen sus
  hashes SHA-256 originales. Nuevas pruebas de regresión y 30 capturas reales
  del `StagePainter` exigidas en GitHub Actions (28 fases y 2 plataformas).
- **Pendiente:** ejecutar análisis Dart, capturas Flutter y prueba en móvil;
  revisar si la transición artística requiere más dibujos específicos tras ver
  las capturas auténticas. No constituye aprobación visual ni ZIP final.

Ver `CASO_QA_2026-10-26_SALTOS_SOMBRAS.md`.

## Actualización: campo de entrenamiento y escuela de danza (26/10/2026)

Aplicamos los mismos criterios SNES del barrio a dos escenarios muy
diferentes (índices internos 4 y 5; capítulos 5 y 6 del mapa).

**Campo de entrenamiento:**

1. Acceso al complejo deportivo, portería y edificio de vestuarios al fondo.
2. Pista de ejercicios con porterías, vallas, maniquíes y red de prácticas.
3. Pequeñas gradas cubiertas y zona final del campo.

**Escuela de danza:**

1. Vestíbulo y recepción con acceso a la academia.
2. Gran estudio luminoso con espejos, ventanales y barras de danza.
3. Pequeño espacio de ensayo escénico con cortinas rojas e iluminación.

Son **seis archivos gráficos nuevos incorporados al motor**, no ilustraciones
sueltas que vayan a mostrarse automáticamente fuera del juego. Los seis fondos
se recorren por zonas del mundo y se funden progresivamente, conservando la
escala de composición y sin copiar los monumentos cada 640 píxeles.

Se mantienen los **suelos físicos y artísticos aprobados**, a cotas distintas:
campo `y=386` (césped) y danza `y=286` (parquet). Dos atlas transparentes
proporcionan seis tipos de objetos pequeños por entorno, con recortes alfa
medidos; sus posiciones son deterministas pero irregulares.

Los archivos anteriores de fútbol y ballet se conservan intactos como
referencia y reversibilidad, pero dejan de pintarse como fondo principal de
estos dos capítulos. El primer capítulo y los otros cuatro no se modifican.

**QA:** 96 pruebas Python locales pasan. GitHub exige otras 14 capturas del
Flutter real (tres zonas y cuatro vistas a ambos lados de las uniones de los
dos capítulos) y una comprobación mecánica de diferencias. **Pendiente:**
`flutter analyze`, las 14 capturas, inspección artística y prueba física
en Android. El cambio NO está aprobado para publicación. No hay ZIP final.

El protocolo y la causa de los fallos detectados están en
`CASO_QA_2026-10-26_CAMPO_DANZA.md`.
