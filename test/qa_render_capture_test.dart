// Capturas del render real Flutter, sin reconstruir escenas artificiales.
// Una sola carga de sprites para el título, mapa y los 7 capítulos.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';

const _view = Size(800, 450);

Future<void> _awaitGameReady(WidgetTester tester) async {
  // En GitHub, la decodificación inicial de sprites puede tardar más de 20 s.
  // Una única carga es necesaria; el resto de capturas reutiliza esas imágenes.
  for (var attempt = 0; attempt < 225; attempt++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 400)));
    await tester.pump(const Duration(milliseconds: 30));
    final errors = find.textContaining('ERROR AL CARGAR RECURSOS');
    if (errors.evaluate().isNotEmpty) {
      fail('Flutter no puede cargar los recursos del juego: ${tester.widget<Text>(errors.first).data}');
    }
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
  }
  fail('La carga inicial de recursos no finalizó en 90 segundos. Revisar los mensajes Recursos incompletos y los tiempos de decodificación.');
}

Future<void> _capture(GlobalKey boundaryKey, String title) async {
  final render = boundaryKey.currentContext?.findRenderObject();
  expect(render, isA<RenderRepaintBoundary>(), reason: 'No existe el límite de captura: $title');
  final boundary = render! as RenderRepaintBoundary;
  expect(boundary.debugNeedsPaint, isFalse, reason: 'La escena aún no se ha dibujado: $title');
  final image = await boundary.toImage(pixelRatio: 1.0);
  try {
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    expect(bytes, isNotNull, reason: 'No se pudo codificar el PNG: $title');
    final file = File('qa/rendered_from_flutter/$title.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
    expect(await file.length(), greaterThan(5000), reason: 'Captura vacía o demasiado pequeña: $title');
  } finally {
    image.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Render Flutter REAL: mapa, título y 28 puntos de los siete capítulos',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(_view);
    final boundaryKey = GlobalKey();
    final gameKey = GlobalKey();
    final targets = <({String title, int? stage, bool map, double? worldX})>[
      (title: 'titulo_090', stage: null, map: false, worldX: null),
      (title: 'mapa_090', stage: null, map: true, worldX: null),
      for (var i = 0; i < 7; i++)
        (title: 'capitulo_${i + 1}_inicio', stage: i, map: false, worldX: 200),
      for (var i = 0; i < 7; i++)
        (title: 'capitulo_${i + 1}_union', stage: i, map: false, worldX: 1380),
      for (var i = 0; i < 7; i++)
        (title: 'capitulo_${i + 1}_mitad', stage: i, map: false, worldX: 18300),
      for (var i = 0; i < 7; i++)
        (title: 'capitulo_${i + 1}_final', stage: i, map: false, worldX: 35650),
    ];
    for (var i = 0; i < targets.length; i++) {
      final target = targets[i];
      // El GlobalKey de HermanasGame mantiene el mismo State y la memoria de
      // imágenes entre capítulos; didUpdateWidget modifica solo el escenario.
      await tester.pumpWidget(MaterialApp(home: RepaintBoundary(
        key: boundaryKey,
        child: HermanasGame(
          key: gameKey, qaStage: target.stage,
          qaMap: target.map, qaWorldX: target.worldX,
        ),
      )));
      if (i == 0) await _awaitGameReady(tester);
      await tester.pump(const Duration(milliseconds: 40));
      try {
        await _capture(boundaryKey, target.title);
      } catch (error) {
        fail('No se pudo capturar ${target.title}: $error');
      }
      // Permite ver el nombre del punto fallido en el registro de CI.
      // ignore: avoid_print
      print('CAPTURA_OK ${target.title}');
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });
}
