import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

enum Cargo { ejec, gto, mbr }

Cargo? cargoFromString(String s) {
  final v = s.toLowerCase();
  if (v.contains('ejec')) return Cargo.ejec;
  if (v.contains('geren') || v == 'ger') return Cargo.gto;
  if (v.contains('miembr') || v.contains('equipo')) return Cargo.mbr;
  return null;
}

class BenchmarkItem {
  final String dimId, principio, comportamiento, benchmarkPorCargo, guia;
  final Cargo cargo;
  final Map<String, String> c1c5;
  BenchmarkItem({
    required this.dimId,
    required this.principio,
    required this.comportamiento,
    required this.cargo,
    required this.benchmarkPorCargo,
    required this.guia,
    required this.c1c5,
  });
}

class BenchmarkLoader {
  static Future<List<BenchmarkItem>> loadAll({
    required String t1,
    required String t2,
    required String t3,
  }) async => [
    ...await _one(t1, 'D1'),
    ...await _one(t2, 'D2'),
    ...await _one(t3, 'D3'),
  ];

  static Future<List<BenchmarkItem>> _one(String asset, String dim) async {
    final raw = await rootBundle.loadString(asset);
    final arr = json.decode(raw) as List;
    return arr
        .map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          final cg = cargoFromString(m['NIVEL']?.toString() ?? '');
          if (cg == null) return null;
          final mC = <String, String>{};
          for (final k in ['C1', 'C2', 'C3', 'C4', 'C5']) {
            final v = m[k];
            if (v != null && v.toString().trim().isNotEmpty) {
              mC[k] = v.toString();
            }
          }
          return BenchmarkItem(
            dimId: dim,
            principio: m['PRINCIPIOS']?.toString() ?? '',
            comportamiento: m['BENCHMARK DE COMPORTAMIENTOS']?.toString() ?? '',
            cargo: cg,
            benchmarkPorCargo: m['BENCHMARK POR NIVEL']?.toString() ?? '',
            guia: m['GUÍA DE PREGUNTAS']?.toString() ?? '',
            c1c5: mC,
          );
        })
        .where((x) => x != null)
        .cast<BenchmarkItem>()
        .toList();
  }

  static BenchmarkItem? find({
    required List<BenchmarkItem> items,
    required String dimId,
    required String principio,
    required String comportamiento,
    required Cargo cargo,
  }) {
    final p = principio.toLowerCase(), c = comportamiento.toLowerCase();
    for (final it in items) {
      if (it.dimId != dimId) continue;
      if (it.cargo != cargo) continue;
      if (it.principio.toLowerCase().contains(p) &&
          it.comportamiento.toLowerCase().contains(c)) {
        return it;
      }
    }
    return null;
  }
}
