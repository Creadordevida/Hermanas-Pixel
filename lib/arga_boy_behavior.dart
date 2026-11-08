import 'dart:math' as math;

/// QA-stage 7 only. Predictable, telegraphed stone throw; no sprite ownership.
enum ArgaBoyPose { idle, run, warning, throwStone, hurt, defeated }

class ArgaBoyMotion {
  ArgaBoyMotion(this.home) : x = home;

  final double home;
  double x;
  int facing = -1;
  ArgaBoyPose pose = ArgaBoyPose.idle;
  double elapsed = 0;
  double cooldown = 0;
  bool launched = false;

  static const double sight = 280;
  static const double warningTime = .7;
  static const double releaseTime = .2;
  static const double throwingTime = .5;
  static const double recovery = 2.4;

  void _enter(ArgaBoyPose next) {
    if (pose == next) return;
    pose = next;
    elapsed = 0;
  }

  void hit() {
    if (pose == ArgaBoyPose.defeated) return;
    _enter(ArgaBoyPose.hurt);
    elapsed = 0;
    launched = true;
    cooldown = math.max(cooldown, .8);
  }

  void defeat() {
    _enter(ArgaBoyPose.defeated);
    launched = true;
  }

  /// Returns true once per throw, after a visible warning.
  /// The host is responsible for checking the hero is on a valid surface.
  bool update(double dt, double heroX, {required bool playerVisible}) {
    if (dt <= 0 || pose == ArgaBoyPose.defeated) return false;
    elapsed += dt;
    cooldown = math.max(0.0, cooldown - dt);
    if (pose == ArgaBoyPose.hurt) {
      if (elapsed >= .34) _enter(ArgaBoyPose.idle);
      return false;
    }
    if (pose == ArgaBoyPose.warning) {
      if (!playerVisible) {
        _enter(ArgaBoyPose.idle);
      } else if (elapsed >= warningTime) {
        _enter(ArgaBoyPose.throwStone);
        launched = false;
      }
      return false;
    }
    if (pose == ArgaBoyPose.throwStone) {
      if (!launched && elapsed >= releaseTime) {
        launched = true;
        return true;
      }
      if (elapsed >= throwingTime) {
        cooldown = recovery;
        _enter(ArgaBoyPose.idle);
      }
      return false;
    }
    if (playerVisible && (heroX - x).abs() < sight && cooldown <= 0) {
      facing = heroX >= x ? 1 : -1;
      _enter(ArgaBoyPose.warning);
    } else {
      _enter(ArgaBoyPose.idle);
    }
    // Stationary on a broad safe rock: never run across a water gap.
    return false;
  }
}
