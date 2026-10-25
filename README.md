# Las aventuras de Miren y Sara — Android 0.9.0 (candidata de pruebas)

**Proyecto Flutter completo para compilar en GitHub Actions.** El ZIP contiene código fuente y gráficos; **NO** contiene un APK ya compilado. Esta es una candidata para pruebas, **no** una versión final aprobada o certificada.

## Qué incluye esta candidata

- Siete destinos en un mapa de Pamplona, accesibles desde el comienzo para probar libremente. Los destinos completados aparecen marcados; el progreso se guarda localmente.
- Cuatro capítulos urbanos preservados y ampliados, más fútbol de Miren, danza de Sara y el colegio compartido.
- Selección de Miren o Sara para cinco capítulos; el fútbol exige Miren y la danza exige Sara.
- Dos corazones para la protagonista. Balón de Miren y peine de Sara con sus iconos respectivos.
- Obstáculos adaptados: cajas para zonas iniciales, macetas en la plaza, conos en fútbol, bancos de ejercicio en danza y mochilas en el colegio. Mismo sistema de colisiones y roturas.
- Trece variantes de enemigos: tres perros, paloma, gato, estatua viviente, rata, futbolista, árbitro, bailarina novata, bailarín de break dance, alumno abusón y profesor exigente.
- Enemigos resistentes con 2 o 3 golpes donde se acordó; ataques de tarjeta, zapatilla y borrador espaciados y con preparación.
- Animaciones y recursos visuales separados por tipo. Los sprites originales aprobados están conservados intactos.
- Nuevos ambientes de campo de fútbol, escuela de danza y tres zonas del colegio (pasillo, aula, informática).
- La hermana no seleccionada deja de seguir a la protagonista en el juego; tras la presentación, padre y otra hermana salen caminando de escena.
- Tramos de mundo más extensos, monedas, plataformas y guardado local. La extensión está diseñada para aproximarse a cinco minutos de jugabilidad, aún sin medir en móvil.

## Regla de preservación

Los recursos de personajes de la versión **0.7.1** y las pantallas/iconos aprobados en **0.8.0** se incluyen **sin modificar**. Se han creado archivos **derivados independientes** para trajes y enemigos. `qa/approved_hashes.json` contiene las huellas digitales SHA-256 de **31 archivos aprobados**, y `qa/check_090.py` las compara; cualquier modificación los hace fallar. Los archivos fuente del juego previo no se han reemplazado por ilustraciones genéricas.

## Cómo obtener el APK

1. Descomprime el ZIP y copia **su contenido** en la raíz del repositorio GitHub: `lib/`, `assets/`, `test/`, `qa/`, `launcher/`, `pubspec.yaml`, `.github/`.
2. Comprueba que `.github/workflows/build.yml` queda en esa ruta. Puede ser necesario editarlo/crearlo directamente en GitHub si el navegador oculta carpetas con punto inicial.
3. Haz commit en la rama `main` o ejecuta manualmente el flujo de Actions **Compilar Miren y Sara 0.9.0**.
4. El flujo comprueba la integridad, ejecuta `flutter analyze`, ejecuta `flutter test` y, **si todo pasa**, compila y publica `app-release.apk` en el artefacto **Las-aventuras-de-Miren-y-Sara-0.9.0**.
5. Instala el APK en Android horizontal. Verifica menú, mapa, siete capítulos, protagonista obligatoria de fútbol/danza, daños, proyectiles, guardado y salida a mapa.

**Actualizaciones:** el proyecto se genera con `flutter create` en Actions como la versión anterior. El sistema de firma del APK debe mantenerse estable para permitir actualizaciones sin reinstalar. Antes de sustituir un APK existente, realiza copia de seguridad si tienes progresos que quieras conservar. El código intenta leer el guardado antiguo 0.8.0 y trasladar los capítulos completados a la nueva pantalla de mapa cuando el sistema de Android conserva los mismos datos de la aplicación.

## Verificaciones locales efectuadas

- `python3 qa/verify_resources.py` — OK; comprobación estructural PNG y assets base de 0.8.0.
- `python3 qa/check_090.py` — OK; validación de **31 hashes** aprobados y recursos de la 0.9.0.
- Vista estática compuesta con los archivos reales: `qa/vista_recursos_090.jpg`. **NO es una captura de una sesión Flutter o de un APK.**

## Limitaciones pendientes, importantes para evitar falsas garantías

- El entorno de preparación **no dispone de Flutter/Dart ni emulador Android**. No se ha ejecutado `flutter analyze`, `flutter test` ni una instalación real: esas pruebas se lanzarán en Actions, y es posible que descubran errores.
- Los decorados del campo, danza y colegio son **placas iniciales de integración**, no artes definitivos certificados. La escuela se ha dibujado como entorno coherente, pero la fidelidad de las escenas debe juzgarse en la pantalla Android y mejorarse si no alcanza la de 0.7.1.
- Los **trajes** se han creado como transformaciones de sprites aprobados, preservando identidad/cara/cabello; el corte real de la camiseta de fútbol n.º 19 y el maillot de ballet puede requerir ilustración final fotograma a fotograma. No se han proclamado definitivamente aprobados.
- Las animaciones de las protagonistas y del padre preservan los **dos fotogramas aprobados** de andar, no ciclos nuevos de seis u ocho fotogramas. Los nuevos enemigos usan marcos separados; algunos son derivados de arte provisional o compuestos de forma programática. La animación real debe verificarse en marcha.
- El scroll aplica repetición de segmentos e integración suelo-mundo con una placa desplazada con parallax y capa jugable. **Todavía no implementa completamente los tres planos independientes y la variación escénica de un juego comercial**, ni se ha verificado la continuidad de todos los módulos.
- Duración objetivo: el mundo tiene 40 000 unidades a velocidad de 169 unidades por segundo (~3 min 57 s de carrera ininterrumpida, más saltos, obstáculos y ataques). Los **cinco minutos reales no están medidos**; serán un criterio de aceptación en dispositivo.
- No se han ejecutado tests dinámicos de daño, posicionamiento vertical, derrotas, transición entre capítulos ni latencia de botones. Evita publicar todavía en Google Play sin pasar las pruebas de aceptación.

Este README informa del estado real para que no confundamos **preparar el proyecto** con **certificar la calidad final**.
