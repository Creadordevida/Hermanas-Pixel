# Playtest Android 0.9.1-rc.4+35 — autorización y compilación

Fecha: 2026-10-30. Usuario autorizó expresamente producir APK Android de pruebas con todos los bloques A-G y seis enemigos nuevos activos, sin fusión a main ni publicación. Esta autorización reemplaza para **esta APK de prueba** el veto anterior a compilar; los requisitos de calidad artística de publicación siguen intactos.

## Hechos confirmados

- PR #5, rama work/revision-visual-20261028-continuidad.
- Código: commit b8b3c89315f70365a0cc918d8f8e76af55cd62de. Separa activación de gameplay (`TWC_GAMEPLAY_PLAYTEST=true`) de aprobación artística (`enemyArtValidated` seis false). Portada con fuente original 16:9, versión `0.9.1-rc.4+35`.
- Control real de bytes de PNG, SHA de danza, 27 módulos de colegio, seis módulos fútbol, seis atlas nuevos y 23 poses clásicas: qa/playtest_091_asset_gate.py (commit 8a64415822ee3bc274e027b06f2db00941ccbf77).
- Workflow de prueba separado .github/workflows/playtest-091.yml (commit 3c2e9a25ddc8fa857387a168998308bcde3cd3bd). No toca workflow de aprobación final ni merge.
- Única ejecución iniciada vía marcador .github/trigger-091-playtest.txt en commit **5eb481e67e35434009eb8ed503562d08cecea821**, ejecución GitHub Actions **41071461780**, ver https://github.com/Creadordevida/Hermanas-Pixel/actions/runs/41071461780 .
- La ejecución se inició correctamente, no declarar APK hasta que el run finalice success y exista artefacto real.
- Art provisional de seis enemigos procede de scripts generadores actuales y **no está aprobado para publicación**. En la siguiente iteración mejorar visualmente con feedback del móvil. No cambiar indicadores de aprobación.
- El workflow regenera las imágenes en su runner; **eso no equivale a subir los PNG persistentes a GitHub**. Publica hashes y APK en artefactos de Actions (retención 14 días). Guardar fuentes y promover arte aprobado posteriormente.

## Comprobación de resultado

Consultar el run 41071461780, jobs, registros y artefacto `Miren-y-Sara-0.9.1-RC4-APK-con-6-enemigos`. Si falla, corregir la causa concreta sin cambiar el modo de publicación ni falsear tests. No afirmar pruebas Android en dispositivo hasta que el usuario instale y juegue.

## Distinción de evidencias

1. Código integrado: sí, GitHub.
2. Ejecución iniciada: sí, GitHub.
3. APK terminada: verificar run y artefacto.
4. APK probada por usuario: pendiente.
5. Arte aprobado: pendiente.
6. PR fusionada: no.
