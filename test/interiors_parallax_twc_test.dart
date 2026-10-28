import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/interiors_parallax_twc.dart';

void main() {
  test('Cámara aprobada: 0.30, 0.56 y piezas físicas 1.00', () {
    expect(interiorFarSpeedTWC, 0.30);
    expect(interiorMidSpeedTWC, 0.56);
    expect(interiorNearSpeedTWC, 1.00);
    expect(interiorLoopOffsetTWC(600, interiorFarSpeedTWC, 2200), closeTo(180, .001));
    expect(interiorLoopOffsetTWC(600, interiorMidSpeedTWC, 2020), closeTo(336, .001));
    expect(interiorLoopWorldPeriodTWC(interiorFarSpeedTWC,2200),closeTo(7333.33,.02));
  });
  test('Colegio y danza: tres estancias consecutivas hasta 36.500', () {
    expect(interiorZoneEdgesTWC, [0, 10500, 25500, 36500]);
    expect(interiorStageWidthTWC, 36500);
    expect(interiorDanceRoomsTWC.length, 3);
    expect(interiorSchoolRoomsTWC.length, 3);
  });
  test('Posiciones físicas de puertas y paneles', () {
    expect(interiorModuleXWorldTWC(0, 0),0);
    expect(interiorModuleXWorldTWC(1,0),10500);
    expect(interiorModuleXWorldTWC(2,0),25500);
    expect(interiorModuleXWorldTWC(1,3),10500+3*880);
    expect(interiorModuleVariantTWC(1,5),2);
    expect(interiorPanelAssetTWC('dance',0,1),endsWith('/dance/z0_panel_1.png'));
  });
  test('Sin huecos en cada ventana de cámara', () {
    for (var cam=0.0;cam<=35700;cam+=113) {
      var covered=0.0;
      for (var zone=0;zone<3;zone++) {
        for(final index in interiorVisibleModulesTWC(zone,cam)) {
          final left=interiorModuleXWorldTWC(zone,index);
          final right=(left+interiorModuleWidthTWC)
              .clamp(interiorZoneEdgesTWC[zone],interiorZoneEdgesTWC[zone+1]).toDouble();
          covered += (right.clamp(cam,cam+800)-left.clamp(cam,cam+800))
              .clamp(0.0,800.0).toDouble();
        }
      }
      expect(covered,closeTo(800,0.01),reason:'Cámara $cam');
    }
  });
}
