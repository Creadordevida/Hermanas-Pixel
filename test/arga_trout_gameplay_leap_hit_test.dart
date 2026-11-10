// QA-only: trout jump and hero contact inside the actual Flutter game loop.
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
  testWidgets('Arga trout naturally jumps and contacts hero just once',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1000, 450));
    final key = GlobalKey();
    final imageKey = GlobalKey();
    try {
      await tester.pumpWidget(MaterialApp(home: RepaintBoundary(
        key: imageKey,
        child: HermanasGame(key: key, qaStage: 7, qaWorldX: 905),
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
      expect(sawLeap, isTrue, reason: 'Trout must leap from water');
      expect(game.hearts, 4, reason: 'Natural leap must contact Miren');
      for (var i = 0; i < 18; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(game.hearts, 4, reason: 'One leap cannot cause repeated damage');
      final boundary = imageKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      expect(boundary.debugNeedsPaint, isFalse);
      await tester.runAsync(() async {
        final picture = await boundary.toImage(pixelRatio: 1);
        try {
          final png = await picture.toByteData(format: ui.ImageByteFormat.png);
          expect(png, isNotNull);
          final file = File('qa/arga_rc7_flutter/arga_trout_after_leap_hit.png');
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
