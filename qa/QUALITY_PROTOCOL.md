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
