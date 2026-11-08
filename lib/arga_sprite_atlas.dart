/// Frame selector for Arga enemy atlases. Deliberately independent of Flutter
/// so each clip can be tested without loading or modifying approved artwork.
/// Atlas contract: four equally sized columns, six pose rows, feet aligned.
class ArgaSpriteAtlas {
  static const int columns = 4;
  static const int rows = 6;

  /// Normal motion loops; attacks, reactions and defeat hold their last frame.
  static int frame({
    required int poseRow,
    required double elapsed,
    double framesPerSecond = 9,
  }) {
    if (poseRow < 0 || poseRow >= rows) {
      throw RangeError.range(poseRow, 0, rows - 1, 'poseRow');
    }
    if (!elapsed.isFinite || elapsed < 0 ||
        !framesPerSecond.isFinite || framesPerSecond <= 0) {
      throw ArgumentError('Animation time and rate must be finite and valid');
    }
    final elapsedFrames = (elapsed * framesPerSecond).floor();
    // Rows 0-2: rest, locomotion, warning.
    // Rows 3-5: attack, impact, defeat.
    return poseRow <= 2
        ? elapsedFrames % columns
        : (elapsedFrames < columns ? elapsedFrames : columns - 1);
  }
}
