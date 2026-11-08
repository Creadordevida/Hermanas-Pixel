import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/arga_boy_behavior.dart';

void main() {
  test('Stone throw is telegraphed and emitted exactly once', () {
    final boy = ArgaBoyMotion(1500);
    expect(boy.update(.1, 1430, playerVisible: true), isFalse);
    expect(boy.pose, ArgaBoyPose.warning);
    expect(boy.update(.71, 1430, playerVisible: true), isFalse);
    expect(boy.pose, ArgaBoyPose.throwStone);
    expect(boy.update(.21, 1430, playerVisible: true), isTrue);
    expect(boy.update(.05, 1430, playerVisible: true), isFalse);
  });

  test('Disappearing hero cancels warning without a stone', () {
    final boy = ArgaBoyMotion(1500);
    boy.update(.1, 1420, playerVisible: true);
    expect(boy.update(.2, 1420, playerVisible: false), isFalse);
    expect(boy.pose, ArgaBoyPose.idle);
  });

  test('Player shots interrupt the throw and defeat holds', () {
    final boy = ArgaBoyMotion(1500);
    boy.update(.1, 1510, playerVisible: true);
    boy.hit();
    expect(boy.pose, ArgaBoyPose.hurt);
    expect(boy.update(.2, 1510, playerVisible: true), isFalse);
    boy.defeat();
    expect(boy.pose, ArgaBoyPose.defeated);
    expect(boy.update(5, 1510, playerVisible: true), isFalse);
  });

  test('No throws from invisible or distant player', () {
    final boy = ArgaBoyMotion(1500);
    for(var i=0; i<30; i++) {
      expect(boy.update(.2, 1800, playerVisible: true), isFalse);
    }
    expect(boy.pose, ArgaBoyPose.idle);
  });
}
