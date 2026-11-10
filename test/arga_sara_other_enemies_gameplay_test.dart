// QA-only: verify the other three enemies naturally damage Sara in game loop.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';
import 'package:hermanas_aventura/arga_platform_rules.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final kind in <String>['crab', 'fisher', 'boy']) {
    testWidgets('Arga $kind naturally damages Sara exactly once',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.binding.setSurfaceSize(const Size(1000, 450));
      final key = GlobalKey();
      final x = kind == 'crab' ? 350.0 : kind == 'fisher' ? 1260.0 : 1980.0;
      final surface = kind == 'crab' ? 1 : kind == 'fisher' ? 5 : 8;
      final ticks = kind == 'crab' ? 70 : 185;
      try {
        await tester.pumpWidget(MaterialApp(home: HermanasGame(
          key: key, qaStage: 7, qaWorldX: x, qaSelected: 1,
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
        expect(game.selected, 1, reason: 'Sara must be the active heroine');
        expect(game.hearts, 5);
        game.hero.x = x;
        game.hero.y = ArgaCourse.surfaces[surface].top;
        game.hero.vx = 0.0;
        game.hero.vy = 0.0;
        game.hero.grounded = true;
        game.argaSupport = ArgaCourse.surfaces[surface];
        game.argaSupportSince = game.time;

        var sawProjectile = false;
        for (var i = 0; i < ticks && game.hearts == 5; i++) {
          await tester.pump(const Duration(milliseconds: 16));
          if (kind == 'fisher' && game.argaHook != null) {
            sawProjectile = true;
          }
          if (kind == 'boy' && game.argaStone != null) {
            sawProjectile = true;
          }
        }
        if (kind != 'crab') {
          expect(sawProjectile, isTrue,
              reason: 'Projectile must come from normal enemy attack');
        }
        expect(game.hearts, 4,
            reason: 'Normal $kind attack must remove one Sara heart');
        for (var i = 0; i < 18; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(game.hearts, 4,
            reason: 'Same $kind attack must not damage Sara twice');
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.binding.setSurfaceSize(null);
      }
    }, timeout: const Timeout(Duration(minutes: 4)));
  }
}
