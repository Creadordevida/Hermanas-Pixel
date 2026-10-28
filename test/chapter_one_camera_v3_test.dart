import 'package:flutter_test/flutter_test.dart';
import '../lib/chapter_one_camera_v3.dart';
import '../lib/chapter_one_layout.dart';
import '../lib/neighborhood_scene_engine.dart';

void main() {
  test('Mismo inicio de zonas para escenarios y objetos jugables', () {
    final landmarks = neighborhoodSceneRegions.where((r) => !r.connector).toList();
    expect(neighborhoodZones.length, landmarks.length);
    for (var i = 0; i < landmarks.length; i++) {
      expect(neighborhoodZones[i].start, landmarks[i].start);
      expect(neighborhoodZones[i].asset, landmarks[i].asset);
      expect(neighborhoodZones[i].end, i + 1 < landmarks.length
          ? landmarks[i + 1].start : neighborhoodSceneRegions.last.end);
    }
    expect(neighborhoodZones.last.end, 36500);
  });

  test('Objetos anclados recorren exactamente 600 al avanzar cámara 600', () {
    expect(worldObjectScreenX(900, 0) - worldObjectScreenX(900, 600), 600);
    expect(curvedBuildingPilot.screenX(0) - curvedBuildingPilot.screenX(600), 600);
  });

  test('Imagen original se representa a escala uniforme, no 7200 unidades', () {
    final expected = 1672 * 380 / 690;
    expect(curvedBuildingPilot.width, closeTo(expected, .001));
    expect(curvedBuildingPilot.width, lessThan(1000));
    expect(curvedBuildingPilot.scaleFactor, 1);
  });

  test('La falta de arte visible bloquea aprobación, no se rellena con estiramiento', () {
    final at0 = missingWorldArtInCamera(0, 800, [curvedBuildingPilot]);
    final at600 = missingWorldArtInCamera(600, 800, [curvedBuildingPilot]);
    expect(at0, 0);
    expect(at600, greaterThan(470));
    expect(missingWorldArtInCamera(2000, 800, [curvedBuildingPilot]), 800);
  });

  test('Cámara sigue a Sara y se limita al mundo', () {
    const cam = ChapterOneCameraV3();
    expect(cam.follow(145), 0);
    expect(cam.follow(327), 0);
    expect(cam.follow(927), 600);
    expect(cam.follow(36500), 35700);
  });
}
