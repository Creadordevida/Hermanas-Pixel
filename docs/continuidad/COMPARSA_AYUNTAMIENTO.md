# Comparsa de la Plaza Consistorial

Referencia aprobada el 9 de noviembre de 2026. Lámina revisada «Gigantes pixelados en la plaza.png». SHA-256 `b0a9fd3cb14d9508849c96e5a69a9bdf82e17d5d7c1315b781d191b679cf755d`. El gigante lleva peto plateado, banda dorada y faldón azul con el portador visible. Caravinagre lleva casaca verde bordada, tricornio y gesto agrio. El zaldiko lleva rojo y amarillo, cabeza oscura baja, crin larga y espuma amarilla al cordón. Ubicación exclusiva en el Ayuntamiento, índice 1. Primero Caravinagre, luego zaldiko y un gigante hacia el final.

## Contrato de animación

Atlas transparente con cuatro columnas y seis filas, celda 320 × 288, pivote (160, 274), una escala por personaje. Cada fila se reproduce de izquierda a derecha.

| Fila | Gigante | Caravinagre | Zaldiko |
| --- | --- | --- | --- |
| 0 | Reposo con portador visible | Reposo y gesto agrio | Reposo con bola colgando |
| 1 | Pasos con apoyo alterno | Marcha y oscilación de cabeza | Trote corto con balanceo de crin |
| 2 | Planta un pie, inclina figura y recoge faldón | Amago de hombro con espuma atrás | Se inclina y arrastra la bola hacia atrás |
| 3 | Giro, barrido bajo y remate | Golpe frontal corto y retirada | Carrera, frenada y paso de la bola hacia delante |
| 4 | Dos de recuperación y dos de impacto | Dos de recuperación y dos de impacto | Dos de recuperación y dos de impacto |
| 5 | Inclina la figura y el portador la baja | Tropieza y se sienta aturdido | Se frena, se agacha y queda apoyado |

Daño único ligado a la pose de contacto y esquivable con un salto. El gigante abre una ventana para el balón o el peine tras el giro. El zaldiko fija el rumbo antes de correr. Las trayectorias de espuma y el faldón se validan con el reloj de la animación. Microfases por personaje: guardar atlas, integrar y probar con las dos protagonistas, inspeccionar StagePainter a 1000 × 450, corregir, activar y verificar el commit. Android físico queda como validación separada.

## Gigante, primera microfase

Hoja de origen de 24 poses, SHA-256 `0d037a486d12f9cd926f70d5afd2b21fbe7991077e97fe1bd33e3add028f0c06`. Derivado `assets/images/enemies_new/comparsa_gigante.png`. Máscara alfa binaria, pivote por apoyo y escala común de 258 px en reposo. Se conserva la apertura frontal con el portador. Integración y prueba Flutter pendientes en este punto.
SHA-256 del atlas: `8b9ab0ec679e801c198ffcc384f8f825c970e9068084fa119a9367f8e3356153`.
