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
  'cleaning_robot': NewEnemyHitProfile(43, 56, 49),
  'rival_supporter': NewEnemyHitProfile(43, 67, 59),
  'tipsy_tourist': NewEnemyHitProfile(42, 67, 59),
  'navarre_king': NewEnemyHitProfile(42, 58, 52),
  'estafeta_bull': NewEnemyHitProfile(75, 58, 51),
  'sanfermin_runner': NewEnemyHitProfile(42, 64, 57),
};
