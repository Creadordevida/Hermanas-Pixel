import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/main.dart';

void main() {
  group('Adversarios de la candidata 0.9.1', () {
    test('Las tres variantes caninas respetan su resistencia', () {
      expect(Enemy(0, 'dog_dalmatian', 100).hp, 1);
      expect(Enemy(1, 'dog_brown', 100).hp, 1);
      expect(Enemy(2, 'dog_doberman', 100).hp, 2);
      expect(Enemy(2, 'dog_doberman', 100).speed,
          greaterThan(Enemy(0, 'dog_dalmatian', 100).speed));
      expect(Enemy(2, 'dog_doberman', 100).detection,
          greaterThan(Enemy(0, 'dog_dalmatian', 100).detection));
    });
    test('Todos los adversarios difíciles requieren tres impactos', () {
      for (final type in ['referee', 'breakdancer', 'teacher']) {
        final e = Enemy(3, type, 120);
        expect(e.hp, 3, reason: type);
        expect(e.ranged, isTrue, reason: type);
      }
    });
    test('El rey de Navarra resiste tres impactos y no lanza proyectiles', () {
      final king = Enemy(3, 'navarre_king', 120);
      expect(king.hp, 3);
      expect(king.ranged, isFalse);
      expect(enemyKinds, contains('navarre_king'));
      expect(enemyKinds, isNot(contains('statue')));
    });
    test('Los rivales básicos tienen una resistencia de un golpe', () {
      for (final type in ['rival', 'novice', 'bully', 'pigeon', 'rat', 'cat']) {
        expect(Enemy(3, type, 120).hp, 1, reason: type);
      }
    });
    test('Los siete capítulos están desbloqueables y con heroína correcta', () {
      expect(chapterNames.length, 7);
      expect(StageData(4).forcedMiren, isTrue);
      expect(StageData(5).forcedSara, isTrue);
      expect(StageData(6).forcedMiren, isFalse);
      expect(StageData(6).forcedSara, isFalse);
    });
    test('El suelo aprobado y las físicas mantienen parámetros seguros', () {
      expect(groundY, 390);
      expect(stageWidth, greaterThan(800));
    });
  });
}
