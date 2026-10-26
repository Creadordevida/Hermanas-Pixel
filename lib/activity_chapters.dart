import 'dart:ui';

/// Independently authored activity settings. World ranges match stageWidth.
/// A recognizable goal, theatre stage or reception is a UNIQUE landmark,
/// never mirrored or repeated as a 640px background tile.
class ActivityZone {
  const ActivityZone(this.asset, this.start, this.end);
  final String asset;
  final double start, end;
  double get length => end - start;
}

const List<ActivityZone> footballActivityZones = [
  ActivityZone('football_arrival', 0, 10500),
  ActivityZone('football_drills', 10500, 25500),
  ActivityZone('football_stands', 25500, 36500),
];

const List<ActivityZone> danceActivityZones = [
  ActivityZone('dance_foyer', 0, 10500),
  ActivityZone('dance_studio', 10500, 25500),
  ActivityZone('dance_stage', 25500, 36500),
];

List<ActivityZone> activityZones(int stage) =>
    stage == 4 ? footballActivityZones : danceActivityZones;

int activityZoneIndex(List<ActivityZone> zones, double worldX) {
  for (var i = 0; i < zones.length - 1; i++) {
    if (worldX < zones[i].end) return i;
  }
  return zones.length - 1;
}

/// Actual alpha-cropped bounding boxes of the new 1536 x 1024 RGBA atlases.
/// The dance atlas has a taller top-right potted plant than its nominal 512px
/// row: the measured bbox (ends at 515) preserves it without merging objects.
const List<Rect> footballActivityProps = [
  Rect.fromLTRB(81, 172, 446, 438), // traffic cones
  Rect.fromLTRB(567, 240, 974, 416), // low hurdle
  Rect.fromLTRB(1067, 161, 1493, 449), // sports bag
  Rect.fromLTRB(29, 654, 502, 918), // ball rack
  Rect.fromLTRB(584, 614, 974, 926), // water cooler
  Rect.fromLTRB(1058, 704, 1500, 922), // sideline bench
];

const List<Rect> danceActivityProps = [
  Rect.fromLTRB(92, 166, 474, 484), // pink practice bag
  Rect.fromLTRB(640, 176, 949, 494), // pointe shoes
  Rect.fromLTRB(1130, 87, 1439, 519), // green pot plant
  Rect.fromLTRB(83, 676, 492, 916), // rolled mats
  Rect.fromLTRB(619, 635, 949, 919), // piano stool
  Rect.fromLTRB(1108, 679, 1482, 949), // yoga blocks
];

const List<double> footballActivityPropHeights = [51, 43, 63, 69, 73, 45];
const List<double> danceActivityPropHeights = [56, 45, 77, 48, 55, 43];
