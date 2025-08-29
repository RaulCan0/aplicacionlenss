class Evaluacion {
  final  String id;
  final String empresaId;
  final String puntosObtenidos;
  final DateTime fecha;
  final bool finalizada;

  Evaluacion({
    required this.id,
    required this.empresaId,
    required this.puntosObtenidos,
    required this.fecha,
    required this.finalizada,
  });

  factory Evaluacion.fromMap(Map<String, dynamic> m) => Evaluacion(
        id: m["id"].toString(),
        empresaId: m["empresa_id"].toString(),
        fecha: DateTime.parse(m["fecha"].toString()),
        finalizada: (m["finalizada"] ?? false) as bool,
        puntosObtenidos: (m["puntos_obtenidos"] ?? '') as String,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "empresa_id": empresaId,
        "fecha": fecha.toIso8601String(),
        "finalizada": finalizada,
      };
}
