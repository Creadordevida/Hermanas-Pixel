// Capturas REALES del motor Flutter: animal aislado, cinco poses por especie.
// No son imágenes generadas ni fotografías del APK; sirven para auditoría de
// escala, anclaje y fotogramas usando el mismo StagePainter que el juego.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/main.dart';

Future<ui.Image> _loadSheet(String creature) async {
  final data = await rootBundle.load('assets/images/enemies_hifi/${creature}_sheet.png');
  final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  try {
    return (await codec.getNextFrame()).image;
  } finally {
    codec.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Rata y gato: 10 poses renderizadas por StagePainter real',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 450));
    final boundaryKey = GlobalKey();
    final sheets = <String, ui.Image>{};
    for (final creature in ['rat', 'cat']) {
      sheets[creature] = await tester.runAsync(() => _loadSheet(creature))
          ?? (throw StateError('No carga hoja $creature'));
    }
    try {
      for (final creature in ['rat', 'cat']) {
        for (var pose = 0; pose < 5; pose++) {
          final foe = Enemy(0, creature, 400)..facing = 1;
          double time = .15;
          if (pose == 1) foe.t = .18;
          if (pose == 2) foe.t = .35;
          if (pose == 3) foe.stunned = 1;
          if (pose == 4) foe.deathAt = 0;

          final painter = StagePainter(
            images: {'enemy_${creature}_sheet': sheets[creature]!},
            stage: 0, cameraX: 0, time: time, lastAttackTime: -10,
            hero: Character(140), otherSister: Character(200), father: Character(70),
            showFamily: false, selected: 0,
            obstacles: const <Obstacle>[], platforms: const <Rect>[],
            coins: const <Offset>[], collected: const <int>{},
            enemies: [foe], shots: const <Projectile>[], particlesUntil: -10,
          );
          await tester.pumpWidget(Directionality(
            textDirection: TextDirection.ltr,
            child: RepaintBoundary(
              key: boundaryKey,
              child: SizedBox(width: 800, height: 450,
                child: CustomPaint(painter: painter)),
            ),
          ));
          await tester.pump(const Duration(milliseconds: 50));
          final boundary = boundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
          expect(boundary.debugNeedsPaint, false);

          final result = await tester.runAsync<int>(() async {
            final image = await boundary.toImage(pixelRatio: 1.0)
                .timeout(const Duration(seconds: 20));
            try {
              final rgba = await image.toByteData(format: ui.ImageByteFormat.rawRgba)
                  .timeout(const Duration(seconds: 20));
              final png = await image.toByteData(format: ui.ImageByteFormat.png)
                  .timeout(const Duration(seconds: 20));
              if (rgba == null || png == null) throw StateError('No se renderizo $creature/$pose');
              final pixels = rgba.buffer.asUint8List();
              final colors = <int>{};
              // Área del enemigo, incluyendo pose en impacto y tumbado.
              for (var y = 260; y < 397; y++) {
                for (var x = 290; x < 520; x++) {
                  final offset = (y * image.width + x) * 4;
                  final red = pixels[offset], green = pixels[offset + 1], blue = pixels[offset + 2];
                  if (red == 121 && green == 169 && blue == 213) continue;
                  colors.add((red << 16) | (green << 8) | blue);
                }
              }
              final file = File('qa/rendered_from_flutter/criatura_${creature}_$pose.png');
              await file.parent.create(recursive: true)
                  .timeout(const Duration(seconds: 10));
              await file.writeAsBytes(png.buffer.asUint8List(), flush: true)
                  .timeout(const Duration(seconds: 20));
              return colors.length;
            } finally {
              image.dispose();
            }
          });
          expect(result, isNotNull);
          expect(result!, greaterThan(80),
            reason: '$creature pose $pose parece vacío o excesivamente plano en Flutter');
        }
      }
    } finally {
      for (final image in sheets.values) image.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  });
}
