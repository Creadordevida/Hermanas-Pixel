// Capturas REALES de los dos uniformes desde el widget auténtico del juego.
// Una única carga de más de 130 sprites se comparte entre Miren y Sara.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';

Future<void> _waitForAssets(WidgetTester tester) async {
  // El mismo margen de carga (90 s) que la prueba general de capítulos.
  // runAsync permite avanzar al decodificador real, fuera de FakeAsync.
  for (var attempt = 0; attempt < 225; attempt++) {
    await tester.runAsync(() =>
        Future<void>.delayed(const Duration(milliseconds: 400)));
    await tester.pump(const Duration(milliseconds: 30));
    final errors = find.textContaining('ERROR AL CARGAR RECURSOS');
    if (errors.evaluate().isNotEmpty) {
      fail('Falló la carga de recursos: '
          '${tester.widget<Text>(errors.first).data}');
    }
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
  }
  fail('La carga de recursos superó los 90 segundos. Revisar el registro '
      'Recursos incompletos y los tiempos de decodificación.');
}

Future<void> _writeScreenshot(
    WidgetTester tester, GlobalKey key, String name) async {
  final render = key.currentContext?.findRenderObject();
  expect(render, isA<RenderRepaintBoundary>(),
      reason: 'No existe la superficie de captura: $name');
  final boundary = render! as RenderRepaintBoundary;
  expect(boundary.debugNeedsPaint, false,
      reason: 'Flutter aún no ha pintado el uniforme: $name');

  // toImage/toByteData y el acceso al disco necesitan I/O real.
  final bytes = await tester.runAsync<int>(() async {
    final snapshot = await boundary.toImage(pixelRatio: 1)
        .timeout(const Duration(seconds: 20));
    try {
      final encoded = await snapshot.toByteData(format: ui.ImageByteFormat.png)
          .timeout(const Duration(seconds: 20));
      if (encoded == null) throw StateError('PNG vacío: $name');
      final out = File('qa/rendered_from_flutter/$name.png');
      await out.parent.create(recursive: true)
          .timeout(const Duration(seconds: 10));
      await out.writeAsBytes(encoded.buffer.asUint8List(), flush: true)
          .timeout(const Duration(seconds: 20));
      return out.length().timeout(const Duration(seconds: 10));
    } finally {
      snapshot.dispose();
    }
  });
  expect(bytes, isNotNull, reason: 'La captura no pudo terminar: $name');
  expect(bytes!, greaterThan(5000),
      reason: 'La captura $name parece vacía o demasiado sencilla');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Capturas REALES de los uniformes de Miren y Sara',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(800, 450));
    final captureKey = GlobalKey();
    final gameKey = GlobalKey();
    final scenarios = [
      (stage: 4, role: 'Miren',
          attackIcon: 'assets/images/ball.png', slug: 'miren_futbol'),
      (stage: 5, role: 'Sara',
          attackIcon: 'assets/images/comb.png', slug: 'sara_danza'),
    ];

    try {
      for (var index = 0; index < scenarios.length; index++) {
        final scenario = scenarios[index];
        await tester.pumpWidget(MaterialApp(home: RepaintBoundary(
          key: captureKey,
          child: HermanasGame(key: gameKey,
              qaStage: scenario.stage, qaWorldX: 260),
        )));
        if (index == 0) {
          await _waitForAssets(tester);
        } else {
          // didUpdateWidget conserva las imágenes y cambia el escenario.
          await tester.pump(const Duration(milliseconds: 80));
        }
        expect(find.byWidgetPredicate((widget) =>
            widget is CustomPaint && widget.painter is StagePainter &&
            (widget.painter! as StagePainter).stage == scenario.stage),
            findsOneWidget,
            reason: 'No se abrió el capítulo de ${scenario.role}');

        await tester.pump(const Duration(milliseconds: 40));
        await _writeScreenshot(tester, captureKey,
            '${scenario.slug}_quieta_REAL');
        final attackButton = find.byWidgetPredicate((widget) {
          if (widget is! Image || widget.image is! AssetImage) return false;
          return (widget.image as AssetImage).assetName == scenario.attackIcon;
        });
        expect(attackButton, findsOneWidget,
            reason: 'No aparece el ataque de ${scenario.role}');
        await tester.tap(attackButton);
        await tester.pump(const Duration(milliseconds: 40));
        await _writeScreenshot(tester, captureKey,
            '${scenario.slug}_ataque_REAL');
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  });
}
