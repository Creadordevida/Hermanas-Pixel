import 'dart:ui';

const dogAtlasAssets = <String, String>{
  'dog_brown': 'assets/images/dog/brown_atlas.png',
  'dog_dalmatian': 'assets/images/dog/dalmatian_atlas.png',
  'dog_doberman': 'assets/images/dog/doberman_atlas.png',
};

const double wildlifeCellWidth = 152;
const double wildlifeCellHeight = 108;
const double wildlifeAnchorX = 76;
const double wildlifeGroundAnchorY = 94;
const double dogBiteContactTime = .24;

Rect wildlifeFrameSource(int frame) => Rect.fromLTWH(
      (frame % 4) * wildlifeCellWidth,
      (frame ~/ 4) * wildlifeCellHeight,
      wildlifeCellWidth,
      wildlifeCellHeight,
    );

int dogAtlasFrame({
  required String kind,
  required String mode,
  required double elapsed,
  required double stunRemaining,
  required double? defeatElapsed,
}) {
  if (defeatElapsed != null) {
    // The last hit reads as a recoil before the fall, even on one-hit dogs.
    if (defeatElapsed < .12) return defeatElapsed < .06 ? 16 : 17;
    return 20 + ((defeatElapsed - .12) * 12.5).floor().clamp(0, 3);
  }
  if (stunRemaining > 0) {
    return 16 + ((.66 - stunRemaining) * 7).floor().clamp(0, 3);
  }
  final (walkFps, runFps) = switch (kind) {
    'dog_dalmatian' => (5, 8),
    'dog_doberman' => (7, 12),
    _ => (6, 10),
  };
  return switch (mode) {
    'alert' => 3,
    'walk' => 4 + (elapsed * walkFps).floor() % 4,
    'run' => 8 + (elapsed * runFps).floor() % 4,
    'bite' => elapsed < dogBiteContactTime / 2
        ? 12
        : elapsed < dogBiteContactTime
            ? 13
            : elapsed < .40
                ? 14
                : 15,
    _ => (elapsed * 2).floor() % 3,
  };
}

bool dogProjectileHits({
  required String kind,
  required double relativeX,
  required double height,
  required bool lunging,
}) {
  // The target is the body, excluding the thin end of the tail and gaps
  // between paws. Only the extended bite increases its forward reach.
  final (back, front, extended, bottom, top) = switch (kind) {
    'dog_dalmatian' => (-30, 34, 55, 16, 72),
    'dog_doberman' => (-37, 36, 57, 12, 75),
    _ => (-33, 33, 53, 4, 63),
  };
  return relativeX >= back &&
      relativeX <= (lunging ? extended : front) &&
      height >= bottom &&
      height <= top;
}
