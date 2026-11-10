// Ayuntamiento 1: authentic Flutter baseline before artistic replacement.
// These captures are evidence, not artwork nor proof of final quality.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Ayuntamiento baseline 5 sectors 3 Android ratios', (tester) async {
    SharedPreferences.setMockInitialValues({});
    const sizes=<Size>[Size(800,450),Size(975,450),Size(1000,450)];
    const positions=<double>[1600,8500,15100,18500,27300,34900];
    final boundaryKey=GlobalKey();
    final gameKey=GlobalKey();
    try {
      for (final size in sizes) {
        await tester.binding.setSurfaceSize(size);
        await tester.pumpWidget(MaterialApp(home:RepaintBoundary(
          key:boundaryKey,child:HermanasGame(
            key:gameKey,qaStage:1,qaWorldX:2000))));
        await tester.pump(const Duration(milliseconds:150));
        for (final x in positions) {
          await tester.pumpWidget(MaterialApp(home:RepaintBoundary(
            key:boundaryKey,child:HermanasGame(
              key:gameKey,qaStage:1,qaWorldX:x))));
          var ready=false;
          for(var n=0;n<400;n++) {
            await tester.runAsync(()=>Future<void>.delayed(
              const Duration(milliseconds:125)));
            await tester.pump(const Duration(milliseconds:40));
            if(find.textContaining('ERROR AL CARGAR RECURSOS').evaluate().isNotEmpty) {
              throw StateError('Ayuntamiento loading failed');
            }
            if(find.byType(CircularProgressIndicator).evaluate().isEmpty) {
              ready=true; break;
            }
          }
          expect(ready,isTrue,reason:'Assets never ready');
          await tester.pump(const Duration(milliseconds:100));
          expect(find.byWidgetPredicate((w)=>w is CustomPaint &&
            w.painter is StagePainter &&
            (w.painter! as StagePainter).stage==1),findsOneWidget);
          final boundary=boundaryKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;
          expect(boundary.debugNeedsPaint,isFalse);
          final name='${size.width.toInt()}x450_${x.toInt()}';
          await tester.runAsync(() async {
            final frame=await boundary.toImage(pixelRatio:1);
            try {
              final data=await frame.toByteData(format:ui.ImageByteFormat.png);
              if(data==null)throw StateError('No PNG: $name');
              final file=File('qa/ayuntamiento_rc7_flutter/baseline_$name.png');
              await file.parent.create(recursive:true);
              await file.writeAsBytes(data.buffer.asUint8List(
                data.offsetInBytes,data.lengthInBytes),flush:true);
              if(await file.length()<10000)throw StateError('Tiny PNG $name');
              print('REAL_AYUNTAMIENTO_BASELINE $name');
            } finally {frame.dispose();}
          });
        }
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  });
}
