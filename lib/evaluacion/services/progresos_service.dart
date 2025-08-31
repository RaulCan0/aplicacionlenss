import 'package:aplicacionlensys/evaluacion/models/progreso.dart';
import 'package:aplicacionlensys/evaluacion/services/supabase_service.dart';

/// Servicio centralizado para el cálculo de progreso de dimensiones, asociados y principios.
/// Todos los métodos retornan valores normalizados [0.0-1.0].
class ProgresosService {
  final SupabaseService _supabaseService;

  /// Permite inyección para pruebas unitarias y mocks.
  ProgresosService({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService();

  /// Devuelve solo el valor [0.0 - 1.0] del progreso de una dimensión
  Future<double> progresoDimension({
    required String empresaId,
    required String dimensionId,
  }) async {
    try {
      final avance = await _supabaseService.obtenerProgresoDimension(empresaId, dimensionId);
      return avance;
    } catch (e) {
      rethrow; // Puedes también retornar 0.0 si prefieres manejarlo internamente
    }
  }

  /// Devuelve un objeto `Progreso` para una dimensión específica
  Future<Progreso> getProgresoDimension({
    required String empresaId,
    required String dimensionId,
  }) async {
    final avance = await _supabaseService.obtenerProgresoDimension(empresaId, dimensionId);
    return Progreso(
      id: '$empresaId-$dimensionId',
      empresaId: empresaId,
      asociadoId: '',
      dimensionId: dimensionId,
      principio: '',
      avance: avance,
      fecha: DateTime.now(),
    );
  }

  /// Progreso individual de un asociado en una dimensión
  Future<Progreso> getProgresoAsociado({
    required String evaluacionId,
    required String asociadoId,
    required String dimensionId,
  }) async {
    final avance = await _supabaseService.obtenerProgresoAsociado(
      evaluacionId: evaluacionId,
      dimensionId: dimensionId,
      asociadoId: asociadoId,
    );
    return Progreso(
      id: '$asociadoId-$dimensionId',
      empresaId: '',
      asociadoId: asociadoId,
      dimensionId: dimensionId,
      principio: '',
      avance: avance,
      fecha: DateTime.now(),
    );
  }

  /// Progreso de un principio específico (proporción de comportamientos evaluados)
  Progreso getProgresoPrincipio({
    required String asociadoId,
    required String dimensionId,
    required String principio,
    required int totalComportamientos,
    required int comportamientosEvaluados,
  }) {
    final avance = totalComportamientos == 0
        ? 0.0
        : (comportamientosEvaluados / totalComportamientos).clamp(0.0, 1.0);

    return Progreso(
      id: '$asociadoId-$dimensionId-$principio',
      empresaId: '',
      asociadoId: asociadoId,
      dimensionId: dimensionId,
      principio: principio,
      avance: avance,
      fecha: DateTime.now(),
    );
  }

  /// Calcula el progreso de todos los principios para un asociado
  Future<List<Progreso>> getProgresosPrincipiosDeAsociado({
    required String asociadoId,
    required String dimensionId,
    required List<String> nombresPrincipios,
    required Map<String, List<String>> comportamientosPorPrincipio,
  }) async {
    final calificaciones = await _supabaseService.getCalificacionesPorAsociado(asociadoId);
    final List<Progreso> progresos = [];

    for (final principio in nombresPrincipios) {
      final total = comportamientosPorPrincipio[principio]?.length ?? 0;
      final evaluados = calificaciones.where(
        (c) => comportamientosPorPrincipio[principio]?.contains(c.id) ?? false,
      ).length;

      progresos.add(getProgresoPrincipio(
        asociadoId: asociadoId,
        dimensionId: dimensionId,
        principio: principio,
        totalComportamientos: total,
        comportamientosEvaluados: evaluados,
      ));
    }

    return progresos;
  }

  /// Promedio de progreso de todas las dimensiones de una empresa
  Future<double> getProgresoGlobalEmpresa(String empresaId) async {
    final dimensiones = ['1', '2', '3', '4']; // Puedes adaptar esto
    double suma = 0.0;

    for (final dim in dimensiones) {
      final progreso = await _supabaseService.obtenerProgresoDimension(empresaId, dim);
      suma += progreso;
    }

    return (suma / dimensiones.length).clamp(0.0, 1.0);
  }

  /// Progreso por asociado de una dimensión específica
  Future<List<Progreso>> getProgresosAsociadosEmpresa(String empresaId, String dimensionId) async {
    final asociados = await _supabaseService.getAsociadosPorEmpresa(empresaId);
    final List<Progreso> progresos = [];

    for (final asociado in asociados) {
      progresos.add(await getProgresoAsociado(
        evaluacionId: empresaId,
        asociadoId: asociado.id,
        dimensionId: dimensionId,
      ));
    }

    return progresos;
  }
}
