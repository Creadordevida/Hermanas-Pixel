# Miren y Sara — RC3 FIX1 | Corrección del fallo `flutter analyze`

## Fallo detectado en GitHub Actions

El trabajo `flutter-tests` se detenía en `flutter analyze lib test` porque el mapa constante `enemyVisibleBounds` en `lib/sprite_bounds.g.dart` contenía 10 claves repetidas de `goalkeeper_0` a `goalkeeper_4` (3 bloques de 5 definiciones, en lugar de 1).

## Corrección aplicada

- `lib/sprite_bounds.g.dart`: regenerado desde los canales alfa de los PNG, **55 claves únicas**, incluidas las 5 poses del portero.
- `tools/export_sprite_bounds.py`: el generador incluye al portero y rechaza cualquier clave repetida.
- `qa/ENEMY_VISIBLE_BOUNDS.json`: actualizado desde los PNG reales, con SHA-256 y límites alfa para las 55 poses.
- `qa/test_enemy_anchors.py`: prueba actualizada a 55 sprites.
- `qa/test_sprite_bounds_unique.py`: nueva prueba que comprueba ausencia de claves repetidas y correspondencia con los PNG.

Los recursos de arte, el escenario físico del capítulo 1, los controles y las mecánicas jugables **no se han modificado** en FIX1.

## Instalación (elige UNA de las dos opciones)

**Opción A: paquete completo**

1. Conserva el repositorio anterior o crea una rama de pruebas.
2. Descomprime `MIREN_Y_SARA_RC3_FIX1_GITHUB_COMPLETO.zip` y copia su contenido a la **raíz del mismo repositorio** que usaste para RC3, sobrescribiendo archivos.
3. GitHub Desktop → Commit → Push. Abre Actions y comprueba el nuevo `flutter-tests`.

**Opción B: parche pequeño (recomendado si ya tienes RC3 subido)**

1. Descomprime `PARCHE_MIREN_Y_SARA_RC3_FIX1_SOLO_CORRECCION.zip` sobre la raíz del repositorio RC3, conservando las carpetas `lib/`, `tools/`, `qa/`.
2. Sobrescribe los cuatro archivos existentes y añade el test nuevo y este informe.
3. GitHub Desktop → Commit → Push. Abre Actions y comprueba el nuevo `flutter-tests`.

**IMPORTANTE:** GitHub Actions ejecuta primero `flutter analyze lib test` y luego `flutter test`. Solo podrás confirmar que se ha superado el error de análisis cuando GitHub muestre el paso en verde. No se ha instalado Flutter ni probado el APK en el entorno en que se preparó esta corrección.

## Verificaciones locales ejecutadas

- `python3 qa/verify_resources.py`: superado.
- `python3 qa/check_ch1_physical_tiles.py`: superado, 72 teselas y 36.500 unidades.
- `python3 -m unittest discover -s qa -p 'test_*.py' -q`: **165 pruebas superadas**.
- Archivo generado: **55 claves únicas**, ninguna duplicada.

Si el siguiente paso de Flutter falla, consulta el nuevo registro; será un error distinto y habrá que corregirlo según el texto exacto que muestre GitHub.
