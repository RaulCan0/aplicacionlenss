import 'package:aplicacionlensys/evaluacion/utils/report_shingo.dart';
import 'package:flutter/material.dart';
import '../widgets/shingo_hojas.dart'; // ShingoResultData + HojaShingoWidget

class CategoriaD4 {
  String nombre;
  List<SubcategoriaD4> subcategorias;
  CategoriaD4({required this.nombre, required this.subcategorias});
}

class SubcategoriaD4 {
  String nombre;
  int valor; // 0..5
  SubcategoriaD4({required this.nombre, this.valor = 0});
}

class ResultadosD4Screen extends StatefulWidget {
  const ResultadosD4Screen({super.key});

  @override
  State<ResultadosD4Screen> createState() => _ResultadosD4ScreenState();
}

class _ResultadosD4ScreenState extends State<ResultadosD4Screen> {
  static const List<String> _categoriasBase = [
    'seguridad/medio/ambiente/moral',
    'satisfacción del cliente',
    'calidad',
    'costo/productividad',
    'entregas',
  ];

  final List<CategoriaD4> _categorias = [];

  @override
  void initState() {
    super.initState();
    _categorias.addAll(
      _categoriasBase
          .map((nombre) => CategoriaD4(
                nombre: nombre,
                subcategorias: [SubcategoriaD4(nombre: 'Subcat 1')],
              ))
          .toList(),
    );
  }

  // ---- CRUD de categorías/subcategorías ----
  void _agregarCategoria() {
    if (_categorias.length >= 15) return;
    setState(() {
      _categorias.add(CategoriaD4(
        nombre: 'Nueva categoría',
        subcategorias: [SubcategoriaD4(nombre: 'Subcat 1')],
      ));
    });
  }

  void _eliminarCategoria(int idx) {
    if (idx < 0 || idx >= _categorias.length) return;
    setState(() => _categorias.removeAt(idx));
  }

  void _agregarSubcategoria(int catIdx) {
    if (catIdx < 0 || catIdx >= _categorias.length) return;
    final cat = _categorias[catIdx];
    if (cat.subcategorias.length >= 6) return;
    setState(() => cat.subcategorias.add(SubcategoriaD4(nombre: 'Nueva subcat')));
  }

  void _eliminarSubcategoria(int catIdx, int subIdx) {
    if (catIdx < 0 || catIdx >= _categorias.length) return;
    final cat = _categorias[catIdx];
    if (subIdx < 0 || subIdx >= cat.subcategorias.length) return;
    setState(() => cat.subcategorias.removeAt(subIdx));
  }

  // ---- Cálculos ----
  int get _puntajeTotal {
    var total = 0;
    for (final c in _categorias) {
      for (final s in c.subcategorias) {
        total += s.valor;
      }
    }
    return total;
  }

  int get _maximoTotal {
    var max = 0;
    for (final c in _categorias) {
      max += c.subcategorias.length * 5;
    }
    return max;
  }

  double get _porcentajeGlobal {
    final max = _maximoTotal;
    if (max == 0) return 0.0;
    return (_puntajeTotal / max) * 100.0;
  }

  int get _puntosD4 {
    final max = _maximoTotal;
    if (max == 0) return 0;
    return ((_puntajeTotal / max) * 200).round(); // Escala a 200 pts
  }

  Future<void> _navegarAShingoHoja(int catIdx, int subIdx) async {
    if (catIdx < 0 || catIdx >= _categorias.length) return;
    final cat = _categorias[catIdx];
    if (subIdx < 0 || subIdx >= cat.subcategorias.length) return;
    final sub = cat.subcategorias[subIdx];

    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => HojaShingoWidget(
          titulo: sub.nombre,
          data: ShingoResultData(calificacion: sub.valor),
        ),
      ),
    );
    if (result != null) {
      setState(() => sub.valor = result.clamp(0, 5));
    }
  }

  void _verReporte() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReportShingoScreen(categorias: _categorias)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EVALUACION DE RESULTADOS'),
        actions: [
          IconButton(onPressed: _agregarCategoria, icon: const Icon(Icons.add), tooltip: 'Agregar categoría'),
          IconButton(onPressed: _verReporte, icon: const Icon(Icons.table_chart), tooltip: 'Ver reporte'),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _categorias.length,
                itemBuilder: (context, catIdx) {
                  final cat = _categorias[catIdx];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: cat.nombre,
                                  decoration: const InputDecoration(labelText: 'Nombre categoría'),
                                  onChanged: (v) => setState(() => cat.nombre = v),
                                ),
                              ),
                              IconButton(onPressed: () => _eliminarCategoria(catIdx), icon: const Icon(Icons.delete, color: Colors.red)),
                              IconButton(onPressed: () => _agregarSubcategoria(catIdx), icon: const Icon(Icons.add)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cat.subcategorias.length,
                            itemBuilder: (context, subIdx) {
                              final sub = cat.subcategorias[subIdx];
                              return Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: sub.nombre,
                                      decoration: const InputDecoration(labelText: 'Subcategoría'),
                                      onChanged: (v) => setState(() => sub.nombre = v),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 140,
                                    child: GestureDetector(
                                      onTap: () => _navegarAShingoHoja(catIdx, subIdx),
                                      child: Slider(
                                        value: sub.valor.toDouble(),
                                        min: 0, max: 5, divisions: 5, label: sub.valor.toString(),
                                        onChanged: null, // solo editable desde hoja
                                      ),
                                    ),
                                  ),
                                  IconButton(onPressed: () => _eliminarSubcategoria(catIdx, subIdx), icon: const Icon(Icons.delete, color: Colors.red)),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Text('Puntaje total: $_puntajeTotal / $_maximoTotal', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('Porcentaje global: ${_porcentajeGlobal.toStringAsFixed(2)}%'),
                  const SizedBox(height: 6),
                  Text('D4 (0..200): $_puntosD4', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
