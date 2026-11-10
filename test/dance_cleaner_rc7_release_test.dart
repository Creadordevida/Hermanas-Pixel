import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/main.dart';
import 'package:hermanas_aventura/four_enemy_behaviors.dart';

void main() {
  test('RC7 cleaner is enabled in normal release configuration', () {
    expect(twcGameplayPlaytest, isFalse,
      reason: 'This smoke test must run without gameplay playtest dart-define');
    expect(hasApprovedEnemyArtwork('dance_cleaner'), isTrue);
    expect(isEnemyPlayableInBuild('dance_cleaner'), isTrue);
    expect(fourEnemyStages['dance_cleaner'], 5);
    final positions = fourEnemySpawns('dance_cleaner', 5, 36500);
    expect(positions, hasLength(3));
    expect(positions, orderedEquals([6570.0, 19710.0, 30295.0]));
    expect(fourEnemySpawns('dance_cleaner', 4, 36500), isEmpty);
    // The complete four-enemy RC7 set is enabled in the normal build.
    expect(hasApprovedEnemyArtwork('guitar_musician'), isTrue);
    expect(hasApprovedEnemyArtwork('slipper_neighbor'), isTrue);
    expect(hasApprovedEnemyArtwork('rival_coach'), isTrue);
  });
}
