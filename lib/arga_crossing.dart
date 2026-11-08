/// Diseño determinista de los apoyos del río Arga.
///
/// Un tramo seguro de inicio permite aprender los saltos. Los huecos son
/// discontinuidades reales del suelo, nunca texturas que simulan peligro.
library arga_crossing;

enum ArgaSurface { bank, rock, log, plank }

class ArgaFooting {
  const ArgaFooting(this.left, this.width, this.surface);
  final double left;
  final double width;
  final ArgaSurface surface;
  double get right => left + width;
  bool contains(double x, {double tolerance = 0}) =>
      x >= left - tolerance && x <= right + tolerance;
}

class ArgaCrossing {
  const ArgaCrossing._();
  static const double waterLine = 405;
  static const double landingY = 390;
  static const double startBankEnd = 660;

  /// Todos los saltos iniciales tienen huecos de 55–92 unidades, dentro de
  /// la capacidad de salto existente (169 px/s y gravedad 960 px/s²).
  static List<ArgaFooting> firstSection() => const [
    ArgaFooting(0, 660, ArgaSurface.bank),
    ArgaFooting(730, 150, ArgaSurface.rock),
    ArgaFooting(948, 205, ArgaSurface.log),
    ArgaFooting(1223, 132, ArgaSurface.rock),
    ArgaFooting(1434, 210, ArgaSurface.plank),
    ArgaFooting(1712, 150, ArgaSurface.rock),
    ArgaFooting(1937, 240, ArgaSurface.log),
    ArgaFooting(2255, 320, ArgaSurface.bank),
  ];

  static bool supported(double footX, List<ArgaFooting> footings) =>
      footings.any((f) => f.contains(footX));

  /// La caída se confirma cuando los pies alcanzan el agua sin apoyo.
  /// Debe invocarse solo durante caída (velocidad vertical positiva).
  static bool fellInWater({
    required double footX,
    required double footY,
    required double verticalVelocity,
    required List<ArgaFooting> footings,
  }) => verticalVelocity >= 0 &&
      footY >= waterLine &&
      !supported(footX, footings);
}
