import 'package:flutter_test/flutter_test.dart';
import '../lib/new_enemy_behaviors.dart';

void main() {
  test('patrullan sin perseguir a jugador lejano y respetan límites', () {
    for (final kind in NewEnemyKind.values) {
      final e = NewEnemyMotion(kind: kind, home: 100, x: 100);
      for (int i=0;i<1000;i++) {
        expect(e.update(.1, 900), isFalse);
        expect(e.x, inInclusiveRange(-20, 220));
      }
    }
  });
  test('se ve anticipación antes del impacto y solo hay un golpe', () {
    for (final kind in NewEnemyKind.values) {
      final e = NewEnemyMotion(kind: kind, home: 100, x: 100);
      expect(e.update(.05, 125), isFalse);
      expect(e.pose, NewEnemyPose.attack);
      expect(e.update(e.attackDelay+.01, 125), isTrue);
      expect(e.update(.01, 125), isFalse);
      expect(e.cooldown, greaterThan(0));
    }
  });
  test('el jugador puede escapar durante anticipación', () {
    for (final kind in NewEnemyKind.values) {
      final e = NewEnemyMotion(kind: kind, home: 100, x: 100);
      e.update(.05, 125);
      expect(e.update(e.attackDelay+.01, 500), isFalse);
    }
  });
  test('golpe interrumpe ataque, derrotado nunca ataca', () {
    final e=NewEnemyMotion(kind: NewEnemyKind.cleaningRobot, home: 100, x: 100);
    e.update(.05, 125);
    e.hit();
    expect(e.update(1, 125), isFalse);
    e.defeat();
    final prior=e.x;
    expect(e.update(10, 110), isFalse);
    expect(e.x, prior);
    expect(e.pose, NewEnemyPose.defeated);
  });
}
