# Protocolo de traspaso entre conversaciones
## Inicio
Comprobar acceso al repo privado, rama y HEAD actuales, PR abierta y pubspec. Leer CONTINUIDAD_TWC.md, ESTADO_OPERATIVO.md, AGENTS.md, docs/DECISIONES_APROBADAS.md, docs/HISTORIAL_DE_TRABAJO.md y docs/FRAMEWORK_SNES_TWC/README.md. Contrastar informes fechados con árbol y commits actuales.
## Durante
No alterar jugabilidad por documentación. Preservar fuentes. Ciclo visual: inspeccionar → detectar → corregir → generar → abrir PNG real → renderizar StagePainter → examinar movimiento → iterar → validar. Un test Python no prueba calidad visual; Flutter no prueba Android; APK compilada no prueba aprobación.
## Cierre
Actualizar ESTADO_OPERATIVO.md y añadir entrada a BITACORA.md. Guardar SHA, archivos, evidencia real, pruebas ejecutadas/no ejecutadas, bloqueos, decisiones y siguiente acción. Actualizar framework cuando se descubra una técnica reutilizable. Confirmar escritura remota; si falla, avisar.
No lanzar Actions manuales, compilar APK ni fusionar sin autorización explícita.
## Plantilla
Fecha / rama / HEAD anterior / HEAD nuevo:
Objetivo autorizado:
Hecho y archivos:
Pruebas realizadas y evidencia:
Pruebas NO realizadas:
Bloqueos:
Siguiente acción exacta:
