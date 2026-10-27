# Hermanas Pixel 0.9.1 RC2 — CHECKPOINT DE MITAD (27/10/2026)

**NO INSTALAR NI SUBIR ESTE PAQUETE COMO NUEVA VERSIÓN.** Trabajo parcial. Versión base reproducible: `Miren_y_Sara_0.9.1_RC1_GITHUB_COMPLETO.zip`.

## Realizado (motor, seguridad visual, diagnóstico)

1. Copia de trabajo RC1 completa separada. Los 4 PNG originales del barrio conservan exactamente sus SHA-256 aprobados; no se reemplazan.
2. Localizada la causa cuantificable del **doble suelo**: `_neighborhoodBackdropPanel()` desplazaba el recorte hacia abajo hasta casi 200 px de la imagen fuente, mostrando acera y muro dibujados mientras Flutter añadía suelo físico. Eliminado el desplazamiento `sourceTop>0`; ahora el dibujo del panorama se recorta desde arriba, antes de entrar en la acera, y el juego dibuja **solo su suelo físico** en y=380.
3. Corregida la escala de los recortes: `sourceHeight` fijo por recurso, `sourceWidth = panel.width * sourceHeight / 380` con recorte horizontal centrado. Así los paneles acortados en una frontera no aplastan vertical ni horizontalmente el edificio.
4. Ajustadas longitudes de los paneles singulares y de la pérgola para cumplir las dimensiones reales de los recortes sin estirar arte.
5. **Los cuatro monumentos quedan visualmente protegidos**: el código de dibujo ya no coloca árboles de primer plano sobre la calle ni árboles de cierre sobre las fachadas. La decoración adicional queda pequeña y limitada a corredores y respeta un margen alrededor de los monumentos. Los árboles que están pintados en la imagen original permanecen.
6. Auditoría cuantitativa nueva `qa/audit_rc2_scene_composition.py`: enumera todos los paneles, cuenta repeticiones y mide diferencias RGB en sus bordes. Genera `qa/RC2_SCENE_AUDIT_MID.json`.
7. Pruebas nuevas `qa/test_092_composition_gate.py` y `test/neighborhood_visual_contract_test.dart` (esta última pendiente de ejecutar Flutter). Actualizadas las pruebas heredadas para que protejan el modelo corregido, sin aceptar nuevamente el viejo recorte.
8. Revisiones Python: 118 tests aprobados (antes 114), 137/137 recursos declarados válidos, protección de recursos esenciales, control mecánico de capas; SIN ejecución Flutter ni Android.

## Descubrimiento crítico durante auditoría: no está resuelto aún

- El capítulo actual tiene **28 paneles pero solo 7 imágenes base**. Dos imágenes de jardín aparecen 11 y 12 veces respectivamente. La repetición denunciada por el usuario es objetiva.
- Las uniones siguen cortando paisaje. El error absoluto medio RGB de algunas fronteras supera 100/255. Una continuidad matemática de coordenadas no arregla estas discontinuidades artísticas.
- La RC2 seguirá **bloqueada visualmente** hasta rediseñar distribución y zonas de enlace, medir el resultado y verificarla en capturas Flutter reales + vídeo móvil.

## Segunda mitad planificada

1. Reautoría del plano general para otorgar protagonismo a edificio, paseo, cubierta y cohete sin repetir monumentos.
2. Sustituir cadenas alternas de conectores por transiciones compatibles, NO fundidos de ilustraciones enteras ni árboles que tapen defectos.
3. Mantener el único suelo y comprobar continuidad en todas las vistas reales del motor.
4. Auditar obstáculos, monedas, fauna, saltos y sombras sin alterar mecánicas ni arte aprobado salvo fallos concretos.
5. Portada y márgenes: verificar sin duplicaciones; corregir si persiste.
6. Compilación: comprobación `flutter analyze lib test`, tests Flutter, `flutter build apk --release` en GitHub, QA separada; conservar bloqueos por fallos y aportar pruebas reales.
7. Publicar **un único ZIP completo final** cuando haya controles suficientes, nunca este archivo parcial.

## Importante sobre la vista previa

`RC2_MITAD_PREVIA_SIMULADA.jpg` es un DIAGNÓSTICO COMPOSICIONAL HECHO CON PIL, **no una captura Flutter ni una prueba de Android**. Sirve para comparar cómo quedan los cuatro monumentos sin árboles añadidos, con el suelo fuente recortado y un pavimento físico.

## Cómo reanudar si se corta la conversación

Descomprimir `Miren_Sara_091_RC2_MITAD_CHECKPOINT_NO_INSTALAR.zip` y leer este documento y `qa/RC2_SCENE_AUDIT_MID.json`. No mezclar el proyecto del checkpoint con el RC1 a mano: el checkpoint es una copia completa y aislada. Conservar también RC1 como base aprobada para regresiones.
