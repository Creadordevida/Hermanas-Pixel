import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/chapter_one_world_v4.dart';

void main() {
  test('Tramos únicos y 36.500 unidades de mundo', () {
    expect(ch1RegionsConsistentV4(), isTrue);
    expect(ch1StageWidthV4, 36500);
    expect(ch1LandmarksV4.length, 7);
    expect(ch1LandmarksV4.map((a) => a.asset).toSet().length, 7);
  });
  test('Los hitos nunca se estiran y se mueven en coordenadas reales', () {
    final building=ch1LandmarksV4.first;
    expect(building.width, closeTo(804.25316456,0.001));
    expect(building.screenX(600)-building.screenX(0), -600);
    expect(building.visible(500,800),isTrue);
    expect(building.visible(1000,800),isFalse);
  });
  test('Cámara sigue a personaje con límites', () {
    expect(ch1CameraXForHeroV4(327), 0);
    expect(ch1CameraXForHeroV4(927), 600);
    expect(ch1CameraXForHeroV4(36500), 35700);
  });
  test('V5: ninguna copa de arbol atraviesa ilustraciones protegidas', () {
    for (final prop in ch1PropsV4()) {
      final rect = ch1PropRectsV4[prop.atlasIndex];
      final width = prop.height * rect[2] / rect[3];
      expect(ch1PropSafeV4(prop.worldX, width:width), isTrue,
          reason:'objeto ${prop.id} ocupa un monumento protegido');
    }
  });
  test('V5: recorte real preserva la parte jugable de las pinturas', () {
    expect(ch1SourceDimsV4['residential_curve']!.$2, 790);
    expect(ch1SourceDimsV4['green_promenade']!.$2, 790);
    expect(ch1SourceDimsV4['white_canopy']!.$2, 790);
    expect(ch1SourceDimsV4['rocket_park']!.$2, 790);
  });
  test('Los objetos de atlas tienen origen físico único', () {
    expect(ch1PropRectsV4.length,12);
    final props=ch1PropsV4().toList();
    expect(props.length,greaterThan(65));
    expect(props.map((p)=>p.id).toSet().length,props.length);
    for (final p in props) {
      expect(p.worldX,greaterThanOrEqualTo(0));
      expect(p.worldX,lessThan(36500));
      expect(p.height,greaterThan(0));
    }
  });
}

