import 'package:flutter/material.dart';

class Historial extends StatelessWidget {
  final List<String> empresasEvaluadas;

  const Historial({super.key, required this.empresasEvaluadas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empresas Evaluadas'),
      ),
      body: ListView.builder(
        itemCount: empresasEvaluadas.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.business),
            title: Text(empresasEvaluadas[index]),
          );
        },
      ),
    );
  }
}