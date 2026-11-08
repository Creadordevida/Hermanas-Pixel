import 'dart:math' as math;

/// QA-only simulation of the fisher's hook/float. The approved rod art stays
/// untouched; StagePainter will render this projectile independently later.
class ArgaHookProjectile {
  ArgaHookProjectile({
    required double originX,
    required double originY,
    required int facing,
    required double targetX,
  })  : x = originX,
        y = originY,
        vx = (targetX - originX).clamp(-195.0, 195.0).toDouble(),
        vy = -185.0,
        facing = facing < 0 ? -1 : 1;

  static const double gravity = 420;
  static const double maxAge = 1.4;
  static const double radius = 8;

  final int facing;
  double x, y, vx, vy;
  double age = 0;
  bool active = true;
  bool deliveredHit = false;

  /// Fixed-size steps stabilize the arc during a slow frame. Collision is
  /// sampled at the returned position; swept collision remains for QA.
  void update(double dt, {required double waterY}) {
    if (!active || dt <= 0) return;
    var left = math.min(dt, maxAge - age);
    while (left > 0 && active) {
      final step = math.min(left, 1 / 120);
      x += vx * step;
      y += vy * step + .5 * gravity * step * step;
      vy += gravity * step;
      age += step;
      left -= step;
      if (y >= waterY || age >= maxAge - 1e-9) active = false;
    }
  }

  /// Actor rectangle uses center X and a top/bottom interval in world units.
  /// An invulnerable actor should be ignored by the host before applying harm.
  bool overlaps({
    required double centerX,
    required double halfWidth,
    required double top,
    required double bottom,
  }) {
    if (!active || deliveredHit || halfWidth < 0 || bottom < top) return false;
    final closestX = x.clamp(centerX - halfWidth, centerX + halfWidth);
    final closestY = y.clamp(top, bottom);
    final dx = x - closestX;
    final dy = y - closestY;
    if (dx * dx + dy * dy > radius * radius) return false;
    deliveredHit = true;
    active = false;
    return true;
  }

  void cancel() => active = false;
}
