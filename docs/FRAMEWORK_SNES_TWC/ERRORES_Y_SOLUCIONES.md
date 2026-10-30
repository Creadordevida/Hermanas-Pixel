# Errores aprendidos durante el desarrollo — no repetir

| Defecto detectado | Causa real | Principio generalizable |
|---|---|---|
| Misma clase repetida 3 veces | El ancho de recorte era igual al ancho original; desplazamiento siempre 0 | Test visual + variedad por composición, no por nombre |
| Pupitres pegados con baldosas | Máscaras alfa insuficientes en recortes de PNG | Recortar silueta auténtica; inspeccionar sobre damero |
| Biblioteca y pizarra duplicadas | Arte incrustado en fondo y superposición extra | Inventario de qué pertenece a cada capa |
| Colegio de menor riqueza que cap. 1 | Arquitectura clonada y variaciones insuficientes | Comparar *capturas del mismo motor* a escala de juego |
| Ventanas con pared fantasma | Transparencia aplicada a colores fuera del cristal | Mascarar sólo cristales; A/B con exterior móvil |
| Pilares de doble grosor | Dos paneles dibujaban un borde de 22px cada uno | Dividir arquitectura compartida o diseñar un borde único |
| Logotipo encerrado en banda oscura | PNG fuente con fondo y overlay adicional | Obtener marca auténtica, alpha real; no ocultar con parches |
| Portada con franjas laterales | Lienzo 800×450 y `FittedBox.contain` en 20:9 | Diseño responsive separado del gameplay, coordenadas comunes |
| Sprite de derrota todavía erguido | Reutilización de pose vertical sin redibujar caída | Animación y silueta de derrota independiente |
| Carreras aunque enemigo quieto | Avance de fotogramas basado sólo en reloj | Elegir animación por estado real y movimiento |
| Embestida inmediata | Temporizador de aviso mezclado con reloj general | Estado y cronómetro propios; ataque interrumpible |
| PR verde pero enemigo horrible | Tests automáticos verificaban bytes/dimensiones, no arte | Verificación humana y capturas auténticas obligatorias |
| Actions sin espacio | APK y capturas publicados repetidamente | Workflows manuales y una única ronda final |
| Preview distinto del juego | Capas duplicadas en render Python y no en Flutter | Una fuente de verdad para datos y orden de capas |
| YAML parecía ejecutar dos líneas | `run:` sin bloque literal `|` plegaba las líneas | Validar flujo manual y usar bloque de shell explícito |

| Danza con arcos achatados | Recorte 1672×545 reescalado a 1650×286: relación X/Y 1,88× | Usar recortes 1200×390 a 880×286 con factor uniforme; comparar el PNG real y después StagePainter |
| Previsualizador Python no arrancaba | Bucle final de capturas desplazado un nivel de indentación | Comprobar sintaxis y ejecutar el script, no asumir que existe = funciona |

Estos son defectos observados en **Miren y Sara**, no una afirmación de que hayan sido resueltos de forma universal. Reutilizar la solución exige comprobarla en cada nuevo proyecto.
| Cercado deportivo repetitivo | Los tres recortes próximos venían únicamente de football_stands y la supuesta rotación era xx=0 | Mezclar detalles genuinos de entrada/gradas/entrenamiento y comprobar anillo completo y paneles |
| QA visual obsoleta | El test seguía buscando Widget _title() => Stack y recorte de danza start=(0,385,770) | Sincronizar pruebas de contrato con arquitectura realmente activa, ejecutar antes de compilación |
