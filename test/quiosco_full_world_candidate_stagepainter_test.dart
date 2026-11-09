// QA only: authentic StagePainter in four safe-size windows of the complete
// 37,440px Quiosco candidate. Does NOT install candidate art in the actual game.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';

Future<ui.Image> loadCandidateTile(String path) async {
  final bytes=await File(path).readAsBytes();
  final codec=await ui.instantiateImageCodec(bytes);
  try { return (await codec.getNextFrame()).image; }
  finally { codec.dispose(); }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Quiosco full-world candidate 39 tiles real StagePainter', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final boundaryKey=GlobalKey();
    final gameKey=GlobalKey();
    await tester.binding.setSurfaceSize(const Size(1000,450));
    try {
      for(var batch=0;batch<4;batch++) {
        final first=batch*10;
        final count=batch==3?9:10;
        final frames=<ui.Image>[];
        for(var n=0;n<count;n++) {
          final name='quiosco_${(first+n).toString().padLeft(2,'0')}.webp';
          final im=await tester.runAsync(() => loadCandidateTile(
            'qa-output/quiosco_full_world_candidate/tiles_NOT_ACTIVE/$name'));
          expect(im,isNotNull);
          expect(im!.width,960);
          expect(im.height,390);
          frames.add(im);
        }
        final rec=ui.PictureRecorder();
        final canvas=ui.Canvas(rec);
        for(var n=0;n<count;n++) {
          canvas.drawImage(frames[n],ui.Offset((n*960).toDouble(),0),ui.Paint());
        }
        final p=rec.endRecording();
        final candidate=await p.toImage(count*960,390);
        p.dispose();
        for(final im in frames) { im.dispose(); }
        final last=(count*960-1050).toDouble();
        final positionSet=<double>{0,860,940,1850,2810,3770,4730,
          5690,6650,7610,8000,8300,8400};
        // Every architectural A/B/C join must also be centered in a real
        // StagePainter viewport, not merely clipped near the screenshot edge.
        for(var connector=1;connector<=17;connector++) {
          final local=(connector*2076-500-first*960).toDouble();
          if(local>=0 && local<=last) positionSet.add(local);
        }
        for(final landmarkEdge in <int>[17920,19090]) {
          final local=(landmarkEdge-500-first*960).toDouble();
          if(local>=0 && local<=last) positionSet.add(local);
        }
        final positions=positionSet.where((x)=>x<=last).toList()..sort();
        try {
          for(final local in positions) {
            await tester.pumpWidget(MaterialApp(home:RepaintBoundary(
              key:boundaryKey,
              child:HermanasGame(key:gameKey,qaStage:3,qaWorldX:local,
                qaQuioscoPrototype:candidate),
            )));
            var ready=false;
            for(var attempt=0;attempt<400;attempt++) {
              await tester.runAsync(() async =>
                Future<void>.delayed(const Duration(milliseconds:125)));
              await tester.pump(const Duration(milliseconds:40));
              if(find.textContaining('ERROR AL CARGAR RECURSOS').evaluate().isNotEmpty) {
                throw StateError('Failed StagePainter at ${first*960+local}');
              }
              if(find.byType(CircularProgressIndicator).evaluate().isEmpty) {
                ready=true; break;
              }
            }
            expect(ready,isTrue);
            await tester.pump(const Duration(milliseconds:100));
            final painters=tester.widgetList<CustomPaint>(find.byType(CustomPaint))
              .where((w)=>w.painter is StagePainter &&
                (w.painter! as StagePainter).stage==3 &&
                identical((w.painter! as StagePainter).qaQuioscoPrototype,candidate));
            expect(painters,isNotEmpty);
            final boundary=boundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
            expect(boundary.debugNeedsPaint,isFalse);
            final world=first*960+local.toInt();
            await tester.runAsync(() async {
              final frame=await boundary.toImage(pixelRatio:1);
              try {
                final bytes=await frame.toByteData(format:ui.ImageByteFormat.png);
                if(bytes==null) throw StateError('Missing pixels at $world');
                final file=File('qa-output/quiosco_full_world_candidate/screenshots/real_stagepainter_$world.png');
                await file.parent.create(recursive:true);
                await file.writeAsBytes(bytes.buffer.asUint8List(
                  bytes.offsetInBytes,bytes.lengthInBytes),flush:true);
                expect(await file.length(),greaterThan(10000));
                print('REAL_STAGEPAINTER_QUIOSCO_37440 $world ${file.path}');
              } finally { frame.dispose(); }
            });
          }
        } finally {
          await tester.pumpWidget(const SizedBox.shrink());
          candidate.dispose();
        }
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  });
}
