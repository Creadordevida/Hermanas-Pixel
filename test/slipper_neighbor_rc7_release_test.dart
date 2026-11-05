import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/main.dart';
import 'package:hermanas_aventura/four_enemy_behaviors.dart';

void main() {
  test('RC7 neighbor is enabled in normal release configuration', () {
    expect(twcGameplayPlaytest, isFalse,
      reason: 'This smoke test must run without gameplay playtest dart-define');
    expect(hasApprovedEnemyArtwork('slipper_neighbor'), isTrue);
    expect(isEnemyPlayableInBuild('slipper_neighbor'), isTrue);
    expect(fourEnemyStages['slipper_neighbor'], 0);
    final positions = fourEnemySpawns('slipper_neighbor', 0, 36500);
    expect(positions, hasLength(3));
    expect(positions, orderedEquals([5840.0, 17520.0, 28470.0]));
    expect(fourEnemySpawns('slipper_neighbor', 5, 36500), isEmpty);
    // Other new enemies are deliberately not released by this change.
    expect(hasApprovedEnemyArtwork('dance_cleaner'), isTrue);
    expect(hasApprovedEnemyArtwork('guitar_musician'), isTrue);
  });
}
