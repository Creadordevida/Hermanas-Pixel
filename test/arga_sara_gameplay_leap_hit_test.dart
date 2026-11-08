// QA-only: verifies the alternate heroine Sara receives real trout contact.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';
import 'package:hermanas_aventura/arga_platform_rules.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Arga trout damages Sara once in actual Flutter game loop',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1000, 450));
    final key = GlobalKey();
    try {
      await tester.pumpWidget(MaterialApp(home: HermanasGame(
        key: key, qaStage: 7, qaWorldX: 905, qaSelected: 1,
      )));
      final dynamic game = key.currentState;
      var ready = false;
      for (var i = 0; i < 300; i++) {
        await tester.runAsync(() =>
            Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pump(const Duration(milliseconds: 16));
        expect(game.loadError, isNull);
        if (game.resourcesReady == true) { ready = true; break; }
      }
      expect(ready, isTrue);
      expect(game.selected, 1, reason: 'The active heroine must be Sara');
      expect(game.hearts, 5);
      game.hero.x = 905.0;
      game.hero.y = ArgaCourse.surfaces[3].top;
      game.hero.vx = 0.0;
      game.hero.vy = 0.0;
      game.hero.grounded = true;
      game.argaSupport = ArgaCourse.surfaces[3];
      game.argaSupportSince = game.time;
      var sawLeap = false;
      for (var i = 0; i < 190 && game.hearts == 5; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        if (game.argaTrout?.airborne == true) sawLeap = true;
      }
      expect(sawLeap, isTrue);
      expect(game.hearts, 4, reason: 'Trout must be able to damage Sara');
      for (var i = 0; i < 18; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(game.hearts, 4, reason: 'No repeated damage by same leap');
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  }, timeout: const Timeout(Duration(minutes: 4)));
}
