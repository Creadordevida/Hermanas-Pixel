# Informe de auditoría de recuperación — 25/10/2026

## Estado de ejecución

- **Base protegida:** código y 31 recursos PNG procedentes directamente de `Las_Aventuras_de_Miren_y_Sara_0.8.0_ANDROID.zip`. El script `qa/release_gate.py` valida sus hashes SHA-256.
- **Comprobación efectuada:** auditoría de integridad de recursos y pruebas unitarias de geometría y del mecanismo de rechazo. **No se ha compilado ni ejecutado un nuevo APK Android**; Flutter, SDK y emulador no están disponibles en este entorno.
- **Entrega 0.9.0:** **BLOQUEADA**. No se considera corregida, no se ofrecen capturas de un APK inexistente ni versiones visuales conceptuales.

## Auditoría gráfica concreta de la 0.9.0 fallida

Una comprobación sobre imágenes reales de los proyectos (escala común de 640x320) produjo estos valores orientativos:

| Recurso | Índice de variación espacial | Entropía cromática | Decisión |
|---|---:|---:|---|
| 0.8.0 Salida de casa | 21.06 | 7.64 | Referencia aprobada |
| 0.8.0 Ayuntamiento | 14.25 | 7.71 | Referencia aprobada |
| 0.8.0 Estafeta | 11.38 | 7.56 | Referencia aprobada |
| 0.8.0 Plaza | 12.53 | 7.59 | Referencia aprobada |
| 0.9.0 Campo de fútbol | 6.80 | 6.71 | Alerta, no aprobado |
| 0.9.0 Danza | 3.59 | 6.56 | Alerta, no aprobado |
| 0.9.0 Colegio | 4.00 | 4.80 | Alerta, no aprobado |
| 0.9.0 Mapa | 5.13 | 5.71 | Alerta, no aprobado |

**Estas cifras no son notas estéticas absolutas**: la composición y el tipo de entorno influyen. Sirven como aviso temprano ante degradaciones marcadas y **no sustituyen el juicio visual de una persona ni capturas del render real**. La aprobación exige inspección gráfica y de jugabilidad.

## Defecto de escalado

Los fotogramas del alumno abusón de la 0.9.0 miden 57 × 101 (de pie) y 122 × 57 (derrota). Si se fija una altura uniforme de 90 al dibujarlos, la anchura pasa de 50.8 a 192.6 unidades, factor aproximado **3.79**. Se comprobó con `qa/sprite_scale_audit.py` y se debe rechazar ese método. La animación tumbada puede ser más ancha, pero **la escala del cuerpo y el anclaje al suelo deben mantenerse** y verificarse visualmente.

## Controles introducidos en el proyecto de referencia

1. Congelación reproducible de 31 PNG por SHA-256 en `baseline_080_sha256.json`.
2. Puerta de aceptación con 29 fichas de mejora y siete evidencias técnicas, pendientes por defecto (`acceptance_090.json`).
3. Auditoría automática de pérdida evidente de detalle en escenas nuevas.
4. Auditoría de tamaños de fotogramas de enemigos.
5. Límites físicos reales calculados del código original: salto máximo 87.55 unidades y alcance horizontal teórico 144.35 unidades, antes de definir plataformas.
6. Capturas tomadas **exclusivamente desde la pantalla real de Android mediante `adb exec-out screencap -p`**, unidas a la huella digital del APK (`capture_android.py`).
7. Cobertura requerida: título, mapa y los siete capítulos; comprobador `check_evidence.py`.
8. Ocho pruebas unitarias de controles de calidad, más verificaciones anteriores de PNG y CRC.
9. Flujo GitHub adicional de auditoría sin etiquetar un APK como aprobado.

## Qué NO puede concluirse de estas pruebas

- No certifican que los 7 capítulos existan con la duración, presentación y jugabilidad deseadas.
- No certifican que el mapa o enemigos aprobados en imágenes conceptuales se hayan convertido en sprites equivalentes.
- No certifican la naturalidad ni corrección de una animación en tiempo real.
- No certifican compilación ni rendimiento Android.
- No pueden afirmar ausencia de defectos al probar en dispositivo.

**La diferencia respecto a la 0.9.0 fallida es que no se usará una prueba de archivos o una simulación como sustituto de todo lo anterior.**

## Siguiente condición técnica

Para continuar la implementación, desarrollar los gráficos auténticos de cada nuevo componente y probarlos en el motor. Si no es posible conseguir o comprobar la calidad de un recurso, el proceso exige **no integrarlo** y no presentar un ZIP de 0.9.0 como versión satisfactoria. La 0.8.0 permanecerá sin cambios.

## Referencias gráficas adjuntas

Se conservan las cuatro figuras aceptadas por el usuario en una imagen **conceptual**, y las ocho capturas del juego defectuoso como ejemplos de **resultado expresamente rechazado**. Ninguna de estas imágenes se presenta como captura de una nueva versión jugable.
