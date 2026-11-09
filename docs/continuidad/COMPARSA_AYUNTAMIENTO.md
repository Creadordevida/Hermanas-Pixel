# Comparsa de la Plaza Consistorial

Referencia aprobada el 9 de noviembre de 2026. Lámina revisada «Gigantes pixelados en la plaza.png». SHA-256 `b0a9fd3cb14d9508849c96e5a69a9bdf82e17d5d7c1315b781d191b679cf755d`. El gigante lleva peto plateado, banda dorada y faldón azul con el portador visible. Caravinagre lleva casaca verde bordada, tricornio y gesto agrio. El zaldiko lleva rojo y amarillo, cabeza oscura baja, crin larga y espuma amarilla al cordón. Ubicación exclusiva en el Ayuntamiento, índice 1. Primero Caravinagre, luego zaldiko y un gigante ante la fachada consistorial, en el centro del recorrido existente.

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

## Gigante, integración y revisión real

El PNG indexado del primer punto de control dejaba un rectángulo negro en Flutter. Se sustituyó por RGBA de 8 bits por canal con alfa binario y el mismo arte. El atlas de producción es WebP sin pérdida con los mismos píxeles RGBA. SHA-256 `64c13fc7592913c9db5acafd1953a25cffb4748e9f16e7008bf02803cd58f933`. Revisado en StagePainter de 1000 × 450, con el portador visible durante el giro y al bajar la figura tras la derrota. Tres impactos durante recuperación. El encuentro se ubica en x=18520 para aprovechar la fachada histórica existente, situada a mitad del capítulo, y se despeja el espacio de combate inmediato. Las pruebas de Flutter con Miren y Sara verificaron aviso, contacto único, esquiva y derrota. Activado en la ruta normal del Ayuntamiento. Siguiente microfase: atlas e integración de Caravinagre.

## Caravinagre, atlas

Hoja fuente SHA-256 `2db347ca4a07701a0ffa223623f1b1d022c1535500eea83739a89410ec65342e`. Derivado `assets/images/enemies_new/comparsa_caravinagre.png`, SHA-256 `e91ba1fddba1d5f93c60ee91ac277a8921334c176ae7fe6aad87b09792af3bbc`. Altura de referencia 149 px, gesto agrio, tricornio, casaca verde y espuma amarilla. Inspeccionadas las 24 celdas y la extensión frontal de la espuma. El recorrido de la espuma se mantiene dentro de una celda de producción. Siguiente microfase: guardar el atlas del zaldiko y verificar ambos combates con el reloj del motor.

## Zaldiko, atlas

Hoja fuente SHA-256 `e3ede39765e8d9422f36158aedb406c65e86ecfd533a5fb662fb710a2a8a59a7`. Derivado `assets/images/enemies_new/comparsa_zaldiko.png`, SHA-256 `ac4c039acc60b854028d86fc7c031e7c9931c5ead948e25c3364c8dc1fa400f2`. Altura de referencia 153 px. Se separaron siluetas completas de la rejilla original para conservar bola y cordón. Se eligió la extensión baja para contacto y la extensión alta para remate sin segundo daño. Las 24 celdas tienen alfa binario y apoyo en y=274. Siguiente microfase: comprobar los tres en el capítulo real, con ambos proyectiles y capturas 20:9.
