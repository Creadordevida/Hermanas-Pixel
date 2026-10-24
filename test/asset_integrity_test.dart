import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Los recursos de personajes y escenario se cargan desde el bundle', () async {
    final paths = <String>[
      'assets/images/level_pixel.png',
      'assets/images/crate.png',
      'assets/images/coin.png',
    ];
    for (final name in ['padre', 'futbolista', 'bailarina']) {
      for (final pose in ['idle_0', 'walk_0', 'walk_1', 'jump_0']) {
        paths.add('assets/images/frames/${name}_$pose.png');
      }
    }
    for (final path in paths) {
      final asset = await rootBundle.load(path);
      expect(asset.lengthInBytes, greaterThan(300), reason: 'Asset ausente: $path');
    }
  });
}
