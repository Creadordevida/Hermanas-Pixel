# Las aventuras de Miren y Sara — RC5 (uniformes integrados)

**Candidata de pruebas para Android mediante GitHub Actions; todavía no es un APK compilado ni está validada en teléfono.**

## Cambio principal frente a RC4

Se integran los **mismos diseños aprobados por el usuario**, separados directamente de sus ilustraciones fuente y guardados como **PNG transparentes que el motor Flutter carga de verdad**:

- **Miren (capítulo 5, fútbol):** camiseta amarilla/azul con dorsal 19, shorts azules, medias deportivas, zapatillas azules, **ojos marrones**. Cinco poses: quieta, caminar (2), salto y patada/ataque.
- **Sara (capítulo 6, danza):** maillot verde menta, medias rosa pálido y calzado rosa, ojos verdes. Cinco poses: quieta, caminar (2), salto y movimiento extendido para ataque con peine. Se ha reconstruido solo la punta del brazo derecho, que quedaba fuera de la lámina artística original.
- **En los capítulos restantes se conservan los sprites cotidianos originales.** No se han sobrescrito.
- Los botones de ataque muestran la pose especial durante unos 0,23 segundos.
- Se conservan las mejoras técnicas anteriores (capas, mapa aprobado, anclajes de enemigos, cinco corazones).

## Dónde comprobar los gráficos auténticos

- `assets/images/outfits/`: **10 PNG reales que usa Flutter**.
- `qa/uniformes/SPRITES_REALES_TRANSPARENTES.png`: comparación sobre fondo ajedrezado de los 10 PNG anteriores, **NO captura ingame**.
- `reference/MIREN_FUTBOL_OJOS_MARRONES_APROBADO.png` y `reference/SARA_DANZA_APROBADO.png`: referencias artísticas exactas del usuario.
- `qa/uniformes/MANIFIESTO_ORIGEN_Y_POSES.json`: dimensiones, orígenes y SHA-256 de cada recurso.
- `tools/integrate_approved_outfits.py`: proceso reproducible para extraer los sprites y completar una mano que estaba cortada.
- `test/qa_outfits_capture_test.dart`: **genera capturas verdaderas desde Flutter** (reposo y ataque de cada una), pendientes de ejecutar en GitHub Actions.

## Verificaciones

Las pruebas Python locales verifican la integridad de la base 0.8.0, la procedencia exacta del arte aprobado, los colores del uniforme, la transparencia y la presencia de los PNG. **No sustituyen la revisión visual en el APK real**. Flutter y Android deben compilarse y probarse mediante GitHub Actions y el teléfono.

Consulte `README_GITHUB_Y_PRUEBAS.md` antes de actualizar el repositorio.
