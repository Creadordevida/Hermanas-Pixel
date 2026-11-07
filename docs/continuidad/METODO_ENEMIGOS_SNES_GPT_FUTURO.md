# Método reproducible de personajes SNES — The Wolf Company

**Fecha:** 2026-11-07. **Proyecto de origen:** *Las aventuras de Miren y Sara* (Flutter/Android).  
**Rama de trabajo:** `work/revision-visual-20261028-continuidad` · PR #5.  
**Objetivo:** conservar el proceso de creación e integración de personajes para próximas tandas y para un futuro GPT personalizado capaz de crear juegos de distintos géneros con estética 16-bit.  
**Validación de usuario:** después de instalar la RC7 privada en Redmi Note 14, el usuario considera que la calidad gráfica de los enemigos alcanza la estética deseada. Siguen abiertas mejoras de mecánicas y escenarios.

> El éxito se obtuvo con una cadena de decisiones artísticas, reparación de sprites, adaptación al motor y pruebas reales, **no con un único prompt mágico**. Este documento especifica lo comprobable en el repositorio y separa las inferencias de los detalles de generación originales que no se pueden reconstruir.

## 1. El principio artístico vinculante

1. **Aprobar antes el aspecto del personaje completo.** La referencia aprobada es el contrato visual: cara, pelo, silueta, anatomía, proporciones, ropa, colores, accesorios, expresión, iluminación y sombreado. No improvisar otro personaje al fabricar animaciones.
2. **Pixel art de 16 bits tipo Super Nintendo.** Contornos limpios, grupos de píxeles legibles, volumen con sombras agrupadas, pocos colores coherentes por material y silueta reconocible a escala de juego. No tratar un bitmap reducido automáticamente como buen pixel art.
3. **Comparar con las protagonistas en tamaño real.** La calidad se juzga en el escenario y a escala jugable, no solo ampliando la ilustración. Pies, suelo, dirección de luz y perspectiva tienen que casar con Miren/Sara y con el capítulo.
4. **No sustituir la ilustración por figuras procedimentales** ni por iconos simplificados. La identidad aprobada tiene prioridad sobre la facilidad técnica.
5. **Preservar fuentes, atlas y aprobaciones.** El original no se sobrescribe; las reparaciones producen nuevos derivados y se documentan con hashes.

En la tanda de 2026-11-04 los cuatro diseños aprobados fueron: limpiador azul con escoba; músico con guitarra; vecina rubia con gafas, bata blanca y chancla verde; entrenador rival con pizarra blanca. En la tanda anterior: toro de Estafeta, corredor sanferminero, rey de Navarra, robot de limpieza, aficionado rival y turista borracho. Las referencias de robot y corredor tuvieron aprobación artística explícita. **No equiparar aprobación de un boceto con validación de todas las poses finales.**

## 2. Del diseño a un atlas usable

**Formato utilizado en la tanda de cuatro:** PNG con transparencia, rejilla **4 columnas × 6 filas = 24 celdas** por personaje. La correspondencia de las seis filas con los estados del motor es:

| Fila (0–5) | Estado `FourEnemyPose` | Propósito visual |
|---|---|---|
| 0 | `idle` | Respiración/reposo sin cambios bruscos de silueta |
| 1 | `walk` | Marcha con alternancia de apoyos y dirección consistente |
| 2 | `warning` | Aviso reconocible antes del ataque; permite reaccionar |
| 3 | `attack` | Extensión real del arma/objeto y contacto visual |
| 4 | `hit` | Impacto/interrupción legible |
| 5 | `defeated` | Secuencia de caída y pose final completa |

Cada fila tiene cuatro fotogramas. Requisitos de limpieza:

- Separar las poses por **silueta y transparencia**, no cortar ciegamente rectángulos cuando un brazo, escoba, guitarra o pierna invaden la celda vecina. La amputación de la caída fue una incidencia real de este proyecto.
- Comprobar que cada celda contiene figura y alfa correcto; eliminar contaminación visual entre columnas, halos o fondo opaco.
- Mantener un mismo punto de apoyo de pies y escala entre fotogramas; centrar visualmente el personaje sin provocar saltos verticales o cambios de tamaño.
- Conservar las partes sobresalientes de ataque y caída; no amputarlas para ajustarlas a una caja.
- Evitar fotogramas idénticos disfrazados de animación; cada pose debe tener un propósito.
- Producir atlas legible en reposo y movimiento. Probar el personaje mirando en ambas direcciones cuando el motor aplica espejo.

**Verificación automática recuperada:** `tools/verify_enemy_art.py` comprueba SHA-256 de activos protegidos mediante `qa/enemy_art_20261031/locked_asset_hashes.json`, canal alfa con extremos 0/255, 24 celdas no vacías y 24 fotogramas distintos para atlas listados. El documento `docs/continuidad/ENEMIGOS_RC7_ESTADO.md` cita también `tools/verify_four_enemy_art.py` y `FOUR_ENEMY_ART_PASS` de una copia local recuperada, pero **ese script no se ha localizado en la ruta remota indicada**. No atribuirle verificaciones remotas actuales.

### Activos de ejemplo

- `assets/images/enemies_new/dance_cleaner_atlas.png`
- `assets/images/enemies_new/guitar_musician_atlas.png`
- `assets/images/enemies_new/slipper_neighbor_atlas.png`
- `assets/images/enemies_new/green_slipper.png`
- `assets/images/enemies_new/rival_coach_atlas.png`
- `assets/images/enemies_new/{robot,supporter,tourist,navarre_king,estafeta_bull,sanfermin_runner}_atlas.png`

Los archivos `assets/images/enemies_new/robot_approved_source.json` y `sanfermin_runner_approved_source.json` conservan especificaciones de arte aprobado. Las hojas fuente individuales de varios personajes constan en la documentación histórica. **Incidencia abierta:** `qa/enemy_art_20261104/approved_reference.png` devolvió 404 en esta revisión: localizar y respaldar el original grupal antes de afirmar una comparación exacta con esa imagen. No regenerar la referencia de memoria.

## 3. Integración en el motor Flutter

Piezas que deben mantenerse separadas:

1. **Arte**: PNG auténtico, con recorte de celdas, transparencia y escala.
2. **Comportamiento**: `lib/four_enemy_behaviors.dart` define `FourEnemyPose`, `FourEnemyMotion`, avisos, ataque, recuperación, golpe, derrota y aparición según capítulo.
3. **Integración**: `lib/main.dart` registra las rutas en la carga de recursos, crea enemigos en el capítulo correcto, dibuja el fotograma adecuado en `StagePainter`, calcula colisiones/proyectiles y habilita el enemigo para la compilación.
4. **Puerta de visibilidad**: `enemyArtValidated[kind]` solo se activa tras las pruebas; `TWC_GAMEPLAY_PLAYTEST=true` permite probar candidatos sin confundirlos con arte validado para la versión normal.
5. **Pruebas**: contratos de aparición, interacción con ambas protagonistas, animación capturada y versión normal.

Parámetros reales de `FourEnemyMotion` (tanda de cuatro): aviso 0,52 s general, 0,62 s músico y 0,75 s vecina; ataque 0,44 s con impacto después de 0,11 s; recuperación 2,4 s o 3,6 s para la vecina. El daño **nunca debe aplicarse al comienzo del aviso**. Cada ataque entrega un único impacto, se puede esquivar y queda interrumpido al recibir daño. Estos números son los actuales de ese modelo, **no constantes universales del futuro GPT**.

Distribución aprobada: limpiador y músico en etapa 5 (Danza), vecina en etapa 0 (salida de casa), entrenador en etapa 4 (Fútbol). Cada uno tiene tres posiciones relativas al recorrido, codificadas en `fourEnemySpawns`. El proyectil `green_slipper.png` de la vecina debe verse separado del cuerpo.

**No confundir con los seis anteriores:** usan también `lib/new_enemy_behaviors.dart`, `lib/new_enemy_hitboxes.dart` y lógica propia en `main.dart`; sus seis banderas artísticas seguían en `false` antes de RC7, aunque la APK de prueba privada los incluyó con `TWC_GAMEPLAY_PLAYTEST=true`. La satisfacción visual del usuario en RC7 es evidencia positiva en dispositivo, pero no reemplaza una auditoría individual documentada de esas seis banderas.

## 4. Ver en el juego, no solo en el PNG

Para cada personaje:

1. Montar **`HermanasGame` real** dentro de `flutter_test`, seleccionando la etapa correspondiente. En Danza, respetar selección obligatoria de Sara.
2. Encontrar su `StagePainter`; dibujarlo a **1000×450 (20:9)** mediante `RepaintBoundary.toImage(pixelRatio:1)`.
3. Capturar **seis momentos**: reposo, preparación/extensión de ataque en varios tiempos y dos momentos de derrota auténtica.
4. Provocar la derrota con el proyectil real de Miren (balón) o Sara (peine), y comprobar `enemy.defeated == true` **antes** de fotografiar la caída. Un test inicial que asignaba directamente los impactos no garantizó una derrota real: se corrigió.
5. Inspeccionar visualmente las imágenes: silueta, manos, arma, sombra, pies, bordes del atlas, profundidad y escala frente a protagonistas.
6. Repetir tras cada corrección. Una prueba técnica verde no certifica por sí sola calidad artística.

Ejemplos reproducibles:
- `test/dance_cleaner_rc7_render_test.dart` → `qa/dance_cleaner_flutter/`.
- `test/guitar_musician_rc7_render_test.dart` → `qa/guitar_musician_flutter/`.
- `test/slipper_neighbor_rc7_render_test.dart` → `qa/slipper_neighbor_flutter/`.
- `test/rival_coach_rc7_render_test.dart` → `qa/rival_coach_flutter/`.

Se usaron workflows `.github/workflows/*-rc7-qa.yml` específicos con `flutter analyze`, pruebas de comportamiento y seis capturas, comprobación de firma PNG y dimensión 1000×450. Las capturas se conservaron en Git cuando el almacenamiento de artifacts de Actions era insuficiente. **GitHub CI no sustituye instalación y revisión en Android físico**.

## 5. Microtareas y control de versiones: la otra mitad del éxito

Para evitar las conversaciones truncadas y no perder trabajo:

1. Consultar **solo** los archivos del personaje elegido y el último estado remoto, no reconstruir todo el repositorio.
2. Trabajar **un enemigo y una fase** cada vez. Orden: (a) fuente/atlas, (b) alfa y celdas, (c) motor/animaciones, (d) combate/colisiones, (e) capturas reales, (f) aprobación para compilación normal.
3. Realizar un commit recuperable por fase y **leer de nuevo GitHub para confirmar** el SHA/archivo. No dar por guardado un cambio solamente local.
4. Actualizar `docs/continuidad/ENEMIGOS_RC7_ESTADO.md`: estado, archivo, hash/commit, pruebas realmente ejecutadas, defectos y **una próxima acción concreta**.
5. Conservar el arte original y los capítulos de terceros; antes de editar `lib/main.dart`, inspeccionar su versión remota actual para evitar sobrescribir cambios concurrentes.
6. Si falla CI: leer el **paso y log exactos**, corregir una causa y volver a ejecutar. Un `cancelled`, `pending` o push rechazado no es `success`.
7. Solo activar `enemyArtValidated` tras evidencias suficientes. La última comprobación es una APK privada en hardware con pruebas de combate y aspecto; no publicar ni fusionar por defecto.

**Cadena de trabajo en una frase:**  
**INSPECCIONAR → DETECTAR → CORREGIR → GENERAR → VER RESULTADO REAL → PROBAR → VOLVER A CORREGIR → VALIDAR → GUARDAR Y DOCUMENTAR.**

## 6. Plantilla obligatoria para próximos enemigos

Antes de generar el primer sprite, registrar:

- **Identidad:** nombre, capítulo, rol, silueta, cara, ropa, colores, accesorio/arma, iluminación, referencia aprobada y SHA-256.
- **Escala:** relación con Miren/Sara, altura aparente y apoyo exacto de pies.
- **Animación:** atlas transparente 4×6 salvo decisión técnica justificada; estados y cuatro poses por estado, sin invasión de celdas.
- **Ataque:** anticipación visible, alcance, momento de impacto, daño, posibilidad de esquiva, recuperación y contrataque.
- **Interacción:** balón y peine, colisión cuerpo/proyectil, impacto, interrupción, dos direcciones y derrota.
- **Evidencia:** original + atlas + verificador + test de comportamiento + seis capturas de `StagePainter` + CI + observación en móvil.
- **Trazabilidad:** ubicación del archivo, SHA, commit, referencia de ejecución y estado de aprobación.

### Prompt maestro orientativo para el futuro GPT

> Diseña un enemigo para un juego 2D de plataformas con estética SNES 16-bit consistente con las protagonistas y el escenario aportados. Primero propone una referencia de cuerpo completo, silueta legible, paleta/sombreado coherentes, vestuario y accesorio. Espera aprobación artística. Después crea y limpia un atlas RGBA 4×6 de seis estados: reposo, marcha, aviso, ataque, impacto y derrota; cuatro fotogramas por estado, con pies alineados, escala invariable, arma íntegra y ninguna figura invadiendo la celda vecina. Conserva fuente y hashes. Integra el atlas sin sustituir diseños aprobados ni modificar otros capítulos. Prueba aviso esquivable, daño único, interrupción, interacción con ambas protagonistas y derrota. Captura seis PNG auténticos del motor, compara referencia/atlas/juego y reitera las correcciones antes de habilitar el personaje. Guarda cada microfase en GitHub con un punto de recuperación exacto. No anuncies terminado sin evidencia visual y jugable.

## 7. Lo que sabemos y lo que no sabemos

**Confirmado:** atlas 4×6 y seis estados en la tanda de cuatro, modelo `FourEnemyMotion`, recursos integrados, pruebas Dart/Flutter, capturas auténticas 20:9, commits sucesivos y resultado de usuario favorable tras RC7. La compilación privada RC7 se obtuvo en la ejecución `42028211828`, commit fuente `936095822f0722f37f4cce83c4b98a01c5f8dfee`.

**No reconstruido con exactitud:** texto completo de los prompts iniciales de imagen, modelo/semillas/parámetros de generación de cada ilustración, software exacto usado en cada operación de limpieza de píxel, y la referencia grupal maestra faltante en la ruta indicada. No inventar estos datos para un GPT futuro. Se puede reproducir el **proceso de aceptación e integración** y mejorar el archivo de procedencia en nuevas tandas.

**Próxima mejora del propio método:** exigir desde el inicio un manifiesto por personaje con prompt, modelo y versión, semilla (si existe), imagen fuente, aprobación fechada, dimensiones, celdas, hash, herramientas/transformaciones y capturas; así la próxima retrospectiva será completamente reproducible.
