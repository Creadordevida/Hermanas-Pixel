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

const neighborhoodZones = <NeighborhoodZone>[
  NeighborhoodZone('residencial', 'residential_curve', 0, 8300),
  NeighborhoodZone('paseo_verde', 'green_promenade', 8300, 17300),
  NeighborhoodZone('parque_cubierto', 'white_canopy', 17300, 26400),
  NeighborhoodZone('parque_cohete', 'rocket_park', 26400, 36500),
];

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
