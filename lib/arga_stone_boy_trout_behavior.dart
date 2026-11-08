import 'dart:math' as math;

/// Pure Dart controllers for river threats. Their approved art and collision
/// rendering will be wired only to the QA Río Arga stage.
enum ArgaStoneBoyPose { idle, run, warning, throwStone, hit, defeated }

class ArgaStoneBoyMotion {
  ArgaStoneBoyMotion(this.home, {double? minX, double? maxX})
      : minX = minX ?? home - 80,
        maxX = maxX ?? home + 80,
        x = home;

  final double home, minX, maxX;
  double x;
  int facing = -1;
  ArgaStoneBoyPose pose = ArgaStoneBoyPose.idle;
  double elapsed = 0, cooldown = 0;
  bool launched = false;

  void _set(ArgaStoneBoyPose next) {
    if (pose == next) return;
    pose = next;
    elapsed = 0;
  }

  void hit() {
    if (pose == ArgaStoneBoyPose.defeated) return;
    _set(ArgaStoneBoyPose.hit);
    launched = true;
    cooldown = math.max(cooldown, .9);
  }

  void defeat() {
    _set(ArgaStoneBoyPose.defeated);
    launched = true;
  }

  /// Returns true once when a rounded river pebble should be launched.
  /// The engine must simulate a visible arc and collisions independently.
  bool update(double dt, double heroX, {required bool playerVisible}) {
    if (dt <= 0 || pose == ArgaStoneBoyPose.defeated) return false;
    elapsed += dt;
    cooldown = math.max(0.0, cooldown - dt);
    if (pose == ArgaStoneBoyPose.hit) {
      if (elapsed >= .34) _set(ArgaStoneBoyPose.idle);
      return false;
    }
    if (pose == ArgaStoneBoyPose.warning) {
      if (!playerVisible) {
        _set(ArgaStoneBoyPose.idle);
      } else if (elapsed >= .48) {
        _set(ArgaStoneBoyPose.throwStone);
        launched = false;
      }
      return false;
    }
    if (pose == ArgaStoneBoyPose.throwStone) {
      if (!launched && elapsed >= .12) {
        launched = true;
        return true;
      }
      if (elapsed >= .35) {
        cooldown = 2.3;
        _set(ArgaStoneBoyPose.idle);
      }
      return false;
    }

    final dx = heroX - x;
    final distance = dx.abs();
    if (playerVisible && distance <= 255 && cooldown <= 0) {
      facing = dx >= 0 ? 1 : -1;
      _set(ArgaStoneBoyPose.warning);
    } else if (playerVisible && distance < 350 && distance > 260) {
      facing = dx >= 0 ? 1 : -1;
      _set(ArgaStoneBoyPose.run);
      x = (x + facing * 41 * dt).clamp(minX, maxX).toDouble();
    } else {
      _set(ArgaStoneBoyPose.idle);
    }
    return false;
  }
}

/// A trout can attack from a river gap, but returns to water afterwards.
enum ArgaTroutPose { swim, accelerate, alert, leap, hit, defeated }

class ArgaTroutMotion {
  ArgaTroutMotion(this.waterX, this.waterY);
  final double waterX, waterY;
  double x = 0, y = 0, vx = 0, vy = 0, elapsed = 0, cooldown = 0;
  ArgaTroutPose pose = ArgaTroutPose.swim;
  bool contactDelivered = false;

  void _set(ArgaTroutPose next) {
    if (pose == next) return;
    pose = next;
    elapsed = 0;
  }

  void hit() {
    if (pose == ArgaTroutPose.defeated) return;
    _set(ArgaTroutPose.hit);
    contactDelivered = true;
    cooldown = math.max(cooldown, 1.4);
  }

  void defeat() {
    _set(ArgaTroutPose.defeated);
    contactDelivered = true;
  }

  /// Returns true exactly once when the midair trout makes contact.
  /// The host checks actor invulnerability and applies a single heart loss.
  bool update(double dt, double heroX, double heroFeetY) {
    if (dt <= 0 || pose == ArgaTroutPose.defeated) return false;
    elapsed += dt;
    cooldown = math.max(0.0, cooldown - dt);
    if (pose == ArgaTroutPose.hit) {
      if (elapsed >= .45) _set(ArgaTroutPose.swim);
      return false;
    }
    if (pose == ArgaTroutPose.alert) {
      if (elapsed >= .45) {
        _set(ArgaTroutPose.leap);
        x = waterX;
        y = waterY;
        vy = -300;
        vx = heroX >= waterX ? 94 : -94;
        contactDelivered = false;
      }
      return false;
    }
    if (pose == ArgaTroutPose.leap) {
      vy += 660 * dt;
      x += vx * dt;
      y += vy * dt;
      if (!contactDelivered &&
          (heroX - x).abs() < 33 &&
          (heroFeetY - 37 - y).abs() < 36) {
        contactDelivered = true;
        return true;
      }
      if (y > waterY && vy > 0) {
        _set(ArgaTroutPose.swim);
        cooldown = 2.8;
      }
      return false;
    }
    x = waterX;
    y = waterY;
    if ((heroX - waterX).abs() <= 180 && cooldown <= 0) {
      _set(ArgaTroutPose.alert);
    } else {
      _set(ArgaTroutPose.swim);
    }
    return false;
  }
}
