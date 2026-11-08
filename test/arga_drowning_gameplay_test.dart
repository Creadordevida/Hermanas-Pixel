// Integrated QA of actual stage-seven game loop, not a model-only rule test.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';
import 'package:hermanas_aventura/arga_platform_rules.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Arga lethal gap takes one heart and restores safe checkpoint',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1000, 450));
    final gameKey = GlobalKey();
    final imageKey = GlobalKey();
    try {
      await tester.pumpWidget(MaterialApp(home: RepaintBoundary(
        key: imageKey,
        child: HermanasGame(key: gameKey, qaStage: 7, qaWorldX: 130),
      )));
      final dynamic game = gameKey.currentState;
      var ready = false;
      for (var i = 0; i < 300; i++) {
        await tester.runAsync(() =>
            Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pump(const Duration(milliseconds: 16));
        expect(game.loadError, isNull);
        if (game.resourcesReady == true) { ready = true; break; }
      }
      expect(ready, isTrue);
      expect(game.stage, 7);
      expect(game.hearts, 5);

      // The 705..770 interval contains water between safe log and timber.
      game.hero.x = 730.0;
      game.hero.y = ArgaCourse.waterDeathY - 6;
      game.hero.vy = 160.0;
      game.hero.grounded = false;
      game.argaSupport = null;
      for (var i = 0; i < 40 && game.hearts == 5; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(game.hearts, 4, reason: 'A single fall must cost one heart');
      expect(game.hero.x, closeTo(ArgaCourse.startX, .01),
          reason: 'Respawn at last safe Arga checkpoint');
      expect(game.hero.y, lessThan(ArgaCourse.waterDeathY));
      final boundary = imageKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      expect(boundary.debugNeedsPaint, isFalse);
      await tester.runAsync(() async {
        final picture = await boundary.toImage(pixelRatio: 1);
        try {
          final png = await picture.toByteData(format: ui.ImageByteFormat.png);
          expect(png, isNotNull);
          final file = File('qa/arga_rc7_flutter/arga_respawn_after_fall.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(png!.buffer.asUint8List(), flush: true);
          expect(await file.length(), greaterThan(10000));
        } finally { picture.dispose(); }
      });
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  }, timeout: const Timeout(Duration(minutes: 4)));
}
