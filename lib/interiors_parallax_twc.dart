/// THE WOLF COMPANY — Interiores de danza y colegio.
/// Reutiliza la cámara mundial y la separación 0.30 / 0.56 / 1.00.
/// En interiores SOLO el paisaje visto tras los cristales se mueve a 0.30/0.56.
/// Los muros, puertas, mobiliario y suelo ocupan coordenadas físicas 1:1.
/// Cambios de estancia mediante MARCOS, nunca alfa de habitaciones enteras.
const double interiorStageWidthTWC = 36500;
const double interiorModuleWidthTWC = 880;
const double interiorFarSpeedTWC = 0.30;
const double interiorMidSpeedTWC = 0.56;
const double interiorNearSpeedTWC = 1.00;
const int interiorFarCycleWidthTWC = 2200;
const int interiorMidCycleWidthTWC = 2020;
const int interiorVariantsPerRoomTWC = 3;

const List<double> interiorZoneEdgesTWC = [0, 10500, 25500, 36500];
const List<String> interiorDanceRoomsTWC = ['foyer','studio','stage'];
const List<String> interiorSchoolRoomsTWC = ['hall','classroom','computers'];

String interiorAssetTWC(String theme, String name) =>
    'assets/images/interiors_parallax/$theme/$name.png';

String interiorPanelAssetTWC(String theme, int zone, int variant) {
  if (zone < 0 || zone >= 3 || variant < 0 || variant >= 3) {
    throw RangeError('Invalid room panel: $theme:$zone/$variant');
  }
  return interiorAssetTWC(theme,'z${zone}_panel_$variant');
}

double interiorLoopOffsetTWC(double cameraX, double speed, int width) {
  if (speed <= 0 || width <= 0) throw ArgumentError('Invalid parallax');
  return (cameraX*speed) % width;
}

double interiorLoopWorldPeriodTWC(double speed,int width) => width/speed;

double interiorModuleXWorldTWC(int zone, int index) {
  if (zone < 0 || zone >= 3 || index < 0) throw RangeError('Invalid interior module');
  return interiorZoneEdgesTWC[zone] + index*interiorModuleWidthTWC;
}

int interiorModuleVariantTWC(int zone,int index) {
  if(zone < 0 || zone >= 3 || index < 0) throw RangeError('Invalid interior variant');
  return index % interiorVariantsPerRoomTWC;
}

/// Índices de paneles potencialmente visibles, anclados a la zona, no a foto.
Iterable<int> interiorVisibleModulesTWC(int zone, double cameraX,
    {double viewportWidth = 800}) sync* {
  final start=interiorZoneEdgesTWC[zone];
  final end=interiorZoneEdgesTWC[zone+1];
  if(cameraX + viewportWidth <= start || cameraX >= end) return;
  final first=(((cameraX-start)/interiorModuleWidthTWC).floor()-1).clamp(0,999999).toInt();
  final last=(((cameraX+viewportWidth-start)/interiorModuleWidthTWC).floor()+1).clamp(0,999999).toInt();
  for(var i=first;i<=last;i++) {
    if (interiorModuleXWorldTWC(zone,i) >= end) break;
    yield i;
  }
}
