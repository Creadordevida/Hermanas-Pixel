/// Contratos de comportamiento de enemigos nuevos TWC (revisión visual).
/// No se activan hasta contar con sprites aprobados y pruebas de colisiones.
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
  NewEnemyPose pose = NewEnemyPose.idle;
  bool defeated = false;

  /// Lógica determinista, independiente de Flutter y de las imágenes.
  /// Devuelve true para iniciar una ventana de ataque; NO aplica daño.
  bool update(double dt, double heroX) {
    if (dt <= 0 || defeated) return false;
    elapsed += dt;
    cooldown = math.max(0, cooldown - dt);
    final distance = heroX - x;
    final near = distance.abs();
    final range = switch (kind) {
      NewEnemyKind.cleaningRobot => 140.0,
      NewEnemyKind.rivalSupporter => 180.0,
      NewEnemyKind.tipsyTourist => 115.0,
    };
    if (near < range) {
      direction = distance >= 0 ? 1 : -1;
      pose = NewEnemyPose.alert;
      if (near < 52 && cooldown == 0) {
        pose = NewEnemyPose.attack;
        cooldown = switch(kind) {
          NewEnemyKind.cleaningRobot => 2.5,
          NewEnemyKind.rivalSupporter => 2.0,
          NewEnemyKind.tipsyTourist => 3.2,
        };
        return true;
      }
    } else {
      pose = NewEnemyPose.patrol;
    }
    final patrolSpeed = switch(kind) {
      NewEnemyKind.cleaningRobot => 55.0,
      NewEnemyKind.rivalSupporter => 70.0,
      NewEnemyKind.tipsyTourist => 36.0,
    };
    final wobble = kind == NewEnemyKind.tipsyTourist
        ? math.sin(elapsed * 3.1) * 9.0 : 0.0;
    if (near > 52) x += (direction * patrolSpeed + wobble) * dt;
    if ((x-home).abs() > 120 && near >= range) {
      direction = -direction;
      x = x.clamp(home-120, home+120).toDouble();
    }
    return false;
  }

  void hit() {
    if (defeated) return;
    pose = NewEnemyPose.hit;
  }

  void defeat() {
    defeated = true;
    pose = NewEnemyPose.defeated;
  }
}
