import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/interiors_parallax_twc.dart';

void main() {
  test('School corridors are identified from displayed module variant', () {
    for (var zone = 1; zone <= 2; zone++) {
      var hasCorridor = false;
      var hasClassroom = false;
      for (var i = 0; i < 18; i++) {
        final variant = interiorModuleVariantTWC(zone, i, theme: 'school');
        final actual = interiorSchoolRoomTypeTWC(zone, i);
        expect(actual, interiorSchoolSourcePlanTWC[zone][variant]);
        if (actual == 0) {
          hasCorridor = true;
        } else {
          hasClassroom = true;
        }
      }
      expect(hasCorridor, isTrue);
      expect(hasClassroom, isTrue);
    }
  });

  test('School physical desks are separated from source-room types', () {
    for (var zone = 1; zone <= 2; zone++) {
      for (var i = 0; i < 18; i++) {
        final room = interiorSchoolRoomTypeTWC(zone, i);
        expect(room, inInclusiveRange(0, 2));
        for (final dx in interiorSchoolDeskOffsetsTWC(zone, i)) {
          expect(dx, greaterThanOrEqualTo(0));
          expect(dx, lessThan(760));
        }
        // The renderer excludes room==0 and gives a computer to room==2.
        // Its coordinates remain in world space; no scenic parallax.
      }
    }
  });
}
