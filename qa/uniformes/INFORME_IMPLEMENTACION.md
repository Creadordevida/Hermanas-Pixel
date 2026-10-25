# Informe factual — uniformes RC5

## Procedencia y fidelidad

Los PNG de `assets/images/outfits` se extraen de las dos imágenes **aprobadas por el usuario** (`reference/*APROBADO.png`); no son sprites obtenidos pintando la ropa casual ni imágenes genéricas presentadas como juego. Cada archivo tiene su hash registrado en `MANIFIESTO_ORIGEN_Y_POSES.json`. Los ojos de Miren son marrones en el arte aprobado.

Hay cinco poses por personaje: `idle_0`, `walk_0`, `walk_1`, `jump_0`, `attack_0`. El motor `lib/main.dart` carga estos archivos exclusivamente en los capítulos 5 y 6. En el resto usa la ropa cotidiana de `assets/images/frames`. El ataque aparece durante una ventana breve tras pulsar el botón de balón o peine.

La última pose de Sara alcanzaba el borde de la hoja original con la mano derecha parcialmente cortada: se completaron explícitamente unos pocos píxeles de la mano. Se registra esta reparación en el manifiesto y no se afirma que sean píxeles extraídos intactos de la referencia.

## Pruebas efectuadas

- Hashes de ambas imágenes fuente congelados.
- Hashes y dimensiones individuales de diez sprites reales.
- Transparencia alfa, contorno, paleta de amarillo o menta, separación de fondos publicitarios.
- Integridad de recursos esenciales originales 0.8.0.
- Pruebas unitarias y de geometría del proyecto en Python.

## Pendiente explícitamente

- Compilación y análisis Flutter en GitHub Actions.
- Capturas auténticas del renderizador y aprobación visual de escala y anclajes dentro de cada escenario.
- Prueba jugable en Android.
- Más fotogramas de transición si la animación de caminar queda poco fluida; no se deben inventar sin aprobación.
