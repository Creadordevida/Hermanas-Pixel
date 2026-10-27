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
    id: 'enlace_cubierta_cohete', asset: 'connector_neutral_park_v091',
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

/// A backdrop panel belongs to one physical interval of the level.
/// Its screen x-position follows the camera at factor 1.0, unlike the RC8
/// panoramas which barely moved while the player walked thousands of units.
class NeighborhoodBackdropPanel {
  const NeighborhoodBackdropPanel(this.asset, this.start, this.end,
      {this.landmark = false});
  final String asset;
  final double start, end;
  final bool landmark;
  double get width => end - start;
  bool overlaps(double left, double right) => end > left && start < right;
}

/// Unique original illustrated landmarks each appear ONCE in the physical
/// world. Only generic landscaping is used to build the long links. Panel
/// order is deterministic and must not move when a test/frame changes.
List<NeighborhoodBackdropPanel> buildNeighborhoodBackdropPanels() {
  const unique = <NeighborhoodBackdropPanel>[
    NeighborhoodBackdropPanel('residential_curve', 0, 980, landmark: true),
    NeighborhoodBackdropPanel('connector_pergola_v091', 5150, 6650),
    NeighborhoodBackdropPanel('green_promenade', 9500, 10480, landmark: true),
    NeighborhoodBackdropPanel('white_canopy', 18800, 19780, landmark: true),
    NeighborhoodBackdropPanel('rocket_park', 28700, 29680, landmark: true),
  ];
  final result = <NeighborhoodBackdropPanel>[];
  var cursor = 0.0;
  var variant = 0;
  for (final landmark in unique) {
    while (cursor < landmark.start) {
      final next = (cursor + 1450.0).clamp(cursor, landmark.start).toDouble();
      result.add(NeighborhoodBackdropPanel(
          variant.isEven ? 'connector_residential_greenway_v091'
                         : 'connector_neutral_park_v091', cursor, next));
      cursor = next;
      variant++;
    }
    result.add(landmark);
    cursor = landmark.end;
  }
  while (cursor < 36500) {
    final next = (cursor + 1450.0).clamp(cursor, 36500.0).toDouble();
    result.add(NeighborhoodBackdropPanel(
        variant.isEven ? 'connector_neutral_park_v091'
                       : 'connector_residential_greenway_v091', cursor, next));
    cursor = next;
    variant++;
  }
  return List.unmodifiable(result);
}

final List<NeighborhoodBackdropPanel> neighborhoodBackdropPanels =
    buildNeighborhoodBackdropPanels();

bool neighborhoodBackdropPanelsValid() {
  if (neighborhoodBackdropPanels.isEmpty ||
      neighborhoodBackdropPanels.first.start != 0 ||
      neighborhoodBackdropPanels.last.end != 36500) return false;
  for (var n = 0; n < neighborhoodBackdropPanels.length; n++) {
    final p = neighborhoodBackdropPanels[n];
    if (p.width <= 0) return false;
    if (n > 0 && neighborhoodBackdropPanels[n - 1].end != p.start) {
      return false;
    }
  }
  for (final asset in [
    'residential_curve', 'green_promenade', 'white_canopy', 'rocket_park'
  ]) {
    if (neighborhoodBackdropPanels.where(
        (p) => p.asset == asset && p.landmark).length != 1) return false;
  }
  return true;
}
