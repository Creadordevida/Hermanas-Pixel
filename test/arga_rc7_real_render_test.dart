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
import 'package:hermanas_aventura/arga_crab_behavior.dart';
import 'package:hermanas_aventura/arga_fisher_behavior.dart';
import 'package:hermanas_aventura/arga_boy_behavior.dart';
import 'package:hermanas_aventura/arga_trout_behavior.dart';

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
        // QA-only experimental crab: all six user-approved candidate poses
        // must decode, and the active state machine is attached to stage 7.
        for (final pose in ['reposo','caminar','alerta','ataque','impacto','derrota']) {
          expect(game.images['arga_crab_$pose'],isNotNull,
            reason:'Missing independent crab pose $pose');
        }
        expect(game.argaCrab,isNotNull);
        // The approved fisherman candidates are loaded only in Arga QA.
        for (final pose in ['reposo','caminar','alerta','lanzamiento','impacto','derrota']) {
          expect(game.images['arga_fisher_$pose'],isNotNull,
            reason:'Missing independent fisherman pose $pose');
        }
        expect(game.argaFisher,isNotNull);
        for(final pose in ['reposo','correr','alerta','lanzamiento','impacto','derrota']) {
          expect(game.images['arga_boy_$pose'],isNotNull,
            reason:'Missing independent stone thrower pose $pose');
        }
        expect(game.argaBoy,isNotNull);
        for(final pose in ['nado','acelerar','alerta','salto','impacto','derrota']) {
          expect(game.images['arga_trout_$pose'],isNotNull,
            reason:'Missing independent trout pose $pose');
        }
        expect(game.argaTrout,isNotNull);
        // Atlas QA must decode the exact 24-frame sheets that StagePainter
        // selects. No candidate is enabled in a regular gameplay build.
        if (const bool.fromEnvironment('TWC_ARGA_ATLAS_QA')) {
          for (final key in [
            'arga_crab_atlas', 'arga_fisher_atlas',
            'arga_boy_atlas', 'arga_trout_atlas',
          ]) {
            final atlas=game.images[key];
            expect(atlas,isNotNull,reason:'Atlas not decoded: $key');
            expect(atlas!.width,1024,reason:'Unexpected columns: $key');
            expect(atlas.height,1536,reason:'Unexpected rows: $key');
          }
        }

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
        if(x==810) {
          // Capture a REAL offensive trout pose after its warning period;
          // loading six images alone does not prove the leap is ever drawn.
          game.argaTrout.update(.1,game.hero.x,playerVisible:true);
          game.argaTrout.update(.56,game.hero.x,playerVisible:true);
          expect(game.argaTrout.pose,ArgaTroutPose.leap);
          await tester.pump(const Duration(milliseconds:120));
          expect(game.argaTrout.airborne,isTrue);
          final leapBoundary=boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
          expect(leapBoundary.debugNeedsPaint,isFalse);
          await tester.runAsync(() async {
            final leapImage=await leapBoundary.toImage(pixelRatio:1);
            try {
              final bytes=await leapImage.toByteData(format:ui.ImageByteFormat.png);
              expect(bytes,isNotNull);
              final file=File('qa/arga_rc7_flutter/trout_leap_810.png');
              await file.parent.create(recursive:true);
              await file.writeAsBytes(bytes!.buffer.asUint8List(),flush:true);
              expect(await file.length(),greaterThan(10000));
              print('ARGA_TROUT_REAL_LEAP_20x9 ${file.path}');
            } finally {leapImage.dispose();}
          });
        }
        if(x==positions.last) {
          // QA crab must take two legitimate shots and enter its defeat pose.
          expect(game.argaCrabHits,0);
          for(var hit=1;hit<=2;hit++) {
            game.shots.add(Projectile(x:game.argaCrab.x,y:330,vx:0,kind:'ball'));
            await tester.pump(const Duration(milliseconds:33));
            expect(game.argaCrabHits,hit);
          }
          expect(game.argaCrab.pose,ArgaCrabPose.defeated);

          // Real player shots interrupt fisherman and defeat after two hits.
          expect(game.argaFisherHits,0);
          for (var hit=1;hit<=2;hit++) {
            game.shots.add(Projectile(x:game.argaFisher.x,y:307,vx:0,kind:'ball'));
            await tester.pump(const Duration(milliseconds:33));
            expect(game.argaFisherHits,hit);
          }
          expect(game.argaFisher.pose,ArgaFisherPose.defeated);

          // Player projectiles interrupt and defeat the QA stone-thrower.
          expect(game.argaBoyHits,0);
          for(var hit=1;hit<=2;hit++) {
            game.shots.add(Projectile(x:game.argaBoy.x,y:310,vx:0,kind:'ball'));
            await tester.pump(const Duration(milliseconds:33));
            expect(game.argaBoyHits,hit);
          }
          expect(game.argaBoy.pose,ArgaBoyPose.defeated);

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
