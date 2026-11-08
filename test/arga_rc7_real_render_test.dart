// QA-only: actual Flutter StagePainter frames for the experimental Río Arga.
// The normal seven-chapter map remains unchanged.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Río Arga initial 20:9 real StagePainter panorama and platforms',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1000, 450));
    final gameKey=GlobalKey();
    final boundaryKey=GlobalKey();
    try {
      const positions=<double>[130,340,810,1250,1950];
      for(final x in positions) {
        await tester.pumpWidget(MaterialApp(home:RepaintBoundary(
          key:boundaryKey,
          child:HermanasGame(key:gameKey,qaStage:7,qaWorldX:x),
        )));
        final dynamic game=gameKey.currentState;
        var ready=false;
        for(var i=0;i<300;i++) {
          await tester.runAsync(() =>
            Future<void>.delayed(const Duration(milliseconds:50)));
          await tester.pump(const Duration(milliseconds:16));
          expect(game.loadError,isNull);
          if(game.resourcesReady==true) {ready=true;break;}
        }
        expect(ready,isTrue,reason:'Arga WebP decode failed');
        final painters=tester.widgetList<CustomPaint>(find.byType(CustomPaint))
          .where((p)=>p.painter is StagePainter &&
            (p.painter! as StagePainter).stage==7);
        expect(painters,isNotEmpty,reason:'No real Arga StagePainter');
        expect(game.images['arga_art'],isNotNull);
        expect(game.images['arga_supports'],isNotNull);
        await tester.pump(const Duration(milliseconds:16));
        final boundary=boundaryKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
        expect(boundary.size,const Size(1000,450));
        expect(boundary.debugNeedsPaint,isFalse);
        await tester.runAsync(() async {
          final image=await boundary.toImage(pixelRatio:1);
          try {
            final bytes=await image.toByteData(format:ui.ImageByteFormat.png);
            expect(bytes,isNotNull);
            final file=File('qa/arga_rc7_flutter/qa_${x.toInt()}.png');
            await file.parent.create(recursive:true);
            await file.writeAsBytes(bytes!.buffer.asUint8List(),flush:true);
            expect(await file.length(),greaterThan(10000));
            print('ARGA_STAGEPAINTER_20x9 ${file.path}');
          } finally {image.dispose();}
        });
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  },timeout:const Timeout(Duration(minutes:5)));
}
