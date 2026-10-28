/// Capítulo 1: paisaje físico construido de antemano a partir de atlas,
/// vegetación y siete lugares originales. Cada pieza ocupa coordenadas
/// absolutas de mundo; se mueve 1:1 con la cámara y jamás se estira.
/// Generador y manifiesto: tools/build_ch1_world_tiles.py
const double ch1PhysicalWidth = 36500;
const double ch1PhysicalHeight = 380;
const double ch1PhysicalTileWidth = 512;
const int ch1PhysicalTileCount = 72;

String ch1PhysicalTileAsset(int index) {
  if (index < 0 || index >= ch1PhysicalTileCount) {
    throw RangeError.range(index, 0, ch1PhysicalTileCount - 1);
  }
  return 'assets/images/chapter1/ch1_world_tiles/world_${index.toString().padLeft(3, '0')}.png';
}

double ch1PhysicalTileX(int index) => index * ch1PhysicalTileWidth;
double ch1PhysicalTileActualWidth(int index) =>
    (ch1PhysicalWidth - ch1PhysicalTileX(index))
        .clamp(0.0, ch1PhysicalTileWidth).toDouble();

/// Incluye índices vecinos en ambos lados para evitar rendijas subpíxel.
Iterable<int> ch1PhysicalVisibleTiles(double cameraX,
    {double viewportWidth = 800}) sync* {
  final first = ((cameraX / ch1PhysicalTileWidth).floor() - 1)
      .clamp(0, ch1PhysicalTileCount - 1).toInt();
  final last = (((cameraX + viewportWidth) / ch1PhysicalTileWidth).floor() + 1)
      .clamp(0, ch1PhysicalTileCount - 1).toInt();
  for (int index = first; index <= last; index++) {
    yield index;
  }
}

/// Contrato de cámara común con el escenario y los protagonistas.
double ch1CameraForHero(double heroX, {double viewportWidth = 800,
    double followOffset = 327}) =>
  (heroX - followOffset).clamp(0.0,ch1PhysicalWidth-viewportWidth).toDouble();

/// Paisaje distante y ciudad: textura circular de 2200 px que reaparece
/// aproximadamente cada quinta parte del recorrido, sin desplazarse 1:1.
const double ch1FarSpeed = 0.30;
const double ch1MidSpeed = 0.56;
const int ch1FarCycleWidth = 2200;
const int ch1MidCycleWidth = 2020;

double ch1LoopOffset(double cameraX,double speed,int width) {
  if (speed <= 0 || width <= 0) throw ArgumentError('Invalid parallax');
  return (cameraX*speed)%width;
}

double ch1LoopWorldInterval(double speed,int width) => width/speed;
