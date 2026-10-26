# Caso QA: rata y gato planos que superaron los controles

**Proyecto:** Las aventuras de Miren y Sara — Hermanas Pixel  
**Fecha:** 26 de octubre de 2026  
**Objetivo:** corregir ambos enemigos y conservar el aprendizaje para el futuro GPT de creación de videojuegos estilo SNES.  
**Estado:** integrados en el código y comprobados mecánicamente; render Flutter y recorrido Android todavía pendientes.

## 1. Problema descubierto mediante vídeos del usuario

- Los sprites de rata (`assets/images/enemies/rat_0..4.png`) y gato (`cat_0..4.png`) eran figuras casi planas y poco detalladas.
- Varias poses de desplazamiento apenas variaban. El personaje parecía deslizarse más que caminar/correr.
- La rata tenía una proporción visual que podía parecer excesiva frente a las heroínas y al decorado.
- Los controles de RC6 verificaban existencia de archivos, transparencia, dimensiones, recortes y parte de la animación, pero no exigían variedad perceptible entre poses ni riqueza visual.
- Como todos los PNG originales eran RGBA de 128 × 96, esos controles podían mostrar verde sin que el usuario viera un enemigo de buena calidad.

## 2. Medición del defecto

Contando colores RGB diferentes en píxeles opacos del fotograma inicial:

| Enemigo | PNG antiguo | Nueva imagen de referencia |
|---|---:|---:|
| Rata | 15 | Más de 16.000 |
| Gato | 19 | Más de 32.000 |

La cantidad de colores no define por sí sola una buena estética SNES; aquí solo se usa como señal **negativa** de una ilustración extremadamente simple. La aprobación depende también de la lectura de silueta, texturas, continuidad, movimiento, proporciones, anclajes y capturas reales.

## 3. Solución implementada

- Generadas dos hojas RGBA transparentes de cinco estados, usando los fondos y enemigos del propio juego como referencias de estilo:
  - Espera con cuatro patas apoyadas.
  - Desplazamiento con una configuración de patas.
  - Desplazamiento con la configuración complementaria.
  - Reacción al golpe sin símbolos añadidos.
  - Derrota con el cuerpo tumbado, misma identidad y pelaje.
- Integradas como `assets/images/enemies_hifi/rat_sheet.png` y `cat_sheet.png`, sin sustituir ni borrar los originales RC6.
- El renderizador Flutter ya no usa los PNG antiguos para estos dos enemigos; utiliza la hoja actual y recortes explícitos de cada pose.
- La escala se calcula siempre a partir de la pose inicial: rata 36 unidades lógicas, gato 76. Los demás fotogramas conservan el mismo factor de píxel y se anclan al suelo mediante `groundY`.
- Hashes y tamaños en `qa/ENEMIES_HIFI_MANIFEST.json`.

## 4. Nuevo cortafuegos de calidad

`qa/test_hifi_rat_cat.py` verifica:

1. Existencia, contenido y hash SHA-256 de las hojas realmente cargadas.
2. Transparencia y recortes alpha de cada pose, evitando recortes accidentales.
3. Diferencia significativa entre reposo y dos fotogramas de desplazamiento.
4. Detalle de la nueva imagen con prueba negativa que también examina los PNG antiguos y demuestra que no cumplen la nueva exigencia.
5. Escala canónica única, pies anclados y rutas de recursos declaradas en el motor.

`test/qa_creature_render_test.dart` se incorpora al flujo de GitHub para producir **diez capturas del StagePainter real**, uno por estado de rata y gato. El flujo de capturas es obligatorio y ya no se marca `continue-on-error`. Las capturas deberán abrirse y revisarse; un contador de colores no equivale a aprobación artística.

## 5. Comprobaciones aún obligatorias

- Ejecutar `flutter analyze` y el nuevo test de capturas en GitHub/Flutter.
- Verificar que la rata no se ve grande ni borrosa al moverse respecto a las heroínas, que el gato no flota y que el suelo/colisiones visuales coinciden.
- Verificar 30/60 FPS, poses de desplazamiento y daño en el APK Android, en los capítulos donde aparecen.
- Ajustar tamaño o dibujo después de observar el render **real**; la hoja generada por IA no debe presentarse como captura del juego.

## 6. Regla permanente para el futuro GPT

**Un recurso puede existir, tener alfa, dimensiones correctas y compilar, y aun así ser artísticamente inaceptable.**

En adelante todo enemigo nuevo debe tener:

- ficha de identidad, escala y proporciones;
- hoja coherente de estados suficientemente diferentes;
- prueba negativa que detecte una versión demasiado simple o con poses repetidas;
- captura del motor real y vídeo de movimiento;
- comparación con el nivel de acabado visual aprobado y revisión explícita del usuario;
- referencia y hash de los recursos usados realmente por la aplicación.

Este caso es una **lección de proceso**, no una certificación automática de calidad de la versión nueva.
