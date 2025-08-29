class AsociadoEvaluacion {
  final String id;
  final String evaluacionId;
  final String nombreCompleto;
  final String? antiguedad; // ej: "4 años"
  final String? cargo; // ejec | gto | mbr
  final String? puesto;

  AsociadoEvaluacion({
    required this.id,
    required this.evaluacionId,
    required this.nombreCompleto,
    this.antiguedad,
    this.cargo,
    this.puesto,
  });

  factory AsociadoEvaluacion.fromMap(Map<String, dynamic> m) =>
      AsociadoEvaluacion(
        id: m["id"].toString(),
        evaluacionId: m["evaluacion_id"].toString(),
        nombreCompleto: m["nombre_completo"] ?? "",
        antiguedad: m["antiguedad"],
        cargo: m["cargo"],
        puesto: m["puesto"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "evaluacion_id": evaluacionId,
        "nombre_completo": nombreCompleto,
        "antiguedad": antiguedad,
        "cargo": cargo,
        "puesto": puesto,
      };
}
