/// Hitbox for a visual sprite. Pure Dart: use identical values for
/// projectile interactions and unit tests, without importing Flutter.
class NewEnemyHitProfile {
  const NewEnemyHitProfile(this.halfWidth, this.centerAboveGround,
      this.halfHeight);
  final double halfWidth;
  final double centerAboveGround;
  final double halfHeight;

  bool projectileHits({required double foeX, required double groundY,
      required double shotX, required double shotY}) =>
      (shotX - foeX).abs() < halfWidth &&
      (shotY - (groundY - centerAboveGround)).abs() < halfHeight;
}

/// Physics silhouettes follow current *world render dimensions* (not the
/// large texture atlas cell). In particular the charging bull needs a much
/// broader collision profile than a 37px human-sized foe.
const Map<String, NewEnemyHitProfile> newEnemyHitProfiles = {
  'cleaning_robot': NewEnemyHitProfile(43, 40, 36),
  'rival_supporter': NewEnemyHitProfile(27, 70, 64),
  'tipsy_tourist': NewEnemyHitProfile(34, 70, 64),
  'navarre_king': NewEnemyHitProfile(48, 75, 67),
  'estafeta_bull': NewEnemyHitProfile(70, 55, 48),
  'sanfermin_runner': NewEnemyHitProfile(30, 70, 64),
};
