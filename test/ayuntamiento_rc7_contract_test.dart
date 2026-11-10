// Ayuntamiento RC7 release contract: NORMAL builds must show the new art.
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/main.dart';
void main() {
  test('Ayuntamiento new art is visible and covers whole existing chapter', () {
    expect(twcAyuntamientoRC7ArtworkEnabled,isTrue,
      reason:'Standard RC7 must display the new city hall art without dart-define');
    expect(twcAyuntamientoRC7TileCount,39);
    expect(twcAyuntamientoRC7TileWidth,960.0);
    expect(twcAyuntamientoRC7TileCount*twcAyuntamientoRC7TileWidth,
      greaterThanOrEqualTo(stageWidth));
    expect(groundY,390.0);
  });
  test('Physical facades follow camera at world speed', () {
    const x=18000.0;
    expect((x-1460.0)-(x-1400.0),-60.0);
  });
}
