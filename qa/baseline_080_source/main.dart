import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const double viewW = 800;
const double viewH = 450;
const double groundY = 390;
const double stageWidth = 1570;
const double actorRadius = 14;
const double actorHeight = 91;
const String saveKey = 'miren_sara_v080_save';

const List<String> chapterNames = [
  'La salida de casa',
  'Ayuntamiento de Pamplona',
  'Calle Estafeta',
  'Plaza del Castillo',
];
const List<String> sceneryFiles = [
  'level_pixel',
  'level_ayuntamiento',
  'level_estafeta',
  'level_plaza_castillo',
];

enum GameScreen { title, choose, introduction, playing, chapterEnd, gameOver, victory, paused }
enum DogMood { idle, walk, alert, run, bite, hit, stunned, defeated }

class Character {
  Character(this.x, {this.y = groundY});
  double x;
  double y;
  double vx = 0;
  double vy = 0;
  double travelled = 0;
  int facing = 1;
  bool grounded = true;
  double hurtUntil = 0;
}

class DogEnemy {
  DogEnemy(this.id, this.x)
      : origin = x,
        patrolLeft = x - 95,
        patrolRight = x + 95;
  final int id;
  final double origin;
  final double patrolLeft;
  final double patrolRight;
  double x;
  int facing = -1;
  DogMood mood = DogMood.walk;
  double modeTime = 0;
  double cooldown = 0;
  bool hasBitThisAttack = false;
}

class FlyingItem {
  FlyingItem({required this.x, required this.y, required this.vx, required this.kind});
  double x;
  double y;
  double vx;
  double vy = -45;
  final int kind; // 0 balón de Miren, 1 peine de Sara.
  double life = 0;
  bool active = true;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Las aventuras de Miren y Sara',
    home: HermanasGame(),
  ));
}

class HermanasGame extends StatefulWidget {
  const HermanasGame({super.key});
  @override
  State<HermanasGame> createState() => _HermanasGameState();
}

class _HermanasGameState extends State<HermanasGame>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController ticker;
  final Map<String, ui.Image> images = {};
  SharedPreferences? storage;
  bool resourcesReady = false;
  bool savedAvailable = false;
  String? loadError;
  GameScreen screen = GameScreen.title;
  final List<Character> sisters = [Character(160), Character(97)];
  final Character father = Character(45);
  final List<int> hearts = [2, 2];
  final List<Rect> obstacles = [];
  final List<Offset> coins = [];
  final Set<int> collected = {};
  final Set<int> smashedCrates = {};
  final Set<int> defeatedDogs = {};
  final List<DogEnemy> dogs = [];
  final List<FlyingItem> projectiles = [];
  int stage = 0;
  int selected = 0;
  int totalCoins = 0;
  int finishedStage = 0;
  int introLine = 0;
  bool introPlayed = false;
  bool leftHeld = false;
  bool rightHeld = false;
  double time = 0;
  double lastMicroseconds = 0;
  double lastSaveTime = 0;
  double cameraX = 0;
  double effectUntil = 0;
  double lastAttackTime = -10;
  double lastCheckpointX = 135;
  bool saving = false;

  Character get active => sisters[selected];
  Character get follower => sisters[1 - selected];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ticker = AnimationController(vsync: this, duration: const Duration(days: 1))
      ..addListener(_tick)
      ..forward();
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      storage = await SharedPreferences.getInstance();
      savedAvailable = storage?.getString(saveKey) != null;
      final paths = <String, String>{
        'title': 'assets/images/title_approved.png',
        'logo': 'assets/images/brand_logo_twc.png',
        'crate': 'assets/images/crate.png',
        'coin': 'assets/images/coin.png',
        'ball': 'assets/images/ball.png',
        'comb': 'assets/images/comb.png',
      };
      for (int i = 0; i < sceneryFiles.length; i++) {
        paths['scene_$i'] = 'assets/images/${sceneryFiles[i]}.png';
      }
      for (final role in ['futbolista', 'bailarina', 'padre']) {
        for (final pose in ['idle_0', 'walk_0', 'walk_1', 'jump_0']) {
          paths['${role}_$pose'] = 'assets/images/frames/${role}_$pose.png';
        }
      }
      for (final pose in ['idle', 'walk', 'alert', 'run', 'bite', 'hit', 'stunned', 'defeated']) {
        paths['dog_$pose'] = 'assets/images/dog/$pose.png';
      }
      for (final entry in paths.entries) {
        final data = await rootBundle.load(entry.value);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        images[entry.key] = frame.image;
        codec.dispose();
      }
      _layoutStage();
      if (mounted) setState(() => resourcesReady = true);
    } catch (e, stack) {
      debugPrint('No se pudieron cargar recursos: $e\n$stack');
      if (mounted) setState(() => loadError = '$e');
    }
  }

  void _layoutStage() {
    obstacles.clear();
    coins.clear();
    dogs.clear();
    collected.clear();
    smashedCrates.clear();
    defeatedDogs.clear();
    // Obstáculos separados de las fachadas para que suelo y colisiones coincidan.
    for (final x in [460.0, 760.0, 1015.0, 1290.0]) {
      obstacles.add(Rect.fromLTWH(x + stage % 2 * 14, groundY - 42, 42, 42));
    }
    if (stage >= 1) obstacles.add(const Rect.fromLTWH(1030, groundY - 73, 42, 31));
    for (int i = 0; i < 16; i++) {
      final double x = 270 + i * 78.0;
      double y = 348.0;
      if (i % 5 == 2) y = 299;
      if (i % 5 == 3) y = 309;
      if (i == 10 || i == 13) y = 288;
      coins.add(Offset(x, y));
    }
    if (stage == 0) {
      dogs.add(DogEnemy(0, 1140));
    } else if (stage == 1) {
      dogs.add(DogEnemy(0, 820));
      dogs.add(DogEnemy(1, 1250));
    } else if (stage == 2) {
      dogs.add(DogEnemy(0, 685));
      dogs.add(DogEnemy(1, 1300));
    } else {
      dogs.add(DogEnemy(0, 980));
    }
  }

  void _setStageStart({double initialX = 145}) {
    sisters[selected] = Character(initialX);
    sisters[1 - selected] = Character(math.max(38.0, initialX - 68));
    father.x = 48;
    father.y = groundY;
    cameraX = 0;
    projectiles.clear();
    lastCheckpointX = 145;
    lastAttackTime = -10;
    leftHeld = false;
    rightHeld = false;
    _layoutStage();
  }

  Future<void> _beginFreshGame() async {
    if (savedAvailable) {
      final answer = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¿Comenzar nueva partida?'),
          content: const Text('Se sustituirá el progreso guardado de la partida anterior.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCELAR')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('NUEVA PARTIDA')),
          ],
        ),
      );
      if (answer != true || !mounted) return;
    }
    await storage?.remove(saveKey);
    stage = 0;
    selected = 0;
    totalCoins = 0;
    hearts[0] = 2;
    hearts[1] = 2;
    introPlayed = false;
    introLine = 0;
    savedAvailable = false;
    _setStageStart();
    if (mounted) setState(() => screen = GameScreen.choose);
  }

  void _choose(int index) {
    selected = index;
    hearts[selected] = hearts[selected].clamp(1, 2).toInt();
    _setStageStart();
    if (stage == 0 && !introPlayed) {
      introLine = 0;
      screen = GameScreen.introduction;
    } else {
      screen = GameScreen.playing;
    }
    _saveGame();
    setState(() {});
  }

  Future<void> _continueGame() async {
    final text = storage?.getString(saveKey);
    if (text == null) return;
    try {
      final json = jsonDecode(text) as Map<String, dynamic>;
      stage = ((json['stage'] as num?)?.toInt() ?? 0).clamp(0, 3).toInt();
      selected = ((json['selected'] as num?)?.toInt() ?? 0).clamp(0, 1).toInt();
      totalCoins = ((json['totalCoins'] as num?)?.toInt() ?? 0).clamp(0, 9999).toInt();
      hearts[0] = ((json['mirenHearts'] as num?)?.toInt() ?? 2).clamp(0, 2).toInt();
      hearts[1] = ((json['saraHearts'] as num?)?.toInt() ?? 2).clamp(0, 2).toInt();
      introPlayed = true;
      _setStageStart();
      active.x = ((json['x'] as num?)?.toDouble() ?? 145).clamp(40.0, stageWidth - 35).toDouble();
      follower.x = math.max(35.0, active.x - 65);
      cameraX = (active.x - 300).clamp(0.0, stageWidth - viewW).toDouble();
      for (final x in (json['coins'] as List<dynamic>? ?? [])) {
        final index = (x as num).toInt();
        if (index >= 0 && index < coins.length) collected.add(index);
      }
      for (final x in (json['crates'] as List<dynamic>? ?? [])) {
        smashedCrates.add((x as num).toInt());
      }
      for (final x in (json['dogs'] as List<dynamic>? ?? [])) {
        final i = (x as num).toInt();
        defeatedDogs.add(i);
        if (i < dogs.length) dogs[i].mood = DogMood.defeated;
      }
      lastCheckpointX = (active.x / 400).floor() * 400.0;
      if (hearts[selected] == 0) hearts[selected] = 2;
      screen = (json['atBoundary'] == true) ? GameScreen.choose : GameScreen.playing;
      if (mounted) setState(() {});
    } catch (error) {
      debugPrint('Partida guardada dañada: $error');
      if (mounted) setState(() { savedAvailable = false; });
    }
  }

  Future<void> _saveGame({bool atBoundary = false}) async {
    if (storage == null || saving || !resourcesReady) return;
    if (screen == GameScreen.title) return;
    saving = true;
    try {
      final info = <String, dynamic>{
        'version': 2,
        'stage': stage,
        'selected': selected,
        'x': atBoundary ? 145.0 : active.x,
        'mirenHearts': hearts[0],
        'saraHearts': hearts[1],
        'totalCoins': totalCoins,
        'coins': atBoundary ? <int>[] : collected.toList()..sort(),
        'crates': atBoundary ? <int>[] : smashedCrates.toList()..sort(),
        'dogs': atBoundary ? <int>[] : defeatedDogs.toList()..sort(),
        'atBoundary': atBoundary,
      };
      await storage!.setString(saveKey, jsonEncode(info));
      savedAvailable = true;
    } catch (error) {
      debugPrint('No se pudo guardar: $error');
    } finally {
      saving = false;
    }
  }

  void _nextIntroLine() {
    introLine++;
    if (introLine >= 4) {
      introPlayed = true;
      screen = GameScreen.playing;
      _saveGame();
    }
    setState(() {});
  }

  static double _approach(double from, double to, double step) {
    if ((to - from).abs() <= step) return to;
    return from + (to - from).sign * step;
  }

  void _tick() {
    final micros = ticker.lastElapsedDuration?.inMicroseconds.toDouble() ?? 0;
    final dt = lastMicroseconds == 0
        ? .016
        : ((micros - lastMicroseconds) / 1000000).clamp(0.0, .033).toDouble();
    lastMicroseconds = micros;
    if (dt <= 0 || !resourcesReady) return;
    time += dt;
    if (screen != GameScreen.playing) {
      if (screen == GameScreen.introduction && mounted) setState(() {});
      return;
    }

    final input = (rightHeld ? 1 : 0) - (leftHeld ? 1 : 0);
    final a = active;
    a.vx = _approach(a.vx, input * 169.0, dt * (input == 0 ? 800 : 1040));
    if (input != 0) a.facing = input;
    // La hermana no seleccionada NUNCA recibe directamente las órdenes del jugador.
    final target = active.x - 66 * active.facing;
    final gap = target - follower.x;
    final followSpeed = gap.abs() > 25 ? gap.sign * math.min(126.0, gap.abs() * 2.5) : 0.0;
    follower.vx = _approach(follower.vx, followSpeed, dt * 620);
    if (follower.vx.abs() > 9) follower.facing = follower.vx.sign.toInt();
    if (follower.grounded && follower.vx.abs() > 18) {
      for (int i = 0; i < obstacles.length; i++) {
        if (smashedCrates.contains(i)) continue;
        final block = obstacles[i];
        final gapAhead = follower.vx > 0 ? block.left - follower.x - actorRadius : follower.x - actorRadius - block.right;
        if (gapAhead > -6 && gapAhead < 38 && follower.y > block.top + 2) {
          follower.vy = -409;
          follower.grounded = false;
          break;
        }
      }
    }

    for (final hero in sisters) {
      final previousX = hero.x;
      final previousY = hero.y;
      hero.x = (hero.x + hero.vx * dt).clamp(actorRadius, stageWidth - actorRadius).toDouble();
      for (int i = 0; i < obstacles.length; i++) {
        if (smashedCrates.contains(i)) continue;
        final block = obstacles[i];
        if (hero.y > block.top + 3 && hero.y - actorHeight < block.bottom - 3) {
          if (hero.vx > 0 && previousX + actorRadius <= block.left + 1 && hero.x + actorRadius > block.left) {
            hero.x = block.left - actorRadius;
            hero.vx = 0;
          } else if (hero.vx < 0 && previousX - actorRadius >= block.right - 1 && hero.x - actorRadius < block.right) {
            hero.x = block.right + actorRadius;
            hero.vx = 0;
          }
        }
      }
      hero.vy = (hero.vy + 960 * dt).clamp(-500.0, 650.0).toDouble();
      hero.y += hero.vy * dt;
      hero.grounded = false;
      for (int i = 0; i < obstacles.length; i++) {
        if (smashedCrates.contains(i)) continue;
        final block = obstacles[i];
        if (hero.x + actorRadius <= block.left || hero.x - actorRadius >= block.right) continue;
        if (hero.vy >= 0 && previousY <= block.top + 2 && hero.y >= block.top) {
          hero.y = block.top;
          hero.vy = 0;
          hero.grounded = true;
        } else if (hero.vy < 0 && previousY - actorHeight >= block.bottom - 2 && hero.y - actorHeight < block.bottom) {
          hero.y = block.bottom + actorHeight;
          hero.vy = 0;
        }
      }
      if (hero.y >= groundY) {
        hero.y = groundY;
        hero.vy = 0;
        hero.grounded = true;
      }
      hero.travelled += (hero.x - previousX).abs();
    }

    for (int i = 0; i < coins.length; i++) {
      if (collected.contains(i)) continue;
      if ((coins[i].dx - a.x).abs() < 24 && (coins[i].dy - (a.y - 43)).abs() < 40) {
        collected.add(i);
        totalCoins++;
        effectUntil = time + .30;
      }
    }
    for (final shot in projectiles) {
      if (!shot.active) continue;
      shot.x += shot.vx * dt;
      shot.vy += 560 * dt;
      shot.y += shot.vy * dt;
      shot.life += dt;
      for (int i = 0; i < obstacles.length; i++) {
        if (smashedCrates.contains(i)) continue;
        if (obstacles[i].inflate(4).contains(Offset(shot.x, shot.y))) {
          smashedCrates.add(i);
          shot.active = false;
          effectUntil = time + .33;
          break;
        }
      }
      if (!shot.active) continue;
      for (final dog in dogs) {
        if (dog.mood == DogMood.defeated || dog.mood == DogMood.hit || dog.mood == DogMood.stunned) continue;
        if ((shot.x - dog.x).abs() < 36 && (shot.y - (groundY - 28)).abs() < 43) {
          dog.mood = DogMood.hit;
          dog.modeTime = 0;
          shot.active = false;
          defeatedDogs.add(dog.id);
          effectUntil = time + .6;
          break;
        }
      }
      if (shot.y > groundY || shot.life > 2.6 || shot.x < 0 || shot.x > stageWidth) shot.active = false;
    }
    projectiles.removeWhere((x) => !x.active);

    for (final dog in dogs) {
      dog.modeTime += dt;
      dog.cooldown = math.max(0.0, dog.cooldown - dt);
      if (dog.mood == DogMood.defeated) continue;
      if (dog.mood == DogMood.hit) {
        if (dog.modeTime > .32) {
          dog.mood = DogMood.stunned;
          dog.modeTime = 0;
        }
        continue;
      }
      if (dog.mood == DogMood.stunned) {
        if (dog.modeTime > .6) {
          dog.mood = DogMood.defeated;
          dog.modeTime = 0;
        }
        continue;
      }
      final distance = a.x - dog.x;
      if (dog.mood == DogMood.bite) {
        if (!dog.hasBitThisAttack && dog.modeTime > .18 && dog.modeTime < .58 && distance.abs() < 44 && a.y > groundY - 38) {
          dog.hasBitThisAttack = true;
          _receiveBite(dog.facing);
        }
        if (dog.modeTime >= .68) {
          dog.mood = DogMood.run;
          dog.modeTime = 0;
          dog.cooldown = 1.4;
        }
        continue;
      }
      if (distance.abs() < 205 && dog.cooldown <= 0) {
        dog.facing = distance >= 0 ? 1 : -1;
        if (distance.abs() <= 48) {
          dog.mood = DogMood.bite;
          dog.hasBitThisAttack = false;
          dog.modeTime = 0;
        } else {
          dog.mood = DogMood.run;
          dog.x += dog.facing * 94 * dt;
        }
      } else {
        dog.mood = dog.cooldown > 0 ? DogMood.alert : DogMood.walk;
        if (dog.cooldown == 0) {
          dog.x += dog.facing * 32 * dt;
          if (dog.x < dog.patrolLeft || dog.x > dog.patrolRight) dog.facing = -dog.facing;
        }
      }
      // Colisión propia del enemigo: no atraviesa las cajas.
      for (int i = 0; i < obstacles.length; i++) {
        if (smashedCrates.contains(i)) continue;
        final block = obstacles[i];
        if (dog.x + 27 > block.left && dog.x - 27 < block.right) {
          dog.x = dog.facing > 0 ? block.left - 27 : block.right + 27;
          dog.facing = -dog.facing;
          dog.cooldown = math.max(dog.cooldown, .55);
          dog.mood = DogMood.alert;
          break;
        }
      }
      dog.x = dog.x.clamp(55.0, stageWidth - 40).toDouble();
    }

    cameraX = _approach(cameraX,
        (active.x - 330).clamp(0.0, stageWidth - viewW).toDouble(), dt * 550);
    if (active.x > lastCheckpointX + 420) {
      lastCheckpointX = active.x;
      _saveGame();
    }
    if (time > lastSaveTime + 8) {
      lastSaveTime = time;
      _saveGame();
    }
    if (active.x >= stageWidth - 55) _endChapter();
    if (mounted) setState(() {});
  }

  void _receiveBite(int facing) {
    if (time < active.hurtUntil || hearts[selected] <= 0) return;
    hearts[selected] = math.max(0, hearts[selected] - 1);
    active.hurtUntil = time + 1.45;
    active.vx = facing * 200;
    active.vy = -270;
    active.grounded = false;
    effectUntil = time + .45;
    if (hearts[selected] == 0) {
      screen = GameScreen.gameOver;
      leftHeld = false;
      rightHeld = false;
    }
    _saveGame();
  }

  void _jump() {
    if (screen != GameScreen.playing) return;
    if (active.grounded) {
      active.vy = -410;
      active.grounded = false;
    }
  }

  void _attack() {
    if (screen != GameScreen.playing || time - lastAttackTime < .5) return;
    lastAttackTime = time;
    projectiles.add(FlyingItem(
      x: active.x + active.facing * 28,
      y: active.y - 42,
      vx: active.facing * (selected == 0 ? 320.0 : 360.0),
      kind: selected,
    ));
    effectUntil = time + .24;
  }

  void _endChapter() {
    if (screen != GameScreen.playing) return;
    leftHeld = false;
    rightHeld = false;
    finishedStage = stage;
    if (stage == chapterNames.length - 1) {
      screen = GameScreen.victory;
    } else {
      stage++;
      _saveGame(atBoundary: true);
      screen = GameScreen.chapterEnd;
    }
  }

  void _restartCheckpoint() {
    hearts[selected] = 2;
    active.x = math.max(140.0, lastCheckpointX);
    active.y = groundY;
    active.vx = 0;
    active.vy = 0;
    follower.x = math.max(40.0, active.x - 67);
    for (final dog in dogs) {
      if ((dog.x - active.x).abs() < 140 && dog.mood != DogMood.defeated) {
        dog.x = math.min(stageWidth - 70, active.x + 230);
        dog.cooldown = 2;
        dog.mood = DogMood.walk;
      }
    }
    screen = GameScreen.playing;
    _saveGame();
    setState(() {});
  }

  void _nextChapter() {
    _setStageStart();
    screen = GameScreen.choose;
    _saveGame(atBoundary: true);
    setState(() {});
  }

  void _returnToTitle() {
    if (screen != GameScreen.victory) _saveGame();
    leftHeld = false;
    rightHeld = false;
    screen = GameScreen.title;
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      leftHeld = false;
      rightHeld = false;
      if (screen == GameScreen.playing) {
        _saveGame();
        screen = GameScreen.paused;
        if (mounted) setState(() {});
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ticker.dispose();
    for (final im in images.values) { im.dispose(); }
    super.dispose();
  }

  Widget _control(IconData icon, VoidCallback down, VoidCallback up, {double width = 63}) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) { down(); if (mounted) setState(() {}); },
      onPointerUp: (_) { up(); if (mounted) setState(() {}); },
      onPointerCancel: (_) { up(); if (mounted) setState(() {}); },
      child: Container(
        width: width, height: 61,
        decoration: BoxDecoration(
          color: const Color(0xc3123456),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.white.withValues(alpha: .82), width: 2),
          boxShadow: const [BoxShadow(color: Color(0x55091427), blurRadius: 3, offset: Offset(1, 3))],
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _pixelButton(String text, VoidCallback? onPressed,
      {bool golden = false, double width = 235}) {
    return SizedBox(
      width: width, height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: golden ? const Color(0xffe49a0c) : const Color(0xff0755a5),
          disabledBackgroundColor: const Color(0xff44546a),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
            side: const BorderSide(color: Color(0xffffe9a4), width: 3),
          ),
        ),
        child: Text(text, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900,
            shadows: [Shadow(color: Color(0xff09152e), offset: Offset(2, 2))])),
      ),
    );
  }

  Widget _dialogPanel(String heading, String body, VoidCallback callback) {
    return Positioned(
      left: 165, top: 255, width: 470, height: 130,
      child: GestureDetector(
        onTap: callback,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 9),
          decoration: BoxDecoration(
            color: const Color(0xf211294b),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: const Color(0xffffd56a), width: 3),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(heading, style: const TextStyle(color: Color(0xffffde78), fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(body, style: const TextStyle(color: Colors.white, fontSize: 18)),
            const Spacer(),
            const Align(alignment: Alignment.bottomRight,
              child: Text('TOCA PARA SEGUIR  ▶', style: TextStyle(color: Color(0xffffd56a), fontSize: 11))),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff102a41),
      body: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(width: viewW, height: viewH, child: _screenContent()),
        ),
      ),
    );
  }

  Widget _screenContent() {
    if (loadError != null) {
      return ColoredBox(color: const Color(0xff122d46), child: Center(
        child: Padding(padding: const EdgeInsets.all(20), child: Text(
          'ERROR AL CARGAR LOS RECURSOS\n$loadError',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        )),
      ));
    }
    if (!resourcesReady) return const Center(child: CircularProgressIndicator(color: Colors.amber));
    switch (screen) {
      case GameScreen.title:
        return _titleScreen();
      case GameScreen.choose:
        return _choiceScreen();
      case GameScreen.introduction:
        return _gameScreen(showFather: true);
      case GameScreen.playing:
        return _gameScreen(showFather: false);
      case GameScreen.chapterEnd:
        return _gameScreen(showFather: false, overlay: _chapterOverlay());
      case GameScreen.gameOver:
        return _gameScreen(showFather: false, overlay: _gameOverOverlay());
      case GameScreen.victory:
        return _gameScreen(showFather: false, overlay: _victoryOverlay());
      case GameScreen.paused:
        return _gameScreen(showFather: false, overlay: _pauseOverlay());
    }
  }

  Widget _titleScreen() {
    // Obra gráfica APROBADA: imagen sin cambios ni recortes del título.
    // Los botones son zonas táctiles sobre la propia imagen, no un menú de otro estilo.
    return Stack(children: [
      Positioned.fill(child: Image.asset('assets/images/title_approved.png', fit: BoxFit.fill)),
      Positioned(left: 551, top: 183, width: 208, height: 59,
        child: Material(color: Colors.transparent, child: InkWell(onTap: _beginFreshGame,
          borderRadius: BorderRadius.circular(6)))),
      Positioned(left: 557, top: 249, width: 203, height: 61,
        child: Material(color: savedAvailable ? Colors.transparent : const Color(0x99404b63),
          child: InkWell(onTap: savedAvailable ? _continueGame : null,
            borderRadius: BorderRadius.circular(6)))),
      if (!savedAvailable) const Positioned(left: 578, top: 299,
        child: Text('Sin partida guardada', style: TextStyle(color: Colors.white, fontSize: 11,
            shadows: [Shadow(color: Colors.black, blurRadius: 3)]))),
      Positioned(left: 303, bottom: 4, width: 194, height: 43,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xa0092749),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: const Color(0x99e8c27d), width: 1),
          ),
          child: Image.asset('assets/images/brand_logo_twc.png', fit: BoxFit.contain),
        )),
    ]);
  }

  Widget _choiceScreen() {
    return Stack(children: [
      Positioned.fill(child: Image.asset('assets/images/${sceneryFiles[stage]}.png', fit: BoxFit.cover)),
      Positioned.fill(child: Container(color: const Color(0x990c213a))),
      const Positioned(left: 0, right: 0, top: 15,
        child: Text('ELIGE TU PROTAGONISTA', textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xffffe18e), fontSize: 27, fontWeight: FontWeight.w900,
            shadows: [Shadow(color: Colors.black, blurRadius: 4)]))),
      Positioned(left: 0, right: 0, top: 54,
        child: Text('CAPÍTULO ${stage + 1} · ${chapterNames[stage]}', textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
      _choiceCard(0, 140),
      _choiceCard(1, 414),
      Positioned(left: 15, bottom: 10, child: TextButton(
        onPressed: _returnToTitle, child: const Text('◀ VOLVER', style: TextStyle(color: Colors.white)))),
    ]);
  }

  Widget _choiceCard(int index, double x) {
    final role = index == 0 ? 'futbolista' : 'bailarina';
    return Positioned(
      left: x, top: 94, width: 246, height: 332,
      child: GestureDetector(
        onTap: () => _choose(index),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xff073c73), Color(0xff05182e)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: index == 0 ? const Color(0xffffd45b) : const Color(0xffff9dcd), width: 4),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 6)],
          ),
          child: Column(children: [
            const SizedBox(height: 6),
            Text(index == 0 ? 'MIREN' : 'SARA',
              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
            SizedBox(height: 175, child: Image.asset('assets/images/frames/${role}_idle_0.png', fit: BoxFit.contain)),
            const SizedBox(height: 3),
            Text(index == 0 ? '⚽  BALÓN' : '✦  PEINE',
              style: const TextStyle(color: Color(0xffffd475), fontSize: 18, fontWeight: FontWeight.w900)),
            const Text('♥   ♥', style: TextStyle(color: Color(0xffff647b), fontSize: 26)),
            const Spacer(),
            const Text('TOCA PARA ELEGIR', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 11),
          ]),
        ),
      ),
    );
  }

  Widget _gameScreen({required bool showFather, Widget? overlay}) {
    return Stack(children: [
      Positioned.fill(child: CustomPaint(painter: StagePainter(
        images: images, stage: stage, cameraX: cameraX, time: time,
        sisters: sisters, father: father, showFather: showFather, selected: selected,
        obstacles: obstacles, smashedCrates: smashedCrates, coins: coins,
        collected: collected, dogs: dogs, shots: projectiles,
        effectUntil: effectUntil,
      ))),
      Positioned(left: 8, top: 8,
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xb40b2949), borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0x99ffffff))),
          child: Text('${selected == 0 ? 'MIREN' : 'SARA'}  ${hearts[selected] >= 1 ? '❤️' : '🖤'} ${hearts[selected] >= 2 ? '❤️' : '🖤'}',
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)))),
      Positioned(left: 276, top: 8,
        child: Container(padding: const EdgeInsets.all(7), color: const Color(0xb40b2949),
          child: Text('CAP. ${stage + 1} · ${chapterNames[stage]}',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)))),
      Positioned(right: 10, top: 8,
        child: Container(padding: const EdgeInsets.all(7), color: const Color(0xb40b2949),
          child: Text('🟡 $totalCoins', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)))),
      if (screen == GameScreen.playing) ...[
        Positioned(left: 15, bottom: 12, child: Row(children: [
          _control(Icons.arrow_back_rounded, () => leftHeld = true, () => leftHeld = false),
          const SizedBox(width: 10),
          _control(Icons.arrow_forward_rounded, () => rightHeld = true, () => rightHeld = false),
        ])),
        Positioned(right: 15, bottom: 12, child: Row(children: [
          _control(selected == 0 ? Icons.sports_soccer : Icons.brush_rounded, _attack, () {}),
          const SizedBox(width: 12),
          _control(Icons.arrow_upward_rounded, _jump, () {}),
        ])),
        Positioned(right: 8, top: 45, child: IconButton(
          onPressed: () { leftHeld = false; rightHeld = false; _saveGame(); setState(() => screen = GameScreen.paused); },
          icon: const Icon(Icons.pause_circle_filled_rounded, color: Colors.white, size: 27))),
      ],
      if (screen == GameScreen.introduction)
        _dialogPanel(['PAPÁ', 'MIREN', 'SARA', 'PAPÁ'][introLine],
          ['¡Venga, chicas! ¿Estáis listas?', '¡Yo sí! ¡Vamos!',
            '¡Espérame, que voy!', '¡Pues en marcha!'][introLine], _nextIntroLine),
      if (overlay != null) overlay,
    ]);
  }

  Widget _overlayFrame(String headline, String detail, List<Widget> buttons) {
    return Positioned.fill(child: ColoredBox(
      color: const Color(0x9f061324),
      child: Center(child: Container(
        width: 485,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xf0113255), borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0xffffd86c), width: 4)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(headline, textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xffffd86c), fontSize: 27, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text(detail, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 19),
          ...buttons.map((b) => Padding(padding: const EdgeInsets.only(bottom: 10), child: b)),
        ]),
      )),
    ));
  }

  Widget _chapterOverlay() => _overlayFrame(
    '¡CAPÍTULO ${finishedStage + 1} COMPLETADO!',
    'Monedas recogidas en total: $totalCoins\nAhora puedes elegir a Miren o Sara para la siguiente fase.',
    [_pixelButton('SIGUIENTE CAPÍTULO', _nextChapter, golden: true),
     _pixelButton('MENÚ PRINCIPAL', _returnToTitle)],
  );

  Widget _gameOverOverlay() => _overlayFrame(
    '¡SIN CORAZONES!',
    'El perro os ha alcanzado. Puedes volver a intentarlo desde el último punto de control.',
    [_pixelButton('REINTENTAR', _restartCheckpoint, golden: true),
     _pixelButton('MENÚ PRINCIPAL', _returnToTitle)],
  );

  Widget _victoryOverlay() => _overlayFrame(
    '¡AVENTURA COMPLETADA!',
    '¡Miren y Sara han recorrido Pamplona!\nMonedas recogidas: $totalCoins',
    [_pixelButton('VOLVER AL INICIO', () {
      storage?.remove(saveKey);
      savedAvailable = false;
      screen = GameScreen.title;
      setState(() {});
    }, golden: true)],
  );

  Widget _pauseOverlay() => _overlayFrame(
    'PAUSA', 'Tu progreso se guarda automáticamente en el móvil.',
    [_pixelButton('SEGUIR JUGANDO', () => setState(() => screen = GameScreen.playing), golden: true),
     _pixelButton('MENÚ PRINCIPAL', _returnToTitle)],
  );
}

class StagePainter extends CustomPainter {
  StagePainter({
    required this.images, required this.stage, required this.cameraX,
    required this.time, required this.sisters, required this.father,
    required this.showFather, required this.selected, required this.obstacles,
    required this.smashedCrates, required this.coins, required this.collected,
    required this.dogs, required this.shots, required this.effectUntil,
  });
  final Map<String, ui.Image> images;
  final int stage;
  final double cameraX;
  final double time;
  final List<Character> sisters;
  final Character father;
  final bool showFather;
  final int selected;
  final List<Rect> obstacles;
  final Set<int> smashedCrates;
  final List<Offset> coins;
  final Set<int> collected;
  final List<DogEnemy> dogs;
  final List<FlyingItem> shots;
  final double effectUntil;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(const Rect.fromLTWH(0, 0, viewW, viewH));
    canvas.drawColor(const Color(0xff5daee0), BlendMode.src);
    final backdrop = images['scene_$stage'];
    if (backdrop != null) {
      final srcW = backdrop.width * (viewW / stageWidth);
      final srcX = backdrop.width * cameraX / stageWidth;
      _sprite(canvas, backdrop, const Rect.fromLTWH(0, 0, viewW, viewH),
        source: Rect.fromLTWH(srcX, 0, srcW, viewH));
    }
    for (int i = 0; i < obstacles.length; i++) {
      if (smashedCrates.contains(i)) continue;
      final rect = obstacles[i];
      _sprite(canvas, images['crate'], Rect.fromLTWH(rect.left - cameraX, rect.top, rect.width, rect.height));
    }
    for (int i = 0; i < coins.length; i++) {
      if (collected.contains(i)) continue;
      final p = coins[i];
      final x = p.dx - cameraX;
      if (x < -24 || x > 824) continue;
      final y = p.dy + 4 * math.sin(time * 5 + i);
      final w = 20.0 * (.65 + .35 * math.cos(time * 6 + i).abs());
      _sprite(canvas, images['coin'], Rect.fromCenter(center: Offset(x, y), width: w, height: 24));
    }
    for (final dog in dogs) {
      if (dog.mood == DogMood.defeated && dog.modeTime > .3) continue;
      final x = dog.x - cameraX;
      if (x < -100 || x > 900) continue;
      canvas.drawOval(Rect.fromCenter(center: Offset(x, groundY + 2), width: 48, height: 7),
        Paint()..color = const Color(0x660b2027));
      canvas.save();
      if (dog.facing == -1) {
        canvas.translate(x, 0);
        canvas.scale(-1, 1);
        canvas.translate(-x, 0);
      }
      final name = switch (dog.mood) {
        DogMood.idle => 'idle',
        DogMood.walk => (time * 7).floor().isEven ? 'walk' : 'run',
        DogMood.alert => 'alert',
        DogMood.run => (time * 10).floor().isEven ? 'run' : 'walk',
        DogMood.bite => 'bite',
        DogMood.hit => 'hit',
        DogMood.stunned => 'stunned',
        DogMood.defeated => 'defeated',
      };
      _sprite(canvas, images['dog_$name'], Rect.fromLTWH(x - 52, groundY - 80, 104, 79));
      canvas.restore();
      if (dog.mood == DogMood.alert || dog.mood == DogMood.bite) {
        _outlinedText(canvas, '!', Offset(x, groundY - 90), const Color(0xffffd958), 24);
      }
      if (dog.mood == DogMood.hit || dog.mood == DogMood.stunned || dog.mood == DogMood.defeated) {
        for (int i = 0; i < 3; i++) {
          final angle = time * 6 + i * 2 * math.pi / 3;
          _outlinedText(canvas, '★', Offset(x + 20 * math.cos(angle), groundY - 85 + 8 * math.sin(angle)),
            const Color(0xffffd24a), 13);
        }
      }
    }
    // El padre solo existe en esta escena cuando hay conversación introductoria.
    if (showFather) _actor(canvas, father, 'padre', 2, false);
    _actor(canvas, sisters[1 - selected], selected == 0 ? 'bailarina' : 'futbolista', 1 - selected, false);
    _actor(canvas, sisters[selected], selected == 0 ? 'futbolista' : 'bailarina', selected, true);
    for (final shot in shots) {
      if (!shot.active) continue;
      final w = shot.kind == 0 ? 24.0 : 26.0;
      final h = shot.kind == 0 ? 24.0 : 16.0;
      _sprite(canvas, images[shot.kind == 0 ? 'ball' : 'comb'],
        Rect.fromCenter(center: Offset(shot.x - cameraX, shot.y), width: w, height: h));
    }
    if (time < effectUntil) {
      final x = sisters[selected].x - cameraX;
      for (int i = 0; i < 5; i++) {
        final a = i * (2 * math.pi / 5) + time * 4;
        canvas.drawCircle(Offset(x + 28 * math.cos(a), groundY - 75 + 17 * math.sin(a)),
          2.5, Paint()..color = const Color(0xffffd865));
      }
    }
    canvas.restore();
  }

  void _actor(Canvas canvas, Character hero, String role, int index, bool active) {
    final pose = !hero.grounded ? 'jump_0' : hero.vx.abs() > 15
        ? 'walk_${(hero.travelled / 23).floor() % 2}' : 'idle_0';
    final img = images['${role}_$pose'];
    if (img == null) return;
    final double scale = index == 1 ? .49 : .43;
    final w = img.width * scale;
    final h = img.height * scale;
    final x = hero.x - cameraX;
    if (x < -120 || x > 920) return;
    final blink = time < hero.hurtUntil && (time * 11).floor().isEven;
    if (blink) return;
    canvas.drawOval(Rect.fromCenter(center: Offset(x, groundY + 1), width: w * .68, height: 8),
      Paint()..color = const Color(0x66061c25));
    canvas.save();
    if (hero.facing < 0) {
      canvas.translate(x, 0);
      canvas.scale(-1, 1);
      canvas.translate(-x, 0);
    }
    _sprite(canvas, img, Rect.fromLTWH(x - w / 2, hero.y - h + 8 * scale, w, h), pixelated: false);
    canvas.restore();
    if (active) {
      canvas.drawArc(Rect.fromCenter(center: Offset(x, hero.y + 4), width: 40, height: 13),
        0, math.pi, false,
        Paint()..color = const Color(0xffffdc65)..strokeWidth = 2..style = PaintingStyle.stroke);
    }
  }

  static void _outlinedText(Canvas canvas, String value, Offset offset, Color color, double fontSize) {
    final painter = TextPainter(
      text: TextSpan(text: value, style: TextStyle(color: color, fontSize: fontSize,
        fontWeight: FontWeight.bold, shadows: const [Shadow(color: Colors.black, blurRadius: 3)])),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset(offset.dx - painter.width / 2, offset.dy));
  }

  static void _sprite(Canvas canvas, ui.Image? image, Rect target,
      {Rect? source, bool pixelated = true}) {
    if (image == null) return;
    canvas.drawImageRect(image,
      source ?? Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      target, Paint()..filterQuality = pixelated ? FilterQuality.none : FilterQuality.low);
  }

  @override
  bool shouldRepaint(covariant StagePainter oldDelegate) => true;
}
