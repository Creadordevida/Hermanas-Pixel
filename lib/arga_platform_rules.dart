import 'dart:math' as math;

/// Physical river-course contract, independent of art and Flutter widgets.
/// World Y is the hero's FEET coordinate (the existing game convention).
enum ArgaSurfaceKind { rock, log, timber, movingLog, sinkingRock }

class ArgaSurface {
  const ArgaSurface(this.x, this.width, this.top, this.kind,
      {this.checkpoint = false, this.phase = 0});
  final double x, width, top, phase;
  final ArgaSurfaceKind kind;
  final bool checkpoint;

  double leftAt(double seconds) => kind == ArgaSurfaceKind.movingLog
      ? x + 16 * math.sin(seconds * 1.1 + phase) : x;
  double topAt(double seconds, double occupiedForSeconds) {
    if (kind != ArgaSurfaceKind.sinkingRock) return top;
    return top + math.min(80, math.max(0, occupiedForSeconds - .6) * 62);
  }
  double rightAt(double seconds) => leftAt(seconds) + width;
}

class ArgaCourse {
  const ArgaCourse();
  static const double waterDeathY = 435;
  static const double startX = 110;
  static const double runSpeed = 169;
  static const double jumpVelocity = 423;
  static const double gravity = 960;

  /// With the existing game physics, an equal-height leap spans ~149px.
  static const double flatJumpRange =
      runSpeed * (2 * jumpVelocity / gravity);

  /// Authored first playable sequence. A fixed baseline is intentional:
  /// no unpredictable impossible gaps from a random generator.
  static const surfaces = <ArgaSurface>[
    ArgaSurface(0, 235, 365, ArgaSurfaceKind.rock, checkpoint:true),
    ArgaSurface(295, 155, 365, ArgaSurfaceKind.rock),
    ArgaSurface(525, 180, 368, ArgaSurfaceKind.log),
    ArgaSurface(770, 150, 355, ArgaSurfaceKind.timber),
    ArgaSurface(985, 160, 365, ArgaSurfaceKind.movingLog,phase:.9),
    ArgaSurface(1215, 180, 365, ArgaSurfaceKind.rock,checkpoint:true),
    ArgaSurface(1460, 145, 365, ArgaSurfaceKind.sinkingRock),
    ArgaSurface(1675, 180, 365, ArgaSurfaceKind.log),
    ArgaSurface(1920, 230, 365, ArgaSurfaceKind.rock,checkpoint:true),
  ];

  /// Deterministic river beyond the introductory authored nine surfaces.
  /// The movement pattern varies by section; no RNG and no impossible gaps.
  static final List<ArgaSurface> allSurfaces = List.unmodifiable([
    ...surfaces,
    ..._extendedSurfaces(),
  ]);

  static List<ArgaSurface> _extendedSurfaces() {
    final result=<ArgaSurface>[];
    const easyGaps=<double>[58,64,68,72,60,66,70,63];
    const mediumGaps=<double>[68,78,74,84,70,76,82,72];
    const hardGaps=<double>[77,86,82,93,78,85,90,80];
    const widths=<double>[185,155,220,165,190,170,210,180];
    const heights=<double>[365,360,368,355,362,370,358,365];
    const kinds=<ArgaSurfaceKind>[
      ArgaSurfaceKind.rock, ArgaSurfaceKind.log,
      ArgaSurfaceKind.timber, ArgaSurfaceKind.movingLog,
      ArgaSurfaceKind.rock, ArgaSurfaceKind.sinkingRock,
      ArgaSurfaceKind.log, ArgaSurfaceKind.rock,
    ];
    var right=surfaces.last.x+surfaces.last.width;
    var index=0;
    while(right<35900) {
      final segment=index~/8;
      final variant=(index+segment*3)%8;
      final tier=index<24 ? 0 : index<80 ? 1 : 2;
      final gapPattern=tier==0 ? easyGaps : tier==1 ? mediumGaps : hardGaps;
      final gap=gapPattern[(index+segment)%8];
      final checkpoint=index%8==7;
      // Every checkpoint is a stable broad rock, never moving or sinking.
      final width=widths[variant]+(checkpoint ? 80 : 0);
      final kind=checkpoint ? ArgaSurfaceKind.rock
          : (tier==2 && index%5==2) ? ArgaSurfaceKind.movingLog
          : (tier==2 && index%7==4) ? ArgaSurfaceKind.sinkingRock
          : kinds[variant];
      final x=right+gap;
      result.add(ArgaSurface(x,width,heights[variant],kind,
          checkpoint:checkpoint,phase:index*.43));
      right=x+width;
      index++;
    }
    // The final bank safely covers the actual 36,500-unit chapter exit,
    // so reaching the goal never requires a leap into open water.
    const finishGap=65.0;
    final finishLeft=right+finishGap;
    final finishWidth=math.max(520.0,36620.0-finishLeft);
    result.add(ArgaSurface(finishLeft,finishWidth,365,
        ArgaSurfaceKind.rock,checkpoint:true));
    return result;
  }

  bool overPlatform(double footX, double actorRadius, double seconds) =>
      allSurfaces.any((s) => footX + actorRadius > s.leftAt(seconds) &&
          footX - actorRadius < s.rightAt(seconds));

  /// Returns a support only when feet cross its top while descending.
  ArgaSurface? landing(double prevFootY, double footY,
      double footX, double radius, double seconds,
      {double sinkingElapsed = 0}) {
    for (final platform in allSurfaces) {
      final top = platform.topAt(seconds, sinkingElapsed);
      if (prevFootY <= top + 2 && footY >= top &&
          footX + radius > platform.leftAt(seconds) &&
          footX - radius < platform.rightAt(seconds)) {
        return platform;
      }
    }
    return null;
  }

  bool drowned(double footY) => footY > waterDeathY;

  double checkpointBefore(double x) {
    var result = startX;
    for (final s in allSurfaces) {
      if (s.checkpoint && s.x + 30 <= x) result = s.x + 55;
    }
    return result;
  }

  /// Static gaps must remain comfortably within the actual leap range.
  /// Moving logs have an additional 16px drift margin at either extreme.
  bool get allGapsReachable {
    for (var i = 1; i < allSurfaces.length; i++) {
      final a = allSurfaces[i - 1], b = allSurfaces[i];
      final extraDrift = (a.kind == ArgaSurfaceKind.movingLog ? 16 : 0) +
          (b.kind == ArgaSurfaceKind.movingLog ? 16 : 0);
      if (b.x - (a.x + a.width) + extraDrift > flatJumpRange - 20) {
        return false;
      }
      if ((b.top - a.top).abs() > 45) return false;
    }
    return true;
  }
}
