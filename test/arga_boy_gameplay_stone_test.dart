// QA-only: actual stone throw and hero damage in the Flutter game loop.
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
  testWidgets('Arga boy naturally throws a stone that hits hero once',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1000, 450));
    final key = GlobalKey();
    final imageKey = GlobalKey();
    try {
      await tester.pumpWidget(MaterialApp(home: RepaintBoundary(
        key: imageKey,
        child: HermanasGame(key: key, qaStage: 7, qaWorldX: 1980),
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
      game.hero.x = 1980.0;
      game.hero.y = ArgaCourse.surfaces[8].top;
      game.hero.vx = 0.0;
      game.hero.vy = 0.0;
      game.hero.grounded = true;
      game.argaSupport = ArgaCourse.surfaces[8];
      game.argaSupportSince = game.time;

      var sawStone = false;
      for (var i = 0; i < 185 && game.hearts == 5; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        if (game.argaStone != null) sawStone = true;
      }
      expect(sawStone, isTrue, reason: 'Boy must release a stone after warning');
      expect(game.hearts, 4, reason: 'A naturally thrown stone must hit hero');
      for (var i = 0; i < 18; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(game.hearts, 4, reason: 'One stone cannot deal repeated damage');
      final boundary = imageKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      expect(boundary.debugNeedsPaint, isFalse);
      await tester.runAsync(() async {
        final picture = await boundary.toImage(pixelRatio: 1);
        try {
          final png = await picture.toByteData(format: ui.ImageByteFormat.png);
          expect(png, isNotNull);
          final file = File('qa/arga_rc7_flutter/arga_boy_after_stone.png');
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
