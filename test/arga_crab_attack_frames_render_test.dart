// Controlled real StagePainter frames. These are NOT Android gameplay captures.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show listEquals;
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
        child: HermanasGame(key: key, qaStage: 7, qaWorldX: 230),
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
      final List<List<int>> crabPixels = [];
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
            // Compare only crab's screen area, excluding animated HUD/coins.
            final raw = await picture.toByteData(format: ui.ImageByteFormat.rawRgba);
            expect(raw, isNotNull);
            final rgba = raw!.buffer.asUint8List();
            final region = <int>[];
            for (var y = 250; y < 395; y++) {
              for (var x = 310; x < 450; x++) {
                final offset = (y * 1000 + x) * 4;
                region.addAll(rgba.sublist(offset, offset + 4));
              }
            }
            crabPixels.add(region);
            final data = await picture.toByteData(format: ui.ImageByteFormat.png);
            expect(data, isNotNull);
            final bytes = data!.buffer.asUint8List().toList();
            final file = File('qa/arga_rc7_flutter/crab_pinch_frame_$frame.png');
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes, flush: true);
            expect(await file.length(), greaterThan(10000));
          } finally { picture.dispose(); }
        });
      }
      for (var frame = 1; frame < crabPixels.length; frame++) {
        expect(listEquals(crabPixels[frame], crabPixels[frame - 1]), isFalse,
            reason: 'Consecutive real pinch poses must differ inside crab bounds');
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  }, timeout: const Timeout(Duration(minutes: 4)));
}
