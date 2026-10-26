# Guía para probar Las aventuras de Miren y Sara — 0.9.0 RC8 REV2

## Lo que estás descargando

`Las_aventuras_de_Miren_y_Sara_0.9.0_RC8_REV2_GITHUB_COMPLETO.zip` contiene **código
completo y gráficos** para GitHub. **No es el APK**. GitHub Actions lo construye
automáticamente al subir estos archivos al repositorio.

## Actualizar con GitHub Desktop (Windows)

1. Guarda una copia de la carpeta del proyecto anterior por seguridad.
2. Descomprime el ZIP en una carpeta nueva.
3. Abre tu repositorio habitual en GitHub Desktop y selecciona
   **Repository → Show in Explorer**.
4. Copia el **contenido interior** de la carpeta descomprimida a la **raíz**
   del repositorio. Allí deben quedar `pubspec.yaml`, `lib`, `assets`,
   `.github`, `test`, `qa`, etc., sin una carpeta adicional `game` o `RC8`.
5. Acepta reemplazar los archivos del juego. **No borres `.git`** ni elimines
   otros archivos del repositorio que no estén incluidos en esta versión.
6. En la pestaña **Changes** comprueba que aparecen los nuevos recursos
   `chapter1`, `chapter45`, `enemies_hifi`, el código `lib` y `.github`.
7. Escribe `Miren y Sara 0.9.0 RC8 REV2 - capturas y CI` como mensaje,
   pulsa **Commit to main** y después **Push origin**.

## Descargar el APK

1. En GitHub web, entra en **Actions**.
2. Abre **Miren y Sara 0.9.0 RC8 REV2 - APK Y CONTROL VISUAL**.
3. Selecciona la ejecución más reciente. Ahora aparecen **dos trabajos**:
   `android-apk-candidato` (APK y mecánicas) y `qa-graficos-flutter`
   (capturas y revisión de escenas). Se muestran sus resultados por separado.
4. En **Artifacts**, descarga **`Miren-y-Sara-0.9.0-RC8-REV2-APK-PRUEBAS`**.
5. Descomprime ese archivo: dentro encontrarás **`app-release.apk`** para
   transferir al teléfono e instalar como APK de prueba.
6. Si alguna captura falla, GitHub puede mostrar la ejecución global en
   **rojo**, aunque el trabajo Android esté verde y el APK esté disponible.
   Eso significa *candidato para investigar*, no versión aprobada.
7. Si aparece, descarga también **`Capturas-REALES-Flutter-0.9.0-RC8-REV2`**.
   Esas sí son pantallas del motor que podemos analizar juntos.

## Qué revisar en el teléfono

| Lugar | Comprobar |
| --- | --- |
| Inicio y mapa | Portada, botones, capítulos y continuidad de partida |
| Capítulo 1 | Cuatro ambientes, uniones, objetos y suelo sin saltos |
| Rata y gato | Detalle, tamaño, movimiento, colisión y derrota |
| Perros | Patrulla, alerta, persecución, mordida visible y daño |
| Palomas | Despegue, batido, vuelo, picado, aterrizaje y caída |
| Miren y Sara | Impulso, subida, caída, aterrizaje y sombra sobre suelo/plataformas |
| Campo de entrenamiento | Acceso, ejercicios, gradas, césped y uniforme de Miren |
| Escuela de danza | Recepción, estudio, escenario, parquet y uniforme de Sara |
| Rendimiento | Fluidez, botones táctiles, texturas y posibles bloqueos |

Si detectas un fallo, envíame una **captura o vídeo corto** e indica capítulo,
posición aproximada y si se repite. Así podremos estudiar el problema con
evidencia del juego real y corregirlo en la siguiente iteración.

**Limitación:** el entorno de elaboración no tenía SDK Flutter ni emulador.
Las pruebas Python locales no garantizan una compilación ni aprobación visual.
Esta RC8 **no debe publicarse todavía en Google Play**.
