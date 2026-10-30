# Bandeja de importación del colegio — ARTE APROBADO, NO APK

IMPORTANTE: carpeta auxiliar para una ÚNICA subida web de archivo ZIP.
Esta carpeta NO contiene arte provisional. Usa exclusivamente:
`COLEGIO_REFERENCIA_EXACTA_27_PANELES_Y_VENTANAS_MOVILES.zip`
Tamaño esperado: 18.505.839 bytes
SHA256 esperado: `c9579acf7ba154cfaaa31ffd237bacb50d7a723000bbea278f0123008e2dee78`.

## Única acción manual necesaria, si no hay transferencia binaria directa
1. Descargar el ZIP exacto de la conversación (NO descomprimir).
2. En GitHub, elegir rama **work/revision-visual-20261028-continuidad**.
3. Abrir carpeta `qa/school_inbox`, seleccionar **Add file > Upload files**.
4. Arrastrar **EL ZIP** a esta carpeta, confirmar **Commit directly to branch**.
5. El workflow `.github/workflows/school-hifi-only.yml` se activará
   automáticamente. **No compila APK**: verifica el paquete por SHA,
   incorpora 27 PNG exactos, master y suelo, prueba Flutter REAL, guarda
   siete capturas y hace un commit de los recursos a esta misma rama.

Si falla cualquier comprobación, no integra recursos incompletos ni afirma
que el arte está terminado. Conservar el ZIP en la rama como evidencia.
La PR #5 NO se fusiona y los assets históricos no se eliminan.

NO añadir aquí los PNG por separado. La única subida debe ser el ZIP,
para evitar errores de nombres, rutas o hashes.
