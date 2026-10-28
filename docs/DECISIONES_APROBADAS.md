# Decisiones protegidas — Hermanas Pixel
**28/10/2026**
- **Sí aprobado:** método de movimiento y paisaje modular ordinario RC3 FIX2 del capítulo 1, documentado en `TWC_PARALLAX_2D_METODO_APROBADO_RC3_FIX2.md`. El fondo es detallado y dinámico.
- **No equivale a:** aprobación de los grandes hitos superpuestos, portada ni todos los capítulos.
- **Conservar:** escenas originales y sprites; estilo pixel-art de calidad; parallax 0.30/0.56/1.00; mundo cercano en `worldX-cameraX`; interiores con paredes/objetos al 100% y fondo visible solo tras ventanas.
- **No hacer:** bandas rectangulares semitransparentes, edificios fantasma, deformación/estiramiento de panorámicas, uniones cortadas a 90°, repetir carteles o lugares emblemáticos como mosaico.
- **Danza:** buena base artística, ampliar variedad sin perder las salas y el estilo original.
- **Fútbol:** conservar calidad del campo; corregir costura de profundidad con redes, vallas, setos y siluetas irregulares propias de un complejo deportivo sin invadir la superficie jugable.
- **Colegio:** reconstruir con piezas arquitectónicas realmente conectadas; no basta con variar colores de paneles de pasillo.
- **Pantalla inicial:** mantener personajes, título y botones que están bien; eliminar bandas laterales y caja del logo y hacer sello legible.
- **Entrega:** prueba Python no sustituye `flutter analyze`, `flutter test`, compilación, inspección de movimiento y revisión por el usuario en móvil.


## Norma obligatoria de aceptación de CADA enemigo nuevo — aprobada por el usuario (28/10/2026)

**No se admite ningún enemigo nuevo en una versión jugable solo porque compile, se genere su PNG o supere pruebas de lógica.**
1. **Revisión visual del archivo real:** obtener el atlas PNG efectivamente generado/compilado, abrirlo y examinar todas las poses y fotogramas; no sustituir por imágenes inventadas, bocetos ideales, referencias ni descripciones de lo que debería ser.
2. **Comparación con los gráficos originales:** verificar detalle pixel art SNES, anatomía o silueta, volumen, paleta y sombreado, escala frente a Miren y Sara, uniformidad de calidad y ausencia de figuras geométricas provisionales. Si no está a la altura, **RECHAZADO**.
3. **Movimiento real y coherencia:** verificar transiciones entre espera, marcha, alerta, ataque, impacto y derrota; pivote de suelo estable, tamaño constante, ausencia de saltos y deformaciones; comprobar secuencia en contexto de escenario.
4. **Pruebas técnicas por enemigo:** atlas y transparencia correctos, carga de recursos, hitboxes y daños, ataques con anticipación, esquiva, recuperación, interacción Miren/Sara, aparición solo donde corresponde, tests y análisis Flutter. Resultado probado, no solo código escrito.
5. **Puerta de publicación:** documentar por separado `calidad_visual`, `animacion`, `jugabilidad`, `pruebas` y `aprobacion`. La ausencia de revisión real o cualquier fallo bloquea la inclusión del enemigo en un APK de entrega. No etiquetar «terminado», «aprobado» o «validado» sin evidencia.
6. **Estado presente:** robot, aficionado rival, turista y rey de Navarra: **RECHAZADOS ARTÍSTICAMENTE** los atlas procedimentales actuales. Sus reglas/mecánicas pueden conservarse aisladas, pero se tienen que rehacer los sprites antes de activarlos para publicación. No presentar la mera creación de un archivo como cumplimiento de este requisito.


## Corrección de criterio — iteración obligatoria, nunca abandono (28/10/2026)
El usuario aclara: **si un enemigo no supera la revisión de calidad, el asistente debe mejorar sus gráficos/animaciones y volver a probar, tantas iteraciones como sean necesarias; NO rechazar ni descartar el concepto de enemigo.** Robot de limpieza, aficionado rival, turista y rey de Navarra continúan aprobados como **personajes que deben incluirse** en la siguiente versión una vez estén bien terminados. El único elemento rechazado es cada **diseño gráfico insuficiente**, no el enemigo.

Ciclo de trabajo obligatorio por personaje: generar/editar arte de calidad comparable al material aprobado → integrar en motor → capturar **imagen real producida por el juego** en su escenario y a escala real → inspeccionar personalmente arte y movimiento real → registrar defectos y corregir → repetir hasta calidad satisfactoria → ejecutar pruebas técnicas → habilitar para versión de pruebas. No sustituir captura real por montaje o archivo PNG aislado. El bloqueo temporal de diseños inaceptables es una barrera de seguridad, **no una solución final ni permiso para omitir enemigos**. No dar versión por cerrada si siguen pendientes los cuatro enemigos pactados.
