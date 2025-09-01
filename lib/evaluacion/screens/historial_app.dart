import 'package:flutter/material.dart';

class Historial extends StatelessWidget {
  final List<String> empresasEvaluadas;

  const Historial({super.key, required this.empresasEvaluadas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003056),
        centerTitle: true,
        title: const Text(
          'HISTORIAL EMPRESAS',
          style: TextStyle(color: Colors.white),
        ),
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