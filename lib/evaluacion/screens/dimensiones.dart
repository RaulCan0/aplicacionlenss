import 'package:aplicacionlensys/evaluacion/providers/evaluaciones_provider.dart';
import 'package:aplicacionlensys/evaluacion/screens/formulario_asociados.dart';
import 'package:aplicacionlensys/evaluacion/screens/resultados_d4_screen.dart';
import 'package:aplicacionlensys/evaluacion/screens/tabla_global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/empresa.dart';

class AppColors {
  static const Color primary = Color.fromARGB(255, 3, 34, 59); // Azul AppBar
}

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
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          "Dimensiones - ${empresa.nombre}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            context,
            titulo: "IMPULSORES CULTURALES",
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FormularioAsociadosScreen(
                    evaluacionId: evaluacionId,
                    dimensionId: "D1",
                    empresa: empresa,
                  ),
                ),
              );
            },
          ),
          _buildCard(
            context,
            titulo: "MEJORA CONTINUA",
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FormularioAsociadosScreen(
                    evaluacionId: evaluacionId,
                    dimensionId: "D2",
                    empresa: empresa,
                  ),
                ),
              );
            },
          ),
          _buildCard(
            context,
            titulo: "ALINEAMIENTO EMPRESARIAL",
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FormularioAsociadosScreen(
                    evaluacionId: evaluacionId,
                    dimensionId: "D3",
                    empresa: empresa,
                  ),
                ),
              );
            },
              showCircles: false,
          ),
          _buildCard(
            context,
            titulo: "RESULTADOS ",
            color: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ResultadosD4Screen(),
                ),
              );
            },
              showCircles: false,
          ),
          _buildCard(
            context,
            titulo: "EVALUACION FINAL",
            color: Colors.grey,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TablaGlobalScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String titulo,
    required Color color,
    required VoidCallback onTap,
    bool showCircles = true,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
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
              showCircles
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _CircleCargo("Ejecutivos", Colors.blue),
                        _CircleCargo("Gerentes", Colors.green),
                        _CircleCargo("Miembros", Colors.orange),
                      ],
                    )
                  : SizedBox(
                      height: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(width: 80),
                          Container(width: 80),
                          Container(width: 80),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // Elimina _buildSimpleCard, ya no se usa
}

class _CircleCargo extends StatelessWidget {
  final String label;
  final Color color;

  const _CircleCargo(this.label, this.color);

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
                value: 0.0, // sin ejemplo
                strokeWidth: 8,
                color: color,
                backgroundColor: Colors.grey[300],
              ),
              const Center(
                child: Text(
                  "-",
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                    
