# TWC — Transferencia binaria de recursos artísticos a GitHub

## Hallazgo verificado el 30/10/2026
El conector de GitHub SÍ acepta PNG de gran tamaño usando **`create_blob` con `encoding='base64'`**. La limitación anterior era el tránsito de bytes desde el contenedor local a la llamada del conector, NO los permisos ni GitHub.

Prueba **real realizada**, sin Actions ni APK:
- Archivo PNG de panel de danza 377.797 bytes, Base64 503.732 caracteres.
- Su Base64 se preparó como archivo de texto en líneas de 4.096 caracteres y quedó accesible mediante Files en la conversación.
- Se leyó desde Files por páginas de 20 líneas, concatenando en memoria JS las cadenas sin saltos de línea.
- Se llamó `mcp__GitHub__create_blob({repository_full_name:'Creadordevida/Hermanas-Pixel', content:b64, encoding:'base64'})`.
- Se recibió SHA Git `16671f5d374652cbd48c18dd2b385b587bc1ee40`, **idéntico** al hash calculado sobre los bytes originales mediante `sha1(b'blob '+str(len(data)).encode()+b'\\0'+data)`. No se anexó ese blob aislado a la rama.

## Procedimiento reproducible para una subida de verdad
1. Generar el PNG definitivo en local, abrirlo e inspeccionarlo, y calcular Git blob SHA1 y SHA256.
2. Codificar Base64 exacto con líneas pequeñas, preservar el archivo de transferencia para lectura por Files, y obtener su referencia de archivo real. No copiar millones de caracteres en el chat.
3. Leer el archivo completo por segmentos con Files y concatenar en memoria `content` sin espacios ni saltos.
4. `create_blob` con `encoding:'base64'`, comprobar que la SHA Git devuelta coincide con el cálculo del PNG **byte por byte**.
5. Preparar un árbol Git `create_tree` con elementos `{path:'ruta.png',mode:'100644',type:'blob',sha:'SHA'}` sobre el árbol de HEAD. Para grupos de archivos, preparar todos los blobs ANTES de crear el árbol; no subir solo un panel de nueve.
6. Crear commit sobre HEAD anterior y mover la rama con `update_ref` y `expected_sha` (protección ante carreras). Verificar que la rama contiene los blobs esperados, que los archivos son visibles y que no se han disparado Actions.
7. Distinguir **objeto blob creado** de **asset versionado en árbol** y de **arte aprobado por usuario**. Son tres hitos diferentes.

## Prohibiciones
- No usar esta técnica para convertir arte rechazado en final: sólo transporta bytes.
- No almacenar tokens de acceso ni URL temporales con parámetros de autenticación en Git.
- No lanzar GitHub Actions ni compilar APK sin permiso.
- No afirmar que un recurso está en la rama si únicamente hay un blob huérfano o un artefacto temporal de workflow.

**Aplicación pendiente:** 9 paneles de danza y 6 de fútbol ya generados localmente, pero aún no versionados; y los 6 atlas de nuevos enemigos cuando superen el contrato artístico.
