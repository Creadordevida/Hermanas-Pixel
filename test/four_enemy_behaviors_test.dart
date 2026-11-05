import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/four_enemy_behaviors.dart';

void main() {
  for(final kind in fourEnemyStages.keys) {
    test('$kind distribution, telegraph, one impact, interrupt, defeat', () {
      for(var stage=0;stage<7;stage++) {
        expect(fourEnemySpawns(kind,stage,36500).length,
          stage==fourEnemyStages[kind]?3:0);
      }
      final m=FourEnemyMotion(kind,400);
      var impacts=0;
      for(var i=0;i<5;i++) {
        expect(m.update(.016,425,390,390),FourEnemyImpact.none);
      }
      expect(m.pose,FourEnemyPose.warning);
      for(var i=0;i<100;i++) {
        if(m.update(.016,425,390,390)!=FourEnemyImpact.none)impacts++;
      }
      expect(impacts,1);
      final interrupted=FourEnemyMotion(kind,400);
      interrupted.update(.016,425,390,390);interrupted.hit();
      for(var i=0;i<40;i++) {
        expect(interrupted.update(.016,425,390,390),FourEnemyImpact.none);
      }
      interrupted.defeat();final x=interrupted.x;
      for(var i=0;i<200;i++) {
        expect(interrupted.update(.016,425,390,390),FourEnemyImpact.none);
      }
      expect(interrupted.x,x);
    });
    if(kind!='slipper_neighbor') {
      test('$kind jump and move behind cancel damage', () {
        for(final target in [(425.0,300.0),(300.0,390.0)]) {
          final m=FourEnemyMotion(kind,400);
          m.update(.016,425,390,390);
          for(var i=0;i<100;i++) {
            expect(m.update(.016,target.$1,target.$2,390),FourEnemyImpact.none);
          }
        }
      });
    }
  }
}
