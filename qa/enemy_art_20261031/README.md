## 2026-10-31 — Orden vigente: terminar todos los enemigos sin APK
Autorización explícita en conversación principal Work: seis nuevos y correcciones de clásicos; modificar arte/código, pruebas locales y Actions exclusivamente de pruebas; avanzar sin pausas de aprobación entre enemigos. Prohibidos APK, merge y publicación. Aprobación artística final del usuario sigue pendiente.

Avance real de esta ronda: se recuperaron y visualizaron los dos idle originales de protagonistas. Generación con imagegen integrado usando esos PNG como referencia. Guardados maestro robot turquesa y dos hojas candidatas robot/corredor (4×6, 1024×1536) en qa/enemy_art_20261031/. NO son atlas de producción ni capturas Flutter.
Inspección: robot requiere comprobar locomoción y tamaño/pivotes. Corredor inicial tenía tres celdas vacías de impacto; nueva edición las rellena. Persisten problemas de distribución en celdas regulares, escala/anatomía y alfa residual: hojas alfa 0..254. No normalizar cada pose por separado. No activar flags de aprobación.
Control local ejecutado: dimensiones, SHA256 y conteo alfa>128 por 24 celdas. Esto NO certifica separación de figuras, animación ni arte. No Flutter/Dart local disponible; git clone directo falla por autenticación, conector GitHub sí permite binarios mediante create_blob.
Estados: robot y corredor GENERADOS COMO CANDIDATOS, NO INTEGRADOS/VERIFICADOS; aficionado, turista, rey y toro PENDIENTES DE PRODUCCIÓN; clásicos PENDIENTES DE REVISIÓN/CORRECCIÓN en esta ronda. Ningún enemigo cerrado.

Siguiente: separar/normalizar hojas con escala canónica y pivote consistente, inspeccionar todos los fotogramas a escala de motor, continuar cuatro enemigos y clásicos; usar QA-only remota tras revisar workflow. La autorización no permite ejecutar workflows de build APK.
Lección reutilizable: pedir 24 poses no garantiza 24 figuras ni cuadrícula válida. Alpha presente tampoco prueba bordes limpios. Validar conteo visual, contornos, celdas y coordenadas antes de integrar. La apariencia de fondo en vista previa puede provenir de RGB bajo alpha; inspeccionar bytes antes de diagnosticar opacidad.

