class Dimension4 {
  final String id;
  final String evaluacionId;
  final String nombre;
  final double pesoPct; // 0..100
  final double rating; // 0..5

  Dimension4({
    required this.id,
    required this.evaluacionId,
    required this.nombre,
    required this.pesoPct,
    required this.rating,
  });

  factory Dimension4.fromMap(Map<String, dynamic> m) => Dimension4(
        id: m["id"].toString(),
        evaluacionId: m["evaluacion_id"].toString(),
        nombre: m["nombre"] ?? "",
        pesoPct: (m["peso_pct"] as num).toDouble(),
        rating: (m["rating"] as num).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "evaluacion_id": evaluacionId,
        "nombre": nombre,
        "peso_pct": pesoPct,
        "rating": rating,
      };
}
