class Calificacion {
  final String id;
  final String evaluacionId;
  final String comportamientoId;
  final String? asociadoId;
  final String? cargo; // ejec | gto | mbr
  final double valor; // 0..5
  final String? observaciones;
  final List<String>? sistemas;
  final List<String>? evidencias; // urls
  final DateTime updatedAt;

  Calificacion({
    required this.id,
    required this.evaluacionId,
    required this.comportamientoId,
    this.asociadoId,
    this.cargo,
    required this.valor,
    this.observaciones,
    this.sistemas,
    this.evidencias,
    required this.updatedAt,
  });

  factory Calificacion.fromMap(Map<String, dynamic> m) => Calificacion(
        id: m["id"].toString(),
        evaluacionId: m["evaluacion_id"].toString(),
        comportamientoId: m["comportamiento_id"].toString(),
        asociadoId: m["asociado_id"]?.toString(),
        cargo: m["cargo"]?.toString(),
        valor: (m["valor"] as num).toDouble(),
        observaciones: m["observaciones"],
        sistemas: (m["sistemas"] as List?)?.map((e) => e.toString()).toList(),
        evidencias: (m["evidencias"] as List?)?.map((e) => e.toString()).toList(),
        updatedAt: DateTime.parse(m["updated_at"].toString()),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "evaluacion_id": evaluacionId,
        "comportamiento_id": comportamientoId,
        "asociado_id": asociadoId,
        "cargo": cargo,
        "valor": valor,
        "observaciones": observaciones,
        "sistemas": sistemas,
        "evidencias": evidencias,
        "updated_at": updatedAt.toIso8601String(),
      };
}
