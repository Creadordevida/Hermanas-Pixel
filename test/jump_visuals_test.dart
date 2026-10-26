import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/jump_visuals.dart';
import 'package:hermanas_aventura/main.dart';

void main() {
  group('Mejora 8: salto, caída y aterrizaje', () {
    test('Despegue, ascenso, ápice y caída dependen de velocidad real', () {
      JumpVisualPhase at(double vy, double time) => jumpVisualPhase(
        grounded: false, vy: vy, time: time,
        jumpedAt: 2.0, landedAt: -100);
      expect(at(-410,2.04), JumpVisualPhase.takeoff);
      expect(at(-250,2.20), JumpVisualPhase.rising);
      expect(at(0,2.45), JumpVisualPhase.apex);
      expect(at(350,2.65), JumpVisualPhase.falling);
    });

    test('Impacto y recuperación duran 240ms y luego vuelve la marcha', () {
      JumpVisualPhase at(double time) => jumpVisualPhase(
        grounded: true, vy: 0, time: time,
        jumpedAt: 3, landedAt: 4);
      expect(at(4.04), JumpVisualPhase.impact);
      expect(at(4.13), JumpVisualPhase.recovery);
      expect(at(4.25), JumpVisualPhase.grounded);
    });

    test('La sombra no cambia de Y aunque la heroína suba 100px', () {
      final onGround = shadowSurfaceY(
        footX:300,footY:groundY,floorY:groundY,surfaces:const []);
      final airborne = shadowSurfaceY(
        footX:300,footY:groundY-100,floorY:groundY,surfaces:const []);
      expect(onGround, groundY);
      expect(airborne, onGround);
      expect(jumpShadowScale(100), lessThan(jumpShadowScale(0)));
      expect(jumpShadowAlpha(100), lessThan(jumpShadowAlpha(0)));
    });

    test('La sombra se proyecta sobre una plataforma inferior a los pies', () {
      const platforms = [Rect.fromLTWH(240,280,120,16)];
      expect(shadowSurfaceY(footX:300,footY:235,floorY:groundY,
        surfaces:platforms),280);
      // Once below the platform, its shadow belongs to the ground.
      expect(shadowSurfaceY(footX:300,footY:310,floorY:groundY,
        surfaces:platforms),groundY);
      expect(shadowSurfaceY(footX:500,footY:235,floorY:groundY,
        surfaces:platforms),groundY);
    });

    test('No convierte caminar normal o ser golpeada en aterrizaje nuevo', () {
      final c = Character(300);
      expect(c.landedAt, -100);
      expect(jumpVisualPhase(grounded:c.grounded,vy:c.vy,
        time:10,jumpedAt:c.jumpedAt,landedAt:c.landedAt),
        JumpVisualPhase.grounded);
    });
  });
}
