class Empresa {
  final String id;
  final String nombre;
  final String? tamano;
  final int? empleadosTotales;
  final String? sector;
  final List<String>? unidadesNegocio;
  final List<String>? areas;

  Empresa({
    required this.id,
    required this.nombre,
    this.tamano,
    this.empleadosTotales,
    this.sector,
    this.unidadesNegocio,
    this.areas,
  });

  factory Empresa.fromMap(Map<String, dynamic> m) => Empresa(
        id: m["id"].toString(),
        nombre: m["nombre"] ?? "",
        tamano: m["tamano"],
        empleadosTotales: m["empleados_totales"],
        sector: m["sector"],
        unidadesNegocio:
            (m["unidades_negocio"] as List?)?.map((e) => e.toString()).toList(),
        areas: (m["areas"] as List?)?.map((e) => e.toString()).toList(),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "nombre": nombre,
        "tamano": tamano,
        "empleados_totales": empleadosTotales,
        "sector": sector,
        "unidades_negocio": unidadesNegocio,
        "areas": areas,
      };
}
