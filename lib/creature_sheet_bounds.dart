import 'dart:ui';

/// Rectángulos medidos sobre los PNG RGBA REALES de los nuevos enemigos.
/// Cada recorte omite el margen transparente del atlas, pero conserva la
/// anatomía completa y el tamaño de píxel entre poses.
///
/// Se midieron usando alfa >= 128: los PNG generados tienen algunos píxeles
/// casi transparentes fuera del personaje y NO deben contar como cuerpo.
/// Los originales RC6 permanecen intactos como referencia histórica.
const Map<String, Rect> creatureFrameBounds = <String, Rect>{
  'rat_0': Rect.fromLTWH(21, 369, 395, 173),
  'rat_1': Rect.fromLTWH(462, 383, 410, 159),
  'rat_2': Rect.fromLTWH(884, 383, 453, 159),
  'rat_3': Rect.fromLTWH(1378, 298, 313, 244),
  'rat_4': Rect.fromLTWH(1749, 438, 403, 125),
  'cat_0': Rect.fromLTWH(36, 254, 341, 304),
  'cat_1': Rect.fromLTWH(419, 263, 388, 295),
  'cat_2': Rect.fromLTWH(838, 281, 396, 277),
  'cat_3': Rect.fromLTWH(1272, 308, 346, 251),
  'cat_4': Rect.fromLTWH(1627, 428, 434, 138),
};

const Map<String, double> creatureIdleHeights = <String, double>{
  'rat': 36,
  'cat': 76,
};
