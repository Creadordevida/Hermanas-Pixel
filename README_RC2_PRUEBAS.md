# Las aventuras de Miren y Sara — 0.9.1 RC2 (candidata de pruebas)

## Estado

**Proyecto completo para subir a GitHub, NO APK y NO aprobado visualmente.**
Se ha continuado desde el checkpoint de mitad RC2, conservando una copia del RC1.

## Cambios principales

1. Geografía: 4 ilustraciones aprobadas (edificio, paseo, cubierta y cohete) conservadas byte a byte.
2. Distribución: 7 regiones / 7 artes distintos, sin bucle de jardines repetidos (eran 28 paneles con 11+12 usos de dos imágenes genéricas).
3. Cámara: grandes vistas panorámicas lejanas, con recorte horizontal proporcional al avance dentro de cada región; suelo, personajes y obstáculos continúan a velocidad real del mundo.
4. Uniones: 6 puntos, con máscara *espacial* localizada a una franja de 96 unidades. No se disuelve una pantalla completa con el tiempo.
5. Visibilidad: ninguna vegetación añadida sobre los cuatro hitos; vegetación original conservada.
6. Suelo: sigue vigente la corrección de mitad RC2 que impide dibujar simultáneamente acera pintada y suelo físico.
7. Portada: relleno lateral desenfocado para que no aparezca una copia nítida de los coches, la familia ni el título. El área central sigue manteniendo el formato 800×450.
8. Palomas: se reduce de 136 a 108 la celda de vuelo del atlas; su pivote de patas sigue medido fotograma a fotograma.
9. Capturas reales de Flutter preparadas para las seis uniones, los siete capítulos, los cuatro hitos y fútbol/danza.
10. Flujo de GitHub: Flutter fijado a 3.47.8, integridad y análisis antes del APK; QA gráfica separada de su compilación.

## Comprobaciones locales

- **119 pruebas Python aprobadas**, junto a las auditorías de recursos esenciales y capas.
- **137/137 rutas de recursos referenciadas válidas**.
- Cuatro ilustraciones originales y mapa protegidos por SHA-256.
- 7 fondos regionales distintos, 0 conectores repetidos, 6 uniones enumeradas en `qa/RC2_SCENE_AUDIT_FINAL.json`.
- Las capturas de `qa/rc2_simulated_seams/` son **simulaciones PIL**, no capturas del motor ni prueba de calidad artística.

## Pendiente ANTES de aprobar

- `flutter analyze --no-pub lib test` y pruebas Flutter: **no ejecutados localmente, SDK no disponible**.
- `flutter build apk --release`: **no ejecutado localmente**, se hará en GitHub Actions.
- Capturas del motor + vídeo Android: **pendiente**.
- No afirmar aún que las seis uniones son naturales: incluso 96 px de mezcla espacial pueden producir dobles contornos de arquitectura. Si sucede, serán necesarias transiciones ilustradas expresamente.
- La interfaz central mantiene relación de aspecto 800×450; las bandas de juego panorámico solo tienen relleno estilizado, no existe aún ampliación real del campo de cámara.
- No se han cambiado el resto de seis capítulos ni se han creado nuevas poses para saltos.

## Instrucciones rápidas

1. Descomprimir este ZIP en una carpeta temporal.
2. Copiar **su contenido interior** a la raíz de tu repositorio GitHub Desktop, sobrescribiendo archivos. Preservar `.git`.
3. Hacer `Commit to main` y `Push origin`.
4. En GitHub Actions localizar `Miren y Sara 0.9.1 RC2 - APK y auditoria grafica`.
5. Descargar el artifact `Miren-y-Sara-0.9.1-RC2-APK-PRUEBAS` si compila; es un ZIP con `app-release.apk`.
6. Verificar también `Capturas-REALES-Flutter-0.9.1-RC2` y enviar un vídeo del capítulo 1 para inspección dinámica.

Para preservar la documentación de aprendizaje consultar `docs/RC2_FINAL_STATE.json` y `qa/RC2_SCENE_AUDIT_FINAL.json`.
