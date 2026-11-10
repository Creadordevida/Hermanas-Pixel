# Profesora del Colegio — renovación

## Microfase 1 — diagnóstico y contrato visual

Base verificada `a7383d5d7cc88432043a00d02b9a8fe0044e6dd4`. La ruta normal abre El colegio y crea 14 profesoras. En Flutter se probaron la goma y la derrota al tercer impacto con Miren y Sara. Cinco PNG actuales, cuatro poses de pie con la misma base de piernas y una derrota fija. El motor alterna fotogramas de pie durante el reposo, reutiliza uno en impacto y muestra la goma saliendo hacia el lado opuesto al brazo. La hoja aprobada `reference/profesora_colegio_arte_aprobado.png` fija gafas, moño castaño, traje morado, blusa blanca, tacones y examen con F roja.

El atlas candidato consta de 24 poses RGBA orientadas a la derecha. Se conserva la profesora como enemiga estática de proyectil y se dibujan apoyos distintos cuando prepara o ejecuta el lanzamiento.

| Fila | Poses | Contrato de juego |
| --- | --- | --- |
| 0 Reposo | 4 | Apoyo fijo, gesto de espera |
| 1 Preparación | 4 | Anticipación durante los 0,75 s anteriores a la suelta |
| 2 Suelta | 4 | Goma desde la mano en la primera pose y continuación del gesto |
| 3 Recuperación | 4 | Vuelve a la guardia durante la recarga |
| 4 Impacto | 4 | Retroceso y aturdimiento visibles |
| 5 Derrota | 4 | Desequilibrio, rodilla, caída y cuerpo apoyado en el suelo |

Se mantienen tres impactos para derrotarla, 3,6 s de recarga y los puntos de aparición. Siguiente acción: comparar los dibujos con el original, componer el atlas y auditar celdas y pivotes antes de activarlo.
