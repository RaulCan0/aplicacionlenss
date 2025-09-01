import 'package:flutter/material.dart';
import '../widgets/shingo_hojas.dart';

class CategoriaD4 {
  String nombre;
  List<SubcategoriaD4> subcategorias;
  CategoriaD4({required this.nombre, required this.subcategorias});
}

class SubcategoriaD4 {
  String nombre;
  int valor;
  SubcategoriaD4({required this.nombre, this.valor = 0});
}

class ResultadosD4Screen extends StatefulWidget {
  const ResultadosD4Screen({super.key});

  @override
  State<ResultadosD4Screen> createState() => _ResultadosD4ScreenState();
}

class _ResultadosD4ScreenState extends State<ResultadosD4Screen> {
  static const List<String> _categoriasBase = [
    'S/M/A/M',
    'Cliente',
    'Calidad',
    'Costo',
    'Entregas',
  ];

  final List<CategoriaD4> _categorias = [];

  @override
  void initState() {
    super.initState();
    _categorias.addAll(
      _categoriasBase
          .map((nombre) => CategoriaD4(
                nombre: nombre,
                subcategorias: [],
              ))
          .toList(),
    );
  }

  void _agregarCategoria() {
    if (_categorias.length >= 10) return;
    setState(() {
      _categorias.add(CategoriaD4(
        nombre: 'Nueva categoría',
        subcategorias: [],
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
    setState(() => cat.subcategorias.add(SubcategoriaD4(nombre: '')));
  }

  void _eliminarSubcategoria(int catIdx, int subIdx) {
    if (catIdx < 0 || catIdx >= _categorias.length) return;
    final cat = _categorias[catIdx];
    if (subIdx < 0 || subIdx >= cat.subcategorias.length) return;
    setState(() => cat.subcategorias.removeAt(subIdx));
  }

  Future<void> _navegarAShingoHoja(int catIdx, int subIdx) async {
    final cat = _categorias[catIdx];
    final sub = cat.subcategorias[subIdx];
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => HojaShingoWidget(
          titulo: sub.nombre,
          data: ShingoResultData(), // Replace with appropriate initialization if needed
        ),
      ),
    );
    if (result != null) {
      setState(() => sub.valor = result.clamp(0, 5));
    }
  }

  int get _puntajeTotal => _categorias.expand((c) => c.subcategorias).fold(0, (sum, s) => sum + s.valor);
  int get _maximoTotal => _categorias.fold(0, (sum, c) => sum + (c.subcategorias.length * 5));
  double get _porcentajeGlobal => _maximoTotal == 0 ? 0.0 : (_puntajeTotal / _maximoTotal) * 100;
  int get _puntosD4 => _maximoTotal == 0 ? 0 : ((_puntajeTotal / _maximoTotal) * 200).round();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003056),
        title: const Text('EVALUACIÓN DE RESULTADOS', textAlign: TextAlign.center),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(onPressed: _agregarCategoria, icon: const Icon(Icons.add, color: Colors.white)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ..._categorias.asMap().entries.map((catEntry) {
                  final catIdx = catEntry.key;
                  final cat = catEntry.value;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
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
                          const SizedBox(height: 10),
                          ...cat.subcategorias.asMap().entries.map((subEntry) {
                            final subIdx = subEntry.key;
                            final sub = subEntry.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: sub.nombre,
                                      decoration: const InputDecoration(labelText: 'Subcategoría'),
                                      onChanged: (v) => setState(() => sub.nombre = v),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 130,
                                    child: GestureDetector(
                                      onTap: () => _navegarAShingoHoja(catIdx, subIdx),
                                      child: AbsorbPointer(
                                        child: Slider(
                                          value: sub.valor.toDouble(),
                                          min: 0,
                                          max: 5,
                                          divisions: 5,
                                          label: sub.valor.toString(),
                                          onChanged: (_) {},
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _eliminarSubcategoria(catIdx, subIdx),
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
        ),
      ),
    );
  }
}
