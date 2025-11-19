class Lugar {
  final int id;
  final String nombre;
  final double lat;
  final double lon;
  final int? capacidadMaxima;
  final int? countNow;
  final String? semaforo;
  final String? direccion;
  final String? comuna;
  final String? region;
  final String? sourceId; // <== NUEVO (código de cámara)
  final String? imageUrl;

  Lugar({
    required this.id,
    required this.nombre,
    required this.lat,
    required this.lon,
    this.capacidadMaxima,
    this.countNow,
    this.semaforo,
    this.direccion,
    this.comuna,
    this.region,
    this.sourceId,
    this.imageUrl
  });

  factory Lugar.fromJson(Map<String, dynamic> j) => Lugar(
    id: j['id'] as int,
    nombre: (j['nombre'] as String?) ?? 'Lugar',
    lat: (j['lat'] as num).toDouble(),
    lon: (j['lon'] as num).toDouble(),
    capacidadMaxima: (j['capacidad_maxima'] ?? j['capacidadMaxima']) as int?,
    countNow: (j['count_now'] ?? j['countNow']) as int?,
    semaforo: j['semaforo'] as String?,
    direccion: j['direccion'] as String?,
    comuna: j['comuna'] as String?,
    region: j['region'] as String?,
    sourceId: j['source_id'] as String?, // <== NUEVO
    imageUrl: j['image_url'] as String?,

  );
}
