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

Fuente maestra local SHA256 `fd56e54b43ce3a871aa85a56bd01d45af1e73f87c98497dae57810c19525c802`. Paquete entregado al usuario en la conversación: `COLEGIO_27_PANELES_RECONSTRUIDOS_LISTOS_PARA_INTEGRAR.zip`, SHA256 `ac7e65824017ac3b3b74b88fa4919d8ed6b863c37183a21bfe68662b71b802a9` (ESTE HASH PUEDE CAMBIAR SI SE ACTUALIZA EL PAQUETE Y DEBE REVALIDARSE).

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
