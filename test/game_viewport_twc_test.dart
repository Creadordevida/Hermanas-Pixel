import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import '../lib/game_viewport_twc.dart';

void main() {
  for(final sample in [
    (const Size(1600,900),800.0),
    (const Size(2340,1080),975.0),
    (const Size(2400,1080),1000.0),
  ]) {
    test('Fullscreen ${sample.$1.width} x ${sample.$1.height}',(){
      final viewport=GameViewportTWC(sample.$1);
      expect(viewport.worldWidth,closeTo(sample.$2,.001));
      expect(viewport.hasHorizontalGutters,isFalse);
      expect(viewport.worldWidth/GameViewportTWC.baseHeight,
          closeTo(viewport.aspect,.0001));
      expect(viewport.screenXFromWorld(viewport.worldXFromScreen(321)),
          closeTo(321,.001));
    });
  }
}
