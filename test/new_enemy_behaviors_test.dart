import 'package:flutter_test/flutter_test.dart';
import '../lib/new_enemy_behaviors.dart';

void main() {
  test('los tres enemigos patrullan sin herir a distancia', () {
    for (final kind in NewEnemyKind.values) {
      final e = NewEnemyMotion(kind: kind, home: 100, x: 100);
      expect(e.update(0.1, 600), isFalse);
      expect(e.pose, NewEnemyPose.patrol);
    }
  });

  test('cada enemigo inicia ataque con cooldown propio', () {
    for (final kind in NewEnemyKind.values) {
      final e = NewEnemyMotion(kind: kind, home: 100, x: 100);
      expect(e.update(0.05, 125), isTrue);
      expect(e.pose, NewEnemyPose.attack);
      expect(e.update(0.05, 125), isFalse);
      expect(e.cooldown, greaterThan(0));
    }
  });

  test('derrotado deja de moverse y no vuelve a atacar', () {
    final e = NewEnemyMotion(kind: NewEnemyKind.cleaningRobot, home: 100, x: 100);
    e.defeat();
    expect(e.update(1, 110), isFalse);
    expect(e.x, 100);
    expect(e.pose, NewEnemyPose.defeated);
  });
}
