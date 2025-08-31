import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';

import '../models/empresa.dart';
import '../models/asociado_evaluacion.dart';

class PrincipiosScreen extends StatefulWidget {
  final Empresa empresa;
  final AsociadoEvaluacion asociado;
  final String dimensionId;
  final String evaluacionId;

  const PrincipiosScreen({
    super.key,
    required this.empresa,
    required this.asociado,
    required this.dimensionId,
    required this.evaluacionId,
  });

  @override
  State<PrincipiosScreen> createState() => _PrincipiosScreenState();
}

class _PrincipiosScreenState extends State<PrincipiosScreen> {
  List<dynamic> _principios = [];
  Map<String, dynamic>? _principioSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarCatalogo();
  }

  Future<void> _cargarCatalogo() async {
    final String raw = await rootBundle.loadString('assets/estructura.json');
    final data = json.decode(raw);

    final dimension = (data['dimensiones'] as List).firstWhere(
      (d) => d['id'] == widget.dimensionId,
      orElse: () => null,
    );

    if (dimension != null) {
      setState(() {
        _principios = dimension['principios'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003056),
        title: Text(
          "${widget.empresa.nombre} - Principios",
          style: GoogleFonts.roboto(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Asociado: ${widget.asociado.nombreCompleto}",
                style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<Map<String, dynamic>>(
              decoration: const InputDecoration(
                labelText: "Selecciona un Principio",
                border: OutlineInputBorder(),
              ),
              value: _principioSeleccionado,
              items: _principios.map<DropdownMenuItem<Map<String, dynamic>>>((p) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: p,
                  child: Text(p['nombre'], style: GoogleFonts.roboto()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _principioSeleccionado = value;
                });
              },
            ),
            const SizedBox(height: 20),
            if (_principioSeleccionado != null)
              Expanded(
                child: ListView.builder(
                  itemCount: _principioSeleccionado!['comportamientos'].length,
                  itemBuilder: (context, index) {
                    final comp =
                        _principioSeleccionado!['comportamientos'][index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(comp['nombre'],
                            style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(comp['descripcion'],
                            style: GoogleFonts.roboto()),
                        onTap: () {
                          // Aquí puedes navegar a ComportamientoEvaluacionScreen
                          // pasando evaluacionId, dimensionId, asociado, comportamiento
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
