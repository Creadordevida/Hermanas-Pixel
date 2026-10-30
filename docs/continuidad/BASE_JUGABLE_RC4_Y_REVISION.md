# BASE DE REFERENCIA: 0.9.1 RC4 probada por usuario en Android — 2026-10-30

Proyecto: Las aventuras de Miren y Sara / The Wolf Company.
Repositorio: `Creadordevida/Hermanas-Pixel`.
Rama de trabajo: `work/revision-visual-20261028-continuidad`. PR #5 abierta en borrador, NO fusionada.
Release privado de PRUEBAS: `playtest-0.9.1-rc4`.
URL: https://github.com/Creadordevida/Hermanas-Pixel/releases/tag/playtest-0.9.1-rc4
APK: `app-release.apk`, 142.317.311 bytes, confirmada como asset remoto de GitHub Releases.
**COMMIT COMPILADO:** `c08ba00283775b99593ff426e8d4bd2130d35307`; el HEAD actual de trabajo es posterior y no altera retrospectivamente los bytes de esa APK.
Run: `41071927964`, completado SUCCESS (revisión remota).
Versión Flutter: `0.9.1-rc.4+35`. Los seis enemigos nuevos habilitados con `TWC_GAMEPLAY_PLAYTEST=true`, pero su arte sigue provisional.

## NUEVA EVIDENCIA APORTADA DIRECTAMENTE POR EL USUARIO
El usuario ha **instalado y probado la APK en su móvil**. Su valoración inicial: hay «muchas cosas que mejorar y algunas decepciones»; orden expresa: «partamos de este punto para avanzar». NO se conocen todavía los defectos específicos. NO etiquetar esta prueba como aceptación gráfica, funcional ni satisfacción con la versión. NO adivinar ni rellenar incidencias que el usuario no haya descrito.

## DECISIÓN DE MÉTODO
- RC4 es la **base de comparación / punto de partida reproducible**, NO una versión final aprobada ni una afirmación de que todo funciona bien.
- Mantener intacta la prerelease RC4 y el commit fuente; no mover/eliminar referencias ni borrar arte original.
- Registrar problemas del usuario UNO A UNO con: capítulo, personaje/recurso, observado, esperado, evidencia (captura/vídeo), severidad, causa comprobada, cambio, prueba y estado. Evitar duplicados.
- Preparar una **lista acumulativa de mejoras de la siguiente versión**, sin generar APK a cada incidencia. Las correcciones se agruparán en candidata posterior tras decisión del usuario.
- Priorizar fallos que impidan jugar/cargar, ataques o interacciones rotas, después defectos visuales prioritarios, pero escuchar el orden de importancia indicado por el usuario.
- Conservar los siete capítulos, el parallax, la calidad artística histórica, originales aprobados, logo TWC y recursos existentes. No empeorar RC4 por buscar mejora aislada.
- Para cada modificación: contraste con RC4 y original → código/PNG generado → pruebas Python → capturas Flutter reales → revisión móvil; separar estados sin inventar evidencia.
- No generar ni lanzar más GitHub Actions, compilar APK, fusionar PR #5 o publicar hasta que el usuario solicite siguiente ronda de compilación. No se autoriza la publicación artística.
- La APK RC4 no contiene PNG nuevos de danza/fútbol/enemigos guardados persistentemente como commits: el workflow los generó en el runner y los empaquetó. El proceso futuro debe conservar manifests/sha y promover arte final aprobado a la rama.
- Docs de la sesión de compilación: `docs/continuidad/APK_RC4_PLAYTEST_2026-10-30.md`.

## LISTA ACUMULATIVA RC SIGUIENTE
**ABIERTA — SIN INCIDENCIAS DETALLADAS AÚN.**
Esperar la primera observación concreta del usuario, agregar sin implementar/compilar automáticamente.

### 30/10/2026 — Vídeo 001: P0 tamaño/ocupación de pantalla (portada Y juego)
Usuario envía vídeo `Screenrecorder-2026-10-30-15-53-34-17.mp4` (33.32 s, 1080×2400). Registro de dos incidencias críticas RC4-001A (portada) y RC4-001B (juego/mapa). Se documentó franja activa 20:9 en centro del vídeo vertical (filas ~957–1442), exterior negro y márgenes internos; código fuente comprueba BoxFit.contain y viewport fijo 800×450, y manifest Android ausente del repositorio al usar flutter create. **Causa exacta del encajonado nativo aún por validar en móvil.** Requiere corrección de orientación nativa + viewport adaptable sin distorsión ni recorte de HUD. Estado: EN LISTA DE PRÓXIMA VERSIÓN, NO RESUELTO, sin compilar. Detalles y aceptación en `docs/continuidad/INCIDENCIAS_VIDEOS_RC4.md`.
