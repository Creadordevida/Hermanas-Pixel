import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: Demo()));
}

class Demo extends StatefulWidget {
  const Demo({super.key});
  @override State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  final Map<String, ui.Image> images = {};
  Timer? timer;
  bool left = false, right = false, dialog = true, action = false;
  int dialogue = 0, selected = 0;
  double x = 300, y = 0, vy = 0, fatherX = 200, phase = 0;
  final lines = [
    ('PADRE', '¡Venga, chicas! ¿Estáis listas?'),
    ('FUTBOLISTA', '¡Yo sí! ¡Vamos!'),
    ('BAILARINA', '¡Espérame, que voy!'),
    ('PADRE', '¡Pues en marcha!'),
  ];

  @override void initState() {
    super.initState();
    _load();
    timer = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
  }
  Future<void> _load() async {
    for (final name in ['padre', 'futbolista', 'bailarina', 'edificio_pixel', ...[for (final who in ['padre', 'futbolista', 'bailarina']) for (final pose in ['idle', 'run', 'jump']) for (var i = 0; i < 3; i++) 'frames/${who}_${pose}_$i']]) {
      final data = await rootBundle.load('assets/images/$name.png');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      images[name] = frame.image;
    }
    if (mounted) setState(() {});
  }
  void _tick() {
    if (!mounted || dialog) return;
    const dt = 0.016;
    if (left) x -= 175 * dt;
    if (right) x += 175 * dt;
    x = x.clamp(45.0, 1350.0).toDouble();
    vy += 920 * dt;
    y += vy * dt;
    if (y >= 0) { y = 0; vy = 0; }
    final gap = x - fatherX;
    if (gap.abs() > 100) fatherX += gap.sign * math.min(gap.abs() - 100, 110 * dt);
    phase += dt;
    setState(() {});
  }
  void _jump() { if (!dialog && y >= 0) setState(() { vy = selected == 0 ? -420 : -490; }); }
  void _ability() {
    if (dialog) return;
    setState(() { action = true; });
    Future.delayed(const Duration(milliseconds: 350), () { if (mounted) setState(() { action = false; }); });
  }
  void _next() { setState(() { if (dialogue < lines.length - 1) { dialogue++; } else { dialog = false; } }); }
  @override void dispose() { timer?.cancel(); for (final image in images.values) { image.dispose(); } super.dispose(); }

  Widget control(IconData icon, VoidCallback down, VoidCallback up, {double size = 58}) =>
      Listener(onPointerDown: (_) => down(), onPointerUp: (_) => up(), onPointerCancel: (_) => up(),
        child: Container(width: size, height: size, margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: const Color(0xAA102C50), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white70, width: 2)),
          child: Icon(icon, size: 30, color: Colors.white)));

  @override Widget build(BuildContext context) {
    return Scaffold(body: LayoutBuilder(builder: (context, constraints) {
      final scale = math.min(constraints.maxWidth / 960, constraints.maxHeight / 540);
      return Center(child: SizedBox(width: 960 * scale, height: 540 * scale,
        child: FittedBox(fit: BoxFit.fill, child: SizedBox(width: 960, height: 540,
          child: Stack(children: [
            Positioned.fill(child: CustomPaint(painter: Scene(images, x, y, fatherX, selected, phase, action, left, right))),
            const Positioned(left: 20, top: 14, child: Text('DOS HERMANAS  •  PRUEBA GRÁFICA 0.1.1', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 5, color: Colors.black)]))),
            if (!dialog) ...[
              Positioned(left: 15, bottom: 15, child: Row(children: [
                control(Icons.arrow_back, () => left = true, () => left = false),
                control(Icons.arrow_forward, () => right = true, () => right = false),
              ])),
              Positioned(right: 16, bottom: 15, child: Row(children: [
                control(Icons.swap_horiz, () => setState(() => selected = 1 - selected), () {}),
                control(selected == 0 ? Icons.sports_soccer : Icons.auto_awesome, _ability, () {}),
                control(Icons.arrow_upward, _jump, () {}),
              ])),
              Positioned(right: 18, top: 12, child: Text(selected == 0 ? 'FUTBOLISTA · 19' : 'BAILARINA', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 5, color: Colors.black)]))),
            ],
            if (dialog) Positioned(left: 125, right: 125, bottom: 18, child: GestureDetector(onTap: _next,
              child: Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xF516284A), border: Border.all(color: Colors.white, width: 3), borderRadius: BorderRadius.circular(12)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text(lines[dialogue].$1, style: const TextStyle(color: Color(0xFFFFD76A), fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 7),
                  Text(lines[dialogue].$2, style: const TextStyle(color: Colors.white, fontSize: 21)),
                  const Align(alignment: Alignment.bottomRight, child: Text('TOCA PARA CONTINUAR  ▶', style: TextStyle(color: Colors.white70, fontSize: 12))),
                ]))))
          ])))));
    }));
  }
}

class Scene extends CustomPainter {
  final Map<String, ui.Image> images;
  final double x, y, fatherX, phase;
  final int selected;
  final bool action, left, right;
  Scene(this.images, this.x, this.y, this.fatherX, this.selected, this.phase, this.action, this.left, this.right);
  @override void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    canvas.drawRect(const Rect.fromLTWH(0, 0, 960, 540), p..color = const Color(0xFF8DC9F0));
    final camera = (x - 390).clamp(0.0, 530.0).toDouble();
    canvas.save(); canvas.translate(-camera, 0);
    // Background based on the user's actual apartment-building photograph.
    final building = images['edificio_pixel'];
    if (building != null) {
      p.color = Colors.white;
      canvas.drawImageRect(building, Rect.fromLTWH(0, 0, building.width.toDouble(), building.height.toDouble()), const Rect.fromLTWH(90, -370, 660, 830), p);
    }
    // Sidewalk and pixel-styled platform floor.
    p.color = const Color(0xFFB7AFA5); canvas.drawRect(const Rect.fromLTWH(0, 432, 1550, 108), p);
    p.color = const Color(0xFF65636A); canvas.drawRect(const Rect.fromLTWH(0, 428, 1550, 11), p);
    p.color = const Color(0xFFE0D8C8);
    for (var i = 0; i < 22; i++) {
      canvas.drawRect(Rect.fromLTWH(i * 74.0, 460, 3, 80), p);
      canvas.drawRect(Rect.fromLTWH(i * 74.0, 496, 74, 2), p);
    }
    // A short playable street with small obstacles.
    for (final bx in [850.0, 1100.0, 1290.0]) {
      p.color = const Color(0xFF79512F); canvas.drawRect(Rect.fromLTWH(bx, 392, 48, 36), p);
      p.color = const Color(0xFFB98A4B); canvas.drawRect(Rect.fromLTWH(bx + 4, 397, 40, 26), p);
      p.color = const Color(0xFF53331E); canvas.drawLine(Offset(bx + 4, 397), Offset(bx + 44, 423), p..strokeWidth = 4);
      canvas.drawLine(Offset(bx + 44, 397), Offset(bx + 4, 423), p);
    }
    void sprite(String name, double sx, double bottom, double height, {bool moving = false, bool jumping = false}) {
      final pose = jumping ? 'jump' : moving ? 'run' : 'idle';
      final frame = ((phase * (moving ? 9 : 3)).floor() % 3);
      final image = images['frames/${name}_${pose}_$frame'] ?? images[name];
      if (image == null) return;
      final width = height * image.width / image.height;
      p.color = const Color(0x66000000);
      canvas.drawOval(Rect.fromCenter(center: Offset(sx, 433), width: width * 0.75, height: 9), p);
      p.color = Colors.white;
      p.filterQuality = FilterQuality.none;
      canvas.drawImageRect(image, Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()), Rect.fromLTWH(sx - width / 2, bottom - height, width, height), p);
    }
    sprite('padre', fatherX, 430, 136, moving: (x - fatherX).abs() > 101);
    sprite('futbolista', selected == 0 ? x : x - 65, selected == 0 ? 430 + y : 430, 119, moving: selected == 0 && (left || right), jumping: selected == 0 && y < -3);
    sprite('bailarina', selected == 1 ? x : x + 65, selected == 1 ? 430 + y : 430, 105, moving: selected == 1 && (left || right), jumping: selected == 1 && y < -3);
    if (action) {
      p.color = const Color(0xFFFFD95E);
      canvas.drawCircle(Offset(x + 44, 345 + y), 13, p);
      p.color = Colors.white; canvas.drawCircle(Offset(x + 44, 345 + y), 8, p);
    }
    canvas.restore();
  }
  @override bool shouldRepaint(covariant Scene oldDelegate) => true;
}
