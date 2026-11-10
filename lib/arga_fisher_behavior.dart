import 'dart:math' as math;

/// Fishing-rod enemy logic for the QA-only river chapter. Art and projectile
/// rendering belong to the engine; this state machine only emits a cast event.
enum ArgaFisherPose { idle, walk, warning, cast, hurt, defeated }

class ArgaFisherMotion {
  ArgaFisherMotion(this.home) : x = home;

  final double home;
  double x;
  int facing = -1;
  ArgaFisherPose pose = ArgaFisherPose.idle;
  double elapsed = 0, cooldown = 0;
  bool castDelivered = false;

  static const double detection = 280;
  static const double warningSeconds = .75;
  static const double castMoment = .19;
  static const double castDuration = .54;
  static const double recovery = 2.7;

  void _set(ArgaFisherPose next) {
    if (pose == next) return;
    pose = next;
    elapsed = 0;
  }

  void hit() {
    if (pose == ArgaFisherPose.defeated) return;
    _set(ArgaFisherPose.hurt);
    elapsed = 0;
    castDelivered = true;
    cooldown = math.max(cooldown, 1.0);
  }

  void defeat() {
    _set(ArgaFisherPose.defeated);
    castDelivered = true;
  }

  /// Return true exactly when the hook/float is launched. The engine must
  /// then simulate the projectile, its arc and collision with either sister.
  bool update(double dt, double heroX, {required bool playerVisible}) {
    if (dt <= 0 || pose == ArgaFisherPose.defeated) return false;
    elapsed += dt;
    cooldown = math.max(0.0, cooldown - dt);
    if (pose == ArgaFisherPose.hurt) {
      if (elapsed >= .36) _set(ArgaFisherPose.idle);
      return false;
    }
    if (pose == ArgaFisherPose.warning) {
      if (!playerVisible) {
        _set(ArgaFisherPose.idle);
      } else if (elapsed >= warningSeconds) {
        _set(ArgaFisherPose.cast);
        castDelivered = false;
      }
      return false;
    }
    if (pose == ArgaFisherPose.cast) {
      if (!castDelivered && elapsed >= castMoment) {
        castDelivered = true;
        return true;
      }
      if (elapsed >= castDuration) {
        cooldown = recovery;
        _set(ArgaFisherPose.idle);
      }
      return false;
    }
    final distance = (heroX - x).abs();
    if (playerVisible && distance < detection && cooldown <= 0) {
      facing = heroX >= x ? 1 : -1;
      _set(ArgaFisherPose.warning);
    } else {
      _set(ArgaFisherPose.idle);
    }
    // Fisher remains on his assigned rock; never chases into river water.
    return false;
  }
}
