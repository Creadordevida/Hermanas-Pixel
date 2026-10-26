// Evidencias reales de los 2 uniformes APROBADOS cargados por el motor Flutter.
// Las imágenes generadas son capturas del RenderRepaintBoundary, NO dibujos
// simulados fuera del juego. Su ejecución depende de Flutter/GitHub Actions.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';

Future<void> _waitForAssets(WidgetTester tester) async {
  for (var i=0; i<100; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds:200)));
    await tester.pump(const Duration(milliseconds:30));
    expect(find.textContaining('ERROR AL CARGAR RECURSOS'), findsNothing);
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
  }
  fail('No se cargaron los recursos del juego');
}

Future<void> _writeScreenshot(GlobalKey key, String name) async {
  final render=key.currentContext?.findRenderObject();
  expect(render, isA<RenderRepaintBoundary>());
  final snapshot=await (render as RenderRepaintBoundary).toImage(pixelRatio:1);
  try {
    final encoded=await snapshot.toByteData(format:ui.ImageByteFormat.png);
    expect(encoded,isNotNull);
    final out=File('qa/rendered_from_flutter/$name.png');
    await out.parent.create(recursive:true);
    await out.writeAsBytes(encoded!.buffer.asUint8List(),flush:true);
    expect(await out.length(),greaterThan(5000));
  } finally { snapshot.dispose(); }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final scenario in [
    (stage:4, role:'Miren',attackIcon:'assets/images/ball.png',slug:'miren_futbol'),
    (stage:5, role:'Sara',attackIcon:'assets/images/comb.png',slug:'sara_danza'),
  ]) {
    testWidgets('Capturas REALES de ${scenario.role} con vestuario temático',(tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.binding.setSurfaceSize(const Size(800,450));
      final captureKey=GlobalKey();
      await tester.pumpWidget(MaterialApp(home:RepaintBoundary(
        key:captureKey,child:HermanasGame(qaStage:scenario.stage,qaWorldX:260))));
      await _waitForAssets(tester);
      await tester.pump(const Duration(milliseconds:40));
      await _writeScreenshot(captureKey,'${scenario.slug}_quieta_REAL');
      final attackButton=find.byWidgetPredicate((widget) {
        if (widget is! Image || widget.image is! AssetImage) return false;
        return (widget.image as AssetImage).assetName==scenario.attackIcon;
      });
      expect(attackButton,findsOneWidget);
      await tester.tap(attackButton);
      await tester.pump(const Duration(milliseconds:40));
      await _writeScreenshot(captureKey,'${scenario.slug}_ataque_REAL');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    });
  }
}
