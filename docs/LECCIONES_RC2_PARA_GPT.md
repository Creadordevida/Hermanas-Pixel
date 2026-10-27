# Lecciones contrastadas RC2 — motor y QA

**OBSERVADO EN RC1 (gameplay Android):** 28 backplates con 7 artes, repeticiones masivas, dobles pavimentos y cortes verticales. La existencia de assets y las pruebas estáticas no certifican continuidad ni belleza.

**IMPLEMENTADO RC2, NO VALIDADO EN ANDROID:** zonas 7/7 sin repetir, mayor tiempo con hitos principales, paisaje de fondo panorámico con cámara a proporción, uniones espaciales 96px, original protegido por hash, vegetación añadida excluida de monumentos.

**RIESGO ABIERTO:** incluso franjas cortas de mezcla espacial pueden crear dobles fachadas. NO elevar esta técnica a «funciona» en el GPT hasta observar gameplay y contar con aprobación explícita; si falla, diseñar un atlas de corredores nuevos con geometría compatible y sin superposiciones.

**REGLA ESTABLE:** guardar cada diagnóstico de un fallo, el cambio mínimo que lo resuelve y la evidencia de mejora real; distinguir tests Python, capturas Flutter, gameplay Android y aprobación artística.

**CI:** análisis Dart/tests antes de construir APK; SDK fijado y una pipeline QA separada. No prometer éxito Flutter sin haberlo ejecutado.
