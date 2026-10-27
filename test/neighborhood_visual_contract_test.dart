import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/neighborhood_scene_engine.dart';

/// Visual composition PRECONDITIONS. Passing does not imply that hard joins
/// have been fixed: they must also pass screenshot/video inspection.
void main() {
  test('Every original landmark is unique and protected from new tree overlays', () {
    expect(neighborhoodBackdropPanelsValid(), isTrue);
    final landmarks = neighborhoodBackdropPanels.where((p) => p.landmark);
    expect(landmarks.length, 4);
    expect(landmarks.map((p) => p.asset).toSet().length, 4);
    for (final landmark in landmarks) {
      expect(neighborhoodTreeAllowedAt(landmark.start + 20), isFalse);
      expect(neighborhoodTreeAllowedAt(landmark.end - 20), isFalse);
      expect(neighborhoodLandmarkInCamera(landmark.start - 150, 800), isTrue);
    }
  });

  test('Pavement from artwork can never enter the physical ground layer', () {
    const sourceWidths = <String, double>{
      'residential_curve': 1672,
      'green_promenade': 1672,
      'white_canopy': 1672,
      'rocket_park': 1672,
      'connector_residential_greenway_v091': 2116,
      'connector_neutral_park_v091': 2086,
      'connector_pergola_v091': 2172,
    };
    for (final panel in neighborhoodBackdropPanels) {
      final originalWidth = sourceWidths[panel.asset];
      expect(originalWidth, isNotNull, reason: panel.asset);
      expect(neighborhoodCropFits(panel.asset, originalWidth!, 800), isTrue,
          reason: 'Aspect-ratio or source overrun: ${panel.asset}');
      final sh = neighborhoodSourceHeight(panel.asset);
      expect(sh, greaterThan(0));
      // Physical floor begins at y=380; 0..sh contains no source pavement.
      expect(sh, lessThan(710));
    }
  });
}
