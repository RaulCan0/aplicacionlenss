import 'package:aplicacionlensys/evaluacion/models/tabla_evaluacion.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TablaEvaluacionService {
  final SupabaseClient _client;
  TablaEvaluacionService(this._client);

  // Usa EXACTAMENTE estos textos en tu DB
  static const cargoEjecutivos = 'Ejecutivos';
  static const cargoGerentes = 'Gerentes';
  static const cargoMiembro = 'Miembro de equipo';

  Future<List<FilaTablaEvaluacion>> getFilasParaTabla(String evaluacionId) async {
    final List<dynamic> rows = await _client
        .from('calificaciones')
        .select('principio,comportamiento,cargo,sistema,observacion,valor')
        .eq('id_evaluacion', evaluacionId)
        .order('principio')
        .order('comportamiento');

    final Map<String, FilaTablaEvaluacion> index = {};
    String keyRow(String p, String c) => '$p||$c';

    for (final r in rows) {
      final principio = (r['principio'] ?? '').toString();
      final comportamiento = (r['comportamiento'] ?? '').toString();
      final cargo = (r['cargo'] ?? '').toString();
      final sistema = (r['sistema'] ?? '').toString();
      final observacion = (r['observacion'] ?? '').toString();
      final double? valor = (r['valor'] is num)
          ? (r['valor'] as num).toDouble()
          : double.tryParse('${r['valor']}');

      if (principio.isEmpty || comportamiento.isEmpty || cargo.isEmpty) continue;

      final k = keyRow(principio, comportamiento);
      index.putIfAbsent(
        k,
        () => FilaTablaEvaluacion(principio: principio, comportamiento: comportamiento),
      );

      final actual = index[k]!;

      if (cargo == cargoEjecutivos) {
        index[k] = actual.copyWith(
          valorEjecutivos: valor ?? actual.valorEjecutivos,
          sistemasEjecutivos: sistema.isEmpty ? actual.sistemasEjecutivos : sistema,
          obsEjecutivos: observacion.isEmpty ? actual.obsEjecutivos : observacion,
        );
      } else if (cargo == cargoGerentes) {
        index[k] = actual.copyWith(
          valorGerentes: valor ?? actual.valorGerentes,
          sistemasGerentes: sistema.isEmpty ? actual.sistemasGerentes : sistema,
          obsGerentes: observacion.isEmpty ? actual.obsGerentes : observacion,
        );
      } else if (cargo == cargoMiembro) {
        index[k] = actual.copyWith(
          valorMiembro: valor ?? actual.valorMiembro,
          sistemasMiembro: sistema.isEmpty ? actual.sistemasMiembro : sistema,
          obsMiembro: observacion.isEmpty ? actual.obsMiembro : observacion,
        );
      } else {
        // Si te llegan otros cargos, decide aquí si los ignoras o los logueas.
      }
    }

    final result = index.values.toList()
      ..sort((a, b) {
        final cmpP = a.principio.compareTo(b.principio);
        if (cmpP != 0) return cmpP;
        return a.comportamiento.compareTo(b.comportamiento);
      });

    return result;
  }
}