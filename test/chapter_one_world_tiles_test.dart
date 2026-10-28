import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/chapter_one_world_tiles.dart';

void main(){
  test('36.500 unidades cubiertas sin huecos por exactamente 72 piezas',(){
    expect(ch1PhysicalWidth,36500);
    expect(ch1PhysicalTileCount,72);
    double next=0;
    for(var n=0;n<ch1PhysicalTileCount;n++){
      expect(ch1PhysicalTileX(n),next);
      next+=ch1PhysicalTileActualWidth(n);
    }
    expect(next,ch1PhysicalWidth);
    expect(ch1PhysicalTileActualWidth(71),148);
  });
  test('La cámara conserva desplazamiento físico y límites',(){
    expect(ch1CameraForHero(327),0);
    expect(ch1CameraForHero(927),600);
    expect(ch1CameraForHero(36500),35700);
    expect(ch1PhysicalTileX(4)-600-(ch1PhysicalTileX(4)-0),-600);
  });
  test('Todas las teselas tienen ruta determinada y vecinos para cada cámara',(){
    expect(ch1PhysicalTileAsset(0),endsWith('/world_000.png'));
    expect(ch1PhysicalTileAsset(71),endsWith('/world_071.png'));
    expect(()=>ch1PhysicalTileAsset(72),throwsRangeError);
    for(double cam=0;cam<=35700;cam+=89){
      final tiles=ch1PhysicalVisibleTiles(cam).toList();
      expect(tiles,isNotEmpty);
      expect(ch1PhysicalTileX(tiles.first),lessThanOrEqualTo(cam));
      final end=ch1PhysicalTileX(tiles.last)+ch1PhysicalTileActualWidth(tiles.last);
      expect(end,greaterThanOrEqualTo(cam+800));
    }
  });
  test('Paralaje lejano en ciclo ~1/5 capitulo y plano cercano fisico',(){
    expect(ch1FarCycleWidth,2200);
    expect(ch1LoopWorldInterval(ch1FarSpeed,ch1FarCycleWidth),closeTo(7333,3));
    expect(ch1LoopOffset(0,ch1FarSpeed,ch1FarCycleWidth),0);
    expect(ch1LoopOffset(600,ch1FarSpeed,ch1FarCycleWidth),closeTo(180,0.01));
    expect(ch1LoopOffset(600,ch1MidSpeed,ch1MidCycleWidth),closeTo(336,0.01));
    expect(ch1CameraForHero(927)-ch1CameraForHero(327),600);
  });

}
