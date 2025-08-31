import 'package:flutter/material.dart';
import 'package:aplicacionlensys/evaluacion/charts/chart_dimensiones.dart';
import 'package:aplicacionlensys/evaluacion/charts/chart_principios.dart';
import 'package:aplicacionlensys/evaluacion/charts/chart_comportamientos.dart';
import 'package:aplicacionlensys/evaluacion/charts/chart_sistemas.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Widget _buildChartContainer({
    required Color color,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          height: 500,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Dashboard: 4 Gráficos',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildChartContainer(
              color: Colors.blue.shade50,
              child: MultiRingChart(
                puntosObtenidos: const {
                  'IMPULSORES CULTURALES': 3.5,
                  'MEJORA CONTINUA': 4.2,
                  'ALINEAMIENTO EMPRESARIAL': 2.8,
                },
              ),
            ),
            _buildChartContainer(
              color: Colors.green.shade50,
              child: ScatterBubbleChart(
                datosGraficoPrincipios: const [], // Aquí pon tus datos reales
              ),
            ),
            _buildChartContainer(
              color: Colors.orange.shade50,
              child: ChartComportamiento(
                datos: const {}, // Aquí pon tus datos reales
                minY: 0.0,
                maxY: 5.0,
              ),
            ),
            _buildChartContainer(
              color: Colors.purple.shade50,
              child: ChartSistemas(
                data: const {}, // Aquí pon tus datos reales
                minY: 0.0,
                maxY: 5.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}