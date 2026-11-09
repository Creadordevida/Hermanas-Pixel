import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/comparsa_enemy.dart';
import 'package:hermanas_aventura/hero_hearts.dart';
import 'package:hermanas_aventura/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Los tres miembros de la comparsa están activos en la ruta normal', () {
    expect(comparsaAtlases.keys, unorderedEquals(ComparsaKind.values));
    expect(comparsaStage, 1);
    for (final kind in ComparsaKind.values) {
      expect(isEnemyPlayableInBuild(kind.id), isTrue);
    }
  });

  for (final kind in ComparsaKind.values) {
    test('${kind.id}: aviso, fotograma de contacto, salto y recuperación', () {
      ComparsaMotion ready() {
        final motion = ComparsaMotion(kind, 800);
        final heroX = 800 + kind.trigger - 6;
        expect(motion.update(.016, heroX, 0), isNull);
        expect(motion.pose, ComparsaPose.warning);
        expect(motion.update(kind.warning - .01, heroX, 0), isNull);
        expect(motion.pose, ComparsaPose.warning);
        expect(motion.update(.02, heroX, 0), isNull);
        expect(motion.pose, ComparsaPose.strike);
        return motion;
      }

      final contact = kind.strike / 2;
      final heroX = 800 + kind.trigger - 6;
      final attack = ready();
      expect(attack.update(contact - .01, heroX, 0), isNull);
      expect(attack.frame(), 13);
      expect(attack.update(.02, heroX, 0), 1);
      expect(attack.frame(), 14);
      expect(attack.update(.02, heroX, 0), isNull);
      expect(attack.update(contact, heroX, 0), isNull);
      expect(attack.pose, ComparsaPose.recover);
      expect(attack.acceptsProjectile(attack.x, 49), isTrue);
      final jump = ready();
      expect(jump.update(contact + .01, heroX, kind.jump + 4), isNull);
      expect(jump.update(.02, heroX, 0), isNull);

      if (kind != ComparsaKind.giant) {
        final behind = ready();
        expect(behind.update(contact + .01, 780, 0), isNull);
        expect(behind.facing, 1);
      } else {
        expect(ready().acceptsProjectile(800, 49), isFalse);
      }
    });
  }

  testWidgets('Comparsa del Ayuntamiento en StagePainter con Miren y Sara',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final output = Platform.environment['COMPARSA_QA_OUTPUT'];
    final rootKey = GlobalKey();
    final gameKey = GlobalKey();
    await tester.binding.setSurfaceSize(const Size(1000, 450));

    Future<void> tick([int count = 1]) async {
      for (var i = 0; i < count; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    }

    Future<void> capture(String name) async {
      if (output == null) return;
      final boundary =
          rootKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      expect(boundary.size, const Size(1000, 450));
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        try {
          final png = (await image.toByteData(format: ui.ImageByteFormat.png))!;
          final file = File('$output/$name.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(
              png.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes));
        } finally {
          image.dispose();
        }
      });
    }

    try {
      await tester.pumpWidget(MaterialApp(
          home: RepaintBoundary(
        key: rootKey,
        child: HermanasGame(key: gameKey, qaStage: comparsaStage),
      )));
      final dynamic game = gameKey.currentState!;
      for (var i = 0; i < 1200 && game.resourcesReady != true; i++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tick();
        expect(game.loadError, isNull);
      }
      expect(game.resourcesReady, isTrue);
      expect(
          tester
              .widgetList<CustomPaint>(find.byType(CustomPaint))
              .any((paint) => paint.painter is StagePainter),
          isTrue);
      final spawns = (game.enemies as List<Enemy>)
          .where((enemy) => enemy.comparsaMotion != null)
          .toList();
      expect(spawns.map((enemy) => enemy.kind),
          unorderedEquals(comparsaAtlases.keys.map((kind) => kind.id)));

      Enemy reset(ComparsaKind kind, int selected, double distance) {
        final x = comparsaPositions[kind]!;
        game.obstacles.clear();
        game.platforms.clear();
        game.coins.clear();
        game.enemies.clear();
        game.shots.clear();
        game.screen = Screen.playing;
        game.selected = selected;
        game.hero = Character(x - distance);
        game.cameraX = x - distance - 410;
        game.hearts = maxHeroHearts;
        game.leftHeld = false;
        game.rightHeld = false;
        game.exitTime = -1.0;
        game.lastAttackTime = -10.0;
        final foe = Enemy(0, kind.id, x);
        game.enemies.add(foe);
        return foe;
      }

      Future<void> fire(int selected) async {
        final asset = selected == 0 ? 'ball' : 'comb';
        await tester.tap(find.byWidgetPredicate((widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/$asset.png' &&
            widget.width == 41));
      }

      for (final kind in comparsaAtlases.keys) {
        final name = kind.name;
        final atlas =
            (game.images as Map<String, ui.Image>)['enemy_comparsa_$name']!;
        expect((atlas.width, atlas.height), (1280, 1728));
        final rgba = (await tester.runAsync(() => atlas.toByteData()))!;
        for (var frame = 0; frame < 24; frame++) {
          final source = comparsaFrameSource(frame);
          final index =
              (source.top.toInt() * atlas.width + source.left.toInt()) * 4;
          expect(rgba.getUint8(index + 3), 0, reason: '$name, marco $frame');
        }
        final idle = reset(kind, 0, 360);
        await tick();
        expect(idle.comparsaMotion!.pose, ComparsaPose.idle);
        await capture('$name/idle');

        for (final selected in [0, 1]) {
          final foe = reset(kind, selected, kind.trigger + 20);
          final motion = foe.comparsaMotion!;
          var sawWarning = false;
          for (var i = 0; i < 155 && game.hearts == maxHeroHearts; i++) {
            await tick();
            if (motion.pose == ComparsaPose.warning && !sawWarning) {
              sawWarning = true;
              expect(game.hearts, maxHeroHearts);
              if (selected == 0) await capture('$name/warning');
            }
            if (selected == 0 && i % 5 == 0) {
              await capture('$name/motion/a_${i.toString().padLeft(3, '0')}');
            }
          }
          expect(sawWarning, isTrue);
          expect(game.hearts, maxHeroHearts - 1, reason: kind.id);
          expect(motion.frame(), 14);
          if (selected == 0) {
            await capture('$name/contact');
            for (var i = 0; i < 40; i++) {
              await tick();
              if (i % 5 == 0) {
                await capture(
                    '$name/motion/a_recover_${i.toString().padLeft(3, '0')}');
              }
            }
          }

          final dodged = reset(kind, selected, kind.trigger - 4);
          await tick();
          expect(dodged.comparsaMotion!.pose, ComparsaPose.warning);
          game.hero = Character(dodged.x + 255);
          await tick(99);
          expect(game.hearts, maxHeroHearts);

          final target = reset(kind, selected, kind.trigger - 6);
          final targetMotion = target.comparsaMotion!;
          for (var hit = 1; hit <= target.hp; hit++) {
            if (kind == ComparsaKind.giant) {
              for (var i = 0;
                  i < 200 && targetMotion.pose != ComparsaPose.recover;
                  i++) {
                await tick();
              }
              expect(targetMotion.pose, ComparsaPose.recover);
            } else {
              await tick();
            }
            game.hero = Character(target.x - 111)..facing = 1;
            await tick();
            await fire(selected);
            for (var i = 0; i < 32 && target.hits < hit; i++) {
              await tick();
              if (selected == 0 && hit == target.hp && i % 5 == 0) {
                await capture('$name/motion/b_${i.toString().padLeft(3, '0')}');
              }
            }
            expect(target.hits, hit, reason: '${kind.id}, personaje $selected');
            if (hit < target.hp) {
              await tick(44);
              game.hero = Character(target.x - kind.trigger + 9);
            }
          }
          expect(target.defeated, isTrue);
          if (selected == 0) {
            for (var i = 0; i < 36; i++) {
              if (i % 5 == 0)
                await capture('$name/motion/c_${i.toString().padLeft(3, '0')}');
              if (i == 30) await capture('$name/defeat');
              await tick();
            }
          }
        }
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  }, timeout: const Timeout(Duration(minutes: 6)));
}
