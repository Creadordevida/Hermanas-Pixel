# Manual maestro TWC — personajes pixel art SNES

**Edición:** 2026-11-09 · **Alcance:** Miren, Sara, enemigos, jefes, animales, NPC y futuros juegos de The Wolf Company. **Regla primordial:** una imagen bonita no demuestra que ese personaje esté bien integrado en el juego.

## 1. Fuente de verdad, evidencias y vocabulario

Este documento consolida el aprendizaje del proyecto, pero **no sustituye** los diseños aprobados, los atlas binarios ni las pruebas del repositorio. Ante divergencias, prevalecen (en este orden): decisión explícita del usuario, imagen original aprobada y su hash, artefacto integrado en el commit concreto, prueba reproducible, captura auténtica del motor, y documentación histórica fechada.

No se deben confundir estas condiciones:

| Nivel | Qué demuestra | Qué no demuestra |
| --- | --- | --- |
| Concepto aprobado | Dirección artística elegida por el usuario | Atlas utilizable |
| Original PNG preservado | Fuente de arte identificable | Transparencia ni poses correctas |
| Atlas generado | Fotogramas preparados | Que el motor los emplee |
| Código integrado | La aplicación puede cargar el asset y elegir frames | Que los estados sean alcanzables ni visualmente buenos |
| QA técnica aprobada | Reglas verificadas por tests concretos | Calidad visual a tamaño real |
| **Captura real inspeccionada** | Salida de una ejecución concreta de Flutter/`StagePainter` | Funcionamiento en el teléfono |
| Prueba Android y aprobación | Funcionamiento y aspecto en el dispositivo ensayado | Ausencia absoluta de defectos en todo dispositivo |

Toda ficha debe registrar fecha, rama, commit SHA exacto, pruebas ejecutadas (con resultado real), fuente de la captura, aprobación o rechazo y pendientes. Si falta una evidencia, escribir **NO COMPROBADO**, nunca «validado». Si un dato histórico (prompt, semilla, motor exacto) no consta, registrar **desconocido**: está prohibido inventarlo.

## 2. Ciclo de producción obligatorio

**INSPECCIONAR → DETECTAR → CORREGIR → GENERAR → VER RESULTADO REAL → PROBAR → VOLVER A CORREGIR → VALIDAR → GUARDAR Y DOCUMENTAR.**

Trabajar en microfases recuperables: inspección del personaje actual y su runtime; referencia y contrato visual; poses y atlas; atlas QA; integración; comportamiento; captura real; inspección visual y ajustes; pruebas finales; respaldo. Cada avance pequeño debe quedar en commit verificable en GitHub; registrar SHA y siguiente acción. Evitar repetir trabajos ya terminados o disparar flujos CI costosos sin una hipótesis concreta.

### 2.1 Contrato artístico inalterable

- Preservar **imagen aprobada, PNG fuente, paleta y hashes**. No modificar el original ni regenerarlo silenciosamente; producir variantes con nombres nuevos y trazabilidad.
- Comparar rostro, ojos, pelo, silueta, proporciones, anatomía, ropa, accesorios, sombreado y expresión con la referencia. Prohibido reemplazar al personaje por figuras geométricas/procedimentales que pierdan identidad.
- Estética pixel art 16-bit estilo SNES; legibilidad en el tamaño **real dentro del juego**, no solo en zoom. Contorno limpio, luces coherentes con escena, colores controlados y lectura de acción a primera vista.
- Determinar escala frente a Miren y Sara, posición de pies/centro de apoyo, orientación izquierda/derecha, desplazamiento, sombra y plano de suelo. Para peces y otros seres sin pies, definir ancla anatómica equivalente.
- Si se rehace el dibujo, presentar la nueva referencia al usuario antes de tratarla como aprobada; si una referencia concreta ya está aprobada, respetarla como vinculante.

### 2.2 Producción de poses y atlas

El patrón común existente es **4 columnas × 6 filas = 24 celdas**: reposo, desplazamiento, alerta, ataque, impacto y derrota, con cuatro fases por estado. Es una **base comprobable**, no un límite rígido de seis animaciones ni una garantía de calidad. Se pueden añadir anticipación, preparación, ataque activo, recuperación, salto, caída, lanzamiento, celebración, giro, aterrizaje, etc., con el número de fotogramas que necesite el movimiento. Especificar en el manifiesto cuántos estados y frames tiene realmente cada personaje; si el atlas final no cabe en 4×6, adaptar formato **y** lector Flutter/test, sin truncar estados.

1. Elaborar tabla de poses: ID del estado, número de frames, dirección, acción visual, temporización, pivote, hitbox y evento de golpe/proyectil.
2. Dibujar variantes coherentes con el original. Ni duplicar fotogramas para llenar huecos ni cambiar cara/ropa en mitad de animación.
3. Exportar PNG RGBA real; verificar canal alfa y bordes. No confiar en que la previsualización parezca transparente.
4. Segmentar silueta por alfa/mascara y revisar extremidades y accesorios. **No recortar únicamente por cuadrículas rectangulares** cuando piernas, cañas, guitarras, escobas o poses de caída invaden el espacio de otra celda: puede amputar brazos o mezclar poses.
5. Cada celda con márgenes adecuados, sin invasión de vecinas, sin elementos de otro frame, sin fondos opacos; pies o ancla constantes para que no «flote» la animación.
6. Revisar hoja ampliada y **secuencia reproducida** (no basta inspección estática). Verificar recortes, temblores, sombras, transparencia, simetría y que todos los frames se distinguen.
7. Calcular SHA-256 del original, atlas y proyectiles; proteger arte validado de regeneradores antiguos y de sustituciones por placeholders.

### 2.3 Integración real en Flutter

- Registrar asset en rutas/manifest reales y localizar carga de imagen, clase de enemigo y `StagePainter`. Comprobar que se dibuja **el nuevo atlas**, no fallback antiguo ni duplicado.
- Verificar mapeo `(estado, frame, dirección) → rectángulo correcto`, duraciones, interpolación y precisión en límites de tiempo; evitar que un error flotante salte el frame previsto.
- Respetar pivote, pies/roca/agua, escala, profundidad y orientación. Revisar que armas y proyectiles no aparezcan detrás del cuerpo o fuera de la hitbox sin intención.
- Implementar estado operativo completo: patrulla/aproximación, alerta/anticipación telegráfica, ataque activo, recuperación, impacto/interrupción/invulnerabilidad según reglas, derrota auténtica y desactivación. Un ataque puede necesitar más subestados que los seis renglones genéricos.
- Probar con **Miren y Sara por separado**: colisión, daño, disparos/objetos, esquiva/salto, reacción, derrota, desaparición, repetición y reaparición. No simular derrota estableciendo un contador de golpes si el motor no llega al estado `defeated`.
- Validar que aparece en el capítulo correcto y que no altera otros personajes ni otras escenas.

### 2.4 Captura auténtica e inspección

Una «captura real» es un archivo **producido por ejecutar el motor Flutter real en un commit identificable**, por ejemplo test/widget de `HermanasGame` + `StagePainter` con `RepaintBoundary.toImage`; guardar PNG/JPG/WebP/GIF y el test/procedimiento que lo originó. Formato de referencia 20:9 (p. ej., 1000×450). No es captura real un concepto generado por IA, un montaje pintado a mano, una maqueta reconstruida, un sprite aislado sobre un fondo inventado ni una imagen enviada sin procedencia.

Conservar tres pruebas separadas: **(A) referencia aprobada**, **(B) atlas PNG definitivo**, **(C) captura real del motor**. Revisar visualmente C, no simplemente constatar que el fichero existe. Capturar reposo, desplazamiento, alerta, ataque anticipado/activo, impacto y derrota verdadera; añadir subestados específicos. Registrar capítulo, viewport, SHA, prueba, fecha y qué se ve. En escenas con salto/agua comprobar plataformas y suelo. La captura Flutter no sustituye la prueba Android en pantalla real; anotar el escalón de evidencia pendiente.

## 3. Problemas reales sufridos y prevención

| Síntoma histórico | Causa o riesgo detectado | Corrección y prueba preventiva |
| --- | --- | --- |
| Piernas, brazos, escoba o caída cortados; restos en celda vecina | Rebanado rectangular de atlas con siluetas superpuestas | Segmentar por alfa; reconstruir/corregir celda, visualizar transparencia y atlas reproducido |
| 24 celdas presentes pero animación pobre o incompleta | Relleno de tabla sin fases suficientes, duplicados o frames inaccesibles | Tabla de estados específicos; secuencia real y test de cada frame/transition |
| Rival mostraba índice `12,12,14,15` en vez de `12,13,14,15` | Comparación de tiempos en límite de punto flotante | Tolerancia numérica medida (en caso histórico `1e-8`); test exactamente en fronteras |
| Figura «genérica» o demasiado simple | Sustitución procedural o mala correspondencia con referencia | Rehacer sobre referencia vinculante; comparar rasgos y calidad SNES a escala real |
| PNG aparentemente sin fondo pero opaco | Transparencia visual simulada o canal alfa ausente | Inspeccionar RGBA/alpha por píxel, fondo de contraste y QA técnica |
| Personaje salta visualmente al morir | Pivote/pies cambian entre cuadros o se recorta silueta | Ancla única; inspección de todos los frames a escala gameplay |
| Ataque parece acertar pero mecánica falla | Hitbox, ventana activa, proyectil o cooldown incoherentes | Tests temporales de anuncio, impacto único, recuperación, Miren/Sara y alcance real |
| Test de derrota «verde» sin enemigo derrotado | Se cambian `hits` sin ejecutar mecánica del juego | Disparar acción de protagonista, assert `defeated == true`, captura del estado real |
| Imagen espectacular que no coincide con el juego | Confundir concept art/simulación con captura | Etiquetado A/B/C y captura `StagePainter` de ejecución trazable |
| Se ve atlas viejo pese a subir uno nuevo | Asset manifest, caché, ruta, generador o fallback obsoleto | Inspección del loader, hashes, commit, screenshot del runtime y limpieza controlada |
| Assets originales perdidos/sobrescritos | Regeneración y nombre idéntico | Conservar originales inmutables y hashes; no generar encima de aprobados |
| Build de pruebas falla por código de otra escena | CI global incluye pruebas/recursos no relacionados | Distinguir fallo propio de ajeno, corregir sin regresiones, repetir suite focalizada y luego global |
| Workflow pasa tests pero falla al subir binarios | Conflicto de `git rebase` entre ramas con PNG | Commits pequeños, base remota actual y verificación SHA antes y después; no asumir éxito por logs parciales |
| GitHub Actions gasta cuota y envía avisos excesivos | Disparos CI repetitivos para revisar arte | Workflow manual/focalizado, agrupar checks justificados, no relanzar por rutina |
| No llega ZIP/PNG o se atribuye a «limitación» | Transferencia binaria no verificada o nombre alternativo | Inspeccionar recursos disponibles, confirmar tamaño/hash; transferencia por blob base64 cuando proceda |
| Se declara «listo» con solo generación, CI o vistas parciales | Confusión entre niveles de evidencia | Checklist y etiquetas de evidencia; nunca certificar Android sin prueba física |

## 4. Casos positivos y lecciones replicables

### Limpiador de danza (`dance_cleaner`)

El usuario aprobó su identidad visual: uniforme azul, escoba, sombreado SNES. Se preparó atlas de 24 celdas y animación/ataque. Una QA inicial de derrota era insuficiente al no ejecutar el golpe real: se corrigió probando el ataque de Sara y comprobando `cleaner.defeated == true`. Se documentó ejecución Actions **`42018586860`** satisfactoria y evidencias de captura en `qa/dance_cleaner_flutter/`. **Lección:** la prueba debe accionar la mecánica auténtica y renderizar el estado resultante.

### Señora rubia de bata (`slipper_neighbor`)

Referencia vinculante: gafas, bata blanca, pelo rubio y **chancla verde**. Separar atlas de la mujer y proyectil `green_slipper.png` permitió mantener identidad y representar trayectorias/ataque. Evidencias documentadas `qa/slipper_neighbor_flutter/` y ejecuciones **`42021699403`** y **`42022195350`**; esta última satisfactoria. **Lección:** proyectiles con identidad propia, telegráfica visible, sincronización y comprobación de ambas protagonistas.

### Guitarrista de danza (`guitar_musician`)

La silueta y la guitarra son parte inseparable del contrato visual. Atlas `assets/images/enemies_new/guitar_musician_atlas.png`; existen pruebas focalizadas `test/guitar_musician_rc7_{gameplay,render,release}_test.dart` y material `qa/guitar_musician_flutter/`. **Lección:** las herramientas/armas deben mantenerse legibles en todas las poses, sobre todo ataque y derrota. Consultar logs/commit específico para certificar el resultado actual; la existencia de ficheros no equivale a un nuevo test ejecutado.

### Jugador rival clásico (`rival`), campo de entrenamiento

Se reemplazó una versión visual insuficiente con `assets/images/enemies_new/rival_player_atlas.png`, lector `lib/rival_player_atlas.dart` e integración en `lib/main.dart`. El test detectó el borde temporal `12,12,14,15`; tras corregir precisión, ejecución enfocada **`42577421529` (#11) SUCCESS** y capturas auténticas `qa/enemy_verified_render/classic_rival.{jpg,webp,gif}`. El usuario vio una imagen real y expresó que era mucho mejor. **Lección:** repetir referencia → atlas → mapeo temporal → motor real → aprobación, sin confundir jugador rival con entrenador rival (`rival_coach`).

Estas son **evidencias históricas documentadas**, no afirmación de haber reejecutado todas las pruebas al redactar este manual.

## 5. Protocolo reproducible y cierre

1. Leer `AGENTS.md`, `CONTINUIDAD_TWC.md`, `docs/continuidad/ESTADO_OPERATIVO.md`, `docs/DECISIONES_APROBADAS.md` y este manual. Confirmar rama y HEAD remotos; conservar cambios preexistentes.
2. Crear ficha desde `PLANTILLA_FICHA_PERSONAJE.md`. Localizar y preservar referencia original; generar SHA-256.
3. Dibujar y exportar poses, atlas y proyectiles; ejecutar verificadores existentes como `python3 tools/verify_enemy_art.py` **si aplica al asset**. No inferir que su éxito cubra estética.
4. Integrar en Flutter y crear tests específicos del nuevo enemigo/personaje. Ejecutar `flutter analyze` y `flutter test` dirigidos y generales cuando el entorno tenga Flutter; distinguir los no ejecutados de los pasados.
5. Ejecutar captura real 20:9 de `StagePainter`, guardarla con metadatos y abrirla para inspección humana; iterar. Test Android si está disponible, registrar dispositivo y versión.
6. Commit pequeño; comprobar contenido, árbol, SHA y rama remota tras push. Actualizar `ESTADO_OPERATIVO.md` y `BITACORA.md`; registrar fallos, runs y capturas verdaderas. Mantener posibilidad de rollback.
7. Etiquetar **APROBADO VISUALMENTE**, **INTEGRADO**, **VALIDADO EN FLUTTER**, **PROBADO EN ANDROID** por separado. «Listo para nueva versión» solo cuando estén cumplidos los niveles exigidos para esa versión.

### Checklist de aceptación

- [ ] Referencia aceptada preservada con SHA y procedencia.
- [ ] Originales intocados y atlas RGBA sin recortes/solapamientos.
- [ ] Tabla de todos los estados necesarios, frames distintos y anclas estables.
- [ ] Integración, frame lookup y mecánicas verificadas con Miren y Sara.
- [ ] Pruebas focalizadas ejecutadas, resultado y commit anotados.
- [ ] Captura **real** reproducible del motor en 20:9 y **abierta/inspeccionada**.
- [ ] Comparación A/B/C revisada a tamaño de juego; correcciones aplicadas.
- [ ] Prueba Android anotada o marcada expresamente como pendiente.
- [ ] Commits/GitHub confirmados y copia de seguridad independiente disponible.

## 6. Respaldo contra pérdida de GitHub y reutilización

Mantener al menos **tres ubicaciones** para la documentación: (1) archivos versionados en el repositorio, (2) paquete ZIP independiente descargado al ordenador del usuario, (3) copia adicional externa o en la nube, con verificación SHA-256. El paquete documental debe contener manual, ficha, estándares, decisiones y bitácoras pertinentes; **no es un respaldo de la totalidad del juego** ni sustituye los PNG originales, que requieren copia aparte si se desea reconstruir el proyecto sin GitHub. Verificar que el ZIP abre, no contiene secretos y que el manifiesto de hashes coincide. Si se restaura en otro GPT, entregar manual + ficha + referencias visuales aprobadas + recursos exactos, informar del motor y exigir prueba de integración real.

**Documentación asociada:** `docs/TWC_PIPELINE_PERSONAJES_CALIDAD_DESDE_ORIGEN.md`, `docs/continuidad/METODO_ENEMIGOS_SNES_GPT_FUTURO.md`, `docs/continuidad/ENEMIGOS_RC7_ESTADO.md`, `docs/continuidad/ARGA_ENEMIGOS_ANIMACIONES_2026-11-08.md`, `docs/FRAMEWORK_SNES_TWC/PROTOCOLO_ACEPTACION_VISUAL.md`, `docs/FRAMEWORK_SNES_TWC/ERRORES_Y_SOLUCIONES.md`, `docs/FRAMEWORK_SNES_TWC/02_PERSONAJES_ESTANDAR_MIREN_SARA.md` y `docs/FRAMEWORK_SNES_TWC/TRANSFERENCIA_BINARIA_GITHUB.md`.
