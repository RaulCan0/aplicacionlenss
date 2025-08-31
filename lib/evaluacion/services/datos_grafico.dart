
// Servicio para alimentar los gráficos
import 'package:aplicacionlensys/evaluacion/models/calificacion.dart';
import 'package:aplicacionlensys/evaluacion/services/supabase_service.dart';

class DatosGraficosService {
  final SupabaseService supabaseService;

  DatosGraficosService({SupabaseService? supabaseService})
      : supabaseService = supabaseService ?? SupabaseService();

  Future<Map<String, double>> getPromedioPorComportamiento(String evaluacionId) async {
    final calificaciones = await supabaseService.getCalificacionesEvaluacion(evaluacionId);
    final Map<String, List<Calificacion>> porComportamiento = {};

    for (final cal in calificaciones) {
      porComportamiento.putIfAbsent(cal.comportamientoId, () => []).add(cal);
    }

    return porComportamiento.map((id, cal) =>
        MapEntry(id, _promedio(cal)));
  }

  Future<Map<String, double>> getPromedioPorPrincipio(String evaluacionId) async {
    final calificaciones = await supabaseService.getCalificacionesEvaluacion(evaluacionId);
    final Map<String, List<Calificacion>> porPrincipio = {};

    for (final cal in calificaciones) {
      porPrincipio.putIfAbsent(cal.principioId, () => []).add(cal);
    }

    return porPrincipio.map((id, cal) =>
        MapEntry(id, _promedio(cal)));
  }

  Future<Map<String, double>> getPromedioPorDimension(String evaluacionId) async {
    final calificaciones = await supabaseService.getCalificacionesEvaluacion(evaluacionId);
    final Map<String, List<Calificacion>> porDimension = {};

    for (final cal in calificaciones) {
      porDimension.putIfAbsent(cal.dimensionId, () => []).add(cal);
    }

    return porDimension.map((id, cal) =>
        MapEntry(id, _promedio(cal)));
  }

  Future<Map<String, double>> getPromedioPorSistema(String evaluacionId) async {
    final calificaciones = await supabaseService.getCalificacionesEvaluacion(evaluacionId);
    final Map<String, List<Calificacion>> porSistema = {};

    for (final cal in calificaciones) {
      if (cal.getSistemasAsociados != null) {
        porSistema.putIfAbsent(cal.getSistemasAsociados.toString(), () => []).add(cal);
      }
    }

    return porSistema.map((sistema, cal) =>
        MapEntry(sistema, _promedio(cal)));
  }

  double _promedio(List<Calificacion> calificaciones) {
    if (calificaciones.isEmpty) return 0.0;
    return calificaciones.map((c) => c.valor.toDouble()).reduce((a, b) => a + b) / calificaciones.length;
  }
}