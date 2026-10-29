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

  test('golpe visible persiste y no dispara otro ataque en la recuperación', () {
    for (final kind in NewEnemyKind.values) {
      final e=NewEnemyMotion(kind:kind,home:100,x:100);
      e.update(.05,125);
      e.hit();
      expect(e.pose,NewEnemyPose.hit);
      expect(e.update(.10,125),isFalse);
      expect(e.pose,NewEnemyPose.hit);
      expect(e.update(.20,125),isFalse);
      expect(e.pose,NewEnemyPose.hit);
      expect(e.update(.05,125),isFalse);
      expect(e.cooldown,greaterThan(0));
      e.defeat();
      expect(e.pose,NewEnemyPose.defeated);
      expect(e.update(5,125),isFalse);
      expect(e.pose,NewEnemyPose.defeated);
    }
  });

  test('solo aparecen en los capítulos aprobados', () {
    for (final kind in NewEnemyKind.values) {
      for (int stage=0;stage<=6;stage++) {
        final expected=switch(kind) {
          NewEnemyKind.cleaningRobot => stage==6,
          NewEnemyKind.rivalSupporter => stage==4,
          NewEnemyKind.tipsyTourist => stage<=3,
        };
        expect(newEnemyAllowedInStage(kind, stage), expected);
      }
    }
  });
  test('planes de apariciones dejan márgenes y no se solapan', () {
    for(final kind in NewEnemyKind.values) {
      final stage=newEnemyAllowedStages[kind]!.first;
      final x=plannedNewEnemySpawns(kind,stage,36500);
      expect(x, isNotEmpty);
      expect(x.first,greaterThan(900));
      expect(x.last,lessThan(35600));
      for(int i=1;i<x.length;i++) expect(x[i]-x[i-1],greaterThan(1000));
      expect(plannedNewEnemySpawns(kind,5,36500),isEmpty);
    }
  });

}
