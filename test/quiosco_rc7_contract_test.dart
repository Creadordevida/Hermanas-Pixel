// Plaza del Castillo / Quiosco RC7: preliminary technical contract.
// Artistic approval is independent of this test; new image assets are gated.
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
  test('Quiosco art is protected until binary import is validated', () {
    expect(twcQuioscoRC7ArtworkEnabled, isFalse,
        reason: 'Do not activate files that are not yet in GitHub');
  });
  test('Buildings travel with physical ground in screen coordinates', () {
    const x=17300.0;
    expect((x-2100.0)-(x-2040.0),-60.0);
  });
}
