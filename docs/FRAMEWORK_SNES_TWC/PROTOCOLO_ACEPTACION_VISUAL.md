# Protocolo de aceptación artística — TWC SNES

## Salidas distintas, certificados distintos

| Producto | Prueba mínima | Lo que NO prueba |
|---|---|---|
| PNG fuente | Abrir PNG real y verificar transparencia, contorno, escala | Cómo se dibuja en Flutter |
| Hoja de sprites | Ver 6 estados y todos los fotogramas, posturas y pivotes | Funcionamiento/colisiones |
| Composición de escenario | Capturas reales en 10+ cámaras y uniones | Movimiento fluido |
| Animación | 3+ fotogramas sucesivos y cambio de estado correcto | Integración en Android |
| Flutter StagePainter | Capturas del motor con cámara y personaje reales | Frame rate en dispositivo |
| Android APK | Prueba en móvil físico, rendimiento, toques y guardado | Calidad artística sin revisión |

## Ficha de personaje

Identificación; archivo/sha; origen del arte; estilo de referencia; resolución nativa y escala; estados (reposo, movimiento, alerta, ataque, daño, derrota); ancho/alto por pose; línea de suelo y pivote; hitbox; interacciones con héroes; juicio crítico; defectos; evidencias reales; decisión de aprobación.

**Criterios visuales:** silhouette legible a escala de juego, rostro/volumen/telas, sombreado coherente, fotogramas realmente diferenciados, piernas/brazos funcionales, línea de suelo y derrota reconocible. Si falla cualquier criterio relevante: **INSUFICIENTE**.

## Ficha de escenario

Fuente/sha; zona mundial; muestras al inicio/mitad/final; cambios de sala; variación **percibida**, no sólo hash; perspectiva; iluminación; contacto de objetos con suelo; capas de fondo; continuidad de paralaje; uniones; recortes alfa; decorados repetidos.

**Contraprueba:** mantener cámara de arquitectura fija y mover sólo `exterior_cam`. Fuera de los cristales la composición debe permanecer idéntica.

## Condiciones de bloqueo

- Un PNG anunciado como nuevo sin haber sido generado.
- Capturas creadas mediante montajes en lugar del motor cuando se afirma que son de Flutter.
- Un atlas que aún no coincide con el asset registrado por el juego.
- Un enemigo con `enemyArtValidated=false`.
- Imagen panorámica faltante, deformación, bandas borrosas o logo con recuadro.
- Una comparación con el capítulo 1 basada exclusivamente en cifras de color.
- Una partida Android anunciada como comprobada sin probarla.

## Evidencia por entrega

`commit SHA`, ruta del asset, `SHA256` del PNG, método de generación, imagen inspeccionada, prueba pasada, incidencia corregida, responsable de aceptar, fecha, estado. Las aprobaciones quedan vinculadas a esos bytes: cualquier modificación posterior exige nueva revisión.

## Resultado válido

`COMPLETADO` exige código integrado, recursos reales regenerados, validación visual real, pruebas mecánicas y ausencia de defectos críticos. `PENDIENTE` o `BLOQUEADO` cuando falte una de esas fases. No declarar que el trabajo seguirá autónomamente después de terminar la sesión.