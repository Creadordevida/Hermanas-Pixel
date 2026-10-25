// Capturas auténticas de los píxeles dibujados por Flutter/Skia.
// NO son fotografías de Android; sirven para comprobar regresiones visuales.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';

const _view = Size(800,450);

Future<void> _assetsLoaded(WidgetTester tester) async {
  for(var attempt=0; attempt<100; attempt++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump(const Duration(milliseconds: 30));
    expect(find.textContaining('ERROR AL CARGAR RECURSOS'), findsNothing);
    if(find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
  }
  fail('Flutter no terminó de cargar los recursos en 20 segundos.');
}

Future<void> _capture(GlobalKey key,String filename) async {
  final rendered=key.currentContext?.findRenderObject();
  expect(rendered,isA<RenderRepaintBoundary>());
  final png=await (rendered as RenderRepaintBoundary).toImage(pixelRatio:1);
  try {
    final bytes=await png.toByteData(format:ui.ImageByteFormat.png);
    expect(bytes,isNotNull);
    final dir=Directory('qa/rendered_from_flutter');
    await dir.create(recursive:true);
    final output=File('${dir.path}/$filename.png');
    await output.writeAsBytes(bytes!.buffer.asUint8List(),flush:true);
    expect(await output.length(),greaterThan(5000));
  } finally { png.dispose(); }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final targets=<({String title,int? stage,bool map})>[
    (title:'titulo_090',stage:null,map:false),
    (title:'mapa_090',stage:null,map:true),
    for(var i=0;i<7;i++) (title:'capitulo_${i+1}_090',stage:i,map:false),
  ];
  for(final target in targets) {
    testWidgets('Render real Flutter: ${target.title}',(tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.binding.setSurfaceSize(_view);
      final boundaryKey=GlobalKey();
      await tester.pumpWidget(MaterialApp(home:RepaintBoundary(
        key:boundaryKey,
        child:HermanasGame(qaStage:target.stage,qaMap:target.map),
      )));
      await _assetsLoaded(tester);
      // Los recursos se dibujan antes de guardar la imagen del juego real.
      await tester.pump(const Duration(milliseconds:70));
      await _capture(boundaryKey,target.title);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    });
  }
}
