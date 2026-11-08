# Río Arga — continuidad de implementación (8 noviembre 2026)

## Orden aprobada
Nuevo capítulo de **Las aventuras de Miren y Sara** en el río Arga de Pamplona.
Referencia artística vinculante: propuesta SNES 16-bit aprobada en la conversación
«solucionar entrenador rival»: río ancho y agua animada, puente, vegetación y
árboles frondosos, edificios/montañas al fondo, rocas, troncos y tablones para
saltar. La imagen aprobada no debe sustituirse por geometría plana.
Reutilizar el método gráfico de exteriores del capítulo 1, variando su
composición. Los enemigos se trabajarán con el método de sprites aprobado.

## Comprobación del repositorio
- Rama: `work/revision-visual-20261028-continuidad`, PR #5.
- Antes de este trabajo había siete capítulos (índices 0–6).
- No existía módulo Río Arga, entrada en `chapterNames` ni assets declarados.
- El motor usa `groundY = 390` como suelo continuo en `_tick`; añadir
  simples sprites de rocas NO genera huecos jugables.
- Salto existente: impulso -423, gravedad 960, velocidad horizontal 169.
  Tiempo de vuelo teórico al mismo nivel 0,881 s; alcance ~149 px.
  Los huecos iniciales de 55–92 px dejan margen para acelerar y saltar.
- Los siete capítulos anteriores deben quedar intactos, sin cambiar la
  selección ni activar una escena incompleta.

## Avances persistidos
1. `lib/arga_crossing.dart` — modelo independiente y determinista de banco,
   rocas, troncos y tablones; primer tramo 0–2575, apoyos y detección de caída.
   Commit `a80108b8c0c533089b018187cb67db2721119ac4`.
2. `test/arga_crossing_test.dart` — contratos de huecos reales, longitudes,
   apoyos y contacto mortal con el agua. Commit
   `da2a1629a00ecf05ad17c67749827ebbd84c3c2c`.

3. `lib/main.dart` — puente de integración en el motor: en una futura fase `stage == 7`, el suelo continuo se sustituye por apoyos de Arga y el agua resta una vida con reaparición o `gameOver`. Los capítulos 0–6 mantienen su física. El índice 7 sigue sin estar expuesto en el mapa ni declarado en las listas hasta integrar el arte. Commit `31460bb8d46d587c84367da9c2161bbe98c601fd`.

## Estado real
**Fase 1 del modelo y puente de física guardados; NO es todavía un capítulo seleccionable ni validado visualmente.**
Los archivos fueron guardados mediante GitHub; no se ha ejecutado Flutter
sobre el nuevo módulo y no hay capturas `StagePainter` del Arga.
No afirmar que el capítulo está listo para RC7.

## Siguiente acción concreta
1. Obtener/guardar los recursos pixel-art definitivos del Arga inspirados en
   la referencia aprobada, con capas lejanas, medias, río y apoyos físicos
   distintos, protegidos de generadores antiguos.
2. Completar la integración del índice 7 en selección, carga de assets y `StagePainter`
   **solo cuando todos los recursos estén presentes**, sin cambiar índices
   0–6 ni el comportamiento de los capítulos anteriores.
3. Verificar en Flutter la colisión de apoyos y caída mortal ya conectadas; ajustar
   tolerancias, la reaparición y las vidas después de pruebas jugables.
4. Ampliar el recorrido por secciones progresivas y checkpoints, enemigos
   aprobados posteriormente, monedas y salida.
5. Ejecutar análisis/test Flutter y capturas auténticas 20:9: ambas hermanas,
   saltos acertados/fallidos, muerte, reaparición, scroll, parallax, inicio y
   final. Revisar capturas, corregir y solo entonces habilitar RC7.

No hacer APK, merge a main ni publicar sin orden específica.
