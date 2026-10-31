// Genuine Flutter StagePainter evidence for the approved school artwork.
// Captures five school rooms and two joins; never builds an Android APK.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';
import 'package:hermanas_aventura/interiors_parallax_twc.dart';

Future<void> captureSchool(WidgetTester tester, GlobalKey key, String name) async {
  // RepaintBoundary.toImage cannot be called while its current frame needs paint.
  await tester.pump(const Duration(milliseconds: 100));
  final render = key.currentContext?.findRenderObject();
  expect(render, isA<RenderRepaintBoundary>(), reason: 'Missing boundary: $name');
  final boundary = render! as RenderRepaintBoundary;
  expect(boundary.size.width, closeTo(1000, 1));
  expect(boundary.size.height, closeTo(450, 1));
  expect(boundary.debugNeedsPaint, isFalse, reason: 'Unpainted room: $name');

  final activeSchool = tester.widgetList<CustomPaint>(find.byType(CustomPaint))
      .where((c) => c.painter is StagePainter &&
          (c.painter! as StagePainter).stage == 6);
  expect(activeSchool, isNotEmpty, reason: 'No real school StagePainter: $name');

  // Both rasterization and real filesystem operations need the real async
  // zone. Keep all of them inside runAsync (not just toImage/toByteData).
  final result = await tester.runAsync<({int bytes, int width, int height})>(() async {
    ui.Image? image;
    try {
      print('SCHOOL_QA_RENDER_START $name');
      image = await boundary.toImage(pixelRatio: 1.0)
          .timeout(const Duration(seconds: 30));
      print('SCHOOL_QA_RENDER_DONE $name: ${image.width}x${image.height}');
      final png = await image.toByteData(format: ui.ImageByteFormat.png)
          .timeout(const Duration(seconds: 30));
      if (png == null) throw StateError('No pixels returned: $name');
      print('SCHOOL_QA_PNG_DONE $name: ${png.lengthInBytes} bytes');
      final file = File('qa/school_hifi_flutter/$name.png');
      await file.parent.create(recursive: true)
          .timeout(const Duration(seconds: 10));
      await file.writeAsBytes(
        png.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes),
        flush: true,
      ).timeout(const Duration(seconds: 20));
      final bytes = await file.length().timeout(const Duration(seconds: 10));
      print('REAL_FLUTTER_SCHOOL_CAPTURE $name: $bytes bytes');
      return (bytes: bytes, width: image.width, height: image.height);
    } catch (error) {
      print('SCHOOL_QA_CAPTURE_ERROR $name: $error');
      rethrow;
    } finally {
      image?.dispose();
    }
  });
  expect(result, isNotNull, reason: 'runAsync did not complete: $name');
  final screenshot = result!;
  expect(screenshot.width, 1000, reason: 'Invalid school screenshot width');
  expect(screenshot.height, 450, reason: 'Invalid school screenshot height');
  expect(screenshot.bytes, greaterThan(10000), reason: 'Empty school screenshot');
}

Future<void> waitForSchoolAssets(WidgetTester tester) async {
  for (var i = 0; i < 400; i++) {
    await tester.runAsync(() =>
        Future<void>.delayed(const Duration(milliseconds: 125)));
    await tester.pump(const Duration(milliseconds: 40));
    if (find.textContaining('ERROR AL CARGAR RECURSOS').evaluate().isNotEmpty) {
      throw StateError('The game could not load the actual school PNGs');
    }
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
  }
  throw StateError('School assets did not become ready');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Approved school: 5 rooms, 2 transitions, 2 parallax frames', (tester) async {
    expect(schoolHifiArtworkEnabled, isTrue);
    expect(interiorSchoolRoomTypeTWC(0, 0), 0);
    expect(interiorSchoolRoomTypeTWC(0, 1), 4);
    expect(interiorSchoolRoomTypeTWC(0, 4), 3);
    expect(interiorSchoolRoomTypeTWC(1, 0), 1);
    expect(interiorSchoolRoomTypeTWC(2, 0), 2);
    SharedPreferences.setMockInitialValues({});
    const locations = <String, double>{
      '01_pasillo': 500,
      '02_taquillas': 1350,
      '03_biblioteca': 3880,
      '04_aula_pupitres': 11000,
      '05_informatica': 26000,
      '06_paso_a_aula': 10525,
      '07_paso_a_informatica': 25525,
      // Same physical room, camera +60: architectural walls move 1:1 while
      // only outside the windows moves at the approved .30/.56 speeds.
      '08_pasillo_movimiento_60': 560,
      '09_biblioteca_movimiento_60': 3940,
    };
    await tester.binding.setSurfaceSize(const Size(1000, 450));
    final boundaryKey = GlobalKey();
    final gameKey = GlobalKey();
    try {
      var first = true;
      for (final entry in locations.entries) {
        print('SCHOOL_QA_SCENE_START ${entry.key} at ${entry.value}');
        // Preserve the real game State/cache across room changes. The previous
        // test unintentionally recreated the game after every screenshot.
        await tester.pumpWidget(MaterialApp(home: RepaintBoundary(
          key: boundaryKey,
          child: HermanasGame(key: gameKey, qaStage: 6, qaWorldX: entry.value),
        )));
        if (first) {
          await waitForSchoolAssets(tester);
          first = false;
        }
        await tester.pump(const Duration(milliseconds: 150));
        await captureSchool(tester, boundaryKey, entry.key);
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  });
}
