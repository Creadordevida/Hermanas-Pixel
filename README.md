# VERSIÓN ACTUAL: 0.9.1 RC1 — CANDIDATA PARA ANDROID

Lee **README_091_PRUEBAS.md** antes de subir a GitHub. El contenido histórico de RC8 se conserva debajo como referencia, pero está superado.

---

# Las aventuras de Miren y Sara — 0.9.0 RC8 REV3 (pruebas Android)

**Candidata de pruebas, no versión artística ni comercial aprobada.**
El ZIP contiene el proyecto Flutter **completo**, no un APK precompilado.
GitHub Actions ejecuta pruebas, construye el APK y publica capturas auténticas
del motor para inspección.

## Mejoras acumuladas que se prueban juntas

- Capítulo 1: cuatro ambientes inspirados en el barrio, transición por zonas,
  paisaje cercano con atlas independiente y suelo original preservado.
- Enemigos: rata y gato de mayor detalle; perros con patrulla, alerta y mordisco
  visible; palomas con cuadros de vuelo y comportamiento aéreo.
- Protagonistas: fases de salto y caída; aterrizaje con compresión, polvo y
  sombras que permanecen sobre pavimento o plataforma.
- Capítulo 5: acceso deportivo, zona de ejercicios y gradas, con objetos
  independientes, césped y uniforme de Miren aprobados.
- Capítulo 6: recepción de danza, gran estudio y espacio escénico, con
  objetos independientes, parquet y uniforme de Sara aprobados.
- Se preservan portada, mapa, referencias y protagonistas anteriores.

## Cómo probar en Android

Lee **`INSTRUCCIONES_RC8_PRUEBAS.md`** antes de copiar los archivos a GitHub.
El flujo **Miren y Sara 0.9.0 RC8 REV3 - APK Y CONTROL VISUAL** separa la
compilación Android de la auditoría gráfica. El primer trabajo publica
`Miren-y-Sara-0.9.0-RC8-REV3-APK-PRUEBAS` cuando el APK termina bien.

El analizador Dart de `lib` **y de `test`**, más las pruebas rápidas de
mecánicas, se ejecutan antes de compilar: un problema que puede detectarse en
segundos no debe obligar a esperar la compilación Android entera.

Si las capturas posteriores fallan, el trabajo de gráficos aparece ROJO, pero
el de compilación Android permanece VERDE cuando ha aprobado sus pruebas.
El APK ya construido se conserva para diagnóstico; la auditoría no se presenta
como aprobada y no existe aprobación artística automática.

## Controles

- Pruebas Python, integridad de recursos y preservación de originales.
- Análisis Dart, pruebas Flutter de mecánicas y widgets.
- Capturas genuinas de siete capítulos, barrio, fauna, saltos, fútbol y danza.
- Inspección humana y prueba física Android: **todavía pendientes**.

Historial técnico: `README_RC7_CAPITULO1.md`, `CASO_QA_*.md` y
los manifiestos `qa/`.
