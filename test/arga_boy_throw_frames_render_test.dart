// Four controlled real StagePainter screenshots; not Android gameplay.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';
import 'package:hermanas_aventura/arga_boy_behavior.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Arga boy throws through four visible atlas frames', (tester) async {
    expect(const bool.fromEnvironment('TWC_ARGA_ATLAS_QA'), isTrue);
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1000, 450));
    final key = GlobalKey();
    final captureKey = GlobalKey();
    try {
      await tester.pumpWidget(MaterialApp(home: RepaintBoundary(
        key: captureKey,
        child: HermanasGame(key: key, qaStage: 7, qaWorldX: 1850),
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
      expect(game.images['arga_boy_atlas'], isNotNull);
      final regions = <List<int>>[];
      for (var frame = 0; frame < 4; frame++) {
        game.setState(() {
          game.argaBoy.pose = ArgaBoyPose.throwStone;
          game.argaBoy.elapsed = frame / 9.0;
        });
        await tester.pump();
        final boundary = captureKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
        expect(boundary.debugNeedsPaint, isFalse);
        await tester.runAsync(() async {
          final picture = await boundary.toImage(pixelRatio: 1);
          try {
            final raw = await picture.toByteData(format: ui.ImageByteFormat.rawRgba);
            expect(raw, isNotNull);
            final pixels = raw!.buffer.asUint8List();
            final roi = <int>[];
            for (var y = 155; y < 435; y++) {
              for (var x = 485; x < 745; x++) {
                final p = (y * 1000 + x) * 4;
                roi.addAll(pixels.sublist(p, p + 4));
              }
            }
            regions.add(roi);
            final png = await picture.toByteData(format: ui.ImageByteFormat.png);
            expect(png, isNotNull);
            final file = File('qa/arga_rc7_flutter/boy_throw_frame_$frame.png');
            await file.parent.create(recursive: true);
            await file.writeAsBytes(png!.buffer.asUint8List(), flush: true);
            expect(await file.length(), greaterThan(10000));
          } finally { picture.dispose(); }
        });
      }
      for (var i = 1; i < regions.length; i++) {
        expect(listEquals(regions[i], regions[i - 1]), isFalse,
            reason: 'Stone throw must change visibly in boy region');
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  }, timeout: const Timeout(Duration(minutes: 4)));
}
