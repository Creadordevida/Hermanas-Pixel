import 'dart:ui';

/// The classic training-ground rival (NOT the rival coach/supporter).
/// Art is a 4-column x 6-row RGBA atlas. Coordinates were measured on the
/// authored pixels, not inferred from transparent rectangular cell padding.
const rivalPlayerAtlasColumns = 4;
const rivalPlayerAtlasRows = 6;
const rivalPlayerAtlasCell = 256.0;
const rivalPlayerWorldHeight = 124.0;

const List<Rect> rivalPlayerSilhouettes = [
  Rect.fromLTWH(79,39,105,214), Rect.fromLTWH(79,36,106,217),
  Rect.fromLTWH(79,42,105,211), Rect.fromLTWH(78,47,106,206),
  Rect.fromLTWH(59,49,139,203), Rect.fromLTWH(54,45,147,199),
  Rect.fromLTWH(50,47,153,195), Rect.fromLTWH(63,58,137,195),
  Rect.fromLTWH(69,36,115,214), Rect.fromLTWH(55,50,138,200),
  Rect.fromLTWH(33,65,159,185), Rect.fromLTWH(33,89,171,161),
  Rect.fromLTWH(59,30,125,212), Rect.fromLTWH(41,38,159,204),
  Rect.fromLTWH(27,45,189,197), Rect.fromLTWH(20,53,213,187),
  Rect.fromLTWH(58,32,139,214), Rect.fromLTWH(59,38,145,208),
  Rect.fromLTWH(36,47,180,199), Rect.fromLTWH(29,48,191,198),
  Rect.fromLTWH(54,59,159,176), Rect.fromLTWH(34,80,179,155),
  Rect.fromLTWH(18,90,189,145), Rect.fromLTWH(7,138,223,94),
];

Rect rivalPlayerAtlasSource(int frame) {
  assert(frame >= 0 && frame < 24);
  final bounds = rivalPlayerSilhouettes[frame];
  return bounds.shift(Offset(
    (frame % rivalPlayerAtlasColumns) * rivalPlayerAtlasCell,
    (frame ~/ rivalPlayerAtlasColumns) * rivalPlayerAtlasCell,
  ));
}

int rivalPlayerAtlasFrame({
  required double elapsed,
  required bool moving,
  required bool attacking,
  required bool stunned,
  required bool defeated,
  required double attackCooldown,
  required double heroDistance,
}) {
  if (defeated) return 23;
  if (stunned) return 16 + ((elapsed * 9).floor() % 4);
  if (attacking) return 12 + ((elapsed * 12).floor() % 4);
  if (moving) return 4 + ((elapsed * 9).floor() % 4);
  if (heroDistance < 95 && attackCooldown < .5) {
    return 8 + ((elapsed * 4).floor() % 4);
  }
  return (elapsed * 2).floor() % 4;
}
