# Enemigos del Río Arga — aprobación artística y continuidad (2026-11-08)

## Orden vinculante
El propietario ha aprobado las cuatro láminas conceptuales de seis poses:
1. **Cangrejo de río**: acercarse lateralmente y atacar con ambas pinzas.
2. **Pescador**: acercarse y atacar lanzando su caña/anzuelo.
3. **Niño gamberro**: lanzar piedras redondeadas del río.
4. **Trucha**: salir del agua y saltar hacia Miren y Sara.

La estética, identidad facial/anatómica, silueta, paleta, ropa, complementos y sombreado de las imágenes aprobadas son vinculantes. No generar sustitutos procedimentales de baja fidelidad.

## Fuentes aprobadas protegidas
Los originales de evaluación, convertidos a WebP **sin pérdida** y con transparencia, están en:
- `docs/continuidad/referencias/arga_enemigos_aprobados_20261108/cangrejo_seis_poses_aprobadas.webp` — Git blob `2ceb16c7c0ee435ee5860a1a2c233f32cd87793d`
- `docs/continuidad/referencias/arga_enemigos_aprobados_20261108/pescador_seis_poses_aprobadas.webp` — Git blob `e33247cc3c56e08760ff404de87ebc087922575a`
- `docs/continuidad/referencias/arga_enemigos_aprobados_20261108/gamberro_seis_poses_aprobadas.webp` — Git blob `6a3837cbcadbc8dc8aa1012f23bcdc6e4138cf77`
- `docs/continuidad/referencias/arga_enemigos_aprobados_20261108/trucha_seis_poses_aprobadas.webp` — Git blob `15697c4bd9bb24cdf64268500fba6a1536fc907e`

Todas son 2172×724 px y representan **conceptos para aprobación**, no atlas de producción. La transferencia binaria se verificó con `git hash-object` local contra los SHA devueltos por GitHub. No sobrescribir originales, tampoco reemplazar imágenes anteriores de otros enemigos.

## Poses aprobadas (orden de izquierda a derecha)
| Enemigo | 1 | 2 | 3 | 4 | 5 | 6 |
| --- | --- | --- | --- | --- | --- | --- |
| Cangrejo | Reposo | Caminar lateral | Alerta | Pinzazo | Impacto | Derrota invertido |
| Pescador | Reposo | Caminar | Caña alta | Lanzamiento | Impacto | Derrota sentado |
| Gamberro | Reposo | Correr | Apuntar | Lanzamiento | Impacto | Derrota sentado |
| Trucha | Nadar | Acelerar | Preparar salto | Salto ofensivo | Impacto | Boca arriba |

## Diagnóstico previo a separar fotogramas
- Los cuatro PNG de origen tienen transparencia RGBA.
- **No se debe cortar a ciegas en seis rectángulos de 362 px**: hay elementos cerca o sobre límites de celda, especialmente la caña del pescador, la piedra y la cola de trucha. Cortar directamente puede amputar complementos y repite defectos ya corregidos en otros enemigos.
- Trabajar mediante máscaras alfa y extracción de siluetas; cuando una pose invada otra columna, ampliar o reconstruir exclusivamente esa pose sin alterar diseño aprobado.
- Alinear base de pies en humanos/cangrejo; preservar la base acuática de la trucha como un efecto separado. Normalizar tamaño **tras** inspeccionar la escala real de Miren y Sara; no inventar tamaño de colisión.

## Estado real
- **COMPLETADO**: concepto artístico, aprobación del usuario, copia sin pérdida en GitHub, comprobación de integridad de los cuatro originales. Commit de incorporación `460d9b5`.
- **PENDIENTE**: extracción limpia de cada pose, intermedios de animación, ataques/proyectiles, integración del motor `qaStage:7`, pruebas físicas, capturas reales `StagePainter` 20:9 y evaluación visual a escala de juego.
- **RESTRICCIONES**: sin gastos en GitHub Actions, sin instalación Flutter por ahora, no activar Arga en el mapa ni desplegar APK. No declarar terminado ningún enemigo sin verlo funcionar.

## Siguiente microtarea
Crear y verificar una extracción conservadora del **cangrejo** (seis máscaras sin amputaciones), medir siluetas y apoyo; solo entonces crear secuencias de fotogramas intermedios y registrar una captura de revisión. Continuar después con los otros tres conservando la referencia.

## Microtarea 2 — inspección de máscaras (2026-11-08)
- Se ensayó una reordenación de poses del cangrejo mediante edición visual.
  **DESCARTADA** por introducir ruido de píxeles sueltos en áreas transparentes.
  No se guardó como sprite definitivo ni se sobrescribió el original aprobado.
- Nuevo comprobador de solo lectura `scripts/check_arga_enemy_atlases.py`,
  commit `ad9a7e7`. Marca visualmente las celdas cuyo contenido opaco
  llega a menos de 8 px del borde de un sexto (362 px) de lámina.
- Resultado de análisis alfa efectuado sobre los cuatro originales locales:
  cangrejo celdas **3, 4, 5**; pescador **1–6**; gamberro **2, 3, 4, 6**;
  trucha **1–5** requieren inspección de recorte y/o accesorios.
  Estos son **avisos de seguridad**, no demostración de amputación; no cortar
  los atlas por sextos sin resolución del conflicto.
- Siguiente acción: aislar siluetas por transparencia y recuperar las partes
  que atraviesan límites. Empezar por cangrejo, comparar cada una de sus
  seis poses con la imagen aprobada, y solo aprobar el atlas cuando esté limpio.
  No hay integración a Flutter ni cambio en capítulos existentes.

## Microtarea 3 — cangrejo, reposo aislado (2026-11-08)
- Extraída una versión candidata del primer estado (reposo frontal), con
  separación amplia y transparencia, a partir de la imagen artística aprobada.
- **Solo candidata, no validada para juego**, 1024×1024: 
  `assets/images/arga_rc7/enemies_candidates/cangrejo_reposo_aislado_candidate.webp`,
  Git blob `57a64a1de1c021723d2242ba87d376b9a63d80ee`,
  commit `27053b0`. Integridad de subida verificada mediante SHA Git.
- Falta comparar cuantitativamente la silueta y paleta con la pose 1 de la
  referencia, reducir al tamaño real sin suavizar píxeles, alinear los pies
  y crear los otros cinco estados limpios. No registrar este fotograma como
  aprobado ni usarlo en `StagePainter` aún.

## Microtarea 4 — poses aisladas de movimiento y ataque (2026-11-08)
- Dos candidatos **sin sustituir originales** guardados en commit `f06a479`:
  - `assets/images/arga_rc7/enemies_candidates/cangrejo_caminar_aislado_candidate.webp`
    — Git blob `5ba0830c536218156829477796a3bdffff9bfc13`.
  - `assets/images/arga_rc7/enemies_candidates/cangrejo_ataque_aislado_candidate.webp`
    — Git blob `edfc77fd5cdd9dabd3899fb0373c24f78f4a3113`.
- Ambos archivos son **1254×1254 RGBA con alpha** y la máscara opaca visible
  queda dentro del lienzo: caminar bbox (181,399)-(1067,930);
  ataque bbox (164,398)-(1089,899). Reposo previo también 1254×1254,
  bbox (188,374)-(1066,914). SHA Git local y remoto coincide en ambos.
- Comparación artística visual preliminar: postura lateral y pinzas claras,
  mismo cangrejo rojizo de referencia; no hay ratificación final de
  proporcionalidad ni escala en StagePainter. Los tres siguen **CANDIDATOS**.
- Faltan estados de alerta, impacto y derrota, así como los intermedios;
  el objetivo siguiente es completar estos tres conservando imagen original,
  limpiar efectos ajenos al cuerpo y después definir atlas homogéneo sin cortes.
