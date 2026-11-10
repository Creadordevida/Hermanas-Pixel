import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/arga_hook_projectile.dart';

void main() {
  test('hook travels in a visible parabola then drops into river', () {
    final hook = ArgaHookProjectile(
      originX: 100, originY: 250, facing: 1, targetX: 240);
    hook.update(.2, waterY: 380);
    expect(hook.x, greaterThan(100));
    expect(hook.y, lessThan(250));
    for (var i = 0; i < 100 && hook.active; i++) {
      hook.update(.02, waterY: 380);
    }
    expect(hook.active, isFalse);
  });

  test('missed hook does not harm a distant character', () {
    final hook = ArgaHookProjectile(
      originX: 100, originY: 250, facing: -1, targetX: 0);
    expect(hook.overlaps(centerX: 700, halfWidth: 12, top: 200, bottom: 280), isFalse);
    expect(hook.active, isTrue);
  });

  test('one hit consumes hook and cannot hit both sisters', () {
    final hook = ArgaHookProjectile(
      originX: 100, originY: 250, facing: 1, targetX: 200);
    expect(hook.overlaps(centerX: 100, halfWidth: 12, top: 230, bottom: 280), isTrue);
    expect(hook.overlaps(centerX: 100, halfWidth: 12, top: 230, bottom: 280), isFalse);
    expect(hook.deliveredHit, isTrue);
    expect(hook.active, isFalse);
  });

  test('cancelled hook cannot inflict delayed damage', () {
    final hook = ArgaHookProjectile(
      originX: 100, originY: 250, facing: 1, targetX: 180);
    hook.cancel();
    hook.update(.3, waterY: 380);
    expect(hook.overlaps(centerX: 100, halfWidth: 12, top: 230, bottom: 280), isFalse);
  });

  test('oversized elapsed time expires without going beyond lifetime', () {
    final hook = ArgaHookProjectile(
      originX: 100, originY: 250, facing: 1, targetX: 260);
    hook.update(5, waterY: 1000);
    expect(hook.active, isFalse);
    expect(hook.age, lessThanOrEqualTo(ArgaHookProjectile.maxAge + .00001));
  });
}
