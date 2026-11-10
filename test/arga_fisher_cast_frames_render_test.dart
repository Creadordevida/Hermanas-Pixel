// Four authentic controlled StagePainter frames; not an Android playthrough.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';
import 'package:hermanas_aventura/arga_fisher_behavior.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Arga fisher casts four visually distinct atlas frames',
      (tester) async {
    expect(const bool.fromEnvironment('TWC_ARGA_ATLAS_QA'), isTrue);
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1000, 450));
    final gameKey = GlobalKey();
    final boundaryKey = GlobalKey();
    try {
      await tester.pumpWidget(MaterialApp(home: RepaintBoundary(
        key: boundaryKey,
        child: HermanasGame(key: gameKey, qaStage: 7, qaWorldX: 1110),
      )));
      final dynamic game = gameKey.currentState;
      var ready = false;
      for (var i = 0; i < 300; i++) {
        await tester.runAsync(() =>
            Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pump(const Duration(milliseconds: 16));
        expect(game.loadError, isNull);
        if (game.resourcesReady == true) { ready = true; break; }
      }
      expect(ready, isTrue);
      expect(game.images['arga_fisher_atlas'], isNotNull);
      final regions = <List<int>>[];
      for (var frame = 0; frame < 4; frame++) {
        game.setState(() {
          game.argaFisher.pose = ArgaFisherPose.cast;
          game.argaFisher.elapsed = frame / 9.0;
        });
        await tester.pump();
        final boundary = boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
        expect(boundary.debugNeedsPaint, isFalse);
        await tester.runAsync(() async {
          final snapshot = await boundary.toImage(pixelRatio: 1);
          try {
            final raw = await snapshot.toByteData(format: ui.ImageByteFormat.rawRgba);
            expect(raw, isNotNull);
            final rgba = raw!.buffer.asUint8List();
            final region = <int>[];
            // The camera follows the sister: the fisherman is right of centre.
            for (var y = 160; y < 430; y++) {
              for (var x = 475; x < 760; x++) {
                final pos = (y * 1000 + x) * 4;
                region.addAll(rgba.sublist(pos, pos + 4));
              }
            }
            regions.add(region);
            final png = await snapshot.toByteData(format: ui.ImageByteFormat.png);
            expect(png, isNotNull);
            final file = File('qa/arga_rc7_flutter/fisher_cast_frame_$frame.png');
            await file.parent.create(recursive: true);
            await file.writeAsBytes(png!.buffer.asUint8List(), flush: true);
            expect(await file.length(), greaterThan(10000));
          } finally { snapshot.dispose(); }
        });
      }
      for (var i = 1; i < regions.length; i++) {
        expect(listEquals(regions[i - 1], regions[i]), isFalse,
            reason: 'Fishing rod cast must change in fisher region');
      }
      // Capture all six atlas rows in the genuine painter for visual QA.
      // Defeat uses its terminal frame rather than its mid-fall transition.
      for (final pose in ArgaFisherPose.values) {
        game.setState(() {
          game.argaFisher.pose = pose;
          game.argaFisher.elapsed =
              pose == ArgaFisherPose.defeated ? 3 / 9.0 : 1 / 9.0;
        });
        await tester.pump();
        final boundary = boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
        expect(boundary.debugNeedsPaint, isFalse);
        await tester.runAsync(() async {
          final picture = await boundary.toImage(pixelRatio: 1);
          try {
            final data = await picture.toByteData(format: ui.ImageByteFormat.png);
            expect(data, isNotNull);
            final file = File('qa/arga_rc7_flutter/fisher_pose_${pose.name}.png');
            await file.parent.create(recursive: true);
            await file.writeAsBytes(data!.buffer.asUint8List(), flush: true);
            expect(await file.length(), greaterThan(10000));
          } finally { picture.dispose(); }
        });
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  }, timeout: const Timeout(Duration(minutes: 4)));
}
