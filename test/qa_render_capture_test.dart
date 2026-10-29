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
  for (var attempt = 0; attempt < 450; attempt++) {
    if (attempt % 25 == 0) {
      // ignore: avoid_print
      print('QA_CARGA_RECURSOS ${attempt * 400 ~/ 1000}s: esperando');
    }
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 400)));
    await tester.pump(const Duration(milliseconds: 30));
    final errors = find.textContaining('ERROR AL CARGAR RECURSOS');
    if (errors.evaluate().isNotEmpty) {
      fail('Flutter no puede cargar los recursos del juego: ${tester.widget<Text>(errors.first).data}');
    }
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
  }
  fail('La carga inicial de recursos no finalizó en 180 segundos. Revisar los mensajes Recursos incompletos y los tiempos de decodificación.');
}

// Las imagenes insertadas con Image.asset usan un ImageProvider aparte
// de las 136 ui.Image del motor. Que _loadAssets termine no implica que
// la portada o el mapa hayan terminado de decodificarse y pintarse.
Future<void> _waitForImageWidgets(WidgetTester tester, String name,
    {required int loadedImages}) async {
  for (var attempt = 0; attempt < 240; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    final count = tester.widgetList<RawImage>(find.byType(RawImage))
        .where((image) => image.image != null).length;
    if (attempt % 40 == 0) {
      // ignore: avoid_print
      print('QA_ESPERA_IMAGES $name $count/$loadedImages intento $attempt');
    }
    if (count >= loadedImages) {
      // Una pasada extra permite que el RepaintBoundary pinte la imagen.
      await tester.pump(const Duration(milliseconds: 50));
      // ignore: avoid_print
      print('QA_IMAGENES_LISTAS $name ($count/$loadedImages)');
      return;
    }
    await tester.runAsync(() =>
        Future<void>.delayed(const Duration(milliseconds: 30)));
  }
  fail('El fondo visible de $name no llego a cargarse: '
      'Image.asset/RawImage sin pixels. No aprobar una pantalla vacia.');
}

// Las llamadas al motor grafico y al sistema de archivos son asincronas reales.
// Dentro de testWidgets se deben ejecutar con tester.runAsync; de lo contrario
// FakeAsync puede dejar la prueba esperando indefinidamente hasta agotar 10 min.
Future<void> _capture(WidgetTester tester, GlobalKey boundaryKey, String title) async {
  final render = boundaryKey.currentContext?.findRenderObject();
  expect(render, isA<RenderRepaintBoundary>(),
      reason: 'No existe el limite de captura: $title');
  final boundary = render! as RenderRepaintBoundary;
  expect(boundary.debugNeedsPaint, isFalse,
      reason: 'La escena aun no se ha dibujado: $title');

  // No ejecutar toImage(), toByteData() ni File.writeAsBytes() en FakeAsync.
  // Un tiempo limite independiente ayuda a localizar el punto de bloqueo.
  final result = await tester.runAsync<({int pngBytes, int colors, int width, int height})>(() async {
    ui.Image? image;
    try {
      // ignore: avoid_print
      print('QA_CAPTURA_INICIO $title');
      image = await boundary.toImage(pixelRatio: 1.0)
          .timeout(const Duration(seconds: 20));
      // ignore: avoid_print
      print('QA_CAPTURA_RENDERIZADA $title');
      final rgba = await image.toByteData(format: ui.ImageByteFormat.rawRgba)
          .timeout(const Duration(seconds: 20));
      if (rgba == null) throw StateError('rawRgba devolvio null: $title');
      // No se valida una captura por sus bytes comprimidos (un PNG correcto
      // puede pesar menos de 5000 bytes). Se muestrea su contenido de color.
      // De esa forma una portada vacia, uniforme o sin Image.asset falla.
      final pixels = rgba.buffer.asUint8List(rgba.offsetInBytes, rgba.lengthInBytes);
      final colors = <int>{};
      final stepX = image.width > 32 ? image.width ~/ 32 : 1;
      final stepY = image.height > 18 ? image.height ~/ 18 : 1;
      for (var y = 0; y < image.height; y += stepY) {
        for (var x = 0; x < image.width; x += stepX) {
          final offset = (y * image.width + x) * 4;
          final alpha = pixels[offset + 3];
          if (alpha < 32) continue;
          final bucket = ((pixels[offset] >> 5) << 6) |
              ((pixels[offset + 1] >> 5) << 3) |
              (pixels[offset + 2] >> 5);
          colors.add(bucket);
        }
      }
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png)
          .timeout(const Duration(seconds: 20));
      if (bytes == null) throw StateError('toByteData devolvio null: $title');
      final file = File('qa/rendered_from_flutter/$title.png');
      await file.parent.create(recursive: true)
          .timeout(const Duration(seconds: 10));
      await file.writeAsBytes(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes), flush: true)
          .timeout(const Duration(seconds: 20));
      final result = await file.length().timeout(const Duration(seconds: 10));
      // ignore: avoid_print
      print('QA_CAPTURA_GUARDADA $title ($result bytes, ${colors.length} colores, '
          '${image.width}x${image.height})');
      return (pngBytes: result, colors: colors.length,
          width: image.width, height: image.height);
    } catch (error) {
      // ignore: avoid_print
      print('QA_CAPTURA_ERROR $title: $error');
      rethrow;
    } finally {
      image?.dispose();
    }
  });
  expect(result, isNotNull, reason: 'runAsync no devolvio resultado: $title');
  final screen = result!;
  expect(screen.width, greaterThanOrEqualTo(700), reason: 'Anchura insuficiente: $title');
  expect(screen.height, greaterThanOrEqualTo(390), reason: 'Altura insuficiente: $title');
  expect(screen.pngBytes, greaterThan(1000), reason: 'PNG ilegible o vacio: $title');
  expect(screen.colors, greaterThanOrEqualTo(14),
      reason: 'Pantalla practicamente uniforme o no pintada: $title. '
          'Colores=${screen.colors}; bytes=${screen.pngBytes}. '
          'Inspeccionar la captura publicada como artifacto.');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Render Flutter REAL: mapa, siete capítulos y cuatro zonas del barrio',
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
      // El capítulo 1 ahora contiene regiones explícitas: se capturan ambos
      // lados de las uniones de obra y los comienzos de las conexiones.
      (title: 'barrio_residencial',stage:0,map:false,worldX:250),
      (title: 'barrio_residencial_avance',stage:0,map:false,worldX:600),
      (title: 'barrio_paseo',stage:0,map:false,worldX:9970),
      (title: 'barrio_paseo_avance',stage:0,map:false,worldX:10350),
      (title: 'barrio_cubierta',stage:0,map:false,worldX:19200),
      (title: 'barrio_cohete',stage:0,map:false,worldX:29150),
      // All six REAL borders, plus viewpoints on each side. Keep explicit
      // literal names so the QA manifest and visual review are auditable.
      (title:'barrio_union_1_antes',stage:0,map:false,worldX:7040),
      (title:'barrio_union_1_despues',stage:0,map:false,worldX:7360),
      (title:'barrio_union_2_antes',stage:0,map:false,worldX:9040),
      (title:'barrio_union_2_despues',stage:0,map:false,worldX:9360),
      (title:'barrio_union_3_antes',stage:0,map:false,worldX:16040),
      (title:'barrio_union_3_despues',stage:0,map:false,worldX:16360),
      (title:'barrio_union_4_antes',stage:0,map:false,worldX:18240),
      (title:'barrio_union_4_despues',stage:0,map:false,worldX:18560),
      (title:'barrio_union_5_antes',stage:0,map:false,worldX:25240),
      (title:'barrio_union_5_despues',stage:0,map:false,worldX:25560),
      (title:'barrio_union_6_antes',stage:0,map:false,worldX:27440),
      (title:'barrio_union_6_despues',stage:0,map:false,worldX:27760),
      // SCHOOL: independent genuine StagePainter renders of successive
      // corridor/classroom/computing compositions and both physical joins.
      // In these images the exterior is the same REAL .30/.56 sky parallax,
      // only visible through alpha-masked windows.
      for (final (label,position) in <(String,double)>[
        ('colegio_pasillo_entrada',450),
        ('colegio_pasillo_biblioteca',4120),
        ('colegio_pasillo_final',7360),
        ('colegio_union_1_antes',10420),
        ('colegio_union_1_despues',10540),
        ('colegio_aula_matematicas',12420),
        ('colegio_aula_distribucion_2',16300),
        ('colegio_aula_distribucion_3',21000),
        ('colegio_union_2_antes',25420),
        ('colegio_union_2_despues',25540),
        ('colegio_aula_informatica',27800),
        ('colegio_laboratorio_2',31300),
        ('colegio_laboratorio_final',34700),
      ]) (title:label,stage:6,map:false,worldX:position),
      // Two further SNES-visual benchmarks, each with THREE REAL unique
      // environments and both sides of their two camera transitions.
      for (final chapter in [4,5]) ...[
        (title: '${chapter==4?'futbol':'danza'}_zona_entrada',
          stage:chapter,map:false,worldX:4500),
        (title: '${chapter==4?'futbol':'danza'}_zona_central',
          stage:chapter,map:false,worldX:18100),
        (title: '${chapter==4?'futbol':'danza'}_zona_final',
          stage:chapter,map:false,worldX:30700),
        (title: '${chapter==4?'futbol':'danza'}_union_1_antes',
          stage:chapter,map:false,worldX:10410),
        (title: '${chapter==4?'futbol':'danza'}_union_1_despues',
          stage:chapter,map:false,worldX:10510),
        (title: '${chapter==4?'futbol':'danza'}_union_2_antes',
          stage:chapter,map:false,worldX:25410),
        (title: '${chapter==4?'futbol':'danza'}_union_2_despues',
          stage:chapter,map:false,worldX:25510),
      ],
    ];
    for (var i = 0; i < targets.length; i++) {
      final target = targets[i];
      // ignore: avoid_print
      print('QA_INICIO_ESCENA ${i + 1}/${targets.length}: ${target.title}');
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
      if (target.title == 'titulo_090') {
        // Portada y logo: dos widgets Image.asset diferentes.
        await _waitForImageWidgets(tester, target.title, loadedImages: 2);
      } else if (target.map) {
        await _waitForImageWidgets(tester, target.title, loadedImages: 1);
      } else {
        // La pantalla QA debe ser el capitulo solicitado, no el titulo
        // heredado del primer pumpWidget ni el capitulo anterior.
        await tester.pump(const Duration(milliseconds: 70));
        expect(find.byWidgetPredicate((widget) =>
            widget is CustomPaint && widget.painter is StagePainter &&
            (widget.painter! as StagePainter).stage == target.stage),
            findsOneWidget, reason: 'Escenario QA incorrecto: ${target.title}');
      }
      await tester.pump(const Duration(milliseconds: 40));
      try {
        await _capture(tester, boundaryKey, target.title);
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
