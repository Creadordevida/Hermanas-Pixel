// Images made by the real StagePainter; NOT an APK screenshot or mockup.
// Exercises original illustrated PNG assets and the actual world-size pivots.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/main.dart';

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
   try {
     for(final kind in cases.keys) {
       final frames=(kind=='referee' || kind=='breakdancer')?6:5;
       for(var frame=0;frame<frames;frame++) {
         art['enemy_${kind}_$frame']=await tester.runAsync(
           () => _load('assets/images/enemies/${kind}_$frame.png'))
           ?? (throw StateError('No se cargó $kind/$frame'));
       }
     }
     const states=['idle','patrol','windup','attack','hit','defeated'];
     for(final caseEntry in cases.entries) {
       for(var pose=0;pose<states.length;pose++) {
         final kind=caseEntry.key;
         final foe=Enemy(0,kind,385)..facing=1;
         // Selection is driven by the original Enemy fields used in gameplay.
         if(pose==1)foe.lastRenderedX=foe.x-12;
         if(pose==2 || pose==3) {
           foe.launched=true;
           foe.t=pose==2?.24:.52;
         }
         if(pose==4)foe.stunned=.45;
         if(pose==5)foe.deathAt=.35;
         final repaint=GlobalKey();
         await tester.pumpWidget(Directionality(
           textDirection:TextDirection.ltr,
           child:RepaintBoundary(key:repaint,
             child:SizedBox(width:800,height:450,
               child:CustomPaint(painter:StagePainter(
                 images:art,stage:caseEntry.value,cameraX:0,
                 time:.8,lastAttackTime:-10,hero:Character(140),
                 otherSister:Character(195),father:Character(70),
                 showFamily:false,selected:0,
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
               'qa/rendered_from_flutter/classic_${kind}_${states[pose]}.png');
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
