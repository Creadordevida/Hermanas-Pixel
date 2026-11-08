# Arga — auditoría de 96 fotogramas (08/11/2026)

**Alcance:** inspección visual de los cuatro atlas candidatos originales 4×6 (24 fotogramas cada uno), métricas de alfa y siluetas por cada celda mediante `qa/audit_arga_atlas_frames.py`, prueba preexistente de márgenes y diversidad `qa/check_arga_candidate_atlas.py`, más capturas reales de `StagePainter` ya conservadas en `qa/arga_rc7_flutter/`.

**No equivale a:** aprobación final de arte, QA Android, visionado temporal de 96 fotogramas a velocidad real ni autorización de distribuir atlas. Los recursos originales no se han modificado. En producción se mantienen condicionados a `TWC_ARGA_ATLAS_QA=true`.

## Hallazgos técnicos reproducibles

| Atlas candidato | Celdas ocupadas/24 | Pares adyacentes con cambio de silueta/18 | Sin píxeles alfa 255 | Fotogramas con >500 píxeles alfa tenue fuera de silueta |
|---|---:|---:|---:|---:|
| Cangrejo v1 q95 | 24 | 18 | 24 | 24 |
| Pescador v2 q95 | 24 | 18 | 24 | 11 |
| Gamberro v2 lossless | 24 | 18 | 24 | 22 |
| Trucha v3 lossless | 24 | 18 | 24 | 8 |

- Cada imagen mide 1024×1536; celdas de 256×256; `qa/check_arga_candidate_atlas.py` devuelve PASS en las cuatro.
- Canal alfa: rango 0–254 en todos los atlas. No hay alfa 255 en ninguna de las 96 celdas. `254/255` es prácticamente opaco y, aislado, **no demuestra defecto visible**.
- Se han comprobado las 72 transiciones adyacentes dentro de las seis filas de cada atlas mediante máscaras alfa>=128: ninguna es idéntica; cambios de silueta mínimos: cangrejo 869, pescador 460, gamberro 253, trucha 886 píxeles. No garantiza fluidez temporal.
- Las zonas de alfa entre 1 y 63 fuera del rectángulo sólido expandido 8px son una **alerta, no prueba de fallo**: pueden ser restos de fondo, halos, agua, destellos, líneas de acción o salpicaduras. Prohibido eliminarlas indiscriminadamente.
- Variación del apoyo visual dentro de la misma fila (margen inferior de silueta alfa>=128): cangrejo 0–11px, pescador 0–11px, gamberro 0–8px, trucha 0–15px. La trucha no se apoya en suelo, por lo que ese margen no es un pivote de pies. Pescador y niño requieren comprobar estabilidad en reproducción real antes de aprobar.

## Observación directa de cada atlas completo

- **Cangrejo:** 6 filas distingibles: reposo, avance lateral, alerta con pinzas elevadas, pinzamiento, impacto con chispas, derrota boca arriba. El último estado no conserva apoyo de patas por diseño. Siluetas completas a vista general; la fila de impacto es la más propensa a contaminación tenue.
- **Pescador:** reposo, marcha con botas, aviso, lanzamiento de caña, reacción y derrota sentado con caña en suelo. Caída no parece amputada a vista general. Algunas diferencias de reposo son pequeñas, pero medibles; evaluar su fluidez y el asentamiento de botas al reproducirlas.
- **Niño:** reposo, carrera, aviso, lanzar piedra, impacto y derrota sentado; vestimenta y rostro se mantienen reconocibles en las seis filas. Posibles trazos de fondo oculto/tenue alrededor de celdas; requiere composición sobre varios fondos antes de decidir si son visibles.
- **Trucha:** nado, aceleración con agua, alerta y curvatura, salto con salpicadura, impacto y derrota horizontal. Conserva la identidad de pez en las 24 celdas; los efectos acuáticos son necesarios y no se deben confundir con contaminación. La caída y la altura solo pueden aprobarse viendo el movimiento renderizado.

## Resultado y siguiente microfase

**Resultado:** estructura 4×6, presencia, variación alfa>=128 y primera revisión ocular de 96 poses **COMPROBADAS**. La calidad final de 96 fotogramas como animación jugable **NO APROBADA**.

1. Superponer cada atlas sobre un fondo real oscuro y otro claro, para discriminar halos de efectos legítimos; conservar efectos con identidad.
2. Renderizar secuencias de reproducción continuas (no solo pose suelta) para ver pies, cambios de escala, curvatura y caídas; corregir solo celdas concretas defectuosas.
3. Revisar las 96 celdas en tamaño objetivo respecto a Miren y Sara; validar alfa y fidelidad con la imagen aprobada.
4. Ejecutar Flutter QA tras cualquier cambio; no activar los atlas en versión jugable, no APK ni merge sin cierre formal.

`qa/audit_arga_atlas_frames.py --summary <cuatro rutas>` reproduce métricas; `qa/audit_arga_atlas_frames.py <rutas>` imprime los 96 registros detallados.
