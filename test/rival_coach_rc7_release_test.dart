import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/main.dart';
import 'package:hermanas_aventura/four_enemy_behaviors.dart';

void main() {
  test('RC7 rival coach is enabled in normal release configuration', () {
    expect(twcGameplayPlaytest, isFalse,
      reason: 'This smoke test must run without gameplay playtest dart-define');
    expect(hasApprovedEnemyArtwork('rival_coach'), isTrue);
    expect(isEnemyPlayableInBuild('rival_coach'), isTrue);
    expect(fourEnemyStages['rival_coach'], 4);
    final positions = fourEnemySpawns('rival_coach', 4, 36500);
    expect(positions, hasLength(3));
    expect(positions, orderedEquals([8760.0, 21170.0, 31390.0]));
    expect(fourEnemySpawns('rival_coach', 5, 36500), isEmpty);
    expect(hasApprovedEnemyArtwork('dance_cleaner'), isTrue);
    expect(hasApprovedEnemyArtwork('guitar_musician'), isTrue);
    expect(hasApprovedEnemyArtwork('slipper_neighbor'), isTrue);
  });
}
