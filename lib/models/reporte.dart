
class Reporte {
  final String titulo;
  final String descripcion;
  final String lugarDetalle;
  final bool esPerdido;
  final String autor;
  final String imagenUrl;
  final DateTime fecha;

  // 🧠 NLP
  final String tipoObjeto;

  Reporte({
    required this.titulo,
    required this.descripcion,
    required this.lugarDetalle,
    required this.esPerdido,
    required this.autor,
    required this.imagenUrl,
    required this.fecha,
    required this.tipoObjeto,
  });

  factory Reporte.fromJson(Map<String, dynamic> json) {
    return Reporte(
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      lugarDetalle: json['lugarDetalle'],
      esPerdido: json['esPerdido'],
      autor: json['autor'],
      imagenUrl: json['imagenUrl'] ?? '',
      tipoObjeto: json['tipoObjeto'] ?? 'otro',
      fecha: DateTime.parse(json['fecha']),
    );
  }
}
