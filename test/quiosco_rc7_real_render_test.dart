// Authentic Flutter raster QA for RC7 Quiosco; DOES NOT build an APK.
// Execute only after 39 WebP resources and pubspec entry are committed:
// flutter test --dart-define=TWC_QUIOSCO_RC7_ART=true test/quiosco_rc7_real_render_test.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('RC7 Quiosco: 18 actual StagePainter captures with camera +60',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    const sizes = <Size>[Size(800,450), Size(975,450), Size(1000,450)];
    // Cameras must be away from level edges: at worldX=400 and a 1000px\n    // viewport cameraX clamps to zero and moves only 50px, not 60px.\n    // Use x=1200/1260 for a true 60px move in all three ratios.
    const positions = <double>[1200, 1260, 9200, 18200, 18260, 35700];
    final key = GlobalKey();
    final game = GlobalKey();
    try {
      for (final size in sizes) {
        await tester.binding.setSurfaceSize(size);
        // The game uses a shared viewW written by LayoutBuilder. Prime the
        // actual viewport BEFORE didUpdateWidget computes cameraX for a new
        // world position, otherwise the first frame of a new aspect ratio
        // uses the previous screen width and camera-motion QA is misleading.
        await tester.pumpWidget(MaterialApp(home:RepaintBoundary(
          key:key,child:HermanasGame(key:game,qaStage:3,qaWorldX:1100))));
        await tester.pump(const Duration(milliseconds:120));
        for (final x in positions) {
          await tester.pumpWidget(MaterialApp(home: RepaintBoundary(key:key,
            child:HermanasGame(key:game,qaStage:3,qaWorldX:x))));
          var ready = false;
          for (var i=0;i<400;i++) {
            await tester.runAsync(() =>
              Future<void>.delayed(const Duration(milliseconds:125)));
            await tester.pump(const Duration(milliseconds:40));
            if (find.textContaining('ERROR AL CARGAR RECURSOS').evaluate().isNotEmpty) {
              throw StateError('Quiosco resource failure at $x');
            }
            if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
              ready=true;break;
            }
          }
          expect(ready,isTrue,reason:'Assets not ready');
          await tester.pump(const Duration(milliseconds:100));
          final painters = tester.widgetList<CustomPaint>(find.byType(CustomPaint))
            .where((p) => p.painter is StagePainter &&
              (p.painter! as StagePainter).stage == 3);
          expect(painters,isNotEmpty,reason:'Not an actual Quiosco StagePainter');
          final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          expect(boundary.debugNeedsPaint,isFalse);
          final tag='${size.width.toInt()}x${size.height.toInt()}_${x.toInt()}';
          await tester.runAsync(() async {
            final rendered = await boundary.toImage(pixelRatio:1);
            try {
              final bytes = await rendered.toByteData(format:ui.ImageByteFormat.png);
              if (bytes == null) throw StateError('Empty capture: $tag');
              final file=File('qa/quiosco_rc7_flutter/$tag.png');
              await file.parent.create(recursive:true);
              await file.writeAsBytes(bytes.buffer.asUint8List(
                bytes.offsetInBytes,bytes.lengthInBytes),flush:true);
              if (await file.length()<10000) throw StateError('Tiny PNG: $tag');
              print('REAL_FLUTTER_QUIOSCO_CAPTURE $tag');
            } finally { rendered.dispose(); }
          });
        }
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  },skip:!twcQuioscoRC7ArtworkEnabled);
}
