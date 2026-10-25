# Auditoría técnica — candidata 0.9.0-rc.2

## Base y referencias
- Base aprobada 0.8.0: control de hashes SHA-256 OK.
- Imágenes originales: control de integridad OK, sin modificarlas.
- 117 referencias de PNG desde el motor: **117/117 presentes**.
- QA Python: **31/31 pruebas superadas**.
- Tratamiento artístico de los vestuarios: adaptado sobre 4 poses por cada hermana, caras pixel-a-pixel sin modificar, misma máscara alfa.
- Colegio: tres fondos pintados en assets/images/scenes/school*.png; suelo común desde y=395; texturas no planas y aulas diferenciadas.

## Puertas sin superar todavía — candidatas, NO aprobación
- NO hay ejecución local de Flutter/Android ni capturas reales del APK probadas en esta sesión.
- No se ha medido en móvil la duración objetivo de cinco minutos por capítulo.
- Falta aprobación visual final del vestuario, calidad de enemigos, mapa y fondos vistos dentro del APK, en particular el equilibrio entre gráficos nuevos y los de 0.8.0.
- Las pruebas unitarias no sustituyen revisión humana de arte/animación.
- Al fallar un paso de GitHub Actions, corregir la causa concreta; no eliminar los controles de seguridad para conseguir un verde.

## Protocolo de instalación y verificación
Leer `README_GITHUB_Y_PRUEBAS.md`. El workflow adjunta automáticamente APK y trata de exportar las capturas del renderizador Flutter. Confirmar resultados de la compilación y jugar los siete capítulos en el teléfono antes de aprobar.
