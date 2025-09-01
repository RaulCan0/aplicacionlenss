import 'package:supabase_flutter/supabase_flutter.dart';

class EvaluacionIdService {
  final SupabaseClient _client = Supabase.instance.client;

  EvaluacionIdService();

  Future<String> ensureEvaluacionId({
    required String empresaId,
    String? empresaNombre,
  }) async {
    // Reutiliza la evaluación activa si existe
    final existing = await _client
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
    final nueva = await _client.from('evaluacion').insert({
      'empresa_id': empresaId,
      'empresa_nombre': empresaNombre,
      'fecha': DateTime.now().toIso8601String(),
      'finalizada': false,
    }).select('id').single();

    return nueva['id'] as String;
  }
}
