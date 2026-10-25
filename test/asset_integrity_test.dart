import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Los 117 recursos requeridos por el motor están empaquetados', () async {
    final required=<String>[
      'assets/images/title_approved.png',
      'assets/images/brand_logo_twc.png',
      'assets/images/worldmap/pamplona.png',
      for(final n in ['level_pixel','level_ayuntamiento','level_estafeta','level_plaza_castillo'])
        'assets/images/$n.png',
      for(final n in ['football','ballet','school','school_classroom','school_computers'])
        'assets/images/scenes/$n.png',
      for(final n in ['crate','coin','ball','comb']) 'assets/images/$n.png',
      for(final n in ['cone','planter','backpack','gym_bench','red_card','shoe','eraser'])
        'assets/images/props/$n.png',
      for(final role in ['padre','futbolista','bailarina'])
        for(final pose in ['idle_0','walk_0','walk_1','jump_0'])
          'assets/images/frames/${role}_$pose.png',
      for(final role in ['futbolista','bailarina'])
        for(final pose in ['idle_0','walk_0','walk_1','jump_0'])
          'assets/images/outfits/${role}_$pose.png',
      for(final variant in ['', 'dalmatian/', 'doberman/'])
        for(final pose in ['idle','walk','alert','run','bite','hit','stunned','defeated'])
          'assets/images/dog/$variant$pose.png',
      for(final role in ['rival','referee','novice','breakdancer','pigeon','cat','rat','bully','teacher','statue'])
        for(var i=0;i<5;i++) 'assets/images/enemies/${role}_$i.png',
    ];
    for(final path in required) {
      final blob=await rootBundle.load(path);
      expect(blob.lengthInBytes, greaterThan(200), reason:path);
    }
  });
}
