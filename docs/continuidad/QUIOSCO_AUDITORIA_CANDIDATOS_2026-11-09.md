# Quiosco — auditoría de las ilustraciones candidatas (09/11/2026)

**NO INTEGRADO / NO FLUTTER / NO ARTE APROBADO.** Diagnóstico visual de los PNG generados en la conversación, no de los recursos de la APK.

## Resultado comprobado sobre 13 PNG recuperados

- Los trece tienen tamaño original **2172 × 724 píxeles**.
- **Siete no contienen el quiosco** y son candidatos a fachadas/recorrido.
- **Seis sí muestran el quiosco completo o parcialmente**: **NO se pueden concatenar** o se duplicaría el monumento.
- El quiosco seleccionado como referente artístico de prueba es `quiosco_de_flores_en_plaza_del_castillo.png`, **sin aprobación definitiva y sin sustituir `quiosco_unico.webp`**.
- Para una comparación de trabajo se montó localmente una franja de ocho paneles de 960 × 390 (siete vistas sin quiosco y una con él). Conversión usada **2172 × 724 → 1170 × 390 con escala proporcional → recorte centrado a 960 × 390**. No se afirma que esas ocho vistas encajen arquitectónicamente entre sí.
- La composición evidenció **cambios de edificios, tejados y perspectiva en las uniones**; no cumple todavía el criterio aprobado de fondo horizontal continuo. Queda aislada y **no se sube como fondo del juego**.
- 8 paneles = **7.680 px**, apenas el 20,5 % de 37.440 px. Los trece diseños juntos no resolverían la falta de contenido original por la prohibición de duplicar el quiosco y la incompatibilidad de uniones.

## Selección para desarrollo, NO para importación

| Función | Archivo PNG en conversación | Quiosco visible |
| --- | --- | --- |
| Entrada | `entrada_a_la_plaza_del_castillo_en_pixel_art.png` | No |
| Fachadas | `fachadas_navarras_en_la_plaza_del_castillo.png` | No |
| Fachadas | `plaza_histórica_bajo_un_cielo_azul.png` | No |
| Fachadas | `plaza_del_castillo_en_16_bits.png` | No |
| Fachadas | `a_detailed_pixel_art_scene_a_wide_continuous_sid.png` | No |
| Espacio abierto | `a_wide_pixel_art_city_plaza_scene_snes_like_pixel.png` | No |
| Salida | `plaza_del_castillo_en_píxel_art.png` | No |
| Hito único (solo candidato) | `quiosco_de_flores_en_plaza_del_castillo.png` | Sí |
| Alternativas descartadas para recorrido horizontal | `a_wide_detailed_pixel_art_16_bit_style_scene_of_p.png`, `a_wide_detailed_pixel_art_scene_of_plaza_del_cast.png`, `a_wide_pixel_art_scene_of_a_spanish_plaza_plaza_d.png`, `a_wide_detailed_pixel_art_scene_snes_style_of_p.png`, `plaza_del_castillo_en_píxeles.png` | Sí |

## Siguiente intervención de arte necesaria

1. Diseñar **edificios completos con lados compatibles**, evitando cambiar de cornisa, distancia, cielo o pavimento en puntos arbitrarios.
2. Crear suficientes panorámicas **distintas** para cubrir los 37.440 píxeles **sin estirar ni repetir**: la base de siete fondos más el quiosco no es suficiente.
3. Separar fondo realmente lejano (0,30), intermedio distante (0,56) y arquitectura/quiosco/suelo físico (1:1). No mover el quiosco con el paralaje.
4. Tras revisar uniones internas y entre paneles, generar candidato completo, integrarlo en `StagePainter`, inspeccionar barrido, corregir y validar. Mantener los originales en producción hasta entonces.

**La prueba visual compuesta solo es un control de candidatos. No es un fotograma del juego.** No modificar `lib/main.dart` ni declarar superado Flutter por preparar imágenes. No APK, no fusión PR.
