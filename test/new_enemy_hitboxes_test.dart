import 'package:flutter_test/flutter_test.dart';
import '../lib/new_enemy_hitboxes.dart';

void main() {
  test('All six approved concepts have a physical projectile profile', () {
    expect(newEnemyHitProfiles.length, 6);
    for (final item in newEnemyHitProfiles.entries) {
      final b=item.value;
      expect(b.halfWidth, greaterThan(0), reason:item.key);
      expect(b.halfHeight, greaterThan(0), reason:item.key);
      expect(b.centerAboveGround, greaterThan(0), reason:item.key);
      expect(b.projectileHits(
          foeX:400,groundY:390,shotX:400,shotY:390-b.centerAboveGround),
          isTrue,reason:item.key);
    }
  });
  test('Wide bull hitbox works at the visible shoulder', () {
    final bull=newEnemyHitProfiles['estafeta_bull']!;
    expect(bull.projectileHits(
        foeX:400,groundY:390,shotX:465,shotY:342),isTrue);
    expect(bull.projectileHits(
        foeX:400,groundY:390,shotX:490,shotY:342),isFalse);
    expect(bull.halfWidth,greaterThan(
        newEnemyHitProfiles['sanfermin_runner']!.halfWidth));
  });
  test('Ball and comb both hit the robot mid-body, not the sky', () {
    final robot=newEnemyHitProfiles['cleaning_robot']!;
    expect(robot.projectileHits(
      foeX:400,groundY:390,shotX:404,shotY:342),isTrue);
    expect(robot.projectileHits(
      foeX:400,groundY:390,shotX:404,shotY:180),isFalse);
  });
}
