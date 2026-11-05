import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('RC7 tactics board coach: real-game attack, escape, interruption and defeat',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(800,450));
    final key=GlobalKey();
    await tester.pumpWidget(MaterialApp(home:HermanasGame(key:key,qaStage:4)));
    final dynamic game=key.currentState;
    for(var i=0;i<400 && game.resourcesReady!=true;i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds:50)));
      await tester.pump(const Duration(milliseconds:16));
      expect(game.loadError,isNull);
    }
    expect(game.resourcesReady,isTrue);
    Future<void> frames(int count) async {
      for(var i=0;i<count;i++) await tester.pump(const Duration(milliseconds:16));
    }
    Enemy reset(int selected) {
      game.obstacles.clear();game.platforms.clear();game.coins.clear();
      game.enemies.clear();game.shots.clear();
      game.screen=Screen.playing;
      game.selected=selected;
      game.hero=Character(425);
      game.hearts=5;
      game.leftHeld=false;game.rightHeld=false;
      game.exitTime=-1.0;
      final foe=Enemy(0,'rival_coach',400)..attackCooldown=0;
      game.enemies.add(foe);
      return foe;
    }
    try {
      for(final selected in [0,1]) {
        reset(selected);
        await frames(5);
        expect(game.hearts,5,reason:'Coach warning missing');
        await frames(105);
        expect(game.hearts,lessThan(5),reason:'Coach did not strike');

        reset(selected);
        await frames(5);
        game.hero.x=2000.0;
        await frames(105);
        expect(game.hearts,5,reason:'Escaped coach hit');

        final foe=reset(selected);
        await frames(5);
        game.shots.add(Projectile(x:foe.x,y:groundY-48,vx:0,
          kind:selected==0?'ball':'comb'));
        await frames(1);
        expect(foe.hits,1,reason:'Coach projectile hit missed');
        expect(foe.stunned,greaterThan(0));
        await frames(18);
        expect(game.hearts,5,reason:'Coach struck while stunned');
        foe.stunned=0;foe.hits=foe.hp-1;
        game.shots.add(Projectile(x:foe.x,y:groundY-48,vx:0,
          kind:selected==0?'ball':'comb'));
        await frames(1);
        expect(foe.defeated,isTrue);
        final lastX=foe.x;
        await frames(70);
        expect(foe.x,lastX);
        expect(game.hearts,5);
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  },timeout:const Timeout(Duration(minutes:5)));
}
