import 'package:flutter/material.dart';

class DetallesScreen extends StatelessWidget {
  const DetallesScreen({super.key});

  // 3 gráficos por cargo
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalles')),
      body: Center(child: Text('3 gráficos por cargo')),
    );
  }
}
