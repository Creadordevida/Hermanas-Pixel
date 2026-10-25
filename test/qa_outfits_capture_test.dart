// Capturas REALES del renderizador Flutter: Miren fútbol y Sara danza.
// Se reutiliza una única carga de recursos para los dos personajes.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';

Future<void> _waitForResources(WidgetTester tester) async {
  for (var i=0; i<225; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 400)));
    await tester.pump(const Duration(milliseconds:30));
    final errors = find.textContaining('ERROR AL CARGAR RECURSOS');
    if (errors.evaluate().isNotEmpty) {
      fail('Error real de recursos: ${tester.widget<Text>(errors.first).data}');
    }
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
  }
  fail('La carga de sprites tardó más de 90 segundos. Consultar Recursos incompletos en los logs.');
}

// Es imprescindible hacer renderizacion, codificacion PNG y E/S en runAsync:
// FakeAsync de testWidgets puede bloquear Future<File> y Future<ByteData>.
Future<void> _screenshot(WidgetTester tester, GlobalKey key, String name) async {
  final obj = key.currentContext?.findRenderObject();
  expect(obj, isA<RenderRepaintBoundary>());
  final boundary = obj! as RenderRepaintBoundary;
  expect(boundary.debugNeedsPaint, isFalse,
      reason: 'Captura antes del renderizado: $name');

  final length = await tester.runAsync<int>(() async {
    ui.Image? image;
    try {
      // ignore: avoid_print
      print('QA_VESTUARIO_INICIO $name');
      image = await boundary.toImage(pixelRatio: 1)
          .timeout(const Duration(seconds: 20));
      final data = await image.toByteData(format: ui.ImageByteFormat.png)
          .timeout(const Duration(seconds: 20));
      if (data == null) throw StateError('PNG sin datos: $name');
      final output = File('qa/rendered_from_flutter/$name.png');
      await output.parent.create(recursive: true)
          .timeout(const Duration(seconds: 10));
      await output.writeAsBytes(data.buffer.asUint8List(), flush: true)
          .timeout(const Duration(seconds: 20));
      final result = await output.length().timeout(const Duration(seconds: 10));
      // ignore: avoid_print
      print('QA_VESTUARIO_GUARDADO $name ($result bytes)');
      return result;
    } catch (error) {
      // ignore: avoid_print
      print('QA_VESTUARIO_ERROR $name: $error');
      rethrow;
    } finally {
      image?.dispose();
    }
  });
  expect(length, isNotNull, reason: 'runAsync no devolvio datos: $name');
  expect(length!, greaterThan(5000), reason: 'PNG vacio: $name');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Vestuario REAL de Miren y Sara: espera y ataque',(tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(800,450));
    final boundaryKey = GlobalKey();
    final gameKey = GlobalKey();
    for (final scenario in [
      (stage:4, role:'Miren',attackIcon:'assets/images/ball.png',slug:'miren_futbol'),
      (stage:5, role:'Sara',attackIcon:'assets/images/comb.png',slug:'sara_danza'),
    ]) {
      await tester.pumpWidget(MaterialApp(home: RepaintBoundary(
        key:boundaryKey,
        child:HermanasGame(key:gameKey,qaStage:scenario.stage,qaWorldX:260),
      )));
      if (scenario.stage==4) await _waitForResources(tester);
      await tester.pump(const Duration(milliseconds:40));
      await _screenshot(tester, boundaryKey, '${scenario.slug}_quieta_REAL');
      final attack=find.byWidgetPredicate((widget) {
        if (widget is! Image || widget.image is! AssetImage) return false;
        return (widget.image as AssetImage).assetName==scenario.attackIcon;
      });
      expect(attack,findsOneWidget);
      await tester.tap(attack);
      await tester.pump(const Duration(milliseconds:40));
      await _screenshot(tester, boundaryKey, '${scenario.slug}_ataque_REAL');
      // ignore: avoid_print
      print('VESTUARIO_OK ${scenario.slug}');
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });
}
