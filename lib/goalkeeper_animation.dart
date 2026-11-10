/// Frame-selection contract for the 4 x 6 goalkeeper atlas.
const goalkeeperAtlasCell = 256.0;
const goalkeeperAtlasFootY = 244.0;
const goalkeeperDefeatImpactTime = .18;

enum GoalkeeperPose { idle, shuffle, warning, dive, hurt, defeated }

class GoalkeeperFrame {
  const GoalkeeperFrame(this.pose, this.column);

  final GoalkeeperPose pose;
  final int column;

  int get row => pose.index;
  int get atlasIndex => row * 4 + column;
}

GoalkeeperFrame goalkeeperAtlasFrame({
  required double elapsed,
  required bool moving,
  required bool attacking,
  required bool stunned,
  required bool defeated,
  double defeatElapsed = 0,
}) {
  int boundedFrame(double seconds, double fps) =>
      (seconds.clamp(0.0, 100000.0) * fps).floor().clamp(0, 3).toInt();

  if (defeated) {
    // One projectile defeats this enemy. Play the impact row before the fall.
    if (defeatElapsed < goalkeeperDefeatImpactTime) {
      return GoalkeeperFrame(
          GoalkeeperPose.hurt, boundedFrame(defeatElapsed, 24));
    }
    return GoalkeeperFrame(GoalkeeperPose.defeated,
        boundedFrame(defeatElapsed - goalkeeperDefeatImpactTime, 7));
  }
  if (stunned) {
    return GoalkeeperFrame(GoalkeeperPose.hurt, boundedFrame(elapsed, 8));
  }
  if (attacking) {
    // Existing keeper attack: 0.00–0.27 anticipation, dive at 0.27,
    // active hit at 0.34–0.52, recovery until 0.75 seconds.
    if (elapsed < .27) {
      return GoalkeeperFrame(GoalkeeperPose.warning, boundedFrame(elapsed, 12));
    }
    // The keeper's original attack lasts about .75 s. Map the full dive
    // window to four distinct frames, including landing/recovery. The old
    // 9-fps clamp never reached column 3 before the attack ended.
    final diveElapsed = (elapsed - .27).clamp(0.0, .48).toDouble();
    final diveColumn = (diveElapsed / .48 * 4).floor().clamp(0, 3);
    return GoalkeeperFrame(GoalkeeperPose.dive, diveColumn);
  }
  if (moving) {
    return GoalkeeperFrame(GoalkeeperPose.shuffle, (elapsed * 8).floor() % 4);
  }
  return GoalkeeperFrame(GoalkeeperPose.idle, (elapsed * 3).floor() % 4);
}
