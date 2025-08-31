import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Modelo para la hoja Shingo (D4)
class ShingoResultData {
  Map<String, String> campos;
  File? imagenFile; // Imagen local opcional
  int calificacion; // 0..5

  ShingoResultData({
    this.campos = const {},
    this.imagenFile,
    this.calificacion = 0,
  });

  ShingoResultData copyWith({
    Map<String, String>? campos,
    File? imagenFile,
    int? calificacion,
  }) => ShingoResultData(
        campos: campos ?? this.campos,
        imagenFile: imagenFile ?? this.imagenFile,
        calificacion: calificacion ?? this.calificacion,
      );
}

/// Hoja de captura/edición para una subcategoría de D4
/// Devuelve un int (0..5) como calificación al cerrar con "Guardar".
class HojaShingoWidget extends StatefulWidget {
  final String titulo;
  final ShingoResultData data;

  const HojaShingoWidget({
    super.key,
    required this.titulo,
    required this.data,
  });

  @override
  State<HojaShingoWidget> createState() => _HojaShingoWidgetState();
}

class _HojaShingoWidgetState extends State<HojaShingoWidget> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;
  int _valor = 0;
  File? _imagen;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _valor = widget.data.calificacion.clamp(0, 5);
    _imagen = widget.data.imagenFile;
    _controllers = {
      for (final entry in widget.data.campos.entries)
        entry.key: TextEditingController(text: entry.value),
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _agregarCampo() {
    final nuevo = 'Campo ${_controllers.length + 1}';
    setState(() {
      _controllers[nuevo] = TextEditingController();
    });
  }

  Future<void> _seleccionarImagen() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x == null) return;
    setState(() {
      _imagen = File(x.path);
    });
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    // Si quisieras devolver campos/imagen, cámbialo por: Navigator.pop(context, ShingoResultData(...))
    Navigator.pop<int>(context, _valor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
        actions: [
          IconButton(onPressed: _agregarCampo, icon: const Icon(Icons.add_comment), tooltip: 'Agregar campo'),
          IconButton(onPressed: _guardar, icon: const Icon(Icons.save), tooltip: 'Guardar'),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Calificación 0..5
            Row(
              children: [
                const Text('Calificación (0..5):', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _valor,
                  items: List.generate(6, (i) => DropdownMenuItem(value: i, child: Text('$i'))),
                  onChanged: (v) => setState(() => _valor = v ?? 0),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Imagen
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _seleccionarImagen,
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Seleccionar imagen'),
                ),
                const SizedBox(width: 12),
                if (_imagen != null)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_imagen!, height: 120, fit: BoxFit.cover),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Campos', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._controllers.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextFormField(
                    controller: e.value,
                    decoration: InputDecoration(
                      labelText: e.key,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => e.value.clear()),
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save),
              label: const Text('Guardar y volver'),
            ),
          ],
        ),
      ),
    );
  }
}
