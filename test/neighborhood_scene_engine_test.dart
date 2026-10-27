import 'package:flutter_test/flutter_test.dart';

import '../lib/neighborhood_scene_engine.dart';

void main() {
  test('chapter one has a closed, continuous 36,500-unit world', () {
    expect(neighborhoodRegionsAreContinuous(36500), isTrue);
    expect(neighborhoodRegionsAreContinuous(36501), isFalse);
    expect(neighborhoodSceneRegions.length, 7);
    expect(neighborhoodSceneRegions.where((r) => !r.connector).length, 4);
  });

  test('all backdrop panels are world-locked and unique landmarks do not repeat', () {
    expect(neighborhoodBackdropPanelsValid(), isTrue);
    expect(neighborhoodBackdropPanels.length, 7);
    for (final landmark in <String>[
      'residential_curve', 'green_promenade', 'white_canopy', 'rocket_park',
    ]) {
      expect(neighborhoodBackdropPanels.where(
          (p) => p.asset == landmark && p.landmark).length, 1);
    }
    final allAssets=neighborhoodBackdropPanels.map((p) => p.asset).toSet();
    expect(allAssets.length, 7);
    expect(neighborhoodPanFraction(neighborhoodBackdropPanels[0], 0), 0);
    expect(neighborhoodPanFraction(neighborhoodBackdropPanels[0], 7000), 1);
    expect(neighborhoodPanFraction(neighborhoodBackdropPanels[0], 3500),
        inInclusiveRange(0.4,0.6));
  });

  test('seams reveal two different sections of the world, never a fade', () {
    final before = visibleNeighborhoodRegions(7000, 800).toList();
    expect(before.length, 2);
    expect(before.first.asset, 'residential_curve');
    expect(before.last.asset, 'connector_residential_greenway_v091');
    final after = visibleNeighborhoodRegions(8800, 800).toList();
    expect(after.length, 2);
    expect(after.first.connector, isTrue);
    expect(after.last.asset, 'green_promenade');
  });

  test('section progress is clamped and monotonic', () {
    final region = neighborhoodSceneRegions[1];
    expect(neighborhoodRegionProgress(region, 0), 0);
    expect(neighborhoodRegionProgress(region, 7200), 0);
    expect(neighborhoodRegionProgress(region, 8200), closeTo(.5, .001));
    expect(neighborhoodRegionProgress(region, 9200), 1);
    expect(neighborhoodRegionProgress(region, 50000), 1);
  });

  test('no repeated photo landmarks or unique region names', () {
    final regions = neighborhoodSceneRegions;
    final ids = regions.map((r) => r.id).toSet();
    expect(ids.length, regions.length);
    for (final asset in [
      'residential_curve',
      'green_promenade',
      'white_canopy',
      'rocket_park',
    ]) {
      expect(regions.where((r) => r.asset == asset).length, 1);
    }
  });
}

// Render panels must move one world pixel for each camera pixel. This catches
// a regression to using full-screen wallpapers and visually static landmarks.
// Native Dart stage-scene tests run before Android APK compilation.
