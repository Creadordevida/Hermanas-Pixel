// QA-only: actual Flutter StagePainter frames for the experimental Río Arga.
// The normal seven-chapter map remains unchanged.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';
import 'package:hermanas_aventura/arga_platform_rules.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Río Arga initial 20:9 real StagePainter panorama and platforms',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1000, 450));
    final gameKey=GlobalKey();
    final boundaryKey=GlobalKey();
    try {
      const positions=<double>[130,340,810,1250,1950,12000,25000,35900];
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
        expect(game.stage,7);
        expect(game.argaCourse.allGapsReachable,isTrue);
        final painters=tester.widgetList<CustomPaint>(find.byType(CustomPaint))
          .where((p)=>p.painter is StagePainter &&
            (p.painter! as StagePainter).stage==7);
        expect(painters,isNotEmpty,reason:'No real Arga StagePainter');
        expect(game.images['arga_far'],isNotNull);
        expect(game.images['arga_mid'],isNotNull);
        expect(game.images['arga_far_wild'],isNotNull);
        expect(game.images['arga_mid_wild'],isNotNull);
        expect(game.images['arga_far_mill'],isNotNull);
        expect(game.images['arga_mid_mill'],isNotNull);
        expect(game.images['arga_art'],isNull,
          reason:'Superseded single panorama must not be decoded');
        expect(game.images['arga_supports'],isNotNull);
        expect(game.images['arga_supports_v2'],isNotNull);
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
        if(x==positions.last) {
          // Actual game ticker: moving log carries the hero while grounded.
          game.hero=Character(1060,y:365);
          game.argaSupport=ArgaCourse.surfaces[4];
          game.argaSupportSince=game.time;
          game.hero.grounded=true;
          game.leftHeld=false;game.rightHeld=false;
          final logStart=game.hero.x;
          await tester.pump(const Duration(milliseconds:33));
          expect(game.hero.x,isNot(logStart),
              reason:'Moving log must carry the grounded hero');

          // Occupied sinking rock must physically lower the hero.
          game.hero=Character(1520,y:365);
          game.argaSupport=ArgaCourse.surfaces[6];
          game.argaSupportSince=game.time-1.5;
          game.hero.grounded=true;
          await tester.pump(const Duration(milliseconds:33));
          expect(game.hero.y,greaterThan(365),
              reason:'Sinking rock must descend after warning');

          // One river fall consumes exactly one heart and respawns safely.
          game.hero=Character(260,y:440);
          game.hero.grounded=false;
          game.argaSupport=null;
          game.hearts=5;
          game.checkpointX=ArgaCourse.startX;
          await tester.pump(const Duration(milliseconds:33));
          expect(game.hearts,4);
          expect(game.hero.x,const ArgaCourse().checkpointBefore(260));
          expect(game.hero.y,ArgaCourse.surfaces.first.top);
          expect(game.screen,Screen.playing);

          // Later checkpoints can have different heights from the first bank.
          final varied=ArgaCourse.allSurfaces.firstWhere(
            (s)=>s.checkpoint && s.top!=ArgaCourse.surfaces.first.top);
          game.hero=Character(varied.x+varied.width+20,y:440);
          game.hero.grounded=false;
          game.argaSupport=null;
          game.hearts=5;
          await tester.pump(const Duration(milliseconds:33));
          expect(game.hero.x,varied.x+55);
          expect(game.hero.y,varied.top,
              reason:'Checkpoint respawn must use its own height');
        }
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  },timeout:const Timeout(Duration(minutes:5)));
}
