/// Mecánicas puras de los tres adversarios aprobados por el usuario.
/// Separadas de Flutter para poder probar IA y ventanas de impacto antes de
/// conectar hitboxes, sprites y daño. No usar dibujos provisionales en juego.
import 'dart:math' as math;

enum NewEnemyKind { cleaningRobot, rivalSupporter, tipsyTourist }
enum NewEnemyPose { idle, patrol, alert, attack, hit, defeated }

class NewEnemyMotion {
  NewEnemyMotion({required this.kind, required this.home, required this.x});
  final NewEnemyKind kind;
  final double home;
  double x;
  int direction = 1;
  double elapsed = 0;
  double cooldown = 0;
  double windup = 0;
  NewEnemyPose pose = NewEnemyPose.idle;
  bool defeated = false;
  bool _impactDelivered = false;

  double get awareness => switch (kind) {
    NewEnemyKind.cleaningRobot => 140,
    NewEnemyKind.rivalSupporter => 180,
    NewEnemyKind.tipsyTourist => 115,
  };
  double get patrolSpeed => switch(kind) {
    NewEnemyKind.cleaningRobot => 55,
    NewEnemyKind.rivalSupporter => 70,
    NewEnemyKind.tipsyTourist => 36,
  };
  double get attackDelay => switch(kind) {
    NewEnemyKind.cleaningRobot => .46,
    NewEnemyKind.rivalSupporter => .35,
    NewEnemyKind.tipsyTourist => .68,
  };
  double get recovery => switch(kind) {
    NewEnemyKind.cleaningRobot => 2.5,
    NewEnemyKind.rivalSupporter => 2.0,
    NewEnemyKind.tipsyTourist => 3.2,
  };

  /// Devuelve true EXACTAMENTE una vez al concluir la anticipación visible
  /// de un ataque y SOLO si el protagonista sigue en alcance.
  /// El daño real se aplicará en el motor del juego, con sus propias hitboxes.
  bool update(double dt, double heroX) {
    if (dt <= 0 || defeated) return false;
    elapsed += dt;
    cooldown = math.max(0.0, cooldown-dt);
    final distance = heroX-x;
    final near = distance.abs();
    if (windup > 0) {
      windup = math.max(0.0, windup-dt);
      pose = NewEnemyPose.attack;
      if (windup == 0 && !_impactDelivered) {
        _impactDelivered = true;
        return near <= 52;
      }
      return false;
    }
    if (near < awareness) {
      direction = distance >= 0 ? 1 : -1;
      pose = NewEnemyPose.alert;
      if (near < 52 && cooldown <= 0) {
        windup = attackDelay;
        cooldown = recovery;
        _impactDelivered = false;
        pose = NewEnemyPose.attack;
      } else if (near > 60) {
        x += direction*patrolSpeed*dt*.65;
      }
    } else {
      pose = NewEnemyPose.patrol;
      // Sin perseguir a personas que quedan fuera de rango; patrulla cerrada.
      if ((x-home).abs() >= 120) direction = x >= home ? -1 : 1;
      final wobble = kind == NewEnemyKind.tipsyTourist
          ? math.sin(elapsed*3.1)*9.0 : 0.0;
      x += (direction*patrolSpeed*.45+wobble)*dt;
      x=x.clamp(home-120,home+120).toDouble();
    }
    return false;
  }

  void hit() {
    if (defeated) return;
    windup=0;
    _impactDelivered=true;
    pose=NewEnemyPose.hit;
  }

  void defeat() {
    defeated=true;
    windup=0;
    pose=NewEnemyPose.defeated;
  }
}
