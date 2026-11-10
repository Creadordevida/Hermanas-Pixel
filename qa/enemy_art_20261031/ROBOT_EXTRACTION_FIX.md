# Corrección de separación del robot, 2026-11-01

La inspección ampliada de la animación real encontró una pequeña porción del robot vecino en el segundo ataque. La hoja aprobada tiene siluetas que se solapan horizontalmente pero no se tocan: un recorte rectangular no sirve. Se separan las cuatro componentes completas de esa fila con alfa>=128, sin dibujar ni modificar colores. Se excluyen trazos decorativos sueltos. La fuente aprobada y su hash permanecen intactos.

Las cuatro siluetas completas miden hasta 314 px de ancho. Factor uniforme nuevo: 136/314=0.4331210191. Altura opaca de reposo derivada: 83 px; motor usa 80/83 para conservar 80 unidades de altura visible. Pies y proporciones se mantienen. Atlas y manifiesto actualizados; el importador reproduce exactamente el PNG y la prueba de hashes detecta sustituciones.

La paleta única de los GIF ahorra aproximadamente 88% del tamaño anterior, pero altera algunos colores. Se conserva como previsualización comprimida y se añade animación WebP SIN PÉRDIDA para revisión artística fiel a los píxeles del motor. Las fuentes PNG nunca se reducen a una paleta GIF.

Última prueba previa: 41317042039 SUCCESS (21 PNG protegidos, análisis Flutter, 20 encuentros reales y 240 muestras de motor). Se repite la verificación después de esta corrección. No APK ni publicación.
