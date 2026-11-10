// Four controlled StagePainter atlas poses during an airborne trout leap.
// Physics/trajectory are covered by the separate behavior and render tests.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';
import 'package:hermanas_aventura/arga_trout_behavior.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Arga trout atlas leap has four distinct real drawn frames',
      (tester) async {
    expect(const bool.fromEnvironment('TWC_ARGA_ATLAS_QA'), isTrue);
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1000, 450));
    final key = GlobalKey();
    final imageKey = GlobalKey();
    try {
      await tester.pumpWidget(MaterialApp(home: RepaintBoundary(
        key: imageKey,
        child: HermanasGame(key: key, qaStage: 7, qaWorldX: 790),
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
      expect(game.images['arga_trout_atlas'], isNotNull);
      final regions = <List<int>>[];
      for (var frame = 0; frame < 4; frame++) {
        game.setState(() {
          game.argaTrout.pose = ArgaTroutPose.leap;
          game.argaTrout.y = 340.0; // Hold trajectory constant to isolate pose.
          game.argaTrout.elapsed = frame / 9.0;
        });
        await tester.pump();
        final boundary = imageKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
        expect(boundary.debugNeedsPaint, isFalse);
        await tester.runAsync(() async {
          final picture = await boundary.toImage(pixelRatio: 1);
          try {
            final raw = await picture.toByteData(format: ui.ImageByteFormat.rawRgba);
            expect(raw, isNotNull);
            final pixels = raw!.buffer.asUint8List();
            final roi = <int>[];
            for (var y = 205; y < 400; y++) {
              for (var x = 470; x < 730; x++) {
                final p = (y * 1000 + x) * 4;
                roi.addAll(pixels.sublist(p, p + 4));
              }
            }
            regions.add(roi);
            final png = await picture.toByteData(format: ui.ImageByteFormat.png);
            expect(png, isNotNull);
            final file = File('qa/arga_rc7_flutter/trout_pose_frame_$frame.png');
            await file.parent.create(recursive: true);
            await file.writeAsBytes(png!.buffer.asUint8List(), flush: true);
            expect(await file.length(), greaterThan(10000));
          } finally { picture.dispose(); }
        });
      }
      for (var i = 1; i < regions.length; i++) {
        expect(listEquals(regions[i], regions[i - 1]), isFalse,
            reason: 'Trout source atlas leap frames must visibly change');
      }
      // Capture six atlas states with correct water/air anchor for visual QA.
      for (final pose in ArgaTroutPose.values) {
        game.setState(() {
          game.argaTrout.pose = pose;
          game.argaTrout.y = pose == ArgaTroutPose.leap ? 340.0 : 417.0;
          game.argaTrout.elapsed =
              pose == ArgaTroutPose.defeated ? 3 / 9.0 : 1 / 9.0;
        });
        await tester.pump();
        final boundary = imageKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
        expect(boundary.debugNeedsPaint, isFalse);
        await tester.runAsync(() async {
          final picture = await boundary.toImage(pixelRatio: 1);
          try {
            final data = await picture.toByteData(format: ui.ImageByteFormat.png);
            expect(data, isNotNull);
            final file = File('qa/arga_rc7_flutter/trout_state_${pose.name}.png');
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
