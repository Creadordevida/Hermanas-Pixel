# Informe de avance real — reconstrucción de la versión 0.9.0
Fecha: 25-10-2026. **Estado: NO PUBLICABLE.**

## Procedencia

- Código base extraído de `Las_Aventuras_de_Miren_y_Sara_0.8.0_ANDROID.zip`.
- 31 PNG originales protegidos con SHA-256 contra `qa/baseline_080_sha256.json`.
- No se han usado las escenas, el mapa, las figuras geométricas ni los enemigos rechazados de la 0.9.0 anterior.
- Los PNG nuevos proceden únicamente del perro original aprobado, recoloreado, sin cambiar alfa, pose ni dimensiones.

## Implementación incorporada realmente a `lib/main.dart`

1. DogType con tres variedades: dálmata (1 golpe, rango 145, velocidad 65), original marrón (1, 205, 94), dóberman (2, 260, 117). El primer golpe al dóberman lo aturde pero no lo elimina.
2. Ocho poses reales para cada perro, y verificación de transparencia idéntica entre cada variante y su original.
3. Diálogo de inicio a la derecha; PAPÁ azul, MIREN amarillo, SARA morado.
4. El padre y la hermana no elegida salen caminando hacia la izquierda tras la conversación y no acompañan al jugador durante el capítulo.
5. Las cajas no desaparecen visualmente sin más: durante 0,45 s se ven seis fragmentos del PNG aprobado.
6. El suelo original, los fondos de los capítulos 1–4, la apariencia de los personajes, el logo original y el control de ataque del balón/peine permanecen como en la 0.8.0, salvo los cambios registrados.

## Únicamente especificado, NO desarrollado con calidad aprobada

- Los siete capítulos, tres niveles nuevos, recorridos de cinco minutos, mapa seleccionable y guardado del mapa.
- Diez enemigos nuevos fuera de los perros (paloma, gato, rata, estatua y seis personajes temáticos). Las ilustraciones conceptuales NO son sus sprites funcionales.
- Obstáculos personalizados (conos, macetas, caballetes, mochilas) con calidad 0.8.0.
- Extensión de escenas con texturas originales sin costuras; verificación de saltos y rutas completas.
- Logos que solo podrían cambiarse si se verifica el archivo oficial de otras aplicaciones.

Las especificaciones solicitadas están inventariadas en `qa/specification_090.json`; una especificación no equivale a implementación.

## Pruebas realizadas en este entorno

| Prueba | Estado real |
|---|---|
| Revisión integridad hash de 31 PNG base | Superada |
| Verificación de recursos de 0.8.0 y launcher | Superada |
| 26 pruebas Python de calidad, geometría, variantes y rechazo | Superadas |
| Comparación directa de 8 poses de cada variante con alfa original | Superada |
| Prueba de puerta estricta | Bloquea con 155 pendientes, como debe |
| `flutter analyze` / `flutter test` / `flutter build apk` | NO EJECUTADOS: SDK Flutter no disponible |
| Capturas y vídeos procedentes de APK real | NO DISPONIBLES |
| Pruebas visuales y funcionales en Android | NO REALIZADAS |

## Procedimiento obligatorio antes de entregar una versión real

1. Producir los gráficos definitivos con calidad comparable a 0.8.0.
2. Asignar SHA-256 aprobado al PNG exacto que carga el motor.
3. Verificar escalas, sombras, suelo, colisiones y animación de todos los fotogramas.
4. Integrar cada capítulo y pasar pruebas de recorrido, saltos, checkpoint, ataques, completado y guardado.
5. Capturar desde Android realmente instalado en el APK exacto: inicio, mapa, tres ubicaciones de cada capítulo, cuatro estados de cada enemigo, vídeos de movimiento y recorridos.
6. Rechazar cualquier partida con arte falso, niveles inaccesibles, animaciones escaladas, errores de cámara, fondos cortados o pérdida de un elemento aprobado.
7. `qa/release_gate.py --strict` bloquea mientras falte una sola evidencia o aprobación.

**Este código es un avance aislado sobre la 0.8.0; NO es el nuevo juego prometido, NO es la 0.9.0 completa y NO debería reemplazarla en GitHub ni presentarse como validada.**

## Continuación de controles tras el primer paquete de reconstrucción

Se ha añadido un ensayo de capturas extraídas del **renderizador del juego** en Flutter Test (no de ilustraciones externas), comparación regresiva de píxeles con detalle de 1 píxel, y un modelo físico de alcanzabilidad de saltos ligado a las constantes de la 0.8.0. Estas comprobaciones no completan ningún nivel ni aprueban gráficos de terceros. No se ha ejecutado aquí la parte Flutter, que requiere CI. **La versión continúa sin aprobarse y sin poder instalarse como versión candidata final.**
