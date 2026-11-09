import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/hero_hearts.dart';
import 'package:hermanas_aventura/main.dart';
import 'package:hermanas_aventura/wildlife_animation.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Dog lunge pose begins at the single directional contact', () {
    final dog = Enemy(0, 'dog_brown', 400)..attackCooldown = 0;
    dog.advanceAnimal(.02, 440, groundY);
    dog.advanceAnimal(.40, 440, groundY);
    expect(dog.animalMode, 'bite');
    expect(dog.advanceAnimal(.20, 440, groundY), isFalse);
    int pose() => dogAtlasFrame(
      kind: dog.kind,
      mode: dog.animalMode,
      elapsed: dog.animalTime,
      stunRemaining: 0,
      defeatElapsed: null,
    );
    expect(pose(), 13);
    expect(dog.advanceAnimal(.05, 440, groundY), isTrue);
    expect(pose(), 14);
    expect(dog.advanceAnimal(.05, 440, groundY), isFalse);

    final reverse = Enemy(0, 'dog_brown', 400)..attackCooldown = 0;
    reverse.advanceAnimal(.02, 440, groundY);
    reverse.advanceAnimal(.40, 440, groundY);
    expect(reverse.advanceAnimal(.25, 360, groundY), isFalse);
    expect(reverse.advanceAnimal(.05, 440, groundY), isFalse);
  });

  testWidgets('Fauna real: colisiones, proyectiles y secuencia 20:9', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final output = Platform.environment['WILDLIFE_QA_OUTPUT'];
    final rootKey = GlobalKey();
    final gameKey = GlobalKey();
    await tester.binding.setSurfaceSize(const Size(1000, 450));

    Future<void> tick([int count = 1]) async {
      for (var i = 0; i < count; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    }

    Future<void> capture(String path) async {
      if (output == null) return;
      final boundary =
          rootKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      expect(boundary.size, const Size(1000, 450));
      expect(boundary.debugNeedsPaint, isFalse);
      await tester.runAsync(() async {
        final rendered = await boundary.toImage(pixelRatio: 1);
        try {
          final png = (await rendered.toByteData(
            format: ui.ImageByteFormat.png,
          ))!;
          final file = File('$output/$path.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(
            png.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes),
          );
        } finally {
          rendered.dispose();
        }
      });
    }

    try {
      await tester.pumpWidget(
        MaterialApp(
          home: RepaintBoundary(
            key: rootKey,
            child: HermanasGame(key: gameKey, qaStage: 0),
          ),
        ),
      );
      final dynamic game = gameKey.currentState!;
      for (var i = 0; i < 1000 && game.resourcesReady != true; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tick();
        expect(game.loadError, isNull);
      }
      expect(game.resourcesReady, isTrue);
      expect(
        tester
            .widgetList<CustomPaint>(find.byType(CustomPaint))
            .any((paint) => paint.painter is StagePainter),
        isTrue,
      );
      final images = game.images as Map<String, ui.Image>;

      Enemy reset(String kind, int selected, double heroX) {
        game.obstacles.clear();
        game.platforms.clear();
        game.coins.clear();
        game.enemies.clear();
        game.shots.clear();
        game.screen = Screen.playing;
        game.selected = selected;
        game.hero = Character(heroX);
        game.cameraX = 0.0;
        game.hearts = maxHeroHearts;
        game.leftHeld = false;
        game.rightHeld = false;
        game.exitTime = -1.0;
        game.lastAttackTime = -10.0;
        final dog = Enemy(0, kind, 430)..attackCooldown = 0;
        game.enemies.add(dog);
        return dog;
      }

      for (final kind in dogAtlasAssets.keys) {
        final atlasKey = '${kind}_atlas';
        expect(images[atlasKey], isNotNull);

        reset(kind, 0, 170);
        await tick();
        final atlas = images.remove(atlasKey)!;
        await tick();
        await capture('$kind/previous');
        images[atlasKey] = atlas;
        await tick();
        await capture('$kind/idle');

        final patrol = reset(kind, 0, 100)..t = 1.3;
        final patrolStart = patrol.x;
        for (var i = 0; i < 40; i++) {
          await tick();
          if (i % 5 == 0) {
            await capture('$kind/motion/0_${i.toString().padLeft(3, '0')}');
          }
        }
        expect(patrol.animalMode, 'walk');
        expect(patrol.x, isNot(patrolStart));

        for (final selected in [0, 1]) {
          final dog = reset(kind, selected, 550);
          for (var i = 0; i < 150 && dog.animalMode != 'bite'; i++) {
            await tick();
            if (selected == 0 && i % 5 == 0) {
              await capture('$kind/motion/a_${i.toString().padLeft(3, '0')}');
            }
          }
          expect(dog.animalMode, 'bite');
          for (var i = 0; i < 30 && game.hearts == maxHeroHearts; i++) {
            await tick();
            if (selected == 0 && i % 5 == 0) {
              await capture('$kind/motion/b_${i.toString().padLeft(3, '0')}');
            }
          }
          expect(game.hearts, maxHeroHearts - 1);
          if (selected == 0) await capture('$kind/bite');

          final dodged = reset(kind, selected, 470);
          await tick(27);
          expect(dodged.animalMode, 'bite');
          game.hero.x = 390.0;
          await tick(20);
          expect(game.hearts, maxHeroHearts);

          final target = reset(kind, selected, 295);
          final shotAsset = selected == 0 ? 'ball' : 'comb';
          await tick();
          for (var hit = 1; hit <= target.hp; hit++) {
            game.hero = Character(295)..facing = 1;
            await tester.tap(
              find.byWidgetPredicate(
                (w) =>
                    w is Image &&
                    w.image is AssetImage &&
                    (w.image as AssetImage).assetName ==
                        'assets/images/$shotAsset.png' &&
                    w.width == 41,
              ),
            );
            for (var i = 0; i < 40 && target.hits < hit; i++) {
              await tick();
            }
            expect(target.hits, hit, reason: '$kind, $shotAsset');
            if (hit < target.hp) await tick(43);
          }
          expect(target.defeated, isTrue);
          if (selected == 0) {
            for (var i = 0; i < 38; i++) {
              if (i % 5 == 0) {
                await capture('$kind/motion/c_${i.toString().padLeft(3, '0')}');
              }
              if (i == 20) await capture('$kind/defeat');
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
