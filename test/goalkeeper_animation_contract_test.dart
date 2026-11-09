import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/goalkeeper_animation.dart';

void main() {
  GoalkeeperFrame frame(double t, {bool moving = false, bool attacking = false,
    bool stunned = false, bool defeated = false, double death = 0}) =>
      goalkeeperAtlasFrame(elapsed: t, moving: moving, attacking: attacking,
          stunned: stunned, defeated: defeated, defeatElapsed: death);

  test('each state selects the correct atlas row', () {
    expect(frame(0).row, 0);
    expect(frame(.5, moving: true).row, 1);
    expect(frame(.1, attacking: true).row, 2);
    expect(frame(.38, attacking: true).row, 3);
    expect(frame(.1, stunned: true).row, 4);
    expect(frame(.1, defeated: true).row, 5);
  });

  test('anticipation precedes real keeper contact', () {
    expect(frame(.20, attacking: true).pose, GoalkeeperPose.warning);
    expect(frame(.27, attacking: true).pose, GoalkeeperPose.dive);
    expect(frame(.35, attacking: true).pose, GoalkeeperPose.dive);
    expect(frame(.51, attacking: true).pose, GoalkeeperPose.dive);
  });

  test('all four defeat frames remain reachable', () {
    expect([0.0, .16, .30, .48].map((d) =>
        frame(0, defeated: true, death: d).column).toList(), [0, 1, 2, 3]);
  });

  test('atlas lookups are always within 24 cells', () {
    for (final t in [0.0, .1, .3, .7, 1.5, 10.0]) {
      for (final state in [
        frame(t), frame(t, moving: true), frame(t, attacking: true),
        frame(t, stunned: true), frame(t, defeated: true, death: t),
      ]) {
        expect(state.column, inInclusiveRange(0, 3));
        expect(state.atlasIndex, inInclusiveRange(0, 23));
      }
    }
  });
}
