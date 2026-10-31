// Genuine Flutter StagePainter evidence for the approved dance artwork.
// Captures five dance rooms and two joins; never builds an Android APK.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';
import 'package:hermanas_aventura/interiors_parallax_twc.dart';

Future<void> captureDance(WidgetTester tester, GlobalKey key, String name,
    {int expectedCharacter = 0}) async {
  // RepaintBoundary.toImage cannot be called while its current frame needs paint.
  await tester.pump(const Duration(milliseconds: 100));
  final render = key.currentContext?.findRenderObject();
  expect(render, isA<RenderRepaintBoundary>(), reason: 'Missing boundary: $name');
  final boundary = render! as RenderRepaintBoundary;
  expect(boundary.size.width, closeTo(1000, 1));
  expect(boundary.size.height, closeTo(450, 1));
  expect(boundary.debugNeedsPaint, isFalse, reason: 'Unpainted room: $name');

  final activeDance = tester.widgetList<CustomPaint>(find.byType(CustomPaint))
      .where((c) => c.painter is StagePainter &&
          (c.painter! as StagePainter).stage == 5);
  expect(activeDance, isNotEmpty, reason: 'No real dance StagePainter: $name');
  expect((activeDance.first.painter! as StagePainter).selected, expectedCharacter,
      reason: 'Wrong protagonist rendered in $name');

  // Both rasterization and real filesystem operations need the real async
  // zone. Keep all of them inside runAsync (not just toImage/toByteData).
  final result = await tester.runAsync<({int bytes, int width, int height})>(() async {
    ui.Image? image;
    try {
      print('DANCE_QA_RENDER_START $name');
      image = await boundary.toImage(pixelRatio: 1.0)
          .timeout(const Duration(seconds: 30));
      print('DANCE_QA_RENDER_DONE $name: ${image.width}x${image.height}');
      final png = await image.toByteData(format: ui.ImageByteFormat.png)
          .timeout(const Duration(seconds: 30));
      if (png == null) throw StateError('No pixels returned: $name');
      print('DANCE_QA_PNG_DONE $name: ${png.lengthInBytes} bytes');
      final file = File('qa/dance_hifi_flutter/$name.png');
      await file.parent.create(recursive: true)
          .timeout(const Duration(seconds: 10));
      await file.writeAsBytes(
        png.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes),
        flush: true,
      ).timeout(const Duration(seconds: 20));
      final bytes = await file.length().timeout(const Duration(seconds: 10));
      print('REAL_FLUTTER_DANCE_CAPTURE $name: $bytes bytes');
      return (bytes: bytes, width: image.width, height: image.height);
    } catch (error) {
      print('DANCE_QA_CAPTURE_ERROR $name: $error');
      rethrow;
    } finally {
      image?.dispose();
    }
  });
  expect(result, isNotNull, reason: 'runAsync did not complete: $name');
  final screenshot = result!;
  expect(screenshot.width, 1000, reason: 'Invalid dance screenshot width');
  expect(screenshot.height, 450, reason: 'Invalid dance screenshot height');
  expect(screenshot.bytes, greaterThan(10000), reason: 'Empty dance screenshot');
}

Future<void> waitForDanceAssets(WidgetTester tester) async {
  for (var i = 0; i < 400; i++) {
    await tester.runAsync(() =>
        Future<void>.delayed(const Duration(milliseconds: 125)));
    await tester.pump(const Duration(milliseconds: 40));
    if (find.textContaining('ERROR AL CARGAR RECURSOS').evaluate().isNotEmpty) {
      throw StateError('The game could not load the actual dance PNGs');
    }
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
  }
  throw StateError('Dance assets did not become ready');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Approved dance: 5 rooms, 2 transitions, 2 parallax frames', (tester) async {
    expect(danceFiveSceneArtworkEnabled, isTrue);
    expect(interiorDanceRoomsTWC.length, 5);
    expect(interiorDanceFiveSceneEdgesTWC.length, 6);
    SharedPreferences.setMockInitialValues({});
    const locations = <String, double>{
      '01_recepcion': 500,
      '02_pasillo': 7500,
      '03_vestuario': 14600,
      '04_estudio': 22100,
      '05_escenario': 30000,
      '06_transicion_recepcion_pasillo': 7000,
      '07_transicion_estudio_escenario': 29000,
      '08_pasillo_camara_60': 7560,
      '09_estudio_camara_60': 22160,
      '10_sara_estudio': 22100,
      '11_sara_vestuario': 14600,
    };
    await tester.binding.setSurfaceSize(const Size(1000, 450));
    final boundaryKey = GlobalKey();
    final gameKey = GlobalKey();
    try {
      var first = true;
      for (final entry in locations.entries) {
        print('DANCE_QA_SCENE_START ${entry.key} at ${entry.value}');
        // Preserve the real game State/cache across room changes. The previous
        // test unintentionally recreated the game after every screenshot.
        final sara = entry.key.startsWith('10_') || entry.key.startsWith('11_');
        await tester.pumpWidget(MaterialApp(home: RepaintBoundary(
          key: boundaryKey,
          child: HermanasGame(key: gameKey, qaStage: 5,
              qaWorldX: entry.value, qaSelected: sara ? 1 : 0),
        )));
        if (first) {
          await waitForDanceAssets(tester);
          first = false;
        }
        await tester.pump(const Duration(milliseconds: 150));
        await captureDance(tester, boundaryKey, entry.key,
            expectedCharacter: sara ? 1 : 0);
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  });
}
