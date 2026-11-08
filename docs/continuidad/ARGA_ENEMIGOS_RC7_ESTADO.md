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
