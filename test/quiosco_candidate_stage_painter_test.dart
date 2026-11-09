// Real STAGEPAINTER test with real Miren/Sara game layer and opt-in candidate.
// This is a LOCAL 5,782px test slice, NOT the full 37,440px level or final APK.
// Default builds always have qaQuioscoPrototype=null and cannot show this art.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Qu iosco authentic StagePainter with opt-in original PNG',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final input=File('qa-output/quiosco_six_sector_candidate/panorama_prototipo_6_sectores.png');
    final image=await tester.runAsync(() async {
      final bytes=await input.readAsBytes();
      final codec=await ui.instantiateImageCodec(bytes);
      try {
        final frame=await codec.getNextFrame();
        return frame.image;
      } finally {codec.dispose();}
    });
    expect(image,isNotNull);
    final candidate=image!;
    expect(candidate.width,5782);
    expect(candidate.height,390);
    final boundaryKey=GlobalKey();
    final gameKey=GlobalKey();
    const size=Size(1000,450);
    const worldXs=<double>[1200,1850,2450,3250,4250,5350];
    try {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(MaterialApp(home:RepaintBoundary(
        key:boundaryKey,
        child:HermanasGame(key:gameKey,qaStage:3,qaWorldX:1100,
          qaQuioscoPrototype:candidate),
      )));
      await tester.pump(const Duration(milliseconds:120));
      for(final x in worldXs) {
        await tester.pumpWidget(MaterialApp(home:RepaintBoundary(
          key:boundaryKey,
          child:HermanasGame(key:gameKey,qaStage:3,qaWorldX:x,
            qaQuioscoPrototype:candidate),
        )));
        var ready=false;
        for(var attempt=0;attempt<400;attempt++) {
          await tester.runAsync(() async {
            await Future<void>.delayed(const Duration(milliseconds:125));
          });
          await tester.pump(const Duration(milliseconds:40));
          if(find.textContaining('ERROR AL CARGAR RECURSOS').evaluate().isNotEmpty) {
            throw StateError('Game asset load failure at $x');
          }
          if(find.byType(CircularProgressIndicator).evaluate().isEmpty) {
            ready=true;break;
          }
        }
        expect(ready,isTrue,reason:'Not ready at world X=$x');
        await tester.pump(const Duration(milliseconds:100));
        final painters=tester.widgetList<CustomPaint>(find.byType(CustomPaint))
          .where((widget)=>widget.painter is StagePainter &&
             (widget.painter! as StagePainter).stage==3 &&
             identical((widget.painter! as StagePainter).qaQuioscoPrototype,candidate));
        expect(painters,isNotEmpty,reason:'Not the actual StagePainter!');
        final boundary=boundaryKey.currentContext!.findRenderObject()
             as RenderRepaintBoundary;
        expect(boundary.debugNeedsPaint,isFalse);
        await tester.runAsync(() async {
          final frame=await boundary.toImage(pixelRatio:1);
          try {
            final bytes=await frame.toByteData(format:ui.ImageByteFormat.png);
            if(bytes==null)throw StateError('Empty Flutter capture');
            final file=File('qa-output/quiosco_candidate_stagepainter/stage3_candidate_${x.toInt()}.png');
            await file.parent.create(recursive:true);
            await file.writeAsBytes(bytes.buffer.asUint8List(
                 bytes.offsetInBytes,bytes.lengthInBytes),flush:true);
            if(await file.length()<10000)throw StateError('Tiny Flutter capture');
            print('REAL_STAGEPAINTER_QUIOSCO_CANDIDATE ${file.path}');
          } finally {frame.dispose();}
        });
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
      candidate.dispose();
    }
  });
}
