# Las aventuras de Miren y Sara — 0.9.0 RC3 · prueba técnica

**Este ZIP no es una versión aprobada para publicación.** Es una compilación candidata para la prueba del usuario en su Android. **No reemplazar la copia protegida de la 0.8.0** ni dar la calidad por validada solo porque GitHub compile.

## Subida con GitHub Desktop

1. Guarda una copia del repositorio anterior o utiliza una rama de pruebas; se recomienda crear `prueba-rc3` desde `main` y publicarla. Si se utiliza `main`, la compilación se iniciará automáticamente tras `Push origin`.
2. Extrae el ZIP y copia su **contenido** en la carpeta raíz clonada, sin crear un subdirectorio adicional. **No borres `.git`.**
3. En GitHub Desktop revisa `Changes`, realiza Commit y Push origin. En GitHub Actions busca `Compilar Miren y Sara 0.9.0 RC3 - PRUEBAS`.
4. Si el flujo queda verde, descarga el artifact `Miren-y-Sara-0.9.0-RC3-APK`. El artifact de capturas `Capturas-REALES-Flutter-0.9.0-RC3` contiene imágenes obtenidas del renderizador Flutter **si el test de capturas termina correctamente**.
5. Comprueba en Android el mapa, selección de las siete fases, suelo, escala y ataques. Captura y describe cualquier fallo antes de aprobar esta candidata.

## Qué se ha modificado de forma verificable

- El selector usa como asset **exactamente** `assets/images/worldmap/pamplona_aprobado.png`, con el SHA256 especificado en `qa/scene_metrics_vnext.py` y los siete rótulos originales como áreas pulsables. No se generan nuevos carteles encima.
- La representación de los fondos ya no invierte automáticamente tramos pares/impares ni estira imágenes de 1320 píxeles a 1570 unidades. Las imágenes se colocan a escala natural y con metadatos explícitos de altura de suelo.
- La escala de sprites humanos, enemigos y animaciones se calcula desde su pose inicial, sin hacer grande al personaje en un golpe o caída.
- Paloma reemplazada por un sprite reconocible extraído de una referencia real de arte. Las animaciones completas de vuelo requieren aún inspección.
- `flutter analyze` queda limitado a `lib` y `test`, sin analizar los `pubspec` de la copia congelada de auditoría.
- El flujo trata de capturar inicio, unión entre tramos, mitad y final de los siete capítulos. No presenta esas capturas como pruebas de Android.

## Limitaciones detectadas antes de instalar

**BLOQUEO DE APROBACIÓN ARTÍSTICA.** Las siete fuentes de fondo no proporcionan todavía suficientes secciones nuevas diseñadas a mano. La auditoría `qa/SCENE_SEAMS_REPORT.json` señala que seis tienen bordes incompatibles para una repetición limpia. Se ha eliminado el reflejo y el estiramiento, pero **aún puede verse repetición/corte en el paso entre secciones**. No declarar resuelto este punto.

**VESTUARIO TEMÁTICO PENDIENTE.** Se rechazó una versión nueva porque parecía una camiseta geométrica dibujada encima. Los ocho PNG de ropa de esta RC3 se han restaurado a la RC2; deben redibujarse por artistas o en fuentes editables de igual calidad antes de dar esa mejora por terminada.

**ANIMACIONES PENDIENTES.** El nuevo renderizador limita cambios de tamaño, pero algunas imágenes originales de derrota y ataque de enemigos contienen recortes que no pueden repararse mediante escalado. Requieren nuevos fotogramas artísticos auténticos.

**SIN COMPILACIÓN LOCAL.** No hay Flutter/Android emulator en el entorno de creación. Pasar controles Python **no garantiza** que `flutter analyze`, `flutter test`, `flutter build apk` ni la ejecución Android funcionen: esas pruebas se ejecutan en GitHub/tu móvil.

Para detalles y métricas ver `qa/INFORME_REAL_090_RC3.md` y `qa/SCENE_SEAMS_REPORT.json`.
