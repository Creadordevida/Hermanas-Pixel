import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sprite_bounds.g.dart';
import 'hero_hearts.dart';
import 'chapter_one_layout.dart';
import 'neighborhood_scene_engine.dart';
import 'chapter_one_world_v4.dart';
import 'chapter_one_world_tiles.dart';
import 'chapter_one_camera_v3.dart';
import 'creature_sheet_bounds.dart';
import 'animal_sprite_bounds.dart';
import 'jump_visuals.dart';
import 'activity_chapters.dart';
import 'football_parallax_twc.dart';
import 'interiors_parallax_twc.dart';

const double viewW = 800;
const double viewH = 450;
const double groundY = 390;
const double stageWidth = 36500; // ~3.6 minutes walking, closer to 5 including obstacles and enemies.
const double actorRadius = 14;
const double actorHeight = 118;
const String saveKey = 'miren_sara_v090_save';
const String oldSaveKey = 'miren_sara_v080_save';
const List<String> chapterNames = [
  'La salida de casa', 'Ayuntamiento de Pamplona', 'Calle Estafeta',
  'Plaza del Castillo', 'Campo de entrenamiento', 'Escuela de danza',
  'El colegio',
];
const List<String> chapterScenes = [
  'level_pixel', 'level_ayuntamiento', 'level_estafeta',
  'level_plaza_castillo', 'football', 'ballet', 'school',
];
const List<String> chapterProps = [
  'crate', 'crate', 'crate', 'planter', 'cone', 'gym_bench', 'backpack',
];
const List<String> enemyKinds = [
  'dog_dalmatian', 'dog_brown', 'dog_doberman', 'pigeon', 'cat', 'statue',
  'rat', 'rival', 'goalkeeper', 'referee', 'novice', 'breakdancer', 'bully', 'teacher',
];
const List<String> poses = ['idle', 'walk', 'attack', 'hit', 'defeated'];

enum Screen { title, map, choose, introduction, playing, chapterEnd, gameOver, paused }

class Character {
  Character(this.x, {this.y = groundY});
  double x, y;
  double vx = 0, vy = 0, travelled = 0, hurtUntil = 0;
  double jumpedAt = -100, landedAt = -100, landingStrength = 0;
  int facing = 1;
  bool grounded = true;
}

class Obstacle {
  Obstacle(this.x, this.y, this.w, this.h, this.kind, {this.breakable = true});
  final double x, y, w, h;
  final String kind;
  final bool breakable;
  Rect get rect => Rect.fromLTWH(x, y, w, h);
  double smashedAt = -100;
  bool get destroyed => smashedAt >= 0;
}

class Enemy {
  Enemy(this.id, this.kind, this.x) : home = x,
    animalMode = kind == 'pigeon' ? 'perch' : 'idle';
  final int id;
  final String kind;
  final double home;
  double x;
  int facing = -1, hits = 0;
  double t = 0, attackCooldown = 1, stunned = 0, deathAt = -1;
  // Explicit animation/behaviour state: the art must reflect actual movement.
  String animalMode;
  double animalTime = 0, flightAltitude = 0, flightDuration = 0;
  bool biteApplied = false;
  bool launched = false;
  bool get defeated => deathAt >= 0;
  bool get ranged => ['referee','breakdancer','teacher','statue'].contains(kind);
  bool get dog => kind.startsWith('dog_');
  bool get aerial => kind == 'pigeon';
  int get hp => kind == 'dog_doberman' ? 2 : ranged ? 3 : 1;
  double get speed => switch(kind) {
    'dog_dalmatian' => 56, 'dog_doberman' => 112,
    'rat' => 118, 'cat' => 92, 'pigeon' => 84,
    'rival' => 90, 'goalkeeper' => 80, 'novice' => 94, 'bully' => 90,
    _ => 72,
  };
  double get detection => kind == 'goalkeeper' ? 230 : kind == 'dog_dalmatian' ? 145 : kind == 'dog_doberman' ? 290 : 220;
  double get height => aerial ? 99 + 30 * math.sin(t * 4) : kind == 'rat' ? 21 : 64;

  void _animalState(String next) {
    if (animalMode == next) return;
    animalMode = next;
    animalTime = 0;
    if (next == 'bite') biteApplied = false;
  }

  void animalHit() => _animalState(defeated ? 'defeated' : 'hit');

  /// Pure world-space simulation, independently testable without Flutter UI.
  /// Returns true only on the single contact frame of a real attack.
  bool advanceAnimal(double dt, double heroX, double heroY) {
    assert(dog || aerial);
    animalTime += dt;
    final distance = heroX - x;
    final absDist = distance.abs();
    if (dog) {
      if (animalMode == 'hit' || animalMode == 'stunned') {
        _animalState('alert');
      }
      if (animalMode == 'bite') {
        // Bite must be shown BEFORE damage; no invisible instant contact.
        if (!biteApplied && animalTime >= .24) {
          biteApplied = true;
          if (absDist < 61 && heroY > groundY - 48) return true;
        }
        if (animalTime >= .62) _animalState('alert');
        return false;
      }
      if (absDist < detection) {
        facing = distance >= 0 ? 1 : -1;
        if (animalMode != 'alert' && animalMode != 'run') {
          _animalState('alert');
        }
        if (animalMode == 'alert' && animalTime < .38) return false;
        if (absDist > 49) {
          _animalState('run');
          x += facing * speed * dt;
        } else if (attackCooldown <= 0 && heroY > groundY - 48) {
          _animalState('bite');
          attackCooldown = 1.75;
        } else {
          _animalState('alert');
        }
      } else {
        // Small pauses between patrol cycles prevent clockwork pacing.
        if ((t + id * .43) % 3.7 < 1.25) {
          _animalState('idle');
        } else {
          _animalState('walk');
          x += facing * speed * .30 * dt;
          if ((x - home).abs() > 88) facing = -facing;
        }
      }
      return false;
    }

    // Pigeons start ON the pavement, take off, flap/glide, dive and land.
    // Never animate a standing bird 58px above the floor.
    if (animalMode == 'hit') _animalState('flap');
    if (animalMode == 'perch' || animalMode == 'walk') {
      flightAltitude = 0;
      flightDuration = 0;
      if (absDist < 188) {
        facing = distance >= 0 ? -1 : 1;
        _animalState('takeoff');
      } else if ((t + id * .57) % 4.3 < 2.9) {
        _animalState('perch');
      } else {
        _animalState('walk');
        x += facing * speed * .12 * dt;
        if ((x - home).abs() > 44) facing = -facing;
      }
      return false;
    }
    if (animalMode == 'takeoff') {
      flightDuration += dt;
      flightAltitude = math.min(82, flightAltitude + 158 * dt);
      x += facing * speed * .64 * dt;
      if (flightAltitude >= 82) _animalState('flap');
      return false;
    }
    if (animalMode == 'landing') {
      flightDuration += dt;
      if (absDist < 188) {
        _animalState('takeoff');
      } else {
        flightAltitude = math.max(0.0, flightAltitude - 82 * dt);
        final towardHome = (home - x).clamp(-speed * dt, speed * dt).toDouble();
        x += towardHome;
        if (flightAltitude <= 0) _animalState('perch');
      }
      return false;
    }
    if (animalMode == 'dive') {
      flightDuration += dt;
      facing = distance >= 0 ? 1 : -1;
      flightAltitude = math.max(34, flightAltitude - 105 * dt);
      x += facing * speed * 1.35 * dt;
      if (absDist < 48 && flightAltitude <= 50 && heroY > groundY - 50) {
        attackCooldown = 2.7;
        _animalState('flap');
        return true;
      }
      if (animalTime > 1.18) {
        attackCooldown = 2.3;
        _animalState('flap');
      }
      return false;
    }
    // Smooth, bounded flight around the nesting point, alternating wing beats
    // and short glides. Altitude is independent of wing-frame dimensions.
    flightDuration += dt;
    flightAltitude += (83 - flightAltitude).clamp(-80 * dt, 80 * dt).toDouble();
    final targetX = home + 83 * math.sin(t * .61 + id * .31);
    final vx = (targetX - x).clamp(-speed * dt, speed * dt).toDouble();
    if (vx.abs() > .01) facing = vx > 0 ? 1 : -1;
    x += vx;
    if (absDist < 224 && attackCooldown <= 0 && flightAltitude > 60) {
      _animalState('dive');
    } else if (absDist > 320 && flightDuration > 1.5) {
      _animalState('landing');
    } else if (animalMode == 'flap' && animalTime > 1.12) {
      _animalState('glide');
    } else if (animalMode == 'glide' && animalTime > .55) {
      _animalState('flap');
    }
    return false;
  }
}

class Projectile {
  Projectile({required this.x, required this.y, required this.vx,
    required this.kind, this.fromEnemy = false});
  double x, y, vx;
  double vy = -24, life = 0;
  final String kind;
  final bool fromEnemy;
  bool active = true;
}

class StageData {
  const StageData(this.index);
  final int index;
  String get name => chapterNames[index];
  String get prop => chapterProps[index];
  bool get forcedMiren => index == 4;
  bool get forcedSara => index == 5;
  String get sceneKey => chapterScenes[index];
  List<String> get enemies => switch (index) {
    0 => ['dog_dalmatian','dog_brown','rat','pigeon'],
    1 => ['dog_brown','pigeon','statue','dog_dalmatian'],
    2 => ['dog_brown','cat','rat','dog_doberman'],
    3 => ['pigeon','cat','statue','dog_doberman','rat'],
    4 => ['rival','goalkeeper','referee'],
    5 => ['novice','breakdancer'],
    _ => ['bully','teacher'],
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MaterialApp(debugShowCheckedModeBanner: false,
    title: 'Las aventuras de Miren y Sara', home: HermanasGame()));
}

class HermanasGame extends StatefulWidget {
  const HermanasGame({super.key, this.qaStage, this.qaMap = false, this.qaWorldX});
  /// Entradas de diagnóstico usadas solo por testWidgets; en Android son null/false.
  final int? qaStage;
  final bool qaMap;
  /// Posición del recorrido utilizada por capturas de QA, nunca por el juego Android.
  final double? qaWorldX;
  @override
  State<HermanasGame> createState() => _HermanasGameState();
}

class _HermanasGameState extends State<HermanasGame> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController ticker;
  final Map<String, ui.Image> images = {};
  SharedPreferences? storage;
  bool resourcesReady = false, savedAvailable = false, saving = false;
  String? loadError;
  Screen screen = Screen.title;
  Character hero = Character(140);
  Character father = Character(70);
  Character otherSister = Character(190);
  final List<Obstacle> obstacles = [];
  final List<Rect> platforms = [];
  final List<Offset> coins = [];
  final List<Enemy> enemies = [];
  final List<Projectile> shots = [];
  final Set<int> collected = {};
  final Set<int> completed = {};
  int stage = 0, selected = 0, hearts = maxHeroHearts, totalCoins = 0, introLine = 0;
  bool introPlayed = false, leftHeld = false, rightHeld = false;
  double time = 0, levelTime = 0, lastMicros = 0, lastSaveTime = 0;
  double cameraX = 0, lastAttackTime = -10, checkpointX = 145, particlesUntil = -10;
  double exitTime = -1;
  StageData get level => StageData(stage);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ticker = AnimationController(vsync: this, duration: const Duration(days: 1))
      ..addListener(_tick)..forward();
    _loadAssets();
  }

  // Diagnostico visual: testWidgets conserva esta instancia y sus 136 imagenes
  // entre capturas. Si cambian las entradas QA hay que cambiar REALMENTE el
  // estado del juego. La version anterior no implementaba didUpdateWidget:
  // todas las capturas podian mostrar el mismo titulo o escenario.
  // No afecta al APK normal: sus parametros qa* son siempre null/false.
  @override
  void didUpdateWidget(covariant HermanasGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!resourcesReady ||
        (oldWidget.qaStage == widget.qaStage &&
         oldWidget.qaMap == widget.qaMap &&
         oldWidget.qaWorldX == widget.qaWorldX)) {
      return;
    }
    if (widget.qaStage != null) {
      stage = widget.qaStage!.clamp(0, 6);
      selected = level.forcedSara ? 1 : 0;
      _layoutStage();
      if (widget.qaWorldX != null) {
        hero.x = widget.qaWorldX!.clamp(actorRadius, stageWidth - actorRadius).toDouble();
        cameraX = (hero.x - 327).clamp(0.0, stageWidth - viewW).toDouble();
      }
      screen = Screen.playing;
    } else if (widget.qaMap) {
      screen = Screen.map;
    } else {
      screen = Screen.title;
    }
    // didUpdateWidget siempre va seguido de build: no es necesario setState.
  }

  Future<void> _loadAssets() async {
    try {
      storage = await SharedPreferences.getInstance();
      savedAvailable = storage?.getString(saveKey) != null || storage?.getString(oldSaveKey) != null;
      final paths = <String,String>{
        'title':'assets/images/title_cars_fixed_091.png',
        'logo':'assets/images/twc_corporate_verified_091.png',
        'map':'assets/images/worldmap/pamplona_aprobado.png',
        'crate':'assets/images/crate.png',
        'coin':'assets/images/coin.png',
        'ball':'assets/images/ball.png',
        'comb':'assets/images/comb.png',
      };
      for (int i=0;i<7;i++) {
        paths['scene_$i'] = i<4 ? 'assets/images/${chapterScenes[i]}.png'
          : 'assets/images/scenes/${i==5 ? 'ballet_refined' : chapterScenes[i]}.png';
        paths['ground_$i'] = 'assets/images/ground/stage_$i.png';
        paths['mid_$i'] = 'assets/images/mid/stage_$i.png';
        if (i == 4) paths['mid_4_plain'] = 'assets/images/mid/stage_4_plain.png';
      }
      // El nuevo capítulo 1 carga recursos que el juego realmente dibuja.
      // No son renders ilustrativos ni sustituyen a los originales protegidos.
      for (final zone in neighborhoodZones) {
        paths['neighborhood_${zone.asset}'] =
          'assets/images/chapter1/${zone.asset}.png';
      }
      // RC3 FIX2: horizonte rico en edificios/montañas y arbolado intermedio.
      // Son decorativos, solo capítulo 1; suelo y gameplay siguen intactos.
      paths['ch1_far_city_loop'] =
        'assets/images/chapter1/ch1_parallax/montanas_ciudad_ciclo.png';
      paths['ch1_mid_woodland_loop'] =
        'assets/images/chapter1/ch1_parallax/arbolado_medio_ciclo.png';
      // FÚTBOL: mismo movimiento aprobado que el capítulo 1; arte propio.
      paths['football_far_twc'] = footballFarAssetTWC;
      paths['football_mid_twc'] = footballMidAssetTWC;
      for (int i = 0; i < footballTileCountTWC; i++) {
        paths['football_near_tile_$i'] = footballNearTileAssetTWC(i);
      }
      // Interiores TWC: muros físicos 1:1 y vistas exteriores por ventanas.
      // El colegio y la academia NO funden panoramas de habitaciones.
      for (final theme in ['dance','school']) {
        paths['interior_${theme}_far'] =
          interiorAssetTWC(theme,'exterior_lejano_ciclo');
        paths['interior_${theme}_mid'] =
          interiorAssetTWC(theme,'arbolado_tras_ventanas_ciclo');
        paths['interior_${theme}_passage'] =
          interiorAssetTWC(theme,'marco_paso');
        for (var room=0;room<3;room++) {
          for (var variant=0;variant<interiorVariantsPerRoomTWC;variant++) {
            paths['interior_${theme}_z${room}_panel_$variant'] =
                interiorPanelAssetTWC(theme,room,variant);
          }
        }
      }
      for (final name in ['pizarra_matematicas','pizarra_informatica',
          'estanteria_biblioteca','mesa_aula','ordenador_aula']) {
        paths['interior_school_$name'] = interiorAssetTWC('school',name);
      }
      // 72 teselas de mundo FISICO, generadas una sola vez fuera del juego.
      for (int i=0; i<ch1PhysicalTileCount; i++) {
        paths['ch1_world_tile_$i'] = ch1PhysicalTileAsset(i);
      }
      // Pergola is a unique neutral connecting vista, never repeated.
      paths['neighborhood_connector_pergola_v091'] =
        'assets/images/chapter1/connector_pergola_v091.png';
      // Replacement for the broken irregular props grid: four isolated trees.
      paths['neighborhood_clouds_v4'] =
        'assets/images/chapter1/clouds_v4_experimental.png';
      paths['neighborhood_park_props_atlas'] =
        'assets/images/chapter1/park_props_atlas.png';
      paths['neighborhood_trees_v091'] =
        'assets/images/chapter1/trees_separated_v091.png';
      for (final region in neighborhoodSceneRegions.where((r) => r.connector)) {
        paths['neighborhood_${region.asset}'] =
          'assets/images/chapter1/${region.asset}.png';
      }
      // The training field and dance academy have three real distinct views
      // each; none replaces approved character art or original protected PNGs.
      for (final zone in [...footballActivityZones, ...danceActivityZones]) {
        paths['activity_${zone.asset}'] = 'assets/images/chapter45/${zone.asset}.png';
      }
      for (final kind in ['football','dance']) {
        paths['activity_${kind}_props'] = 'assets/images/chapter45/${kind}_props_atlas.png';
      }
      for(final kind in ['classroom','computers']) {
        paths['scene_school_$kind'] = 'assets/images/scenes/school_$kind.png';
        paths['mid_school_$kind'] = 'assets/images/mid/school_$kind.png';
      }
      for (final item in ['cone','planter','backpack','gym_bench','red_card','shoe','eraser']) {
        paths[item] = 'assets/images/props/$item.png';
      }
      for (final role in ['futbolista','bailarina','padre']) {
        for (final pose in ['idle_0','walk_0','walk_1','jump_0']) {
          paths['${role}_$pose'] = 'assets/images/frames/${role}_$pose.png';
          if (role != 'padre') paths['costume_${role}_$pose'] = 'assets/images/outfits/${role}_$pose.png';
        }
        // Ataques con el atuendo APROBADO, sin superponer parches de color.
        if (role != 'padre') {
          paths['costume_${role}_attack_0'] = 'assets/images/outfits/${role}_attack_0.png';
        }
      }
      for (final pose in ['idle','walk','alert','run','bite','hit','stunned','defeated']) {
        paths['dog_brown_$pose'] = 'assets/images/dog/$pose.png';
        for (final v in ['dalmatian','doberman']) {
          paths['dog_${v}_$pose'] = 'assets/images/dog/$v/$pose.png';
        }
      }
      for (final v in ['rival','goalkeeper','referee','novice','breakdancer','pigeon','cat','rat','bully','teacher','statue']) {
        if (v=='cat' || v=='rat') {
          // Se carga la hoja nueva única, con cinco poses coherentes y
          // recortes medidos; no se usan los cinco dibujos planos originales.
          paths['enemy_${v}_sheet'] = 'assets/images/enemies_hifi/${v}_sheet.png';
        } else {
          for (int j=0;j<5;j++) paths['enemy_${v}_$j'] = 'assets/images/enemies/${v}_$j.png';
        }
      }
      // Eight true flight silhouettes (upstroke, downstroke, glide, hit, fall).
      // The old pigeon frames remain for genuine ground walking/pecking.
      paths['pigeon_flight_sheet'] = 'assets/images/enemies_hifi/pigeon_flight_sheet.png';
      for (final item in paths.entries) {
        final blob = await rootBundle.load(item.value);
        final codec = await ui.instantiateImageCodec(blob.buffer.asUint8List());
        images[item.key] = (await codec.getNextFrame()).image;
        codec.dispose();
      }
      if (widget.qaStage != null) {
        stage = widget.qaStage!.clamp(0, 6);
        selected = level.forcedSara ? 1 : 0;
        _layoutStage();
        if(widget.qaWorldX != null) {
          hero.x=widget.qaWorldX!.clamp(actorRadius,stageWidth-actorRadius).toDouble();
          cameraX=(hero.x-327).clamp(0.0,stageWidth-viewW).toDouble();
        }
        screen = Screen.playing;
      } else {
        _layoutStage();
        if (widget.qaMap) screen = Screen.map;
      }
      if (mounted) setState(() => resourcesReady = true);
    } catch (e,stack) {
      debugPrint('Recursos incompletos: $e\n$stack');
      if (mounted) setState(() => loadError = '$e');
    }
  }

  void _layoutStage() {
    obstacles.clear(); platforms.clear(); coins.clear(); enemies.clear();
    collected.clear(); shots.clear();
    if (stage == 0) {
      _layoutNeighborhood();
      hero=Character(145);otherSister=Character(230);father=Character(67);
      cameraX=0;checkpointX=145;hearts=maxHeroHearts;lastAttackTime=-10;
      levelTime=0;exitTime=-1;leftHeld=false;rightHeld=false;
      return;
    }
    final rng = math.Random(1001 + stage * 117);
    // The authored world's length gives roughly 4 minutes of traversing at 169px/s,
    // plus platforming, combat and exploration. Actual ~5min must be device-playtested.
    for (double x = 520; x<stageWidth-260; x+= 545 + rng.nextInt(260)) {
      final y=groundY- (stage==5 ? 38.0 : 43.0);
      obstacles.add(Obstacle(x,y,stage==5?72:44,groundY-y,level.prop));
      if (rng.nextDouble()>.84) obstacles.add(Obstacle(x+70,groundY-40,42,40,level.prop));
    }
    for (double x=1000; x<stageWidth-450; x+=1680 + rng.nextInt(350)) {
      final yy = groundY- (55+rng.nextInt(17)); // jump apex 87.55 px, so 55-71 is reachable.
      platforms.add(Rect.fromLTWH(x,yy,125+rng.nextInt(25).toDouble(),15));
      for (int i=0;i<3;i++) coins.add(Offset(x+32+i*47, yy-34));
    }
    for (double x=300; x<stageWidth-300; x+=136 + rng.nextInt(45)) {
      coins.add(Offset(x, rng.nextBool()?groundY-55:groundY-112));
    }
    final kinds=level.enemies;
    for (double x=820; x<stageWidth-300; x+=930+rng.nextInt(300)) {
      final prog=x/stageWidth;
      String type=kinds[rng.nextInt(kinds.length)];
      if (prog<.3 && ['goalkeeper','referee','breakdancer','teacher','statue','dog_doberman'].contains(type)) {
        type=kinds.first;
      }
      enemies.add(Enemy(enemies.length,type,x));
    }
    // The chapter's strong thematic opponent always appears near its last segment.
    if (stage>=4) enemies.add(Enemy(enemies.length,level.enemies.last,stageWidth-980));
    hero=Character(145);otherSister=Character(230);father=Character(67);
    cameraX=0;checkpointX=145;hearts=maxHeroHearts;lastAttackTime=-10;
    levelTime=0;exitTime=-1;leftHeld=false;rightHeld=false;
  }

  /// Obstáculos y adversarios escritos por zonas. Se evita colocar enemigos
  /// justo en la llegada a un nuevo espacio o bloquear una transición.
  /// La semilla por zona hace reproducible cada partida y los tests.
  void _layoutNeighborhood() {
    for (int zoneIndex=0; zoneIndex<neighborhoodZones.length; zoneIndex++) {
      final zone=neighborhoodZones[zoneIndex];
      final rng=math.Random(42021+zoneIndex*223);
      final length=zone.length;
      for (double local=680; local<length-450; local+=730+rng.nextInt(220)) {
        final x=zone.start+local;
        final kind=zoneIndex==0 && rng.nextBool() ? 'crate' : 'planter';
        final h=kind=='planter'?46.0:43.0;
        obstacles.add(Obstacle(x,groundY-h,kind=='planter'?56:44,h,kind));
      }
      // Una plataforma sobre bancos/cajas con suelo físico definido.
      for (double local=1440; local<length-900; local+=2300+rng.nextInt(370)) {
        final x=zone.start+local;
        final top=groundY-61.0;
        platforms.add(Rect.fromLTWH(x,top,132,15));
        for(int i=0;i<3;i++) coins.add(Offset(x+21+i*47,top-35));
      }
      for (double local=320;local<length-240;local+=185+rng.nextInt(80)) {
        coins.add(Offset(zone.start+local,
          rng.nextDouble()<.45?groundY-104:groundY-58));
      }
      final types=switch(zoneIndex) {
        0 => ['dog_brown','pigeon','dog_dalmatian','rat'],
        1 => ['pigeon','dog_dalmatian','rat','cat'],
        2 => ['cat','pigeon','dog_brown','rat'],
        _ => ['dog_dalmatian','pigeon','cat','dog_doberman'],
      };
      for(double local=1100;local<length-400;local+=1170+rng.nextInt(390)) {
        final kind=types[rng.nextInt(types.length)];
        enemies.add(Enemy(enemies.length,kind,zone.start+local));
      }
    }
  }

  Future<void> _startNew() async {
    if (savedAvailable) {
      final confirm=await showDialog<bool>(context: context,builder: (ctx)=>AlertDialog(
        title: const Text('¿Nueva partida?'),
        content: const Text('Se reiniciará el progreso guardado de la versión 0.9.0.'),
        actions: [TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('CANCELAR')),
          FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('NUEVA PARTIDA'))]));
      if (confirm!=true || !mounted) return;
    }
    completed.clear();totalCoins=0;introPlayed=false;stage=0;selected=0;
    _layoutStage();savedAvailable=false;
    await storage?.remove(saveKey);
    await storage?.remove(oldSaveKey);
    if (mounted) setState(()=>screen=Screen.map);
  }

  Future<void> _continue() async {
    final raw=storage?.getString(saveKey) ?? storage?.getString(oldSaveKey);
    if (raw==null) return;
    try {
      final s=jsonDecode(raw) as Map<String,dynamic>;
      stage=((s['stage'] as num?)?.toInt()??0).clamp(0,6).toInt();
      selected=((s['selected'] as num?)?.toInt()??0).clamp(0,1).toInt();
      totalCoins=((s['totalCoins'] as num?)?.toInt()??0).clamp(0,99999).toInt();
      completed..clear()..addAll((s['completed'] as List<dynamic>? ?? [])
        .whereType<num>().map((e)=>e.toInt()).where((i)=>i>=0 && i<7));
      introPlayed=s['introPlayed']==true || (s['version'] as num? ?? 0)<3;
      if((s['version'] as num? ?? 0)<3) {
        for(int i=0;i<stage;i++)completed.add(i);
      }
      _layoutStage();
      // Returning to the map is intentional for free-selection test mode.
      if (mounted) setState(()=>screen=Screen.map);
    } catch(e) {debugPrint('Guardado inválido: $e');if(mounted)setState(()=>savedAvailable=false);}
  }

  Future<void> _save({bool atMap=false}) async {
    if (storage==null || saving || !resourcesReady || screen==Screen.title) return;
    saving=true;
    try {
      final data=<String,dynamic>{
        'version':3,'stage':stage,'selected':selected,'totalCoins':totalCoins,
        'completed':completed.toList()..sort(),'introPlayed':introPlayed,
        'atMap':atMap,'x':hero.x,'hearts':hearts,
      };
      await storage!.setString(saveKey,jsonEncode(data));savedAvailable=true;
    } catch(e) {debugPrint('Guardado fallido: $e');} finally {saving=false;}
  }

  void _selectChapter(int index) {
    stage=index;
    selected=level.forcedSara?1:0;
    _layoutStage();
    if (level.forcedMiren || level.forcedSara) {
      _choose(selected);
    } else {
      setState(()=>screen=Screen.choose);
    }
  }

  void _choose(int choice) {
    selected=choice;
    _layoutStage();
    final intro=stage==0 && !introPlayed;
    screen=intro?Screen.introduction:Screen.playing;
    introLine=0;
    father.x=80;otherSister.x=184;hero.facing=-1;otherSister.facing=-1;father.facing=1;
    _save();setState((){});
  }

  void _introNext() {
    introLine++;
    if(introLine>=4) {
      introPlayed=true;exitTime=time;screen=Screen.playing;
      hero.x=205;otherSister.x=95;father.x=75;
      _save();
    }
    setState((){});
  }

  static double _ease(double from,double to,double maxStep) {
    if ((to-from).abs()<=maxStep) return to;
    return from+(to-from).sign*maxStep;
  }

  void _tick() {
    final micros=ticker.lastElapsedDuration?.inMicroseconds.toDouble()??0;
    final dt=lastMicros == 0 ? .016 :((micros-lastMicros)/1000000).clamp(0.0,.033).toDouble();
    lastMicros=micros;
    if(dt<=0 || !resourcesReady) return;
    time+=dt;
    if(screen!=Screen.playing) {if(screen==Screen.introduction && mounted)setState((){});return;}
    levelTime+=dt;
    if(exitTime>=0) {
      father.x-=65*dt;otherSister.x-=67*dt;
      father.vx=-65;father.facing=-1;otherSister.vx=-67;otherSister.facing=-1;
      father.travelled+=65*dt;otherSister.travelled+=67*dt;
      if(father.x< -110 && otherSister.x< -100) exitTime=-1;
    }
    final input=(rightHeld?1:0)-(leftHeld?1:0);
    hero.vx=_ease(hero.vx,input*169.0,dt*(input==0?800:1040));
    if(input!=0)hero.facing=input;
    final prevX=hero.x,prevY=hero.y;
    final wasGrounded=hero.grounded;
    hero.x=(hero.x+hero.vx*dt).clamp(actorRadius,stageWidth-actorRadius).toDouble();
    // Solid platforms and themed obstacles share one tested collision routine.
    final solids=<Rect>[...platforms,...obstacles.where((o)=>!o.destroyed).map((o)=>o.rect)];
    for(final box in solids) {
      if(hero.y>box.top+2 && hero.y-actorHeight<box.bottom-2) {
        if(hero.vx>0 && prevX+actorRadius<=box.left+2 && hero.x+actorRadius>box.left) {
          hero.x=box.left-actorRadius;hero.vx=0;
        } else if(hero.vx<0 && prevX-actorRadius>=box.right-2 && hero.x-actorRadius<box.right) {
          hero.x=box.right+actorRadius;hero.vx=0;
        }
      }
    }
    hero.vy=(hero.vy+960*dt).clamp(-550.0,680.0).toDouble();
    final speedBeforeLanding=hero.vy;
    hero.y+=hero.vy*dt;hero.grounded=false;
    for(final box in solids) {
      if(hero.x+actorRadius<=box.left || hero.x-actorRadius>=box.right)continue;
      if(hero.vy>=0 && prevY<=box.top+2 && hero.y>=box.top) {
        hero.y=box.top;hero.vy=0;hero.grounded=true;
      } else if(hero.vy<0 && prevY-actorHeight>=box.bottom-2 && hero.y-actorHeight<box.bottom) {
        hero.y=box.bottom+actorHeight;hero.vy=0;
      }
    }
    if(hero.y>=groundY){hero.y=groundY;hero.vy=0;hero.grounded=true;}
    if(!wasGrounded && hero.grounded && speedBeforeLanding > 65) {
      hero.landedAt=time;
      hero.landingStrength=(speedBeforeLanding/440).clamp(.45,1.0).toDouble();
    }
    hero.travelled+=(hero.x-prevX).abs();
    for(int i=0;i<coins.length;i++) {
      if(collected.contains(i))continue;
      if((coins[i].dx-hero.x).abs()<23 && (coins[i].dy-(hero.y-46)).abs()<41) {
        collected.add(i);totalCoins++;particlesUntil=time+.2;
      }
    }
    for(final shot in shots) {
      if(!shot.active)continue;
      shot.x+=shot.vx*dt;shot.y+=shot.vy*dt;shot.life+=dt;
      if(shot.fromEnemy) {
        shot.vy+=210*dt;
        if((shot.x-hero.x).abs()<24 && (shot.y-(hero.y-46)).abs()<48) {
          shot.active=false;_receiveDamage(shot.vx.sign.toInt());
        }
      } else {
        shot.vy+=490*dt;
        for(final o in obstacles) {
          if(o.destroyed || !o.breakable)continue;
          if(o.rect.inflate(3).contains(Offset(shot.x,shot.y))) {
            o.smashedAt=time;shot.active=false;particlesUntil=time+.35;break;
          }
        }
        if(!shot.active) continue;
        for(final foe in enemies) {
          if(foe.defeated || foe.stunned>0)continue;
          final ey=groundY-(foe.aerial?foe.flightAltitude+24:foe.kind=='rat'?24:64);
          if((shot.x-foe.x).abs()<37 && (shot.y-ey).abs()<(foe.aerial?42:51)) {
            foe.hits++;foe.stunned=.66;foe.t=0;shot.active=false;
            particlesUntil=time+.4;
            if(foe.hits>=foe.hp)foe.deathAt=time;
            if(foe.dog || foe.aerial) foe.animalHit();
            break;
          }
        }
      }
      if(shot.y>groundY+40 || shot.life>2.5 || shot.x<0 || shot.x>stageWidth)shot.active=false;
    }
    shots.removeWhere((s)=>!s.active);
    for(final foe in enemies) {
      foe.t+=dt;foe.attackCooldown=math.max(0,foe.attackCooldown-dt);
      if(foe.defeated) {
        // Gravity brings a defeated flying bird down BEFORE it fades away.
        if(foe.aerial) foe.flightAltitude=math.max(0.0,foe.flightAltitude-145*dt);
        continue;
      }
      if(foe.stunned>0){foe.stunned=math.max(0,foe.stunned-dt);continue;}
      if(foe.dog || foe.aerial) {
        if(foe.advanceAnimal(dt,hero.x,hero.y))_receiveDamage(foe.facing);
        foe.x=foe.x.clamp(70.0,stageWidth-70).toDouble();
        continue;
      }
      final distance=hero.x-foe.x,absDist=distance.abs();
      if(foe.kind=='goalkeeper') {
        // Intermediate threat: restricted patrol, readable wind-up then ONE dive.
        // The keeper never teleports, throws projectiles or attacks immediately.
        if(foe.launched) {
          if(foe.t >= .34 && foe.t < .52 && !foe.biteApplied) {
            foe.biteApplied=true;
            if(absDist<52 && hero.y>groundY-60) _receiveDamage(foe.facing);
          }
          if(foe.t>=.75) {
            foe.launched=false;foe.biteApplied=false;
            foe.attackCooldown=2.7;foe.t=0;
          }
        } else if(absDist < 95 && foe.attackCooldown<=0) {
          foe.launched=true;foe.biteApplied=false;foe.t=0;
          foe.facing=distance>=0?1:-1;
        } else if(absDist<foe.detection) {
          foe.facing=distance>=0?1:-1;
          if(absDist>85)foe.x+=foe.facing*foe.speed*dt;
        } else {
          foe.x+=foe.facing*foe.speed*.18*dt;
          if((foe.x-foe.home).abs()>95)foe.facing=-foe.facing;
        }
      } else if(foe.ranged) {
        if(absDist<390 && foe.attackCooldown<=0) {
          // No machine-gun projectiles: one visible wind-up, one projectile, long recovery.
          if(!foe.launched){foe.launched=true;foe.t=0;foe.facing=distance>=0?1:-1;}
          if(foe.t>=.75) {
            final kind=switch(foe.kind){'referee'=>'red_card','breakdancer'=>'shoe','teacher'=>'eraser',_=>'coin'};
            // Do not overlap a second projectile of the same kind.
            if(!shots.any((s)=>s.fromEnemy && s.kind==kind)) {
              shots.add(Projectile(x:foe.x+foe.facing*27,y:groundY-71,
                vx:foe.facing*195.0,kind:kind,fromEnemy:true));
            }
            foe.launched=false;foe.t=0;foe.attackCooldown=3.6;
          }
        } else if(absDist>390)foe.launched=false;
      } else if(absDist<foe.detection) {
        foe.facing=distance>=0?1:-1;
        if(absDist>34)foe.x+=foe.facing*foe.speed*dt;
        if(absDist<37 && foe.attackCooldown<=0 && (foe.aerial || hero.y>groundY-45)) {
          _receiveDamage(foe.facing);foe.attackCooldown=1.7;
        }
      } else {
        foe.x+=foe.facing*foe.speed*.36*dt;
        if((foe.x-foe.home).abs()>87)foe.facing=-foe.facing;
      }
      foe.x=foe.x.clamp(70.0,stageWidth-70).toDouble();
    }
    cameraX=_ease(cameraX,(hero.x-327).clamp(0.0,stageWidth-viewW).toDouble(),dt*600);
    if(hero.x>checkpointX+2800){checkpointX=hero.x;_save();}
    if(time>lastSaveTime+12){lastSaveTime=time;_save();}
    if(hero.x>=stageWidth-90)_finishChapter();
    if(mounted)setState((){});
  }

  void _receiveDamage(int direction) {
    if(time<hero.hurtUntil || hearts<=0)return;
    hearts=heartsAfterDamage(hearts);
    hero.hurtUntil=time+1.65;
    hero.vx=direction*145;hero.vy=-235;hero.grounded=false;
    particlesUntil=time+.3;
    if(hearts==0){screen=Screen.gameOver;leftHeld=false;rightHeld=false;}
    _save();
  }
  void _jump() {
    if(screen==Screen.playing && hero.grounded) {
      hero.vy=-423;hero.grounded=false;
      hero.jumpedAt=time;
      hero.landedAt=-100;
    }
  }
  void _attack() {
    if(screen!=Screen.playing || time-lastAttackTime<.5)return;
    lastAttackTime=time;
    shots.add(Projectile(x:hero.x+hero.facing*30,y:hero.y-48,
      vx:hero.facing*(selected==0?338.0:360.0),kind:selected==0?'ball':'comb'));
  }
  void _finishChapter() {
    if(screen!=Screen.playing)return;
    leftHeld=false;rightHeld=false;
    completed.add(stage);screen=Screen.chapterEnd;_save(atMap:true);
  }
  void _retry() {
    final cp=checkpointX;
    _layoutStage();hero.x=cp;hearts=maxHeroHearts;
    cameraX=(cp-300).clamp(0.0,stageWidth-viewW).toDouble();
    // Reset only the unfinished part of the chapter after checkpoint.
    screen=Screen.playing;_save();setState((){});
  }
  void _returnMap() {
    leftHeld=false;rightHeld=false;
    screen=Screen.map;_save(atMap:true);setState((){});
  }
  void _returnTitle() {
    if(screen!=Screen.title)_save(atMap:true);
    leftHeld=false;rightHeld=false;
    screen=Screen.title;setState((){});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state!=AppLifecycleState.resumed){
      leftHeld=false;rightHeld=false;
      if(screen==Screen.playing){screen=Screen.paused;_save();if(mounted)setState((){});}
    }
  }
  @override
  void dispose(){WidgetsBinding.instance.removeObserver(this);ticker.dispose();for(final img in images.values){img.dispose();}super.dispose();}

  Widget _pixelButton(String title, VoidCallback onTap,{bool gold=false,double width=250}) => SizedBox(
    width:width,height:49,child:ElevatedButton(onPressed:onTap,
      style:ElevatedButton.styleFrom(backgroundColor:gold?const Color(0xffdd970d):const Color(0xff0755a5),
        foregroundColor:Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(7),
          side:const BorderSide(color:Color(0xffffdfa2),width:3))),
      child:Text(title,textAlign:TextAlign.center,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:16))));

  Widget _control(Widget glyph,VoidCallback onDown,VoidCallback onUp) => Listener(
    behavior:HitTestBehavior.opaque,
    onPointerDown:(_){onDown();if(mounted)setState((){});},
    onPointerUp:(_){onUp();if(mounted)setState((){});},
    onPointerCancel:(_){onUp();if(mounted)setState((){});},
    child:Container(width:65,height:61,alignment:Alignment.center,
      decoration:BoxDecoration(color:const Color(0xcc102d53),borderRadius:BorderRadius.circular(35),
        border:Border.all(color:Colors.white,width:2)),child:glyph));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xff0d2943),
    body: LayoutBuilder(builder: (context, constraints) => Stack(
      fit: StackFit.expand,
      children: [
        // Extra-wide Android displays get illustrated, not black, gutters.
        // Crucially the playable 800×450 image remains at its CORRECT aspect
        // ratio: no stretching of characters or hidden touch buttons.
        if (screen == Screen.title)
          // La portada aprobada se conserva sin estirar: bandas de
          // seguridad neutras, NO otra copia borrosa del mismo dibujo.
          // El arte completo permanece 800x450 mediante BoxFit.contain.
          const ColoredBox(color: Color(0xff12334d))
        else
          DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: stage == 5
                ? const [Color(0xffcaac8d), Color(0xffba8c67), Color(0xff68462c)]
                : const [Color(0xff53a9ed), Color(0xffa7d3ee), Color(0xff557c48)],
          ))),
        Center(child: FittedBox(fit: BoxFit.contain,
          child: SizedBox(width:viewW,height:viewH,child:_screen()))),
      ],
    )),
  );

  Widget _screen() {
    if(loadError!=null)return Center(child:Text('ERROR AL CARGAR RECURSOS\n$loadError',style:const TextStyle(color:Colors.white)));
    if(!resourcesReady)return const Center(child:CircularProgressIndicator());
    switch(screen) {
      case Screen.title:return _title();
      case Screen.map:return _map();
      case Screen.choose:return _chooseScreen();
      case Screen.introduction:return _play(showFamily:true);
      case Screen.playing:return _play();
      case Screen.chapterEnd:return _play(overlay:_overlay('¡CAPÍTULO COMPLETADO!',
        '¡Has superado ${chapterNames[stage]}!\nMonedas: $totalCoins',
        [_pixelButton('VOLVER AL MAPA',_returnMap,gold:true),_pixelButton('MENÚ PRINCIPAL',_returnTitle)]));
      case Screen.gameOver:return _play(overlay:_overlay('¡SIN CORAZONES!',
        'Puedes volver al último punto de control.',
        [_pixelButton('REINTENTAR',_retry,gold:true),_pixelButton('VOLVER AL MAPA',_returnMap)]));
      case Screen.paused:return _play(overlay:_overlay('PAUSA','Se conserva tu progreso.',
        [_pixelButton('SEGUIR JUGANDO',()=>setState(()=>screen=Screen.playing),gold:true),
         _pixelButton('VOLVER AL MAPA',_returnMap),_pixelButton('MENÚ PRINCIPAL',_returnTitle)]));
    }
  }

  Widget _title() => Stack(children:[
    Positioned.fill(child:Image.asset('assets/images/title_cars_fixed_091.png',fit:BoxFit.fill)),
    Positioned(left:551,top:183,width:208,height:59,child:Material(color:Colors.transparent,
      child:InkWell(onTap:_startNew))),
    Positioned(left:557,top:249,width:203,height:61,child:Material(
      color:savedAvailable?Colors.transparent:const Color(0x99505b67),
      child:InkWell(onTap:savedAvailable?_continue:null))),
    if(!savedAvailable)const Positioned(left:579,top:299,child:Text('Sin partida guardada',
      style:TextStyle(color:Colors.white,fontSize:11,shadows:[Shadow(color:Colors.black,blurRadius:3)]))),
    // El sello deja de estar dentro de una caja azul oscura.
    // La transparencia/contorno dependen ahora del PNG original.
    Positioned(left:284,bottom:2,width:232,height:51,
      child:Image.asset('assets/images/twc_corporate_verified_091.png',
        fit:BoxFit.contain)),
  ]);

  // Las coordenadas de esta imagen proceden de la ilustración EXACTA aprobada
  // (1672 x 941). No generar carteles ni duplicar títulos encima del arte.
  // La selección libre se conserva durante las pruebas de Android.
  static const double mapArtWidth = 1672;
  static const double mapArtHeight = 941;
  static const List<Rect> mapHitboxesOriginal = [
    Rect.fromLTWH(103,222,211,84),  // Casa
    Rect.fromLTWH(488,108,214,99),  // Ayuntamiento
    Rect.fromLTWH(985,262,215,88),  // Estafeta
    Rect.fromLTWH(691,407,198,80),  // Plaza y quiosco
    Rect.fromLTWH(1351,165,195,91), // Fútbol
    Rect.fromLTWH(1299,475,197,81), // Danza
    Rect.fromLTWH(240,534,220,88),  // Colegio
  ];
  Widget _map() => Stack(children:[
    // Ajuste 1672/941 ≃ 800/450, sin estirar un fondo antiguo del Ayuntamiento.
    const Positioned.fill(child:Image(image:AssetImage(
      'assets/images/worldmap/pamplona_aprobado.png'),fit:BoxFit.fill)),
    for(int i=0;i<mapHitboxesOriginal.length;i++)
      Positioned(
        left: mapHitboxesOriginal[i].left*viewW/mapArtWidth,
        top: mapHitboxesOriginal[i].top*viewH/mapArtHeight,
        width: mapHitboxesOriginal[i].width*viewW/mapArtWidth,
        height: mapHitboxesOriginal[i].height*viewH/mapArtHeight,
        child:Semantics(label:'Capítulo ${i+1}: ${chapterNames[i]}',button:true,
          child:Material(color:Colors.transparent,
            child:InkWell(onTap:()=>_selectChapter(i),splashColor:Colors.white24,
              child:const SizedBox.expand()))),
      ),
    // Botón MENÚ que está DIBUJADO en la propia imagen aprobada.
    Positioned(left:22,top:396,width:122,height:43,
      child:Material(color:Colors.transparent,child:InkWell(onTap:_returnTitle))),
    // El contador de la ilustración era de ejemplo (123 monedas): actualizaremos
    // solo esa cifra dinámica con un recuadro del mismo color y tipografía.
    Positioned(bottom:5,right:9,child:Container(
      width:250,height:27,alignment:Alignment.centerRight,
      padding:const EdgeInsets.symmetric(horizontal:8),
      decoration:BoxDecoration(color:const Color(0xff08335c),
        borderRadius:BorderRadius.circular(5)),
      child:Text('COMPLETADOS: ${completed.length}/7  ·  MONEDAS: $totalCoins',
        style:const TextStyle(color:Colors.white,fontSize:10,fontWeight:FontWeight.w900)))),
  ]);

  Widget _chooseScreen()=>Stack(children:[
    Positioned.fill(child:Image.asset(stage<4?'assets/images/${chapterScenes[stage]}.png':
      'assets/images/scenes/${chapterScenes[stage]}.png',fit:BoxFit.cover)),
    Positioned.fill(child:ColoredBox(color:Colors.black.withValues(alpha:.60))),
    Positioned(left:0,right:0,top:18,child:Text('CAPÍTULO ${stage+1} · ${chapterNames[stage]}',
      textAlign:TextAlign.center,style:const TextStyle(color:Color(0xffffde88),fontSize:24,fontWeight:FontWeight.w900))),
    _chooseCard(0,142),_chooseCard(1,415),
    Positioned(left:12,bottom:8,child:_pixelButton('◀ MAPA',_returnMap,width:129)),
  ]);
  Widget _chooseCard(int index,double x) {
    final role=index==0?'futbolista':'bailarina';
    final folder=((stage==4 && index==0)||(stage==5 && index==1))?'outfits':'frames';
    return Positioned(left:x,top:74,width:242,height:346,child:GestureDetector(onTap:()=>_choose(index),
      child:Container(decoration:BoxDecoration(color:const Color(0xee0b305a),borderRadius:BorderRadius.circular(11),
        border:Border.all(color:index==0?const Color(0xffffc748):const Color(0xffffa6d1),width:4)),
        child:Column(children:[const SizedBox(height:9),Text(index==0?'MIREN':'SARA',
          style:const TextStyle(fontSize:24,color:Colors.white,fontWeight:FontWeight.w900)),
          SizedBox(height:209,child:Image.asset('assets/images/$folder/${role}_idle_0.png',fit:BoxFit.contain)),
          Text(index==0?'BALÓN  ⚽':'PEINE  ✦',style:const TextStyle(color:Color(0xffffd783),fontSize:18,fontWeight:FontWeight.w900)),
          const HeroHeartsRow(hearts:maxHeroHearts,iconSize:22),
          const Text('TOCA PARA ELEGIR',style:TextStyle(color:Colors.white,fontSize:12,fontWeight:FontWeight.bold)),
        ]))));
  }

  Widget _play({bool showFamily=false,Widget? overlay}) => Stack(children:[
    Positioned.fill(child:CustomPaint(painter:StagePainter(
      images:images,stage:stage,cameraX:cameraX,time:time,lastAttackTime:lastAttackTime,hero:hero,
      otherSister:otherSister,father:father,showFamily:showFamily || exitTime>=0,
      selected:selected,obstacles:obstacles,platforms:platforms,
      coins:coins,collected:collected,enemies:enemies,shots:shots,particlesUntil:particlesUntil))),
    Positioned(left:10,top:9,child:Container(padding:const EdgeInsets.all(8),
      decoration:BoxDecoration(color:const Color(0xdd0d3050),borderRadius:BorderRadius.circular(7)),
      child:Row(children:[Text(selected==0?'MIREN':'SARA',style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w900)),
        const SizedBox(width:9),HeroHeartsRow(hearts:hearts,iconSize:18),
        const SizedBox(width:10),Image.asset('assets/images/coin.png',width:25,height:25),
        Text(' $totalCoins',style:const TextStyle(color:Colors.white,fontSize:17,fontWeight:FontWeight.bold))]))),
    Positioned(left:0,right:0,top:10,child:IgnorePointer(child:Text('CAP. ${stage+1} · ${chapterNames[stage]}',
      textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:13,shadows:[Shadow(color:Colors.black,blurRadius:5)])))),
    if(screen==Screen.playing)...[
      Positioned(left:15,bottom:12,child:Row(children:[
        _control(const Icon(Icons.arrow_back_rounded,color:Colors.white,size:33),()=>leftHeld=true,()=>leftHeld=false),
        const SizedBox(width:10),
        _control(const Icon(Icons.arrow_forward_rounded,color:Colors.white,size:33),()=>rightHeld=true,()=>rightHeld=false)])),
      Positioned(right:14,bottom:12,child:Row(children:[
        _control(Image.asset(selected==0?'assets/images/ball.png':'assets/images/comb.png',width:41,height:36),_attack,(){}),
        const SizedBox(width:12),
        _control(const Icon(Icons.arrow_upward_rounded,color:Colors.white,size:33),_jump,(){}),
      ])),
      Positioned(right:12,top:10,child:IconButton(onPressed:(){leftHeld=false;rightHeld=false;
        screen=Screen.paused;_save();setState((){});},
        icon:const Icon(Icons.pause_circle_filled,color:Colors.white,size:29))),
    ],
    if(screen==Screen.introduction)Positioned(left:310,right:13,top:245,height:142,
      child:GestureDetector(onTap:_introNext,child:Container(padding:const EdgeInsets.all(14),
        decoration:BoxDecoration(color:const Color(0xf00b2948),border:Border.all(color:const Color(0xffffd875),width:3),
          borderRadius:BorderRadius.circular(9)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(['PAPÁ','MIREN','SARA','PAPÁ'][introLine],
          style:TextStyle(color:[Colors.lightBlueAccent,Colors.yellowAccent,Colors.purpleAccent,Colors.lightBlueAccent][introLine],
            fontSize:19,fontWeight:FontWeight.w900)),
        const SizedBox(height:6),Text(['¡Venga, chicas! ¿Estáis listas?','¡Yo sí! ¡Vamos!',
          '¡Espérame, que voy!','¡Pues en marcha!'][introLine],
          style:const TextStyle(color:Colors.white,fontSize:17)),
        const Spacer(),const Align(alignment:Alignment.bottomRight,child:Text('TOCA PARA SEGUIR  ▶',
          style:TextStyle(color:Color(0xffffdd83),fontSize:11))),
      ])))),
    if(overlay!=null)overlay,
  ]);

  Widget _overlay(String title,String detail,List<Widget> buttons)=>Positioned.fill(child:ColoredBox(
    color:const Color(0xb0001324),child:Center(child:Container(width:495,padding:const EdgeInsets.all(16),
      decoration:BoxDecoration(color:const Color(0xf0113155),borderRadius:BorderRadius.circular(10),
        border:Border.all(color:const Color(0xffffd56c),width:4)),
      child:Column(mainAxisSize:MainAxisSize.min,children:[
        Text(title,textAlign:TextAlign.center,style:const TextStyle(color:Color(0xffffd46d),fontSize:25,fontWeight:FontWeight.w900)),
        const SizedBox(height:12),Text(detail,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:16)),
        const SizedBox(height:17),...buttons.map((x)=>Padding(padding:const EdgeInsets.only(bottom:9),child:x)),
      ])))));
}

// Secciones de fondos: escala nativa y suelo conocido. Prohibido espejar.
// Los tramos de apoyo deberán sustituirse por arte exclusivo si repiten un hito.
class SectionArt {
  const SectionArt(this.assetKey,this.floorInImage,{this.cropStart=0});
  final String assetKey;
  final double floorInImage;
  final double cropStart;
}

class StagePainter extends CustomPainter {
  StagePainter({required this.images,required this.stage,required this.cameraX,required this.time,
    required this.lastAttackTime,
    required this.hero,required this.otherSister,required this.father,required this.showFamily,
    required this.selected,required this.obstacles,required this.platforms,
    required this.coins,required this.collected,required this.enemies,required this.shots,
    required this.particlesUntil});
  final Map<String,ui.Image> images;
  final int stage,selected;
  final double cameraX,time,particlesUntil,lastAttackTime;
  final Character hero,otherSister,father;
  final bool showFamily;
  final List<Obstacle> obstacles;
  final List<Rect> platforms;
  final List<Offset> coins;
  final Set<int> collected;
  final List<Enemy> enemies;
  final List<Projectile> shots;

  @override
  void paint(Canvas canvas,Size size) {
    canvas.save();canvas.clipRect(const Rect.fromLTWH(0,0,viewW,viewH));
    canvas.drawColor(const Color(0xff79a9d5),BlendMode.src);
    _background(canvas); // Includes the APPROVED original street pavement; never add a fake second floor.
    // Low, reachable elevated surfaces made of integrated benches/platform props.
    // Exact collision rectangles and visible surfaces share the same coordinates.
    for (final p in platforms) {
      final x = p.left - cameraX;
      if (x < -225 || x > 850) continue;
      final prop = images[stage == 5 ? 'gym_bench' : stage == 6 ? 'backpack' : stage == 4 ? 'cone' : 'crate'];
      if (prop != null) {
        if (stage >= 4 && stage <= 6) {
          _sprite(canvas, images[stage == 5 ? 'gym_bench' : stage == 6 ? 'gym_bench' : 'gym_bench'],
              Rect.fromLTWH(x, p.top, p.width, groundY - p.top));
        } else {
          // Crate clusters support the upper stone paving; no floating rectangles.
          _sprite(canvas, images['crate'], Rect.fromLTWH(x+5,p.top+10,48,groundY-p.top-10));
          _sprite(canvas, images['crate'], Rect.fromLTWH(x+p.width-54,p.top+10,48,groundY-p.top-10));
          _sprite(canvas, images['crate'], Rect.fromLTWH(x+37,p.top,56,groundY-p.top));
        }
      }
    }
    for(final o in obstacles) {
      final x=o.x-cameraX;if(x< -90 || x>880)continue;
      if(o.destroyed) {
        if(time-o.smashedAt<.48) {
          final elapsed=time-o.smashedAt;
          final texture=images[o.kind];
          if(texture!=null) {
            // Pieces come from the SAME obstacle texture (not crude flat shapes).
            for(int k=0;k<9;k++) {
              final a=k*2*math.pi/9;
              final radial=elapsed*(55+(k%3)*19);
              final sx=(texture.width*(k%3)/3).floorToDouble();
              final sy=(texture.height*(k~/3)/3).floorToDouble();
              final sw=texture.width/3.0,sh=texture.height/3.0;
              _sprite(canvas,texture,Rect.fromCenter(center:Offset(
                x+o.w/2+radial*math.cos(a),o.y+o.h/2+radial*math.sin(a)+elapsed*29),
                width:math.max(5,o.w/4),height:math.max(5,o.h/4)),
                source:Rect.fromLTWH(sx,sy,sw,sh));
            }
          }
        }
        continue;
      }
      _sprite(canvas,images[o.kind],Rect.fromLTWH(x,o.y,o.w,o.h));
    }
    for(int i=0;i<coins.length;i++) {
      if(collected.contains(i))continue;
      final p=coins[i],x=p.dx-cameraX;if(x< -30 || x>830)continue;
      final w=20.0*(.72+.28*math.cos(time*6+i).abs());
      _sprite(canvas,images['coin'],Rect.fromCenter(center:Offset(x,p.dy+3*math.sin(time*5+i)),width:w,height:24));
    }
    for(final foe in enemies) {
      final x=foe.x-cameraX;if(x< -110 || x>900)continue;
      if(foe.defeated && time-foe.deathAt>.85)continue;
      final shadowAlpha=foe.aerial ? (0x55*(1-foe.flightAltitude/190)).round().clamp(12,85).toInt() : 0x55;
      canvas.drawOval(Rect.fromCenter(center:Offset(x,groundY+2),
        width:foe.aerial?39+foe.flightAltitude*.13:53,height:7),
        Paint()..color=Color.fromARGB(shadowAlpha,9,23,35));
      canvas.save();
      if(foe.defeated) {
        final alpha=(1-(time-foe.deathAt-.32)/.53).clamp(0.0,1.0).toDouble();
        canvas.saveLayer(Rect.fromLTWH(x-110,groundY-150,220,170),Paint()..color=Colors.white.withValues(alpha:alpha));
      }
      if(foe.facing==-1){canvas.translate(x,0);canvas.scale(-1,1);canvas.translate(-x,0);}
      if(foe.dog) {
        final variant=foe.kind.substring(4);
        final state=foe.defeated?'defeated':foe.stunned>0
          ? (foe.stunned>.43?'hit':'stunned'):foe.animalMode;
        // Leg key poses only advance WHILE travelling; no moonwalking in idle,
        // alert or bite states. Ground pivot and pixel scale remain unchanged.
        final running=['run','alert','run','walk'];
        final walking=['walk','alert'];
        final mode=state=='run'?running[(foe.animalTime*9).floor()%running.length]
          :state=='walk'?walking[(foe.animalTime*4).floor()%walking.length]
          :state=='stunned'?'idle':state;
        final source=dogVisibleBounds[mode];
        final idle=dogVisibleBounds['idle'];
        final img=images['dog_${variant}_$mode'];
        if(source!=null && idle!=null && img!=null) {
          final pixelScale=(variant=='doberman'?76.0:69.0)/idle.height;
          final w=source.width*pixelScale, h=source.height*pixelScale;
          canvas.save();
          if(foe.defeated) {
            // A short sideways collapse around the paws instead of running in
            // place while the alpha fade is playing.
            canvas.translate(x,groundY);
            canvas.rotate(-.58);
            canvas.translate(-x,-groundY);
          } else if(state=='hit' || state=='stunned') {
            canvas.translate(x,groundY);
            canvas.rotate(state=='hit' ? .17 : .055*math.sin(foe.t*17));
            canvas.translate(-x,-groundY);
          }
          _sprite(canvas,img,Rect.fromLTWH(x-w/2,groundY-h,w,h),source:source);
          canvas.restore();
        }
      } else if(foe.aerial && foe.flightAltitude>1) {
        final phase=(foe.t*10).floor()%4;
        final frame=foe.defeated?7:foe.stunned>0?6
          :foe.animalMode=='glide'?4:foe.animalMode=='dive'?5:phase;
        final bob=foe.defeated?0.0:3.0*math.sin(foe.t*5.3);
        // Large wings, but the body remains comparable in size to the original
        // 64px grounded pigeon. Pivot is measured from each pose's actual feet.
        // Both flight pixels/world scale and torso position stay consistent.
        const flightScale=pigeonAtlasWorldCell/pigeonAtlasCell;
        _sprite(canvas,images['pigeon_flight_sheet'],
          Rect.fromLTWH(x-pigeonFlightFootX[frame]*flightScale,
            groundY-foe.flightAltitude-pigeonFlightFootY[frame]*flightScale+bob,
            pigeonAtlasWorldCell,pigeonAtlasWorldCell),
          source:pigeonFlightSource(frame));
      } else if(['rival','goalkeeper','referee','novice','breakdancer','pigeon','cat','rat','bully','teacher','statue'].contains(foe.kind)) {
        // Distinct combat states: a teacher must not run while throwing an exam,
        // and a referee must actually show his raised red card in wind-up.
        final int frame;
        if (foe.defeated) {
          frame=4;
        } else if (foe.stunned>0) {
          frame=foe.ranged ? 1 : 3;
        } else if (foe.launched) {
          frame=foe.kind=='goalkeeper' ? (foe.t < .15 ? 0 : foe.t < .27 ? 2 : foe.t < .34 ? 3 : foe.t < .56 ? 4 : 1) : foe.kind=='referee' ? 2 : foe.kind=='breakdancer' ? 3
              : foe.kind=='teacher' ? 2 : 3;
        } else {
          frame=foe.ranged ? ((foe.t*2).floor()%2) : ((foe.t*6).floor()%3);
        }
        final hiFiCreature=foe.kind=='rat' || foe.kind=='cat';
        final img=images[hiFiCreature ? 'enemy_${foe.kind}_sheet' : 'enemy_${foe.kind}_$frame'];
        if(img!=null) {
          // Una misma escala de píxel para TODOS los fotogramas del enemigo:
          // jamás normalizar cada frame a una altura arbitraria (causa del gigantismo).
          final targetHeight = switch(foe.kind) {
            'rival' => 124.0, 'goalkeeper' => 121.0, 'novice' => 117.0, 'bully' => 137.0,
            'referee' => 143.0, 'teacher' => 145.0, 'breakdancer' => 126.0,
            'statue' => 139.0, 'pigeon' => 64.0,
            'rat' => creatureIdleHeights['rat']!,
            'cat' => creatureIdleHeights['cat']!, _ => 105.0,
          };
          final visible=hiFiCreature ? creatureFrameBounds['${foe.kind}_$frame']
            : enemyVisibleBounds['${foe.kind}_$frame'];
          final canonical=hiFiCreature ? creatureFrameBounds['${foe.kind}_0']
            : enemyVisibleBounds['${foe.kind}_0'];
          if(visible != null && canonical != null){
            // The visible body is anchored at the SAME floor and native pixel
            // scale across idle / run / hit / defeat. Transparent padding in a
            // source sheet cannot make the character float or grow.
            final pixelScale=targetHeight/canonical.height;
            final ww=visible.width*pixelScale;
            final actualHeight=visible.height*pixelScale;
            final airborne=0.0; // Ground pigeon art is used ONLY when grounded.
            // The pivot is the feet, so a wind-up never slides the enemy off the floor.
            // Small movement for large characters whose source sheets have
            // nearly identical waiting/walking poses (not a sprite-scale hack).
            final lean=foe.launched && foe.kind!='goalkeeper' ? -0.085 :
              (foe.kind=='bully' && !foe.defeated ? .028*math.sin(foe.t*8) : 0.0);
            canvas.save();
            if(lean != 0){
              canvas.translate(x,groundY+airborne);
              canvas.rotate(lean);
              canvas.translate(-x,-groundY-airborne);
            }
            _sprite(canvas,img,Rect.fromLTWH(x-ww/2,
              groundY-actualHeight+airborne,ww,actualHeight),source:visible);
            canvas.restore();
          }
        }
      }
      if(foe.defeated)canvas.restore();
      canvas.restore();
      if(foe.launched)_outlined(canvas,'!',Offset(x,groundY-126),const Color(0xffffdc58),23);
      if(foe.stunned>0 || foe.defeated) {
        for(int j=0;j<3;j++) {
          final a=time*7+j*math.pi*2/3;
          _outlined(canvas,'✦',Offset(x+24*math.cos(a),groundY-99+14*math.sin(a)),const Color(0xffffd46b),13);
        }
      }
    }
    if(showFamily) {
      _actor(canvas,father,'padre',2,false);
      _actor(canvas,otherSister,selected==0?'bailarina':'futbolista',1-selected,false);
    }
    _actor(canvas,hero,selected==0?'futbolista':'bailarina',selected,true);
    for(final s in shots) {
      if(!s.active)continue;
      final img=images[s.kind];final w=s.kind=='ball'?24.0:s.kind=='comb'?27.0:31.0;
      _sprite(canvas,img,Rect.fromCenter(center:Offset(s.x-cameraX,s.y),width:w,height:s.kind=='comb'?16:25));
    }
    // No near-camera atlas trees on chapter 1: preserve characters and landmarks.
    if(time<particlesUntil) {
      final x=hero.x-cameraX;
      for(int i=0;i<5;i++) {
        final a=time*5+i*2*math.pi/5;
        canvas.drawCircle(Offset(x+26*math.cos(a),hero.y-65+19*math.sin(a)),2,
          Paint()..color=const Color(0xffffdb66));
      }
    }
    canvas.restore();
  }

  // SNES-inspired THREE-PLANE world: distant approved illustration (camera
  // only pans across it ONCE); independently tileable near fence / garden /
  // barres; native-pixel paving/turf/parquet with world-speed collisions.
  // Unlike RC3, no foreground car/town hall/gazebo is duplicated every 1320px.
  // All original 0.8.0 image files remain untouched and load as far references.
  static const List<double> _floorArtTop = [380,390,390,390,386,286,278];
  static const List<double> _midArtTop = [330,355,330,345,196,170,172];

  void _backLayer(Canvas canvas,ui.Image? source,double sceneAlpha,double parallax,{double zoneOrigin=0}) {
    if(source == null || sceneAlpha <= 0)return;
    final limit=math.max(0.0,source.width.toDouble()-viewW);
    // No repeats, mirrors, or stretching of distant landmarks.
    final scroll=math.min(math.max(0, cameraX-zoneOrigin)*parallax,limit).toDouble();
    final bottom=math.min(_floorArtTop[stage],source.height.toDouble());
    final crop=Rect.fromLTWH(scroll,0,viewW,bottom);
    final dest=Rect.fromLTWH(0,0,viewW,bottom);
    canvas.drawImageRect(source,crop,dest,
      Paint()..filterQuality=FilterQuality.none
             ..color=Colors.white.withValues(alpha:sceneAlpha));
  }

  void _midLayer(Canvas canvas,ui.Image? tile,double sceneAlpha) {
    if(tile==null || sceneAlpha<=0)return;
    final tileW=tile.width.toDouble();
    final y=_midArtTop[stage];
    final first=(cameraX/tileW).floor();
    for(int n=first;n<=first+2;n++) {
      final dx=n*tileW-cameraX;
      // The dugout is a UNIQUE recognizable landmark, not an infinite fence
      // tile. The practice dummies and fence are intentionally repeatable.
      final art=(stage==4 && n%9!=0) ? (images['mid_4_plain'] ?? tile) : tile;
      canvas.drawImageRect(art,Rect.fromLTWH(0,0,tileW,art.height.toDouble()),
        Rect.fromLTWH(dx,y,tileW,tile.height.toDouble()),
        Paint()..filterQuality=FilterQuality.none
               ..color=Colors.white.withValues(alpha:sceneAlpha));
    }
  }

  // The scenery is distant, but anchored to a unique geographical region.
  // Each approved master is displayed ONCE. The 7,000+ world units of the
  // region pan a NON-REPEATING slice of its artwork; nearby physical props,
  // platforms, coins and floor travel at full world speed.
  void _neighborhoodVista(Canvas canvas, NeighborhoodBackdropPanel panel) {
    final art = images['neighborhood_${panel.asset}'];
    if (art == null) return;
    final sh = neighborhoodSourceHeight(panel.asset);
    final sw = neighborhoodViewSourceWidth(panel.asset);
    if (!neighborhoodCropFits(panel.asset, art.width.toDouble(), viewW)) {
      throw StateError('Scene source too narrow for viewport: ${panel.asset}');
    }
    final maxPan = math.max(0.0, art.width.toDouble() - sw);
    final sx = maxPan * neighborhoodPanFraction(panel, cameraX);
    _sprite(canvas, art, const Rect.fromLTWH(0, 0, viewW, 380),
      pixelated:false, source:Rect.fromLTWH(sx, 0, sw, sh));
  }

  // This join is bounded to 96 WORLD pixels across a border, rather than
  // dissolving a whole image for several seconds while Miren walks. Painting
  // is limited to the strip and follows camera coordinates; no one-off
  // landmark can appear in two separate world regions.
  void _neighborhoodJoin(Canvas canvas,
      NeighborhoodBackdropPanel left, NeighborhoodBackdropPanel right) {
    final seamX = left.end - cameraX;
    const half = neighborhoodSeamHalfWidth;
    if (seamX + half <= 0 || seamX - half >= viewW) return;
    final area = Rect.fromLTWH(seamX-half, 0, half*2, 380);
    canvas.save();
    canvas.clipRect(area);
    _neighborhoodVista(canvas, left);
    // A short horizontal alpha MASK on the incoming SCENE; it does not fade
    // either landscape as a function of time or alter the original images.
    canvas.saveLayer(area, Paint());
    _neighborhoodVista(canvas, right);
    canvas.drawRect(area, Paint()
      ..blendMode = BlendMode.dstIn
      ..shader = ui.Gradient.linear(
        Offset(seamX-half, 0), Offset(seamX+half, 0),
        [Colors.transparent, Colors.white]));
    canvas.restore();
    canvas.restore();
  }

  // Transparent margins are EXCLUDED from the atlas source region. Without
  // this, roots float above the pavement and crowns change scale on camera.
  static const List<Rect> _treeSourceBounds = [
    Rect.fromLTRB(33, 13, 724, 543),
    Rect.fromLTRB(725, 16, 1434, 539),
    Rect.fromLTRB(0, 545, 724, 1068),
    Rect.fromLTRB(741, 544, 1428, 1067),
  ];

  // Illustration masters already include detailed autumn trees. Extra atlas
  // vegetation is only warranted in a connector and NEVER in front of a
  // protected curved facade, canopy or rocket. This avoids foliage doubling.
  void _neighborhoodTrees(Canvas canvas,{bool foreground=false}) {
    if (foreground) return; // In RC1 these occluded the playable route.
    if (neighborhoodLandmarkInCamera(cameraX, viewW)) return;
    final atlas = images['neighborhood_trees_v091'];
    if (atlas == null) return;
    const spacing = 2350.0;
    final first = (cameraX / spacing).floor() - 1;
    for (int n = first; n < first + 4; n++) {
      if (n < 0) continue;
      final worldX = 1200.0 + n * spacing;
      if (!neighborhoodTreeAllowedAt(worldX)) continue;
      final x = worldX - cameraX;
      if (x < -130 || x > viewW + 130) continue;
      final source = _treeSourceBounds[n % _treeSourceBounds.length];
      const height = 78.0;
      final width = source.width * height / source.height;
      // Small decoration embedded in the mid-depth; never overlaps Sara.
      _sprite(canvas, atlas,
        Rect.fromLTWH(x - width/2, 375 - height, width, height),
        source: source);
    }
  }

  // LABORATORIO RC3: activación explícita solo para QA. El nuevo modelo
  // ancla el hito al mundo y RECHAZA material visual no construido. No
  // sustituye el capítulo en las compilaciones normales hasta aprobar arte.
  static const bool chapterOneWorldV3Lab =
      bool.fromEnvironment('CHAPTER_ONE_WORLD_V3_LAB', defaultValue:false);

  void _neighborhoodWorldV3Lab(Canvas canvas) {
    const sceneH = 380.0;
    canvas.drawRect(const Rect.fromLTWH(0, 0, viewW, sceneH),
        Paint()..color=const Color(0xff4da9ed));
    final piece = curvedBuildingPilot;
    final img = images['neighborhood_${piece.asset}'];
    if (img != null && piece.intersects(cameraX, viewW)) {
      final dest = Rect.fromLTWH(
          piece.worldX-cameraX, piece.worldY, piece.width, piece.height);
      // Fuente y destino escalan por el MISMO factor; el edificio conserva su
      // arquitectura, aparece UNA vez y no queda pegado a la pantalla.
      canvas.drawImageRect(img,
          Rect.fromLTWH(0, 0, img.width.toDouble(), 690), dest,
          Paint()..filterQuality=FilterQuality.none);
    }
    // La zona magenta es una alarma de ARTE AUSENTE, no un paisaje nuevo.
    // Se muestra solo con --dart-define=CHAPTER_ONE_WORLD_V3_LAB=true.
    final missing = missingWorldArtInCamera(cameraX, viewW, [piece]);
    if (missing > 0.5) {
      final left = math.max(0.0, piece.right-cameraX);
      canvas.drawRect(Rect.fromLTWH(left, 0, viewW-left, sceneH),
          Paint()..color=const Color(0xff532a6c));
      _outlined(canvas, 'ARTE PENDIENTE · NO APROBADO',
          Offset((left+viewW)/2, 90), Colors.white, 17);
    }
  }

  // Laboratorio RC3 V4: mundo completo con cámara, capas, objetos,
  // culling y suelo independientes. No es el render de producción porque
  // los bordes fotográficos requieren una salida artística aprobada.
  static const bool chapterOneWorldV4Lab =
      bool.fromEnvironment('CHAPTER_ONE_WORLD_V4_LAB', defaultValue:false);

  void _neighborhoodWorldV4Lab(Canvas canvas) {
    const scenicBottom = 380.0;
    final sky = Rect.fromLTWH(0, 0, viewW, scenicBottom);
    canvas.drawRect(sky, Paint()..shader=ui.Gradient.linear(
       const Offset(0,0), const Offset(0,380),
       [const Color(0xff309af3),const Color(0xffa4dbff)]));
    // Montañas lejanas: capa world-space y parallax deliberado. Las lomas
    // se muestrean en coordenadas globales, sin pantalla-origen repetida.
    for (int layer=0;layer<2;layer++) {
      final speed=layer==0?0.18:0.38;
      final baseline=layer==0?297.0:348.0;
      final path=Path()..moveTo(0,scenicBottom)
        ..lineTo(0,baseline);
      for (double sx=0;sx<=viewW+8;sx+=8) {
        final wx=sx+cameraX*speed;
        final y=baseline-21*math.sin(wx/(layer==0?251.0:137.0))
          -11*math.sin(wx/(layer==0?103.0:75.0));
        path.lineTo(sx,y.roundToDouble());
      }
      path..lineTo(viewW,scenicBottom)..close();
      canvas.drawPath(path, Paint()..color=layer==0?
        const Color(0xff699ab5):const Color(0xff478b78));
    }
    // Nubes independientes en paralaje lento, elaboradas desde arte NUEVO.
    // No se reutilizan ni se estiran las cuatro ilustraciones originales.
    final clouds=images['neighborhood_clouds_v4'];
    if(clouds!=null) {
      for(int i=0;i<100;i++) {
        final wx=110.0+i*500.0+(i%3)*48;
        final dx=wx-cameraX*0.18;
        if(dx < -290 || dx>viewW+290)continue;
        final box=ch1CloudRectsV4[i%2];
        final dest=Rect.fromLTWH(dx,35+(i%4)*19,264,94);
        canvas.drawImageRect(clouds,
           Rect.fromLTWH(box[0],box[1],box[2],box[3]),dest,
           Paint()..filterQuality=FilterQuality.none);
      }
    }
    // Dos profundidades: arbolado más alejado, detrás de vallados/mobiliario.
    final distantAtlas=images['neighborhood_park_props_atlas'];
    if(distantAtlas!=null) {
      for(final prop in ch1MidTreesV4()) {
        final r=ch1PropRectsV4[prop.atlasIndex];
        final ww=prop.height*r[2]/r[3];
        final dx=prop.worldX-cameraX;
        if(dx+ww<0||dx>viewW)continue;
        canvas.drawImageRect(distantAtlas,
          Rect.fromLTWH(r[0],r[1],r[2],r[3]),
          Rect.fromLTWH(dx,prop.baseY-prop.height,ww,prop.height),
          Paint()..filterQuality=FilterQuality.none
                 ..color=Colors.white.withValues(alpha:.87));
      }
    }
    // Los hitos originales no se repiten; transforman mundo -> pantalla.
    for (final landmark in ch1LandmarksV4) {
      if (!landmark.visible(cameraX,viewW)) continue;
      final img=images['neighborhood_${landmark.asset}'];
      if (img==null) continue;
      final destination=Rect.fromLTWH(
        landmark.screenX(cameraX),0,landmark.width,landmark.displayH);
      canvas.drawImageRect(img,
        Rect.fromLTWH(0,0,img.width.toDouble(),landmark.sourceH),
        destination,Paint()..filterQuality=FilterQuality.none);
    }
    // Fábrica de muros repetibles: a diferencia de las panorámicas únicas,
    // son piezas de mosaico. Ninguna afecta a la geometría de colisiones.
    final atlasForWalls=images['neighborhood_park_props_atlas'];
    if(atlasForWalls!=null) {
      final b=ch1PropRectsV4[10];
      const wallH=57.0;
      final wallW=wallH*b[2]/b[3];
      final first=(cameraX/wallW).floor()-1;
      final last=((cameraX+viewW)/wallW).ceil()+1;
      for(int n=first; n<last; n++) {
        if(n<0) continue;
        final x=n*wallW;
        // Nunca pegar un muro nuevo por encima del vallado fotográfico.
        if(ch1LandmarksV4.any((p) =>
            x+wallW>=p.x-16 && x<=p.right+16)) continue;
        canvas.drawImageRect(atlasForWalls,
            Rect.fromLTWH(b[0],b[1],b[2],b[3]),
            Rect.fromLTWH(x-cameraX,325,wallW,wallH),
            Paint()..filterQuality=FilterQuality.none);
      }
    }
    // Atlas de objetos completos anclados al mundo. Renderizamos únicamente
    // los objetos del viewport. No cubrir las escenas originales ni a Sara.
    final atlas=images['neighborhood_park_props_atlas'];
    if(atlas!=null) {
      for(final prop in ch1PropsV4()) {
        final bounds=ch1PropRectsV4[prop.atlasIndex];
        final width=prop.height*bounds[2]/bounds[3];
        final dx=ch1OnScreenV4(prop.worldX,cameraX);
        if(dx+width<0 || dx>viewW) continue;
        canvas.drawImageRect(atlas,
          Rect.fromLTWH(bounds[0],bounds[1],bounds[2],bounds[3]),
          Rect.fromLTWH(dx,prop.baseY-prop.height,width,prop.height),
          Paint()..filterQuality=FilterQuality.none);
      }
    }
  }

  // CAPITULO 1 RC3: paisaje fisico continuo por tiles. El x de cada imagen
  // corresponde a un unico x de mundo. No hay fundidos temporales, auto-pan,
  // fotografias estiradas, ni duplicacion de escenas por region.
  // Paralaje de profundidad RC3 FIX2: fondo elaborado inspirado en el
  // detalle de las ilustraciones deportivas; se repite cada ~7.400 unidades
  // sin congelarse. El mapa cercano mantiene EXACTAMENTE su cámara 1:1.
  void _drawCh1Loop(Canvas canvas, ui.Image? image, double speed) {
    if (image == null) return;
    final width=image.width.toDouble();
    final shift=(cameraX*speed)%width;
    for (double x=-shift; x<viewW; x+=width) {
      canvas.drawImageRect(image,
        Rect.fromLTWH(0,0,width,image.height.toDouble()),
        Rect.fromLTWH(x,0,width,380),
        Paint()..filterQuality=FilterQuality.none);
    }
  }

  void _neighborhoodPhysicalWorld(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(0,0,viewW,380),
      Paint()..color=const Color(0xff4b9fe8));
    _drawCh1Loop(canvas,images['ch1_far_city_loop'],ch1FarSpeed);
    _drawCh1Loop(canvas,images['ch1_mid_woodland_loop'],ch1MidSpeed);
    for (final index in ch1PhysicalVisibleTiles(cameraX,viewportWidth:viewW)) {
      final img = images['ch1_world_tile_$index'];
      if (img == null) continue;
      final x = ch1PhysicalTileX(index)-cameraX;
      final width = ch1PhysicalTileActualWidth(index);
      // Pixel exacto, incluida la ultima pieza de 148px.
      canvas.drawImageRect(img,
        Rect.fromLTWH(0, 0, width, ch1PhysicalHeight),
        Rect.fromLTWH(x, 0, width, ch1PhysicalHeight),
        Paint()..filterQuality=FilterQuality.none);
    }
  }

  // Solo para contrastar el render antiguo durante una inspeccion de QA.
  static const bool chapterOneLegacyBackdrop =
      bool.fromEnvironment('CH1_LEGACY_BACKGROUND',defaultValue:false);

  void _neighborhoodBackground(Canvas canvas) {
    if (!chapterOneLegacyBackdrop && !chapterOneWorldV3Lab && !chapterOneWorldV4Lab) {
      _neighborhoodPhysicalWorld(canvas);
      return;
    }
    if (chapterOneWorldV4Lab) {
      _neighborhoodWorldV4Lab(canvas);
      return;
    }
    if (chapterOneWorldV3Lab) {
      _neighborhoodWorldV3Lab(canvas);
      return;
    }
    // Solid sky behind the scene for safe viewport edges even during joins.
    canvas.drawRect(const Rect.fromLTWH(0, 0, viewW, 380),
      Paint()..color=const Color(0xff4da9ed));
    for (final panel in neighborhoodBackdropPanels) {
      final worldLeft=panel.start-cameraX;
      final worldRight=panel.end-cameraX;
      if (worldRight<=0 || worldLeft>=viewW) continue;
      canvas.save();
      canvas.clipRect(Rect.fromLTRB(
        math.max(0.0, worldLeft), 0,
        math.min(viewW, worldRight), 380));
      _neighborhoodVista(canvas, panel);
      canvas.restore();
    }
    // Only six unique spatial joins, never dozens of random hard cuts.
    for (var i=0;i<neighborhoodBackdropPanels.length-1;i++) {
      _neighborhoodJoin(canvas,neighborhoodBackdropPanels[i],
          neighborhoodBackdropPanels[i+1]);
    }
    _neighborhoodTrees(canvas); // connector-only, never hide landmarks
  }

  // El antiguo método de grandes panoramas y fundidos entre estancias
  // queda retirado. Fútbol usa el paralaje exterior; danza y colegio usan
  // muros físicos, marcos de puertas y vistas tras ventanas (abajo).

  void _activityProps(Canvas canvas) {
    final football=stage==4;
    final atlas=images[football?'activity_football_props':'activity_dance_props'];
    if(atlas==null)return;
    final sources=football?footballActivityProps:danceActivityProps;
    final heights=football?footballActivityPropHeights:danceActivityPropHeights;
    const footballMotifs=<List<int>>[[0,1,2,4],[0,1,3,4],[1,3,4,5]];
    const danceMotifs=<List<int>>[[0,1,2],[2,3,4],[1,4,5]];
    final first=(cameraX/389).floor()-2;
    for(int n=first;n<first+7;n++) {
      if(n<0)continue;
      final seed=((n+17)*73856093 ^ (n+43)*19349663)&0x7fffffff;
      final worldX=250+n*389.0+(seed%131)-65;
      if(worldX<330 || worldX>stageWidth-240)continue;
      final x=worldX-cameraX;
      if(x< -190 || x>viewW+190)continue;
      final zoneIndex=activityZoneIndex(activityZones(stage),worldX);
      final kinds=(football?footballMotifs:danceMotifs)[zoneIndex];
      final kind=kinds[(seed~/11)%kinds.length];
      final src=sources[kind];
      final h=heights[kind],w=src.width*h/src.height;
      // Only truly movable small objects repeat, unevenly. Goal, terraces,
      // mirrored studio and rehearsal stage belong ONLY to their panoramas.
      _sprite(canvas,atlas,Rect.fromLTWH(x-w/2,groundY-h,w,h),source:src);
    }
  }

  // Capa X 0.30 y 0.56: mismo contrato TWC del barrio, arte de fútbol.
  // La transparencia sólo pertenece al arbolado recortado, no a escenas
  // enteras. Cada recurso puede repetirse cíclicamente sin fundidos en juego.
  void _footballLoopTWC(Canvas canvas, ui.Image? image, double speed) {
    if (image == null) return;
    final width = image.width.toDouble();
    final shift = footballLoopShiftTWC(cameraX, speed, image.width);
    for (double x = -shift; x < viewW; x += width) {
      canvas.drawImageRect(image,
        Rect.fromLTWH(0,0,width,image.height.toDouble()),
        Rect.fromLTWH(x,0,width,footballBackdropHeightTWC),
        Paint()..filterQuality=FilterQuality.none);
    }
  }

  void _footballBackgroundTWC(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(0,0,viewW,footballBackdropHeightTWC),
      Paint()..color=const Color(0xff54a4ed));
    _footballLoopTWC(canvas,images['football_far_twc'],footballFarSpeedTWC);
    _footballLoopTWC(canvas,images['football_mid_twc'],footballMidSpeedTWC);
    // Construcción física real 1:1. No fotos panorámicas lentas ni fundidos.
    for (final n in footballVisibleModulesTWC(cameraX,viewportWidth:viewW)) {
      final img=images['football_near_tile_${footballNearModuleAssetIndex(n)}'];
      if (img==null) continue;
      final x=footballNearModuleX(n)-cameraX;
      canvas.drawImageRect(img,
        Rect.fromLTWH(0,0,footballTileWidthTWC,footballBackdropHeightTWC),
        Rect.fromLTWH(x,0,footballTileWidthTWC,footballBackdropHeightTWC),
        Paint()..filterQuality=FilterQuality.none);
    }
  }

  // INTERIORES aprobados TWC: misma cámara que fútbol/barrio, pero el
  // parallax se ve ÚNICAMENTE tras el cristal de los paneles RGBA.
  // La pared, el mobiliario y el suelo siguen en coordenadas de mundo 100%.
  void _interiorLoopTWC(Canvas canvas, ui.Image? image,
      double speed, double height) {
    if (image == null) return;
    final width=image.width.toDouble();
    final shift=interiorLoopOffsetTWC(cameraX,speed,image.width);
    for(double x=-shift;x<viewW;x+=width) {
      canvas.drawImageRect(image,
        Rect.fromLTWH(0,0,width,image.height.toDouble()),
        Rect.fromLTWH(x,0,width,height),
        Paint()..filterQuality=FilterQuality.none);
    }
  }

  void _interiorBackgroundTWC(Canvas canvas) {
    final theme=stage==5 ? 'dance' : 'school';
    final height=stage==5 ? 286.0 : 278.0;
    canvas.drawRect(Rect.fromLTWH(0,0,viewW,height),
      Paint()..color=const Color(0xffabd7e9));
    // El orden se conserva: lejos 0.30, medio 0.56, muros y objetos 1.00.
    _interiorLoopTWC(canvas,images['interior_${theme}_far'],
        interiorFarSpeedTWC,height);
    _interiorLoopTWC(canvas,images['interior_${theme}_mid'],
        interiorMidSpeedTWC,height);
    for (var zone=0;zone<3;zone++) {
      final start=interiorZoneEdgesTWC[zone];
      final end=interiorZoneEdgesTWC[zone+1];
      if (end<=cameraX || start>=cameraX+viewW) continue;
      final clip=Rect.fromLTRB(
        math.max(0.0,start-cameraX),0,
        math.min(viewW,end-cameraX),height);
      canvas.save();canvas.clipRect(clip);
      for (final index in interiorVisibleModulesTWC(zone,cameraX,
          viewportWidth:viewW)) {
        final variant=interiorModuleVariantTWC(zone,index);
        final image=images['interior_${theme}_z${zone}_panel_$variant'];
        if(image==null)continue;
        final x=interiorModuleXWorldTWC(zone,index)-cameraX;
        canvas.drawImageRect(image,
          Rect.fromLTWH(0,0,interiorModuleWidthTWC,height),
          Rect.fromLTWH(x,0,interiorModuleWidthTWC,height),
          Paint()..filterQuality=FilterQuality.none);
      }
      canvas.restore();
    }
    // Pizarras y biblioteca: Hitos ÚNICOS. No forman parte del panel
    // repetible; su posición es 100% mundo, no fade ni parallax.
    if(stage==6) {
      for(final item in <(String,double,double)>[
        ('estanteria_biblioteca',1720,0),
        ('pizarra_matematicas',15320,52),
        ('pizarra_informatica',29820,51)]) {
        final art=images['interior_school_${item.$1}'];
        if(art==null)continue;
        final x=item.$2-cameraX;
        if(x+art.width<0 || x>=viewW)continue;
        canvas.drawImageRect(art,
          Rect.fromLTWH(0,0,art.width.toDouble(),art.height.toDouble()),
          Rect.fromLTWH(x,item.$3,art.width.toDouble(),art.height.toDouble()),
          Paint()..filterQuality=FilterQuality.none);
      }
    }
    // Marcos de paso colocados en x absoluto. No crossfade de habitaciones.
    final passage=images['interior_${theme}_passage'];
    if(passage!=null) {
      for (final edge in [interiorZoneEdgesTWC[1],interiorZoneEdgesTWC[2]]) {
        final x=edge-cameraX-60;
        if(x+120<=0 || x>=viewW) continue;
        canvas.drawImageRect(passage,
          Rect.fromLTWH(0,0,120,height),Rect.fromLTWH(x,0,120,height),
          Paint()..filterQuality=FilterQuality.none);
      }
    }
  }

  void _background(Canvas canvas) {
    // The approved detailed backdrop is a DISTANT vista. Its limited camera
    // pan cannot wrap the same clock, cathedral, car or kiosk indefinitely.
    // Foreground structures scroll at full world speed, just like sprites.
    if(stage == 0) {
      _neighborhoodBackground(canvas);
    } else if(stage == 4) {
      _footballBackgroundTWC(canvas);
    } else if(stage == 5 || stage == 6) {
      // Sala de danza y colegio: interiores por piezas, sin fantasmas.
      _interiorBackgroundTWC(canvas);
    } else {
      _backLayer(canvas,images['scene_$stage'],1,0.014);
      _midLayer(canvas,images['mid_$stage'],1);
    }
    // Rich APPROVED world floor tiles: stone, turf, polished parquet or school
    // flooring. The exact same groundY governs hero feet and collision tests.
    final tile=images['ground_$stage'];
    if(tile!=null){
      final tileW=tile.width.toDouble();
      final first=(cameraX/tileW).floor();
      for(int n=first;n<=first+2;n++){
        final x=n*tileW-cameraX;
        _sprite(canvas,tile,Rect.fromLTWH(x,_floorArtTop[stage],tileW,tile.height.toDouble()));
      }
    }
    if(stage == 4 || stage == 5) _activityProps(canvas);
    if(stage==6) {
      final desk=images['interior_school_mesa_aula'];
      if(desk!=null) {
        // Mesas sobre el suelo a la velocidad 1:1, solo en las aulas.
        for(final room in [1,2]) {
          final start=interiorZoneEdgesTWC[room];
          final end=interiorZoneEdgesTWC[room+1];
          final first=((cameraX-start)/570).floor()-1;
          for(var n=math.max(0,first);n<first+5;n++) {
            final worldX=start+260+n*570;
            if(worldX>end-180)break;
            final x=worldX-cameraX;
            if(x+desk.width<0||x>=viewW)continue;
            canvas.drawImageRect(desk,
              Rect.fromLTWH(0,0,desk.width.toDouble(),desk.height.toDouble()),
              Rect.fromLTWH(x,286,desk.width.toDouble(),desk.height.toDouble()),
              Paint()..filterQuality=FilterQuality.none);
            if(room==2) {
              final pc=images['interior_school_ordenador_aula'];
              if(pc!=null) {
                canvas.drawImageRect(pc,
                  Rect.fromLTWH(0,0,pc.width.toDouble(),pc.height.toDouble()),
                  Rect.fromLTWH(x+34,233,pc.width.toDouble(),pc.height.toDouble()),
                  Paint()..filterQuality=FilterQuality.none);
              }
            }
          }
        }
      }
    }
  }
  void _actor(Canvas canvas,Character c,String role,int index,bool active) {
    final costume=(stage==4 && role=='futbolista')||(stage==5 && role=='bailarina');
    // El ataque utiliza la pose auténtica de la hoja aprobada. Solo se activa
    // en protagonistas con atuendo temático; padre/hermana no se ven afectados.
    final isCostumeAttack=active && costume && time-lastAttackTime>=0 && time-lastAttackTime<.23;
    final phase=jumpVisualPhase(grounded:c.grounded,vy:c.vy,time:time,
      jumpedAt:c.jumpedAt,landedAt:c.landedAt);
    // Approved character art stays intact. Rise and apex use their genuine
    // leap, falling extends the feet, and landing compresses the idle stance.
    final pose=isCostumeAttack?'attack_0':
      phase==JumpVisualPhase.takeoff || phase==JumpVisualPhase.rising ||
      phase==JumpVisualPhase.apex ? 'jump_0' :
      phase==JumpVisualPhase.falling ? 'jump_0' :
      phase==JumpVisualPhase.impact || phase==JumpVisualPhase.recovery ? 'idle_0' :
      c.vx.abs()>15?'walk_${(c.travelled/23).floor()%2}':'idle_0';
    final img=images['${costume?'costume_':''}${role}_$pose'];if(img==null)return;
    final base=images['${costume?'costume_':''}${role}_idle_0'];
    final standardHeight=role=='padre'?134.0:role=='bailarina'?112.0:124.0;
    final scale=standardHeight/(base?.height ?? img.height);
    final w=img.width*scale,h=img.height*scale,x=c.x-cameraX;
    if(x< -120 || x>900)return;
    final floorAtX=shadowSurfaceY(footX:c.x,footY:c.y,floorY:groundY,
      surfaces:platforms.followedBy(obstacles.where((o)=>!o.destroyed).map((o)=>o.rect)));
    final altitude=math.max(0.0,floorAtX-c.y);
    final shadowFactor=jumpShadowScale(altitude);
    // Physical contact projection: X follows the heroine but shadow Y sticks
    // to floor/platform. Both the dark oval and gold selection ring share it.
    canvas.drawOval(Rect.fromCenter(center:Offset(x,floorAtX+3),
      width:w*.7*shadowFactor,height:8*shadowFactor),
      Paint()..color=Color.fromARGB(jumpShadowAlpha(altitude),11,28,39));
    if(active)canvas.drawArc(Rect.fromCenter(center:Offset(x,floorAtX+4),
      width:38*shadowFactor,height:11*shadowFactor),0,math.pi,false,
      Paint()..color=const Color(0xffffdf73)..style=PaintingStyle.stroke..strokeWidth=2);
    if(time<c.hurtUntil && (time*12).floor().isEven)return;
    var stretchX=1.0,stretchY=1.0,tilt=0.0;
    switch(phase) {
      case JumpVisualPhase.takeoff:
        stretchX=.955;stretchY=1.065;tilt=-.045;
        break;
      case JumpVisualPhase.rising:
        stretchY=1.025;tilt=-.035;
        break;
      case JumpVisualPhase.apex:
        stretchX=1.025;stretchY=.975;
        break;
      case JumpVisualPhase.falling:
        stretchY=1.015;tilt=.045;
        break;
      case JumpVisualPhase.impact:
        stretchX=1+.09*c.landingStrength;
        stretchY=1-.17*c.landingStrength;
        break;
      case JumpVisualPhase.recovery:
        final progress=((time-c.landedAt-.10)/.14).clamp(0.0,1.0).toDouble();
        stretchX=1.035-.035*progress;
        stretchY=.95+.05*progress;
        break;
      case JumpVisualPhase.grounded:
        break;
    }
    canvas.save();
    if(c.facing<0){canvas.translate(x,0);canvas.scale(-1,1);canvas.translate(-x,0);}
    if(tilt!=0) {
      canvas.translate(x,c.y);canvas.rotate(tilt);canvas.translate(-x,-c.y);
    }
    _sprite(canvas,img,Rect.fromLTWH(x-w*stretchX/2,
      c.y-h*stretchY+5*scale,w*stretchX,h*stretchY),pixelated:false);
    canvas.restore();
    if(active && (phase==JumpVisualPhase.impact || phase==JumpVisualPhase.recovery)) {
      final duration=time-c.landedAt;
      final fade=(1-duration/.24).clamp(0.0,1.0).toDouble();
      final dust=Paint()..color=Color.fromARGB((fade*148).round(),191,178,149);
      // Small 16-bit-style impact puffs anchored to the contact plane.
      for(final sign in [-1,1]) {
        canvas.drawRect(Rect.fromCenter(center:Offset(x+sign*(17+duration*32),floorAtX-4-duration*14),
          width:5,height:4),dust);
        canvas.drawRect(Rect.fromCenter(center:Offset(x+sign*(26+duration*21),floorAtX-1-duration*9),
          width:3,height:3),dust);
      }
    }
  }
  static void _outlined(Canvas c,String s,Offset center,Color color,double font) {
    final tp=TextPainter(text:TextSpan(text:s,style:TextStyle(color:color,fontSize:font,
      fontWeight:FontWeight.w900,shadows:const [Shadow(color:Colors.black,blurRadius:3)])),
      textDirection:TextDirection.ltr)..layout();tp.paint(c,Offset(center.dx-tp.width/2,center.dy));
  }
  static void _sprite(Canvas c,ui.Image? img,Rect target,{bool pixelated=true, Rect? source}) {
    if(img==null)return;
    c.drawImageRect(img,source ?? Rect.fromLTWH(0,0,img.width.toDouble(),img.height.toDouble()),target,
      Paint()..filterQuality=pixelated?FilterQuality.none:FilterQuality.low);
  }
  @override
  bool shouldRepaint(covariant StagePainter oldDelegate)=>true;
}
