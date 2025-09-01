import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/empresa.dart';
import '../models/evaluacion.dart';
import '../models/asociado_evaluacion.dart';
import '../models/calificacion.dart';
import '../models/sistema_asociado.dart';
enum CargoEval { E, G, M } // E=Ejecutivo, G=Gerente, M=Miembro

// Enum para cargos
enum Cargo { ejecutivo, gerente, miembro }

class SupabaseService {
  // ======================= PROGRESOS =======================
  Future<double> obtenerProgresoDimension(String empresaId, String dimensionId) async {
    // Implementa la lógica real aquí según tu modelo y base de datos
    // Ejemplo: contar calificaciones por empresa y dimension, dividir entre el total esperado
    final response = await _client
        .from('calificaciones')
        .select()
        .eq('empresa_id', empresaId)
        .eq('dimension_id', dimensionId);
    final evaluados = (response as List).length;
    // Supón que el total esperado es 100 (ajusta según tu lógica)
    const totalEsperado = 100;
    return totalEsperado == 0 ? 0.0 : evaluados / totalEsperado;
  }

  Future<double> obtenerProgresoDimensionCargos(String empresaId, String dimensionId) async {
    // Implementa la lógica real aquí
    final response = await _client
        .from('calificaciones')
        .select()
        .eq('empresa_id', empresaId)
        .eq('dimension_id', dimensionId);
    final evaluados = (response as List).length;
    const totalEsperado = 100;
    return totalEsperado == 0 ? 0.0 : evaluados / totalEsperado;
  }

  Future<double> obtenerProgresoAsociado({
    required String evaluacionId,
    required String dimensionId,
    required String asociadoId,
  }) async {
    final response = await _client
        .from('calificaciones')
        .select()
        .eq('evaluacion_id', evaluacionId)
        .eq('dimension_id', dimensionId)
        .eq('asociado_id', asociadoId);
    final evaluados = (response as List).length;
    const totalEsperado = 100;
    return totalEsperado == 0 ? 0.0 : evaluados / totalEsperado;
  }

  Future<List<Calificacion>> getCalificacionesPorAsociado(String asociadoId) async {
    final response = await _client
        .from('calificaciones')
        .select()
        .eq('asociado_id', asociadoId);
    return (response as List).map((e) => Calificacion.fromMap(e)).toList();
  }

  Future<List<AsociadoEvaluacion>> getAsociadosPorEmpresa(String empresaId) async {
    final response = await _client
        .from('asociados_evaluacion')
        .select()
        .eq('empresa_id', empresaId);
    return (response as List).map((e) => AsociadoEvaluacion.fromMap(e)).toList();
  }
  // ======================= SISTEMAS ASOCIADOS =======================
  Future<List<SistemaAsociado>> getSistemasAsociados(String evaluacionId) async {
    final response = await _client.from('sistemas_asociados').select().eq('evaluacion_id', evaluacionId);
    return (response as List).map((e) => SistemaAsociado.fromJson(e)).toList();
  }

  Future<SistemaAsociado?> addSistemaAsociado(SistemaAsociado sistema) async {
    final response = await _client.from('sistemas_asociados').insert(sistema.toJson()).select().single();
    return SistemaAsociado.fromJson(response);
  }

  Future<void> updateSistemaAsociado(SistemaAsociado sistema) async {
    await _client.from('sistemas_asociados').update(sistema.toJson()).eq('id', sistema.id);
  }

  Future<void> deleteSistemaAsociado(int id) async {
    await _client.from('sistemas_asociados').delete().eq('id', id);
  }
  final SupabaseClient _client = Supabase.instance.client;

  // ======================= EMPRESAS =======================
  Future<List<Empresa>> getEmpresas() async {
    final response = await _client.from('empresas').select();
    return (response as List).map((e) => Empresa.fromMap(e)).toList();
  }

  Future<Empresa?> addEmpresa(Empresa empresa) async {
    final response = await _client.from('empresas').insert(empresa.toMap()).select().single();
    return Empresa.fromMap(response);
  }

  Future<void> updateEmpresa(Empresa empresa) async {
    await _client.from('empresas').update(empresa.toMap()).eq('id', empresa.id);
  }

  Future<void> deleteEmpresa(String id) async {
    await _client.from('empresas').delete().eq('id', id);
  }

  // ======================= EVALUACIONES =======================
  Future<List<Evaluacion>> getEvaluaciones(String empresaId) async {
    final response = await _client.from('evaluaciones').select().eq('empresa_id', empresaId);
    return (response as List).map((e) => Evaluacion.fromMap(e)).toList();
  }

  Future<Evaluacion?> addEvaluacion(Evaluacion evaluacion) async {
    final response = await _client.from('evaluaciones').insert(evaluacion.toMap()).select().single();
    return Evaluacion.fromMap(response);
  }

  Future<void> updateEvaluacion(Evaluacion evaluacion) async {
    await _client.from('evaluaciones').update(evaluacion.toMap()).eq('id', evaluacion.id);
  }

  Future<void> deleteEvaluacion(String id) async {
    await _client.from('evaluaciones').delete().eq('id', id);
  }

  // ======================= ASOCIADOS =======================
  Future<List<AsociadoEvaluacion>> getAsociadosEvaluacion(String evaluacionId) async {
    final response = await _client.from('asociado_evaluacion').select().eq('evaluacion_id', evaluacionId);
    return (response as List).map((e) => AsociadoEvaluacion.fromMap(e)).toList();
  }

  Future<AsociadoEvaluacion?> addAsociado(AsociadoEvaluacion asociado) async {
    final response = await _client.from('asociado_evaluacion').insert(asociado.toMap()).select().single();
    return AsociadoEvaluacion.fromMap(response);
  }

  Future<void> updateAsociado(AsociadoEvaluacion asociado) async {
    await _client.from('asociado_evaluacion').update(asociado.toMap()).eq('id', asociado.id);
  }

  Future<void> deleteAsociado(String id) async {
    await _client.from('asociado_evaluacion').delete().eq('id', id);
  }

  // ======================= CALIFICACIONES =======================
  Future<List<Calificacion>> getCalificacionesEvaluacion(String evaluacionId) async {
    final response = await _client.from('calificaciones').select().eq('evaluacion_id', evaluacionId);
    return (response as List).map((e) => Calificacion.fromMap(e)).toList();
  }

  Future<Calificacion?> addCalificacion(Calificacion calificacion) async {
    final response = await _client.from('calificaciones').insert(calificacion.toMap()).select().single();
    return Calificacion.fromMap(response);
  }

  Future<void> updateCalificacion(Calificacion calificacion) async {
    await _client.from('calificaciones').update(calificacion.toMap()).eq('id', calificacion.id);
  }

  Future<void> deleteCalificacion(String id) async {
    await _client.from('calificaciones').delete().eq('id', id);
  }

  // ======================= PROMEDIOS =======================
  Future<void> upsertPromedioPrincipio({
    required String evaluacionId,
    required String dimensionId,
    required String principioId,
    required String cargo,
    required double promedio,
  }) async {
    await _client.from('promedios_principio').upsert({
      'evaluacion_id': evaluacionId,
      'dimension_id': dimensionId,
      'principio_id': principioId,
      'cargo': cargo,
      'promedio': promedio,
    }).select();
  }

  Future<void> upsertPromedioComportamiento({
    required String evaluacionId,
    required String dimensionId,
    required String comportamientoId,
    required String cargo,
    required double promedio,
  }) async {
    await _client.from('promedios_comportamiento').upsert({
      'evaluacion_id': evaluacionId,
      'dimension_id': dimensionId,
      'comportamiento_id': comportamientoId,
      'cargo': cargo,
      'promedio': promedio,
    }).select();
  }

  Future<void> upsertPromedioDimension({
    required String evaluacionId,
    required String dimensionId,
    required String cargo,
    required double promedio,
  }) async {
    await _client.from('promedios_dimension').upsert({
      'evaluacion_id': evaluacionId,
      'dimension_id': dimensionId,
      'cargo': cargo,
      'promedio': promedio,
    }).select();
  }
}

// Servicio para cálculo de promedios
class CalculoPromediosService {
  final SupabaseService supabase;

  CalculoPromediosService(this.supabase);

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

    final Map<String, Map<Cargo, List<double>>> agrupadosPrincipio = {};
    final Map<String, Map<Cargo, List<double>>> agrupadosComportamiento = {};

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

          final valores = califs.map((c) => c.valor.toDouble()).toList();

          agrupadosComportamiento[comportamientoId]![cargo]!.addAll(valores);
          agrupadosPrincipio[principioId]![cargo]!.addAll(valores);
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
  // ======================= SISTEMAS ASOCIADOS =======================
  Future<List<SistemaAsociado>> getSistemasAsociados(String evaluacionId) async {
    final response = await supabase._client.from('sistemas_asociado').select().eq('evaluacion_id', evaluacionId);
    return (response as List).map((e) => SistemaAsociado.fromJson(e)).toList();
  }

  Future<SistemaAsociado?> addSistemaAsociado(SistemaAsociado sistema) async {
    final response = await supabase._client.from('sistemas_asociado').insert(sistema.toJson()).select().single();
    return SistemaAsociado.fromJson(response);
  }

  Future<void> updateSistemaAsociado(SistemaAsociado sistema) async {
    await supabase._client.from('sistemas_asociado').update(sistema.toJson()).eq('id', sistema.id);
  }

  Future<void> deleteSistemaAsociado(String id) async {
    await supabase._client.from('sistemas_asociado').delete().eq('id', id);
  }
}

extension SupabaseServicePerfilExtension on SupabaseService {
  // PERFIL
  Future<Map<String, dynamic>?> getPerfil() async {
    final user = _client.auth.currentUser;
      if (user == null) return null;
  
      final response =
          await _client.from('usuarios').select().eq('id', user.id).single();
      return response;
    }
  
    Future<void> actualizarPerfil(Map<String, dynamic> valores) async {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception("Usuario no autenticado");
  
      await _client.from('usuarios').update(valores).eq('id', userId);
    }
  
    Future<void> actualizarContrasena({required String newPassword}) async {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    }
  
    Future<String> subirFotoPerfil(String rutaLocal) async {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception("Usuario no autenticado");
  
      final archivo = File(rutaLocal);
      final fileName = archivo.uri.pathSegments.last;
      final storagePath = '$userId/$fileName';
  
      await _client.storage
          .from('perfil')
          .upload(
            storagePath,
            archivo,
            fileOptions: const FileOptions(upsert: true),
          );
  
      final publicUrl = _client.storage.from('perfil').getPublicUrl(storagePath);
  
      // Guarda la URL en la tabla usuarios
      await _client.from('usuarios').update({'foto_url': publicUrl}).eq('id', userId);
  
      return publicUrl;
    }
  }
Future<String> ensureEvaluacionId(
  SupabaseService supabaseService, {
  required String empresaId,
  String? empresaNombre,
}) async {
  // Reutiliza la evaluación activa si existe
  final existing = await supabaseService._client
      .from('evaluacion')
      .select('id')
      .eq('empresa_id', empresaId)
      .eq('finalizada', false)
      .order('fecha', ascending: false)
      .limit(1)
      .maybeSingle();

  if (existing != null) {
    return existing['id'] as String;
  }

  // Crea una nueva evaluación si no hay activa
  final nueva = await supabaseService._client.from('evaluacion').insert({
    'empresa_id': empresaId,
    'empresa_nombre': empresaNombre,
    'fecha': DateTime.now().toIso8601String(),
    'finalizada': false,
  }).select('id').single();

  return nueva['id'] as String;
}