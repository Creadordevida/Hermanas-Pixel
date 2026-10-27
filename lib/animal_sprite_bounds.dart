import 'dart:ui';

/// Measured alpha boundaries of the ORIGINAL 144 x 108 canine PNGs.
/// All three coats share geometry, so feet use an immutable world-floor pivot.
/// Never normalize every pose separately: that causes scale jumps.
const Map<String, Rect> dogVisibleBounds = {
  'idle': Rect.fromLTRB(41, 41, 97, 94),
  'walk': Rect.fromLTRB(29, 42, 113, 94),
  'alert': Rect.fromLTRB(28, 42, 115, 94),
  'run': Rect.fromLTRB(28, 40, 115, 94),
  'bite': Rect.fromLTRB(29, 40, 114, 94),
  'hit': Rect.fromLTRB(38, 39, 106, 94),
  'stunned': Rect.fromLTRB(38, 39, 106, 94),
  'defeated': Rect.fromLTRB(34, 40, 105, 95),
};

/// Authored atlas: four columns, two rows, 1774 x 887 source pixels.
/// The fractional cell sizes preserve the full sheet with no strip discarded.
const double pigeonAtlasCell = 443.5;
const int pigeonAtlasColumns = 4;
const int pigeonAtlasFrames = 8;
const double pigeonAtlasWorldCell = 108;
// Measured pink-foot pivots inside each atlas cell (in source pixels).
// Without these per-pose anchors the bird teleports when its wings change.
const List<double> pigeonFlightFootX = [209, 277, 270, 237, 239, 250, 276, 266];
const List<double> pigeonFlightFootY = [368, 363, 334, 369, 325, 328, 337, 301];

Rect pigeonFlightSource(int frame) {
  assert(frame >= 0 && frame < pigeonAtlasFrames);
  return Rect.fromLTWH(
    (frame % pigeonAtlasColumns) * pigeonAtlasCell,
    (frame ~/ pigeonAtlasColumns) * pigeonAtlasCell,
    pigeonAtlasCell,
    pigeonAtlasCell,
  );
}
