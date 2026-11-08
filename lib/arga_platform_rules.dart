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

  bool overPlatform(double footX, double actorRadius, double seconds) =>
      surfaces.any((s) => footX + actorRadius > s.leftAt(seconds) &&
          footX - actorRadius < s.rightAt(seconds));

  /// Returns a support only when feet cross its top while descending.
  ArgaSurface? landing(double prevFootY, double footY,
      double footX, double radius, double seconds,
      {double sinkingElapsed = 0}) {
    for (final platform in surfaces) {
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
    for (final s in surfaces) {
      if (s.checkpoint && s.x + 30 <= x) result = s.x + 55;
    }
    return result;
  }

  /// Static gaps must remain comfortably within the actual leap range.
  /// Moving logs have an additional 16px drift margin at either extreme.
  bool get allGapsReachable {
    for (var i = 1; i < surfaces.length; i++) {
      final a = surfaces[i - 1], b = surfaces[i];
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
