# Ayuntamiento RC7: handoff folder, identical to the successful Colegio/Estafeta process

Subir **sin descomprimir** el archivo `AYUNTAMIENTO_RC7_SUBIR_GITHUB_2.zip`
a esta carpeta **en la rama `work/revision-visual-20261028-continuidad`**.

El flujo `.github/workflows/ayuntamiento-rc7-only.yml` verifica el SHA256 exacto,
importa 39 paneles + un único maestro consistorial, declara los recursos,
ejecuta Flutter (18 vistas, 38 uniones, geometría, movimiento y regresiones)
y guarda capturas reales en la rama si TODO pasa.

**Arte candidato.** No se activa en la compilación normal hasta revisar las
capturas y aprobar la continuidad. No compila APK ni fusiona PR.
