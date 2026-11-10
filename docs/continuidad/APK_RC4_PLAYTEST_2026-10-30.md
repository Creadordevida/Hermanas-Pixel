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

## Resultado real de la ejecución (verificado en GitHub, 30/10/2026)

**APK COMPILADA Y PUBLICADA COMO PRERELEASE PRIVADA.** No es publicación en Google Play.

- Run 1: 41071461780, FAILED en `flutter analyze` con cinco errores en `lib/adaptive_title_screen.dart`: `math.ceil` inválido y parámetros `_` duplicados en dos errorBuilder. Los seis atlas y las comprobaciones Python ya habían pasado. El almacenamiento de artefactos Actions estaba agotado y el paso de upload-artifact falló; se cambió la entrega a GitHub Releases privado.
- Corrección de Dart: commit `f4becfb50f70a7dd46172560d9626e757d484fa5`.
- Workflow actualizado a entregas por `gh release create --prerelease` sin gastar almacenamiento Actions: commit `4c7405ea35b2d8fc21ac99fff58e3b1734b369b6`.
- **Run 2: 41071927964, COMPLETED / SUCCESS**, fuente exacta `c08ba00283775b99593ff426e8d4bd2130d35307`. Regenerados seis atlas, nueve módulos danza, seis fútbol, controles Python y tests Dart superados; compilación `flutter build apk --release --dart-define=TWC_GAMEPLAY_PLAYTEST=true` SUPERADA.
- Release privado **`playtest-0.9.1-rc4`**, prerelease=true, id 429133632. URL https://github.com/Creadordevida/Hermanas-Pixel/releases/tag/playtest-0.9.1-rc4
- APK VERIFICADA en assets de GitHub Release: `app-release.apk`, asset id 692384866, **142.317.311 bytes**, URL de descarga https://github.com/Creadordevida/Hermanas-Pixel/releases/download/playtest-0.9.1-rc4/app-release.apk
- Assets auxiliares publicados: `PLAYTEST_RC4_APK.sha256` (id 692384868) y `PLAYTEST_RC4_ASSETS.json` (id 692384867).
- El modo de juego de los seis enemigos está activado SOLO en esta APK. Los flags `enemyArtValidated` siguen siendo FALSE y los sprites procedimentales siguen SIN aprobación artística.
- Los 9 PNG danza, 6 fútbol y 6 atlas enemigos fueron regenerados dentro del runner y empaquetados en la APK, **pero no están persistidos como blobs individuales en GitHub**. Esta diferencia se debe conservar como pendiente de integración de recursos definitivos.
- **No se ha probado aún esta APK en un móvil real**. Usuario debe descargar, instalar y comunicar problemas concretos para revisión y corrección.
- **NO se ha fusionado** PR #5, no hay publicación de Google Play.

Lección reusable: para repositorios con cuota de artifacts Actions llena, una **GitHub Release privada PRELIMINAR** permite entregar una APK real sin subirla al historial git ni consumir storage de Actions artifacts. Requiere permiso contents:write en workflow. No dar una URL de descarga hasta comprobar la presencia del release asset y tamaño real en la API de GitHub.

## 2026-10-30 — Nuevo punto de partida REAL tras prueba Android de 0.9.1 RC4
Actualización de evidencia: el usuario ha **instalado y probado** la APK 0.9.1 RC4 (run 41071927964, fuente c08ba002, release playtest-0.9.1-rc4). Indica que hay muchas mejoras pendientes y decepciones, pero **sin detallar aún defectos**. Ordena usar RC4 como base para avanzar, NO como arte aprobado. Se abre lista acumulativa para siguiente versión; no compilar ni modificar jugabilidad hasta recibir las incidencias y criterio de cierre. Informe exacto: `docs/continuidad/BASE_JUGABLE_RC4_Y_REVISION.md`.
