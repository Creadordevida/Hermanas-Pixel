# Hermanas Pixel 0.7.0 — demo gráfica Android

Proyecto Flutter de plataformas 2D para **Android horizontal**, preparado para compilarse con GitHub Actions. No es un mockup de imágenes fijas: los actores, monedas, cajas y balón se renderizan como entidades independientes.

## Cambios sobre las versiones 0.6.x

- **12 sprites RGBA nuevos**: 4 poses por personaje (espera, 2 pasos diferentes y salto). Se han extraído de una hoja de producción elaborada según la referencia aprobada, no de las figuras simplificadas de las versiones 0.4–0.6.
- Rostros con ojos verdes, peinados, ropa, altura relativa y colores correspondientes al objetivo visual.
- Escenario ilustrado independiente de los personajes: fachada con balcones, vegetación, farolas en escala coherente, acera, fachada y vehículo plateado.
- Suelo y cajas con colisión; saltos sometidos a gravedad; controles táctiles; cambiar entre hermanas; padre y hermana no seleccionada con seguimiento independiente.
- Monedas, balón que destruye cajas y doble salto de la bailarina; una zona final de prueba cerca del coche.
- Test de carga de recursos Flutter y verificación Python de PNG previa a compilar.

## Estado de la revisión

✅ Se comprobó localmente la presencia y validez de los archivos PNG, CRC, dimensiones RGBA, independencia de los 12 fotogramas, márgenes transparentes y representación de los 3 personajes sobre el escenario.

✅ Se ejecutó `python3 qa/verify_resources.py` satisfactoriamente.

⚠️ **No se ha compilado ni probado el APK en un dispositivo Android desde este entorno.** Los tests de Flutter y el análisis Dart los ejecutará el workflow de GitHub Actions. No presentar estas comprobaciones como sustitución de la prueba real.

⚠️ Para no introducir rostros deformados, esta demo utiliza solo **2 dibujos de paso distintos por personaje**, además de espera y salto. Son sprites de gran calidad visual, pero aún no son ciclos largos de animación de 6–8 dibujos independientes. El salto tiene una pose, no un arco entero. Es una demo gráfica y física corta, no un nivel completo de varios minutos.

⚠️ El edificio es una interpretación artística del objetivo aprobado, no una copia exacta de la fachada real original.

## Subir a GitHub

1. Descargar y **descomprimir** el ZIP.
2. En el repositorio `Hermanas-Pixel`, sustituir los anteriores `lib/main.dart`, `pubspec.yaml`, `assets/images/` y `test/` por los nuevos. Evitar conservar sprites antiguos con nombres parecidos.
3. Para `.github`, como Windows suele impedir subir esa carpeta, ir al repositorio, abrir el archivo `.github/workflows/build.yml` en el editor web y sustituir **todo** su contenido por el de este ZIP. Si no existe, usar **Add file → Create new file** y poner el nombre `.github/workflows/build.yml`.
4. Si quedan otros archivos `.yml` dentro de `.github/workflows/` de versiones antiguas, desactivarlos o eliminarlos para no obtener dos APK diferentes.
5. Hacer **Commit changes**. Ir a **Actions → Compilar Hermanas Pixel APK**.
6. Confirmar que el test, análisis y compilación aparecen en verde. Descargar desde **Artifacts → Hermanas-Pixel-0.7.0-Android**.
7. Instalar el `app-release.apk` en el teléfono.

**Atención**: los archivos `pubspec.yaml` y `lib/main.dart` deben estar en la **raíz del repositorio**, no dentro de otra carpeta. Si se sube solo el ZIP, GitHub no podrá compilarlo.

## Controles

- Izquierda / derecha: caminar.
- Flecha arriba: saltar.
- ↔: cambiar de hermana.
- Balón (hermana mayor): disparo que puede destruir cajas.
- ✦ (hermana pequeña): segundo impulso de salto.
- El padre sigue como acompañante no jugable.

## Principios de diseño 16 bits

La SNES trabajaba con gráficos organizados en tiles pequeños y sprites independientes, con prioridades de capas y animaciones por fotogramas. Esta demo **se inspira** en esos principios artísticos, pero no limita la paleta ni la resolución al hardware original. Véase: https://snes.nesdev.org/wiki/Sprites y https://snes.nesdev.org/wiki/Tiles

## Estructura

```
.github/workflows/build.yml   -> GitHub Actions
lib/main.dart                  -> gameplay Flutter y pintado
pubspec.yaml                   -> dependencias y activos
assets/images/level_pixel.png -> fondo detallado, sin personajes
assets/images/frames/         -> sprites por personaje y pose
assets/images/crate.png        -> caja
assets/images/coin.png         -> moneda
reference/                     -> objetivos artísticos aprobados
qa/verify_resources.py         -> validación reproducible sin librerías
qa/sprite_audit.json           -> resultado de inspección de sprites
test/                          -> pruebas Flutter
```
