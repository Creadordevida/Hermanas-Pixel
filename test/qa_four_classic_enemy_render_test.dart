// Images made by the real StagePainter; NOT an APK screenshot or mockup.
// Exercises original illustrated PNG assets and the actual world-size pivots.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/main.dart';
import 'package:hermanas_aventura/interiors_parallax_twc.dart';

Future<ui.Image> _load(String path) async {
  final bytes=await rootBundle.load(path);
  final codec=await ui.instantiateImageCodec(bytes.buffer.asUint8List());
  try {return (await codec.getNextFrame()).image;}
  finally {codec.dispose();}
}

void main() {
 TestWidgetsFlutterBinding.ensureInitialized();
 testWidgets('Los cuatro enemigos clásicos se dibujan en StagePainter REAL',
     (tester) async {
   await tester.binding.setSurfaceSize(const Size(800,450));
   final cases=<String,int>{
     'breakdancer':5,'bully':6,'referee':4,'rival':4,
   };
   final art=<String,ui.Image>{};
   final backdrops=<String,String>{
     'scene_2':'assets/images/level_estafeta.png',
     'mid_2':'assets/images/mid/stage_2.png',
     'ground_2':'assets/images/ground/stage_2.png',
     'ground_5':'assets/images/ground/stage_5.png',
     'costume_bailarina_idle_0':'assets/images/outfits/bailarina_idle_0.png',
     'scene_3':'assets/images/level_plaza_castillo.png',
     'mid_3':'assets/images/mid/stage_3.png',
     'ground_3':'assets/images/ground/stage_3.png',
     'football_far_twc':
         'assets/images/chapter45/football_parallax/montanas_ciudad_deportiva_ciclo.png',
     'football_mid_twc':
         'assets/images/chapter45/football_parallax/arbolado_deportivo_ciclo.png',
     'ground_4':'assets/images/ground/stage_4.png',
     'interior_school_far':
         'assets/images/interiors_parallax/school/exterior_lejano_ciclo.png',
     'interior_school_mid':
         'assets/images/interiors_parallax/school/arbolado_tras_ventanas_ciclo.png',
     'interior_school_passage':
         'assets/images/interiors_parallax/school/marco_paso.png',
     'ground_6':schoolHifiArtworkEnabled
         ? 'assets/images/ground/stage_6_hifi.png'
         : 'assets/images/ground/stage_6.png',
     'futbolista_idle_0':'assets/images/frames/futbolista_idle_0.png',
     'bailarina_idle_0':'assets/images/frames/bailarina_idle_0.png',
     'costume_futbolista_idle_0':'assets/images/outfits/futbolista_idle_0.png',
   };
   for(var index=0;index<6;index++) {
     backdrops['football_near_tile_$index']=
         'assets/images/chapter45/football_parallax/near_world_tiles/near_$index.png';
   }
   // Rival clásico nuevo: el QA debe pintar el atlas realmente integrado,
   // nunca aprobar accidentalmente una captura de los seis PNG antiguos.
   art['enemy_rival_player_atlas']=await tester.runAsync(
      () => _load('assets/images/enemies_new/rival_player_atlas.png'))
      ?? (throw StateError('Falta el atlas definitivo del jugador rival'));
   for(var room=0;room<3;room++) {
     for(var variant=0;variant<9;variant++) {
       backdrops['interior_school_z${room}_panel_$variant']=
           'assets/images/interiors_parallax/school/z${room}_panel_$variant.png';
     }
   }

   for(var i=0;i<interiorDanceFiveSceneFilesTWC.length;i++) {
     backdrops['dance_hifi_$i']=interiorDanceFiveSceneAssetTWC(i);
   }
   for(final name in ['far','mid','passage']) {
     backdrops['interior_dance_$name']=interiorAssetTWC('dance',
       name=='far'?'exterior_lejano_ciclo':name=='mid'?'arbolado_tras_ventanas_ciclo':'marco_paso');
   }
   for(var zone=0;zone<3;zone++) {
     for(var variant=0;variant<interiorVariantsPerRoomTWC;variant++) {
       backdrops['interior_dance_z${zone}_panel_$variant']=
         interiorPanelAssetTWC('dance',zone,variant);
     }
   }
   try {
     for(final entry in backdrops.entries) {
       art[entry.key]=await tester.runAsync(() => _load(entry.value))
         ?? (throw StateError('Missing game background ${entry.value}'));
     }
     for(final kind in cases.keys) {
       const frames=6;
       for(var frame=0;frame<frames;frame++) {
         art['enemy_${kind}_$frame']=await tester.runAsync(
           () => _load('assets/images/enemies/${kind}_$frame.png'))
           ?? (throw StateError('No se cargó $kind/$frame'));
       }
     }
     const states=['idle','patrol','windup','attack','hit','defeated'];
     for(final caseEntry in cases.entries) {
       for(var sample=0;sample<24;sample++) {
         final pose=sample~/4,phase=sample%4;
         final kind=caseEntry.key;
         final foe=Enemy(0,kind,385)..facing=1..t=phase/7;
         // Selection is driven by the original Enemy fields used in gameplay.
         if(pose==1)foe.lastRenderedX=foe.x-12;
         if(pose==2 || pose==3) {
           foe.t=pose==2 ? phase*.035 : .14+phase*.08;
           if(kind=='rival' || kind=='bully') {
             foe.meleeWarning=.3;
           } else {
             foe.launched=true;
             foe.t=pose==2 ? phase*.10 : .38+phase*.13;
           }
         }
         if(pose==4)foe.stunned=.45;
         if(pose==5)foe.deathAt=.8-phase*.12;
         final repaint=GlobalKey();
         await tester.pumpWidget(Directionality(
           textDirection:TextDirection.ltr,
           child:RepaintBoundary(key:repaint,
             child:SizedBox(width:800,height:450,
               child:CustomPaint(painter:StagePainter(
                 images:art,stage:caseEntry.value,cameraX:0,
                 time:.8,lastAttackTime:-10,
                 hero:Character((kind=='rival' || kind=='bully') &&
                   (pose==2 || pose==3)?420:140),
                 otherSister:Character(195),father:Character(70),
                 showFamily:true,selected:pose%2,
                 obstacles:const <Obstacle>[],platforms:const <Rect>[],
                 coins:const <Offset>[],collected:const <int>{},
                 enemies:[foe],shots:const <Projectile>[],
                 particlesUntil:-10,
               )))),
         ));
         await tester.pump(const Duration(milliseconds:50));
         final boundary=repaint.currentContext!.findRenderObject()
            as RenderRepaintBoundary;
         expect(boundary.debugNeedsPaint,false);
         final length=await tester.runAsync<int>(() async {
           final frame=await boundary.toImage(pixelRatio:1)
               .timeout(const Duration(seconds:20));
           try {
             final png=await frame.toByteData(format:ui.ImageByteFormat.png)
                 .timeout(const Duration(seconds:20));
             if(png==null)throw StateError('Empty image: $kind/${states[pose]}');
             final file=File(
               'qa/rendered_from_flutter/classic_${kind}_${sample.toString().padLeft(2,'0')}.png');
             await file.parent.create(recursive:true);
             await file.writeAsBytes(png.buffer.asUint8List(),flush:true);
             return file.length();
           }finally {frame.dispose();}
         });
         expect(length,greaterThan(2000),
           reason:'StagePainter rendered a blank frame for $kind/${states[pose]}');
       }
     }
   }finally {
     await tester.pumpWidget(const SizedBox.shrink());
     await tester.binding.setSurfaceSize(null);
     for(final img in art.values)img.dispose();
   }
 });
}
