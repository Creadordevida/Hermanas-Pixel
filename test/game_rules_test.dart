import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/main.dart';

void main() {
  test('Siete capítulos, y exclusividad solo en fútbol y ballet', () {
    expect(chapterNames.length, 7);
    expect(chapterScenes.length, 7);
    expect(chapterProps.length, 7);
    expect(StageData(4).forcedMiren, true);
    expect(StageData(5).forcedSara, true);
    for (final chapter in [0, 1, 2, 3, 6]) {
      expect(StageData(chapter).forcedMiren, false);
      expect(StageData(chapter).forcedSara, false);
    }
  });
  test('Enemigos resistentes y proyectiles limitados por familias', () {
    expect(Enemy(0, 'dog_dalmatian', 100).hp, 1);
    expect(Enemy(0, 'dog_brown', 100).hp, 1);
    expect(Enemy(0, 'dog_doberman', 100).hp, 2);
    for (final name in ['referee', 'breakdancer', 'teacher', 'statue']) {
      expect(Enemy(0, name, 200).ranged, true);
      expect(Enemy(0, name, 200).hp, 3);
    }
    for (final name in ['rival', 'novice', 'bully', 'rat', 'cat', 'pigeon']) {
      expect(Enemy(0, name, 100).hp, 1);
    }
  });
  test('Diferenciación temática de obstáculos y fases', () {
    expect(StageData(0).prop, 'crate');
    expect(StageData(3).prop, 'planter');
    expect(StageData(4).prop, 'cone');
    expect(StageData(5).prop, 'gym_bench');
    expect(StageData(6).prop, 'backpack');
    expect(StageData(6).enemies, containsAll(['bully', 'teacher']));
  });
}
