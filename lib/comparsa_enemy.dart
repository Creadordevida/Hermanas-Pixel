import 'dart:math' as math;
import 'dart:ui';

enum ComparsaPose { idle, walk, warning, strike, recover, hit, defeated }

enum ComparsaKind {
  giant('comparsa_gigante', 3, 38, 106, 111, .68, .56, 1.25, 35, 48, 129),
  caravinagre(
      'comparsa_caravinagre', 1, 58, 64, 84, .44, .44, .66, 79, 29, 122),
  zaldiko('comparsa_zaldiko', 2, 52, 156, 117, .56, .80, .86, 61, 54, 114);

  const ComparsaKind(
      this.id,
      this.hp,
      this.speed,
      this.trigger,
      this.reach,
      this.warning,
      this.strike,
      this.recovery,
      this.jump,
      this.halfWidth,
      this.top);

  final String id;
  final int hp;
  final double speed,
      trigger,
      reach,
      warning,
      strike,
      recovery,
      jump,
      halfWidth,
      top;

  static final byId = {for (final kind in values) kind.id: kind};
}

const comparsaAtlases = {
  ComparsaKind.giant: 'assets/images/enemies_new/comparsa_gigante.webp',
  ComparsaKind.caravinagre:
      'assets/images/enemies_new/comparsa_caravinagre.png',
  ComparsaKind.zaldiko: 'assets/images/enemies_new/comparsa_zaldiko.png',
};

const comparsaStage = 1;

// The existing unique City Hall facade spans world x=17920–19090.
const comparsaPositions = {
  ComparsaKind.caravinagre: 7200.0,
  ComparsaKind.zaldiko: 13100.0,
  ComparsaKind.giant: 18520.0,
};

const comparsaCell = Size(320, 288);
const comparsaPivot = Offset(160, 274);

Rect comparsaFrameSource(int frame) => Rect.fromLTWH(
      (frame % 4) * comparsaCell.width,
      (frame ~/ 4) * comparsaCell.height,
      comparsaCell.width,
      comparsaCell.height,
    );

class ComparsaMotion {
  ComparsaMotion(this.kind, this.home) : x = home;

  final ComparsaKind kind;
  final double home;
  double x;
  int facing = -1;
  ComparsaPose pose = ComparsaPose.idle;
  double elapsed = 0;
  double _cooldown = 0;
  bool _delivered = false;

  void _enter(ComparsaPose next) {
    if (pose == next) return;
    pose = next;
    elapsed = 0;
  }

  int frame({double stunRemaining = 0, double? defeatElapsed}) {
    if (defeatElapsed != null) {
      return defeatElapsed < .08
          ? 18
          : 20 + ((defeatElapsed - .08) * 8).floor().clamp(0, 3);
    }
    if (stunRemaining > 0) return stunRemaining > .4 ? 18 : 19;
    return switch (pose) {
      ComparsaPose.idle => (elapsed * 2).floor() % 4,
      ComparsaPose.walk =>
        4 + (elapsed * (kind == ComparsaKind.zaldiko ? 8 : 5)).floor() % 4,
      ComparsaPose.warning =>
        8 + (elapsed / kind.warning * 4).floor().clamp(0, 3),
      ComparsaPose.strike =>
        12 + (elapsed / kind.strike * 4).floor().clamp(0, 3),
      ComparsaPose.recover => elapsed < kind.recovery * .42 ? 16 : 17,
      ComparsaPose.hit => 19,
      ComparsaPose.defeated => 23,
    };
  }

  bool acceptsProjectile(double shotX, double height) {
    if (kind == ComparsaKind.giant && pose != ComparsaPose.recover)
      return false;
    return (shotX - x).abs() < kind.halfWidth &&
        height > 4 &&
        height < kind.top;
  }

  void receiveHit({required bool defeated}) {
    _enter(defeated ? ComparsaPose.defeated : ComparsaPose.hit);
    _cooldown = .72;
  }

  /// Returns the knockback direction only on the visible contact frame.
  int? update(double dt, double heroX, double heroHeight) {
    if (dt <= 0 || pose == ComparsaPose.defeated) return null;
    final previous = elapsed;
    elapsed += dt;
    _cooldown = math.max(0, _cooldown - dt);
    if (pose == ComparsaPose.warning) {
      if (elapsed >= kind.warning) {
        _enter(ComparsaPose.strike);
        _delivered = false;
      }
      return null;
    }
    if (pose == ComparsaPose.strike) {
      final contact = kind.strike / 2;
      if (kind == ComparsaKind.zaldiko) {
        final moveTime = (contact - previous).clamp(0.0, dt);
        x = (x + facing * 176 * moveTime).clamp(home - 190, home + 190);
      }
      int? knockback;
      if (!_delivered && elapsed >= contact) {
        _delivered = true;
        final dx = heroX - x;
        final sweep = kind == ComparsaKind.giant;
        final forward = dx * facing;
        final minimum = kind == ComparsaKind.zaldiko ? 48 : 36;
        final inReach = sweep
            ? dx.abs() < kind.reach
            : forward >= minimum && forward < kind.reach;
        if (inReach && heroHeight < kind.jump) {
          knockback = sweep ? (dx >= 0 ? 1 : -1) : facing;
        }
      }
      if (elapsed >= kind.strike) _enter(ComparsaPose.recover);
      return knockback;
    }
    if (pose == ComparsaPose.recover) {
      if (elapsed >= kind.recovery) {
        _enter(ComparsaPose.idle);
        _cooldown = .24;
      }
      return null;
    }
    final dx = heroX - x;
    if (dx.abs() <= kind.trigger && _cooldown <= 0) {
      facing = dx >= 0 ? 1 : -1;
      _enter(ComparsaPose.warning);
    } else if (dx.abs() > kind.trigger && dx.abs() < 330) {
      facing = dx >= 0 ? 1 : -1;
      final next = (x + facing * kind.speed * dt).clamp(home - 128, home + 128);
      _enter(next != x ? ComparsaPose.walk : ComparsaPose.idle);
      x = next;
    } else {
      _enter(ComparsaPose.idle);
    }
    return null;
  }
}
