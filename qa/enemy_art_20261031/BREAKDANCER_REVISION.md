# Bailarín — tres poses intermedias rehechas, 2026-11-01

Inspección de los PNG originales 0..7: 1 y 2 son inclinaciones casi rígidas del reposo y 3 un cuerpo horizontal sin apoyo claro. Se conservan 0 (reposo), 4 (derrota completa) y 5 (impacto). Se redibujan únicamente 1 (crouch), 2 (entrada con palma apoyada) y 3 (freeze con apoyo). Referencias exactas: breakdancer_0.png y breakdancer_5.png. Herramienta imagegen integrada, preservando gorra azul/amarilla, rostro, camiseta blanca con emblema, pantalón morado y zapatillas. Prompt: tres keyframes anatómicos apoyados, mismo diseño/escala, sin giros rígidos ni figuras duplicadas; transparencia real.

Fuente generada: exec-4907846a-359d-49c7-a668-fca1728f07b6.png. Extracción: tres componentes alfa>=128 (>1000 píxeles), orden X; alfa binaria sin pintar RGB; factor común 0.15, vecino próximo. Salidas 76×77, 92×76 y 114×70. Motor conserva escala de píxel de reposo (115px opacos →126 unidades). No aumentar cada postura agachada hasta altura de pie.

Los tres PNG están en assets/images/enemies y sus SHA256 se añaden al manifiesto protegido. Se mantienen lógica, numeración y selección de estados. La siguiente QA comprueba motor real y ambas protagonistas. Esto es corrección técnica/artística candidata, no aprobación final del usuario.

Última QA previa a estos tres PNG: 41316619261 SUCCESS, incluye los veinte casos de combate con evasión y correcciones de toro/rey. Los GIF nuevos usan una paleta compartida para reducir tamaño sin repetir el fondo completo por fotograma; no se modifica ningún sprite de producción para comprimir evidencias.
