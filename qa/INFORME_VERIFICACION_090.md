# Informe de verificación de la candidata 0.9.0

**Resultado local (fuente y recursos):** comprobaciones ejecutadas y satisfactorias.

| Punto | Evidencia | Estado |
| --- | --- | --- |
| Recursos personajes 0.7.1 | SHA-256 idéntico de los 12 PNG de poses | OK |
| Fondo original 0.7.1 | SHA-256 idéntico | OK |
| Pantalla de inicio, logo, escenarios y launcher 0.8.0 | SHA-256 idéntico de 18 archivos | OK |
| Archivos PNG de 0.9.0 | Escaneo e identificación PNG, tamaños y presencia | OK |
| Siete destinos en el mapa | Tabla y controles presentes en Dart | Inspección estática |
| Obstáculos con aspecto por capítulo | Recursos presentes y tipos asignados | Inspección estática |
| Enemigos (13 variantes) | Datos de resistencia, arte de estados y daño | Inspección estática |
| Flutter analyze | Requiere Flutter SDK no disponible localmente | SIN EJECUTAR |
| Flutter test | Requiere Flutter SDK no disponible localmente | SIN EJECUTAR |
| Compilación APK release | Workflow configurado; no se ha ejecutado aquí | SIN EJECUTAR |
| Juego en móvil y cinco minutos/capítulo | Requiere APK y pruebas manuales | SIN VERIFICAR |
| Calidad visual final frente a 0.7.1 | Solo se ha probado retención íntegra del material aprobado; nuevos materiales aún no validados en juego | PENDIENTE |

## Criterios de aceptación antes de dar por buena la versión

- GitHub Actions verde de inicio a fin; descargar y arrancar APK.
- Los siete destinos del mapa deben ser pulsables y aparecer en el mapa sin desbloqueos.
- Todos los capítulos deben comenzar, poder pausarse y volver a mapa sin pérdida de completados.
- Fútbol solo Miren; danza solo Sara; cinco capítulos con elección.
- Dos corazones, invulnerabilidad tras daño, reintento en checkpoint y guardado al cerrar.
- 3 golpes al árbitro, breakdancer, profesor y estatua; 2 al dóberman; 1 al resto.
- Máximo un proyectil enemigo del mismo tipo simultáneamente, aviso previo de ataque y ventana entre ataques.
- Animaciones naturales sin deslizamiento visible ni aparición/desaparición brusca.
- Ninguna textura de fondo con monedas o enemigos dibujados en ella; objetos interactivos siempre independientes.
- Suelo gráfico y suelo de colisiones coincidentes en los siete recorridos; plataformas accesibles.
- Cronometrar duración de todos los capítulos a velocidad habitual con fallos razonables.
- Validar con la familia los trajes y nuevos enemigos. Si fallan, conservar las poses y fondos originales y corregir solo los derivados, nunca sobreescribir la referencia.

**Decisión:** Proyecto **candidato de pruebas**, NO certificado para publicación comercial, hasta completar esas verificaciones.
