// Controlled StagePainter QA: verify all 96 candidate atlas poses render
// as distinct successive silhouettes at the game's 9 fps selector cadence.
// These controlled captures are not an Android gameplay video or art sign-off.
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';
import 'package:hermanas_aventura/arga_crab_behavior.dart';
import 'package:hermanas_aventura/arga_fisher_behavior.dart';
import 'package:hermanas_aventura/arga_boy_behavior.dart';
import 'package:hermanas_aventura/arga_trout_behavior.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final cases = <(String, double, int, int, int, int)>[
    ('crab', 230, 310, 250, 450, 395),
    ('fisher', 1110, 475, 160, 760, 430),
    ('boy', 1850, 485, 155, 745, 435),
    ('trout', 790, 470, 205, 730, 400),
  ];
  for (final entry in cases) {
    final (kind, camera, x0, y0, x1, y1) = entry;
    testWidgets('all 24 real Arga $kind StagePainter frames differ in-row',
        (tester) async {
      expect(const bool.fromEnvironment('TWC_ARGA_ATLAS_QA'), isTrue);
      SharedPreferences.setMockInitialValues({});
      await tester.binding.setSurfaceSize(const Size(1000, 450));
      final key = GlobalKey();
      final captureKey = GlobalKey();
      try {
        await tester.pumpWidget(MaterialApp(home: RepaintBoundary(
          key: captureKey,
          child: HermanasGame(key: key, qaStage: 7, qaWorldX: camera),
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
        expect(game.images['arga_${kind}_atlas'], isNotNull);
        final poses = switch (kind) {
          'crab' => ArgaCrabPose.values,
          'fisher' => ArgaFisherPose.values,
          'boy' => ArgaBoyPose.values,
          _ => ArgaTroutPose.values,
        };
        var checked = 0;
        for (final pose in poses) {
          int? previousHash;
          for (var frame = 0; frame < 4; frame++) {
            game.setState(() {
              if (kind == 'crab') {
                game.argaCrab.pose = pose;
                game.argaCrab.elapsed = frame / 9.0;
              } else if (kind == 'fisher') {
                game.argaFisher.pose = pose;
                game.argaFisher.elapsed = frame / 9.0;
              } else if (kind == 'boy') {
                game.argaBoy.pose = pose;
                game.argaBoy.elapsed = frame / 9.0;
              } else {
                game.argaTrout.pose = pose;
                game.argaTrout.y = pose == ArgaTroutPose.leap ? 340.0 : 417.0;
                game.argaTrout.elapsed = frame / 9.0;
              }
            });
            await tester.pump();
            final boundary = captureKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
            expect(boundary.debugNeedsPaint, isFalse);
            final image = await boundary.toImage(pixelRatio: 1);
            try {
              final bytes = await image.toByteData(
                  format: ui.ImageByteFormat.rawRgba);
              expect(bytes, isNotNull);
              final rgba = bytes!.buffer.asUint8List();
              var hash = 2166136261;
              for (var y = y0; y < y1; y++) {
                for (var x = x0; x < x1; x++) {
                  final offset = (y * 1000 + x) * 4;
                  for (var channel = 0; channel < 3; channel++) {
                    hash = ((hash ^ rgba[offset + channel]) * 16777619)
                        & 0xffffffff;
                  }
                }
              }
              if (previousHash != null) {
                expect(hash, isNot(previousHash),
                    reason: '$kind $pose frames ${frame - 1} and $frame '
                        'should produce different pixels in real render');
              }
              previousHash = hash;
              checked++;
            } finally { image.dispose(); }
          }
        }
        expect(checked, 24);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.binding.setSurfaceSize(null);
      }
    }, timeout: const Timeout(Duration(minutes: 8)));
  }
}
