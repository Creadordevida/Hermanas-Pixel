// REAL Flutter snapshots from AdaptiveTitleScreen with shipped PNG assets.
// These are widget renders, not illustrative mockups or Android APK captures.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/adaptive_title_screen.dart';

void main() {
 TestWidgetsFlutterBinding.ensureInitialized();
 testWidgets('Portada original y sello reales en 16:9, 18:9, 19.5:9 y 20:9',
     (tester) async {
   // Reject the fallback image here: it is NOT the approved final panorama.
   final panorama=await rootBundle.load(AdaptiveTitleScreen.panoramaAsset);
   final logo=await rootBundle.load(AdaptiveTitleScreen.cleanLogoAsset);
   expect(panorama.lengthInBytes,greaterThan(100000));
   expect(logo.lengthInBytes,greaterThan(2000));

   const screens=<String,Size>{
     '16_9':Size(800,450),
     '18_9':Size(900,450),
     '19_5_9':Size(975,450),
     '20_9':Size(1000,450),
   };
   try {
     for(final entry in screens.entries) {
       await tester.binding.setSurfaceSize(entry.value);
       final repaint=GlobalKey();
       await tester.pumpWidget(MaterialApp(
         home:Scaffold(body:RepaintBoundary(key:repaint,
           child:AdaptiveTitleScreen(
             hasSavedGame:true,
             onNewGame:(){},
             onContinue:(){},
           ),
         )),
       ));
       await tester.pumpAndSettle();
       expect(find.byKey(const ValueKey('title-new-game')),findsOneWidget);
       expect(find.byKey(const ValueKey('title-continue')),findsOneWidget);
       expect(repaint.currentContext,isNotNull);
       final boundary=repaint.currentContext!.findRenderObject()
           as RenderRepaintBoundary;
       expect(boundary.debugNeedsPaint,false);
       final count=await tester.runAsync<int>(() async {
         final image=await boundary.toImage(pixelRatio:1);
         try {
           final bytes=await image.toByteData(format:ui.ImageByteFormat.png);
           if(bytes==null)throw StateError('No real title image');
           final file=File('qa/rendered_from_flutter/title_${entry.key}.png');
           await file.parent.create(recursive:true);
           await file.writeAsBytes(bytes.buffer.asUint8List(),flush:true);
           return await file.length();
         }finally {image.dispose();}
       });
       expect(count,greaterThan(30000));
     }
   }finally {
     await tester.pumpWidget(const SizedBox.shrink());
     await tester.binding.setSurfaceSize(null);
   }
 });
}
