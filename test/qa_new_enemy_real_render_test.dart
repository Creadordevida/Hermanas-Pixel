// Capturas autenticas: exactamente el StagePainter que dibuja el videojuego.
// No son conceptos, montajes, ni capturas de un APK en dispositivo.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/main.dart';
import 'package:hermanas_aventura/interiors_parallax_twc.dart';
import 'package:hermanas_aventura/new_enemy_behaviors.dart';

Future<ui.Image> loadPng(String path) async {
  final data=await rootBundle.load(path);
  final codec=await ui.instantiateImageCodec(data.buffer.asUint8List());
  try {return (await codec.getNextFrame()).image;}
  finally {codec.dispose();}
}

void main() {
 TestWidgetsFlutterBinding.ensureInitialized();
 testWidgets('Seis enemigos nuevos: imagen REAL del motor en su escenario',
     (tester) async {
   await tester.binding.setSurfaceSize(const Size(800,450));
   final kinds=<String,(String,int)>{
     'cleaning_robot':('robot',6),
     'rival_supporter':('supporter',4),
     'tipsy_tourist':('tourist',2),
     'navarre_king':('navarre_king',3),
     'estafeta_bull':('estafeta_bull',2),
     'sanfermin_runner':('sanfermin_runner',2),
   };
   final images=<String,ui.Image>{};
   // Each scene must be painted with the SAME live StagePainter assets that
   // gameplay uses. A new enemy on an empty sky is not valid visual QA.
   final backdrops=<String,String>{
     'scene_2':'assets/images/level_estafeta.png',
     'mid_2':'assets/images/mid/stage_2.png',
     'ground_2':'assets/images/ground/stage_2.png',
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
   for(var room=0;room<3;room++) {
     for(var variant=0;variant<9;variant++) {
       backdrops['interior_school_z${room}_panel_$variant']=
           'assets/images/interiors_parallax/school/z${room}_panel_$variant.png';
     }
   }

   try {
     // Fail early if a level background was not generated: no empty-scene
     // screenshots can be mislabelled as real gameplay illustrations.
     for(final entry in backdrops.entries) {
       images[entry.key]=await tester.runAsync(() => loadPng(entry.value))
           ?? (throw StateError('Falta fondo REAL de juego: ${entry.value}'));
     }
     expect(images.containsKey('football_near_tile_5'),isTrue);
     expect(images.containsKey('interior_school_z2_panel_8'),isTrue);
     for(final pair in kinds.entries) {
       final short=pair.value.$1;
       final key=short=='navarre_king'?'enemy_navarre_king_atlas':
         (short=='estafeta_bull' || short=='sanfermin_runner')?
         'enemy_$short':'enemy_new_$short';
       images[key]=await tester.runAsync(() => loadPng(
         'assets/images/enemies_new/${short}_atlas.png'))
         ?? (throw StateError('No se pudo cargar el atlas REAL $short'));
     }
     for(final pair in kinds.entries) {
       final kind=pair.key,stage=pair.value.$2;
       // Six distinct conditions, full scene graphics + StagePainter render:
       // 0 idle, 1 alert, 2 locomotion, 3 attack, 4 hit, 5 defeat.
       for(var sample=0;sample<24;sample++) {
         final pose=sample~/4, phase=sample%4;
         final elapsed=phase/7.0;
         final renderTime=2.0+elapsed;
         final foe=Enemy(0,kind,390)..facing=1
           ..t=elapsed;
         if(foe.newArchetype) {
           final archetype=switch(kind) {
             'cleaning_robot'=>NewEnemyKind.cleaningRobot,
             'rival_supporter'=>NewEnemyKind.rivalSupporter,
             _=>NewEnemyKind.tipsyTourist,
           };
           final motion=NewEnemyMotion(kind:archetype,home:foe.home,x:foe.x);
           motion.pose=switch(pose) {
             0=>NewEnemyPose.idle,
             1=>NewEnemyPose.alert,
             2=>NewEnemyPose.patrol,
             3=>NewEnemyPose.attack,
             4=>NewEnemyPose.hit,
             _=>NewEnemyPose.defeated,
           };
           if(pose==3)motion.windup=motion.attackDelay*(1-phase/3);
           foe.newMotion=motion;
         }
         if(kind=='navarre_king' && pose>=1 && pose<=3) {
           foe.kingAwakeAt=0;
           if(pose==1)foe.kingAwakeAt=renderTime-.2;
           if(pose==3)foe.kingAttackAt=renderTime-elapsed;
         }
         if(kind=='estafeta_bull') {
           if(pose==1)foe.bullWarnedAt=0;
           if(pose==2 || pose==3) {
             foe.launched=true;
             foe.t=pose==2 ? elapsed*.6 : .4+elapsed;
           }
         }
         if(kind=='sanfermin_runner') {
           if(pose==1)foe.runnerWarningAt=renderTime-.1;
           if(pose==3)foe.runnerImpactUntil=renderTime+.2;
         }
         if(pose==4)foe.stunned=.6;
         if(pose==5)foe.deathAt=2.0;
         final key=GlobalKey();
         final painter=StagePainter(
           images:images,stage:stage,cameraX:0,
           time:renderTime,
           lastAttackTime:-10,
           hero:Character(kind=='sanfermin_runner'&&pose==3?320:140),
           otherSister:Character(195),
           father:Character(70),showFamily:true,selected:pose%2,
           obstacles:const <Obstacle>[],platforms:const <Rect>[],
           coins:const <Offset>[],collected:const <int>{},
           enemies:[foe],shots:const <Projectile>[],particlesUntil:-10,
         );
         await tester.pumpWidget(Directionality(
           textDirection:TextDirection.ltr,
           child:RepaintBoundary(key:key,
             child:SizedBox(width:800,height:450,
               child:CustomPaint(painter:painter))),
         ));
         await tester.pump(const Duration(milliseconds:50));
         final boundary=key.currentContext!.findRenderObject()
           as RenderRepaintBoundary;
         expect(boundary.debugNeedsPaint,false);
         final size=await tester.runAsync<int>(() async {
           final frame=await boundary.toImage(pixelRatio:1)
             .timeout(const Duration(seconds:20));
           try {
             final bytes=await frame.toByteData(format:ui.ImageByteFormat.png)
               .timeout(const Duration(seconds:20));
             if(bytes==null)throw StateError('No render $kind/$pose');
             final file=File('qa/rendered_from_flutter/nuevo_${kind}_${sample.toString().padLeft(2,'0')}.png');
             await file.parent.create(recursive:true);
             await file.writeAsBytes(bytes.buffer.asUint8List(),flush:true);
             return await file.length();
           }finally {frame.dispose();}
         });
         expect(size,isNotNull);
         expect(size!,greaterThan(2000),
           reason:'Render de $kind en pose $pose vacio o demasiado sencillo');
       }
     }
   }finally {
     await tester.pumpWidget(const SizedBox.shrink());
     await tester.binding.setSurfaceSize(null);
     for(final image in images.values)image.dispose();
   }
 });
}
