# Hermanas Pixel — estado y reanudación
**Fecha de corte:** 2026-10-28. **Rama de trabajo:** `work/revision-visual-20261028-continuidad`. **Base protegida:** `main`.
## Estado verificado
- PR #4 fusionada en main el 2026-10-28: 55 archivos; fútbol (stage 4), danza (stage 5), colegio (stage 6) con paralaje TWC.
- 196 pruebas Python constan como superadas *antes de la PR*. No confundirlas con aceptación artística ni ejecución Android.
- Workflow #36 (`40725972108`): job `android-apk-candidato` completado **success**, artefacto `Miren-y-Sara-0.9.1-RC3-APK-PRUEBAS`, ID `12833916176`. Auditoría gráfica estaba aún en marcha en la última comprobación. APK de pruebas, no aprobación visual.
- Método aprobado RC3 FIX2: `docs/TWC_PARALLAX_2D_METODO_APROBADO_RC3_FIX2.md`. No reescribirlo como si el capítulo entero estuviera aprobado.
## Defectos reportados mediante vídeos reales del 28-10-2026
1. Portada: barras laterales borrosas; caja opaca bajo sello TWC; tamaño y legibilidad del sello.
2. Colegio: fondo visto por ventanas visualmente pobre y desplazándose; composición de paneles cerca incoherente, columnas/taquillas desajustadas, objetos y rótulos repetidos.
3. Danza: paredes/cuadros/carteles/puertas demasiado repetidos a lo largo del recorrido; fondos exteriores de ventanas de menor calidad que el interior.
4. Fútbol: imágenes de calidad aceptable, pero unión horizontal artificial entre plano lejano y banda cercana. Necesita contornos y piezas deportivas/vegetación que atraviesen la junta sin fundido global.
## Restricciones
- Preservar recursos fuente originales, física, colisiones, personajes, capacidades y fondos modulares aprobados del capítulo 1.
- Paralaje lejano 0.30, intermedio 0.56, cercano/arquitectura 1.00; exteriores por ventanas solo en interiores. No usar crossfade de panorámicas completas.
- No considerar aprobadas las propuestas hasta revisarlas en **vídeo de Flutter real y en Android**.
## Próximo paso comprobable
Crear y evaluar recursos visuales nuevos **por capas** y sus máscaras, generar vistas de cámara en transiciones y ciclos, ensayar Flutter, comparar vídeo real y solo entonces compilar APK candidato. Mantener cambios en rama/PR revisable; no sustituir `main` antes de superar pruebas.
## Cómo continuar tras cierre de chat
Leer primero este fichero, `docs/DECISIONES_APROBADAS.md`, `docs/HISTORIAL_DE_TRABAJO.md` y `docs/TWC_PARALLAX_2D_METODO_APROBADO_RC3_FIX2.md`; inspeccionar rama, diff, PR y CI. No rehacer trabajo ni declarar APK validado por el usuario sin pruebas actuales.
