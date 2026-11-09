// Real Flutter raster inspection of the uploaded SIX-SECTOR CANDIDATE PNG.
// This is NOT StagePainter, not the playable level, and not the final art.
// Never claim these screenshots are from actual Miren/Sara gameplay.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

class _PanoramaPainter extends CustomPainter {
  const _PanoramaPainter(this.panorama, this.camera);
  final ui.Image panorama;
  final double camera;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xffd1c1a7), BlendMode.src);
    canvas.drawImageRect(
      panorama,
      Rect.fromLTWH(camera, 0, size.width, 390),
      Rect.fromLTWH(0, 0, size.width, 390),
      Paint()..filterQuality=FilterQuality.none,
    );
  }
  @override
  bool shouldRepaint(_PanoramaPainter old) =>
      old.camera != camera || old.panorama != panorama;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('real Flutter raster views of non-integrated Quiosco candidate',
      (tester) async {
    final input=File('qa-output/quiosco_six_sector_candidate/panorama_prototipo_6_sectores.png');
    // IO and image-codec futures must run outside fake async testWidgets time.
    final source=await tester.runAsync(() async {
      if (!await input.exists()) throw StateError('Candidate ZIP was not extracted');
      final raw=await input.readAsBytes();
      final codec=await ui.instantiateImageCodec(raw);
      try {
        final frame=await codec.getNextFrame();
        return frame.image;
      } finally {codec.dispose();}
    });
    expect(source,isNotNull);
    final actualSource=source!;
    expect(actualSource.width, 5782);
    expect(actualSource.height, 390);
    const cameras=<double>[0, 900, 1850, 2450, 3200, 4250, 4782];
    const viewport=Size(1000, 450);
    final key=GlobalKey();
    try {
      await tester.binding.setSurfaceSize(viewport);
      for (final camera in cameras) {
        await tester.pumpWidget(
          MaterialApp(home:Scaffold(body:RepaintBoundary(
            key:key,
            child:CustomPaint(
              size:viewport,
              painter:_PanoramaPainter(actualSource,camera),
            ),
          ))),
        );
        await tester.pump(const Duration(milliseconds:120));
        final boundary=key.currentContext!.findRenderObject() as RenderRepaintBoundary;
        expect(boundary.debugNeedsPaint, isFalse);
        await tester.runAsync(() async {
          final image=await boundary.toImage(pixelRatio:1);
          try {
            final bytes=await image.toByteData(format:ui.ImageByteFormat.png);
            expect(bytes, isNotNull);
            final file=File('qa-output/quiosco_candidate_flutter/flutter_candidate_cam_${camera.toInt()}.png');
            await file.parent.create(recursive:true);
            await file.writeAsBytes(bytes!.buffer.asUint8List(
              bytes.offsetInBytes,bytes.lengthInBytes),flush:true);
            expect(await file.length(), greaterThan(10000));
          } finally {image.dispose();}
        });
      }
    } finally {
      actualSource.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  });
}
