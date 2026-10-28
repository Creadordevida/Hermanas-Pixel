import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/football_parallax_twc.dart';

void main() {
  test('TWC: mismas tres velocidades aprobadas, sin inmovilizar montañas', () {
    expect(footballFarSpeedTWC, 0.30);
    expect(footballMidSpeedTWC, 0.56);
    expect(footballLoopShiftTWC(600,footballFarSpeedTWC,footballFarCycleWidthTWC),180);
    expect(footballLoopShiftTWC(600,footballMidSpeedTWC,footballMidCycleWidthTWC),336);
    expect(footballLoopWorldPeriodTWC(footballFarSpeedTWC,footballFarCycleWidthTWC),closeTo(7333.33,0.02));
    expect(footballLoopWorldPeriodTWC(footballMidSpeedTWC,footballMidCycleWidthTWC),closeTo(3607.14,0.02));
    expect(() => footballLoopShiftTWC(0,0,2200),throwsArgumentError);
  });
  test('TWC: campo de fútbol con seis módulos 1:1 en ciclo de 6.600',(){
    expect(footballWorldLengthTWC,36500);
    expect(footballBackdropHeightTWC,386);
    expect(footballTileCountTWC,6);
    expect(footballNearWorldCycleTWC,6600);
    expect(footballNearTileAssetTWC(5),endsWith('/near_5.png'));
    expect(() => footballNearTileAssetTWC(6),throwsRangeError);
    expect(footballNearModuleAssetIndex(6),0);
    for(double cam=0;cam<=35700;cam+=113){
      final tiles=footballVisibleModulesTWC(cam).toList();
      expect(tiles,isNotEmpty);
      expect(footballNearModuleX(tiles.first),lessThanOrEqualTo(cam));
      expect(footballNearModuleX(tiles.last)+footballTileWidthTWC,
          greaterThanOrEqualTo(cam+800));
    }
  });
}
