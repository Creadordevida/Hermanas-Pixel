import 'dart:ui';

const dogAtlasAssets = <String, String>{
  'dog_brown': 'assets/images/dog/brown_atlas.png',
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
    return 20 + (defeatElapsed * 10).floor().clamp(0, 3);
  }
  if (stunRemaining > 0) {
    return 16 + ((.66 - stunRemaining) * 7).floor().clamp(0, 3);
  }
  return switch (mode) {
    'alert' => 3,
    'walk' => 4 + (elapsed * 6).floor() % 4,
    'run' => 8 + (elapsed * 10).floor() % 4,
    'bite' =>
      elapsed < dogBiteContactTime / 2
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
  final forwardEdge = lunging ? 53.0 : 33.0;
  return relativeX >= -33 &&
      relativeX <= forwardEdge &&
      height >= 4 &&
      height <= 63;
}
