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

      Enemy reset(String kind, int selected, double heroX,
          {double enemyX = 430}) {
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
        final foe = Enemy(0, kind, enemyX)..attackCooldown = 0;
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
            await fire(selected);
            for (var i = 0; i < 40 && target.hits < hit; i++) {
              await tick();
            }
            expect(target.hits, hit, reason: '$kind, $shotAsset');
            if (hit < target.hp) {
              expect(target.defeated, isFalse);
              expect(target.stunned, greaterThan(0));
              for (var i = 0; i < 43; i++) {
                if (selected == 0 && i % 5 == 0) {
                  await capture(
                      '$kind/motion/b_stun_${i.toString().padLeft(3, '0')}');
                }
                await tick();
              }
              expect(target.stunned, 0);
            }
          }
          expect(target.defeated, isTrue);
          if (selected == 0) {
            for (var i = 0; i < 38; i++) {
              if (i % 5 == 0) {
                await capture('$kind/motion/c_${i.toString().padLeft(3, '0')}');
              }
              if (i == 26) await capture('$kind/defeat');
              await tick();
            }
          }
        }
      }

      const pigeonKey = 'pigeon_flight_atlas';
      final pigeonAtlas = images.remove(pigeonKey)!;
      reset('pigeon', 0, 110, enemyX: 500);
      await tick();
      await capture('pigeon/previous');
      images[pigeonKey] = pigeonAtlas;
      await tick();
      await capture('pigeon/idle');
      final walking = reset('pigeon', 0, 110, enemyX: 500)..t = 3;
      for (var i = 0; i < 35; i++) {
        await tick();
        if (i % 5 == 0)
          await capture('pigeon/motion/0_${i.toString().padLeft(3, '0')}');
      }
      expect(walking.animalMode, 'walk');
      expect(walking.flightAltitude, 0);

      for (final selected in [0, 1]) {
        final bird = reset('pigeon', selected, 390, enemyX: 500);
        var sawTakeoff = false;
        var sawWarning = false;
        var sawDive = false;
        for (var i = 0; i < 135 && game.hearts == maxHeroHearts; i++) {
          await tick();
          if (bird.animalMode == 'takeoff' && bird.flightAltitude > 12) {
            if (!sawTakeoff && selected == 0) await capture('pigeon/takeoff');
            sawTakeoff = true;
          }
          if (bird.animalMode == 'dive_warning') {
            sawWarning = true;
            expect(game.hearts, maxHeroHearts);
          }
          if (bird.animalMode == 'dive' && bird.flightAltitude < 55) {
            if (!sawDive && selected == 0) await capture('pigeon/dive');
            sawDive = true;
          }
          if (selected == 0 && i % 5 == 0) {
            await capture('pigeon/motion/a_${i.toString().padLeft(3, '0')}');
          }
        }
        expect(sawTakeoff, isTrue);
        expect(sawWarning, isTrue);
        expect(sawDive, isTrue);
        expect(game.hearts, maxHeroHearts - 1);
        expect(bird.animalMode, 'recover');
        if (selected == 0) {
          game.hero = Character(30);
          var landed = false;
          var sawLanding = false;
          for (var i = 0; i < 210 && !landed; i++) {
            await tick();
            if (i % 5 == 0) {
              await capture('pigeon/motion/b_${i.toString().padLeft(3, '0')}');
            }
            if (!sawLanding &&
                bird.animalMode == 'landing' &&
                bird.flightAltitude < 22) {
              await capture('pigeon/landing');
              sawLanding = true;
            }
            landed = bird.animalMode == 'perch';
          }
          expect(landed, isTrue);
          expect(sawLanding, isTrue);
          expect(bird.flightAltitude, 0);
        }

        final dodged = reset('pigeon', selected, 390, enemyX: 500);
        for (var i = 0; i < 90 && dodged.animalMode != 'dive_warning'; i++) {
          await tick();
        }
        expect(dodged.animalMode, 'dive_warning');
        final lockedDirection = dodged.facing;
        game.hero = Character(dodged.x - lockedDirection * 85);
        await tick(31);
        expect(dodged.facing, lockedDirection);
        expect(game.hearts, maxHeroHearts);

        final target = reset('pigeon', selected, 390, enemyX: 500)
          ..attackCooldown = 9;
        for (var i = 0; i < 65 && target.animalMode != 'flap'; i++) {
          await tick();
        }
        expect(target.flightAltitude, greaterThan(70));
        game.hero = Character(target.x - 85, y: groundY - 64)
          ..grounded = false
          ..facing = 1;
        await fire(selected);
        for (var i = 0; i < 30 && !target.defeated; i++) {
          await tick();
        }
        expect(target.defeated, isTrue,
            reason: 'Impacto aéreo de ${selected == 0 ? 'Miren' : 'Sara'}');
        expect(target.flightAltitude, greaterThan(0));
        if (selected == 0) {
          for (var i = 0; i < 43; i++) {
            if (i % 5 == 0) {
              await capture('pigeon/motion/c_${i.toString().padLeft(3, '0')}');
            }
            if (i == 36) {
              expect(target.flightAltitude, 0);
              await capture('pigeon/defeat');
            }
            await tick();
          }
        } else {
          await tick(43);
        }
        expect(target.flightAltitude, 0);
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  }, timeout: const Timeout(Duration(minutes: 6)));
}
