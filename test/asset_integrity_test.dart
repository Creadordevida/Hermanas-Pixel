import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Están empaquetados los originales y todos los recursos 0.9.0', () async {
    final paths = <String>[
      'assets/images/title_approved.png',
      'assets/images/brand_logo_twc.png',
      'assets/images/map_pamplona.png',
      'assets/images/level_pixel.png',
      'assets/images/level_ayuntamiento.png',
      'assets/images/level_estafeta.png',
      'assets/images/level_plaza_castillo.png',
      'assets/images/coin.png',
      'assets/images/crate.png',
      'assets/images/ball.png',
      'assets/images/comb.png',
    ];
    for (final name in ['football','ballet','school']) {
      paths.add('assets/images/scenes/$name.png');
    }
    for (final name in ['cone','planter','backpack','gym_bench','red_card','shoe','eraser']) {
      paths.add('assets/images/props/$name.png');
    }
    for (final role in ['padre','futbolista','bailarina']) {
      for (final pose in ['idle_0','walk_0','walk_1','jump_0']) {
        paths.add('assets/images/frames/${role}_$pose.png');
        if (role!='padre')paths.add('assets/images/outfits/${role}_$pose.png');
      }
    }
    for (final pose in ['idle','walk','alert','run','bite','hit','stunned','defeated']) {
      paths.add('assets/images/dog/$pose.png');
      for(final v in ['dalmatian','doberman']) {
        paths.add('assets/images/dog/$v/$pose.png');
      }
    }
    for (final foe in ['rival','referee','novice','breakdancer','pigeon','cat','rat','bully','teacher','statue']) {
      for(int i=0;i<5;i++)paths.add('assets/images/enemies/${foe}_$i.png');
    }
    for(final path in paths) {
      final binary=await rootBundle.load(path);
      expect(binary.lengthInBytes,greaterThan(120),reason:path);
    }
  });
}
