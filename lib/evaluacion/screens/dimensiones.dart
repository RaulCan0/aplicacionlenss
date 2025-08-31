import 'package:aplicacionlensys/evaluacion/providers/evaluaciones_provider.dart';
import 'package:aplicacionlensys/evaluacion/screens/formulario_asociados.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/empresa.dart';


class DimensionesScreen extends ConsumerWidget {
  final Empresa empresa;
  final String evaluacionId;

  const DimensionesScreen({
    super.key,
    required this.empresa,
    required this.evaluacionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(evaluacionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Dimensiones - ${empresa.nombre}"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDimensionCard(
            context,
            titulo: "D1 - Impulsores Culturales",
            color: Colors.blue,
            evaluacionId: evaluacionId,
            dimensionId: "D1",
          ),
          _buildDimensionCard(
            context,
            titulo: "D2 - Mejora Continua",
            color: Colors.green,
            evaluacionId: evaluacionId,
            dimensionId: "D2",
          ),
          _buildDimensionCard(
            context,
            titulo: "D3 - Alineamiento Organizacional",
            color: Colors.orange,
            evaluacionId: evaluacionId,
            dimensionId: "D3",
          ),
          _buildSimpleCard(
            titulo: "D4 - Resultados",
            color: Colors.purple,
          ),
          _buildSimpleCard(
            titulo: "EVALUACION FINAL",
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionCard(
    BuildContext context, {
    required String titulo,
    required Color color,
    required String evaluacionId,
    required String dimensionId,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FormularioAsociadosScreen(
                evaluacionId: evaluacionId,
                dimensionId: dimensionId,
                empresa: empresa,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                titulo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _CircleCargo(label: "Ejecutivos", progreso: 0.6, color: Colors.blue),
                  _CircleCargo(label: "Gerentes", progreso: 0.4, color: Colors.green),
                  _CircleCargo(label: "Miembros", progreso: 0.8, color: Colors.orange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleCard({required String titulo, required Color color}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          titulo,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _CircleCargo extends StatelessWidget {
  final String label;
  final double progreso;
  final Color color;

  const _CircleCargo({
    required this.label,
    required this.progreso,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 80,
          width: 80,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progreso,
                strokeWidth: 8,
                color: color,
                backgroundColor: Colors.grey[300],
              ),
              Center(
                child: Text(
                  "${(progreso * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
