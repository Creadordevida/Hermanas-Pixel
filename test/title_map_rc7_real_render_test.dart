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
Future<void> waitBitmaps(WidgetTester tester) async {
 for(var i=0;i<180;i++){
  await tester.pump(const Duration(milliseconds:40));
  if(tester.widgetList<RawImage>(find.byType(RawImage)).any((w)=>w.image!=null)) return;
  await tester.runAsync(()=>Future<void>.delayed(const Duration(milliseconds:20)));
 }
 throw StateError('Rendered Image.asset not decoded');
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
      child:HermanasGame(key:ValueKey('${pair.key}-$isMap'),qaMap:isMap))));
     await waitReady(tester);
     await waitBitmaps(tester);
     await tester.pump(const Duration(milliseconds:120));
     final boundary=key.currentContext!.findRenderObject() as RenderRepaintBoundary;
     expect(boundary.size,pair.value);
     final count=await tester.runAsync<int>(() async {
      final img=await boundary.toImage(pixelRatio:1);
      try {
       final data=await img.toByteData(format:ui.ImageByteFormat.png);
       if(data==null)throw StateError('No pixels');
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
