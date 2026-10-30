// Real game/render verification: 16:9, 19.5:9 and 20:9.
// Saves genuine Flutter screenshots of title, map and all seven levels.
// No mock or fabricated images. Must run with all generated game assets.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';
import 'package:hermanas_aventura/game_viewport_twc.dart';

Future<void> waitReady(WidgetTester tester) async {
  for(var k=0;k<400;k++) {
    await tester.runAsync(() =>
      Future<void>.delayed(const Duration(milliseconds:250)));
    await tester.pump(const Duration(milliseconds:30));
    if(find.textContaining('ERROR AL CARGAR RECURSOS').evaluate().isNotEmpty) {
      throw StateError('App reported asset loading error');
    }
    if(find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
  }
  throw StateError('Resources not loaded after extended timeout');
}

Future<void> capture(WidgetTester tester,GlobalKey key,String name,
    Size physical,{bool expectStage=false, int stage=0}) async {
  await tester.pump(const Duration(milliseconds:90));
  final obj=key.currentContext!.findRenderObject()
      as RenderRepaintBoundary;
  expect(obj.size.width,closeTo(physical.width,.1));
  expect(obj.size.height,closeTo(physical.height,.1));
  if(expectStage) {
    final paints=tester.widgetList<CustomPaint>(find.byType(CustomPaint))
      .where((c)=>c.painter is StagePainter &&
                      (c.painter! as StagePainter).stage==stage);
    expect(paints,isNotEmpty,reason:'Real StagePainter stage $stage missing');
    final painterSize=tester.getSize(find.byWidgetPredicate(
      (w)=>w is CustomPaint && w.painter is StagePainter &&
        (w.painter! as StagePainter).stage==stage).first);
    expect(painterSize.width,
      closeTo(GameViewportTWC(physical).worldWidth,.6));
    expect(painterSize.height,closeTo(450,.6));
  }
  final ok=await tester.runAsync<bool>(() async {
    final img=await obj.toImage(pixelRatio:1);
    try {
      final png=await img.toByteData(format:ui.ImageByteFormat.png);
      final rgba=await img.toByteData(format:ui.ImageByteFormat.rawRgba);
      if(png==null||rgba==null)return false;
      // Screens MUST fill both outer edges with visible, non-black artwork.
      final b=rgba.buffer.asUint8List(rgba.offsetInBytes,rgba.lengthInBytes);
      var leftColors=<int>{},rightColors=<int>{};
      final width=img.width,height=img.height;
      for(var y=height~/5;y<height*4~/5;y+=13) {
        for(var x=4;x<42;x+=9) {
          final a=(y*width+x)*4;
          leftColors.add((b[a]>>4)*256+(b[a+1]>>4)*16+(b[a+2]>>4));
          final c=(y*width+width-x-1)*4;
          rightColors.add((b[c]>>4)*256+(b[c+1]>>4)*16+(b[c+2]>>4));
        }
      }
      final file=File('qa/fullscreen_rc5_flutter/$name.png');
      await file.parent.create(recursive:true);
      await file.writeAsBytes(png.buffer.asUint8List(),flush:true);
      print('FULLSCREEN_EVIDENCE: $name, pixels=${img.width}x${img.height}, '
          'leftColors=${leftColors.length},rightColors=${rightColors.length}');
      return leftColors.length>3&&rightColors.length>3 &&
          (await file.length())>1500;
    } finally {img.dispose();}
  });
  expect(ok,isTrue,reason:'Blank side bars / no drawing: $name');
}

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Real title map and all seven chapters: full-screen ratios',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final boundary=GlobalKey();
    final game=GlobalKey();
    var first=true;
    try {
      final targets=<({String label,Size size,int? stage,bool map})>[
        (label:'title_16_9',size:const Size(800,450),stage:null,map:false),
        (label:'map_16_9',size:const Size(800,450),stage:null,map:true),
        (label:'chapter1_16_9',size:const Size(800,450),stage:0,map:false),
        (label:'title_19_5_9',size:const Size(975,450),stage:null,map:false),
        (label:'map_19_5_9',size:const Size(975,450),stage:null,map:true),
        (label:'chapter1_19_5_9',size:const Size(975,450),stage:0,map:false),
        (label:'title_20_9',size:const Size(1000,450),stage:null,map:false),
        (label:'map_20_9',size:const Size(1000,450),stage:null,map:true),
        for(var stage=0;stage<7;stage++)
          (label:'chapter${stage+1}_20_9',
             size:const Size(1000,450),stage:stage,map:false),
      ];
      for(final target in targets) {
        await tester.binding.setSurfaceSize(target.size);
        await tester.pumpWidget(MaterialApp(home:RepaintBoundary(
          key:boundary,
          child:HermanasGame(key:game,qaStage:target.stage,
                             qaMap:target.map,qaWorldX:target.stage==null?null:450),
        )));
        if(first){await waitReady(tester);first=false;}
        await capture(tester,boundary,target.label,target.size,
          expectStage:target.stage!=null,stage:target.stage??0);
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  });
}
