/// Frame selection for the four EXISTING high-detail enemy PNG sets.
///
/// Source frames live under assets/images/enemies/{kind}_{0..4}.png.
/// This keeps authentic painter-drawn anatomy; no geometric replacement.
///
/// The enemy's physics, damage, hitboxes and attack timing remain in main.dart.
/// This file only chooses a pose matching the current simulated state.
int classicEnemyFrame({
  required String kind,
  required double elapsed,
  required bool moving,
  required bool attacking,
  required bool stunned,
  required bool defeated,
  required double heroDistance,
  required double attackCooldown,
}) {
  // The rival has a dedicated fully prone sixth image, distinct from
  // frame 4's transitional fall. Use the actual authored final pose.
  if (defeated) return kind=='rival' ? 5 : 4;
  // These are genuine original poses, not scaled/upside-down frame tricks.
  if (stunned) {
    return switch (kind) {
      'rival' => 2,
      'bully' => 5,
      // Authentically illustrated struck poses already exist in the repo.
      'referee' => 5,
      'breakdancer' => 5,
      _ => 3,
    };
  }

  if (kind == 'breakdancer') {
    // 0 upright / 1 descent / 2 lean / 3 hands-on-floor / 4 defeat.
    // Every action phase is shown and there is NO dancing while idle.
    if (attacking) {
      if (elapsed < .10) return 0;
      if (elapsed < .22) return 1;
      if (elapsed < .34) return 2;
      if (elapsed < .54) return 3;
      if (elapsed < .66) return 2;
      return 1;
    }
    return moving ? ((elapsed * 4).floor().isEven ? 0 : 1) : 0;
  }

  if (kind == 'referee') {
    // Raise the red card over a real sequence instead of displaying one
    // static arm for the whole attack: 0 normal -> 1 brace -> 2/3 card.
    if (attacking) {
      if (elapsed < .18) return 0;
      if (elapsed < .38) return 1;
      if (elapsed < .57) return 2;
      return 3;
    }
    return moving ? ((elapsed * 5).floor().isEven ? 0 : 1) : 0;
  }

  if (kind == 'rival') {
    if (attacking) return elapsed < .13 ? 2 : 3;
    // The authentic three running frames are used only when x changed.
    return moving ? 1 + ((elapsed * 8).floor() % 3) : 0;
  }

  if (kind == 'bully') {
    if (attacking) return elapsed < .13 ? 2 : 3;
    return moving ? 1 + ((elapsed * 7).floor() % 2) : 0;
  }

  return moving ? 1 + ((elapsed * 6).floor() % 2) : 0;
}
