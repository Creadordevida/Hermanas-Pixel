# Nueva mejora acumulada — cinco corazones por protagonista

Origen: proyecto 0.9.0 RC4. Estado: implementada en copia de desarrollo; NO publicada como APK.

## Implementación
- Constante única `maxHeroHearts = 5` (`lib/hero_hearts.dart`).
- Miren y Sara empiezan los capítulos con 5 corazones, incluidos capítulos compartidos.
- Cada impacto reduce exactamente 1 corazón, sujeto a la invulnerabilidad temporal que ya existía.
- Al reintentar un capítulo se recuperan los cinco corazones; la partida acaba al llegar a cero.
- El HUD contiene 5 corazones con huecos vacíos visibles; no se encoge al perder vida.
- La selección de personaje también muestra 5 corazones y conserva el mismo tamaño de tarjeta.
- La especificación de versión declara `health_per_character: 5`.

## Controles
- `qa/test_hearts_contract.py`: inspección de puntos de inicio, reinicio, daño, HUD y selección; pruebas negativas detectan límite viejo de 2 y pérdida de un hueco visual.
- `test/hero_hearts_test.dart`: comprueba daño, máximo, muerte, 5/3/0 corazones y anchura compacta del HUD. Se ejecutará en GitHub Actions con Flutter.
- Recursos artísticos de RC4 intactos; integridad base 0.8.0 y 134 rutas gráficas correctas.

## Ejecución en este entorno
- 52 pruebas Python locales: correctas.
- Scripts de QA de recursos/capas y verificación estática de delimitadores: correctos.
- Pruebas Flutter y APK Android: pendientes; Flutter no está instalado en este entorno.

## Pendientes anteriores de RC4
- Redibujar vestuarios naturales y completar fotogramas humanos dañados.
- Verificar continuidad gráfica y rutas de capítulos completos en Android.
- No publicar un ZIP como versión terminada basándose solo en estas pruebas.
