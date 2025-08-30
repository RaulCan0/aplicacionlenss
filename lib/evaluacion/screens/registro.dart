import 'package:aplicacionlensys/colores_app.dart';
import 'package:flutter/material.dart';
class Registro extends StatelessWidget {
  const Registro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Coloresapp.lensys,
        centerTitle: true,
        title: const Text(
          'Diagnóstico Lean TrainningCenter',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Text('Pantalla de Registro'),
      ),
    );
  }
}