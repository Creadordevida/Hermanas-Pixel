# Las aventuras de Miren y Sara — 0.9.1 RC1

**Candidata técnica para pruebas Android, NO aprobación artística.**

Fecha de trabajo: 27/10/2026. Base: RC8 REV3 + checkpoint 0.9.1 de mitad de reconstrucción. Versión del juego `0.9.1-rc.1+31`.

## Novedades integradas

1. Las cuatro ilustraciones maestras de las fotografías de Pamplona permanecen **idénticas, byte a byte** (`residential_curve`, `green_promenade`, `white_canopy`, `rocket_park`).
2. Un sistema nuevo de paneles con posiciones de mundo reemplaza el antiguo fondo casi inmóvil. Los cuatro hitos aparecen una vez; se interpolan sectores neutros y arbolado físico anclado al suelo. Los fondos **no** se funden a pantalla completa.
3. Dos paisajes ya preparados en el checkpoint y un nuevo fragmento de pérgola/jardín se incorporan como paisajes de conexión, sin tocar los originales. Hay vegetación adicional sobre las uniones. **Aún requiere evaluación visual de cada unión**: las texturas neutras siguen pudiendo resultar repetitivas en un recorrido largo.
4. Los árboles se recortan usando sus **límites alfa medidos**, en lugar de mostrar una cuadrícula con troncos cortados o raíces flotantes.
5. Portada: copia retocada únicamente en la zona de vehículos, conservando los píxeles de las protagonistas, el padre y el título original. Se conserva también la portada anterior completa.
6. Logotipo: monograma TWC con ojos de lobo y texto «THE WOLF COMPANY / MIREN & SARA SEAL OF APPROVAL», derivado del archivo corporativo original guardado en `reference/`. No es una recreación textual.
7. Los móviles extrapanorámicos muestran una prolongación visual en lugar de las bandas negras. El **área activa 800×450 se mantiene sin deformar y sin cortar botones**. Esto no equivale todavía a ampliar el campo jugable horizontal: hay que comprobar el resultado en el teléfono.
8. Palomas voladoras más pequeñas; descenso de Miren/Sara con la pose de salto, sin volver a la pose vertical en pleno aire. Sombras y demás sprites originales permanecen protegidos.
9. Flutter 3.47.8, Ubuntu 24.04, y `shared_preferences 2.3.2` fijos. Dart se analiza *antes* del APK. El workflow almacena `pubspec.lock` como artifacto para futura reproducibilidad. La plataforma Android todavía se genera con `flutter create` desde la versión fija de SDK.
10. Dos jobs independientes en GitHub: compilación/APK y QA gráfica. Las capturas se ejecutan secuencialmente, con límites de tiempo y evidencias adjuntas; un fallo gráfico no impide descargar un APK que haya compilado bien.

## Cómo instalar para probar

1. **Guarda una copia de la versión anterior** por si necesitas restaurarla.
2. Descomprime este ZIP en una carpeta nueva. En GitHub Desktop abre el repositorio y copia **todo el contenido de la carpeta extraída a la raíz del repositorio**, aceptando reemplazar archivos; no elimines `.git`.
3. En GitHub Desktop revisa Changes, escribe `Miren y Sara 0.9.1 RC1 reconstruccion capitulo 1` y pulsa **Commit to main → Push origin**.
4. Abre Actions en GitHub. El workflow se llama `Miren y Sara 0.9.1 RC1 - APK y auditoria grafica`.
5. Si `android-apk-candidato` sale verde, descarga el artifacto `Miren-y-Sara-0.9.1-RC1-APK-PRUEBAS`, descomprime y usa `app-release.apk` en el Android. No confundir este ZIP con un APK instalable.
6. El job gráfico puede quedar rojo: despliega el paso concreto y conserva los registros y capturas para diagnóstico. No lo interpretes como aprobación visual.

## Prioridades para la prueba visual

- Inicio: coches separados, título y protagonistas intactos, logo auténtico, sin bandas laterales oscuras.
- Capítulo 1: el edificio se desplaza con la cámara; las transiciones ya no mezclan fotografías a pantalla completa, pero hay que valorar si alguna unión nueva resulta brusca o si el paisaje neutro se repite demasiado.
- Árboles: pies y copas completos; revisar también las uniones cercanas a pérgola/jardín.
- Paloma, perro, rata, gato: escala, sensación de contacto y movimiento, sin sprites gigantes.
- Saltos/caídas: postura, sombra sobre el suelo, hitboxes, botones móviles.
- Fútbol, danza y los otros capítulos: verificar que continúan funcionando como en RC8, sin rediseño adicional.

## Límites de esta entrega

Las **113 pruebas Python locales** y cinco comandos de preflight han pasado, pero **Flutter y Android no se ejecutaron en el entorno autor**. No afirmamos haber validado `flutter analyze`, `flutter test`, el APK ni el aspecto en el Redmi. GitHub será la primera prueba real de esa parte. La composición, calidad de las transiciones y fluidez requieren imágenes reales del motor, vídeo de recorrido y revisión humana.

Hasta que se obtenga esa evidencia, `qa/release_gate.py --strict` debe seguir bloqueando la aprobación artística y comercial.
