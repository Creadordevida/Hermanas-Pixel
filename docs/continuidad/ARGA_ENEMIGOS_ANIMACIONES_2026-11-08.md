# Río Arga — continuidad de animaciones y QA (8 noviembre 2026)

Rama: `work/revision-visual-20261028-continuidad`. Capítulo experimental `stage == 7`, fuera del mapa normal. Conservar siete capítulos existentes; no habilitar GitHub Actions automáticas, generar APK, ni declarar finalizado sin capturas reales StagePainter y jugabilidad completa.

## Estado comprobado en código

Los cuatro enemigos **se dibujan y tienen lógica de ataque** en `lib/main.dart`, con máquina de estados separada:
- **Cangrejo:** `lib/arga_crab_behavior.dart`. Poses reposo, lateral, alerta, pinza, impacto, derrota. Se aproxima sobre la misma roca y ataca con pinzas. Tests en `test/arga_crab_behavior_test.dart`.
- **Pescador:** `lib/arga_fisher_behavior.dart`. Reposo, caminar, alerta, lanzamiento, impacto, derrota. Lanza anzuelo físico de `lib/arga_hook_projectile.dart`; la pose `walk` está definida pero su comportamiento actual permanece estacionario. Tests en `test/arga_fisher_behavior_test.dart`.
- **Niño gamberro:** `lib/arga_boy_behavior.dart`. Reposo, correr, alerta, lanzamiento, impacto, derrota. Lanza piedra física de `lib/arga_stone_projectile.dart`; `run` está definida pero no se activa. Tests en `test/arga_boy_behavior_test.dart`.
- **Trucha:** `lib/arga_trout_behavior.dart`. Nado, acelerar, alerta, salto, impacto, derrota; físicas y contacto aéreo. Se incorporó transición real nado→acelerar→alerta→salto (`fca9eaf`); test de cancelación (`50f83ed`); dibujo elevado 21 unidades de pantalla sin alterar hitbox (`1112222`). Tests actualizados (`cb24b1b`).

### Importante: seis estados NO equivalen a animación completa

Actualmente `StagePainter` selecciona **una imagen aislada por estado**. No existe todavía un atlas de varios fotogramas interpolados por estado para estos cuatro enemigos. Debe aplicarse la metodología aprobada para limpiador/músico: originales intactos; atlas con varias columnas por fila; alfa limpio y ninguna silueta invadiendo celdas; apoyos y escalas alineados; temporización de fotogramas; impacto/caída completos; comparación referencia→atlas→captura real.

## Orden de ejecución pendiente

1. Verificar visualmente las seis poses actuales y los originales de cada enemigo, empezando por trucha y cangrejo. Medir alfa, apoyos y tamaños; NO fabricar equivalencias o fotogramas sin inspección.
2. Crear **varios fotogramas distintos por estado**, preservando identidad aprobada, y empaquetar atlas de dimensiones estables. La cantidad de columnas se determina por movimiento real (no limitar a seis imágenes totales). Mantener PNG fuente.
3. Añadir selector temporal de fotogramas en `StagePainter` y probar transiciones, dirección, ciclo, interrupción, ataque, impacto y derrota sin recortes ni salto de posición.
4. Revisar anzuelo y piedra (actualmente círculos de QA), escalas y altura de trucha. No promover arte sin capturas auténticas 20:9.
5. Probar toda la travesía y caída mortal al agua con Miren y Sara; corregir huecos, checkpoints y respawn. Solo entonces habilitar acceso normal al Arga.

## Validación y cautelas

- Verificados en repositorio: archivos y commits nuevos. **No ejecutados:** `flutter test`, compilación Android, capturas StagePainter ni partida completa (Flutter/Dart no disponibles en este entorno).
- GitHub Actions se mantiene **manual** para evitar consumo de minutos.
- No se modificaron los otros capítulos; los cambios de `main.dart` son exclusivos de la representación de la trucha en `stage == 7`.
- No confundir avance técnico con aprobación artística o juego listo para próxima versión.

## Infraestructura de animación añadida (misma jornada)

- `lib/arga_sprite_atlas.dart`: reloj de animación determinista para atlas **4 columnas × 6 filas**; filas 0–2 cíclicas y 3–5 de una ejecución con último fotograma mantenido.
- `test/arga_sprite_atlas_test.dart`: tests de bucles, ataques, reinicio y valores inválidos. Guardado en `b0de161`.
- `lib/main.dart`: los cuatro pintores de enemigos del Arga pueden seleccionar una celda del atlas (`arga_crab_atlas`, `arga_fisher_atlas`, `arga_boy_atlas`, `arga_trout_atlas`) usando el estado y el tiempo. Commits `1ed4579` y `d404bd8`.
- **Compatibilidad:** mientras esos atlas no estén empaquetados/cargados, se dibujan las poses aisladas actuales. No se han inventado ni incorporado nuevos fotogramas.
- **Pendiente imprescindible:** crear los PNG atlas reales a partir del arte aprobado, registrar su carga y comparar 24 celdas por enemigo con capturas reales; reconsiderar el número de columnas por acción si cuatro resultan insuficientes. Esta infraestructura NO representa una animación acabada.
- No se han ejecutado tests Flutter/Dart ni Actions; no se ha modificado la visibilidad del capítulo.

## Microfase siguiente — selector tolerante a filas incompletas (2026-11-08)

- `lib/arga_sprite_atlas.dart` añade `activeFrames` (1–4) por fila, conservando el valor predeterminado de cuatro. Esto permite iterar sobre el arte sin seleccionar celdas vacías mientras se revisan fotogramas. Commit `e4c197b`.
- `test/arga_sprite_atlas_test.dart` añade escenarios con dos y un fotograma, bucle, retención del último y rangos inválidos. Commit `4f02cd2`.
- Verificada persistencia remota mediante consulta a GitHub. **Pruebas Dart/Flutter no ejecutadas** (aplazadas por acuerdo), no existe atlas artístico nuevo ni captura real.
- Siguiente microfase: auditar visualmente las seis poses aprobadas del cangrejo, alinear apoyos y producir intermedios auténticos antes de cargar un atlas. El parámetro opcional no sustituye esa tarea; no habilitar el capítulo normal.
