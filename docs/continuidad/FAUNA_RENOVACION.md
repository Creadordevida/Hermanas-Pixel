# Renovación de perros y paloma

## Perros

Referencia original preservada en `assets/images/dog/`. El marrón mantiene
pelaje castaño, pecho claro, cola curvada, patas cortas y tronco compacto.
El dálmata tendrá patas largas y manchas de posición coherente. El dóberman
tendrá perfil más alto, pecho profundo y pelaje negro y fuego.

| Fila | Columnas | Pose y fase |
| --- | --- | --- |
| 0 | 0–3 | Reposo, respiración, parpadeo, orejas levantadas para alerta |
| 1 | 0–3 | Paseo con cuatro apoyos alternos |
| 2 | 0–3 | Galope con extensión y recogida alternas |
| 3 | 0–3 | Preparación inicial y agachada, contacto, recuperación |
| 4 | 0–3 | Retroceso y desequilibrio, aturdimiento y recuperación |
| 5 | 0–3 | Tropiezo, caída, apoyo de costado y reposo final |

Celda 152 × 108 a escala de juego, anclaje horizontal 76, pies en 94.
Los dos primeros fotogramas de mordisco se muestran hasta 0,24 s. El tercero
coincide con el único contacto, que comprueba dirección, alcance y altura.
El cuarto muestra recuperación. Paseo y galope tienen cadencias distintas.

## Paloma

Conservar cuello azulado, cuerpo gris claro, bandas oscuras en ala y
patas rosadas. Una sola identidad, escala y dirección para suelo y aire.

| Estado | Fases |
| --- | --- |
| Reposo posado y paseo | Pausa, cabeceo y apoyos alternos |
| Despegue | Agachada, apertura de alas y subida |
| Batida y planeo | Subida de ala, paso neutro, bajada, extensión y planeo |
| Aviso, picado y recuperación | Cabeza hacia abajo, alas recogidas, extensión y repunte |
| Aterrizaje | Alas de frenado, patas extendidas y vuelta al reposo |
| Impacto y caída | Pérdida de sustentación, descenso y contacto con el suelo |

El pivote de vuelo enlaza con el apoyo en tierra. El picado conserva el alcance
y enfriamiento de referencia y avisa antes de infligir daño. El impacto de un
proyectil cancela el ataque y hace que el ave caiga antes de desvanecerse.
## 2026-11-09 — Fauna: perro marrón integrado y probado en Flutter

El atlas de `7c47b577` ya se carga en la ruta normal. Mordisco con dos poses de preparación, un solo contacto frontal a los 240 ms y recuperación. Paseo y carrera separados, pivote de pies común y caja de impacto ajustada al cuerpo. Flutter 3.47.8 pasó las 9 pruebas de fauna, incluida la escena con marcha, mordisco, esquiva, balón y peine con Miren y Sara. Capturas auténticas de StagePainter de 1000 × 450 inspeccionadas. Los originales siguen disponibles. Una prueba antigua de `dog_mechanics_test.dart` espera siete capítulos y la rama tiene ocho. Pendiente validar en Android. Siguiente animal: dálmata.


## 2026-11-09 — Fauna: dálmata integrado y probado en Flutter

Atlas RGBA de 24 poses `assets/images/dog/dalmatian_atlas.png` (SHA-256 `7dd7e4d5818725c82100488b9c2bc52e940bec06a478571a5999657da39151ad`). Pata larga, torso estrecho y manchas coherentes. Marcha de 5 fps y carrera de 8 fps, con velocidad y resistencia originales. La zona de impacto del proyectil sigue el cuerpo más alto. Los golpes finales de ambos perros muestran primero retroceso y luego caída. Nueve pruebas Flutter de fauna y siete de recursos superadas. Inspeccionadas capturas reales de StagePainter a 1000 × 450. Queda Android. Siguiente animal: dóberman.


## 2026-11-09 — Fauna: dóberman integrado y probado en Flutter

Atlas RGBA de 24 poses `assets/images/dog/doberman_atlas.png` (SHA-256 `577f029dfd354ec4100c8c36aafef4b0a3c36afacac5525bcf37ede6b2e01fb4`). Pecho profundo, orejas erguidas y galope a 12 fps. Mantiene velocidad, detección y dos impactos. Prueba real con Miren y Sara: primer proyectil aturde y el segundo derrota, con aviso y esquiva de mordisco. Nueve pruebas Flutter de fauna y siete de recursos superadas. Revisadas capturas StagePainter 1000 × 450, incluido aturdimiento. Queda Android. Siguiente animal: paloma.


## 2026-11-09 — Fauna: paloma integrada y validación conjunta Flutter

Atlas RGBA de 32 poses `assets/images/enemies_hifi/pigeon_atlas.png` (SHA-256 `c94dda99e5ab55d6299dd086807c657b9d28e066e40b16d757a19dde6b2e3135`). Una orientación de referencia y pivote común para suelo y aire. Despegue con agachada, vuelo con batida y planeo, aviso de picado de 220 ms y dirección comprometida, recuperación de altura, aterrizaje con patas extendidas y caída visible hasta tocar suelo. La caja de impacto sigue el cuerpo y deja libres las puntas de ala. Se conserva el arte anterior. Diez pruebas Flutter de fauna, ocho de PNG y análisis Dart focalizado superados. StagePainter 1000 × 450 inspeccionado en los cuatro animales, con ataque, esquiva y derrota con Miren y Sara. Las mejoras están activas en la ruta normal de esta rama. Queda probar en el Redmi Note 14 la próxima compilación Android, incluidos controles, legibilidad y fluidez.

