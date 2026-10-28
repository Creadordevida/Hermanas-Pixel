/// Fútbol: mismo contrato de movimiento validado en el capítulo 1 RC3 FIX2.
/// Paisaje DIFERENTE, técnica idéntica: .30 / .56 / 1.00.
/// Los assets deportivos se crean con tools/build_football_parallax_twc.py.
/// Nunca se aplica un fundido completo entre escenas ni se estiran panorámicas
/// a lo largo de los sectores de 10.500/15.000 unidades del nivel.
const double footballWorldLengthTWC = 36500;
const double footballBackdropHeightTWC = 386;
const double footballTileWidthTWC = 1100;
const int footballTileCountTWC = 6;
const int footballFarCycleWidthTWC = 2200;
const int footballMidCycleWidthTWC = 2020;
const double footballFarSpeedTWC = 0.30;
const double footballMidSpeedTWC = 0.56;

const String footballFarAssetTWC =
    'assets/images/chapter45/football_parallax/montanas_ciudad_deportiva_ciclo.png';
const String footballMidAssetTWC =
    'assets/images/chapter45/football_parallax/arbolado_deportivo_ciclo.png';

String footballNearTileAssetTWC(int index) {
  if (index < 0 || index >= footballTileCountTWC) {
    throw RangeError.range(index, 0, footballTileCountTWC - 1);
  }
  return 'assets/images/chapter45/football_parallax/near_world_tiles/near_$index.png';
}

/// Módulo de mundo: baseX=n*1100, pieza gráfica n % 6.
/// El primer plano avanza 100% con la cámara, mientras la vegetación remota
/// viaja a .56 y las montañas a .30. El periodo completo son 6.600px.
const double footballNearWorldCycleTWC = footballTileWidthTWC * footballTileCountTWC;

double footballNearModuleX(int absoluteIndex) => absoluteIndex * footballTileWidthTWC;
int footballNearModuleAssetIndex(int absoluteIndex) =>
    absoluteIndex % footballTileCountTWC;

Iterable<int> footballVisibleModulesTWC(double cameraX,
    {double viewportWidth = 800}) sync* {
  final first = ((cameraX / footballTileWidthTWC).floor() - 1).clamp(0, 999999).toInt();
  final last = ((cameraX + viewportWidth) / footballTileWidthTWC).floor() + 1;
  for (var n=first;n<=last;n++) yield n;
}

double footballLoopShiftTWC(double cameraX, double speed, int width) {
  if (speed <= 0 || width <= 0) throw ArgumentError('Invalid parallax');
  return (cameraX * speed) % width;
}

double footballLoopWorldPeriodTWC(double speed, int width) => width / speed;
