import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/main.dart';
import 'package:hermanas_aventura/four_enemy_behaviors.dart';

void main() {
  test('RC7 musician is enabled in normal release configuration', () {
    expect(twcGameplayPlaytest, isFalse,
      reason: 'This smoke test must run without gameplay playtest dart-define');
    expect(hasApprovedEnemyArtwork('guitar_musician'), isTrue);
    expect(isEnemyPlayableInBuild('guitar_musician'), isTrue);
    expect(fourEnemyStages['guitar_musician'], 5);
    final positions = fourEnemySpawns('guitar_musician', 5, 36500);
    expect(positions, hasLength(3));
    expect(positions, orderedEquals([12045.0, 24455.0, 33215.0]));
    expect(fourEnemySpawns('guitar_musician', 4, 36500), isEmpty);
    // Other new enemies are deliberately not released by this change.
    expect(hasApprovedEnemyArtwork('dance_cleaner'), isTrue);
    expect(hasApprovedEnemyArtwork('slipper_neighbor'), isFalse);
  });
}
