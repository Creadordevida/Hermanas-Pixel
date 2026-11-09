# Portero de fútbol — reconstrucción SNES

## Microfase 1 — inspección y referencia candidata (09/11/2026)

- Rama: `work/revision-visual-20261028-continuidad`; capítulo 4, campo de entrenamiento.
- El portero clásico `goalkeeper` usa cinco imágenes separadas en `assets/images/enemies/goalkeeper_0.png` a `goalkeeper_4.png` (57×101, 72×114, 95×116, 102×118 y 122×57). Se conservan sin cambios.
- Motor: `lib/main.dart` carga esas cinco poses y selecciona fotogramas para aproximación, aviso, estirada, impacto y caída. Su ataque es una estirada con aviso y daño único. No existe aún un atlas completo de 24 fotogramas del portero.
- Referencia candidata v1: `qa/goalkeeper_rebuild_20261109/goalkeeper_reference_candidate_v1.png`, 2172×724 RGBA, SHA-256 `435096200274233928393fb7bad2a1d1d49d0701f2ecb948b816b0208da46840`.
- La referencia mantiene pelo castaño, camiseta verde, pantalón blanco y guantes blancos, con seis poses de cuerpo entero: guardia, desplazamiento, alerta, estirada, impacto y derrota. **Es una propuesta artística, NO un atlas listo para recortar ni un recurso activo.**
- Pendiente de aprobación visual del usuario. La lámina requiere limpieza adicional de pequeñas orlas y trazos alrededor de algunas siluetas antes de exportar celdas.
- No se ha modificado código Flutter, atlas activo, físicas, colisiones, banderas o capítulos; no se ha lanzado Actions ni compilado APK.

## Contrato para las siguientes microfases

1. Aprobar o retocar el aspecto de la referencia; conservarla junto a los cinco originales.
2. Especificar tabla completa de fases (al menos reposo, desplazamiento lateral, alerta, anticipación, estirada, contacto, recuperación, impacto y derrota), con tiempos y pivotes. 4×6 es un mínimo orientativo, no un límite.
3. Fabricar atlas transparente sin manchas, solapes ni amputaciones; verificar poses distintas y apoyo a escala de Miren y Sara.
4. Integrar la ruta específica de atlas del portero sin interferir con `rival`, `rival_coach` ni `referee`, y sin sustituir los PNG originales.
5. Probar ambas protagonistas, estirada esquivable, impacto único, reacción a balón/peine y derrota verdadera.
6. Ejecutar Flutter `StagePainter` 20:9 en los estados de movimiento, alerta, contacto, recuperación y derrota; inspeccionar imágenes reales y corregir.
7. Habilitar el nuevo recurso para la próxima APK únicamente después del cierre de QA y de la aceptación artística. Mantener test Android pendiente hasta jugar en Redmi Note 14.

**Siguiente acción:** obtener aprobación artística de la referencia candidata y realizar la limpieza de siluetas antes de fabricar el atlas definitivo.
