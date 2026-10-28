# Enemigos Estafeta — contrato de producción y aceptación visual

**Estado: mecánicas iniciales implementadas; imágenes finales NO creadas ni verificadas.**

## Toro de encierro — `estafeta_bull`
- Capítulo: Calle Estafeta, exclusivamente (índice 2).
- Referencia: toro bravo realista estilizado como pixel art SNES: musculatura marcada, pecho poderoso, cuello y morrillo, cabeza inclinada, dos pitones curvos creíbles, hocico oscuro, pezuñas separadas y cola con borla. Debe ser inequívocamente un toro y no una vaca, perro o forma rectangular.
- Ataque: observa a la jugadora a menos de 250 px, avisa al menos 0,55 s y embiste; una única colisión por carga, recuperación de 2,2 s. Sin embestida instantánea ni ataques a distancia.
- Poses mínimas: espera con respiración, pateo/alerta, arranque, carrera con ciclo de cuatro patas, frenado, impacto, derrota. Silueta orgánica y centro de gravedad bajo; pezuñas ancladas.
- Referencia de escala: más largo y pesado que cualquier perro; relación de tamaño y colisión consistente respecto a las niñas.
- Sensibilidad: no mostrar gore ni heridas; desmayo/retirada al ser derrotado.

## Corredor sanferminero — `sanfermin_runner`
- Capítulo: Calle Estafeta, exclusivamente.
- Identidad: persona adulta vestida **completamente de blanco**, pañuelo **rojo** al cuello y **faja roja** anudada a la cintura. Zapatillas para correr, rostro y cabello humanos proporcionales, ropa con pliegues y sombreado; no muñeco construido con rectángulos.
- Mecánica: corre y se aparta de la protagonista al acercarse; tropiezo/choque breve que puede restar salud con recuperación. No es un atacante armado ni lanza objetos.
- Poses mínimas: espera, mirada atrás, aceleración, carrera, apartarse/tropezar, impacto, caída/salida. Brazos y piernas se alternan en una zancada auténtica y los accesorios siguen el movimiento.
- **Criterio de diseño:** enemigo jugable por el choque/tropiezo, pero visualmente una persona normal en un encierro, no un villano caricaturesco.

## Pipeline obligatorio antes de activarlos
1. Crear **arte maestro original de alta fidelidad**, comparado con los personajes aprobados (Miren, Sara y enemigos originales) desde el primer diseño. Prohibido sustituirlo por los generadores de rectángulos.
2. Elaborar atlas de poses y fotogramas con transparencia, píxel nativo, suelo y dimensiones estables.
3. Integrar en `StagePainter`, cargar sprites y producir capturas **reales del motor Flutter en el escenario Estafeta**, con Miren y Sara de referencia y poses en movimiento.
4. **Abrir e inspeccionar de verdad** esas capturas; evaluar anatomía, silueta, proporciones, expresividad y estilo, además de continuidad animada.
5. Corregir defectos y repetir las capturas tantas veces como haga falta. Pruebas Dart y comportamiento pasan por CI.
6. Solo cuando exista evidencia documentada de calidad permitir `enemyArtValidated['estafeta_bull']` y `enemyArtValidated['sanfermin_runner']` en `true`. No dar por terminados si no son renderizables de alta calidad.

## Estado real a la fecha
La IA y aparición condicionada se han añadido a `lib/main.dart`, pero **no hay atlas definitivos aprobados, ni render propio, ni captura real**. Sus apariciones están desactivadas por la puerta de calidad. No se debe presentar esto como creación finalizada.
