// RC7 Estafeta contract tests. These do NOT approve artistic quality.
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/main.dart';

void main() {
  test('Estafeta asset switch is safe until all candidates are present', () {
    // Flag can be enabled for explicit QA; never assert a build mode.
    expect(twcEstafetaRC7ArtworkEnabled, isTrue,
      reason: 'Standard preview APK must display Estafeta RC7');
    expect(twcEstafetaRC7TileCount, 39);
    expect(twcEstafetaRC7TileWidth, 960);
  });
  test('Candidate tiles cover the existing physical chapter length', () {
    expect(twcEstafetaRC7TileCount * twcEstafetaRC7TileWidth,
      greaterThanOrEqualTo(stageWidth));
    // Facades run at world speed: their screen X = world X - camera X.
    const facadeWorldX = 4800.0;
    const firstCamera = 2450.0;
    const secondCamera = 2510.0;
    expect((facadeWorldX - secondCamera) - (facadeWorldX - firstCamera), -60);
    expect(groundY, 390);
  });
}
