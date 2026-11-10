import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/main.dart';
import 'package:hermanas_aventura/hero_hearts.dart';
import 'package:hermanas_aventura/teacher_animation.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('La profesora avisa, suelta la goma y cae en el Colegio',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1000, 450));
    final output = Platform.environment['TEACHER_QA_OUTPUT'];
    final key = GlobalKey();
    final imageKey = GlobalKey();
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(
        home: RepaintBoundary(key: imageKey, child: HermanasGame(key: key))));
    final dynamic game = key.currentState;
    Future<void> tick([int n = 1]) async {
      for (var i = 0; i < n; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    }

    Future<void> capture(int selected, String name) async {
      if (output == null) return;
      final boundary =
          imageKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      expect(boundary.size, const Size(1000, 450));
      await tester.runAsync(() async {
        final img = await boundary.toImage(pixelRatio: 1);
        try {
          final bytes = (await img.toByteData(format: ui.ImageByteFormat.png))!;
          final hero = selected == 0 ? 'miren' : 'sara';
          final file = File('$output/${hero}_$name.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes.buffer
              .asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
        } finally {
          img.dispose();
        }
      });
    }

    try {
      for (var i = 0; i < 600 && game.resourcesReady != true; i++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 30)));
        await tick();
        expect(game.loadError, isNull);
      }
      expect(game.resourcesReady, isTrue);
      await tester.tap(find.bySemanticsLabel('Nueva partida'));
      await tick();
      await tester.tap(find.bySemanticsLabel('Capítulo 7: El colegio'));
      await tick();
      expect(game.stage, 6);
      expect(game.screen, Screen.choose);
      await tester.tap(find.text('MIREN'));
      await tick();
      expect(game.screen, Screen.playing);
      final teachers = (game.enemies as List<Enemy>)
          .where((e) => e.kind == 'teacher')
          .toList();
      expect(teachers, hasLength(14));
      final position = teachers.first.x;
      StagePainter painter() => tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((w) => w.painter)
          .whereType<StagePainter>()
          .single;
      final atlas = painter().images['enemy_teacher_atlas'];
      expect(atlas, isNotNull);
      expect((atlas!.width, atlas.height), (1024, 1536));
      final rgba = (await tester.runAsync(atlas.toByteData))!;
      final silhouettes = <int>{};
      for (var i = 0; i < 24; i++) {
        final x = (i % 4) * 256;
        final y = (i ~/ 4) * 256;
        var hash = 0;
        for (var dy = 0; dy < 256; dy++) {
          for (var dx = 0; dx < 256; dx++) {
            final alpha =
                rgba.getUint8(((y + dy) * atlas.width + x + dx) * 4 + 3);
            if (dy == 0 || dx == 0 || dx == 255 || dy == 255) {
              expect(alpha, 0);
            }
            if (alpha != 0) hash = (hash * 31 + dx * 3 + dy) & 0x3fffffff;
          }
        }
        expect(hash, isNonZero);
        expect(silhouettes.add(hash), isTrue, reason: 'Silueta de la celda $i');
      }

      Enemy reset(int selected, double distance, {double cooldown = 0}) {
        final side = selected == 0 ? 1 : -1;
        game.obstacles.clear();
        game.platforms.clear();
        game.coins.clear();
        game.enemies.clear();
        game.shots.clear();
        game.screen = Screen.playing;
        game.selected = selected;
        game.hero = Character(position + side * distance)..facing = -side;
        game.cameraX = game.hero.x - 410.0;
        game.hearts = maxHeroHearts;
        game.leftHeld = false;
        game.rightHeld = false;
        game.exitTime = -1.0;
        game.lastAttackTime = -10.0;
        final teacher = Enemy(1, 'teacher', position)
          ..facing = side
          ..attackCooldown = cooldown;
        game.enemies.add(teacher);
        return teacher;
      }

      ({int row, int column}) frame(Enemy teacher) => teacherAtlasFrame(
            elapsed: teacher.t,
            preparing: teacher.launched,
            cooldown: teacher.attackCooldown,
            stunned: teacher.stunned > 0,
            defeatElapsed:
                teacher.defeated ? painter().time - teacher.deathAt : null,
          );

      for (final selected in [0, 1]) {
        final side = selected == 0 ? 1 : -1;
        final teacher = reset(selected, 140, cooldown: 1);
        await tick(4);
        expect(frame(teacher).row, TeacherPose.idle.index);
        expect(teacher.x, position);
        await capture(selected, '01_reposo');

        teacher.attackCooldown = 0;
        await tick(12);
        expect(teacher.launched, isTrue);
        expect(teacher.facing, side);
        expect(game.shots, isEmpty);
        await capture(selected, '02_aviso');

        final warned = <int>{};
        for (var i = 0; i < 50 && teacher.launched; i++) {
          final current = frame(teacher);
          expect(current.row, TeacherPose.warning.index);
          warned.add(current.column);
          await tick();
        }
        expect(warned, {0, 1, 2, 3});
        expect(frame(teacher), (row: TeacherPose.release.index, column: 0));
        final eraser = (game.shots as List<Projectile>).single;
        expect(eraser.kind, 'eraser');
        expect(eraser.vx, side * 195.0);
        expect(eraser.x, position + side * teacherReleaseX);
        expect(eraser.y, groundY - teacherReleaseHeight);
        expect(teacher.attackCooldown, teacherAttackCooldown);
        expect(game.hearts, maxHeroHearts);
        await capture(selected, '03_suelta');

        await tick(24);
        expect(frame(teacher).row, TeacherPose.recovery.index);
        await capture(selected, '04_recuperacion');
        await tick(45);
        expect(game.hearts, maxHeroHearts - 1);
        expect(teacher.x, position);

        final dodged = reset(selected, 140);
        await tick(39);
        expect(dodged.launched, isTrue);
        await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
        await tick(30);
        expect(game.hero.y, lessThan(groundY - 60));
        await tick(43);
        expect(game.hearts, maxHeroHearts);

        final target = reset(selected, 125);
        await tick(10);
        expect(target.launched, isTrue);
        final asset = selected == 0 ? 'ball' : 'comb';
        final button = find.byWidgetPredicate((w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName == 'assets/images/$asset.png' &&
            w.width == 41);
        for (var hit = 1; hit <= 3; hit++) {
          await tester.tap(button);
          expect((game.shots as List<Projectile>).single.kind, asset);
          for (var i = 0; i < 32 && target.hits < hit; i++) {
            await tick();
          }
          expect(target.hits, hit);
          expect(target.launched, isFalse);
          if (hit < 3) {
            expect(frame(target).row, TeacherPose.hit.index);
            if (hit == 1) await capture(selected, '05_impacto');
            await tick(45);
            expect(target.defeated, isFalse);
            expect(game.shots, isEmpty);
          }
        }
        expect(game.hearts, maxHeroHearts);
        expect(target.defeated, isTrue);
        expect(frame(target), (row: TeacherPose.defeat.index, column: 0));
        await tick(13);
        await capture(selected, '06_caida');
        await tick(20);
        expect(frame(target), (row: TeacherPose.defeat.index, column: 3));
        await capture(selected, '07_derrota');
      }
    } finally {
      semantics.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  }, timeout: const Timeout(Duration(minutes: 5)));
}
