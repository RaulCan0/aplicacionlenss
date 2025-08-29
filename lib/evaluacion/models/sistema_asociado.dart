class SistemaAsociado {
  final String id;
  final String nombre;

  SistemaAsociado({required this.id, required this.nombre});

  factory SistemaAsociado.fromMap(Map<String, dynamic> m) => SistemaAsociado(
        id: m["id"].toString(),
        nombre: m["nombre"] ?? "",
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "nombre": nombre,
      };
}
