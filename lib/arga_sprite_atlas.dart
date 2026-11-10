/// Frame selector for Arga enemy atlases. Independent of Flutter.
/// Each row can use between one and four real drawings without duplicating
/// the last drawing to fill unused cells. The approved source art is untouched.
class ArgaSpriteAtlas {
  static const int columns = 4;
  static const int rows = 6;

  /// Rows 0-2 loop; attacks, reactions and defeat hold their last frame.
  /// [activeFrames] is the number of *verified drawings* in this pose row.
  /// The default retains the original four-column atlas behavior.
  static int frame({
    required int poseRow,
    required double elapsed,
    double framesPerSecond = 9,
    int activeFrames = columns,
  }) {
    if (poseRow < 0 || poseRow >= rows) {
      throw RangeError.range(poseRow, 0, rows - 1, 'poseRow');
    }
    if (activeFrames < 1 || activeFrames > columns) {
      throw RangeError.range(activeFrames, 1, columns, 'activeFrames');
    }
    if (!elapsed.isFinite || elapsed < 0 ||
        !framesPerSecond.isFinite || framesPerSecond <= 0) {
      throw ArgumentError('Animation time and rate must be finite and valid');
    }
    final elapsedFrames = (elapsed * framesPerSecond).floor();
    return poseRow <= 2
        ? elapsedFrames % activeFrames
        : (elapsedFrames < activeFrames ? elapsedFrames : activeFrames - 1);
  }
}
