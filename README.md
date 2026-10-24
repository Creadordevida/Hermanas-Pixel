# Dos hermanas — Prueba Android 0.1.0

## Objetivo
Prueba temprana para revisar en el teléfono el aspecto visual de los tres personajes, la fachada familiar, los diálogos, el cambio entre hermanas y los controles táctiles. **No es un juego terminado ni una reproducción definitiva de las ilustraciones conceptuales.**

## Compilación en GitHub
1. Crear un repositorio vacío en GitHub.
2. Subir el **contenido** de esta carpeta (incluida `.github/workflows/android.yml`).
3. Abrir **Actions > Compilar APK Android** y esperar la compilación.
4. Descargar el artefacto `Hermanas-Android-0.1.0`, descomprimirlo e instalar `app-release.apk` en el móvil.
5. Si GitHub solicita habilitar Actions, habilitarlo en el repositorio.

## Controles
- Flechas izquierda/derecha: desplazamiento.
- Flechas verticales: salto.
- Icono de intercambio: alternar entre las dos hermanas.
- Icono balón/estrella: efecto temporal de habilidad (aún no mecánica definitiva).
- Tocar el diálogo: continuar.

## Limitaciones conocidas (importante)
- No se ha podido compilar ni probar el APK en este entorno porque Flutter no está instalado aquí. El workflow intentará compilarlo en GitHub.
- Las imágenes de los personajes se han extraído de una lámina conceptual aprobada. **Son recortes estáticos, no spritesheets animados**, por lo que el movimiento es una primera aproximación visual con un pequeño balanceo. Esto NO demuestra aún la calidad de las animaciones finales.
- El edificio es una versión pixelada de la fotografía original, no una reconstrucción artística completa en tiles.
- Los personajes llevan la ropa de ballet y fútbol de la lámina. Las vestimentas casuales quedan pendientes de convertirse en recursos definitivos.
- La habilidad es un efecto visual temporal, no una acción con colisiones. No hay enemigos, puntuación ni guardado.
- Los obstáculos son elementos visuales; no se han implementado colisiones de plataformas todavía.
- Esta versión permite validar el flujo técnico y la escala de los personajes, pero **no alcanza todavía la calidad gráfica jugable prometida como objetivo**.

## Tecnologías
Flutter puro con `CustomPainter`, sin bibliotecas externas de videojuegos. Si el prototipo se aprueba, podemos integrar Flame para las físicas y animaciones definitivas.
