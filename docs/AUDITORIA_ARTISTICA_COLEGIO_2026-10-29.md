# Auditoría artística independiente — Colegio vs capítulo 1
Fecha: 29/10/2026 | Rama: `work/revision-visual-20261028-continuidad`

## Alcance y legitimidad de la evidencia

- **Evidencia REAL anterior a los cambios:** imágenes de `StagePainter` capturadas por Flutter y exportadas en el artefacto de Actions `12846407243`: `capitulo_1_inicio.png`, `barrio_residencial.png`, `barrio_paseo.png`, `barrio_cubierta.png`, `capitulo_7_inicio.png`. Las capturas enseñan código **anterior**, nunca se presentan como nuevos resultados.
- **Recursos originales comprobados directamente:** `assets/images/scenes/school.png`, `school_classroom.png`, `school_computers.png`. Los tres originales comparten el mismo módulo arquitectónico de ventanas/taquillas. No son tres edificios artísticamente diferentes.
- **Evidencia técnica previa:** artefacto `12841021198`: tres paneles por estancia con bytes de imagen coincidentes, y pupitre/monitor que retenían trozos de baldosas y paredes.
- **Imágenes nuevas:** NO regeneradas ni inspeccionadas aún. No se dispone de una copia de los PNG fuente privados dentro del runtime Python de esta sesión, y NO se han usado GitHub Actions por prohibición expresa.
- **Cero capturas inventadas:** contacto/comparativa local del material anterior no equivale a captura nueva de Flutter.

## Indicadores cuantitativos de las capturas antiguas

Se midió la región [x=25..775, y=48..360] de los PNG originales 800×450, excluyendo gran parte de la interfaz. Son **indicadores de complejidad visual**, NO puntuaciones estéticas automáticas.

| Captura auténtica | Diferencia media horizontal RGB | Diferencia media vertical RGB | Amplitud cromática media |
|---|---:|---:|---:|
| Cap. 1, inicio | 11.85 | 12.54 | 140.45 |
| Cap. 1, residencial | 11.82 | 12.38 | 140.09 |
| Cap. 1, paseo | 10.67 | 11.44 | 154.09 |
| Cap. 1, cubierta | 12.11 | 12.68 | 137.21 |
| Cap. 7, colegio antiguo | **5.42** | **8.23** | **55.48** |

Un colegio tiene legítimamente colores menos saturados que un parque, así que NO se exige igualar estos números. Pero confirman la sensación observada: fondo escolar más uniforme y pocos motivos arquitectónicos diferentes.

## Evaluación ARTÍSTICA provisional (SOLO capturas antiguas, nunca nuevos renders)

Escala subjetiva 0–10; las valoraciones derivan de las imágenes anteriores y causas detectadas en código. **No constituyen aprobación del nuevo colegio**.

| Criterio | Capítulo 1 anterior | Colegio anterior | Evidencia / causa |
|---|---:|---:|---|
| Calidad de ilustración | 9 | 6 | Cap. 1 muestra árboles, cielos, detalles de edificios; colegio, bloque de taquillas/ventanas recurrente |
| Detalle de arquitectura/decoración | 8 | 5 | Biblioteca, pizarras y rótulos existen, pero ventanas/taquillas dominan el recorrido |
| Variedad perceptible | 9 | 2 | Los tres paneles de cada estancia eran exactamente iguales |
| Profundidad/perspectiva | 9 | 5 | Cap. 1, múltiples planos. Colegio, paisaje al otro lado de cristales pero arquitectura repetitiva |
| Iluminación/color | 9 | 6 | Interior puede ser menos saturado, pero falta variedad local de iluminación |
| Integración mobiliario | 8 | 4 | Muebles recortados con baldosas/pared residual, superposición de elementos incrustados |
| Calidad de ventanas | N/A (exterior) | 6 | Marcos auténticos pero máscaras cromáticas parciales; necesita comprobación de nueva versión |
| Movimiento exterior natural | N/A (exterior) | **no verificado** | velocidades conocidas .30/.56, movimiento completo requiere secuencia de frames reales |
| Continuidad entre módulos | 8 | 4 | Doble pilar de 22+22px, uniones poco naturales, exceso de puerta repetida |
| Coherencia con Miren/Sara | 9 | 6 | Arquitectura escolar presenta menor riqueza de volumen que protagonistas |

**Conclusión de auditoría:** Antes de la corrección, colegio **INSUFICIENTE**, por razones verificables. Después de los cambios de este encargo, **NO VERIFICADO**; no se puede certificar la calidad de las 27 composiciones sin regeneración y revisión.

## Errores encontrados ahora y CORREGIDOS en GitHub

1. **Biblioteca y pizarras dibujadas dos veces:** ya existen integradas en `scenes/school*.png` y además se pintaban objetos separados en x1720, x15320 y x29820. Eliminadas las segundas copias de `StagePainter`.
2. **Pupitres fantasma en el panel mural:** el fondo de aula recortaba y dejaba los bordes superiores de mesas/ordenadores antiguos, que luego se superponían con los muebles físicos. Los últimos 27px de la pared de cada aula se sustituyen por la base **original del pasillo, a escala nativa**, conservando la arquitectura alta y las ventanas.
3. **Pilares duplicados:** los módulos escolares tenían 22px opacos en ambos extremos, creando 44px de poste por unión. Sustituidos por dos mitades 11+11px que comparten eje.
4. **Ordenador atravesando la mesa:** el monitor se colocaba a y233, con el teclado mucho más abajo que el tablero y286. Corregido a y198 para apoyar el teclado aproximadamente en y281 y la pantalla encima del pupitre.
5. **Recursos redundantes:** dejan de cargarse pizarras y biblioteca que ya aparecen en las ilustraciones; se reduce carga innecesaria de imágenes.
6. **Tests obsoletos:** se han actualizado los contratos Python que aún exigían la arquitectura anterior, y se añade comprobación real de los 27 paneles y su integridad.

## Lo conservado

- 27 paneles, nueve composiciones por zona, alternancia de tres fuentes reales aprobadas.
- Distribución de pupitres por patrones de módulo con módulos despejados.
- Fondo de cielo y arbolado procedente del capítulo 1; velocidades .30/.56 inalteradas, muros y muebles 1.00.
- Dibujos originales de Miren, Sara, mobiliario y arquitectura sin reemplazos geométricos simplificados.
- Guardado/colisiones/capítulos y rama principal no tocados.

## Puertas de calidad (ESTADO REAL)

| Puerta | Estado |
|---|---|
| Inspección de capturas anteriores Cap. 1 y colegio | REALIZADA |
| Análisis y eliminación de superposiciones en Dart | CAMBIO COMMIT |
| Eliminación de fragmentos de mobiliario en paredes | CAMBIO COMMIT |
| Continuidad de las velocidades de parallax en código | CONFIRMADA |
| Regeneración real 27 PNG con fuente `scenes/school*.png` | **PENDIENTE** |
| Ejecución de `qa/test_interiors_twc.py`, `qa/audit_school_visual_quality.py` | **PENDIENTE** |
| Inspección visual de 27 PNG y vistas sucesivas | **PENDIENTE** |
| Capturas auténticas StagePainter en 13 posiciones | **PENDIENTE** |
| Aprobación de igualdad artística con capítulo 1 | **NO APROBADO** |

Al autorizar un entorno de ejecución con los PNG fuente, regenerar, inspeccionar, corregir y repetir. El nuevo `qa/audit_school_visual_quality.py` registra métricas y etiqueta explícitamente la aprobación como bloqueada por falta de inspección, no como éxito artístico.
