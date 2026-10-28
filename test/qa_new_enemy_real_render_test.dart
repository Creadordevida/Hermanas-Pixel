// Capturas autenticas: exactamente el StagePainter que dibuja el videojuego.
// No son conceptos, montajes, ni capturas de un APK en dispositivo.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/main.dart';

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
   try {
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
       for(var pose=0;pose<4;pose++) {
         final foe=Enemy(0,kind,390)..facing=1
           ..t=pose*.22;
         if(pose==2)foe.stunned=.6;
         if(pose==3)foe.deathAt=0;
         if(kind=='navarre_king' && pose==1)foe.kingAwakeAt=0;
         if(kind=='estafeta_bull' && pose==1)foe.launched=true;
         final key=GlobalKey();
         final painter=StagePainter(
           images:images,stage:stage,cameraX:0,time:.6,
           lastAttackTime:-10,
           hero:Character(140),otherSister:Character(195),
           father:Character(70),showFamily:false,selected:0,
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
             final file=File('qa/rendered_from_flutter/nuevo_${kind}_$pose.png');
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
