import 'package:flutter/material.dart';

class ResultadosD4Screen extends StatelessWidget {
  const ResultadosD4Screen({super.key});

  // Pesos=100%, 5–10 categorías, cálculo 200
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Resultados D4')),
      body: Center(child: Text('Pesos, categorías, cálculo')),
    );
  }
}
