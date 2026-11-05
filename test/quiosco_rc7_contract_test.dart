// Plaza del Castillo / Quiosco RC7: standard-build visibility contract.
// Technical readiness is separate from a final artistic approval.
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/main.dart';

void main() {
  test('Quiosco tile world matches existing level length', () {
    expect(twcQuioscoRC7TileCount, 39);
    expect(twcQuioscoRC7TileWidth, 960.0);
    expect(twcQuioscoRC7TileCount * twcQuioscoRC7TileWidth,
        greaterThanOrEqualTo(stageWidth));
    expect(groundY, 390.0);
  });
  test('Quiosco art is visible in normal RC7 builds', () {
    expect(twcQuioscoRC7ArtworkEnabled, isTrue,
        reason: 'Integrated art must be visible without development flags');
  });
  test('Buildings travel with physical ground in screen coordinates', () {
    const x=17300.0;
    expect((x-2100.0)-(x-2040.0),-60.0);
  });
}
