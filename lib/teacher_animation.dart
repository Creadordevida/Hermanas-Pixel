const teacherAtlasCell = 256.0;
const teacherAtlasFootY = 236.0;
const teacherThrowTime = .75;
const teacherAttackCooldown = 3.6;
const teacherFollowThroughTime = .32;
const teacherRecoveryTime = .32;

// Position of the fingers in the release cel, relative to the foot anchor.
const teacherReleaseX = 59.0;
const teacherReleaseHeight = 93.0;
const teacherReleaseVerticalSpeed = 35.0;

enum TeacherPose { idle, warning, release, recovery, hit, defeat }

({int row, int column}) teacherAtlasFrame({
  required double elapsed,
  required bool preparing,
  required double cooldown,
  required bool stunned,
  double? defeatElapsed,
}) {
  (TeacherPose, int) frame;
  int column(double seconds, double fps) => (seconds * fps).floor().clamp(0, 3);
  if (defeatElapsed != null) {
    frame = (TeacherPose.defeat, column(defeatElapsed, 6));
  } else if (stunned) {
    frame = (TeacherPose.hit, column(elapsed, 7));
  } else if (preparing) {
    frame = (TeacherPose.warning, column(elapsed, 4 / teacherThrowTime));
  } else if (cooldown > teacherAttackCooldown - teacherFollowThroughTime) {
    frame =
        (TeacherPose.release, column(elapsed, 4 / teacherFollowThroughTime));
  } else if (cooldown >
      teacherAttackCooldown - teacherFollowThroughTime - teacherRecoveryTime) {
    frame = (
      TeacherPose.recovery,
      column(elapsed - teacherFollowThroughTime, 4 / teacherRecoveryTime),
    );
  } else {
    frame = (TeacherPose.idle, (elapsed * 3).floor() % 4);
  }
  return (row: frame.$1.index, column: frame.$2);
}
