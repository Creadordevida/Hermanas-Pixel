// Real Flutter StagePainter captures, NEVER AI mock-ups or claimed APK screenshots.
// The CI artifact must be inspected before artistically approving #9 / #11.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/main.dart';

Future<ui.Image> _asset(String filename) async {
  final bytes = await rootBundle.load(filename);
  final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
  try {
    return (await codec.getNextFrame()).image;
  } finally {
    codec.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Tres perros / ocho estados y paloma / ocho cuadros de vuelo REAL',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 450));
    final sprites = <String, ui.Image>{};
    final poses = ['idle','walk','alert','run','bite','hit','stunned','defeated'];
    for (final breed in ['brown','dalmatian','doberman']) {
      for (final pose in poses) {
        final path = breed == 'brown'
          ? 'assets/images/dog/$pose.png'
          : 'assets/images/dog/$breed/$pose.png';
        sprites['dog_${breed}_$pose'] = await tester.runAsync(() => _asset(path))
          ?? (throw StateError('Falta $path'));
      }
    }
    sprites['pigeon_flight_sheet'] = await tester.runAsync(() =>
      _asset('assets/images/enemies_hifi/pigeon_flight_sheet.png'))
      ?? (throw StateError('Falta la hoja de vuelo'));
    for (var i=0; i<5; i++) {
      sprites['enemy_pigeon_$i'] = await tester.runAsync(() =>
        _asset('assets/images/enemies/pigeon_$i.png'))
        ?? (throw StateError('Falta paloma en suelo $i'));
    }

    Future<void> capture(Enemy animal, String label) async {
      final key = GlobalKey();
      final painter = StagePainter(
        images: sprites, stage: 0, cameraX: 0, time: .1,
        lastAttackTime: -10,
        hero: Character(140), otherSister: Character(180), father: Character(70),
        showFamily: false, selected: 0,
        obstacles: const <Obstacle>[], platforms: const <Rect>[],
        coins: const <Offset>[], collected: const <int>{},
        enemies: [animal], shots: const <Projectile>[], particlesUntil: -10,
      );
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(key: key,
          child: SizedBox(width: 800,height: 450,child: CustomPaint(painter: painter))),
      ));
      await tester.pump(const Duration(milliseconds: 40));
      final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      expect(boundary.debugNeedsPaint, false);
      final bytes = await tester.runAsync<int>(() async {
        final rendered = await boundary.toImage(pixelRatio: 1)
            .timeout(const Duration(seconds: 20));
        try {
          final data = await rendered.toByteData(format: ui.ImageByteFormat.png)
              .timeout(const Duration(seconds: 20));
          if (data == null) throw StateError('Captura vacía $label');
          final file = File('qa/rendered_from_flutter/animal_$label.png');
          await file.parent.create(recursive: true)
              .timeout(const Duration(seconds: 10));
          await file.writeAsBytes(data.buffer.asUint8List(), flush: true)
              .timeout(const Duration(seconds: 20));
          return await file.length().timeout(const Duration(seconds: 10));
        } finally {
          rendered.dispose();
        }
      });
      if (bytes == null) throw StateError('Captura vacía $label');
      expect(bytes, greaterThan(2500), reason: 'Imagen sin detalles: $label');
      debugPrint('QA_FAUNA_CAPTURA_OK $label ($bytes bytes)');
    }

    try {
      for (final breed in ['brown','dalmatian','doberman']) {
        for (final pose in poses) {
          final foe = Enemy(0,'dog_$breed',400)..facing=1
            ..animalMode=pose;
          if(pose=='hit') foe.stunned=.6;
          if(pose=='stunned') foe.stunned=.2;
          if(pose=='defeated') foe.deathAt=0;
          await capture(foe,'dog_${breed}_$pose');
        }
      }
      await capture(Enemy(0,'pigeon',400)..facing=1,'pigeon_perch');
      for (var frame=0;frame<8;frame++) {
        final bird = Enemy(0,'pigeon',400)..facing=1
          ..flightAltitude=82;
        if(frame<4) {
          bird.animalMode='flap';
          bird.t=frame/10.0;
        } else if(frame==4) {
          bird.animalMode='glide';
        } else if(frame==5) {
          bird.animalMode='dive';
        } else if(frame==6) {
          bird.stunned=.6;
        } else {
          bird.deathAt=0;
        }
        await capture(bird,'pigeon_flight_$frame');
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
      for (final img in sprites.values) img.dispose();
    }
  });
}
