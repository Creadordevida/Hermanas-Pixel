import 'package:flutter_test/flutter_test.dart';
import '../lib/interiors_parallax_twc.dart';

void main() {
  test('El colegio usa nueve fondos reales por zona, no tres clones', () {
    expect(interiorSchoolVariantsTWC,9);
    expect(interiorVariantsPerRoomTWC,3); // dance preserved.
    for(var zone=0;zone<3;zone++) {
      final variants=<int>{};
      for(var index=0;index<9;index++) {
        variants.add(interiorModuleVariantTWC(
          zone,index,theme:'school'));
      }
      expect(variants,{0,1,2,3,4,5,6,7,8});
      expect(interiorModuleVariantTWC(zone,0,theme:'school'),
             interiorModuleVariantTWC(zone,9,theme:'school'));
      expect(interiorPanelAssetTWC('school',zone,8),
        contains('z${zone}_panel_8.png'));
      expect(() => interiorPanelAssetTWC('school',zone,9),
        throwsRangeError);
    }
  });

  test('Danza conserva sus tres módulos sin cambios', () {
    for(var zone=0;zone<3;zone++) {
      expect(interiorModuleVariantTWC(zone,0),0);
      expect(interiorModuleVariantTWC(zone,1),1);
      expect(interiorModuleVariantTWC(zone,2),2);
      expect(interiorModuleVariantTWC(zone,3),0);
    }
  });

  test('Hay aulas con pupitres y transiciones realmente despejadas', () {
    for(final zone in [1,2]) {
      final groups=<String>{};
      var empty=0;
      for(var i=0;i<14;i++) {
        final offsets=interiorSchoolDeskOffsetsTWC(zone,i);
        groups.add(offsets.join(','));
        if(offsets.isEmpty)empty++;
        for(final x in offsets) {
          expect(x,greaterThan(100));
          expect(x,lessThan(680));
        }
      }
      expect(groups.length,greaterThanOrEqualTo(6));
      expect(empty,greaterThanOrEqualTo(2));
    }
    expect(interiorSchoolDeskOffsetsTWC(0,0),isEmpty);
  });

  test('Paisaje de ventana sigue a 0.30/0.56; muebles y paredes a 1.0', () {
    expect(interiorFarSpeedTWC,.30);
    expect(interiorMidSpeedTWC,.56);
    expect(interiorNearSpeedTWC,1.0);
    for(final cx in [0.0,80.0,900.0,13320.0,34110.0]) {
      final far=interiorLoopOffsetTWC(cx,interiorFarSpeedTWC,
          interiorFarCycleWidthTWC);
      final mid=interiorLoopOffsetTWC(cx,interiorMidSpeedTWC,
          interiorMidCycleWidthTWC);
      expect(far,inInclusiveRange(0,interiorFarCycleWidthTWC));
      expect(mid,inInclusiveRange(0,interiorMidCycleWidthTWC));
      final zone= cx<10500 ? 0 : (cx<25500 ? 1 : 2);
      final count=interiorVisibleModulesTWC(zone,cx).length;
      expect(count,lessThan(5),
        reason:'Sólo cargar/dibujar módulos cercanos a cámara');
    }
  });
}
