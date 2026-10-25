# Las aventuras de Miren y Sara — 0.9.0 RC6 (candidata para Android)

## Estado y origen
Esta entrega parte de la **RC5 con uniformes aprobados**. No es una nueva línea gráfica: los recursos de las protagonistas se mantienen byte a byte. Conserva la referencia protegida 0.8.0, las siete fases y los cinco corazones.

## Cambios reales incorporados

1. **Futbolista rival:** fotogramas de carrera 1–3 reparados con una pierna trasera procedente de su pose original íntegra. Se conservaron las poses delanteras y la identidad.
2. **Árbitro:** poses 2–3 recompuestas desde la figura íntegra y el brazo con tarjeta de la hoja aprobada; sin el bloque negro que ocupaba medio cuerpo. Pose 4 de derrota reconstruida tumbando la figura completa. Sigue lanzando una sola tarjeta tras la preparación y con 3,6 s de pausa.
3. **Profesora:** piernas y zapatos integrados desde la imagen aprobada del capítulo escolar, sin monedas ni fondo. Pose de derrota reconstruida a partir de la figura completa. Los cuatro estados de pie tienen escala homogénea.
4. **Alumno abusón:** reparación del zapato derecho que quedaba fuera del sprite mediante píxeles de la misma referencia visual.
5. **Renderizador de enemigos:** separación de espera, preparación de ataque, golpe y derrota; escala uniforme por enemigo y giro sutil alrededor del punto de apoyo durante los ataques.
6. **Fondo deportivo:** el banquillo aparece en un módulo especial cada nueve módulos; los módulos intermedios solo reutilizan la valla y elementos de entrenamiento.
7. **Escenario escolar:** la cámara de cada una de las tres zonas (pasillo, aula y ordenadores) calcula el parallax en coordenadas locales de su zona, evitando empezar en el extremo derecho de la imagen al cambiar de sala.
8. **Encuadre:** el fondo lejano muestra la parte permitida hasta el inicio del suelo, en vez de cortarse arbitrariamente antes de él.
9. **QA ampliado:** pruebas reproducibles para cada reparación, que elevan las pruebas Python locales a 68.

## Controles superados en el entorno autor
- `python qa/verify_resources.py`
- `python qa/verify_layered_scenes.py`
- `python qa/verify_candidate_assets.py`
- `python qa/release_gate.py`
- `python qa/scene_metrics_vnext.py`
- `python -m unittest discover -s qa -p 'test_*.py'` → 68 pruebas.
- Verificación de hashes de los diez sprites de vestuario de RC5.
- Verificación del mapa de Pamplona exacto y de archivos originales 0.8.0.

## Verificaciones pendientes / limitaciones
- **Flutter no está instalado aquí.** No se ha ejecutado `flutter analyze`, `flutter test` ni se ha compilado el APK en este entorno: esas pruebas corresponden a GitHub Actions.
- **No se ha probado el APK en Android.** Esta RC6 es expresamente una candidata de pruebas para tu móvil.
- Las animaciones de la profesora y el abusón siguen teniendo menos variedad de poses que las del futbolista y bailarina. Se ha corregido la falta de partes del cuerpo y se ha añadido un movimiento de preparación en el motor, pero todavía es recomendable valorarlas en el teléfono.
- Los módulos reutilizables de vallas, plantas y suelo se repiten por diseño. Todavía serán necesarios tramos artísticos inéditos para conseguir siete recorridos extensos con variedad comparable a un gran título SNES. Las pruebas no constituyen una aprobación artística.
- Algunos fotogramas todavía alcanzan los bordes de sus lienzos (13 alertas en 50 poses): no significa necesariamente un corte, pero se mantiene como control de revisión.

## Método de instalación y prueba
1. Descomprime este ZIP en una **carpeta nueva** y conserva la RC5 en una copia separada.
2. Abre GitHub Desktop → `Repository` → `Show in Explorer` para abrir la copia local del repositorio.
3. Copia el **contenido** del ZIP a la raíz del repositorio (sin crear una carpeta adicional) y acepta reemplazar archivos. No elimines `.git`.
4. Comprueba las modificaciones en `Changes`, escribe `Miren y Sara 0.9.0 RC6 - reparaciones enemigos escenarios`, pulsa `Commit to main` y luego `Push origin`.
5. En GitHub web → `Actions`, abre el trabajo **Compilar Miren y Sara 0.9.0 RC6** y comprueba sus pasos. Si aparece rojo, comparte el log antes de instalar.
6. Descarga el APK desde `Artifacts` si la compilación termina en verde. En el móvil revisa particularmente el futbolista, el árbitro, la profesora, el alumno, el campo y las transiciones del colegio.

IMPORTANTE: Una marca verde de GitHub no equivale a certificar calidad artística ni recorrido real en móvil.
