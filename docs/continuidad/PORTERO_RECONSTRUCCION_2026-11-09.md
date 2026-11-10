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

## Microfase 2 — diseño aprobado y atlas 24 poses NO LIMPIO

- El usuario aprobó el aspecto de la referencia y autorizó su subida a GitHub. Referencia y documento de recuperación guardados en commit remoto `159a3b7948528d667b843d8e41739841dfa49977`.
- Generada hoja candidata de 4 columnas × 6 filas (`1024×1536`, celda `256×256`) en `qa/goalkeeper_rebuild_20261109/goalkeeper_atlas_4x6_UNCLEAN_candidate.png`, SHA-256 `3522b9e2bc21bd24490251febb3b3e2c90c2fb42d0a833fb0d0ffbf0a1a93e64`.
- Filas: espera, carrera/desplazamiento, aviso, estirada, impacto y derrota. Son dibujos de evaluación: algunos fotogramas tienen variaciones insuficientes para animación fluida y **la imagen conserva fondo degradado opaco**. La petición de quitarlo mediante edición generativa no produjo transparencia útil.
- **RECHAZADO COMO ATLAS DE PRODUCCIÓN**. No registrar en pubspec, no sustituir `goalkeeper_0..4`, no atribuirle validación Flutter o Android. Se conserva para redibujar/limpiar usando la identidad aprobada.
- Siguiente microfase concreta: preparar 24 celdas realmente RGBA sin halos, con pivote de pies y márgenes verificados, inspeccionar secuencia animada; después implementar el lector, tests de combate y capturas auténticas.

## Microfase 3 — contrato temporal de atlas, aislado

- `lib/goalkeeper_animation.dart` establece el mapeo de seis filas y cuatro columnas para las 24 poses propuestas. Diferencia espera (3 fps), desplazamiento lateral (8 fps), preparación de estirada, salto/estirada, impacto y caída real; preserva las ventanas actuales de aviso (.27 s) y contacto (.34–.52 s), sin cambiar daños o físicas.
- `test/goalkeeper_animation_contract_test.dart` comprueba filas, transición aviso/estirada, acceso a las cuatro poses de caída y rango 0–23 de índice. **Código preparatorio desconectado del motor normal:** el portero existente se conserva.
- `flutter` y `dart` no están disponibles localmente; pruebas no ejecutadas. CI manual tampoco ejecutada por la restricción de `AGENTS.md`. La validación Dart queda pendiente.
- El intento adicional de producir atlas nuevo con fondo realmente transparente volvió a generar un degradado. Queda descartado como producción; no se ha introducido el recurso en la aplicación.

## Microfase 4 — seis poses maestras aisladas con alfa real

- La generación por personaje aislado sí obtuvo transparencias reales. Se conservaron seis PNG RGBA separados en `qa/goalkeeper_rebuild_20261109/pose_{ready,shuffle,warning,dive,hurt,defeated}_rgba.png`.
- Comprobación local `identify`: los seis tienen canal alpha y esquinas transparentes (en la pose shuffle hay alpha residual 1/255 en la esquina, que exige limpieza antes de producción). No contienen el fondo degradado opaco de la hoja anterior.
- Resoluciones origen: ready/shuffle/warning/hurt 1312×1199, dive 1774×887 y defeated 2007×783. **No son aún fotogramas de tamaño de juego**, y no deben estirarse individualmente a altura fija. Se preservan como fuentes artísticas para derivar y alinear el atlas.
- Las poses conservan pelo castaño, ojos verdes, equipación verde/blanca y guantes. Hay que comprobar comparativamente proporciones y silueta a la misma escala y corregir halos/semialfa de borde antes de aprobarlas.
- Pendiente: producir variaciones intermedias genuinas, normalizar pivote de apoyo, montar el atlas sin cortar extremidades ni juntar siluetas, conectar en Flutter y verificar 20:9. Sin cambio de recursos activos, sin CI ni APK.

## Microfase 5 — diagnóstico de transparencia reproducible

- `qa/check_goalkeeper_master_poses.py` analiza solo lectura seis PNG RGBA: bbox de silueta opaca, bordes, esquinas y distribución alfa, sin modificar imágenes.
- Ejecución local con Pillow 13: `GOALKEEPER_MASTER_ALPHA_PASS`. Las seis siluetas son interiores al lienzo y las cuatro esquinas tienen alfa 0, salvo un residual 1/255 de la esquina superior izquierda de `shuffle` (tolerado para diagnóstico, pendiente limpieza final).
- Quedan muchos píxeles semitransparentes de antialiasing, por lo que el éxito geométrico **no acredita ausencia visual de halos**; hay que revisar sobre fondos claro/oscuro y a tamaño de juego.
- El atlas 4×6 anterior sigue rechazado. Los seis archivos maestros no sustituyen todavía los cinco sprites de producción; no se ha ejecutado Flutter ni QA Android.

## Microfase 6 — ensayo de tres intermedios de estirada

- Se generaron tres variaciones de impulso, vuelo diagonal y manos extendidas/cierre, a partir de la referencia artística. Los candidatos están en el entorno de generación, no en assets de producción.
- Diagnóstico de esquina y alpha: los tres PNG tienen canal RGBA y fondo nominalmente transparente, pero la inspección visual detectó zonas de sombra/iluminación y píxeles sueltos ajenos al cuerpo; además deben armonizar proporciones con `pose_dive_rgba.png`.
- **No aprobados para atlas**. No se han sustituido los seis maestros protegidos ni los cinco originales activos. Se requiere corregir los tres por silueta y probar reproducción de cuatro fases a escala uniforme antes de promoverlos.

## Microfase 7 — variantes de marcha e impacto con transparencia

- Generados tres PNG RGBA individuales, guardados aparte en `qa/goalkeeper_rebuild_20261109/`: `pose_shuffle_step_a_rgba.png`, `pose_shuffle_step_b_rgba.png` y `pose_hurt_recoil_rgba.png`. La identidad aprobada (pelo castaño, ojos verdes, camiseta verde, guantes) se mantiene.
- Esquinas examinadas: alpha 0 en los tres. Los originales anteriores permanecen intactos. El verificador de geometría incorpora ahora nueve fuentes maestras/intermedias.
- Estas variantes amplían el movimiento pero no sustituyen un atlas completo de 24 cuadros; requieren normalización del tamaño y pivote, inspección de halos en fondo claro/oscuro y secuencia a fps real.
- No se ha alterado `lib/main.dart`, los cinco PNG activos, la lógica de ataque ni la visibilidad de la próxima APK. Sin Flutter ni Android.

## Microfase 8 — dos transiciones de derrota

- Nuevas fuentes `pose_defeat_knee_rgba.png` (rodilla al suelo) y `pose_defeat_hands_rgba.png` (ambas manos apoyadas) como transición hacia `pose_defeated_rgba.png` (tumbado).
- Ambas son 1312×1199 con esquina alfa 0; mantener como ilustraciones de trabajo, pendientes de inspeccionar secuencia temporal y alinear apoyos a la misma escala. El conjunto alcanza once poses maestras/intermedias individuales, no 24 cuadros finales.
- La prueba de control de transparencia se amplía a once archivos. La integración actual y la siguiente APK no se modifican en esta fase.

## Microfase 9 — reposo y anticipación antes de estirada

- Cuatro nuevas fuentes aisladas, con transparencia nominal: `pose_idle_shift_a_rgba.png`, `pose_idle_shift_b_rgba.png`, `pose_warning_crouch_rgba.png`, `pose_warning_reach_rgba.png`.
- Hay quince poses maestras/intermedias únicas bajo control geométrico; aún no forman el atlas final de 24. Las variaciones pequeñas de reposo deben evaluarse en secuencia a tamaño real para descartar cambios de anatomía o duplicaciones encubiertas.
- Se mantienen todos los originales, no se alteran golpes ni tiempos de juego y no se ha lanzado Flutter/Actions/Android.

## Microfase 10 — estirada e impacto ampliados

- Fuentes con transparencia: `pose_dive_extension_rgba.png`, `pose_hurt_side_rgba.png` y `pose_hurt_recover_rgba.png`. Se conservan distintas de las poses maestras de estirada y golpe.
- El candidato de lanzamiento diagonal de esta tanda se **descartó** por mostrar de nuevo un fondo de iluminación/degradado; no se incluye en el verificador ni en los assets activos.
- El inventario controlado alcanza 18 imágenes individuales. Eso no demuestra aún 18 buenos fotogramas sucesivos: siguen sin ajustar pivotes, escala final ni fluidez y existe riesgo de variaciones sutiles de anatomía.
- Falta una secuencia completa de 24 celdas aprobadas y capturas StagePainter. No hay alteración de `main.dart` ni pruebas Flutter/Android de esta variante.

## Microfase 11 — inventario de 24 fuentes individuales

- Se añaden seis imágenes de trabajo RGBA: `pose_idle_shift_c_rgba.png`, `pose_shuffle_step_c_rgba.png`, `pose_warning_extend_rgba.png`, `pose_dive_launch_rgba.png`, `pose_dive_full_rgba.png` y `pose_defeat_side_rgba.png`.
- Se ha inspeccionado visualmente cada nueva imagen de forma individual. La identidad del portero y el vestuario verde/blanco se mantienen; `dive_full` extiende ambas manos y ambas piernas, `dive_launch` enlaza el impulso con el vuelo y `defeat_side` representa la caída lateral. No se confunden con el atlas opaco rechazado.
- El verificador geométrico incorpora 24 nombres. **Son 24 ilustraciones fuente, no un atlas final**: falta reducir a píxel de juego con escala común, ajustar pivotes y orientación, inspeccionar fotogramas consecutivos en movimiento, eliminar cualquier halo y comprobar que ninguna celda corta cuerpo o guantes.
- No se reemplazan los sprites históricos `goalkeeper_0..4` ni se conecta `lib/goalkeeper_animation.dart` a `lib/main.dart` mientras no haya un atlas real y pruebas StagePainter/Flutter. La APK anterior sigue teniendo el portero clásico.
