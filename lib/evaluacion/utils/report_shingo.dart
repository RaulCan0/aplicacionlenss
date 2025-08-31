import 'dart:convert';
import 'package:aplicacionlensys/evaluacion/screens/resultados_d4_screen.dart';
import 'package:flutter/material.dart';

class ReportShingoScreen extends StatelessWidget {
  final List<CategoriaD4> categorias;
  const ReportShingoScreen({super.key, required this.categorias});

  int _total(List<CategoriaD4> cats) {
    var t = 0;
    for (final c in cats) {
      for (final s in c.subcategorias) {
        t += s.valor;
      }
    }
    return t;
  }

  int _max(List<CategoriaD4> cats) {
    var m = 0;
    for (final c in cats) {
      m += (c.subcategorias.length * 5);
    }
    return m;
  }

  int _d4(List<CategoriaD4> cats) {
    final m = _max(cats);
    if (m == 0) return 0;
    return ((_total(cats) / m) * 200).round();
  }

  String _toJson(List<CategoriaD4> cats) {
    final data = [
      for (final c in cats)
        {
          'categoria': c.nombre,
          'subcategorias': [
            for (final s in c.subcategorias) {'nombre': s.nombre, 'valor': s.valor}
          ],
          'subtotal': c.subcategorias.fold<int>(0, (a, b) => a + b.valor),
          'max': c.subcategorias.length * 5,
        }
    ];
    return const JsonEncoder.withIndent('  ').convert({
      'categorias': data,
      'total': _total(cats),
      'maximo': _max(cats),
      'd4_0_200': _d4(cats),
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _total(categorias);
    final max = _max(categorias);
    final d4 = _d4(categorias);
    return Scaffold(
      appBar: AppBar(title: const Text('Reporte Shingo (D4)')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16, runSpacing: 8,
              children: [
                Chip(label: Text('Total: $total')),
                Chip(label: Text('Máximo: $max')),
                Chip(label: Text('D4 (0..200): $d4')),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: categorias.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final c = categorias[i];
                  final subtotal = c.subcategorias.fold<int>(0, (a, b) => a + b.valor);
                  final cmax = c.subcategorias.length * 5;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ...c.subcategorias.map((s) => Row(
                                children: [
                                  Expanded(child: Text('• ${s.nombre}')),
                                  Text('${s.valor} / 5'),
                                ],
                              )),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal'),
                              Text('$subtotal / $cmax'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () async {
                final jsonStr = _toJson(categorias);
                await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('JSON del Reporte'),
                    content: SingleChildScrollView(child: Text(jsonStr)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.code),
              label: const Text('Ver JSON'),
            ),
          ],
        ),
      ),
    );
  }
}
