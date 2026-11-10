import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/arga_crab_behavior.dart';

void main() {
  test('crab warns visibly and pinches exactly once', () {
    final crab = ArgaCrabMotion(500);
    expect(crab.update(.016, 535, 365, 365, onSameSupport: true),
        ArgaCrabImpact.none);
    expect(crab.pose, ArgaCrabPose.warning);
    for (var i = 0; i < 20; i++) {
      expect(crab.update(.016, 535, 365, 365, onSameSupport: true),
          ArgaCrabImpact.none);
    }
    var impacts = 0;
    for (var i = 0; i < 85; i++) {
      if (crab.update(.016, 535, 365, 365, onSameSupport: true) ==
          ArgaCrabImpact.pincers) {
        impacts++;
      }
    }
    expect(impacts, 1);
  });

  test('no strike across a gap, behind the crab, or above pincers', () {
    for (final target in <(double, double, bool)>[
      (530, 365, false),
      (420, 365, true),
      (530, 285, true),
    ]) {
      final crab = ArgaCrabMotion(500);
      crab.update(.016, 530, 365, 365, onSameSupport: true);
      for (var i = 0; i < 100; i++) {
        expect(crab.update(.016, target.$1, target.$2, 365,
            onSameSupport: target.$3), ArgaCrabImpact.none);
      }
    }
  });

  test('damage interrupts telegraph, defeat permanently disables attack', () {
    final crab = ArgaCrabMotion(500);
    crab.update(.016, 530, 365, 365, onSameSupport: true);
    expect(crab.pose, ArgaCrabPose.warning);
    crab.hit();
    for (var i = 0; i < 40; i++) {
      expect(crab.update(.016, 530, 365, 365, onSameSupport: true),
          ArgaCrabImpact.none);
    }
    crab.defeat();
    final x = crab.x;
    for (var i = 0; i < 150; i++) {
      expect(crab.update(.016, 530, 365, 365, onSameSupport: true),
          ArgaCrabImpact.none);
    }
    expect(crab.pose, ArgaCrabPose.defeated);
    expect(crab.x, x);
  });

  test('rock-edge bounds stop crab from walking into the river', () {
    final crab = ArgaCrabMotion(375, minX: 320, maxX: 420);
    for (var i = 0; i < 900; i++) {
      crab.update(.016, 590, 365, 365, onSameSupport: true);
    }
    expect(crab.x, inInclusiveRange(320, 420));
  });

  test('walk is limited to home rock patrol radius', () {
    final crab = ArgaCrabMotion(500);
    for (var i = 0; i < 1000; i++) {
      crab.update(.016, 690, 365, 365, onSameSupport: true);
    }
    expect(crab.x, inInclusiveRange(400, 600));
  });
}
