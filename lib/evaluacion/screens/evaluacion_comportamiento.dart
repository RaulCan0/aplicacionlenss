import 'package:aplicacionlensys/evaluacion/services/evidence_service.dart';
import 'package:aplicacionlensys/evaluacion/utils/benchmark_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/calificacion.dart';
import '../services/supabase_service.dart' hide Cargo;
import '../widgets/sistemas_asociados.dart';

class ComportamientoEvaluacionScreen extends ConsumerStatefulWidget {
  final String evaluacionId;
  final String dimensionId;
  final String principioId;
  final String comportamientoId;
  final String cargo;
  final String asociadoId;

  const ComportamientoEvaluacionScreen({
    super.key,
    required this.evaluacionId,
    required this.dimensionId,
    required this.principioId,
    required this.comportamientoId,
    required this.cargo,
    required this.asociadoId,
  });

  @override
  ConsumerState<ComportamientoEvaluacionScreen> createState() =>
      _ComportamientoEvaluacionScreenState();
}

class _ComportamientoEvaluacionScreenState
    extends ConsumerState<ComportamientoEvaluacionScreen> {
  final SupabaseService _service = SupabaseService();
  final TextEditingController obsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  int valor = 0;
  List<String> sistemasSeleccionados = [];
  String? evidenciaUrl;
  bool isSaving = false;

  Map<String, dynamic>? compJson;

  @override
  void initState() {
    super.initState();
    _cargarComportamiento();
  }

  Future<void> _cargarComportamiento() async {
    // Carga los benchmarks de los assets (ajusta los nombres de los assets si es necesario)
    final items = await BenchmarkLoader.loadAll(
      t1: 'assets/benchmark_d1.json',
      t2: 'assets/benchmark_d2.json',
      t3: 'assets/benchmark_d3.json',
    );
    final cargoEnum = cargoFromString(widget.cargo) ?? Cargo.mbr;
    final item = BenchmarkLoader.find(
      items: items,
      dimId: widget.dimensionId,
      principio: widget.principioId,
      comportamiento: widget.comportamientoId,
      cargo: cargoEnum,
    );
    setState(() => compJson = item != null ? {
      "descripcion": item.comportamiento,
      "guia": item.guia,
      "benchmark": item.benchmarkPorCargo,
      "c1c5": item.c1c5,
    } : {
      "descripcion": "No se encontró el comportamiento en el benchmark"
    });
  }

  Future<void> _guardar() async {
    if (obsController.text.trim().isEmpty) {
      _alerta("Validación", "Debes escribir una observación.");
      return;
    }
    if (sistemasSeleccionados.isEmpty) {
      _alerta("Validación", "Selecciona al menos un sistema.");
      return;
    }

    setState(() => isSaving = true);
    try {
      final cal = Calificacion(
        id: const Uuid().v4(),
        evaluacionId: widget.evaluacionId,
        asociadoId: widget.asociadoId,
        dimensionId: widget.dimensionId,
        principioId: widget.principioId,
        comportamientoId: widget.comportamientoId,
        cargo: widget.cargo,
        valor: valor.toDouble(),
        observaciones: obsController.text.trim(),
        getSistemasAsociados: sistemasSeleccionados,
        evidencias: evidenciaUrl != null ? [evidenciaUrl!] : [],
        updatedAt: DateTime.now(),
      );

      await _service.addCalificacion(cal);

      if (mounted) Navigator.pop(context, cal);
    } catch (e) {
      _alerta("Error", "No se pudo guardar: $e");
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> _tomarFoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    final url = await EvidenceService().uploadFromCamera();
    setState(() => evidenciaUrl = url);
    _alerta("Evidencia", "Imagen subida correctamente.");
  }

  void _alerta(String titulo, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(msg),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Aceptar")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (compJson == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003056),
        title: Text("${widget.principioId} - ${widget.comportamientoId}",
            style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(compJson?["descripcion"] ?? "",
                  style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 20),
              const Text("Calificación (0–5):",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: valor.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: valor.toString(),
                onChanged: isSaving ? null : (v) => setState(() => valor = v.toInt()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: obsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Observaciones",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.settings),
                label: const Text("Seleccionar sistemas"),
                onPressed: () async {
                  final seleccion = await showModalBottomSheet<List<String>>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => SistemasScreen(
                      onSeleccionar: (List<Map<String, dynamic>> sistemas) {
                        setState(() {
                          sistemasSeleccionados = sistemas.map((s) => s['nombre'] as String).toList();
                        });
                      },
                    ),
                  );
                  if (seleccion != null) {
                    setState(() => sistemasSeleccionados = seleccion);
                  }
                },
              ),
              if (sistemasSeleccionados.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: sistemasSeleccionados
                      .map((s) => Chip(
                            label: Text(s),
                            onDeleted: () => setState(
                                () => sistemasSeleccionados.remove(s)),
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 16),
              if (evidenciaUrl != null) Image.network(evidenciaUrl!, height: 180),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text("Subir evidencia"),
                onPressed: _tomarFoto,
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003056),
                      foregroundColor: Colors.white),
                  icon: isSaving
                      ? const CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white)
                      : const Icon(Icons.save),
                  label: Text(isSaving ? "Guardando..." : "Guardar"),
                  onPressed: isSaving ? null : _guardar,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
