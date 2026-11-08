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
