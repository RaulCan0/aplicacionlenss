import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/empresa.dart';
import '../models/evaluacion.dart';
import '../models/asociado_evaluacion.dart';
import '../models/calificacion.dart';
import '../models/sistema_asociado.dart';
import '../models/dimension4.dart';

import '../services/supabase_service.dart';

/// ======================= STATE =======================

@immutable
class EvaluacionState {
  final List<Empresa> empresas;
  final List<Evaluacion> evaluaciones;
  final List<AsociadoEvaluacion> asociados;
  final List<Calificacion> calificaciones;
  final List<SistemaAsociado> sistemas;
  final List<Dimension4> categoriasD4;

  /// evalId -> set(principioId)
  final Map<String, Set<String>> principiosEvaluados;

  const EvaluacionState({
    this.empresas = const [],
    this.evaluaciones = const [],
    this.asociados = const [],
    this.calificaciones = const [],
    this.sistemas = const [],
    this.categoriasD4 = const [],
    this.principiosEvaluados = const {},
  });

  EvaluacionState copyWith({
    List<Empresa>? empresas,
    List<Evaluacion>? evaluaciones,
    List<AsociadoEvaluacion>? asociados,
    List<Calificacion>? calificaciones,
    List<SistemaAsociado>? sistemas,
    List<Dimension4>? categoriasD4,
    Map<String, Set<String>>? principiosEvaluados,
  }) {
    return EvaluacionState(
      empresas: empresas ?? this.empresas,
      evaluaciones: evaluaciones ?? this.evaluaciones,
      asociados: asociados ?? this.asociados,
      calificaciones: calificaciones ?? this.calificaciones,
      sistemas: sistemas ?? this.sistemas,
      categoriasD4: categoriasD4 ?? this.categoriasD4,
      principiosEvaluados: principiosEvaluados ?? this.principiosEvaluados,
    );
  }
}

/// =================== CONTROLLER ======================

class EvaluacionController extends StateNotifier<EvaluacionState> {
  final SupabaseService _service = SupabaseService();

  EvaluacionController() : super(const EvaluacionState());

  /// ---------- Empresas ----------
  Future<void> cargarEmpresas() async {
    final empresas = await _service.getEmpresas();
    state = state.copyWith(empresas: empresas);
  }

  Future<void> agregarEmpresa(Empresa empresa) async {
    final nueva = await _service.addEmpresa(empresa);
    if (nueva != null) {
      state = state.copyWith(empresas: [...state.empresas, nueva]);
    }
  }

  Future<void> actualizarEmpresa(Empresa empresa) async {
    await _service.updateEmpresa(empresa);
    final next = state.empresas.map((e) => e.id == empresa.id ? empresa : e).toList();
    state = state.copyWith(empresas: next);
  }

  Future<void> eliminarEmpresa(String id) async {
    await _service.deleteEmpresa(id);
    state = state.copyWith(
      empresas: state.empresas.where((e) => e.id != id).toList(),
      evaluaciones: state.evaluaciones.where((ev) => ev.empresaId != id).toList(),
    );
  }

  /// ---------- Evaluaciones ----------
  Future<void> cargarEvaluaciones(String empresaId) async {
    final evaluaciones = await _service.getEvaluaciones(empresaId);
    state = state.copyWith(evaluaciones: evaluaciones);
  }

  Future<void> agregarEvaluacion(Evaluacion evaluacion) async {
    final nueva = await _service.addEvaluacion(evaluacion);
    if (nueva != null) {
      state = state.copyWith(evaluaciones: [...state.evaluaciones, nueva]);
    }
  }

  Future<void> actualizarEvaluacion(Evaluacion evaluacion) async {
    await _service.updateEvaluacion(evaluacion);
    final next = state.evaluaciones.map((e) => e.id == evaluacion.id ? evaluacion : e).toList();
    state = state.copyWith(evaluaciones: next);
  }

  Future<void> eliminarEvaluacion(String id) async {
    await _service.deleteEvaluacion(id);
    state = state.copyWith(
      evaluaciones: state.evaluaciones.where((ev) => ev.id != id).toList(),
      asociados: state.asociados.where((a) => a.evaluacionId != id).toList(),
      calificaciones: state.calificaciones.where((c) => c.evaluacionId != id).toList(),
    );
  }

  /// ---------- Asociados ----------
  Future<void> cargarAsociados(String evaluacionId) async {
    final asociados = await _service.getAsociadosEvaluacion(evaluacionId);
    state = state.copyWith(asociados: asociados);
  }

  Future<void> agregarAsociado(AsociadoEvaluacion asociado) async {
    final nuevo = await _service.addAsociado(asociado);
    if (nuevo != null) {
      state = state.copyWith(asociados: [...state.asociados, nuevo]);
    }
  }

  Future<void> actualizarAsociado(AsociadoEvaluacion asociado) async {
    await _service.updateAsociado(asociado);
    final next = state.asociados.map((a) => a.id == asociado.id ? asociado : a).toList();
    state = state.copyWith(asociados: next);
  }

  Future<void> eliminarAsociado(String id) async {
    await _service.deleteAsociado(id);
    state = state.copyWith(asociados: state.asociados.where((a) => a.id != id).toList());
  }

  /// ---------- Calificaciones ----------
  Future<void> cargarCalificaciones(String evaluacionId) async {
    final calificaciones = await _service.getCalificacionesEvaluacion(evaluacionId);
    state = state.copyWith(calificaciones: calificaciones);
  }

  Future<void> agregarCalificacion(Calificacion calificacion) async {
    final nueva = await _service.addCalificacion(calificacion);
    if (nueva != null) {
      state = state.copyWith(calificaciones: [...state.calificaciones, nueva]);
    }
  }

  Future<void> actualizarCalificacion(Calificacion calificacion) async {
    await _service.updateCalificacion(calificacion);
    final next = state.calificaciones.map((c) => c.id == calificacion.id ? calificacion : c).toList();
    state = state.copyWith(calificaciones: next);
  }

  Future<void> eliminarCalificacion(String id) async {
    await _service.deleteCalificacion(id);
    state = state.copyWith(calificaciones: state.calificaciones.where((c) => c.id != id).toList());
  }

  /// ---------- Sistemas Asociados ----------
   // ======================= SISTEMAS ASOCIADOS =======================
    Future<void> cargarSistemasAsociados(String evaluacionId) async {
      final sistemas = await _service.getSistemasAsociados(evaluacionId);
      state = state.copyWith(sistemas: sistemas);
    }

  /// ---------- Dimension 4 ----------
  void cargarCategoriasD4(List<Dimension4> categorias) {
    state = state.copyWith(categoriasD4: categorias);
  }
}

/// =================== PROVIDER ========================

final evaluacionProvider =
    StateNotifierProvider<EvaluacionController, EvaluacionState>((ref) {
  return EvaluacionController();
});
