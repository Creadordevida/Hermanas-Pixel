# Miren y Sara — 0.9.0-rc.2 · CANDIDATA PARA PRUEBA EN ANDROID

**ATENCIÓN:** Esta entrega es una candidata con las mejoras integradas, NO una versión artística/jugable aprobada. La prueba final de Android la hará el usuario.

## Instalación del proyecto para generar APK desde GitHub
1. Hacer una copia de seguridad del repositorio o crear una rama de pruebas `prueba-090` antes de reemplazar archivos; no borrar la versión 0.8.0 aprobada.
2. Descomprimir el ZIP; su contenido debe ir a la **raíz** del repositorio, no dentro de otra carpeta. Subir `lib/`, `assets/`, `qa/`, `test/`, `launcher/`, `pubspec.yaml`, `.github/` y restantes archivos.
3. **IMPORTANTE:** GitHub web limita la carga de muchas carpetas/archivos simultáneos. Usar GitHub Desktop (recomendado) o subir en tandas y comprobar que TODOS los recursos estén presentes. No basta con subir el `build.yml`.
4. Si el workflow oculto no se actualiza en GitHub, entrar en `.github/workflows/build.yml`, pulsar **Edit** y copiar el contenido del archivo de este proyecto. Confirmar cambios en la rama donde desees compilar. El workflow se activa en `main`; para probar en una rama distinta, modificar ese filtro o ejecutar manualmente desde Actions con esa rama.
5. En GitHub, abrir **Actions → Compilar Miren y Sara 0.9.0 CANDIDATA**. Ejecutar workflow si no se inicia automáticamente. Los trabajos de QA, Dart y Flutter deben estar en verde para obtener APK.
6. Descargar en **Artifacts** el ZIP llamado `Miren-y-Sara-0.9.0-CANDIDATA-APK`, extraer `app-release.apk` e instalarlo en Android.
7. En **Artifacts** puede aparecer `Capturas-REALES-Flutter-0.9.0-CANDIDATA`: provienen del propio renderizador Flutter (NO son imágenes externas). Abrir para inspeccionar los 7 fondos y el mapa.

## Cambios gráficos específicos desde la anterior candidata
- Miren fútbol: 4 poses reales cargadas por Flutter, parte superior amarilla con dorsal 19, pantalón corto azul y medias deportivas; rostro y contorno original conservados.
- Sara danza: 4 poses reales cargadas por Flutter, vestuario verde menta con medias rosa claro; rostro y contorno original conservados.
- Colegio: 3 PNG de fondo **diferentes** (pasillo, aula convencional y aula de informática) con suelo de baldosas texturizadas y misma altura de contacto.
- Tests automáticos verifican caras idénticas en los 8 sprites, siluetas de idéntica alfa, colores característicos, salas distintas y suelo alineado.

## Alcance de calidad de esta entrega
- Ejecutado localmente: integridad base 0.8.0, inventario de 117 referencias gráficas y 31 pruebas Python unitarias.
- No ejecutado localmente: Flutter analyze / flutter test / flutter build APK / partida en teléfono. El workflow se encarga de los 3 primeros al subir el proyecto a GitHub; la partida la realiza el usuario.
- No se han probado en dispositivo real los 7 niveles completos ni la duración de 5 minutos; no dar por aprobada la 0.9.0 hasta recibir resultado de esa prueba.
- El vestuario conserva las siluetas de las prendas originales; todavía debe juzgarse en el APK si representa con suficiente fidelidad una **equipación de fútbol** y un **maillot de danza**. No se sustituirá sin autorización por arte genérico. 

## Protección
La versión aprobada 0.8.0 permanece protegida por hash. El código del juego está en `lib/main.dart`. Los sprites originales no se han modificado. Este ZIP **no** incluye APK ya compilado: lo genera GitHub Actions.
