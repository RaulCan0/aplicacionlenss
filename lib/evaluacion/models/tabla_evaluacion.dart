class FilaTablaEvaluacion {
  final String principio;
  final String comportamiento;

  // Ejecutivos
  final double? valorEjecutivos;
  final String? sistemasEjecutivos;
  final String? obsEjecutivos;

  // Gerentes
  final double? valorGerentes;
  final String? sistemasGerentes;
  final String? obsGerentes;

  // Miembro de equipo
  final double? valorMiembro;
  final String? sistemasMiembro;
  final String? obsMiembro;

  const FilaTablaEvaluacion({
    required this.principio,
    required this.comportamiento,
    this.valorEjecutivos,
    this.sistemasEjecutivos,
    this.obsEjecutivos,
    this.valorGerentes,
    this.sistemasGerentes,
    this.obsGerentes,
    this.valorMiembro,
    this.sistemasMiembro,
    this.obsMiembro,
  });

  FilaTablaEvaluacion copyWith({
    double? valorEjecutivos,
    String? sistemasEjecutivos,
    String? obsEjecutivos,
    double? valorGerentes,
    String? sistemasGerentes,
    String? obsGerentes,
    double? valorMiembro,
    String? sistemasMiembro,
    String? obsMiembro,
  }) {
    return FilaTablaEvaluacion(
      principio: principio,
      comportamiento: comportamiento,
      valorEjecutivos: valorEjecutivos ?? this.valorEjecutivos,
      sistemasEjecutivos: sistemasEjecutivos ?? this.sistemasEjecutivos,
      obsEjecutivos: obsEjecutivos ?? this.obsEjecutivos,
      valorGerentes: valorGerentes ?? this.valorGerentes,
      sistemasGerentes: sistemasGerentes ?? this.sistemasGerentes,
      obsGerentes: obsGerentes ?? this.obsGerentes,
      valorMiembro: valorMiembro ?? this.valorMiembro,
      sistemasMiembro: sistemasMiembro ?? this.sistemasMiembro,
      obsMiembro: obsMiembro ?? this.obsMiembro,
    );
  }
}