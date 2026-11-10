import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/goalkeeper_animation.dart';
import 'package:hermanas_aventura/hero_hearts.dart';
import 'package:hermanas_aventura/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Portero: animación, esquiva, balón y peine en el campo',
      (tester) async {
    expect(twcGameplayPlaytest, isFalse);
    expect(hasApprovedEnemyArtwork('goalkeeper'), isTrue);
    expect(
      List.generate(twcChapterCount, (i) => i)
          .where((i) => StageData(i).enemies.contains('goalkeeper')),
      orderedEquals([4]),
    );
    SharedPreferences.setMockInitialValues({});
    final output = Platform.environment['GOALKEEPER_QA_OUTPUT'];
    final imageKey = GlobalKey();
    final gameKey = GlobalKey();
    await tester.binding.setSurfaceSize(const Size(1000, 450));

    Future<void> tick([int count = 1]) async {
      for (var i = 0; i < count; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    }

    Future<void> capture(int selected, String moment) async {
      if (output == null) return;
      final boundary =
          imageKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      expect(boundary.size, const Size(1000, 450));
      expect(boundary.debugNeedsPaint, isFalse);
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        try {
          final png = (await image.toByteData(format: ui.ImageByteFormat.png))!;
          final hero = selected == 0 ? 'miren' : 'sara';
          final file = File('$output/${hero}_$moment.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(
            png.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes),
            flush: true,
          );
          expect(await file.length(), greaterThan(10000));
        } finally {
          image.dispose();
        }
      });
    }

    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(MaterialApp(
          home: RepaintBoundary(
        key: imageKey,
        child: HermanasGame(key: gameKey),
      )));
      final dynamic game = gameKey.currentState!;
      for (var i = 0; i < 500 && game.resourcesReady != true; i++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 30)));
        await tick();
        expect(game.loadError, isNull);
      }
      expect(game.resourcesReady, isTrue);
      expect(game.screen, Screen.title);
      await tester.tap(find.bySemanticsLabel('Nueva partida'));
      await tick();
      expect(game.screen, Screen.map);
      await tester.tap(
        find.bySemanticsLabel('Capítulo 5: Campo de entrenamiento'),
      );
      await tick();
      expect(game.stage, 4);
      expect(game.screen, Screen.playing);
      expect(game.selected, 0);
      expect((game.enemies as List<Enemy>).any((e) => e.kind == 'goalkeeper'),
          isTrue);
      final atlas =
          (game.images as Map<String, ui.Image>)['enemy_goalkeeper_atlas']!;
      expect((atlas.width, atlas.height), (1024, 1536));
      final pixels = (await tester.runAsync(() => atlas.toByteData()))!;
      for (var i = 0; i < 24; i++) {
        final offset = ((i ~/ 4) * 256 * atlas.width + (i % 4) * 256) * 4;
        expect(pixels.getUint8(offset + 3), 0, reason: 'Margen celda $i');
      }
      StagePainter painter() => tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((paint) => paint.painter)
          .whereType<StagePainter>()
          .single;
      expect(painter().images['enemy_goalkeeper_atlas'], same(atlas));

      const worldX = 3300.0;
      Enemy reset(int selected, double distance, {double cooldown = 0}) {
        final side = selected == 0 ? -1 : 1;
        game.obstacles.clear();
        game.platforms.clear();
        game.coins.clear();
        game.enemies.clear();
        game.shots.clear();
        game.screen = Screen.playing;
        game.selected = selected;
        game.hero = Character(worldX + side * distance)..facing = -side;
        game.cameraX = game.hero.x - 410.0;
        game.hearts = maxHeroHearts;
        game.leftHeld = false;
        game.rightHeld = false;
        game.exitTime = -1.0;
        game.lastAttackTime = -10.0;
        final keeper = Enemy(0, 'goalkeeper', worldX)
          ..attackCooldown = cooldown
          ..facing = side;
        game.enemies.add(keeper);
        return keeper;
      }

      GoalkeeperFrame frame(Enemy keeper) => goalkeeperAtlasFrame(
            elapsed: keeper.t,
            moving: false,
            attacking: keeper.launched,
            stunned: keeper.stunned > 0,
            defeated: keeper.defeated,
            defeatElapsed:
                keeper.defeated ? painter().time - keeper.deathAt : 0,
          );

      for (final selected in [0, 1]) {
        final side = selected == 0 ? -1 : 1;
        final idle = reset(selected, 70, cooldown: 1);
        await tick(3);
        expect(idle.x, worldX);
        expect(frame(idle).pose, GoalkeeperPose.idle);
        await capture(selected, '01_reposo');

        final walking = reset(selected, 143, cooldown: 1);
        await tick(11);
        expect((walking.x - worldX) * side, greaterThan(0));
        await capture(selected, '02_desplazamiento');

        final attack = reset(selected, 44);
        await tick(11);
        expect(attack.facing, side);
        expect(attack.launched, isTrue);
        expect(frame(attack).pose, GoalkeeperPose.warning);
        expect(game.hearts, maxHeroHearts);
        await capture(selected, '03_aviso');

        final diveColumns = <int>{};
        var capturedContact = false;
        for (var i = 0; i < 50 && attack.launched; i++) {
          await tick();
          final current = frame(attack);
          if (current.pose == GoalkeeperPose.dive)
            diveColumns.add(current.column);
          if (!capturedContact && game.hearts < maxHeroHearts) {
            expect(attack.t, inInclusiveRange(.34, .52));
            expect(current.pose, GoalkeeperPose.dive);
            await capture(selected, '04_estirada');
            capturedContact = true;
          }
        }
        expect(capturedContact, isTrue);
        expect(diveColumns, {0, 1, 2, 3});
        expect(game.hearts, maxHeroHearts - 1);
        expect(attack.launched, isFalse);
        expect(attack.attackCooldown, closeTo(2.7, .02));

        final dodged = reset(selected, 44);
        await tick(5);
        expect(dodged.launched, isTrue);
        await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
        await tick(21);
        expect(game.hero.y, lessThan(groundY - 60));
        await tick(35);
        expect(game.hearts, maxHeroHearts);
        expect(dodged.launched, isFalse);

        final target = reset(selected, 80);
        await tick(6);
        expect(target.launched, isTrue);
        final asset = selected == 0 ? 'ball' : 'comb';
        await tester.tap(find.byWidgetPredicate((widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/$asset.png' &&
            widget.width == 41));
        expect((game.shots as List<Projectile>).single.kind, asset);
        for (var i = 0; i < 20 && !target.defeated; i++) {
          await tick();
        }
        expect(target.defeated, isTrue);
        expect(target.hits, 1);
        expect(game.hearts, maxHeroHearts);
        expect(frame(target).pose, GoalkeeperPose.hurt);
        await tick(3);
        await capture(selected, '05_impacto');
        await tick(37);
        expect(game.hearts, maxHeroHearts);
        expect(target.x, worldX);
        expect(frame(target).pose, GoalkeeperPose.defeated);
        expect(frame(target).column, 3);
        await capture(selected, '06_derrota');
      }
    } finally {
      semantics.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  }, timeout: const Timeout(Duration(minutes: 6)));
}
