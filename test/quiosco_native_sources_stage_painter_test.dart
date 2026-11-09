// QA ONLY: actual StagePainter showing five distinct native-scale source images.
// This does NOT certify joins or cover the 37,440px world; normal game unchanged.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';

Future<ui.Image> load(String path) async {
  final bytes = await File(path).readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  try { return (await codec.getNextFrame()).image; }
  finally { codec.dispose(); }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Real StagePainter, five separate native Quiosco sources', (tester) async {
    SharedPreferences.setMockInitialValues({});
    const folder='qa/quiosco_inbox/';
    const names=<String>[
      'fachadas_teatro_nativas_2172x390_candidate.webp',
      'fachadas_poniente_nativas_2172x390_candidate.webp',
      'fachadas_comercios_nativas_2172x390_candidate.webp',
      'fachadas_galeria_nativas_2172x390_candidate.webp',
      'fachadas_oriente_nativas_2172x390_candidate.webp',
    ];
    final imgs=<ui.Image>[];
    for(final name in names) {
      final im=await tester.runAsync(() => load('$folder$name'));
      expect(im,isNotNull);
      expect(im!.width,2172);
      expect(im.height,390);
      imgs.add(im);
    }
    final recorder=ui.PictureRecorder();
    final canvas=ui.Canvas(recorder);
    for(var i=0;i<imgs.length;i++) {
      canvas.drawImage(imgs[i],ui.Offset((i*2172).toDouble(),0),ui.Paint());
    }
    final picture=recorder.endRecording();
    final candidate=await picture.toImage(10860,390);
    picture.dispose();
    for(final im in imgs) { im.dispose(); }
    final boundaryKey=GlobalKey();
    final gameKey=GlobalKey();
    const worldXs=<double>[700,2040,2390,4220,4700,6480,6800,8900,9400,10200];
    try {
      await tester.binding.setSurfaceSize(const Size(1000,450));
      for(final x in worldXs) {
        await tester.pumpWidget(MaterialApp(home:RepaintBoundary(
          key:boundaryKey,
          child:HermanasGame(key:gameKey,qaStage:3,qaWorldX:x,
            qaQuioscoPrototype:candidate),
        )));
        var ready=false;
        for(var attempt=0;attempt<400;attempt++) {
          await tester.runAsync(() async =>
            Future<void>.delayed(const Duration(milliseconds:125)));
          await tester.pump(const Duration(milliseconds:40));
          if(find.textContaining('ERROR AL CARGAR RECURSOS').evaluate().isNotEmpty) {
            throw StateError('Game failed loading candidate at $x');
          }
          if(find.byType(CircularProgressIndicator).evaluate().isEmpty) {
            ready=true; break;
          }
        }
        expect(ready,isTrue,reason:'StagePainter not ready at x=$x');
        await tester.pump(const Duration(milliseconds:100));
        final painters=tester.widgetList<CustomPaint>(find.byType(CustomPaint))
          .where((w)=>w.painter is StagePainter &&
            (w.painter! as StagePainter).stage==3 &&
            identical((w.painter! as StagePainter).qaQuioscoPrototype,candidate));
        expect(painters,isNotEmpty,reason:'Not authentic StagePainter at $x');
        final boundary=boundaryKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
        expect(boundary.debugNeedsPaint,isFalse);
        await tester.runAsync(() async {
          final frame=await boundary.toImage(pixelRatio:1);
          try {
            final bytes=await frame.toByteData(format:ui.ImageByteFormat.png);
            if(bytes==null) throw StateError('Empty capture at $x');
            final out=File('qa-output/quiosco_native_stagepainter/stage3_native_${x.toInt()}.png');
            await out.parent.create(recursive:true);
            await out.writeAsBytes(bytes.buffer.asUint8List(
              bytes.offsetInBytes,bytes.lengthInBytes),flush:true);
            if(await out.length()<10000) throw StateError('Tiny real capture at $x');
            print('REAL_STAGEPAINTER_NATIVE_SOURCE ${out.path}');
          } finally { frame.dispose(); }
        });
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
      candidate.dispose();
    }
  });
}
