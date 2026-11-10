import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';

Future<void> waitReady(WidgetTester tester) async {
 for(var i=0;i<360;i++){
  await tester.runAsync(()=>Future<void>.delayed(const Duration(milliseconds:60)));
  await tester.pump(const Duration(milliseconds:40));
  if(find.textContaining('ERROR AL CARGAR RECURSOS').evaluate().isNotEmpty) throw StateError('Resources loading failed');
  if(find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
 }
 throw StateError('Loading timeout');
}
Future<void> waitBitmaps(WidgetTester tester,bool isMap) async {
 final asset=isMap
   ? 'assets/images/worldmap/pamplona_wide_20x9_approved.webp'
   : 'assets/images/title_wide_20x9_wall_continuity_v2.webp';
 final background=find.byWidgetPredicate((w)=>
   w is Image && w.image is AssetImage &&
   (w.image as AssetImage).assetName==asset);
 for(var i=0;i<240;i++){
  await tester.pump(const Duration(milliseconds:50));
  if(background.evaluate().isNotEmpty){
   final rendered=find.descendant(of:background,matching:find.byType(RawImage));
   if(tester.widgetList<RawImage>(rendered).any((w)=>w.image!=null))return;
  }
  await tester.runAsync(()=>Future<void>.delayed(const Duration(milliseconds:20)));
 }
 throw StateError('Panorama asset not decoded: $asset');
}
void main(){
 TestWidgetsFlutterBinding.ensureInitialized();
 testWidgets('Real title/map panorama snapshots 16:9 19.5:9 20:9', (tester) async {
  SharedPreferences.setMockInitialValues({});
  try {
   const sizes=<String,Size>{
    '16_9':Size(800,450),
    '19_5_9':Size(975,450),
    '20_9':Size(1000,450),
   };
   for(final pair in sizes.entries){
    for(final isMap in [false,true]){
     await tester.binding.setSurfaceSize(pair.value);
     final key=GlobalKey();
     await tester.pumpWidget(MaterialApp(home:RepaintBoundary(key:key,
      child:HermanasGame(key:ValueKey('${pair.key}-$isMap'),qaMap:isMap,qaTitle:!isMap))));
     await waitReady(tester);
     await waitBitmaps(tester,isMap);
     await tester.pump(const Duration(milliseconds:120));
     final boundary=key.currentContext!.findRenderObject() as RenderRepaintBoundary;
     expect(boundary.size,pair.value);
     final count=await tester.runAsync<int>(() async {
      final img=await boundary.toImage(pixelRatio:1);
      try {
       final data=await img.toByteData(format:ui.ImageByteFormat.png);
       if(data==null)throw StateError('No pixels');
       // Evidence comes from Flutter's REAL composited frame, never a
       // manually opened background or a newly generated illustration.
       if(pair.key=='20_9'){
        final rgba=await img.toByteData(format:ui.ImageByteFormat.rawRgba);
        if(rgba==null)throw StateError('No raw pixels');
        final bytes=rgba.buffer.asUint8List();
        int pixel(int x,int y){
         final o=(y*img.width+x)*4;
         return (bytes[o]<<16)|(bytes[o+1]<<8)|bytes[o+2];
        }
        final left=<int>{},right=<int>{};
        for(final y in [55,120,225,330,420]){
         left.add(pixel(7,y));
         right.add(pixel(img.width-8,y));
        }
        if(left.length<4||right.length<4){
         throw StateError('20:9 edge still painted as a flat letterbox: $isMap');
        }
       }
       final out=File('qa/title_map_rc7_flutter/${isMap?'map':'title'}_${pair.key}.png');
       await out.parent.create(recursive:true);
       await out.writeAsBytes(data.buffer.asUint8List(),flush:true);
       return await out.length();
      }finally {img.dispose();}
     });
     expect(count,greaterThan(12000));
    }
   }
  }finally{
   await tester.pumpWidget(const SizedBox.shrink());
   await tester.binding.setSurfaceSize(null);
  }
 });
}
