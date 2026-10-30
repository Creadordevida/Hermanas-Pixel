// ACTUAL Flutter StagePainter school screenshots, not PIL mock.
// Requires exact 27 PNGs + master in this checkout. No APK.
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';
import 'package:hermanas_aventura/interiors_parallax_twc.dart';

Future<void> picture(WidgetTester tester,GlobalKey key,String name) async {
 final boundary=key.currentContext?.findRenderObject();
 expect(boundary,isA<RenderRepaintBoundary>());
 final object=boundary! as RenderRepaintBoundary;
 expect(object.size.width,closeTo(1000,1));
 expect(object.size.height,closeTo(450,1));
 final stage=tester.widgetList<CustomPaint>(find.byType(CustomPaint))
  .where((x)=>x.painter is StagePainter &&
              (x.painter! as StagePainter).stage==6);
 expect(stage,isNotEmpty,reason:'Capture must use the real school StagePainter');
 final bytes=await tester.runAsync<ByteData?>(() async{
   final img=await object.toImage(pixelRatio:1);
   try{return await img.toByteData(format:ui.ImageByteFormat.png);}
   finally{img.dispose();}
 });
 expect(bytes,isNotNull);
 final file=File('qa/school_hifi_flutter/'+name+'.png');
 await file.parent.create(recursive:true);
 await file.writeAsBytes(bytes!.buffer.asUint8List(),flush:true);
 expect(await file.length(),greaterThan(10000));
 print('REAL_FLUTTER_SCHOOL_CAPTURE '+name);
}

Future<void> waitReady(WidgetTester t) async {
 for(var i=0;i<400;i++){
  await t.runAsync(()=>
    Future<void>.delayed(const Duration(milliseconds:125)));
  await t.pump(const Duration(milliseconds:40));
  if(find.textContaining('ERROR AL CARGAR RECURSOS').evaluate().isNotEmpty){
   throw StateError('Failed to load actual school PNG resources');
  }
  if(find.byType(CircularProgressIndicator).evaluate().isEmpty)return;
 }
 throw StateError('Resource loading timed out');
}

void main(){
 TestWidgetsFlutterBinding.ensureInitialized();
 testWidgets('Five actual school rooms, 20:9, two world transitions',
  (tester) async{
   expect(schoolHifiArtworkEnabled,isTrue);
   expect(interiorSchoolRoomTypeTWC(0,0),0);
   expect(interiorSchoolRoomTypeTWC(0,1),4);
   expect(interiorSchoolRoomTypeTWC(0,4),3);
   expect(interiorSchoolRoomTypeTWC(1,0),1);
   expect(interiorSchoolRoomTypeTWC(2,0),2);
   SharedPreferences.setMockInitialValues({});
   final locations=<String,double>{
     '01_pasillo':500,
     '02_taquillas':1350,
     '03_biblioteca':3880,
     '04_aula_pupitres':11000,
     '05_informatica':26000,
     '06_paso_a_aula':10525,
     '07_paso_a_informatica':25525,
   };
   try{
    await tester.binding.setSurfaceSize(const Size(1000,450));
    // Load the authentic game ONCE: the previous test recreated the entire
    // 130+ PNG image cache seven times and exhausted the 10-minute timeout.
    // Reusing the SAME RenderRepaintBoundary key keeps the live game State,
    // image cache, StagePainter and parallax implementation intact.
    final key=GlobalKey();
    final first=locations.entries.first;
    await tester.pumpWidget(MaterialApp(home:RepaintBoundary(
      key:key,child:HermanasGame(qaStage:6,qaWorldX:first.value))));
    print('SCHOOL_QA: mounted game, loading actual school images');
    await waitReady(tester);
    print('SCHOOL_QA: school assets ready');
    await tester.pump(const Duration(milliseconds:200));
    print('SCHOOL_QA: capture '+first.key);
    await picture(tester,key,first.key);
    for(final item in locations.entries.skip(1)){
      await tester.pumpWidget(MaterialApp(home:RepaintBoundary(
        key:key,child:HermanasGame(qaStage:6,qaWorldX:item.value))));
      await tester.pump(const Duration(milliseconds:150));
      print('SCHOOL_QA: capture '+item.key);
      await picture(tester,key,item.key);
    }
   }finally{
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
   }
 });
}
