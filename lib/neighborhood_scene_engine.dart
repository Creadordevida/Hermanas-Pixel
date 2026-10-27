/// Escenario continuo del capítulo 1. El motor representa regiones del MUNDO;
/// ninguna transición depende de fundir dos fotografías en la pantalla.
///
/// Los panoramas fotográficos reinterpretados siguen siendo obras originales
/// inmutables. Las regiones puente usan ARTE NUEVO creado para la transición.
class NeighborhoodSceneRegion {
  const NeighborhoodSceneRegion({
    required this.id,
    required this.asset,
    required this.start,
    required this.end,
    this.connector = false,
  });

  final String id;
  final String asset;
  final double start;
  final double end;
  final bool connector;

  double get length => end - start;
  bool intersects(double left, double right) => start < right && end > left;
}

/// Tramos cerrados y contiguos. Los cuatro hitos aparecen exactamente UNA vez
/// en este recorrido; las calles y paseos sirven para conectarlos.
const neighborhoodSceneRegions = <NeighborhoodSceneRegion>[
  NeighborhoodSceneRegion(
    id: 'edificio_curvo', asset: 'residential_curve', start: 0, end: 7200),
  NeighborhoodSceneRegion(
    id: 'enlace_residencial_paseo', asset: 'connector_residential_greenway_v091',
    start: 7200, end: 9200, connector: true),
  NeighborhoodSceneRegion(
    id: 'paseo_verde', asset: 'green_promenade', start: 9200, end: 16200),
  NeighborhoodSceneRegion(
    id: 'enlace_paseo_cubierta', asset: 'connector_neutral_park_v091',
    start: 16200, end: 18400, connector: true),
  NeighborhoodSceneRegion(
    id: 'parque_cubierto', asset: 'white_canopy', start: 18400, end: 25400),
  NeighborhoodSceneRegion(
    id: 'enlace_cubierta_cohete', asset: 'connector_pergola_v091',
    start: 25400, end: 27600, connector: true),
  NeighborhoodSceneRegion(
    id: 'parque_cohete', asset: 'rocket_park', start: 27600, end: 36500),
];

/// Solo las regiones que intersecan la ventana de cámara son dibujadas.
Iterable<NeighborhoodSceneRegion> visibleNeighborhoodRegions(
    double cameraX, double visibleWidth) sync* {
  final right = cameraX + visibleWidth;
  for (final region in neighborhoodSceneRegions) {
    if (region.intersects(cameraX, right)) yield region;
    if (region.start >= right) break;
  }
}

/// Valor estable de avance dentro de un tramo, entre 0 y 1, sin saltos.
double neighborhoodRegionProgress(NeighborhoodSceneRegion region, double x) {
  if (x <= region.start) return 0;
  if (x >= region.end) return 1;
  return (x - region.start) / region.length;
}

/// Invariantes que sirven para validar el mapa antes de compilar Flutter.
bool neighborhoodRegionsAreContinuous(double stageWidth) {
  if (neighborhoodSceneRegions.isEmpty) return false;
  if (neighborhoodSceneRegions.first.start != 0 ||
      neighborhoodSceneRegions.last.end != stageWidth) return false;
  for (var i = 0; i < neighborhoodSceneRegions.length; i++) {
    final region = neighborhoodSceneRegions[i];
    if (region.length <= 0) return false;
    if (i > 0 && neighborhoodSceneRegions[i - 1].end != region.start) {
      return false;
    }
  }
  return true;
}

/// A scene panorama covers its entire authored REGION, not 920 units followed
/// by dozens of repetitions of the same two gardens. It is a DISTANT layer:
/// its source image pans slowly while ground/obstacles move at world speed.
/// No artwork is stretched, mirrored or wrapped. The four landmarks have one
/// region each and consequently remain clearly visible during traversal.
class NeighborhoodBackdropPanel {
  const NeighborhoodBackdropPanel(this.asset, this.start, this.end,
      {this.landmark = false});
  final String asset;
  final double start, end;
  final bool landmark;
  double get width => end - start;
  bool overlaps(double left, double right) => end > left && start < right;
}

/// One *different* scene per region, including three DIFFERENT connectors.
/// Pergola art, formerly wasted on one tiny panel, becomes the third corridor.
List<NeighborhoodBackdropPanel> buildNeighborhoodBackdropPanels() =>
  List<NeighborhoodBackdropPanel>.unmodifiable([
    for (final region in neighborhoodSceneRegions)
      NeighborhoodBackdropPanel(region.asset, region.start, region.end,
        landmark: !region.connector),
  ]);

final List<NeighborhoodBackdropPanel> neighborhoodBackdropPanels =
    buildNeighborhoodBackdropPanels();

bool neighborhoodBackdropPanelsValid() {
  if (neighborhoodBackdropPanels.length != 7 ||
      neighborhoodBackdropPanels.first.start != 0 ||
      neighborhoodBackdropPanels.last.end != 36500) return false;
  for (var i = 0; i < neighborhoodBackdropPanels.length; i++) {
    final p = neighborhoodBackdropPanels[i];
    if (p.width <= 0 ||
        (i > 0 && neighborhoodBackdropPanels[i-1].end != p.start)) {
      return false;
    }
    if (neighborhoodBackdropPanels.where((q) => q.asset == p.asset).length != 1) {
      return false; // no repeated photo, no repeating neutral garden
    }
  }
  return neighborhoodBackdropPanels.where((p) => p.landmark).length == 4;
}

/// The soft seam is a narrow SPATIAL join around a physical boundary, NOT a
/// time-based screen-wide dissolution. Never use a tree to conceal the seam.
const double neighborhoodSeamHalfWidth = 48.0;

/// A panoramic backdrop has different source and destination widths, but its
/// X and Y scales are IDENTICAL. Use the viewport width for a source window;
/// NEVER squeeze a 7,000-unit authored region into an 800px drawing.
double neighborhoodViewSourceWidth(String asset,
    {double visibleWidth = 800.0, double displayHeight = 380.0}) =>
  visibleWidth * neighborhoodSourceHeight(asset) / displayHeight;

double neighborhoodPanFraction(NeighborhoodBackdropPanel panel, double cameraX,
    {double visibleWidth = 800.0}) {
  final usable = (panel.width - visibleWidth);
  if (usable <= 0) return 0;
  return ((cameraX - panel.start) / usable).clamp(0.0, 1.0).toDouble();
}

/// The approved landmarks must be recognisable. Additional tree art cannot
/// cover them, including the moments when a landmark enters/leaves the view.
/// Trees drawn into the ORIGINAL illustrations are not altered by this rule.
const double neighborhoodLandmarkGuard = 330.0;

bool neighborhoodTreeAllowedAt(double worldX) {
  for (final panel in neighborhoodBackdropPanels) {
    if (!panel.landmark) continue;
    if (worldX >= panel.start - neighborhoodLandmarkGuard &&
        worldX <= panel.end + neighborhoodLandmarkGuard) return false;
  }
  return true;
}

/// Stronger guarantee: no overlay from a separate tree atlas is placed over a
/// landmark in the viewport even during the arrival/exit frames.
bool neighborhoodLandmarkInCamera(double cameraX, double visibleWidth) {
  final right = cameraX + visibleWidth;
  return neighborhoodBackdropPanels.any((panel) => panel.landmark &&
    panel.end + neighborhoodLandmarkGuard > cameraX &&
    panel.start - neighborhoodLandmarkGuard < right);
}

/// Artwork already contains its own pavement and retaining wall. The renderer
/// may ONLY sample the scenic area above the first painted sidewalk. Those
/// original pixels stay in the protected artwork file, but may not be shown
/// simultaneously with the actual physical ground tile.
/// Source scanline that is demonstrably ABOVE each illustration's painted
/// pavement. Every panel (including a short panel at a seam) samples at this
/// same vertical scale and horizontally crops, NEVER stretches its artwork.
const neighborhoodSafeSceneHeight = <String, double>{
  'residential_curve': 690.0,
  'green_promenade': 690.0,
  'white_canopy': 690.0,
  'rocket_park': 690.0,
  'connector_residential_greenway_v091': 530.0,
  'connector_neutral_park_v091': 530.0,
  'connector_pergola_v091': 490.0,
};

double neighborhoodSourceHeight(String asset) {
  final value = neighborhoodSafeSceneHeight[asset];
  if (value == null) throw StateError('Unknown neighborhood scene: $asset');
  return value;
}

bool neighborhoodCropFits(String asset, double sourceWidth,
    double visibleWidth, {double displayHeight = 380.0}) {
  final cropWidth = neighborhoodViewSourceWidth(asset,
      visibleWidth: visibleWidth, displayHeight: displayHeight);
  return cropWidth > 0 && cropWidth <= sourceWidth + 0.1;
}
