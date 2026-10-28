/// CAPÍTULO 1 - RC3 WORLD V4 (experimental, nunca habilitar en producción
/// sin auditoría visual y Flutter). Inspirado en mapas de piezas/objetos SNES.
/// Toda coordenada se expresa en píxeles de MUNDO, no en fracción de foto.
/// Usa los tramos jugables de `neighborhood_scene_engine.dart`: no crea un
/// segundo mapa de zonas ni altera otros capítulos.
import 'neighborhood_scene_engine.dart' show neighborhoodSceneRegions;

class Ch1LandmarkV4 {
  const Ch1LandmarkV4(this.asset, this.x, this.sourceW, this.sourceH,
      {this.displayH = 380});
  final String asset;
  final double x, sourceW, sourceH, displayH;
  double get width => sourceW * displayH / sourceH;
  double get right => x + width;
  double screenX(double cameraX) => x - cameraX;
  bool visible(double cameraX, double viewport) =>
      right > cameraX && x < cameraX + viewport;
}

/// El hito original se usa una única vez y a escala uniforme. Los enlaces
/// constituyen piezas independientes, NO panoramas extendidos sobre 7 km.
/// Solo especificaciones de píxeles: NO DUPLICAR coordenadas aquí.
/// Las posiciones se importan de neighborhoodSceneRegions (fuente única).
const ch1SourceDimsV4 = <String, (double, double)>{
  // Las pinturas tienen alto de archivo mayor que la ventana de juego:
  // mostrar hasta el borde del paseo, no truncar bancos y vallas en y=690.
  // Recorte aprobado SOLAMENTE en laboratorio; conservar los PNG intactos.
  'residential_curve': (1672, 790),
  'connector_residential_greenway_v091': (2116, 620),
  'green_promenade': (1672, 790),
  'connector_neutral_park_v091': (2086, 635),
  'white_canopy': (1672, 790),
  'connector_pergola_v091': (2172, 600),
  'rocket_park': (1672, 790),
};

final List<Ch1LandmarkV4> ch1LandmarksV4 =
    List<Ch1LandmarkV4>.unmodifiable([
  for (final region in neighborhoodSceneRegions)
    Ch1LandmarkV4(region.asset,region.start,
      ch1SourceDimsV4[region.asset]!.$1,
      ch1SourceDimsV4[region.asset]!.$2),
]);

/// El atlas de atrezzo NO es un panorama: objetos transparentes completos,
/// posición física independiente y culling de cámara. Límites medidos por
/// alfa en park_props_atlas.png; no se dibuja ningún árbol cortado.
class Ch1PropV4 {
  const Ch1PropV4(this.id, this.worldX, this.atlasIndex,
      {this.height = 118, this.baseY = 387});
  final int id, atlasIndex;
  final double worldX, height, baseY;
}

/// 12 rectángulos del atlas; cada contorno es una figura totalmente aislada.
/// x, y, w, h en píxeles fuente del atlas 1448x1086.
const ch1PropRectsV4 = <List<double>>[
  [24,9,346,451], [391,27,325,434], [736,25,351,439],
  [1103,25,326,436], [113,472,163,316], [380,554,324,211],
  [771,600,309,159], [1153,539,246,219],
  [516,767,68,298], [63,908,340,147], [707,854,438,195],
  [1246,841,103,208],
];

/// Un mapa físico de mobiliario con variaciones reproducibles. En los hitos
/// fotografiados no se colocan nuevos árboles encima de los monumentos.
/// Es un PROTOTIPO de distribución, pendiente de curación manual por artista.
/// Protección por CAJA COMPLETA (no solo origen): una copa no puede
/// invadir una ilustración protegida aunque su tronco esté fuera.
bool ch1PropSafeV4(double x, {double width = 0}) =>
    x >= 0 && x + width <= ch1StageWidthV4 &&
    !ch1LandmarksV4.any((p) =>
       x < p.right + 120 && x + width > p.x - 120);

Iterable<Ch1PropV4> ch1PropsV4() sync* {
  int id = 0;
  // Trazado reproducible con sectores diferentes: jardines, paseo y plaza.
  // No alterar los monumentos: el mobiliario se coloca por caja real.
  for (int block = 0; block < 36500 / 470; block++) {
    final sector = (block * 470) ~/ 4600;
    final offset = (block * 47 + sector * 79) % 155;
    final x = block * 470.0 + offset;
    final int scheme = (block * 13 + sector * 5) % 9;
    final choices = switch (scheme) {
       0 => <(double,int,double)>[(x+32,2,170),(x+318,9,62)],
       1 => <(double,int,double)>[(x+61,8,109),(x+220,5,78)],
       2 => <(double,int,double)>[(x+22,1,175),(x+310,11,91)],
       3 => <(double,int,double)>[(x+61,4,148),(x+268,6,65)],
       4 => <(double,int,double)>[(x+85,9,62),(x+252,7,86)],
       5 => <(double,int,double)>[(x+59,0,170),(x+309,8,115)],
       6 => <(double,int,double)>[(x+40,3,174),(x+317,11,97)],
       7 => <(double,int,double)>[(x+90,5,91),(x+272,9,65)],
       _ => <(double,int,double)>[(x+49,2,172),(x+305,7,84)],
    };
    for (final item in choices) {
      final rect=ch1PropRectsV4[item.$2];
      final ww=item.$3*rect[2]/rect[3];
      if(ch1PropSafeV4(item.$1,width:ww)) {
        yield Ch1PropV4(id++, item.$1, item.$2,height:item.$3);
      }
    }
  }
}

/// Siluetas vegetales de segundo plano, piezas enteras y variadas.
/// No colocarlas delante de ninguna imagen hito aprobada.
Iterable<Ch1PropV4> ch1MidTreesV4() sync* {
  var id=10000;
  for(int i=0;i<110;i++) {
    final x=160.0 + i*335.0 + (i%4)*55.0;
    if(!ch1PropSafeV4(x, width:(99+(i%3)*15.0)*ch1PropRectsV4[i%4][2]/ch1PropRectsV4[i%4][3])) continue;
    yield Ch1PropV4(id++,x,i%4,height:99+(i%3)*15.0,baseY:341);
  }
}

/// Dos nubes obtenidas de arte nuevo (NO son hitos ni se usan para ocultar
/// fachadas); pueden repetirse en paralaje sin repetir edificios originales.
const ch1CloudRectsV4 = <List<double>>[
  [8,4,480,170], [530,4,470,170],
];

/// Piezas físicas idénticas en simulación y motor. Los últimos recortes de
/// viewport jamás estiran las dimensiones intrínsecas de la pieza.
const double ch1StageWidthV4 = 36500;
const double ch1FloorYV4 = 390;
const double ch1FloorTileWidthV4 = 540;

double ch1CameraXForHeroV4(double heroWorldX,
    {double viewport = 800, double followOffset = 327}) =>
  (heroWorldX - followOffset).clamp(0.0, ch1StageWidthV4 - viewport).toDouble();

double ch1OnScreenV4(double worldX, double cameraX) => worldX - cameraX;

bool ch1RegionsConsistentV4() {
  if (neighborhoodSceneRegions.first.start != 0 ||
      neighborhoodSceneRegions.last.end != ch1StageWidthV4) return false;
  for (var i = 1; i < neighborhoodSceneRegions.length; i++) {
    if (neighborhoodSceneRegions[i-1].end != neighborhoodSceneRegions[i].start) {
      return false;
    }
  }
  return ch1LandmarksV4.length == neighborhoodSceneRegions.length &&
      ch1LandmarksV4.every((p) => p.width > 0 && p.displayH > 0);
}
