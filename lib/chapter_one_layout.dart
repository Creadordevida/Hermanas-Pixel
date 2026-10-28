import 'neighborhood_scene_engine.dart' show neighborhoodSceneRegions;

/// Capítulo 1: geografía real reinterpretada en pixel art. Las cuatro vistas
/// se muestran una sola vez por recorrido; el mundo no repite panorámicas.
/// Las coordenadas están en píxeles lógicos de MUNDO, no de pantalla.
class NeighborhoodZone {
  const NeighborhoodZone(this.id, this.asset, this.start, this.end);
  final String id;
  final String asset;
  final double start;
  final double end;
  double get length => end - start;
}

// Fuente única de límites: los encuentros usan los mismos inicios de hito
// que el render de fondos. Los enlaces entre hitos pertenecen a la zona
// anterior. Nunca duplicar aquí números de coordenadas independientes.
final List<NeighborhoodZone> neighborhoodZones =
    List<NeighborhoodZone>.unmodifiable(() {
  final landmarks = neighborhoodSceneRegions.where((r) => !r.connector).toList();
  return <NeighborhoodZone>[
    for (int i = 0; i < landmarks.length; i++)
      NeighborhoodZone(
        landmarks[i].id,
        landmarks[i].asset,
        landmarks[i].start,
        i + 1 < landmarks.length ? landmarks[i + 1].start :
            neighborhoodSceneRegions.last.end,
      ),
  ];
}());

/// El mismo atlas da árboles, plantas y mobiliario independientes del fondo.
/// Ninguno de sus sprites es un monumento repetido.
const int neighborhoodAtlasColumns = 4;
const int neighborhoodAtlasRows = 3;

int neighborhoodZoneIndex(double worldX) {
  for (int i = neighborhoodZones.length - 1; i >= 0; i--) {
    if (worldX >= neighborhoodZones[i].start) return i;
  }
  return 0;
}
