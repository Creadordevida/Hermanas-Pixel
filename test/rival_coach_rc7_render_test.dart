// RC7: genuine StagePainter screenshot for the coach, not an Android build.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('RC7 coach real StagePainter 20:9 evidence', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1000, 450));
    final gameKey = GlobalKey();
    final boundaryKey = GlobalKey();
    try {
      await tester.pumpWidget(MaterialApp(home: RepaintBoundary(
        key: boundaryKey,
        child: HermanasGame(key: gameKey, qaStage: 4, qaSelected: 0),
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
      game.selected = 0; // Football chapter: Miren selected.
      game.hero = Character(425);
      game.hearts = 5;
      game.leftHeld = false;
      game.rightHeld = false;
      game.exitTime = -1.0;
      final coach = Enemy(0, 'rival_coach', 475)..attackCooldown = 0;
      game.enemies.add(coach);
      await tester.pump(const Duration(milliseconds: 150));
      final active = tester.widgetList<CustomPaint>(find.byType(CustomPaint))
        .where((w) => w.painter is StagePainter &&
          (w.painter! as StagePainter).stage == 4);
      expect(active, isNotEmpty);
      expect((active.first.painter! as StagePainter).selected, 0);
      Future<void> capture(String name) async {
        await tester.pump(const Duration(milliseconds: 16));
        final boundary = boundaryKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
        expect(boundary.size, const Size(1000, 450));
        expect(boundary.debugNeedsPaint, false);
        final size = await tester.runAsync<int>(() async {
          final ui.Image image = await boundary.toImage(pixelRatio: 1)
            .timeout(const Duration(seconds: 30));
          try {
            final data = await image.toByteData(format: ui.ImageByteFormat.png)
              .timeout(const Duration(seconds: 30));
            if (data == null) throw StateError('No PNG for $name');
            final file = File('qa/rival_coach_flutter/$name.png');
            await file.parent.create(recursive: true);
            await file.writeAsBytes(data.buffer.asUint8List(
              data.offsetInBytes, data.lengthInBytes), flush: true);
            return await file.length();
          } finally {
            image.dispose();
          }
        });
        expect(size, greaterThan(10000));
        print('REAL_COACH_STAGEPAINTER_CAPTURE $name 1000x450 $size');
      }
      Future<void> frames(int count) async {
        for (var i=0; i<count; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
      }
      await capture('01_miren_entrenador');
      await frames(20);
      await capture('02_pizarra_t20');
      await frames(25);
      await capture('03_pizarra_t45');
      await frames(25);
      await capture('04_pizarra_t70');
      coach.hits = coach.hp - 1;
      game.shots.add(Projectile(x: coach.x, y: groundY - 48,
        vx: 0, kind: 'ball'));
      await frames(1);
      expect(coach.defeated, isTrue,
        reason: 'Coach must enter real defeat state before screenshots');
      await frames(8);
      await capture('05_derrota_t08');
      await frames(20);
      await capture('06_derrota_t28');
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  }, timeout: const Timeout(Duration(minutes: 5)));
}
