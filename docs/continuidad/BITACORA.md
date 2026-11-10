## 2026-11-10 — Portero: seis poses auténticas reconstruidas

Se reconstruyeron los seis dibujos dañados y se conservaron las 18 poses válidas. Derivados RGBA y hashes en `qa/goalkeeper_rebuild_20261109/rebuilt_poses/`. Siguiente microfase: atlas de 24 celdas y auditoría. [Continuidad](PORTERO_RC7_ESTADO.md).

## 09/11/2026 — ocho separadores QA de la Plaza, sin activar

- Se prepararon dos sprites de **pixel art** a tamaño de juego, un plátano de sombra (240×275) y una farola ornamental (98×285), con transparencia binaria para retirar halos. Los PNG fueron guardados en `qa/quiosco_inbox/separators/`, blobs verificados por Git, commit `6389a46`. El boceto de pilastra aislada se descartó para evitar columnas artificiales entre edificios.
- `tools/preview_quiosco_separator_candidate.py` crea **solo un montaje de prueba**, no altera Flutter ni los 39 assets actuales. Distribuye cuatro árboles y cuatro farolas en ocho de las diecisiete uniones, conserva nueve tal cual y evita colocar piezas encima del quiosco único en x=17.920..19.090.
- Generada e inspeccionada localmente la hoja de 17 uniones y el mundo de 37.440×390. La variante con 17 decoraciones se rechazó por repetitiva; la versión escasa de ocho mejora la naturalidad visual. **Aún se aprecian cortes de arquitectura no cubiertos**, por lo que el montaje sigue marcado `NOT_FINAL`.
- `python3 tools/test_quiosco_connector_edges.py`: PASS sintético; `python3 -m py_compile tools/preview_quiosco_separator_candidate.py`: PASS. No se ha realizado Flutter/StagePainter de esta variante ni prueba Android. No APK, no merge.
- Siguiente paso: corregir específicamente los cortes sin resolver, activar solamente tras revisión real de StagePainter en todo el recorrido, comprobar hashes de 39 paneles y hacer regresión sin tocar mecánicas.

## 09/11/2026 — ordenación alternativa descartada por inspección visual

- Se probó localmente una optimización de las 18 fuentes que pondera x2 las fachadas, ventanas y soportales (y=100..329), frente a x0,7 para cielo y extremo de suelo. Se regeneraron los 37.440px y 39 WebP candidatos, y se inspeccionaron las 17 uniones.
- **Resultado rechazado:** aunque algunos empalmes se aproximan más, aparecen nuevas discontinuidades claras entre coronaciones de edificios, alturas de arcos y tejados. La mejora de una función de color no implica continuidad constructiva.
- Se restauró el optimizador original; **no se sube ni activa** la ordenación alternativa, ni se toca ningún panel de producción.
- Prueba de retoque generativo de un panel: redibujó globalmente fachadas y cambió resolución, por lo que también fue descartada. Se conserva solo como estudio visual fuera del juego.
- **Dependencia real pendiente:** corregir o sustituir localmente las ilustraciones incompatibles con bordes comunes nativos a 960×390, revisando cada composición como arquitectura, no como un simple fundido de color. Después StagePainter y revisión del barrido 0..37440. Sin APK ni merge.

## 09/11/2026 — segunda pasada de las 17 uniones: eje arquitectónico

- Código `847cb88`: el montador puntúa los 96 posibles ejes dando mayor peso a fachadas (y=100..329) y restringe la costura serpenteante a un eje casi vertical. No altera las imágenes maestras ni la ruta de juego activa.
- Regenerado el candidato completo de 37.440 × 390 con sus 39 WebP de staging. Se compararon visualmente las 17 uniones con la versión anterior: desaparecen varios fragmentos de ventanas y fachadas con fundido irregular; todavía se aprecian límites estructurales entre edificios de origen incompatible.
- `python3 tools/test_quiosco_connector_edges.py`: PASS sintético. `py_compile`: PASS. 39/39 paneles candidatos presentes. **Sin Flutter ni Android nuevos; no lanzar Actions, APK o merge.**
- **Puerta de calidad todavía cerrada:** queda reconstrucción manual de geometría de algunas fachadas y posterior barrido StagePainter. Los paneles activos se conservan intactos.

## 2026-11-09 — Quiosco, microfase costuras

Cambio: `tools/assemble_quiosco_18_art_candidate.py` (commit `af1127c`), reducir mezcla de 96px en cielo a feather de 6px y evitar doble exposición. Se generó el candidato completo y 17 contactos locales, revisados antes/después; mejora visible del cielo, pero arcos y cornisas todavía discontinuos. `tools/test_quiosco_connector_edges.py` PASS sintético; Flutter/Android no ejecutados. Activos intactos. Siguiente: restaurar continuidad arquitectónica, luego Flutter y QA visual.

## 2026-11-09 — Comparsa del Ayuntamiento: tres enemigos activos

Gigante, Caravinagre y zaldiko integrados exclusivamente en la ruta normal de Ayuntamiento. Verificados los tres atlas de 24 poses y la transparencia en Flutter. 12 pruebas superadas y análisis sin incidencias. StagePainter 1000 × 450 revisado con combate de ambas protagonistas. [Continuidad](COMPARSA_AYUNTAMIENTO.md). Siguiente microfase: partida en el Redmi Note 14 con la próxima compilación Android.

## 2026-11-09 — Comparsa: atlas del zaldiko

24 poses guardadas con el caballo oscuro, portador y bola al cordón. El contacto usa el balanceo bajo. [Continuidad](COMPARSA_AYUNTAMIENTO.md). Siguiente microfase: cerrar las pruebas de combate y la revisión del render conjunto.

## 2026-11-09 — Comparsa: atlas de Caravinagre

24 celdas de Caravinagre revisadas y guardadas con sus apoyos y espuma. [Continuidad](COMPARSA_AYUNTAMIENTO.md). Siguiente microfase: guardar el atlas del zaldiko y completar la prueba conjunta en Flutter.

## 2026-11-09 — Comparsa del Ayuntamiento: Gigante probado y activo

Corregido el alfa del atlas tras detectar un recuadro en el primer render. Cuatro pruebas Flutter superadas y capturas StagePainter de 1000 × 450 inspeccionadas. Portador visible ante la fachada consistorial. Tres impactos durante recuperación con balón o peine. El WebP final conserva exactamente los píxeles RGBA revisados. Siguiente microfase: Caravinagre. [Continuidad](COMPARSA_AYUNTAMIENTO.md).

## 2026-11-09 — Comparsa del Ayuntamiento: atlas candidato del Gigante

Referencia visual aprobada y tabla de poses guardadas en [COMPARSA_AYUNTAMIENTO.md](COMPARSA_AYUNTAMIENTO.md). Atlas de 24 poses con portador visible y pivote de apoyo. La siguiente microfase es integrar y comprobar en Flutter el giro, el golpe único, la recuperación y la derrota con ambas protagonistas.

## 2026-11-09 — Fauna: paloma integrada y validación conjunta Flutter

Atlas RGBA de 32 poses `assets/images/enemies_hifi/pigeon_atlas.png` (SHA-256 `c94dda99e5ab55d6299dd086807c657b9d28e066e40b16d757a19dde6b2e3135`). Una orientación de referencia y pivote común para suelo y aire. Despegue con agachada, vuelo con batida y planeo, aviso de picado de 220 ms y dirección comprometida, recuperación de altura, aterrizaje con patas extendidas y caída visible hasta tocar suelo. La caja de impacto sigue el cuerpo y deja libres las puntas de ala. Se conserva el arte anterior. Diez pruebas Flutter de fauna, ocho de PNG y análisis Dart focalizado superados. StagePainter 1000 × 450 inspeccionado en los cuatro animales, con ataque, esquiva y derrota con Miren y Sara. Las mejoras están activas en la ruta normal de esta rama. Queda probar en el Redmi Note 14 la próxima compilación Android, incluidos controles, legibilidad y fluidez.

## 2026-11-09 — Fauna: dóberman integrado y probado en Flutter

Atlas RGBA de 24 poses `assets/images/dog/doberman_atlas.png` (SHA-256 `577f029dfd354ec4100c8c36aafef4b0a3c36afacac5525bcf37ede6b2e01fb4`). Pecho profundo, orejas erguidas y galope a 12 fps. Mantiene velocidad, detección y dos impactos. Prueba real con Miren y Sara: primer proyectil aturde y el segundo derrota, con aviso y esquiva de mordisco. Nueve pruebas Flutter de fauna y siete de recursos superadas. Revisadas capturas StagePainter 1000 × 450, incluido aturdimiento. Queda Android. Siguiente animal: paloma.

## 2026-11-09 — Fauna: dálmata integrado y probado en Flutter

Atlas RGBA de 24 poses `assets/images/dog/dalmatian_atlas.png` (SHA-256 `7dd7e4d5818725c82100488b9c2bc52e940bec06a478571a5999657da39151ad`). Pata larga, torso estrecho y manchas coherentes. Marcha de 5 fps y carrera de 8 fps, con velocidad y resistencia originales. La zona de impacto del proyectil sigue el cuerpo más alto. Los golpes finales de ambos perros muestran primero retroceso y luego caída. Nueve pruebas Flutter de fauna y siete de recursos superadas. Inspeccionadas capturas reales de StagePainter a 1000 × 450. Queda Android. Siguiente animal: dóberman.

## 2026-11-09 — Fauna: perro marrón integrado y probado en Flutter

El atlas de `7c47b577` ya se carga en la ruta normal. Mordisco con dos poses de preparación, un solo contacto frontal a los 240 ms y recuperación. Paseo y carrera separados, pivote de pies común y caja de impacto ajustada al cuerpo. Flutter 3.47.8 pasó las 9 pruebas de fauna, incluida la escena con marcha, mordisco, esquiva, balón y peine con Miren y Sara. Capturas auténticas de StagePainter de 1000 × 450 inspeccionadas. Los originales siguen disponibles. Una prueba antigua de `dog_mechanics_test.dart` espera siete capítulos y la rama tiene ocho. Pendiente validar en Android. Siguiente animal: dálmata.

## 2026-11-09 — Fauna: atlas candidato del perro marrón

Guardado `assets/images/dog/brown_atlas.png`, SHA-256 `8b0520024c3ce27549790e5438e8a86513374b77e2ddb029e23680edec9ce317`. Revisadas 24 celdas distintas, transparencia binaria, márgenes limpios y apoyo en y=94. Los PNG originales permanecen en `assets/images/dog/`. La tabla de fases está en [FAUNA_RENOVACION.md](FAUNA_RENOVACION.md). En este punto el atlas aún no sustituye el arte en la ruta de juego. La siguiente microfase es comprobar mordisco, esquiva y derrota en Flutter con Miren y Sara y revisar capturas de StagePainter antes de activar el atlas.

## 2026-11-09 — Quiosco: siete capturas Flutter auténticas del candidato, sin integrar

GitHub Actions 42637909799 y 42638008924 SUCCESS. Test real Flutter `test/quiosco_candidate_flutter_preview_test.dart`: 7 cámaras, 1000x450, panorama de 5782x390 importado de ZIP subido; artefacto descargado y comprobado localmente, capturas visibles en conversación. Es CustomPainter QA aislado; NO StagePainter, gameplay ni APK. El render muestra quiosco bien visible pero repetición de edificios; el escenario de 37440px sigue sin reconstruir. Última documentación específica commit d8cf9569364d5fb66677fb6efd6dd2d74cb19cd9. No modificar assets activos ni fusionar. Siguiente fase arte continuo completo y prueba StagePainter después de completar 39 paneles.

## 2026-11-09 — Quiosco: QA de uniones internas probada

Confirmado **SUCCESS** en ejecución GitHub Actions https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/42619854509 (SHA 7169e20952a60c5b7ea5a146bd2854b78235e470). Incorpora test sintético que detecta un corte RGB brusco entre núcleo y conector, además de test de solapamiento, montaje y contrato geométrico. Registrada nueva herramienta `tools/audit_quiosco_connector_edges.py` y actualizada la documentación principal, commit 0374777aeaf33f93ea35f924e8c77b1b4564a590. No hay seis panoramas definitivos, no se han actualizado 39 WebP activos y no existe captura StagePainter de esta reconstrucción. Mantener RC antigua intacta, sin APK ni merge. Próxima acción: composición visual de los sectores a partir de arte original diferente y QA visual auténtico.

## 2026-11-09 — Quiosco conectores, control visual sin sustitución incompleta

Se ha incorporado y comprobado remotamente `tools/preview_quiosco_connector_seams.py` commit ba09be218a3ddad87bb4995679127e3e81188a45. Genera recortes reales de fuentes y marcas de cinco juntas para evaluar continuidad core/conector antes de integrar. Documento principal actualizado commit 5c0911cb01b2cfa384a49e6db92fa9c050ea5fe6. No existen aún seis núcleos PNG definitivos disponibles: sin nueva imagen StagePainter y sin sustitución del fondo. Única captura Flutter existente corresponde a la versión anterior qa/quiosco_rc7_flutter/800x450_18200.png. GitHub Actions permanece en modo manual por gasto; no se ha lanzado CI. No APK ni merge. Siguiente acción: conseguir el arte original completo, generar los sectores A/B/C, auditar visualmente y capturar el juego real.

## 2026-11-09 — Quiosco: montador de arte por sectores

Nuevo `tools/build_quiosco_reconstruction.py` guardado y re-leído en GitHub, commit `ab549dc912fcdfe92dc6c72f92a9f1ad0c54173d`. Montador protegido para seis PNG originales exactos, 39 paneles de staging WebP sin sobrescribir activos, manifiesto con hashes y medidas de uniones. Documentación específica actualizada en `docs/continuidad/QUIOSCO_RC7_RECONSTRUCCION_Y_QA.md`, commit `95a69e3a8a99c80660633e62807c9e2354370cd9`. Falta crear y transferir panoramas completos distintos; candidato recortado 2172x390 solo en conversación. NO render Flutter/Android ni aprobación artística; sin APK ni merge. Siguiente acción: crear biblioteca artística original y revisar composición antes de integrarla.

## 2026-11-09 — Quiosco: inspección visual de 13 ilustraciones y prueba de barrido conceptual

Inspeccionadas realmente las trece imágenes de la conversación, todas 2172×724. Siete sin quiosco y seis con quiosco completo o parcial: usar todas duplicaría el monumento. Montado localmente un prototipo gráfico aislado de ocho paneles (7.680×390) sin estirar proporciones, con un único quiosco; creada también animación de cámara conceptual. La inspección muestra **discontinuidades arquitectónicas visibles** y una cobertura insuficiente del recorrido 37.440 px; no se ha incorporado el mosaico defectuoso a Flutter. Registrado criterio, selección de archivos y pendientes en `docs/continuidad/QUIOSCO_AUDITORIA_CANDIDATOS_2026-11-09.md`, commit `cd6cf4c`. Los GIF/PNG de la conversación son PREVISUALIZACIÓN, no StagePainter. Próxima acción: crear obras originales que continúen las fachadas entre límites y terminar la cobertura sin duplicados, luego prueba Flutter. No APK / no merge.

## 2026-11-09 — Quiosco: diagnosis de renderizado y corrección del contrato de parallax

Inspección directa de `lib/main.dart` (líneas 3083–3102): `_quioscoBackgroundRC7` usa 39 paneles completos a `x=i*960-cameraX` y los escala en altura a `groundY`; no hay todavía planos lejanos e intermedios independientes. La nueva propuesta debe mantener quiosco, fachadas físicas, suelo y objetos a 1:1 y reservar 0.30/0.56 SOLO para elementos realmente distantes, para evitar monumentos flotantes. Corregido `qa/quiosco_rc7_art_rebuild_plan.json` commit `4b28528d`; aún NO se ha modificado el renderizador Flutter. No se han creado los seis sectores completos originales ni se han ejecutado pruebas. Siguiente acción: reunir arte autoral suficiente y crear capas independientes reales antes de activar renderer.

## 2026-11-09 — Quiosco: constructor de arte por sectores y auditoría de juntas

Guardados y releídos en GitHub `tools/build_quiosco_sectors_candidate.py` (commit `ba3fe80f`), `tools/audit_quiosco_candidate_seams.py` (`08133cbc`) y actualización de `docs/continuidad/QUIOSCO_RC7_RECONSTRUCCION_Y_QA.md` (`404e0549`). Nuevo constructor requiere seis panoramas originales completos con dimensiones nativas, no rellena con repeticiones; conserva quiosco único y crea ZIP candidato de 39 paneles sin activar en Flutter. Auditoría mide 38 juntas pero no certifica arte. Todavía no están las seis panorámicas nativas; no se ha importado arte nuevo, ejecutado el constructor, Flutter, Actions ni APK. Siguiente paso: producir material original suficiente y examinar composiciones en movimiento, manteniendo intacto fondo actual.

## 2026-11-09 — Quiosco: reconstrucción artística aprobada, planificación versionada

Recuperado diagnóstico de 163 fragmentos / 11 recortes únicos / 39 paneles. Usuario autoriza guardar en la rama y aprueba reconstrucción por grandes sectores, quiosco único protagonista y tres planos sin alterar jugabilidad. Guardados `qa/quiosco_rc7_art_rebuild_plan.json` y `tools/check_quiosco_rebuild_plan.py`, con plan de 6 sectores y contrato de geometría; documentación actualizada en `docs/continuidad/QUIOSCO_RC7_RECONSTRUCCION_Y_QA.md`. Último commit de documentación `fea5321677782becefdaaf403671ff0ee655811c`. Se confirmó lectura de los dos nuevos archivos remotos. Primer candidato PNG de fachadas solo en conversación; NO subido, integrado, aprobado ni probado en Flutter. Pendiente transferencia y composición gráfica real, QA visual dinámica y capturas StagePainter. Ninguna APK ni merge.

## 2026-11-04 — Enemigos preparados para la RC7 conjunta; recortes de producción corregidos

Auditado HEAD 886a4af259241efd3e68129a6c85e84f6ca848bf, PR #5 abierta sin merge. Los 21 PNG protegidos son idénticos por SHA Git a la entrega verificada del 1/11. El workflow manual rc7-enemies-private-playtest.yml ya habilita TWC_GAMEPLAY_PLAYTEST=true: los seis nuevos aparecerán en la prueba privada sin declarar aprobación artística.

Detectado y corregido un desajuste de entrega: la QA regeneraba sprite_bounds.g.dart, pero la compilación RC7 no lo hacía y el archivo comprometido tenía recortes antiguos. Exportadas localmente 59 poses desde los PNG REALES recuperados del HEAD actual; comprobados límites dentro de cada imagen. Añadido bully_5 al exportador. Guardados Dart/JSON regenerados y paso obligatorio de integridad de arte + exportación antes del análisis/tests/APK. Validada sintaxis Python/YAML, orden del pipeline y define de habilitación. No se modifican sprites, capítulos ni comportamientos.

Para que la siguiente versión muestre TODO: compilar el HEAD actualizado de la rama compartida después de integrar los capítulos de otros chats, conservar este paso de preparación y el define; ejecutar las pruebas conjuntas y revisar en Redmi Note 14. Las pruebas anteriores de enemigos siguen documentadas en 41317694621; esta revisión no equivale a una nueva prueba Flutter/Android de todos los capítulos actuales. Aprobación artística final pendiente. No se ha lanzado Actions ni generado APK en esta revisión.

## 2026-11-01 — Enemigos: integración y verificación completadas; aprobación artística pendiente

Seis nuevos: robot, aficionado rival, turista, Rey de Navarra, toro y corredor. Cuatro clásicos: matón, árbitro, rival y bailarín. Arte real integrado y protegido; escala por altura opaca, apoyo común, ataques sincronizados y derrota sin bucle. Robot/corredor derivados de referencias aprobadas sin redibujarlos. Matón/árbitro completos y tres poses del bailarín rehechas con apoyos. Derrota del rival conserva su original tumbado.

**Evidencia final:** [QA 41317694621](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41317694621) SUCCESS; fuente `ab5a640186d4281ee4085b11ea5b5944309e8735`, capturas persistidas `8433cbd701120bdf2f60e316bd3aa3ddc527db6a`. 21 PNG con hashes correctos, análisis Flutter sin errores, veinte casos de combate real (10 enemigos × 2 protagonistas), incluyendo evasión/interrupción/derrota, y 240 muestras StagePainter. Inspección visual de las secuencias de los diez; nueva revisión del robot tras separar componentes y del bailarín en WebP sin pérdida. Sin defectos de recorte detectados en esa revisión final. Esto no certifica dispositivo Android ni aprobación artística del usuario.

[Galería comparativa: referencia, PNG integrado, capturas y animaciones](../../qa/enemy_verified_render/README.md). Las animaciones son estados controlados del motor, no vídeos de partida. WebP sin pérdida para valorar color; GIF comprimido secundario puede modificar paleta. Los seis flags artísticos siguen falsos hasta aprobación final; no cambiar automáticamente por tests verdes. Los metadatos del importador describen generación/procedencia, la prueba efectiva está en esta ejecución vinculada. No APK, merge o publicación en esta orden. **Siguiente acción: revisión artística del usuario; no queda otra tanda técnica programada ni ejecución en segundo plano prometida.**

## 2026-11-01 — Enemigos: combate real verificado, último ajuste visual en prueba

Run 41209812141 SUCCESS sobre e3d503e: integridad de 18 PNG protegidos, análisis Flutter, pruebas puras y ticker real. Logs confirman REAL_GAMEPLAY_PASS para diez enemigos × Miren/Sara (20 casos): anticipación, daño, balón/peine, interrupción y derrota. Capturas y GIF reales de estados controlados en qa/enemy_verified_render; no son grabaciones Android. Se mantienen los diseños aprobados de robot y corredor, los otros cuatro nuevos son candidatos ilustrados integrados. Matón completo con impacto propio; árbitro completo; derrota del rival usa frame 5.

Reanudación: HEAD base 938cc19d. Ajustes pendientes recuperados: secuenciar los cuatro fotogramas de arranque del toro, limitar marcha del rey al rango real de movimiento y muestrear los relojes de aviso/impacto en QA. Se añade evasión durante aviso a los veinte casos de combate y se repite QA-only. No APK, merge ni publicación en esta orden. Aprobación artística final pendiente; no cambiar enemyArtValidated automáticamente. Véase qa/enemy_art_20261031/REVIEW.md.

## 2026-10-31 — Cierre de verificación Flutter del colegio HIFI, versión 0.9.1

Orden del usuario: terminar integración de cinco imágenes maestras aprobadas 30-10, mantener 27 paneles/suelo/ZIP y aportar 5 habitaciones + 2 transiciones verdaderas del motor Flutter, sin APK, sin merge, sin tocar enemigos, controles o físicas.

Cronología verificable:
1. Reproducido bloqueo de capturas de la ejecución [41133497305](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41133497305): el ZIP sí estaba en el runner, pero `toImage()/toByteData()/File` no concluían en la prueba original. `tester.runAsync` para las tres fases, verificación de `RepaintBoundary`, imagen y escritura con tiempos acotados permitió la primera serie auténtica de siete en [41190483956](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41190483956).
2. Inspección visual de cinco salas y transiciones reales: fondos celestes ocultaban el paisaje, sala de informática y cartelería repetidas, marcos genéricos grises superpuestos en umbrales. Orden de módulos revisado, sin sustituir 27 PNG.
3. Los dos paisajes panorámicos ricos sí se regeneraban pero no se guardaban. Se añadió su seguimiento al paso de commit; [41190937223](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41190937223).
4. Se hizo comparación alpha del cristal en QA temporal y revisión visual, luego se integró ajuste **solo de canal alfa**: todos los RGB de los 27 originales cotejados byte a byte contra los PNG contenidos en el ZIP; maestro inmutable SHA256 `4370a461007d4e96bef60da32e827995301f41f7d1662fec9749da739d72bc9b`. El manifiesto registra hash original/nuevo, y generadores antiguos tienen guardas. [41191399324](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41191399324).
5. Dos nuevas capturas con cámara +60 y verificación de pares imagen-pared alineados demostraron paralaje móvil real: diferencia pared `0.00` y paisaje `3.47` / `9.34`; [41191878556](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41191878556).
6. Se eliminó el marco genérico gris de 120 px **solo** si `stage==6 && schoolHifiArtworkEnabled`; se reexaminaron visualmente las transiciones 06 y 07, ya sin esa obstrucción y con arquitectura aprobada intacta.
7. Se añadieron capturas 10/11 de **Sara** en aula y biblioteca y aserciones de `StagePainter.selected`, usando parámetro `qaSelected` que no afecta al juego normal. El workflow se limitó a arte escolar, sin ejecutar generadores de enemigos. Ejecución definitiva [41192357433](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41192357433) **SUCCESS**: once PNG reales 20:9 guardados, 30/30 archivos originales verificados antes de refinar alfa, 27 paneles/RGB exactos después, análisis Flutter limpio, test Flutter aprobado, ventanas en movimiento y commit `03f1fea` publicado en la rama.
8. Una ejecución intermedia [41192190755](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41192190755) pasó capturas y pruebas, pero el push rechazó un non-fast-forward porque entraron los cambios de la prueba ampliada. No se forzó push: la ejecución definitiva posterior integró y guardó todo correctamente.

Documentación de evidencias, once enlaces y comparación con originales: [COLEGIO_FLUTTER_2026-10-31.md](https://github.com/Creadordevida/Hermanas-Pixel/blob/work/revision-visual-20261028-continuidad/docs/continuidad/COLEGIO_FLUTTER_2026-10-31.md).

Resultado: calidad artística escolar inspeccionada en imágenes reales 1000×450 (20:9), integración técnica Flutter y movimientos del paisaje probados; inspección GPU Android / móvil físico NO hecha porque la orden prohíbe APK. PR #5 abierta en borrador, no merge; sin publicación ni alteración de enemigos.

## 2026-10-31 — Dirección artística robot/corredor aprobada expresamente
El usuario aprueba identidad y aspecto de las hojas guardadas en qa/enemy_art_20261031; no aprueba aún animación ni render final. Se derivan atlas de producción por recorte, limpieza alfa y escala uniforme por personaje, sin redibujar fotogramas. tools/build_approved_enemy_art.py fija hashes fuente y falla si cambian. Se corrige orden runner idle/alert/run, y recorte de cepillo robot extendido. Generadores antiguos delegan estos dos personajes al importador aprobado, sin fallback procedimental. Render mantiene proporción del atlas para ambos. No se activan flags de aprobación.
Ejecutado localmente: importador de ambos atlas, inspección de hojas derivadas, dimensiones y manifiestos de procedencia. NO ejecutado Flutter ni Android. Pendientes: revisar recortes finales, legibilidad/escala física, capturas auténticas, ciclos de animación y colisiones. No hay comparación motor ni animación real verificadas todavía. Resto de enemigos sigue pendiente. Sin APK/merge/publicación.

## 2026-10-31 — Orden vigente: terminar todos los enemigos sin APK
Autorización explícita en conversación principal Work: seis nuevos y correcciones de clásicos; modificar arte/código, pruebas locales y Actions exclusivamente de pruebas; avanzar sin pausas de aprobación entre enemigos. Prohibidos APK, merge y publicación. Aprobación artística final del usuario sigue pendiente.

Avance real de esta ronda: se recuperaron y visualizaron los dos idle originales de protagonistas. Generación con imagegen integrado usando esos PNG como referencia. Guardados maestro robot turquesa y dos hojas candidatas robot/corredor (4×6, 1024×1536) en qa/enemy_art_20261031/. NO son atlas de producción ni capturas Flutter.
Inspección: robot requiere comprobar locomoción y tamaño/pivotes. Corredor inicial tenía tres celdas vacías de impacto; nueva edición las rellena. Persisten problemas de distribución en celdas regulares, escala/anatomía y alfa residual: hojas alfa 0..254. No normalizar cada pose por separado. No activar flags de aprobación.
Control local ejecutado: dimensiones, SHA256 y conteo alfa>128 por 24 celdas. Esto NO certifica separación de figuras, animación ni arte. No Flutter/Dart local disponible; git clone directo falla por autenticación, conector GitHub sí permite binarios mediante create_blob.
Estados: robot y corredor GENERADOS COMO CANDIDATOS, NO INTEGRADOS/VERIFICADOS; aficionado, turista, rey y toro PENDIENTES DE PRODUCCIÓN; clásicos PENDIENTES DE REVISIÓN/CORRECCIÓN en esta ronda. Ningún enemigo cerrado.

Siguiente: separar/normalizar hojas con escala canónica y pivote consistente, inspeccionar todos los fotogramas a escala de motor, continuar cuatro enemigos y clásicos; usar QA-only remota tras revisar workflow. La autorización no permite ejecutar workflows de build APK.
Lección reutilizable: pedir 24 poses no garantiza 24 figuras ni cuadrícula válida. Alpha presente tampoco prueba bordes limpios. Validar conteo visual, contornos, celdas y coordenadas antes de integrar. La apariencia de fondo en vista previa puede provenir de RGB bajo alpha; inspeccionar bytes antes de diagnosticar opacidad.


## 2026-10-31 — Reanudación principal en Work; auditoría contrastada
Esta conversación queda como principal por orden del usuario. Corte de código: 429e2ee6f0c465489187da3de1977a539a9454d6; rama work/revision-visual-20261028-continuidad; PR #5 abierta y borrador. No fusionar ni crear APK sin nueva orden.

Hallazgo que sustituye el bloqueo antiguo de transferencia: la ejecución 41133497305 (job 124330106483) SÍ recibió el ZIP escolar, importó 30 archivos, verificó 27 paneles/cinco familias y preservó 30/30 hashes tras los generadores. Flutter analyze --no-pub lib pasó. El test real cargó imágenes y anunció capture 01_pasillo, pero agotó 10 minutos. El paso de commit quedó OMITIDO. Por tanto: paquete transferido y verificado en runner; integración permanente y siete capturas NO acreditadas. No volver a pedir subir el ZIP basándose en el diagnóstico antiguo.
Evidencia: https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41133497305
Inspección de test/school_hifi_real_render_test.dart: rasterización dentro de runAsync; operaciones asíncronas de File fuera de runAsync. Hipótesis de bloqueo por I/O en reloj simulado pendiente de reproducción; no declarar causa confirmada.
Siguiente trabajo autorizado: aislar y corregir captura/guardado, validar siete renders auténticos y después integración. No aumentar timeout como sustituto de diagnóstico.

Base móvil según documentación recuperada: RC4 probada por usuario; RC5 fullscreen última candidata entregada, aceptación móvil pendiente. Incidencias de viewport, colegio, turista/corredor/Estafeta, danza, robot y bully siguen abiertas salvo evidencia posterior. No reactivar órdenes antiguas de compilación.
Conocimiento específico: docs/DECISIONES_APROBADAS.md, docs/continuidad/ y docs/HISTORIAL_DE_TRABAJO.md.
Conocimiento reutilizable: docs/FRAMEWORK_SNES_TWC/. Mantener arte, cámara/parallax, pivotes, pruebas y procedencia separados de personajes y coordenadas propias del juego. Flutter se conserva; framework todavía no equivale a GPT terminado.
Clasificación obligatoria: propuesto -> aprobado para desarrollar -> generado -> integrado en motor/rama -> comprobado (tipo de prueba y commit) -> aprobado visualmente/dispositivo. Cada transición necesita evidencia; aprobación del concepto no aprueba el resultado.

Límites de esta ronda: recuperación parcial de conversaciones y lectura de documentos actuales de continuidad/decisiones/framework; logs reales inspeccionados. Colegio_TWC.zip localizado (18.505.839 bytes), pero lectura textual no permite inspeccionar contenido ZIP. No se han revisado aquí todos los PNG, vídeos históricos ni todas las ramas; no se ha ejecutado nuevo Flutter/Android. No afirmar auditoría total ni cierre artístico. No se han cambiado jugabilidad ni recursos.

---

# Bitácora de continuidad
## 2026-10-30 — Implantación inicial
Se revisó repositorio privado, PR #5, rama work/revision-visual-20261028-continuidad y HEAD cb8f93a582a3795ae8351c3075f600b6a5b313a0.
Hallazgo: 27 PNG del colegio ya están en Git; docs/CIERRE_INTEGRAL_PR5_2026-10-29.md estaba desactualizado en cuanto a presencia de paneles. No hay aprobación artística nueva.
Se crea un punto de entrada, reglas para agentes, estado operativo y protocolo de sesión; se conserva la documentación histórica y el framework SNES.
No se han ejecutado tests, Flutter, Android ni Actions; no se ha cambiado jugabilidad.
Siguiente acción: revisar los 27 paneles reales, resolver portada y seis atlases, validar danza/fútbol/clásicos. No compilar sin autorización.
## 2026-10-30 — Orden de ejecución pre-APK y revisión del bloque A
Usuario autoriza desarrollar e integrar bloques A–G, pero no APK, ni Actions manuales, ni merge. Nueva regla: informar al terminar **cada bloque**, dar oportunidad de observar y esperar su indicación antes del siguiente; sin pausas por cada cambio interno del bloque.
Auditoría real: `title_cars_fixed_091.png` existe (1.242.063 bytes, SHA Git `8246b4f06bc35bb4845de547e2091659ae93a61d`); `twc_title_mark_clean.png` ya existe (SHA `5f7f4aa54e3a6212da65f7a024df4036bb69ee20`) y es byte a byte el mismo blob que el logo TIKU `twc_mark_from_tiku.png`. PNG del sello visualizado; no regenerarlo. `title_wide_20x9.png` sigue AUSENTE. Herramienta GitHub sólo permite recibir bytes de PNG pequeños; el original de 1,2 MB se devuelve sin contenido en modo base64 y los blobs binarios directos son rechazados. No existe checkout local del repo ni Flutter/Dart instalado en este entorno. NO se han ejecutado tests Flutter, Python del repositorio ni generado panoramas/capturas ni APK. Cuatro workflows en `.github/workflows/` inspeccionados: disparador `workflow_dispatch` exclusivamente; guardar commits no dispara los workflows declarados en la rama.
**Estado A: BLOQUEADO POR ARTE PANORÁMICO Y ACCESO A PIXELES**, no completado; el logo es un subelemento existente y conservado. No declarar portada aprobada. Mantener 16:9 original intacto y QA estricta. Estado B–G todavía pendiente, no modificados por esta ronda. Registrar futuras evidencias en `docs/FRAMEWORK_SNES_TWC/` tras ejecutar verificaciones reales.

## 2026-10-30 — Recuperación material y descarte visual honesto (bloque A)
ACTUALIZACION DE RECUPERACIÓN (30/10/2026, posterior al primer diagnóstico): se localizaron en la biblioteca de archivos los 159.496.519 bytes del ZIP `MIREN_Y_SARA_RC3_FIX2_PARALLAX_GITHUB_COMPLETO.zip`. Se extrajo `assets/images/title_cars_fixed_091.png` (1098×617, 1.242.063 bytes) y se verificó que su Git blob SHA1 es exactamente `8246b4f06bc35bb4845de547e2091659ae93a61d`, idéntico al asset de GitHub. También se recuperó `title_approved.png` y su SHA coincidió con GitHub. **Por tanto NO hace falta pedir al usuario que suba la portada**. Es posible trabajar localmente sobre los píxeles de origen; sigue faltando un panorama artístico aceptable y su integración. Un primer mosaico experimental de expansión 20:9 (1371×617) preservó el centro original píxel a píxel, pero se RECHAZÓ por duplicar fragmentos de letras y personajes en los laterales. NO se guardó en GitHub ni se marcó como válido. No se han ejecutado Flutter, Actions ni compilación APK. Si en otro chat el ZIP no está montado, localizarlo en la biblioteca de archivos y materializarlo. La limitación de acceso a blobs binarios grandes del conector GitHub continúa, pero NO impide recuperar este original desde el archivo histórico.

## 2026-10-30 — Bloque B: trabajo de integración y control local
Se auditó el colegio con las tres imágenes fuente originales verificadas por SHA respecto del GitHub actual. 27 módulos recreados por procedimiento PIL **independiente de Flutter** para inspección local; 27 distintos, 27 con píxeles fuente esperados, tamaños 880×278 y transparencias en ventanas. Las imágenes locales NO son descarga byte por byte de los 27 assets GitHub. Se detectó repetición excesiva de biblioteca y pizarras. No aprobación artística.
Commit de código `7c4e6dc92c84b7bde1f78766fd0206644d7511a8`: `lib/main.dart` condiciona mesas a sala real y ordenadores a fuente informática; `qa/test_interiors_twc.py` actualiza offsets 26/27 obsoletos; nuevo test Dart `test/school_furniture_source_test.dart` escrito, no ejecutado. Modelo local: 31 módulos inspeccionados en alas 1 y 2, 7 pasillos sin mesas ahora, mesas previstas 35→26, ordenadores previstos 14→9 (número teórico, no prueba Flutter). Queda pendiente acceso a los PNG de producción de GitHub y Flutter para capturas reales; no hay descarga binaria viable por el conector conectado, y no hay Flutter/Dart. Paquete local de revisión con imágenes procedentes de fuentes reales, identificado como previsualización, no final aprobado. Pendiente corregir el arte repetitivo y verificar integración en StagePainter. NO marcar B como COMPLETADO. No continuar bloque C sin comentario del usuario.

## 2026-10-30 — Bloque C: corrección de danza e imágenes de muestra reales

- Autorizado explícitamente por usuario tras el bloque B; NO hay autorización para el bloque D ni para APK, Actions o merge.
- Orígenes legítimos exactos recuperados del archivo histórico y contrastados con GitHub actual por Git blob SHA: `dance_foyer.png` a0e98f69, `dance_studio.png` be8e3378, `dance_stage.png` f48659a6.
- DEFECTO VERIFICADO: el generador de danza comprimía un recorte 1672×545 a 1650×286 (escala X 0,9868 frente a escala Y 0,5248; anomalía 1,88×). Arcos y mobiliario se aplastaban verticalmente.
- CAMBIO DE CÓDIGO: `tools/build_interiors_parallax_twc.py` conserva relación de aspecto usando recortes auténticos 1200×390 → 880×286 (factor idéntico 0,7333), con tres encuadres por sala, sin espejos ni reemplazo del arte aprobado. `tools/build_dance_panels_twc.py` regenera SOLAMENTE los nueve PNG de danza, sin tocar los 27 paneles del colegio. `qa/test_dance_proportions.py` comprueba las 3 fuentes originales, nueve PNG, transparencia, proporciones y procedencia de píxeles. `tools/preview_interiors_twc.py` corrige un error real de indentación que impedía importar el visor.
- Evidencia LOCAL con originales recuperados: 9 PNG RGBA de 880×286 creados e inspeccionados, 9 hashes distintos, escala isotrópica exacta, alfa de zócalos opaca, 4 pruebas locales independientes satisfactorias. Contactos antes/después y archivo ZIP ofrecidos en conversación como ejemplos REALES de recursos PIL, NO capturas StagePainter.
- **NO afirmar integración de PNG en GitHub**: por límites del conector binario no se han subido los nueve PNG (aprox. 3,2 MiB en conjunto). Los nueve PNG activos de la rama aún son anteriores al parche; el juego seguirá mostrándolos hasta sustituirlos y confirmar hash. La nueva prueba de regresión del repositorio se ha escrito, pero NO ejecutado contra un checkout completo. NO Flutter ni Android; revisión artística final NO aprobada.
- **Estado C: PENDIENTE DE VALIDACIÓN / INTEGRACIÓN BINARIA.** Paso siguiente: subir 9 PNG exactos al mismo commit/rama mediante canal binario Git autenticado cuando esté disponible, ejecutar `python3 -m unittest qa/test_dance_proportions.py`, `flutter analyze`, `flutter test` y capturas auténticas StagePainter del capítulo 6. No bloquear el motor ni degradar arte previo para forzar cierre.

## 2026-10-30 — Puerta crítica de danza antes de la próxima APK

### REQUISITO CRÍTICO DE PRÓXIMA COMPILACIÓN — DANZA (30/10/2026)
El usuario ordena registrar como BLOQUEANTE la regeneración e integración de los nueve PNG del bloque C antes de construir la próxima APK. En `.github/workflows/build.yml` se incorporan llamadas explícitas a `tools/build_dance_panels_twc.py` y `qa.test_dance_proportions` en ambos jobs. La compilación falla antes de `flutter build apk` si fallan esas comprobaciones. La QA futura conserva los nueve PNG y manifiesto durante 1 día para confrontar SHA. **Esto NO los incorpora todavía de forma permanente a la rama Git:** se debe promover después de QA artística. Véase `docs/continuidad/PLAN_SIGUIENTE_COMPILACION.md`. Sin Actions, APK ni merge ahora.

## 2026-10-30 — Bloque D: fútbol y pruebas de regresión

### BLOQUE D: FÚTBOL — revisión y corrección fuente 30/10/2026
- Usuario autorizó pasar a D. Los orígenes reales `football_arrival.png`, `football_drills.png`, `football_stands.png` extraídos del ZIP histórico y contrastados **exactamente** con blobs GitHub de SHA `059bd4b0`, `8a5fd175`, `16efe192` (3/3).
- DEFECTO VERIFICADO en `tools/build_football_parallax_twc.py`: la capa próxima, pese a presentarse como variada, recortaba exclusivamente tres regiones solapadas de `football_stands` y no giraba ninguna (`xx=0`); patrón repetitivo. Se corrige con franjas reales de ENTRADA, GRADAS y ENTRENAMIENTO (8 motivos, 4 franjas 870x130, escalado casi isotrópico 950x142), manteniendo seis módulos de 1100x386 y velocidades .30/.56/1.00.
- PROTOTIPO LOCAL con fuentes auténticas: se generó y examinó `new_near_band.png` y seis `near_0..5.png` de muestra, 6 hashes distintos, alfa transparente en cielo, ciclo RGB cerrando con salto medio 0 en la junta entre extremo izquierdo y derecho; contacto comparativo antes/después. Es un *laboratorio Python* que reproduce la capa cercana: **NO** es `StagePainter` ni un PNG ya comprometido en GitHub.
- Cambios en `qa/test_football_parallax_twc.py`: fuentes de las tres ilustraciones, seis paneles distintos y geometría uniforme. Se reparan también `qa/test_visual_revision_contract.py` que esperaba el código viejo de portada y el recorte deformado antiguo de danza; estas pruebas no estaban sincronizadas con el código actual.
- **ESTADO D: PENDIENTE DE VALIDACIÓN.** La rama todavía contiene los PNG de fútbol anteriores; el pipeline de la futura compilación ejecuta el generador actualizado, pero es necesario revisar los PNG que salgan y obtener capturas de Flutter reales antes de aprobar. Ninguna APK, Action o merge ejecutado.

## 2026-10-30 — Bloque E, comprobaciones y salvaguarda de arte

### Bloque E — seis enemigos (30/10/2026)
- Código y pruebas guardados: `d3b3f7b4ce6481dbc1549da936bea555c1c21167` (hitboxes seis, golpe con aviso de 0,34s del corredor, HP coherente, tests Dart nuevos); `9b7e9f19f06aec96d57dde3f3f28a3d565780e75` (capturas StagePainter ahora requieren fondos auténticos en Estafeta, Plaza, fútbol y colegio); `47289504b4c16c6ede9abb5128b05b58662996de` (workflow prueba nueva IA/hitboxes y exige evidencia SHA de arte activado).
- **Arte: BLOQUEADO PARA INCLUSIÓN**. Los seis atlases finales siguen ausentes de la rama GitHub. Sus scripts actuales crean prototipos procedimentales que NO satisfacen el estándar 0.7.1; sus flags continúan falsos. No convertir pruebas de bytes/pose en aprobación artística.
- Recuperada de biblioteca hoja visual `Sprites de San Fermín: Toro y Corredor.png`; extracciones de 7 poses toro/corredor y dos atlas locales de prueba 4×6. INSPECCIÓN: diferencias de perspectiva y fotogramas repetidos/cortados, por lo que se conservan únicamente como referencias rechazadas para gameplay en artefacto de conversación `BLOQUE_E_SEIS_ENEMIGOS_REVISION_ARTISTICA_NO_APROBADOS.zip` (incluye además lámina de conceptos de los seis). Los dos atlas NO están en Git ni se anuncian finales.
- **Nueva capacidad verificada:** subida de PNG real usando base64 del archivo fuente leído por conector Files + `mcp__GitHub__create_blob`; 377.797 bytes, SHA Git `16671f5d374652cbd48c18dd2b385b587bc1ee40` coincide exactamente. Fue un objeto de Git sin referencia en rama; verificar permanencia en commits futuros. Documentar en `docs/FRAMEWORK_SNES_TWC/TRANSFERENCIA_BINARIA_GITHUB.md`. No es excusa seguir sin guardar PNG: ahora hay método probado cuando las imágenes estén artísticamente listas.
- Pendiente: dibujar/refinar seis másters de verdad y hojas de animación congruentes, subir **los seis** por transferencias binarias verificadas, integrar, ejecutar tests y analizar las 36 capturas Flutter y la interacción Miren/Sara, entonces pedir revisión usuario. Falta test Flutter local: no instalado; no APK, Actions o merge.
- Estado E **PENDIENTE DE VALIDACIÓN**. Usuario debe revisar este bloque antes de pasar al F.

## 2026-10-30 — Bloque F: cuatro enemigos clásicos (revisión con PNG auténticos)
- Orden expresa de usuario para continuar F. Se recuperaron los 27 PNG auténticos del archivo histórico y sus 27 hashes Git coinciden exactamente con los archivos actuales de la rama, antes de los cambios.
- Hallazgo real: `referee_5.png` mostraba la cabeza y dos miembros separados, sin tronco y piernas completas; ilustraciones adicionales `referee_6/7` también presentan fragmentos, pero NO son usadas por el juego. Reconstrucción responsable de `referee_5.png` a partir de `referee_1.png` ORIGINAL, con rotación de -13° por vecino más cercano, recorte de alfa y pivote en suelo. El nuevo PNG es 55×102, 5720 bytes, SHA Git `4d2ae6d67ededebde1ed9ab31b2ac7aedb873029`; prueba local alfa opaco pasa de ~25,6% del rectángulo a ~50,3%, con cuerpo completo visible. Original antiguo conservado como objeto Git `48bcedd3ced7f17834426549f711a431ae62d51f` y copia de seguridad en `qa/art_review/originals/referee_5_pre_fix.png`. La nueva imagen es una mejora verificable de integridad de sprite, NO aprobación visual Flutter.
- La ilustración `rival_5.png` ya existía en la rama, tumbada en el suelo, pero `classicEnemyFrame()` usaba `rival_4` (caída intermedia) como derrota final. Ahora la derrota usa el fotograma original n. 5, y motor, exportador de cotas y prueba real StagePainter incluyen los 6 fotogramas del rival.
- Se corrigió **riesgo destructivo** del generador `tools/refine_four_classic_enemies.py`: antes reescribía directamente los PNG originales y duplicaba X/Y en tres tipos, lo cual podía romper el tamaño de mundo. Ahora trabaja a resolución 1:1 y escribe SOLO candidatos en `qa/art_review/candidates/`. `qa/check_four_classic_enemies.py` comprueba hash, máscara, tamaño, archivos y mantiene art_approved=False; contacto comparativo por cada tipo.
- En una copia local restaurada de los originales, ejecución efectiva de ambos scripts: **23/23 candidatos generados y comprobados**, sin modificar ningún maestro (salvo la sustitución deliberada y trazada de `referee_5`). Imágenes candidatas y contactos locales no son vistas del motor Flutter. No se han aprobado los candidatos para reemplazo en assets.
- **ESTADO F: PENDIENTE DE VALIDACIÓN ARTÍSTICA Y FLUTTER**. Revisar `qa/rendered_from_flutter/classic_*.png` desde StagePainter en el job QA, verificar las poses y escalas de los cuatro. No ejecutados Flutter/Dart (no disponibles), ni GitHub Actions, APK o merge. El próximo bloque G exige autorización posterior del usuario.

## 2026-10-30 — Bloque G: integración de todos los módulos
Véase `docs/continuidad/BLOQUE_G_INTEGRACION_2026-10-30.md`. Corrigida QA de clásicos que buscaba animaciones en el archivo antiguo; inventariados fotogramas 6.º; añadido `qa/verify_integration_before_apk.py --strict` a ambos jobs con informe de bytes/manifiestos; GitHub Actions reordenadas para que el QA Flutter REAL se ejecute antes de intentar compilar APK. Sin ejecutar Actions, sin APK, sin merge; G PENDIENTE DE VALIDACIÓN por arte A/E y por falta de ejecución Flutter. Solo hay permiso para llegar al cierre de G y pedir revisión antes de siguientes tareas.

## 2026-10-30 — Nuevo punto de partida REAL tras prueba Android de 0.9.1 RC4
El usuario ha **instalado y probado** la APK 0.9.1 RC4 (run 41071927964, fuente c08ba002, release playtest-0.9.1-rc4). Indica que hay muchas mejoras pendientes y decepciones, pero **sin detallar aún defectos**. Ordena usar RC4 como base para avanzar, NO como arte aprobado. Se abre lista acumulativa para siguiente versión; no compilar ni modificar jugabilidad hasta recibir las incidencias y criterio de cierre. Informe exacto: `docs/continuidad/BASE_JUGABLE_RC4_Y_REVISION.md`.

### 30/10/2026 — Vídeo 001: P0 tamaño/ocupación de pantalla (portada Y juego)
Usuario envía vídeo `Screenrecorder-2026-10-30-15-53-34-17.mp4` (33.32 s, 1080×2400). Registro de dos incidencias críticas RC4-001A (portada) y RC4-001B (juego/mapa). Se documentó franja activa 20:9 en centro del vídeo vertical (filas ~957–1442), exterior negro y márgenes internos; código fuente comprueba BoxFit.contain y viewport fijo 800×450, y manifest Android ausente del repositorio al usar flutter create. **Causa exacta del encajonado nativo aún por validar en móvil.** Requiere corrección de orientación nativa + viewport adaptable sin distorsión ni recorte de HUD. Estado: EN LISTA DE PRÓXIMA VERSIÓN, NO RESUELTO, sin compilar. Detalles y aceptación en `docs/continuidad/INCIDENCIAS_VIDEOS_RC4.md`.

### 2026-10-30 — Vídeos 002, 003 y 004 añadidos a lista (SIN implementar ni compilar)
Vídeo 002: RC4-002 colegio (paredes/arquitectura repetitivas, preservar paisaje móvil). Vídeo 003: RC4-003A turista y RC4-003B corredor de San Fermín a rehacer completamente, RC4-003C fondo de Estafeta pendiente. Vídeo 004: RC4-004 academia de danza — visual original aceptable y parallax correcto, pero variedad prometida insuficiente; se confirma causa: 3 recortes por zona con solapamiento 80,3% y ciclo cada 2640 unidades. Exigir composición realmente distinta y validar desplazamiento real, no solo hashes. Véase `docs/continuidad/INCIDENCIAS_VIDEOS_RC4.md`. Lista ABIERTA, sin cambios gráficos ni nueva APK.

### 2026-10-30 — Vídeo 005: robot, colegio y cabeza del bully (lista abierta)
Vídeo `Screenrecorder-2026-10-30-16-00-26-909.mp4` (~36,08 s). Añadidas RC4-005A (robot, mejor de nuevos pero inferior a Miren/Sara), RC4-005B (colegio con plantas poligonales, paredes pobres y siluetas borrosas; amplía RC4-002), RC4-005C (matón: pelo oscuro mínimo en sprites originales y casi invisible a escala de juego; no hay gorra clara, sin prueba de recorte por motor). Ningún gráfico corregido ni APK compilada. Los criterios verificables están en `docs/continuidad/INCIDENCIAS_VIDEOS_RC4.md`.

## 2026-10-30 — ORDEN EXPRESA: PROHIBIDA NUEVA APK HASTA NUEVA AUTORIZACIÓN
El usuario indica: «no hagas mas apks hasta que te lo indique porfavor, tenemos que ir mejorando antes de compilar siempre que sea posible».
**Restricción vinculante para próximas sesiones:**
- NO crear, lanzar ni programar ninguna compilación Android/APK nueva, ni ejecutar marcadores de GitHub Actions que puedan dispararla, hasta que el usuario lo autorice de nuevo explícitamente.
- La **RC5 fullscreen** (`0.9.1-rc.5+36`, GitHub Release `playtest-0.9.1-rc5-fullscreen`) es la **última candidata entregada**, todavía pendiente de que el usuario la descargue, instale y confirme la corrección en su Redmi Note 14.
- Trabajar previamente sobre defectos de código, arquitectura, sprites y escenarios. Guardar commits y documentación, generar comparativas y ejecutar pruebas locales/estáticas/Flutter sin construir APK siempre que se pueda. No confundir pruebas superadas con aprobación artística o en dispositivo.
- Mantener lista abierta de incidencias, no fusionar PR #5 ni publicar en Google Play. **Una orden antigua de compilar RC5 NO autoriza ninguna nueva APK.**

### 2026-10-30 — Reconstrucción real de colegio sin APK: arte LOCAL + código en Git (NO cerrado)
Generados 27 PNG originales con cinco tipos de interior, 880×278, ventanas transparentes y paisaje far/mid conservado. Entregable local `COLEGIO_27_PANELES_RECONSTRUIDOS_LISTOS_PARA_INTEGRAR.zip`, pruebas PIL y manifest. Código GitHub: `tools/build_school_hifi_twc.py`, hook de generador, `lib/interiors_parallax_twc.dart`, `lib/main.dart`, y QA strict. **BLOQUEO CRÍTICO: el origen binario y los PNG nuevos NO están subidos a GitHub y falta prueba Flutter real. NO marcar solucionado.** Informe `docs/continuidad/COLEGIO_RECONSTRUCCION_2026-10-30.md`. No se ejecutó APK ni Actions.

### 30/10/2026 — Colegio: referencia exacta y 27 fondos reconstruidos (aún NO integrados binariamente)
Referencia cargada por usuario 1448×1086 SHA256 4370a461…bc9b. Código nuevo de 5 salas, generación 27 RGBA, ventanas con alfa en paralaje, suelo sin planta poligonal, QA estricto fail-closed y nueva prueba Flutter real en GitHub. Paquete local: COLEGIO_REFERENCIA_EXACTA_27_PANELES_Y_VENTANAS_MOVILES.zip, SHA256 c9579acf…dee78. **Master y PNG aún AUSENTES de GitHub, por tanto NO RESUELTO ni validado en Flutter**. No compilar APK. Véase `docs/continuidad/COLEGIO_RECONSTRUCCION_2026-10-30.md`.

### 30/10/2026 — COLEGIO: puente binario GitHub de una sola subida, aún SIN cerrar
Autor original recuperado EXACTO: `COLEGIO_REFERENCIA_EXACTA_27_PANELES_Y_VENTANAS_MOVILES.zip` (18.505.839 bytes, SHA256 c9579acf…dee78), maestra SHA256 4370a461…bc9b; 27/27 paneles verificados por SHA. Importador de 30 archivos probado localmente; no altera originales. Reparado bug sintaxis de `qa/check_school_hifi_twc.py`; protegido el generador para no sobrescribir PNG/suelo aprobados. GitHub contiene `tools/import_school_exact_twc.py`, `.github/workflows/school-hifi-only.yml` (solo Flutter Python, sin APK), y `qa/school_inbox/README.md`. Bloqueo concreto: falta acceso para enviar bytes binarios del contenedor al conector GitHub. Solución de mínimo esfuerzo: usuario sube **un ZIP sin descomprimir** a `qa/school_inbox/` en la rama PR5; esa subida activa automáticamente QA-only que integra 27 PNG y captura 7 imágenes Flutter REAL y confirma en GitHub si pasa. No Actions ejecutadas, no APK, PR sin fusionar, no artwork final aprobado en render. Véase `docs/continuidad/COLEGIO_RECONSTRUCCION_2026-10-30.md`.

### 2026-11-08 — Enemigos Arga, auditoría estática nueva
Commit `02c0676` crea `scripts/check_arga_24_candidates.py`: verifica formato/transparencia/recorte de las seis poses candidatas de cada uno de los cuatro enemigos y mide pivotes, sin tocar los originales. Solo se comprobó sintaxis Python; pendiente ejecución con las 24 imágenes reales y revisión artística. No se gastó en Actions, no se compiló APK, no se modificaron capítulos 0–6. Próximo paso en `docs/continuidad/ARGA_ENEMIGOS_RC7_ESTADO.md`.

### 2026-11-08 — Eliminada activación automática de QA en PR #5
Por petición expresa del propietario, pausados triggers de `push`/`pull_request` en 25 workflows de `.github/workflows`; ahora todos usan `workflow_dispatch`. Comprobación por lectura GitHub 25/25; último commit `94b5d6e`. No se ejecutó Actions, no se gastó deliberadamente, no se compiló APK. El consumo histórico por ejecuciones previas queda sin cuantificar. Las pruebas permanecen recuperables para futura reactivación bajo autorización.

### 2026-11-08 — Río Arga: preparación anzuelo pescador
Commits `39ea03b` y `c0aaa2d`: modelo aislado de proyectil de pesca y cinco pruebas de contrato, integridad de archivos comprobada en rama PR5. Dart/Flutter no ejecutados, no render real, no cambio en otras etapas ni GitHub Actions. Pendiente conectar únicamente a QA stage 7 y revisar colisión durante frames lentos.

### 2026-11-08 — Pescador Arga, conexión exclusiva QA
`37388cc` conecta pescador y anzuelo al stage 7 de `main.dart`; `f04079d` añade pruebas de carga de seis poses y derrota por dos disparos. Marcador de anzuelo provisional, originales artísticos intactos. Guardado verificado en GitHub, sin ejecución Flutter/Actions ni APK. Aún no aprobado para el juego normal.

### 2026-11-08 — Primer runner público de Arga y corrección estática
Run `42490249834` (job `128760844026`) de Arga inicia gratis en runner estándar, pasa checkout/Flutter/pub get, falla en warning de análisis línea 2905. Los tests/capturas quedan sin ejecutar. Corrección mínima `9021548` aún no reprobada. Workflow devuelto a manual (`d5d72af`); sin APK ni merges.

### 2026-11-08 — Segundo QA público Arga: hallazgo físico concreto
Ejecución [42490644673](https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/42490644673): `flutter analyze` limpio, 10 tests correctos y 1 fallo en reaparición desde checkpoint (110 esperado, 55 recibido). Corregido piso `startX` en `ArgaCourse.checkpointBefore`, commit `1b2c739` y contenido remoto confirmado. **Sin nueva ejecución sobre la corrección**, sin capturas 20:9, APK ni merge. GitHub Actions Arga otra vez exclusivamente manual desde `87899db`. No declarar cerrado hasta pasar tests, obtener ocho capturas reales y revisarlas visualmente.

### 2026-11-08 — Arga: once pruebas físicas correctas, render aún en revisión
Run #56 `42490992815`: `flutter analyze` y once tests físicos PASS. Falló primer test `StagePainter` al exigir reposo pescador no cargado; archivos WebP comprobados en GitHub, error aislado en filtro QA, solución `9752f46` de `main.dart`. Run #57 `42491177824` solicitada una sola vez para comprobar la corrección; no afirmar éxito antes de logs. Trigger restaurado a `workflow_dispatch` (`636b1c1`), sin APK ni merge.

### 2026-11-08 — Primeras ocho capturas auténticas del Río Arga
QA #57 `42491177824` terminó SUCCESS (11 pruebas físicas, `flutter analyze`, render real y 8 PNG 20:9, commit `d5c3f69`). Se inspeccionaron imágenes de inicio, zona pescador y molino. Los paneles/saltos están visibles; quedan cuadrados en glifos de interfaz del runner a revisar. Son capturas Flutter, no Android ni revisión completa de todas las poses. Trigger de workflow manual, sin APK ni merge.

### 2026-11-08 — Integración provisional del tercer enemigo Arga
Niño gamberro conectado a QA-only: seis poses, alerta, piedra con subpasos, colisión y dos impactos de derrota. Commits `c55dd4c`, `49c63b2`, `df4c264`, tests `cdaa77e`, `9eda931`, `c7ecca8`. QA #58 `42492213266` superó análisis y física, pero test gráfico falló por `.name` dinámico; corregido `15ea687`; QA #59 `42492359121` en curso. Sin declaración visual ni APK; workflows manuales.

### 2026-11-08 — QA de los cuatro enemigos del Arga
Run #59 `42492359121` validó niño y piedra; captura real x1950 inspeccionada. Run #60 `42492684662` validó integración de trucha (lógica `01e82c3`, pruebas `c779029`, conexión `64b5323`, render `28ea1389`) y preservó ocho PNG auténticos (`8c66cc2`). Captura x810 muestra la trucha baja sobre el agua: ajuste pendiente. Falta secuencia completa de seis poses, escalas, HUD y partida en Android; **prototipo, no final**. Workflow solo manual commit `4d12bd4`, sin APK ni merge.

## 2026-11-08 — Río Arga, microfase incremental de animación

Rama `work/revision-visual-20261028-continuidad`. Selector de fotogramas ajustado para admitir filas de 1–4 dibujos reales sin acceder a celdas vacías (`lib/arga_sprite_atlas.dart`, commit `e4c197b`) y pruebas adicionales versionadas (`test/arga_sprite_atlas_test.dart`, commit `4f02cd2`). Evidencia: commits y lectura de código en GitHub; NO se ejecutó Flutter/Dart, NO se generaron atlas definitivos ni capturas StagePainter. Restricciones intactas: no Actions de pago, APK, merge, activación del Arga ni cambios en capítulos 0–6. Pendiente: inspección artística y fotogramas intermedios del cangrejo, después pescador, niño y trucha.

## 2026-11-08 — Río Arga: atlas candidatos de cuatro enemigos

Creados y guardados en la rama cuatro WebP Q95 de revisión 4×6 (24 fotogramas) para cangrejo (`76741f1`), pescador (`4834077`), gamberro (`7d8ee8a`) y trucha (`db5261f`). Contrato y auditoría específicos en `docs/continuidad/ARGA_ENEMIGOS_ANIMACIONES_2026-11-08.md`, actualización `dc8bef0`. Los cuatro son **candidatos** y no están habilitados: trucha con recortes y fondo opaco en segunda tentativa rechazada; niño con márgenes bajos; todos pendientes de revisión de alfa, escala y movimiento real. No se ejecutó Flutter, Actions, APK ni se modificó stage 0–6. Siguiente acción: arreglar y validar atlas finales sin pérdida antes de carga a QA stage 7.

## 2026-11-08 — Arga: trucha y gamberro corregidos, QA de atlas

En GitHub: WebP sin pérdida 4×6 de trucha v3 y gamberro v2, commit `55fb52a`; verificador `qa/check_arga_candidate_atlas.py`, commit `cff556e`. El análisis local detectó 24/24 celdas y margen >=12px en las cuatro versiones candidatas seleccionadas (cangrejo v1, pescador v2, trucha v3, gamberro v2); gamberro v1 fallaba y queda descartado. Documento detallado `docs/continuidad/ARGA_ENEMIGOS_ANIMACIONES_2026-11-08.md`, commit `e13e5cb`. **Pendiente** validación visual de transparencia, paleta, apoyos, fluidez real e integración StagePainter. No Flutter, Actions, APK ni activación del capítulo.

## 2026-11-08 — Arga: conexión experimental de atlas a Flutter

Commits `61d7b70` (`main.dart` carga de cuatro atlas solo con `TWC_ARGA_ATLAS_QA` y `qaStage:7`), `ee82040` (test de decodificación), `5e97814` (workflow de QA 20:9 preparado con define). Repositorio público confirmado. No se han ejecutado Flutter/Actions ni generado APK; la integración conserva el fallback original. Bloqueo: falta lanzar manualmente el workflow, revisar render auténtico y reparar alfa/escala/fluidez. Referencia ampliada en `docs/continuidad/ARGA_ENEMIGOS_ANIMACIONES_2026-11-08.md`.

## 2026-11-08 — Arga: Flutter real con atlas 4×6 verificado

QA pública gratuita en runner Ubuntu. Run `42504613482` falló por test que omitía la transición accelerate→warning de trucha, no por error de carga del atlas. Corrección mínima de test `90abd6d`. Run `42504800762` **SUCCESS**: Flutter analyze, 29 pruebas unitarias, `StagePainter` con los cuatro atlas, 8 capturas 1000×450 y salto real de trucha. PNG versionados en `qa/arga_rc7_flutter/` commit `e9b2eef`; revisión visual de cinco capturas registrada en `docs/continuidad/ARGA_ENEMIGOS_ANIMACIONES_2026-11-08.md` commit `4375ea5`. Arte aún candidato: alfa parcial y revisión de 96 fotogramas, ataques, escala y pies pendientes. No APK ni merge.

**2026-11-08 — Arga segunda auditoría visual de enemigos (QA real Flutter):** los cuatro atlas candidatos 4×6 se cargan solo bajo `TWC_ARGA_ATLAS_QA=true`. Tests controlados de cuatro fotogramas de ataque y seis filas por enemigo, render auténtico 1000×450. Actions `42509388954` (pescador), `42509731578` (niño) y `42510057067` (trucha) **SUCCESS**; imágenes preservadas en `qa/arga_rc7_flutter/` por commits `52e1631`, `81c9106`, `aace806`. Cangrejo seis filas en `42508717907`, terminal derrotado boca arriba. Revisión visual: pescador sentado/caña caída, impacto de pescador poco legible; niño caída sentado e impacto claro; trucha impacto arqueada y derrota en agua. Auditoría alfa: máximo 254 en los cuatro atlas, sin píxeles alfa255; originales intactos. Documento principal `docs/continuidad/ARGA_ENEMIGOS_ANIMACIONES_2026-11-08.md`. **Pendiente:** alfa y halos, los 96 fotogramas continuos, impactos y proyectiles en juego, saltos/muertes/reapariciones; no activar Arga ni compilar APK ni hacer merge.

- Decimoquinta ejecución `42510641684` **SUCCESS**. Logs del job `128822732301`: **46 tests unitarios pasan** tras incluir los cuatro archivos omitidos (`arga_crab_behavior_test`, `arga_fisher_behavior_test`, `arga_hook_projectile_test`, `arga_stone_boy_trout_behavior_test`), más cinco pruebas de render controlado 20:9. Las pruebas del anzuelo, daño único y comportamiento enemigo ya forman parte de CI. **Limitación:** siguen siendo tests de componentes y capturas controladas; falta un recorrido continuo con colisiones de las protagonistas, caídas y reapariciones en una partida real.

- Decimoséptima ejecución `42511312779` **SUCCESS**: el nuevo test de **bucle real Flutter** comprobó caída desde x=730 a agua, pérdida de exactamente un corazón (5→4), reaparición de Miren en checkpoint `ArgaCourse.startX` y pies por encima de `waterDeathY`. El QA bot guardó `qa/arga_rc7_flutter/arga_respawn_after_fall.png` en `8e5a421`. Inspección del PNG: escenario real y HUD con un corazón vacío; Miren temporalmente invisible en el instante de invulnerabilidad/parpadeo, por lo que la imagen sola no demuestra su posición (la aserción del estado sí). Esta prueba no cubre aún una partida completa ni selección entre las dos protagonistas.

- Decimoctava ejecución `42511743624` **SUCCESS**. Nuevo `test/arga_crab_gameplay_hit_test.dart` (commit `c2bbf87`) ejecuta contacto de pinzas con Miren x=350 en segunda roca mediante `AnimationController` real: un ataque tras aviso descuenta cinco→cuatro corazones, y 20 fotogramas posteriores conservan cuatro (invulnerabilidad/impacto único). Captura real `qa/arga_rc7_flutter/arga_crab_after_hit.png` guardada por QA bot en `2117ad3`; HUD 4 corazones, protagonista parpadea/invisible durante hurtUntil. No se llamó directamente a `_receiveDamage`; escenario sigue QA-only. Próximas integraciones: anzuelo, piedra, contacto de trucha, dos protagonistas y muerte por pérdida de todos los corazones.

- Decimonovena ejecución `42512247059` **SUCCESS**. `test/arga_fisher_gameplay_hook_test.dart` probó el ciclo **natural** del pescador en bucle Flutter: alerta, lanzamiento de anzuelo real con parábola, contacto sobre Miren en la roca, corazones 5→4 y ausencia de daños repetidos en 18 fotogramas. No se reposicionó artificialmente el anzuelo. Captura auténtica `qa/arga_rc7_flutter/arga_fisher_after_hook.png` guardada por QA bot en `24669e8`, HUD con cuatro corazones y Miren oculta transitoriamente por parpadeo de daño; la posición se comprueba por el motor y no solo la imagen. Pendientes: piedra del niño, contacto de trucha, ambos personajes y alfa.

- 08/11/2026, microfase Arga: CI `42512610207` **SUCCESS** para `arga_boy_gameplay_stone_test.dart`, piedra natural del niño con corazones 5→4, sin daño duplicado; captura auténtica `qa/arga_rc7_flutter/arga_boy_after_stone.png` persistida por QA `a76ae7a`. CI siguiente activada en `394cf18`: `arga_trout_gameplay_leap_hit_test.dart` (`054645d`) para comprobar salto y contacto de trucha sin manipulación de trayectoria. Resultado pendiente; aún no declarar capítulo listo para nueva APK.

- 08/11/2026, siguiente microfase: CI `42513083709` **SUCCESS**. `test/arga_trout_gameplay_leap_hit_test.dart` comprueba salto natural desde agua, contacto con Miren y pérdida de un corazón (5→4), sin daño repetido en 18 frames. Captura genuina `qa/arga_rc7_flutter/arga_trout_after_leap_hit.png` guardada en commit QA `2c65ecb8`. Las cuatro interacciones enemigas principales ya tienen test de bucle Flutter, además de caída/reaparición. **Aún pendiente:** revisión visual de esta captura, todas las variantes de frames/alfa, prueba con Sara y aprobación para próxima versión; no confundir CI verde con capítulo terminado.

- Nueva microfase 08/11: `test/arga_sara_gameplay_leap_hit_test.dart` (`66f47b6`) verifica a **Sara** como heroína activa (`qaSelected:1`), salto autónomo de trucha, daño único y ausencia de repetición; incluido en workflow (`865bc3d`) y disparado en commit `8a47934`, ejecución `42513734276` **pendiente**. Observación sobre rectángulos blancos en HUD de capturas Flutter-test: `lib/main.dart` pinta textos `MIREN`, contador y título de capítulo en esas mismas posiciones; explicación probable es la fuente Ahem usada por pruebas widget, **no defecto Android demostrado**. No cambiar HUD de producción por esa hipótesis; verificar con render que cargue fuente normal/dispositivo.

- 08/11 microfase cerrada: GitHub Actions `42513734276` **SUCCESS** incluyendo `test/arga_sara_gameplay_leap_hit_test.dart`: `qaSelected:1` activa Sara, trucha salta con lógica propia, corazones 5→4, y 18 fotogramas siguientes sin segundo daño. Se conserva la prueba equivalente de Miren y las cuatro de enemigos más caída/respawn. Código `66f47b6`, workflow `865bc3d`, disparador `8a47934`. Pendientes: otras tres interacciones con Sara, revisión exhaustiva de cada fotograma/alfa y validación móvil; estado sigue QA-only.

- 08/11 microfase Sara vs. tres enemigos restantes: nuevo `test/arga_sara_other_enemies_gameplay_test.dart` commit `3e11026`, parametriza cangrejo (pinza x350), pescador (anzuelo x1260) y niño (piedra x1980), activa `qaSelected:1`, permite lanzamientos naturales y exige corazones 5→4 sin daños repetidos. Workflow `e3d7e56`, ejecución `42514687009` iniciada por `6a909cd`; **resultado pendiente**, no certificar hasta CI y revisión de logs.

- 08/11 confirmación: Actions `42514687009` **SUCCESS** tras ejecutar `test/arga_sara_other_enemies_gameplay_test.dart`: las tres pruebas Flutter de Sara (cangrejo, pescador, niño) pasan; daño 5→4, sin repetición 18 fotogramas, con anzuelo/piedra lanzados por su mecánica normal. Se conservan todas las pruebas de Miren, trucha de Sara y ahogamiento. La matriz de interacción básica 4 enemigos × 2 protagonistas queda comprobada en bucle Flutter bajo QA (`TWC_ARGA_ATLAS_QA=true`). **No equivale** a revisión visual completa de los 96 frames, alfa, movimiento en Android o autorización de publicación.

- 08/11 auditoría atlas 96 celdas: script de diagnóstico solo lectura `qa/audit_arga_atlas_frames.py` (`ae26084`); informe completo `docs/continuidad/ARGA_AUDITORIA_96_FOTOGRAMAS_2026-11-08.md` (`8fb0e6d`). Cuatro atlas 4×6: 96 celdas ocupadas, 72 pares adyacentes con siluetas diferentes, alfa máximo 254/255 en los 96. Píxeles de alfa tenue distantes de silueta en 24/24 cangrejo, 11/24 pescador, 22/24 niño, 8/24 trucha según umbral conservador. Inspección ocular de los cuatro atlas realizada; efectos acuáticos y chispas no deben borrarse por umbral ciego. **Pendiente de validación artística:** composición sobre fondos claros/oscuros y continuidad animada a velocidad de juego, escala/pivotes y aprobación para Android. Originales preservados.

- 08/11 siguiente microfase de animación: `test/arga_all_96_frames_render_test.dart` (`6e8c371`) obliga a `StagePainter` a pintar las 24 celdas de cada uno de los cuatro atlas y compara firmas de píxeles en regiones locales a intervalos de 1/9 s, sin guardar 96 PNG ni alterar fuentes. Incluido en workflow (`444c3e7`) y ejecutado por trigger `9b59766`, run `42515650427`: **pendiente**. Sirve para detectar fotogramas renderizados idénticos, no para certificar suavidad estética, contactos de pies ni halos.

- El primer CI `42515650427` permaneció prolongadamente en lectura de imágenes del test 96; se corrigió el manejo de futuros de imagen con `tester.runAsync` (`c325387`) para evitar esperas bajo el reloj falso de `flutter_test`. Segunda ejecución `42516024803` solicitada en `0f5a32d`, quedó a la espera de la anterior por grupo de concurrencia. Hasta concluir la segunda, estado de test 96 renderizado **pendiente**, sin declarar QA final.

- Diagnóstico confirmado por log CI: `42515650427` **FAILURE** a las 8 min por `TimeoutException`, cuatro tests 96-frame quedaron bloqueados en espera asíncrona de imagen; **no** fueron fallos de contenido del atlas. Corrección `c325387` usa `tester.runAsync` para lectura del `RenderRepaintBoundary`; la segunda ejecución `42516024803` ha comenzado. Pendiente resultado nuevo.

- 08/11 validación concluida: segundo GitHub Actions `42516024803` **SUCCESS** con el test corregido `test/arga_all_96_frames_render_test.dart`: 4 pruebas widget, una por enemigo, fuerzan seis filas × cuatro fotogramas a 9 fps de selector y comparan píxeles reales de `StagePainter` en región local; **96/96 renders comprobados**, 72 comparaciones consecutivas en motor distintas. Además vuelven a pasar análisis de Dart, pruebas de movimiento/combate de Miren y Sara y capturas 20:9. La primera ejecución `42515650427` falló solo por timeout de captura bajo fake-async (resuelto en `c325387`). **Límite explícito:** transiciones forzadas con posición fija no equivalen a vídeo de partida Android ni prueban subjetivamente suavidad, pivotes o halos. Atlas siguen QA-only, recursos aprobados intactos, sin APK ni merge.

- 08/11 preparación release: `lib/main.dart` commit `125216b` habilita **octavo capítulo Río Arga** en rama de próxima versión (`twcArgaNextVersionEnabled=true`), carga atlas y fondos en app normal, acceso nuevo botón de mapa y guardado 0..7; deja intactos siete capítulos previos. Test de selección `test/arga_next_version_map_entry_test.dart` (`db1abcf`), workflow `ea63e75`, ejecución `42517083475` disparada por `883ed27`: **pendiente**. No hay APK ni merge ni validación Android. Si el mapa o el arranque normal fallan, corregir antes de aceptar release.

- CI integración Arga `42517083475` **FAILURE** exclusivamente en test de mapa: pantalla `_chooseScreen` intentaba cargar `assets/images/scenes/arga.png` (inexistente) al seleccionar capítulo 8; Flutter registró asset missing. Se sustituyó por recurso real `assets/images/arga_rc7/arga_far_rc7_candidate.webp` en `lib/main.dart` commit `5665ffc`, preservando siete capítulos. Nuevo run `42517410292` disparado por `c8fe46f`: **pendiente**. Las pruebas de combate y 96 renders pasaron antes de ese punto.

- Integración de capítulo 8 validada: CI `42517410292` **SUCCESS** con `arga_next_version_map_entry_test.dart`: aparece botón `8 · RÍO ARGA`, contador 0/8, selección cambia `stage=7` y crea cuatro enemigos; carga fondo de selección real corregido `5665ffc`. Revalidó 96 fotogramas y combate de ambas protagonistas. Para inspeccionar composición visual de mapa sin inventar imagen, test ampliado en `2164b82` para guardar `qa/arga_rc7_flutter/arga_next_version_map.png`, workflow `9faf12d`, ejecución activada por `06d54d5`: resultado/captura pendiente.

- Captura real de mapa: CI `42518003816` **SUCCESS** tras esperar decodificación bitmap (`475d911`), imagen `qa/arga_rc7_flutter/arga_next_version_map.png` persistida por QA commit `fa2ca31`, 1000×450. Inspección visual detectó botón Arga oculto por contador: era error de orden de capas y ubicación (no de PNG original). Corregido en `lib/main.dart` `fa35ccd` moviéndolo al final del Stack y zona del río; test geométrico nuevo `347149c` exige que el texto no se superponga con contador. Nuevo CI lanzado `d3046da`, pendiente. No declarar mapa aprobado hasta ver la captura corregida.

- **08/11 cierre de preparación para próxima versión:** CI `42518369464` **SUCCESS** (analizador Dart, 96 fotogramas pintados por Flutter, ataques 4 enemigos × Miren/Sara, muerte/reaparición, mapa octavo capítulo). La captura real `qa/arga_rc7_flutter/arga_next_version_map.png` versionada en QA commit `f2856df` se inspeccionó: botón nuevo sobre el río visible y separado del contador, sin segundo fondo; reposicionado en `fa35ccd` y protegido por test de no solapamiento `347149c`. Los textos de capturas widget aparecen como bloques Ahem, no es evidencia de fallo del texto Android. 
  **Estado preciso:** código del Río Arga, escenarios y cuatro enemigos **integrados y preparados en rama de próxima versión**, con pruebas Flutter satisfactorias. Falta verificación real de APK Android (rendimiento, continuidad percibida, controles y texto en dispositivo) y aprobación artística final; no se compiló APK ni fusionó PR #5. Los WebP originales están preservados. No prometer publicación definitiva hasta esa comprobación.
# 2026-11-08 — Rehacer jugador rival clásico del campo de entrenamiento

- Se confirmó que el objetivo era `rival`, no `rival_coach` ni `rival_supporter`.
- Originales `rival_0..5.png` preservados. Imagen de referencia antigua comparada con atlas aprobado del limpiador.
- Atlas nuevo 4×6/24 poses de equipación rojiblanca, transparencia RGBA; comprobados visualmente los 24 fotogramas y los límites de cada celda, optimizado a 237 colores sin añadir fondos.
- Carga, selección de acciones y dibujo en `StagePainter` integrados. Prueba unitaria de las 24 celdas y prueba de capturas reales preparadas. La selección de imagen mantiene un anclaje por pies, escala constante, física y daño existentes.
- Primer commit de integración remoto: `beedf40e8b29fd552e805ce274b75e016999866f`. Verificado el SHA exacto del PNG en la rama pública.
- Pendiente Flutter real: análisis, ejecución de pruebas, capturas 20:9 y revisión de escala/pies/ataque/derrota antes de marcar entrega aprobada. No se ejecutaron Actions ni APK.

## 2026-11-09 — Jugador rival: microfase de animación real

Detectado salto directo a pose de derrota 23; las poses 20, 21 y 22 quedaban sin uso. Corregida selección de las cuatro poses de derrota/impacto/ataque con el reloj de cada evento (`deathAt`, `stunned`, `meleeWarning`), preservando movimiento, física y originales. Ampliada prueba `rival_player_atlas_test.dart`, adaptado el test de StagePainter y registrado en workflow manual `enemy-qa-only.yml`. Recortes 24/24 comprobados mediante alfa del PNG real, no con arte inventado. Falta ejecutar el runner Flutter para confirmar la imagen integrada y las pruebas.

## 2026-11-09 — Cierre del rival clásico con evidencia real de Flutter

Con autorización, se ejecutó QA en Actions: #9 detectó error de redondeo (`[12,12,14,15]` frente a `[12,13,14,15]`), corregido con épsilon; #10 validó todas las pruebas de comportamiento y falló en capturas por test decimal/Estafeta ajeno; #11 **SUCCESS** en análisis, comportamiento y capturas auténticas de enemigos clásicos. Evidencia real guardada en `qa/enemy_verified_render/classic_rival.{jpg,webp,gif}` por `76dd51a`; inspeccionados fondo, escala, pies y caída horizontal. Se preservan las seis poses originales y el entrenador rival. Workflow devuelto a manual para evitar nuevas ejecuciones. Preparado técnicamente para RC siguiente; revisión subjetiva del usuario en Android todavía pendiente.

## 2026-11-09 — Manual maestro y respaldo documental

Consolidación transversal de creación de protagonistas, enemigos, NPC y animales en `docs/FRAMEWORK_SNES_TWC/MANUAL_MAESTRO_PERSONAJES_SNES.md` y `PLANTILLA_FICHA_PERSONAJE.md`. El manual distingue imagen aprobada, PNG original, atlas, motor Flutter, captura real y test Android; recoge errores de clipping, alfa, tiempos, daño, falsa derrota, CI y transferencia GitHub. Casos de referencia: limpiador, vecina/chancla, guitarrista, jugador rival. **No se ejecutaron nuevas pruebas de juego al redactarlo**. Se solicita respaldo ZIP externo a GitHub para evitar pérdida del conocimiento.

## 2026-11-09 — Identificación del retorno al mapa en todos los capítulos

Solicitud del usuario: identificar el botón circular para volver al mapa. Inspeccionado `_play`: existía botón circular de pausa con acceso indirecto a «VOLVER AL MAPA». Incorporado control circular independiente de flecha izquierda + `MAPA` y borde dorado, sin eliminar pausa ni tocar `_returnMap` (guarda al mapa). Se aplica a todos los capítulos por composición común. Revisión de diff completada; **análisis, test visual y Android pendientes** al no disponer localmente del SDK Flutter. Sin CI manual ni APK.

## 09/11/2026 — Portero

Microfase de inspección de los cinco sprites `goalkeeper_0..4`, identificación de su ruta de dibujo y creación de propuesta SNES de seis poses, aislada en `qa/goalkeeper_rebuild_20261109/`. Sin reemplazo de activos, Flutter ni Actions. Continuidad: `docs/continuidad/PORTERO_RECONSTRUCCION_2026-11-09.md`.

