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
const int interiorVariantsPerRoomTWC = 3; // danza: sin cambios
const int interiorSchoolVariantsTWC = 9; // colegio: 9 recortes 1:1 por estancia
const bool schoolHifiArtworkEnabled =
    bool.fromEnvironment('TWC_SCHOOL_HIFI_ART', defaultValue: true);

const List<double> interiorZoneEdgesTWC = [0, 10500, 25500, 36500];
const List<String> interiorDanceRoomsTWC = ['foyer','studio','stage'];
const List<String> interiorSchoolRoomsTWC = ['hall','classroom','computers'];
// Misma secuencia de ilustraciones ORIGINALES que el generador Python.
// El paso a otro tipo de estancia se señala con una puerta física 1:1.
const List<List<int>> interiorSchoolSourcePlanTWC = [
  [0,0,0,1,0,0,0,2,0],
  [1,1,0,1,1,0,1,1,2],
  [2,2,0,2,2,0,2,2,1],
];
// Five true room types: 0 corridor, 1 desks, 2 computing,
// 3 library and 4 lockers. Never overlay old desks onto this new artwork.
const List<List<int>> interiorSchoolSourcePlanHifiTWC = [
  [0,4,0,4,3,0,4,3,0],
  [1,1,0,1,3,1,1,0,3],
  [2,2,4,2,3,2,2,4,2],
];

String interiorAssetTWC(String theme, String name) =>
    'assets/images/interiors_parallax/$theme/$name.png';

String interiorPanelAssetTWC(String theme, int zone, int variant) {
  final count=theme=='school'
    ? interiorSchoolVariantsTWC : interiorVariantsPerRoomTWC;
  if ((theme!='school' && theme!='dance') ||
      zone < 0 || zone >= 3 || variant < 0 || variant >= count) {
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

int interiorModuleVariantTWC(int zone,int index,{String theme='dance'}) {
  if(zone < 0 || zone >= 3 || index < 0) {
    throw RangeError('Invalid interior variant');
  }
  if(theme=='school') {
    // The five authored HIFI interior types must follow their genuine
    // physical corridor/classroom/library/IT sequence in the world.
    if(schoolHifiArtworkEnabled) return index % interiorSchoolVariantsTWC;
    // Preserve the old permutation for archived RC5 assets only.
    return (index*5 + zone*2) % interiorSchoolVariantsTWC;
  }
  return index % interiorVariantsPerRoomTWC;
}

int interiorSchoolRoomTypeTWC(int zone,int index) {
  if(zone<0 || zone>=3 || index<0) {
    throw RangeError('Invalid school room type');
  }
  final variant=interiorModuleVariantTWC(zone,index,theme:'school');
  return (schoolHifiArtworkEnabled
      ? interiorSchoolSourcePlanHifiTWC
      : interiorSchoolSourcePlanTWC)[zone][variant];
}

/// True if a real change of school space occurs at the boundary
/// between module index-1 and module index. This is NOT an arbitrary
/// decorative arch repeated every four panels.
bool interiorSchoolDoorAtModuleTWC(int zone,int index) =>
    // New authored scenes already have their doors and jambs. Overlaying
    // the old 120px passage on every classroom change would look pasted-on.
    !schoolHifiArtworkEnabled && index>0 &&
    interiorSchoolRoomTypeTWC(zone,index-1)
        !=interiorSchoolRoomTypeTWC(zone,index);

/// Diverse non-colliding school furnishings in WORLD coordinates.
/// Each source desk is an AUTHENTIC cutout from the approved classroom.
/// No floor or window layers are moved with the furniture.
/// Empty modules become corridors/transitions rather than endless desks.
List<double> interiorSchoolDeskOffsetsTWC(int zone,int index) {
  if(zone!=1 && zone!=2) return const [];
  if(index<0) throw RangeError('Negative classroom module');
  const patterns=<List<double>>[
    <double>[270, 590],
    <double>[],
    <double>[390],
    <double>[190, 580],
    <double>[490],
    <double>[240, 600],
    <double>[],
  ];
  return patterns[(index+zone*3) % patterns.length];
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
