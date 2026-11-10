# Nuevos enemigos — contrato de arte y jugabilidad (28/10/2026)

## Aprobación del usuario
**Tres enemigos nuevos:**
1. **Robot de limpieza** — colegio. Máquina baja con ruedas, cepillos y sensores, distintiva de las ratas, perros y personas.
2. **Aficionado del equipo rival** — fútbol. Persona con **camiseta y bufanda** de equipo rival ficticio; paleta diferenciada de la del equipo de Miren. Sin marcas ni escudos reales.
3. **Turista borracho** — barrio. Persona caricaturesca con **gorra, cámara colgada del cuello y botella en la mano**. Camina de manera irregular; no usar bebidas de marcas reales.

No introducir por ahora avispa, cuervo u otros no aprobados explícitamente.

## Hoja de sprites requerida antes de mostrar enemigos en juego
- Pixel art de alta calidad 16-bit SNES, figuras coherentes con protagonistas y decorados actuales.
- Mismo pivote de pies/ruedas en todos los fotogramas; no normalizar el tamaño de cada pose individualmente.
- Estados: **idle**, **patrol**, **alert** (anticipación), **attack**, **hit**, **defeated**.
- 4 fotogramas de marcha, 2 de espera, 2 de alerta, 3 de ataque, 2 de impacto, 3 de retirada/derrota como mínimo; misma iluminación, proporciones y colores.
- Robot: antena/sensores animados, cepillo visible, ruedas girando.
- Aficionado: bufanda legible en reposo y en gesto de provocación; camiseta contrastada; no ataque violento contra niñas: amenaza caricaturesca o interferencia con balón.
- Turista: gorra, cámara y botella siempre reconocibles, deambular oscilante y postura de equilibrio precario; comportamiento cómico.
- Guardar **fuente de generación/edición** y manifest de atlas con tamaños, transparencias y cajas de colisión por fotograma. No declarar sprites completados sin inspección de PNG reales.

## Mecánicas ya preparadas
Archivo `lib/new_enemy_behaviors.dart`: patrulla limitada, detección específica, anticipación visible, impacto una sola vez si jugador permanece cerca, cooldown, interrupción por golpe y derrota.
Archivo `test/new_enemy_behaviors_test.dart`: pruebas escritas para patrulla, anticipación, esquiva, interrupción y derrota. Pendientes de ejecución en Flutter/CI.

## Integración pendiente
1. Crear y revisar los atlas reales.
2. Cargar atlas sin alterar sprites existentes. Anclar los pies a `groundY`.
3. Incorporar reparto por capítulos (colegio/fútbol/barrio) y evitar apariciones en otras zonas.
4. Conectar al sistema de tiros de balón de Miren y piruetas de Sara, con daño/colisión visible y cooldown.
5. Asegurar que no atacan durante pantalla de pausa, no golpean sin animación y no alteran guardados.
6. Capturas reales de poses y secuencia completa, tests, y **APK solo al final** junto con el resto de mejoras visuales.

### Regla de continuidad
Los prototipos mecánicos **no son enemigos jugables todavía**. Mantenerlos aislados hasta completar sprites e integración; no presentar nombres registrados ni apariencia aprobada cuando solo exista código.
