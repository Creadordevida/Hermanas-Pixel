import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Todas las poses de las hermanas, el padre y el perro están empaquetadas', () async {
    final resources = <String>[
      'assets/images/title_approved.png',
      'assets/images/brand_logo_twc.png',
      'assets/images/level_pixel.png',
      'assets/images/level_ayuntamiento.png',
      'assets/images/level_estafeta.png',
      'assets/images/level_plaza_castillo.png',
      'assets/images/crate.png',
      'assets/images/coin.png',
      'assets/images/ball.png',
      'assets/images/comb.png',
    ];
    for (final role in ['padre', 'futbolista', 'bailarina']) {
      for (final pose in ['idle_0', 'walk_0', 'walk_1', 'jump_0']) {
        resources.add('assets/images/frames/${role}_$pose.png');
      }
    }
    for (final pose in ['idle', 'walk', 'alert', 'run', 'bite', 'hit', 'stunned', 'defeated']) {
      resources.add('assets/images/dog/$pose.png');
    }
    for (final path in resources) {
      final asset = await rootBundle.load(path);
      expect(asset.lengthInBytes, greaterThan(200), reason: 'Archivo ausente: $path');
    }
  });
}
