# Diario de reconstrucción — Hermanas Pixel 0.9.1 RC1

Proyecto original: RC8 REV3. Mitad de trabajo guardada como `HERMANAS_091_CHECKPOINT_MITAD_DELTA.zip` (Library del usuario). Fase 2 integrada el 27/10/2026.

## Secuencia de checkpoints reproducibles

1. **BASELINE**: RC8 REV3. Recursos aprobados 0.8.0 y las cuatro panorámicas protegidas mediante hashes inmutables.
2. **Checkpoint de mitad**: siete regiones, dos conexiones, atlas de árboles separado, sin fundidos globales.
3. **Fase 2a**: añadidos paneles de paisaje anclados a coordenadas de mundo; los hitos únicos no se repiten, las regiones se desplazan a factor 1.0.
4. **Fase 2b**: ajustes de recorte de raíces de árboles, composición de vegetación y una pérgola de conexión; las transiciones requieren pruebas visuales.
5. **Fase 2c**: portada retocada conservando personajes, padre y rótulo; se incorporó el logo corporativo desde el archivo fuente de la Library del usuario; no se tocó la ilustración original de la portada.
6. **Fase 2d**: reducción de palomas, caída de heroínas, fondo adaptable sin bandas oscuras, controles rápidos de GitHub, Flutter/Ubuntu/dependencia directos fijados.
7. **Fase 2e**: 113 pruebas Python locales y preflights satisfactorios; Dart/Flutter/Android y aprobación artística **PENDIENTES**.
8. **Paquete**: ZIP de código completo 0.9.1 RC1 para GitHub. No APK.

## Reglas de reinicio

Para continuar tras un corte: partir del ZIP `Miren_y_Sara_0.9.1_RC1_GITHUB_COMPLETO.zip` y de `README_091_PRUEBAS.md`. No combinarlo manualmente con el delta de mitad, porque **ya incluye esos cambios**. La versión anterior completa RC8 REV3 se conserva por separado en Library.

## Riesgos abiertos y planes de aceptación

- **Transiciones entre paneles**: algoritmos y geometría comprobados, estética solo mediante capturas reales del motor y vídeo móvil.
- **Variedad de fondos neutros**: hay repetición parcial en recorrido largo; no declarar completamente resuelta si resulta evidente al jugar.
- **Logotipo y pantalla panorámica**: original corporativo verificable, pero distribución y tamaño deben contrastarse en Android; el espacio jugable activo aún usa 800×450.
- **Compilación reproducible**: versiones directas fijadas; el lockfile resuelto de transitivas se publicará como artifacto de GitHub para incluirlo en futuras versiones.
- **Registro de QA**: las pruebas de Python certifican recursos y geometría, NO la calidad artística.
