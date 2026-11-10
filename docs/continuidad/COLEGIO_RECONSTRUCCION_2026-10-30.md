# Reconstrucción del capítulo 7 — Colegio (RC4-002 / RC4-005B)
Fecha: 30/10/2026. Trabajo SIN APK y SIN ejecutar GitHub Actions. PR #5 permanece sin fusionar.

## Resultado creado realmente
Se ha generado **arte nuevo** a partir de una ilustración original nueva de cinco espacios escolares diferenciados: pasillo, aula convencional, informática, biblioteca y taquillas. No se reutilizan los tres viejos murales borrosos. Un generador local creó 27 PNG RGBA independientes de **880 × 278**, exactamente bajo los nombres que consume actualmente el motor Flutter: `assets/images/interiors_parallax/school/z{0,1,2}_panel_{0..8}.png`.

La secuencia física diseñada para evitar repetición inmediata es:
- Tramo 0: pasillo → taquillas → pasillo → biblioteca → pasillo → taquillas → biblioteca → pasillo → taquillas.
- Tramo 1: aula → pasillo → aula → biblioteca → aula → pasillo → aula → biblioteca → pasillo.
- Tramo 2: informática → taquillas → informática → biblioteca → informática → taquillas → informática → biblioteca → taquillas.

La ilustración nueva evita las plantas poligonales y manchas de siluetas oscuras del colegio RC4. Las ventanas mantienen transparencia RGBA (no se simula movimiento pegando paisajes fijos), preservando el paisaje far/mid de capítulo 1 aprobado y los desplazamientos 0.30 / 0.56 del código Flutter.

## Pruebas realmente ejecutadas
1. Pillow generó **27/27 archivos PNG RGBA** de 880×278, todos con hash SHA256 distinto.
2. Se comprobaron los 5 tipos de estancia; PNGs y maestros no sufrieron reescalado de los recortes interiores.
3. Se comprobaron hashes SHA256 de cada archivo de salida y origen, así como lectura completa del ZIP sin errores.
4. Se compusieron previsualizaciones de tres tramos con el paisaje far/mid aprobado en dos posiciones de cámara. Tasa de píxeles móviles **7,5% / 7,2% / 8,7%**, paredes y mobiliario inmóviles. **Son composiciones PIL, NO capturas reales Flutter**.
5. Se corrigió una previsualización local que situaba erróneamente el suelo a y=340: el motor Flutter real usa y=278 para el suelo del capítulo del colegio. No certificar calidad a partir de la previsualización errónea.

Fuente maestra local SHA256 `fd56e54b43ce3a871aa85a56bd01d45af1e73f87c98497dae57810c19525c802`. Paquete entregado al usuario en la conversación: `COLEGIO_27_PANELES_RECONSTRUIDOS_LISTOS_PARA_INTEGRAR.zip`, SHA256 `a168c2898dc30f71d5f3f3a11919b017a856b90d6f486bb14459f9c2e022ba3a` (ESTE HASH PUEDE CAMBIAR SI SE ACTUALIZA EL PAQUETE Y DEBE REVALIDARSE).

## Integración de código GUARDADA en GitHub
- `tools/build_school_hifi_twc.py`: generador reproductible usando la fuente original `assets/images/school_hifi/school_five_scenes_master.png`.
- `tools/build_interiors_parallax_twc.py`: ejecuta el generador nuevo si el original está presente; `TWC_REQUIRE_SCHOOL_HIFI=1` impide una compilación que use murales antiguos por error.
- `lib/interiors_parallax_twc.dart`: `TWC_SCHOOL_HIFI_ART` con secuencia física de nuevo arte (9 composiciones por zona), roles correctos en pasillos/aulas/TIC, y evita superponer falsos marcos en cada cambio.
- `lib/main.dart`: con la bandera HIFI habilitada, no dibuja viejos pupitres/monitores duplicados sobre el mobiliario que ya lleva el arte ilustrado.
- `qa/check_school_hifi_twc.py --strict`: inspecciona 27 PNG reales, manifiesto SHA de fuente y PNG, RGBA/alfa de ventanas, variedad física y correspondencia con motor.

**El modo HIFI está DESACTIVADO POR DEFECTO** hasta que estén los PNG fuente confirmados y guardados; así no se rompe la RC5 previa.

## LIMITACIÓN ABIERTA: NO CONFUNDIR CANDIDATOS LOCALES CON INTEGRACIÓN GIT
En esta sesión el conector GitHub guardó **todo el código anterior**, pero NO los bytes binarios nuevos. En el árbol remoto aún existen 27 PNG ANTIGUOS; la ruta `assets/images/school_hifi/school_five_scenes_master.png` continúa ausente. El ZIP local real sí contiene la maestra bajo esa ruta y los 27 paneles en sus rutas definitivas.

**Por ello el capítulo NO ESTÁ TODAVÍA SOLUCIONADO DEFINITIVAMENTE NI OPERATIVO EN UNA BUILD DE GITHUB.** No afirmar lo contrario, incluso si las imágenes locales son visualmente superiores. Para cerrar es imprescindible transferir los bytes reales de fuente + 27 paneles, comprobar SHA remoto, habilitar `TWC_SCHOOL_HIFI_ART=true` en la futura candidata, ejecutar generador y pruebas Flutter REAL en un checkout con los archivos, inspeccionar varias escenas y luego verificar en Android con autorización expresa. Ninguna APK ni Action se ha ejecutado.

**No pedir al usuario que repita el diseño ni reiniciar el trabajo.** El paquete y el generador son resultados de esta sesión: conservarlos y recuperar esos bytes al reanudar.

### Revisión final del paquete local
Se reorganizó la secuencia real de 9 módulos para impedir espacios idénticos seguidos, de manera compatible con `interiorModuleVariantTWC` cuando `TWC_SCHOOL_HIFI_ART=true`. La copia final de 15.443.906 bytes incorpora comparativa RC4 vs arte nuevo, previsualizaciones con paisaje far/mid en movimiento, maestro de 5 estancias y 27 PNG. SHA256 ZIP final: `a168c2898dc30f71d5f3f3a11919b017a856b90d6f486bb14459f9c2e022ba3a`. La ausencia de bytes GitHub y la falta de pruebas Flutter siguen siendo bloqueantes.

## ACTUALIZACIÓN — 30/10/2026, NUEVA REFERENCIA EXACTA SIN PERSONAJES

El usuario sustituyó las imágenes conceptuales anteriores por el archivo cargado en este chat `image(20261030-194900).png` y ordenó que **ESA** obra arquitectónica, sin los rótulos de presentación, constituyera los fondos reales de los cinco espacios escolares. **Master exacto:** 1448×1086 RGBA, SHA256 `4370a461007d4e96bef60da32e827995301f41f7d1662fec9749da739d72bc9b`. No confundir con la antigua master de 1536×1024.

**GitHub: código REAL ya actualizado (y confirmado en API), sin APK:**
- `tools/build_school_hifi_twc.py`: reemplazado por generador de la maestra nueva, recorte y ampliación **proporcional**, cabezales de galería eliminados, ventanas con alfa calculadas por geometría de cristales y no por umbral cromático; secuencia 27 paneles y cinco tipos físicos.
- `lib/interiors_parallax_twc.dart`: plan real pasillo/taquillas/biblioteca, pupitres/pasillos/biblioteca y aula informática/taquillas/biblioteca; `TWC_SCHOOL_HIFI_ART` activo por defecto en la rama de trabajo, jamás altera la APK RC5 ya publicada.
- `lib/main.dart`: activa suelo corregido `assets/images/ground/stage_6_hifi.png` SOLO para colegio HIFI, preservando suelo antiguo; el mobiliario original duplicado sigue condicionado a que el HIFI esté apagado.
- `tools/clean_school_floor_hifi.py`: elimina el elemento vegetal poligonal incrustado en el viejo suelo sin sobrescribir el original; lo genera después del arte escolar.
- `tools/build_interiors_parallax_twc.py`: usa la obra nueva si existe; **falla expresamente** si no existe, impidiendo una nueva APK con antiguos murales por error. Ventanas siguen viendo los mismos paisajes detallados de capítulo 1 con velocidades `0.30/0.56`. Se ajustó el recorte vertical de escuela para mostrar montañas, fachadas y arbolado en vez de solo cielo, sin alterar las capas de danza.
- `qa/check_school_hifi_twc.py`: comprobación estricta de SHA de obra MAESTRA contra hash fijado arriba, 27 paneles y cinco tipos, tamaño, píxeles de vidrio, suelo limpio, y hashes de PNG. `qa/test_interiors_twc.py` reconoce el modo nuevo y evita la falsa regresión que comparaba murales antiguos. Nueva prueba de render real `test/school_hifi_real_render_test.dart`: cinco salas y dos uniones en 20:9, con StagePainter real, lista para ejecutar cuando estén los PNG.

**Recurso local GENERADO Y PROBADO, no subido a GitHub:** paquete `COLEGIO_REFERENCIA_EXACTA_27_PANELES_Y_VENTANAS_MOVILES.zip`, 44 ficheros; SHA256 `c9579acf7ba154cfaaa31ffd237bacb50d7a723000bbea278f0123008e2dee78`. Contiene la imagen maestra de 4.123.861 bytes, los 27 PNG RGBA de 880×278 (9 por zona), el suelo sin planta geométrica (540×202), manifest con SHA de 27 PNG, script y evidencias PIL. Inspección ZIP `testzip()` superada.

**Pruebas locales reales realizadas:** comprobados 27 tamaños, unicidad de hashes, 5 familias, maestra intacta y alfa de ventanas, píxeles de marco opacos; previsualización mediante Pillow usando los DOS ciclos de parallax reales de capítulo 1, comparando desplazamientos de exterior 0/550. Por zona, porcentaje de píxeles que cambia en las zonas transparentes: **99,5 %, 99,4 %, 98,4 %**. Fuera de zonas transparentes el movimiento aparente es **0,068 %, 0,190 %, 0,073 %**, principalmente por interpolación de bordes de cristales. **No son capturas Flutter.**

**Bloqueo concreto demostrado por consulta GitHub:** el master `assets/images/school_hifi/school_five_scenes_master.png` da 404 y el suelo `assets/images/ground/stage_6_hifi.png` también. Los antiguos 27 PNG siguen en el árbol; el conector `mcp__GitHub__create_blob` admite contenido Base64, pero NO puede leer directamente los bytes generados en el contenedor de arte y no hay Git autenticado desde el contenedor. La nueva maestra y los 28 PNG siguen pendientes de subida binaria. **Por esta razón los defectos RC4-002 y RC4-005B NO ESTÁN CERRADOS, NO EXISTE VALIDACIÓN FLUTTER REAL y NO HAY APK NUEVA.**

**Condición de cierre:** subir maestra + 27 PNG + suelo limpio a las rutas exactas; repetir SHA remoto; ejecutar generador y QA estricto; ejecutar `flutter test test/school_hifi_real_render_test.dart` SIN COMPILAR ANDROID, inspeccionar sus siete capturas reales; comparar con la referencia y corregir cualquier deficiencia. No declarar “resuelto” mientras falte una de esas pruebas.

**Regla del usuario vigente:** NO generar más APK ni disparar builds Android hasta nueva autorización expresa. PR #5 en borrador, sin merge.

## CIERRE TÉCNICO DE LA TRANSFERENCIA: solución de una sola subida (30/10/2026)

**VERIFICADO LOCALMENTE:** recuperado ZIP exacto de 18.505.839 bytes, SHA256
`c9579acf7ba154cfaaa31ffd237bacb50d7a723000bbea278f0123008e2dee78`.
Master 1448×1086 SHA256 `4370a461007d4e96bef60da32e827995301f41f7d1662fec9749da739d72bc9b`.
Los 27 PNG RGBA 880×278 coinciden 27/27 con los SHA del manifiesto.
El importador `tools/import_school_exact_twc.py` se probó en una carpeta vacía:
importó 30 archivos exactos (maestro, 27 paneles, suelo, manifiesto) sin error.

**CAMBIOS EFECTIVOS DE CÓDIGO GITHUB:**
- `qa/check_school_hifi_twc.py`: corregido error Python de sangría y comprobación del flag Dart en el archivo correcto.
- `tools/build_interiors_parallax_twc.py`: el generador antiguo ya no reescribe los 27 PNG aprobados ni el suelo cuando están presentes; exige hashes idénticos al manifiesto, de lo contrario detiene el proceso. Mantiene far=.30, mid=.56.
- `tools/import_school_exact_twc.py`: importación autorizada solo si coinciden SHA de ZIP/master y 27 SHA individuales.
- `.github/workflows/school-hifi-only.yml`: integración AUTOMÁTICA de los binarios originales mediante un ZIP en `qa/school_inbox/`, pruebas Python, Flutter real 20:9 de 5 habitaciones + 2 transiciones, y commit de 30 activos y 7 capturas, sin compilar Android. Se configura `contents:write`; no se ejecuta al modificar solo documentación o código. No borrar el ZIP activador para evitar segundas ejecuciones.
- `qa/school_inbox/README.md`: instrucción de subida en un solo archivo para el usuario.

**BLOQUEO EXTERNO QUE SIGUE ABIERTO:** el conector GitHub acepta blobs Base64, pero este entorno no dispone de puente para transferirle automáticamente los bytes del contenedor. Tampoco hay credenciales Git de red desde el contenedor. El ZIP sigue AUSENTE de GitHub: **NO afirmar que los 27 PNG nuevos estén en la rama** ni que exista render Flutter aprobado.

**INTERVENCIÓN MÍNIMA NECESARIA:** el usuario sube un ÚNICO ZIP original de 18,5 MB (sin descomprimir) en la carpeta `qa/school_inbox/` de la rama `work/revision-visual-20261028-continuidad`. GitHub permite 25 MiB de subida por archivo desde web. El archivo debe llamarse exactamente `COLEGIO_REFERENCIA_EXACTA_27_PANELES_Y_VENTANAS_MOVILES.zip`. Al hacer commit, se dispara exclusivamente `.github/workflows/school-hifi-only.yml`; ejecuta Python/Flutter y, si supera todo, integra y confirma assets/capturas en GitHub sin APK. Si falla, diagnosticar el run y corregir la causa, usar el marcador de reejecución `.github/trigger-school-hifi-qa.txt` sin pedir otra subida.

**ESTADO REAL:** transferencia remota y prueba Flutter PENDIENTES; no se ha ejecutado ninguna Action ni APK; PR #5 abierta sin fusionar. No declarar «solucionado» hasta confirmar SHA remoto y revisar las siete capturas.
