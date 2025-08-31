import 'package:aplicacionlensys/evaluacion/models/tabla_evaluacion.dart';
import 'package:aplicacionlensys/evaluacion/services/tabla_datos_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TablaEvaluacionScreen extends StatefulWidget {
  final String evaluacionId;
  const TablaEvaluacionScreen({super.key, required this.evaluacionId});

  @override
  State<TablaEvaluacionScreen> createState() => _TablaEvaluacionScreenState();
}

class _TablaEvaluacionScreenState extends State<TablaEvaluacionScreen> {
  late final TablaEvaluacionService _service;
  List<FilaTablaEvaluacion> filas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _service = TablaEvaluacionService(Supabase.instance.client);
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final data = await _service.getFilasParaTabla(widget.evaluacionId);
    setState(() {
      filas = data;
      isLoading = false;
    });
  }

  DataCell _wrapCell(String? text) {
    return DataCell(
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220), // ajusta ancho
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Text(
            text ?? "-",
            softWrap: true,
            overflow: TextOverflow.visible,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tabla de Evaluación")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 28,
                columns: const [
                  DataColumn(label: Text("Principio")),
                  DataColumn(label: Text("Comportamiento")),
                  DataColumn(label: Text("Ejecutivos")),
                  DataColumn(label: Text("Sist. EJ")),
                  DataColumn(label: Text("Obs. EJ")),
                  DataColumn(label: Text("Gerentes")),
                  DataColumn(label: Text("Sist. G")),
                  DataColumn(label: Text("Obs. G")),
                  DataColumn(label: Text("Miembro")),
                  DataColumn(label: Text("Sist. M")),
                  DataColumn(label: Text("Obs. M")),
                ],
                rows: filas.map((f) {
                  return DataRow(cells: [
                    _wrapCell(f.principio),
                    _wrapCell(f.comportamiento),
                    _wrapCell(f.valorEjecutivos?.toString()),
                    _wrapCell(f.sistemasEjecutivos),
                    _wrapCell(f.obsEjecutivos),
                    _wrapCell(f.valorGerentes?.toString()),
                    _wrapCell(f.sistemasGerentes),
                    _wrapCell(f.obsGerentes),
                    _wrapCell(f.valorMiembro?.toString()),
                    _wrapCell(f.sistemasMiembro),
                    _wrapCell(f.obsMiembro),
                  ]);
                }).toList(),
              ),
            ),
    );
  }
}
