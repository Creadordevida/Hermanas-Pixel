// 38 genuine StagePainter captures centred on every Ayuntamiento panel seam.
// Used to inspect architectural continuity, not to approve the artwork.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('all 38 Ayuntamiento RC7 joins are painted in genuine Flutter',
      (tester) async {
    expect(twcAyuntamientoRC7ArtworkEnabled, isTrue);
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1000,450));
    final boundaryKey=GlobalKey();
    final gameKey=GlobalKey();
    try {
      for (var edge=1;edge<twcAyuntamientoRC7TileCount;edge++) {
        final seamWorldX=edge*twcAyuntamientoRC7TileWidth;
        // cameraX = hero.x - viewW*0.41; place the join at screen x=500.
        final heroWorldX=seamWorldX-90;
        await tester.pumpWidget(MaterialApp(home:RepaintBoundary(
          key:boundaryKey,
          child:HermanasGame(key:gameKey,qaStage:1,qaWorldX:heroWorldX),
        )));
        if (edge==1) {
          var ready=false;
          for (var attempt=0;attempt<400;attempt++) {
            await tester.runAsync(() => Future<void>.delayed(
              const Duration(milliseconds:125)));
            await tester.pump(const Duration(milliseconds:40));
            if (find.textContaining('ERROR AL CARGAR RECURSOS').evaluate().isNotEmpty) {
              throw StateError('Game failed to load Ayuntamiento assets');
            }
            if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
              ready=true;break;
            }
          }
          expect(ready,isTrue);
        }
        await tester.pump(const Duration(milliseconds:120));
        expect(find.byWidgetPredicate((w)=>w is CustomPaint &&
          w.painter is StagePainter &&
          (w.painter! as StagePainter).stage==1),findsOneWidget);
        final boundary=boundaryKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
        expect(boundary.debugNeedsPaint,isFalse);
        final name='join_${edge.toString().padLeft(2,'0')}';
        await tester.runAsync(() async {
          final raster=await boundary.toImage(pixelRatio:1);
          try {
            final raw=await raster.toByteData(format:ui.ImageByteFormat.png);
            if (raw==null) throw StateError('Empty render: $name');
            final file=File('qa/ayuntamiento_rc7_joins/$name.png');
            await file.parent.create(recursive:true);
            await file.writeAsBytes(raw.buffer.asUint8List(
              raw.offsetInBytes,raw.lengthInBytes),flush:true);
            if(await file.length()<10000) throw StateError('Small PNG: $name');
          } finally {raster.dispose();}
        });
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  });
}
