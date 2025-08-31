import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class EstructuraService {
  static Map<String, dynamic>? _cache;

  static Future<Map<String, dynamic>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/estructura.json');
    _cache = json.decode(raw) as Map<String, dynamic>;
    return _cache!;
  }

  static Future<List<dynamic>> dimensiones() async {
    final data = await load();
    return (data['dimensiones'] as List?) ?? [];
  }

  static Future<Map<String, dynamic>?> dimensionById(String id) async {
    final dims = await dimensiones();
    return dims.cast<Map<String, dynamic>?>().firstWhere(
      (d) => d?['id']?.toString() == id,
      orElse: () => null,
    );
  }
}
