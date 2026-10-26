import 'dart:math' as math;
import 'dart:ui';

/// The heroine's drawn movement follows the actual physics, not a loop timer.
/// Takeoff/impact are time-limited; falling is never drawn as rising.
enum JumpVisualPhase { grounded, takeoff, rising, apex, falling, impact, recovery }

JumpVisualPhase jumpVisualPhase({
  required bool grounded,
  required double vy,
  required double time,
  required double jumpedAt,
  required double landedAt,
}) {
  if (!grounded) {
    if (time - jumpedAt >= 0 && time - jumpedAt < .085 && vy < 0) {
      return JumpVisualPhase.takeoff;
    }
    if (vy < -80) return JumpVisualPhase.rising;
    if (vy <= 85) return JumpVisualPhase.apex;
    return JumpVisualPhase.falling;
  }
  final sinceLanding = time - landedAt;
  if (sinceLanding >= 0 && sinceLanding < .10) return JumpVisualPhase.impact;
  if (sinceLanding >= .10 && sinceLanding < .24) return JumpVisualPhase.recovery;
  return JumpVisualPhase.grounded;
}

/// The nearest horizontal surface BELOW the feet receives the shadow.
/// A jump's vertical displacement must never be added to shadow Y.
double shadowSurfaceY({
  required double footX,
  required double footY,
  required double floorY,
  required Iterable<Rect> surfaces,
}) {
  var result = floorY;
  for (final surface in surfaces) {
    if (footX < surface.left + 3 || footX > surface.right - 3) continue;
    if (surface.top < footY - 1 || surface.top >= result) continue;
    result = surface.top;
  }
  return result;
}

/// Altitude attenuates shadow size and opacity, without moving its contact Y.
double jumpShadowScale(double height) =>
  (1.0 - math.max(0.0, height) / 300 * .42).clamp(.55, 1.0).toDouble();

int jumpShadowAlpha(double height) =>
  (105 - math.max(0.0, height) * .37).round().clamp(29, 105).toInt();
