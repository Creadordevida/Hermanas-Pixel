import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const double worldWidth = 1320;
const double viewportWidth = 800;
const double viewportHeight = 450;
const double floorY = 390;
const double actorHalfWidth = 14;
const double actorHitHeight = 92;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MaterialApp(
    title: 'Hermanas Pixel',
    debugShowCheckedModeBanner: false,
    home: HermanasGame(),
  ));
}

class HeroActor {
  HeroActor(this.x, this.y);
  double x;
  double y;
  double vx = 0;
  double vy = 0;
  double animDistance = 0;
  int direction = 1;
  bool onGround = true;
  bool doubleJumpUsed = false;
}

class HermanasGame extends StatefulWidget {
  const HermanasGame({super.key});

  @override
  State<HermanasGame> createState() => _HermanasGameState();
}

class _HermanasGameState extends State<HermanasGame>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController clock;
  final Map<String, ui.Image> resources = {};
  final List<HeroActor> heroes = [
    HeroActor(220, floorY), // Hermana mayor
    HeroActor(277, floorY), // Hermana pequeña
    HeroActor(110, floorY), // Padre
  ];
  final List<Rect> crates = [
    const Rect.fromLTWH(610, floorY - 48, 48, 48),
    const Rect.fromLTWH(790, floorY - 48, 48, 48),
    const Rect.fromLTWH(945, floorY - 48, 48, 48),
    const Rect.fromLTWH(945, floorY - 96, 48, 48),
  ];
  final List<Offset> coinPositions = [
    const Offset(440, 353), const Offset(505, 338),
    const Offset(632, 313), const Offset(705, 346),
    const Offset(811, 311), const Offset(888, 338),
    const Offset(970, 264),
  ];
  final Set<int> gatheredCoins = {};
  final Set<int> destroyedCrates = {};
  int selected = 0;
  bool leftHeld = false;
  bool rightHeld = false;
  bool completed = false;
  bool assetsReady = false;
  double camera = 0;
  double time = 0;
  double previousMicroseconds = 0;
  double footballX = -1000;
  double footballY = 0;
  double footballVX = 0;
  double footballVY = 0;
  double ballLife = 0;
  double sparkleUntil = 0;

  HeroActor get active => heroes[selected];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    clock = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )..addListener(_step)..forward();
    _loadResources();
  }

  Future<void> _loadResources() async {
    final entries = <String, String>{
      'background': 'assets/images/level_pixel.png',
      'crate': 'assets/images/crate.png',
      'coin': 'assets/images/coin.png',
    };
    for (final role in ['futbolista', 'bailarina', 'padre']) {
      for (final pose in ['idle_0', 'walk_0', 'walk_1', 'jump_0']) {
        entries['${role}_$pose'] = 'assets/images/frames/${role}_$pose.png';
      }
    }
    try {
      for (final entry in entries.entries) {
        final data = await rootBundle.load(entry.value);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        resources[entry.key] = (await codec.getNextFrame()).image;
        codec.dispose();
      }
      if (mounted) setState(() => assetsReady = true);
    } catch (error) {
      debugPrint('Error cargando recursos del juego: $error');
      if (mounted) setState(() => assetsReady = false);
    }
  }

  void _step() {
    final microseconds = clock.lastElapsedDuration?.inMicroseconds.toDouble() ?? 0;
    final double dt = previousMicroseconds == 0
        ? 0.016
        : ((microseconds - previousMicroseconds) / 1000000).clamp(0.0, 0.033).toDouble();
    previousMicroseconds = microseconds;
    if (dt <= 0 || !assetsReady) return;
    time += dt;
    if (completed) {
      if (mounted) setState(() {});
      return;
    }

    final input = (rightHeld ? 1 : 0) - (leftHeld ? 1 : 0);
    final leader = active;
    final wantedVelocity = input * 160.0;
    leader.vx = _toward(leader.vx, wantedVelocity, dt * (input == 0 ? 950 : 1050));
    if (input != 0) leader.direction = input;

    for (int i = 0; i < heroes.length; i++) {
      if (i == selected) continue;
      final companion = heroes[i];
      final gap = i == 2 ? 98.0 : 53.0;
      final destination = leader.x - gap * leader.direction;
      final distance = destination - companion.x;
      final wanted = distance.abs() > 11 ? distance.sign * math.min(140.0, distance.abs() * 2.8) : 0.0;
      companion.vx = _toward(companion.vx, wanted, dt * 600);
      if (companion.vx.abs() > 8) companion.direction = companion.vx.sign.toInt();
      if (companion.onGround && companion.vx.abs() > 18) {
        for (int c = 0; c < crates.length; c++) {
          if (destroyedCrates.contains(c)) continue;
          final crate = crates[c];
          final ahead = companion.vx > 0
              ? crate.left - (companion.x + actorHalfWidth)
              : (companion.x - actorHalfWidth) - crate.right;
          if (ahead > -4 && ahead < 36 && companion.y > crate.top + 3) {
            companion.vy = -380;
            companion.onGround = false;
            break;
          }
        }
      }
    }

    for (final hero in heroes) {
      final previousX = hero.x;
      final previousY = hero.y;
      final double nextX = (hero.x + hero.vx * dt).clamp(actorHalfWidth, worldWidth - actorHalfWidth).toDouble();
      hero.x = nextX;
      for (int i = 0; i < crates.length; i++) {
        if (destroyedCrates.contains(i)) continue;
        final block = crates[i];
        // Only sides obstruct a character whose vertical hitbox overlaps the box.
        if (hero.y > block.top + 3 && hero.y - actorHitHeight < block.bottom - 3) {
          if (hero.vx > 0 && previousX + actorHalfWidth <= block.left + 1 &&
              hero.x + actorHalfWidth > block.left) {
            hero.x = block.left - actorHalfWidth;
            hero.vx = 0;
          } else if (hero.vx < 0 && previousX - actorHalfWidth >= block.right - 1 &&
              hero.x - actorHalfWidth < block.right) {
            hero.x = block.right + actorHalfWidth;
            hero.vx = 0;
          }
        }
      }
      hero.vy = (hero.vy + 960 * dt).clamp(-480.0, 550.0).toDouble();
      hero.y += hero.vy * dt;
      hero.onGround = false;
      for (int i = 0; i < crates.length; i++) {
        if (destroyedCrates.contains(i)) continue;
        final block = crates[i];
        if (hero.x + actorHalfWidth <= block.left || hero.x - actorHalfWidth >= block.right) continue;
        if (hero.vy >= 0 && previousY <= block.top + 2 && hero.y >= block.top) {
          hero.y = block.top;
          hero.vy = 0;
          hero.onGround = true;
        } else if (hero.vy < 0 && previousY - actorHitHeight >= block.bottom - 2 &&
            hero.y - actorHitHeight < block.bottom) {
          hero.y = block.bottom + actorHitHeight;
          hero.vy = 0;
        }
      }
      if (hero.y >= floorY) {
        hero.y = floorY;
        hero.vy = 0;
        hero.onGround = true;
      }
      if (hero.onGround) hero.doubleJumpUsed = false;
      hero.animDistance += (hero.x - previousX).abs();
    }

    for (int i = 0; i < coinPositions.length; i++) {
      if (gatheredCoins.contains(i)) continue;
      final coin = coinPositions[i];
      if ((coin.dx - active.x).abs() < 26 && (coin.dy - (active.y - 43)).abs() < 33) {
        gatheredCoins.add(i);
        sparkleUntil = time + .28;
      }
    }
    if (footballX > -100) {
      footballX += footballVX * dt;
      footballVY += 560 * dt;
      footballY += footballVY * dt;
      ballLife += dt;
      for (int i = 0; i < crates.length; i++) {
        if (destroyedCrates.contains(i)) continue;
        if (crates[i].inflate(2).contains(Offset(footballX, footballY))) {
          destroyedCrates.add(i);
          footballX = -1000;
          sparkleUntil = time + .5;
          break;
        }
      }
      if (footballY > floorY - 5 || ballLife > 2.5 || footballX > worldWidth) footballX = -1000;
    }
    camera = _toward(camera, (active.x - 345).clamp(0.0, worldWidth - viewportWidth).toDouble(), 650 * dt);
    // The family reaches its parked car at the end of this deliberately short scene.
    if (active.x >= 1060) {
      completed = true;
      leftHeld = false;
      rightHeld = false;
    }
    if (mounted) setState(() {});
  }

  static double _toward(double from, double target, double step) {
    if ((target - from).abs() <= step) return target;
    return from + (target - from).sign * step;
  }

  void _jump() {
    final a = active;
    if (a.onGround) {
      a.vy = -399;
      a.onGround = false;
    }
  }

  void _special() {
    final a = active;
    if (selected == 0) {
      footballX = a.x + 26 * a.direction;
      footballY = a.y - 30;
      footballVX = 280 * a.direction;
      footballVY = -40;
      ballLife = 0;
    } else if (a.onGround) {
      a.vy = -410;
      a.onGround = false;
      a.doubleJumpUsed = false;
      sparkleUntil = time + .3;
    } else if (!a.doubleJumpUsed) {
      a.vy = -330;
      a.doubleJumpUsed = true;
      sparkleUntil = time + .3;
    }
  }

  void _reset() {
    heroes[0] = HeroActor(220, floorY);
    heroes[1] = HeroActor(277, floorY);
    heroes[2] = HeroActor(110, floorY);
    gatheredCoins.clear();
    destroyedCrates.clear();
    selected = 0;
    camera = 0;
    time = 0;
    completed = false;
    leftHeld = false;
    rightHeld = false;
    footballX = -1000;
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      leftHeld = false;
      rightHeld = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    clock.dispose();
    for (final image in resources.values) { image.dispose(); }
    super.dispose();
  }

  Widget _button(IconData icon, VoidCallback down, VoidCallback up,
      {double width = 58}) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) { down(); if (mounted) setState(() {}); },
      onPointerUp: (_) { up(); if (mounted) setState(() {}); },
      onPointerCancel: (_) { up(); if (mounted) setState(() {}); },
      child: Container(
        width: width, height: 58,
        decoration: BoxDecoration(
          color: const Color(0xb9153049),
          border: Border.all(color: const Color(0xffd7e7ee), width: 2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(icon, color: Colors.white, size: 29),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff142c45),
      body: LayoutBuilder(builder: (context, size) {
        final scale = math.min(size.maxWidth / viewportWidth, size.maxHeight / viewportHeight);
        final offX = (size.maxWidth - viewportWidth * scale) / 2;
        final offY = (size.maxHeight - viewportHeight * scale) / 2;
        return Stack(children: [
          Positioned.fill(child: CustomPaint(
            painter: StagePainter(resources, heroes, selected, camera, time,
                crates, destroyedCrates, coinPositions, gatheredCoins,
                footballX, footballY, sparkleUntil),
          )),
          if (!assetsReady)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else ...[
            Positioned(left: offX + 12 * scale, top: offY + 8 * scale,
              child: Text('HERMANAS PIXEL · DEMO 0.7.0',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                    fontSize: 14 * scale, shadows: const [Shadow(color: Colors.black, blurRadius: 4)]))),
            Positioned(right: offX + 16 * scale, top: offY + 8 * scale,
              child: Text('🟡 ${gatheredCoins.length}/${coinPositions.length}    ${selected == 0 ? '⚽ FUTBOLISTA' : '✦ BAILARINA'}',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                    fontSize: 15 * scale, shadows: const [Shadow(color: Colors.black, blurRadius: 4)]))),
            if (time < 9 && !completed)
              Positioned(top: offY + 40 * scale, left: offX + 30 * scale,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 7 * scale),
                  decoration: BoxDecoration(color: const Color(0xe518314c),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: const Color(0xffefd98c))),
                  child: Text(time < 2.6 ? 'PAPÁ: ¡Venga, chicas! ¿Estáis listas?'
                      : time < 4.8 ? 'FUTBOLISTA: ¡Yo sí! ¡Vamos!'
                      : time < 6.7 ? 'BAILARINA: ¡Espérame, que voy!'
                      : 'PAPÁ: ¡Pues en marcha!',
                    style: TextStyle(color: Colors.white, fontSize: 13 * scale)),
                )),
            Positioned(left: offX + 16 * scale, bottom: offY + 10 * scale,
              child: Transform.scale(scale: scale, alignment: Alignment.bottomLeft,
                child: Row(children: [
                  _button(Icons.arrow_back_rounded, () => leftHeld = true, () => leftHeld = false),
                  const SizedBox(width: 11),
                  _button(Icons.arrow_forward_rounded, () => rightHeld = true, () => rightHeld = false),
                ]))),
            Positioned(right: offX + 16 * scale, bottom: offY + 10 * scale,
              child: Transform.scale(scale: scale, alignment: Alignment.bottomRight,
                child: Row(children: [
                  _button(Icons.swap_horiz_rounded, () { selected = 1 - selected; }, () {}),
                  const SizedBox(width: 10),
                  _button(selected == 0 ? Icons.sports_soccer : Icons.auto_awesome, _special, () {}),
                  const SizedBox(width: 10),
                  _button(Icons.arrow_upward_rounded, _jump, () {}),
                ]))),
            if (completed)
              Positioned.fill(child: Center(child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: const Color(0xee102d43),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xfff6ce64), width: 3)),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('¡PRUEBA COMPLETADA!',
                    style: TextStyle(color: Color(0xffffd763), fontSize: 25, fontWeight: FontWeight.bold)),
                  Text('Monedas recogidas: ${gatheredCoins.length}/${coinPositions.length}',
                    style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 9),
                  TextButton(onPressed: _reset, child: const Text('VOLVER A JUGAR',
                    style: TextStyle(color: Colors.white))),
                ])))),
          ],
        ]);
      }),
    );
  }
}

class StagePainter extends CustomPainter {
  StagePainter(this.images, this.actors, this.selected, this.camera, this.time,
      this.crates, this.destroyed, this.pickups, this.collected,
      this.ballX, this.ballY, this.sparkleUntil);

  final Map<String, ui.Image> images;
  final List<HeroActor> actors;
  final int selected;
  final double camera, time;
  final List<Rect> crates;
  final Set<int> destroyed;
  final List<Offset> pickups;
  final Set<int> collected;
  final double ballX, ballY, sparkleUntil;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / viewportWidth, size.height / viewportHeight);
    final dx = (size.width - viewportWidth * scale) / 2;
    final dy = (size.height - viewportHeight * scale) / 2;
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale, scale);
    canvas.clipRect(const Rect.fromLTWH(0, 0, viewportWidth, viewportHeight));
    canvas.drawColor(const Color(0xff78bce8), BlendMode.src);
    final backdrop = images['background'];
    if (backdrop != null) {
      canvas.drawImageRect(backdrop,
        Rect.fromLTWH(camera, 0, viewportWidth, viewportHeight),
        const Rect.fromLTWH(0, 0, viewportWidth, viewportHeight),
        Paint()..filterQuality = FilterQuality.medium);
    }
    for (int i = 0; i < crates.length; i++) {
      if (destroyed.contains(i)) continue;
      final b = crates[i];
      _drawSprite(canvas, images['crate'], Rect.fromLTWH(b.left-camera, b.top, b.width, b.height));
    }
    for (int i = 0; i < pickups.length; i++) {
      if (collected.contains(i)) continue;
      final x = pickups[i].dx - camera;
      final y = pickups[i].dy + 3 * math.sin(time * 5 + i);
      final width = 21.0 * (.68 + .32 * math.cos(time * 6 + i).abs());
      _drawSprite(canvas, images['coin'], Rect.fromCenter(center: Offset(x,y), width: width, height: 23));
    }
    for (int i = 2; i >= 0; i--) {
      final a = actors[i];
      final name = ['futbolista','bailarina','padre'][i];
      final pose = !a.onGround ? 'jump_0'
          : a.vx.abs() > 13 ? 'walk_${(a.animDistance / 23).floor() % 2}'
          : 'idle_0';
      final sprite = images['${name}_$pose'];
      if (sprite == null) continue;
      final unitScale = i == 2 ? .43 : i == 0 ? .43 : .49;
      final w = sprite.width * unitScale;
      final h = sprite.height * unitScale;
      final screenX = a.x - camera;
      final screenY = a.y;
      canvas.drawOval(Rect.fromCenter(center: Offset(screenX, floorY+1),
          width: w*.67, height: 8), Paint()..color = const Color(0x77061e22));
      canvas.save();
      if (a.direction < 0) {
        canvas.translate(screenX, 0);
        canvas.scale(-1, 1);
        canvas.translate(-screenX, 0);
      }
      // Each PNG has 8 transparent pixels below the feet: use the same foot anchor for all poses.
      _drawSprite(canvas,sprite,Rect.fromLTWH(screenX-w/2,
          screenY - h + 8*unitScale, w, h),pixelated:false);
      canvas.restore();
      if (i == selected) {
        canvas.drawArc(Rect.fromCenter(center:Offset(screenX,screenY+4),width:43,height:13),
            0, math.pi, false, Paint()..color=const Color(0xfff9df72)
              ..strokeWidth=2..style=PaintingStyle.stroke);
      }
    }
    if (ballX > -100) {
      canvas.drawCircle(Offset(ballX-camera,ballY),9,
          Paint()..color=Colors.white);
      canvas.drawCircle(Offset(ballX-camera,ballY),4,
          Paint()..color=const Color(0xff24415c));
    }
    if (time < sparkleUntil) {
      final x = actors[selected].x-camera;
      final y = actors[selected].y-80;
      for (int i=0;i<6;i++) {
        final a=i*math.pi/3+time*4;
        canvas.drawCircle(Offset(x+30*math.cos(a),y+25*math.sin(a)),
            3,Paint()..color=const Color(0xfff7dd59));
      }
    }
    canvas.restore();
  }

  static void _drawSprite(Canvas canvas,ui.Image? image,Rect target,{bool pixelated=true}) {
    if(image==null)return;
    canvas.drawImageRect(image,Rect.fromLTWH(0,0,image.width.toDouble(),image.height.toDouble()),
        target,Paint()..filterQuality=(pixelated?FilterQuality.none:FilterQuality.low));
  }

  @override
  bool shouldRepaint(covariant StagePainter oldDelegate) => true;
}
