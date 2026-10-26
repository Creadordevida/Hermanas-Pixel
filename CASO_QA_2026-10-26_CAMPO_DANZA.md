# Aprendizaje SNES: exterior deportivo e interior de danza

**Fecha:** 26-10-2026. **Proyecto:** Las aventuras de Miren y Sara, RC7.
**Estado:** integrado en código fuente, **sin capturas Flutter ejecutadas ni
aprobación artística o prueba Android**.

## Objetivo de experimentación

Tras el capítulo 1 (paisajes del barrio basados en fotografías), demostrar que
el protocolo de arte de Super Nintendo puede adaptarse a dos entornos muy
diferentes: un campo deportivo abierto con horizonte montañoso y una escuela
de danza interior con paredes, espejos, puertas, luz y parquet.

## Fallos preexistentes comprobados

- Campo: un panel de 640 px con banquillo, valla, conos y siluetas de entrenar
  se repetía a intervalos regulares, mezclándose con un gran fondo general.
  Había también una zona borrosa/artifactada en la imagen de referencia.
- Danza: el mismo trozo de barra y suelo interior se repetía cada 640 px;
  parte del panel tenía una forma triangular o pegote gráfico visible.
- Los capítulos usaban fondos similares de 1320×480, sin secuenciación de
  ambientes. Repetir un elemento de arquitectura, una portería o el piano como
  textura confunde la escala del mundo.

## Diseño aplicado

### Campo de entrenamiento, capítulo 5

1. **Entrada**: edificio auxiliar, verja y acceso al recinto.
2. **Ejercicios**: porterías de práctica, vallas, maniquíes y material lejano.
3. **Gradas**: graderío cubierto y meta, un único lugar reconocible.

Misma luz diurna, cerros lejanos, vegetación, valla y anchura de horizonte.
El jugador permanece sobre el césped original a y=386.

### Danza, capítulo 6

1. **Vestíbulo**: recepción, puerta, carteles de ballet, mobiliario al fondo.
2. **Estudio principal**: grandes espejos, ventanales, piano y barras.
3. **Ensayo escénico**: cortinas rojas, iluminación y piano auxiliar.

El interior cambia de luz y función sin cambiar inexplicablemente de escala
arquitectónica. El personaje conserva el parquet original a y=286.

## Ingeniería

- Dos series de tres fondos reales RGB, dimensiones 1672×941 cada una.
- Rango de zonas en ambas fases: 0–10500, 10500–25500, 25500–36500 unidades.
- Cámara panorámica por zona, con recortes sin deformación y disolvencia de
  900 unidades antes de cada frontera. No hay espejo ni bucles panorámicos.
- Para campo se usa una ventana fuente de 690 px de alto sobre 386 px de
  escena; danza usa 545 px sobre 286 px, conservando la relación de aspecto.
- Atlas distintos para seis objetos de fútbol y seis objetos de danza. Los
  objetos viven en posiciones de mundo, con un patrón irregular y catálogo
  sensible a la zona. La arquitectura permanece exclusiva del fondo.
- Se conservan sin cambios tanto los sprites aprobados de Miren/Sara como los
  ficheros de fondos anteriores, las físicas y los dos suelos originales.

## Fallo detectado DURANTE esta tarea y su resolución

El primer atlas de danza incumplía los márgenes: la planta superior sobrepasaba
la separación nominal entre filas. Se rechazó y solicitó otro atlas. El atlas
final aún contiene unos píxeles de la maceta entre y=512 y y=519, por lo que
**no se finge que el grid 3×2 sea perfecto**: los seis límites alfa reales
están medidos individualmente, y la planta se recorta hasta y=519 sin incluir
objetos inferiores. Tests verifican que los recortes nunca se solapan y que
mantienen un margen de contorno.

Otro aprendizaje: las transparencias pueden contener halos suaves que no
pertenecen al sprite y se hacen visibles sobre parquet/césped. Los recortes
por píxeles sólidos y su padding de 4 px impiden dibujar el halo exterior.

## Controles transferibles al futuro GPT

1. Una fase larga necesita varios ambientes reconocibles, no repetir un único
   panel panorámico o una hilera con monumentos cada 640 píxeles.
2. En exteriores, mantener horizonte, valla, vegetación y sentido de escala;
   en interiores, mantener alturas de ventanas, espejos, zócalos y perspectiva.
3. No estirar fondos para llenar alturas distintas: calcular ventana fuente
   proporcional a la altura visible.
4. Suelo visual, suelo físico y sombras deben coincidir, con cotas específicas
   por capítulo. No añadir una segunda capa de pavimento falsa.
5. Medir el alfa real de cada objeto con márgenes de seguridad; si un atlas
   invade otras celdas, rechazarlo o usar recortes precisos que no se solapen.
6. Nunca utilizar una imagen generada como evidencia de pantalla Android.
   Inspeccionar capturas del verdadero motor a ambos lados de las transiciones,
   con protagonistas y obstáculos a tamaño jugable.
7. Proteger por hash el material anterior; guardar un checkpoint reversible.

## Evidencias y puertas pendientes

- **96 pruebas Python locales correctas** y recursos esenciales intactos.
- `qa/ACTIVITY_SCENES_MANIFEST.json` mantiene hashes de los ocho archivos
  nuevos y siete referencias originales protegidas.
- `test/qa_render_capture_test.dart` exige **14 nuevas capturas reales**:
  tres zonas y cuatro posiciones en torno a fronteras por capítulo.
- `qa/check_activity_flutter_captures.py` falla si faltan capturas, son planas,
  zonas distintas son idénticas o hay un corte extremo en una transición.
- Sin SDK Flutter local no se ejecutaron análisis Dart ni capturas, y sin
  pruebas en Android no se conoce con certeza escala final, FPS ni calidad.
- **No realizar ZIP final hasta revisión visual y cierre de lista.**
