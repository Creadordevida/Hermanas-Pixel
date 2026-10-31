// Runs the real game ticker and projectile/damage logic, not a duplicated model.
// QA uses one cached school scene; enemy art is covered by StagePainter tests.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('All ten enemies: real attacks, ball/comb interruption and defeat',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(800,450));
    final key=GlobalKey();
    await tester.pumpWidget(MaterialApp(home:HermanasGame(key:key,qaStage:6)));
    final dynamic game=key.currentState;
    for(var i=0;i<400 && game.resourcesReady!=true;i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds:50)));
      await tester.pump(const Duration(milliseconds:16));
      expect(game.loadError,isNull);
    }
    expect(game.resourcesReady,isTrue);
    const kinds=['cleaning_robot','rival_supporter','tipsy_tourist',
      'navarre_king','estafeta_bull','sanfermin_runner',
      'bully','referee','rival','breakdancer'];

    Enemy reset(String kind,int selected) {
      game.obstacles.clear();game.platforms.clear();game.coins.clear();
      game.enemies.clear();game.shots.clear();
      game.screen=Screen.playing;
      game.selected=selected;
      game.hero=Character(425);
      game.hearts=5;
      game.leftHeld=false;game.rightHeld=false;
      game.exitTime=-1.0;
      final foe=Enemy(0,kind,400)..attackCooldown=0;
      game.enemies.add(foe);
      return foe;
    }
    Future<void> frames(int count) async {
      for(var i=0;i<count;i++) {
        await tester.pump(const Duration(milliseconds:16));
      }
    }
    try {
      for(final selected in [0,1]) {
        for(final kind in kinds) {
          // A close, grounded protagonist must first see a warning.
          reset(kind,selected);
          await frames(5);
          expect(game.hearts,5,reason:'Immediate damage: $kind/$selected');
          await frames(105);
          expect(game.hearts,lessThan(5),
            reason:'Real attack never reached protagonist: $kind/$selected');

          // Both real projectile types hit through the game's collision loop.
          final foe=reset(kind,selected);
          await frames(5);
          game.shots.add(Projectile(x:foe.x,y:groundY-48,vx:0,
            kind:selected==0?'ball':'comb'));
          await frames(1);
          expect(foe.hits,1,reason:'Missed projectile: $kind/$selected');
          expect(foe.stunned,greaterThan(0));
          expect(foe.launched,isFalse);
          expect(foe.meleeWarning,0);
          expect(foe.kingAttackAt,-1);
          expect(foe.runnerWarningAt,-1);
          expect(foe.bullWarnedAt,-1);
          await frames(18);
          expect(game.hearts,5,reason:'Interrupted attack still damaged: $kind');

          // Finish HP with a fresh shot and prove that a dead foe cannot attack.
          if(!foe.defeated) {
            foe.stunned=0;foe.hits=foe.hp-1;
            game.shots.add(Projectile(x:foe.x,y:groundY-48,vx:0,
              kind:selected==0?'ball':'comb'));
            await frames(1);
          }
          expect(foe.defeated,isTrue,reason:'Missing defeat: $kind/$selected');
          game.shots.clear();
          final lastX=foe.x;
          await frames(70);
          expect(foe.x,lastX,reason:'Defeated foe moved: $kind');
          expect(game.hearts,5,reason:'Defeated foe dealt damage: $kind');
          print('REAL_GAMEPLAY_PASS $kind protagonist=$selected');
        }
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  },timeout:const Timeout(Duration(minutes:5)));
}
