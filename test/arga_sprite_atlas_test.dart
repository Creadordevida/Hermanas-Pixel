import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/arga_sprite_atlas.dart';

void main() {
  test('idle, movement and warning rows loop four distinct frames', () {
    for (var row = 0; row <= 2; row++) {
      expect([for (var i = 0; i < 8; i++)
        ArgaSpriteAtlas.frame(poseRow: row, elapsed: i / 9)],
        [0, 1, 2, 3, 0, 1, 2, 3]);
    }
  });

  test('attack, hit and defeat hold the fourth drawing', () {
    for (var row = 3; row < 6; row++) {
      expect([for (var i = 0; i < 7; i++)
        ArgaSpriteAtlas.frame(poseRow: row, elapsed: i / 9)],
        [0, 1, 2, 3, 3, 3, 3]);
    }
  });

  test('new pose restarts its animation from the first frame', () {
    expect(ArgaSpriteAtlas.frame(poseRow: 3, elapsed: 0), 0);
    expect(ArgaSpriteAtlas.frame(poseRow: 0, elapsed: 0), 0);
  });

  test('invalid row and time are rejected', () {
    expect(() => ArgaSpriteAtlas.frame(poseRow: 6, elapsed: 0),
        throwsRangeError);
    expect(() => ArgaSpriteAtlas.frame(poseRow: 0, elapsed: -1),
        throwsArgumentError);
  });
}
