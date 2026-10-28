/// Sistema de cámara y composición de escenario en coordenadas de MUNDO.
/// No depende de Flutter; sus números son los mismos en tests y render.
/// Arte de hitos: nunca estirado, repetido ni extendido para cubrir kilómetros.
class WorldArtPlacement {
  const WorldArtPlacement({
    required this.asset,
    required this.worldX,
    required this.worldY,
    required this.width,
    required this.height,
    required this.scaleFactor,
  });
  final String asset;
  final double worldX, worldY, width, height, scaleFactor;
  double get right => worldX + width;
  bool intersects(double cameraX, double viewportWidth) =>
      right > cameraX && worldX < cameraX + viewportWidth;
  double screenX(double cameraX) => worldX - cameraX * scaleFactor;
}

/// Pantallas independientes de la cámara: objetos del mundo = factor 1.0.
/// Capas realmente lejanas pueden tener factores menores, pero jamás se
/// añade un factor a un edificio cercano solo para ocultar falta de arte.
double worldObjectScreenX(double worldX, double cameraX) => worldX - cameraX;
double worldObjectScreenY(double worldY, double cameraY) => worldY - cameraY;

class ChapterOneCameraV3 {
  const ChapterOneCameraV3({
    this.viewportWidth = 800,
    this.stageWidth = 36500,
    this.followOffset = 327,
  });
  final double viewportWidth, stageWidth, followOffset;
  double follow(double heroWorldX) =>
      (heroWorldX - followOffset).clamp(0.0, stageWidth - viewportWidth).toDouble();
  double worldToScreen(double objectWorldX, double cameraX) =>
      worldObjectScreenX(objectWorldX, cameraX);
}

/// El tamaño de una ilustración se deduce de píxeles fuente, no del largo
/// artificial de la zona. Sus dimensiones mantienen la relación de aspecto.
double naturalWorldArtWidth(int sourceWidth, double sourceHeight,
    {double drawnHeight = 380}) => sourceWidth * drawnHeight / sourceHeight;

/// Primer experimento: el edificio original aparece solo una vez en el mundo.
/// El escenario restante DEBE construirse mediante piezas; nunca simularlo
/// con una fotografía casi inmóvil. Los demás hitos no están aún aprobados.
final WorldArtPlacement curvedBuildingPilot = WorldArtPlacement(
  asset: 'residential_curve',
  worldX: 0,
  worldY: 0,
  width: naturalWorldArtWidth(1672, 690),
  height: 380,
  scaleFactor: 1,
);

/// La cobertura ausente de arte se declara explícitamente como deuda técnica.
/// No habilitar este prototipo como capítulo de producción sin resolverla.
double missingWorldArtInCamera(double cameraX, double viewportWidth,
    Iterable<WorldArtPlacement> opaquePieces) {
  final start = cameraX;
  final end = cameraX + viewportWidth;
  final spans = <(double,double)>[
    for (final p in opaquePieces)
      if (p.right > start && p.worldX < end)
        (p.worldX < start ? start : p.worldX,
         p.right > end ? end : p.right),
  ]..sort((a, b) => a.$1.compareTo(b.$1));
  var cursor = start;
  var totalMissing = 0.0;
  for (final span in spans) {
    if (span.$1 > cursor) totalMissing += span.$1 - cursor;
    if (span.$2 > cursor) cursor = span.$2;
  }
  if (cursor < end) totalMissing += end - cursor;
  return totalMissing;
}
