class Calificacion {
  final String id;
  final String evaluacionId;
  final String comportamientoId;
  final String dimensionId;
  final String principioId;
  final String? asociadoId;
  final String? cargo; // ejec | gto | mbr
  final double valor; // 0..5
  final String? observaciones;
  final List<String>? getSistemasAsociados;
  final List<String>? evidencias; // urls
  final DateTime updatedAt;

  Calificacion({
    required this.id,
    required this.evaluacionId,
    required this.comportamientoId,
    required this.dimensionId,
    required this.principioId,
    this.asociadoId,
    this.cargo,
    required this.valor,
    this.observaciones,
    this.getSistemasAsociados,
    this.evidencias,
    required this.updatedAt,
  });

  factory Calificacion.fromMap(Map<String, dynamic> m) => Calificacion(
        id: m["id"].toString(),
        evaluacionId: m["evaluacion_id"].toString(),
        comportamientoId: m["comportamiento_id"].toString(),
        dimensionId: m["dimension_id"].toString(),
        principioId: m["principio_id"].toString(),
        asociadoId: m["asociado_id"]?.toString(),
        cargo: m["cargo"]?.toString(),
        valor: (m["valor"] as num).toDouble(),
        observaciones: m["observaciones"],
        getSistemasAsociados: (m["sistemas"] as List?)?.map((e) => e.toString()).toList(),
        evidencias: (m["evidencias"] as List?)?.map((e) => e.toString()).toList(),
        updatedAt: DateTime.parse(m["updated_at"].toString()),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "evaluacion_id": evaluacionId,
        "comportamiento_id": comportamientoId,
        "dimension_id": dimensionId,
        "principio_id": principioId,
        "asociado_id": asociadoId,
        "cargo": cargo,
        "valor": valor,
        "observaciones": observaciones,
        "sistemas": getSistemasAsociados,
        "evidencias": evidencias,
        "updated_at": updatedAt.toIso8601String(),
      };
}
