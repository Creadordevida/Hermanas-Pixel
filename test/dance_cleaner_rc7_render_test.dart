// RC7: genuine StagePainter screenshot for the cleaner, not an Android build.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('RC7 cleaner real StagePainter 20:9 evidence', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1000, 450));
    final gameKey = GlobalKey();
    final boundaryKey = GlobalKey();
    try {
      await tester.pumpWidget(MaterialApp(home: RepaintBoundary(
        key: boundaryKey,
        child: HermanasGame(key: gameKey, qaStage: 5, qaSelected: 1),
      )));
      final dynamic game = gameKey.currentState;
      for (var i = 0; i < 400 && game.resourcesReady != true; i++) {
        await tester.runAsync(() =>
          Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pump(const Duration(milliseconds: 16));
        expect(game.loadError, isNull);
      }
      expect(game.resourcesReady, isTrue);
      game.obstacles.clear();
      game.platforms.clear();
      game.coins.clear();
      game.enemies.clear();
      game.shots.clear();
      game.screen = Screen.playing;
      game.selected = 1; // Dance forces Sara.
      game.hero = Character(425);
      game.hearts = 5;
      game.leftHeld = false;
      game.rightHeld = false;
      game.exitTime = -1.0;
      game.enemies.add(Enemy(0, 'dance_cleaner', 510)..attackCooldown = 0);
      await tester.pump(const Duration(milliseconds: 150));
      final active = tester.widgetList<CustomPaint>(find.byType(CustomPaint))
        .where((w) => w.painter is StagePainter &&
          (w.painter! as StagePainter).stage == 5);
      expect(active, isNotEmpty);
      expect((active.first.painter! as StagePainter).selected, 1);
      final boundary = boundaryKey.currentContext!.findRenderObject()!
        as RenderRepaintBoundary;
      expect(boundary.size, const Size(1000, 450));
      expect(boundary.debugNeedsPaint, false);
      final bytes = await tester.runAsync<List<int>>(() async {
        final ui.Image image = await boundary.toImage(pixelRatio: 1)
          .timeout(const Duration(seconds: 30));
        try {
          final data = await image.toByteData(format: ui.ImageByteFormat.png)
            .timeout(const Duration(seconds: 30));
          if (data == null) throw StateError('PNG encoding returned null');
          final file = File('qa/dance_cleaner_flutter/01_sara_limpiador.png');
          await file.parent.create(recursive: true);
          final png = data.buffer.asUint8List(
            data.offsetInBytes, data.lengthInBytes);
          await file.writeAsBytes(png, flush: true);
          return png;
        } finally {
          image.dispose();
        }
      });
      expect(bytes, isNotNull);
      expect(bytes!.length, greaterThan(10000));
      print('REAL_CLEANER_STAGEPAINTER_CAPTURE 1000x450 bytes=${bytes.length}');
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  }, timeout: const Timeout(Duration(minutes: 5)));
}
