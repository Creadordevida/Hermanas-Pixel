// Actual Flutter StagePainter captures: both girls, everyday outfits and
// protected thematic outfits, seven motion phases plus a platform shadow.
// No generated concept art may be substituted for these captures.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/main.dart';

Future<ui.Image> _load(String path) async {
  final data = await rootBundle.load(path);
  final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  try { return (await codec.getNextFrame()).image; }
  finally { codec.dispose(); }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('28 fases del salto y 2 sombras de plataforma capturadas de Flutter',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800,450));
    final assets=<String,ui.Image>{};
    for (final costume in [false,true]) {
      for (final role in ['futbolista','bailarina']) {
        for (final pose in ['idle_0','walk_0','walk_1','jump_0','attack_0']) {
          if (!costume && pose=='attack_0') continue;
          final folder=costume?'outfits':'frames';
          final prefix=costume?'costume_':'';
          final path='assets/images/$folder/${role}_$pose.png';
          assets['$prefix${role}_$pose'] = await tester.runAsync(() => _load(path))
            ?? (throw StateError('Falta $path'));
        }
      }
    }

    Future<void> capture(String name, Character heroine, int stage, int selected,
        {List<Rect> platforms=const []}) async {
      final key=GlobalKey();
      final painter=StagePainter(
        images:assets,stage:stage,cameraX:0,time:2,
        lastAttackTime:-10,
        hero:heroine,otherSister:Character(130),father:Character(75),
        showFamily:false,selected:selected,
        obstacles:const <Obstacle>[],platforms:platforms,
        coins:const <Offset>[],collected:const <int>{},
        enemies:const <Enemy>[],shots:const <Projectile>[],
        particlesUntil:-10,
      );
      await tester.pumpWidget(Directionality(textDirection:TextDirection.ltr,
        child:RepaintBoundary(key:key,
          child:SizedBox(width:800,height:450,child:CustomPaint(painter:painter)))));
      await tester.pump(const Duration(milliseconds:35));
      final boundary=key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      expect(boundary.debugNeedsPaint,false);
      final bytes=await tester.runAsync<int>(() async {
        final image=await boundary.toImage(pixelRatio:1.0)
            .timeout(const Duration(seconds:20));
        try {
          final png=await image.toByteData(format:ui.ImageByteFormat.png)
              .timeout(const Duration(seconds:20));
          if(png==null)throw StateError('Captura vacía: $name');
          final file=File('qa/rendered_from_flutter/salto_$name.png');
          await file.parent.create(recursive:true)
              .timeout(const Duration(seconds:10));
          await file.writeAsBytes(png.buffer.asUint8List(),flush:true)
              .timeout(const Duration(seconds:20));
          return file.length().timeout(const Duration(seconds:10));
        } finally { image.dispose(); }
      });
      expect(bytes,isNotNull);
      expect(bytes!,greaterThan(2500),reason:'Sprite vacío: $name');
      debugPrint('QA_SALTO_CAPTURA_OK $name ($bytes bytes)');
    }

    try {
      for (final costume in [false,true]) {
        for (var selected=0;selected<2;selected++) {
          final name='${selected==0?'miren':'sara'}_${costume?'traje':'calle'}';
          final chapter=costume ? (selected==0?4:5) : 0;
          for (final phase in ['idle','takeoff','rising','apex','falling','impact','recovery']) {
            final y=switch(phase){
              'takeoff'=>366.0,'rising'=>308.0,'apex'=>295.0,
              'falling'=>325.0,_=>groundY,
            };
            final vy=switch(phase){
              'takeoff'=>-420.0,'rising'=>-230.0,'apex'=>0.0,
              'falling'=>285.0,_=>0.0,
            };
            final c=Character(400,y:y)..facing=1..vy=vy
              ..grounded=['idle','impact','recovery'].contains(phase)
              ..jumpedAt=phase=='takeoff'?1.96:1
              ..landedAt=phase=='impact'?1.95:phase=='recovery'?1.85:-100
              ..landingStrength=1;
            await capture('${name}_$phase',c,chapter,selected);
          }
          if(!costume) {
            final c=Character(400,y:235)..grounded=false..vy=0;
            await capture('${name}_sombra_plataforma',c,0,selected,
              platforms:[const Rect.fromLTWH(330,280,140,16)]);
          }
        }
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
      for (final image in assets.values) image.dispose();
    }
  });
}
