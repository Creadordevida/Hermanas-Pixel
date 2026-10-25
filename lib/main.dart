import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sprite_bounds.g.dart';
import 'hero_hearts.dart';

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
  'rat', 'rival', 'referee', 'novice', 'breakdancer', 'bully', 'teacher',
];
const List<String> poses = ['idle', 'walk', 'attack', 'hit', 'defeated'];

enum Screen { title, map, choose, introduction, playing, chapterEnd, gameOver, paused }

class Character {
  Character(this.x, {this.y = groundY});
  double x, y;
  double vx = 0, vy = 0, travelled = 0, hurtUntil = 0;
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
  Enemy(this.id, this.kind, this.x) : home = x;
  final int id;
  final String kind;
  final double home;
  double x;
  int facing = -1, hits = 0;
  double t = 0, attackCooldown = 1, stunned = 0, deathAt = -1;
  bool launched = false;
  bool get defeated => deathAt >= 0;
  bool get ranged => ['referee','breakdancer','teacher','statue'].contains(kind);
  bool get dog => kind.startsWith('dog_');
  bool get aerial => kind == 'pigeon';
  int get hp => kind == 'dog_doberman' ? 2 : ranged ? 3 : 1;
  double get speed => switch(kind) {
    'dog_dalmatian' => 56, 'dog_doberman' => 112,
    'rat' => 118, 'cat' => 92, 'pigeon' => 84,
    'rival' => 90, 'novice' => 94, 'bully' => 90,
    _ => 72,
  };
  double get detection => kind == 'dog_dalmatian' ? 145 : kind == 'dog_doberman' ? 290 : 220;
  double get height => aerial ? 99 + 30 * math.sin(t * 4) : kind == 'rat' ? 21 : 64;
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
    4 => ['rival','referee'],
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
        'title':'assets/images/title_approved.png',
        'logo':'assets/images/brand_logo_twc.png',
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
      for (final v in ['rival','referee','novice','breakdancer','pigeon','cat','rat','bully','teacher','statue']) {
        for (int j=0;j<5;j++) paths['enemy_${v}_$j'] = 'assets/images/enemies/${v}_$j.png';
      }
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
      if (prog<.3 && ['referee','breakdancer','teacher','statue','dog_doberman'].contains(type)) {
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
          final ey=groundY-(foe.aerial?94:foe.kind=='rat'?24:64);
          if((shot.x-foe.x).abs()<37 && (shot.y-ey).abs()<(foe.aerial?42:51)) {
            foe.hits++;foe.stunned=.66;foe.t=0;shot.active=false;
            particlesUntil=time+.4;
            if(foe.hits>=foe.hp)foe.deathAt=time;
            break;
          }
        }
      }
      if(shot.y>groundY+40 || shot.life>2.5 || shot.x<0 || shot.x>stageWidth)shot.active=false;
    }
    shots.removeWhere((s)=>!s.active);
    for(final foe in enemies) {
      foe.t+=dt;foe.attackCooldown=math.max(0,foe.attackCooldown-dt);
      if(foe.defeated)continue;
      if(foe.stunned>0){foe.stunned=math.max(0,foe.stunned-dt);continue;}
      final distance=hero.x-foe.x,absDist=distance.abs();
      if(foe.ranged) {
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
    if(screen==Screen.playing && hero.grounded) {hero.vy=-423;hero.grounded=false;}
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
  Widget build(BuildContext context) => Scaffold(backgroundColor:const Color(0xff0d2943),body:Center(
    child:FittedBox(fit:BoxFit.contain,child:SizedBox(width:viewW,height:viewH,child:_screen()))));

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
    Positioned.fill(child:Image.asset('assets/images/title_approved.png',fit:BoxFit.fill)),
    Positioned(left:551,top:183,width:208,height:59,child:Material(color:Colors.transparent,
      child:InkWell(onTap:_startNew))),
    Positioned(left:557,top:249,width:203,height:61,child:Material(
      color:savedAvailable?Colors.transparent:const Color(0x99505b67),
      child:InkWell(onTap:savedAvailable?_continue:null))),
    if(!savedAvailable)const Positioned(left:579,top:299,child:Text('Sin partida guardada',
      style:TextStyle(color:Colors.white,fontSize:11,shadows:[Shadow(color:Colors.black,blurRadius:3)]))),
    Positioned(left:303,bottom:4,width:194,height:43,child:Container(padding:const EdgeInsets.all(4),
      decoration:BoxDecoration(color:const Color(0xa0092749),borderRadius:BorderRadius.circular(9)),
      child:Image.asset('assets/images/brand_logo_twc.png',fit:BoxFit.contain))),
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
      canvas.drawOval(Rect.fromCenter(center:Offset(x,groundY+2),width:53,height:7),Paint()..color=const Color(0x55091723));
      canvas.save();
      if(foe.defeated) {
        final alpha=(1-(time-foe.deathAt-.32)/.53).clamp(0.0,1.0).toDouble();
        canvas.saveLayer(Rect.fromLTWH(x-110,groundY-150,220,170),Paint()..color=Colors.white.withValues(alpha:alpha));
      }
      if(foe.facing==-1){canvas.translate(x,0);canvas.scale(-1,1);canvas.translate(-x,0);}
      final y=groundY-foe.height;
      if(foe.dog) {
        final variant=foe.kind.substring(4);
        final mode=foe.defeated?'defeated':foe.stunned>0?'hit':foe.t%1>.5?'run':'walk';
        _sprite(canvas,images['dog_${variant}_$mode'],Rect.fromLTWH(x-48,y-44,96,78));
      } else if(['rival','referee','novice','breakdancer','pigeon','cat','rat','bully','teacher','statue'].contains(foe.kind)) {
        // Distinct combat states: a teacher must not run while throwing an exam,
        // and a referee must actually show his raised red card in wind-up.
        final int frame;
        if (foe.defeated) {
          frame=4;
        } else if (foe.stunned>0) {
          frame=foe.ranged ? 1 : 3;
        } else if (foe.launched) {
          frame=foe.kind=='referee' ? 2 : foe.kind=='breakdancer' ? 3
              : foe.kind=='teacher' ? 2 : 3;
        } else {
          frame=foe.ranged ? ((foe.t*2).floor()%2) : ((foe.t*6).floor()%3);
        }
        final img=images['enemy_${foe.kind}_$frame'];
        if(img!=null) {
          // Una misma escala de píxel para TODOS los fotogramas del enemigo:
          // jamás normalizar cada frame a una altura arbitraria (causa del gigantismo).
          final targetHeight = switch(foe.kind) {
            'rival' => 124.0, 'novice' => 117.0, 'bully' => 137.0,
            'referee' => 143.0, 'teacher' => 145.0, 'breakdancer' => 126.0,
            'statue' => 139.0, 'pigeon' => 64.0,
            'rat' => 41.0, 'cat' => 72.0, _ => 105.0,
          };
          final visible=enemyVisibleBounds['${foe.kind}_$frame'];
          final canonical=enemyVisibleBounds['${foe.kind}_0'];
          if(visible != null && canonical != null){
            // The visible body is anchored at the SAME floor and native pixel
            // scale across idle / run / hit / defeat. Transparent padding in a
            // source sheet cannot make the character float or grow.
            final pixelScale=targetHeight/canonical.height;
            final ww=visible.width*pixelScale;
            final actualHeight=visible.height*pixelScale;
            final airborne=foe.aerial ? -58.0 : 0.0;
            // The pivot is the feet, so a wind-up never slides the enemy off the floor.
            // Small movement for large characters whose source sheets have
            // nearly identical waiting/walking poses (not a sprite-scale hack).
            final lean=foe.launched ? -0.085 :
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

  ui.Image? _schoolImage(int index,bool mid) {
    final suffix = index==1 ? 'classroom' : 'computers';
    return images[mid ? 'mid_school_$suffix' : 'scene_school_$suffix'];
  }

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

  void _background(Canvas canvas) {
    // The approved detailed backdrop is a DISTANT vista. Its limited camera
    // pan cannot wrap the same clock, cathedral, car or kiosk indefinitely.
    // Foreground structures scroll at full world speed, just like sprites.
    if(stage != 6) {
      _backLayer(canvas,images['scene_$stage'],1,0.014);
      _midLayer(canvas,images['mid_$stage'],1);
    } else {
      // Hallway -> classroom -> computer room, once per chapter (not repeated
      // cyclically as was the case in RC3). The final 700 units of each zone
      // crossfade; the scenery layer keeps exact pixel dimensions throughout.
      final zone=stageWidth/3;
      final int part=(cameraX/zone).floor().clamp(0,2).toInt();
      final towardsNext=(cameraX-(part+1)*zone+700).clamp(0.0,700.0)/700;
      final next=math.min(2,part+1);
      final currentArt=part==0?images['scene_6']:_schoolImage(part,false);
      final currentMid=part==0?images['mid_6']:_schoolImage(part,true);
      final nextArt=next==0?images['scene_6']:_schoolImage(next,false);
      final nextMid=next==0?images['mid_6']:_schoolImage(next,true);
      _backLayer(canvas,currentArt,1,0.014,zoneOrigin:part*zone);
      _midLayer(canvas,currentMid,1);
      if(next!=part && towardsNext>0){
        _backLayer(canvas,nextArt,towardsNext.toDouble(),0.014,zoneOrigin:next*zone);
        _midLayer(canvas,nextMid,towardsNext.toDouble());
      }
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
  }
  void _actor(Canvas canvas,Character c,String role,int index,bool active) {
    final costume=(stage==4 && role=='futbolista')||(stage==5 && role=='bailarina');
    // El ataque utiliza la pose auténtica de la hoja aprobada. Solo se activa
    // en protagonistas con atuendo temático; padre/hermana no se ven afectados.
    final isCostumeAttack=active && costume && time-lastAttackTime>=0 && time-lastAttackTime<.23;
    final pose=isCostumeAttack?'attack_0':!c.grounded?'jump_0':
      c.vx.abs()>15?'walk_${(c.travelled/23).floor()%2}':'idle_0';
    final img=images['${costume?'costume_':''}${role}_$pose'];if(img==null)return;
    final base=images['${costume?'costume_':''}${role}_idle_0'];
    final standardHeight=role=='padre'?134.0:role=='bailarina'?112.0:124.0;
    final scale=standardHeight/(base?.height ?? img.height);
    final w=img.width*scale,h=img.height*scale,x=c.x-cameraX;
    if(x< -120 || x>900)return;
    if(time<c.hurtUntil && (time*12).floor().isEven)return;
    canvas.drawOval(Rect.fromCenter(center:Offset(x,c.y+3),width:w*.7,height:8),Paint()..color=const Color(0x660b1c27));
    canvas.save();if(c.facing<0){canvas.translate(x,0);canvas.scale(-1,1);canvas.translate(-x,0);}
    _sprite(canvas,img,Rect.fromLTWH(x-w/2,c.y-h+5*scale,w,h),pixelated:false);
    canvas.restore();
    if(active)canvas.drawArc(Rect.fromCenter(center:Offset(x,c.y+4),width:38,height:11),0,math.pi,false,
      Paint()..color=const Color(0xffffdf73)..style=PaintingStyle.stroke..strokeWidth=2);
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
