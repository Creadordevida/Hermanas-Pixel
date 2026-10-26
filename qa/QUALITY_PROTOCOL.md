# Protocolo de calidad — Las aventuras de Miren y Sara

**Referencia inalterable: versión 0.8.0**. Todos los recursos originales registrados en `baseline_080_sha256.json` son intocables sin una aprobación explícita y pruebas de regresión. La versión 0.9.0 fallida **NO** es fuente aceptada de gráficos nuevos.

## Puertas obligatorias (todas, no alternativas)

1. **Referencia y trazabilidad.** Cada recurso nuevo tiene ID, origen, hash SHA-256, capítulo y ficha de proporciones. La ilustración aprobada es referencia; solo el PNG realmente incluido en `assets/` puede presentarse como recurso del juego.
2. **Calidad visual.** Inspección de detalle, perspectiva, color, iluminación, textura, escala, identidad y compatibilidad con la 0.8.0. Métricas de entropía y bordes detectan degradaciones evidentes pero nunca certifican calidad artística. No permitir sustitutos geométricos ni siluetas de prueba.
3. **Animación.** Animaciones completas, sin fotogramas de otra persona. Revisar reproducción real a 30/60 FPS, pivotes, pies, orientación, transparencia, escala constante y continuidad. Las dimensiones distintas de PNG no significan automáticamente fallo: se exige que el alto corporal renderizado y su suelo ancla sean consistentes. Las poses horizontales tumbadas conservan escala vertical y no se normalizan a una altura fija.
4. **Integración.** El suelo jugable y el suelo representado coinciden, sin overlays de plataformas rudimentarias. Cámara/parallax, transiciones sin costuras, hitboxes alineadas, obstáculos temáticos integrados.
5. **Jugabilidad.** Caminabilidad, salto horizontal y vertical, sin rutas obligatorias imposibles. Completar cada capítulo con ambas heroínas cuando es compartido. Probar daño/invulnerabilidad, ataques, proyectiles espaciados, vida de enemigos, checkpoints, reinicios y guardado.
6. **Regresión.** Comparación de imágenes tomadas por el motor Flutter, con escena/cámara/tiempo/inputs reproducibles; informe de variaciones intencionadas, aprobado manualmente. Nunca confundir equivalencia de archivos con equivalencia de escenas.
7. **Validación de Android.** `flutter analyze`, `flutter test`, compilación y ejecución real en dispositivo. Guardar capturas y grabaciones obtenidas del APK identificando commit y SHA-256 del APK. Si no hay ejecución real, el estado permanece PENDIENTE y se BLOQUEA la versión.

## Política de imágenes

**No se publicará ninguna imagen en el chat diciendo que muestra el videojuego si no procede del renderizado real de la compilación indicada.** Las imágenes generadas separadamente no son prueba de la apariencia del juego. Las cuatro fichas de enemigos aceptadas están en `reference/ENEMIGOS_4_REFERENCIA_VISUAL_APROBADA_NO_USABLE_COMO_SPRITES.png`: deben guiar el arte, nunca pasar como captura del APK. Los ocho fallos ilustrados rechazados están en `qa/ejemplos_rechazados_090/`. Las capturas de las fases anteriores se pueden presentar como referencia histórica, identificadas como tal.

## Política de entregas

`qa/release_gate.py --strict` debe aprobar los elementos de `acceptance_090.json`, las pruebas y evidencias de ejecución. La falta de Flutter/Android no es una exención. **No distribuir como 0.9.0 validada hasta superar el control**. El fallo de una sola puerta paraliza la entrega.

## Disciplina de compilaciones y capturas (incidentes RC8, 26/10/2026)

El objetivo no es solo comprobar recursos, sino evitar rondas de errores
previsibles cada vez que el usuario sube un ZIP a GitHub:

1. **Preflight antes del ZIP:** ejecutar todas las pruebas Python, integridad
   de assets, verificación de archivos y sintaxis YAML. Si se dispone de SDK
   Flutter, ejecutar **también** `flutter analyze --no-pub lib`, `flutter analyze
   --no-pub test`, `flutter test` y `flutter build apk --release`. Si Flutter no
   está disponible, identificar explícitamente la compilación como **pendiente
   de CI**. Los tests Python nunca sustituyen la compilación Flutter.
2. **Capturas fiables:** las pruebas visuales de `HermanasGame` cargan más de
   130 imágenes. Deben tener una ventana de carga realista (90 segundos),
   reutilizar la misma instancia cuando capturan varios capítulos y usar
   `tester.runAsync` para `toImage`, PNG **y escritura de ficheros** (nunca
   `File.writeAsBytes` fuera del `runAsync` de las capturas), con tiempos
   límite diagnosticables. Este fallo hizo agotar diez minutos en el test de
   perros/palomas y ponía en riesgo también el test de saltos.
3. **No saturar el runner:** ejecutar las pruebas de capturas pesadas de forma
   secuencial (`flutter test --concurrency=1`) cuando varias pruebas carguen
   hojas de sprites y escenarios simultáneamente. Fijar un límite de tiempo
   global por paso, dejando visibles los errores concretos.
4. **Diagnóstico no engañoso:** generar el APK para pruebas después de aprobar
   el análisis de `lib`, antes de las pruebas de capturas. Si cualquier
   comprobación posterior falla, la ejecución permanece roja, aunque el APK
   sirva para reproducir el error en móvil. Un APK existente no implica QA
   completada ni calidad artística aprobada.
5. **Agrupar incidencias:** dejar que termine el trabajo completo de GitHub,
   recoger todos los fallos (incluidos los posteriores al primero) y preparar
   **un solo ZIP de correcciones**. No crear una nueva candidata por cada línea
   roja individual. Conservar el informe exacto de qué se arregló y de lo que
   todavía no está verificado.
6. **Regresión permanente:** ejecutar `qa/test_flutter_ci_capture_guardrails.py`
   como parte de la batería Python, además de los tests artísticos y físicos.
