
import 'package:aplicacionlensys/evaluacion/models/cargo.dart';
import 'package:aplicacionlensys/evaluacion/services/supabase_service.dart' hide Cargo;

class CalculoPromediosService {
  final SupabaseService supabase;

  CalculoPromediosService(this.supabase);

  /// Llama después de guardar una calificación
  Future<void> actualizarPromediosTrasCalificacion({
    required String evaluacionId,
    required String dimensionId,
  }) async {
    final asociados = await supabase.getAsociadosEvaluacion(evaluacionId);
    final calificaciones = await supabase.getCalificacionesEvaluacion(evaluacionId);

    final mapaTotales = {
      '1': {'1.1': 3, '1.2': 3},
      '2': {'2.1': 2, '2.2': 3, '2.3': 3, '2.4': 3, '2.5': 3},
      '3': {'3.1': 2, '3.2': 3, '3.3': 3},
    };

    final principios = mapaTotales[dimensionId]!;

    // Map<String (principio), Map<Cargo, List<int>>>
    final Map<String, Map<Cargo, List<int>>> agrupadosPrincipio = {};
    final Map<String, Map<Cargo, List<int>>> agrupadosComportamiento = {};

    for (final p in principios.entries) {
      final principioId = p.key;
      final totalComps = p.value;

      for (final cargo in Cargo.values) {
        agrupadosPrincipio.putIfAbsent(principioId, () => {});
        agrupadosPrincipio[principioId]![cargo] = [];

        for (int i = 1; i <= totalComps; i++) {
          final comportamientoId = '$principioId.$i';
          agrupadosComportamiento.putIfAbsent(comportamientoId, () => {});
          agrupadosComportamiento[comportamientoId]![cargo] = [];

          final califs = calificaciones.where((c) =>
            c.dimensionId == dimensionId &&
            c.principioId == principioId &&
            c.comportamientoId == comportamientoId &&
            asociados.any((a) => a.id == c.asociadoId && a.cargo == cargo.name));

          final valores = califs.map((c) => c.valor).toList();

          agrupadosComportamiento[comportamientoId]![cargo]!.addAll(valores as Iterable<int>);
          agrupadosPrincipio[principioId]![cargo]!.addAll(valores as Iterable<int>);
        }
      }
    }

    // Calcular y guardar promedios
    for (final principio in agrupadosPrincipio.entries) {
      final principioId = principio.key;
      for (final cargo in Cargo.values) {
        final valores = principio.value[cargo]!;
        final promedio = valores.isNotEmpty
            ? valores.reduce((a, b) => a + b) / valores.length
            : 0.0;

        await supabase.upsertPromedioPrincipio(
          evaluacionId: evaluacionId,
          dimensionId: dimensionId,
          principioId: principioId,
          cargo: cargo.name,
          promedio: promedio,
        );
      }
    }

    for (final comportamiento in agrupadosComportamiento.entries) {
      final comportamientoId = comportamiento.key;
      for (final cargo in Cargo.values) {
        final valores = comportamiento.value[cargo]!;
        final promedio = valores.isNotEmpty
            ? valores.reduce((a, b) => a + b) / valores.length
            : 0.0;

        await supabase.upsertPromedioComportamiento(
          evaluacionId: evaluacionId,
          dimensionId: dimensionId,
          comportamientoId: comportamientoId,
          cargo: cargo.name,
          promedio: promedio,
        );
      }
    }

    // Finalmente promedio por dimension y cargo
    for (final cargo in Cargo.values) {
      final valores = agrupadosPrincipio.values
          .map((mapa) => mapa[cargo]!)
          .expand((list) => list)
          .toList();

      final promedio = valores.isNotEmpty
          ? valores.reduce((a, b) => a + b) / valores.length
          : 0.0;

      await supabase.upsertPromedioDimension(
        evaluacionId: evaluacionId,
        dimensionId: dimensionId,
        cargo: cargo.name,
        promedio: promedio,
      );
    }
  }
}
