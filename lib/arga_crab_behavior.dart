import 'dart:math' as math;

/// Gameplay-only state machine for the Río Arga crab.
/// Not enabled in the seven shipped chapters and not linked to artwork yet.
enum ArgaCrabPose { idle, sideways, warning, pinch, hurt, defeated }
enum ArgaCrabImpact { none, pincers }

class ArgaCrabMotion {
  ArgaCrabMotion(this.home, {double? minX, double? maxX})
      : minX = minX ?? home - patrolLimit,
        maxX = maxX ?? home + patrolLimit,
        x = home;

  final double home;
  final double minX, maxX;
  double x;
  int facing = -1;
  ArgaCrabPose pose = ArgaCrabPose.idle;
  double elapsed = 0, cooldown = 0;
  bool impactDelivered = false;

  static const double approachRange = 215;
  static const double pinchReach = 66;
  static const double warningSeconds = .55;
  static const double pinchSeconds = .36;
  static const double attackMoment = .12;
  static const double recoverySeconds = 1.8;
  static const double patrolLimit = 100;

  void _transition(ArgaCrabPose next) {
    if (pose != next) {
      pose = next;
      elapsed = 0;
    }
  }

  void hit() {
    if (pose == ArgaCrabPose.defeated) return;
    _transition(ArgaCrabPose.hurt);
    elapsed = 0;
    impactDelivered = true;
    cooldown = math.max(cooldown, .9);
  }

  void defeat() {
    _transition(ArgaCrabPose.defeated);
    impactDelivered = true;
  }

  /// [onSameSupport] must be false if the player is above a gap or on a
  /// different river rock. This prevents a pincher hitting across water.
  /// [heroFeetY] is the existing character feet coordinate.
  ArgaCrabImpact update(double dt, double heroX, double heroFeetY,
      double supportTop, {required bool onSameSupport}) {
    if (dt <= 0 || pose == ArgaCrabPose.defeated) {
      return ArgaCrabImpact.none;
    }
    elapsed += dt;
    cooldown = math.max(0.0, cooldown - dt);
    final distance = (heroX - x).abs();

    if (pose == ArgaCrabPose.hurt) {
      if (elapsed >= .34) _transition(ArgaCrabPose.idle);
      return ArgaCrabImpact.none;
    }
    if (pose == ArgaCrabPose.warning) {
      if (elapsed >= warningSeconds) {
        _transition(ArgaCrabPose.pinch);
        impactDelivered = false;
      }
      return ArgaCrabImpact.none;
    }
    if (pose == ArgaCrabPose.pinch) {
      if (!impactDelivered && elapsed >= attackMoment) {
        impactDelivered = true;
        if (onSameSupport && distance < pinchReach &&
            (heroX - x) * facing >= -8 &&
            heroFeetY >= supportTop - 48) {
          return ArgaCrabImpact.pincers;
        }
      }
      if (elapsed >= pinchSeconds) {
        cooldown = recoverySeconds;
        _transition(ArgaCrabPose.idle);
      }
      return ArgaCrabImpact.none;
    }

    if (onSameSupport && distance < pinchReach && cooldown <= 0) {
      facing = heroX >= x ? 1 : -1;
      _transition(ArgaCrabPose.warning);
    } else if (onSameSupport && distance < approachRange &&
        distance >= pinchReach) {
      facing = heroX >= x ? 1 : -1;
      _transition(ArgaCrabPose.sideways);
      x += facing * 36 * dt;
      x = x.clamp(minX, maxX).toDouble();
    } else {
      _transition(ArgaCrabPose.idle);
    }
    return ArgaCrabImpact.none;
  }
}
