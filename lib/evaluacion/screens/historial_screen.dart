import 'package:flutter/material.dart';

class HistorialEmpresasScreen extends StatelessWidget {
  const HistorialEmpresasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Empresas')),
      body: const Center(
        child: Text('Lista, gráfico 1 color (0-5 vs 0-1000) + dropdown Evaluaciones'),
      ),
    );
  }
}
