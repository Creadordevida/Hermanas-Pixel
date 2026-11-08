// QA-only integration test: actual Flutter game loop and hero heart counter.
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
  testWidgets('Arga crab pinches hero once in the real game loop',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1000, 450));
    final key = GlobalKey();
    final imageKey = GlobalKey();
    try {
      await tester.pumpWidget(MaterialApp(home: RepaintBoundary(
        key: imageKey,
        child: HermanasGame(key: key, qaStage: 7, qaWorldX: 350),
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
      expect(game.hearts, 5);
      game.hero.x = 350.0;
      game.hero.y = ArgaCourse.surfaces[1].top;
      game.hero.vx = 0.0;
      game.hero.vy = 0.0;
      game.hero.grounded = true;
      game.argaSupport = ArgaCourse.surfaces[1];
      game.argaSupportSince = game.time;
      // The crab telegraphs for .55s and connects after .12s of pinch.
      for (var i = 0; i < 70 && game.hearts == 5; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(game.hearts, 4,
          reason: 'Real pincher contact must subtract exactly one heart');
      // Hit invulnerability and the one-hit flag stop repeat damage.
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(game.hearts, 4);
      final boundary = imageKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      expect(boundary.debugNeedsPaint, isFalse);
      await tester.runAsync(() async {
        final picture = await boundary.toImage(pixelRatio: 1);
        try {
          final png = await picture.toByteData(format: ui.ImageByteFormat.png);
          expect(png, isNotNull);
          final file = File('qa/arga_rc7_flutter/arga_crab_after_hit.png');
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
