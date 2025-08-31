class Progreso {
  final String id;
  final String empresaId;
  final String asociadoId;
  final String dimensionId;
  final String principio;
  final double avance;
  final DateTime? fecha;

  Progreso({
    required this.id,
    required this.empresaId,
    required this.asociadoId,
    required this.dimensionId,
    required this.principio,
    required this.avance,
    this.fecha,
  });
}
