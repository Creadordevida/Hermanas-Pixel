// Controlled real StagePainter frames. These are NOT Android gameplay captures.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';
import 'package:hermanas_aventura/arga_crab_behavior.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Arga crab pinch draws four distinct actual atlas frames',
      (tester) async {
    expect(const bool.fromEnvironment('TWC_ARGA_ATLAS_QA'), isTrue,
        reason: 'Enable the candidate atlas explicitly for this QA test');
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1000, 450));
    final key = GlobalKey();
    final boundaryKey = GlobalKey();
    try {
      await tester.pumpWidget(MaterialApp(home: RepaintBoundary(
        key: boundaryKey,
        child: HermanasGame(key: key, qaStage: 7, qaWorldX: 340),
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
      expect(game.images['arga_crab_atlas'], isNotNull);
      final List<List<int>> samples = [];
      for (var frame = 0; frame < 4; frame++) {
        game.setState(() {
          game.argaCrab.pose = ArgaCrabPose.pinch;
          game.argaCrab.elapsed = frame / 9.0;
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
            final bytes = data!.buffer.asUint8List().toList();
            samples.add(bytes);
            final file = File('qa/arga_rc7_flutter/crab_pinch_frame_$frame.png');
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes, flush: true);
            expect(await file.length(), greaterThan(10000));
          } finally { picture.dispose(); }
        });
      }
      for (var frame = 1; frame < samples.length; frame++) {
        expect(samples[frame], isNot(samples[frame - 1]),
            reason: 'Consecutive real pinch renders must differ');
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  }, timeout: const Timeout(Duration(minutes: 4)));
}
