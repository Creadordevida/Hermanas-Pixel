# Las aventuras de Miren y Sara — prueba Android 0.8.0

**Proyecto Flutter, diseñado para instalarse en Android mediante GitHub Actions.**

## Base y fidelidad visual

Esta entrega CONSERVA SIN CAMBIOS los doce PNG originales de los personajes y el fondo inicial de la **0.7.1**, la versión que funcionó en el móvil y cuya calidad gráfica fue aprobada. Las poses no se han sustituido por figuras simplificadas. La pantalla de inicio utiliza la composición aprobada con el edificio gris, Miren, Sara y el padre sin coche superpuesto. El título queda completo dentro del área horizontal.

El distintivo inferior se ha preparado a partir de una referencia TWC de la pantalla de TIKU. Es una extracción rasterizada (no un archivo vectorial corporativo), que convendría sustituir en una versión comercial por el archivo maestro oficial.

## Cambios incluidos respecto a la 0.7.1

1. **Pantalla de inicio** con «Nueva partida» y «Continuar». El botón Continuar está deshabilitado cuando todavía no hay partida guardada.
2. **Guardar partida localmente** con `shared_preferences`, autoguardado durante el recorrido, puntos de control y al cerrar/pausar; reanudar desde el capítulo y el progreso guardados. Nueva partida solicita confirmación si existe guardado.
3. **Selección de protagonista antes del capítulo**, Miren o Sara, sin cambiar durante el nivel. Dos corazones por hermana.
4. **Movimiento independiente**: las órdenes de movimiento, salto y ataque son únicamente para la protagonista seleccionada. La otra sigue con retraso y movimiento propio. El padre **solo aparece en la conversación inicial**, no en el gameplay.
5. **Cuatro tramos jugables con transiciones de capítulo**: salida de casa, Ayuntamiento de Pamplona, Calle Estafeta y quiosco de Plaza del Castillo. No se representan Ayuntamiento y quiosco como edificios contiguos. Más monedas y obstáculos.
6. **Primer enemigo: perro**: patrulla, detecta, persigue, intenta morder, quita un corazón (con invulnerabilidad temporal), recibe impactos y queda aturdido/derrotado. Pose/animación revisada: reposo, andar, alerta, carrera, mordisco, impacto, aturdimiento y derrota. La derrota es cómica, sin violencia gráfica explícita.
7. **Miren lanza balón** y **Sara lanza peine**. Ambos son proyectiles diferentes con colisión contra el perro y las cajas.
8. **Icono Android propio** en resoluciones mipmap y modo adaptativo. El nombre visible pasa a «Miren y Sara» para caber bajo el icono.
9. **Identidad visual de The Wolf Company** pequeña y centrada en el pie del menú.

### Controles

- Flechas inferiores izquierda/derecha: mover solo a Miren o Sara.
- Flecha superior (inferior derecha): saltar.
- Botón de balón o peine: atacar (dependiendo de protagonista).
- Pausa (parte superior derecha): reanudar o volver al menú, conservando progreso.
- Al superar cada capítulo aparece la opción de volver a elegir protagonista.

### Estructura

- `lib/main.dart`: código jugable, pantallas, física, guardado, IA del perro y dibujado.
- `assets/images/frames`: los sprites aprobados de padre, Miren y Sara.
- `assets/images/dog`: sprites nuevos, ocho estados diferenciados.
- `assets/images/level_*`: los fondos para cada tramo.
- `assets/images/title_approved.png`: pantalla de inicio aprobada.
- `assets/images/brand_logo_twc.png`: insignia TWC basada en TIKU.
- `launcher/res`: recursos nativos del icono (se copian después de `flutter create`).
- `.github/workflows/build.yml`: compilación APK release con análisis y tests.
- `qa/verify_resources.py`: comprobación local de PNGs y recursos.

## Subir a GitHub

**Primero sube a la raíz del repositorio todo el contenido del ZIP descomprimido. No subas el ZIP cerrado ni una carpeta contenedora.** Mantén `lib/main.dart`, `pubspec.yaml`, `assets`, `launcher`, `qa` y `test`.

La carpeta `.github` suele dar problemas al subirla desde el navegador: abre en GitHub `.github/workflows/build.yml`, pulsa el lápiz y pega el contenido del `build.yml` del ZIP. Si todavía no existe, `Add file > Create new file` y escribe el nombre `.github/workflows/build.yml`.

En **Actions > Compilar Miren y Sara 0.8.0** comenzará la compilación después de hacer commit. Si termina en verde, descarga el APK en **Artifacts** bajo el nombre `Las-aventuras-de-Miren-y-Sara-0.8.0`.

Si falla `flutter analyze`, envía el error del primer paso rojo; NO cambies nada al azar. Para versiones futuras, una firma estable de aplicación será necesaria si quieres actualizar un APK sin perder guardados. En este prototipo puede ser necesario desinstalar el APK anterior si las firmas de compilación difieren.

## Revisiones realizadas, y límites

Se ejecutaron scripts locales que verifican la integridad de 30 imágenes, los iconos Android, estructura, pantalla y referencias, así como una auditoría visual de los sprites del perro y escenas. Se compararon los 13 recursos aprobados de 0.7.1 con los originales: son idénticos byte a byte.

**No se dispone de Flutter/Dart ni de un emulador Android en el entorno de preparación.** Por tanto, la compilación real, el analizador Dart y los tests Flutter deben ejecutarse en GitHub Actions. Las vistas previas adjuntas son composiciones con assets reales, no capturas del APK.

La demo es una prueba ampliada, no un juego completo: los fondos nuevos provienen de ilustraciones conceptuales y deben revisarse en el móvil. Los ataques de las hermanas utilizan efectos y las poses aprobadas existentes: todavía no cuentan con secuencias de lanzamiento dibujadas a mano fotograma a fotograma.
