import 'package:flutter/material.dart';

class TablaDatosEvaluacionWidget extends StatelessWidget {
  const TablaDatosEvaluacionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Principio')),
          DataColumn(label: Text('Comportamiento')),
          DataColumn(label: Text('Ejecutivos')),
          DataColumn(label: Text('Sistemas Ejecutivos')),
          DataColumn(label: Text('Observaciones Ejecutivos')),
          DataColumn(label: Text('Gerentes')),
          DataColumn(label: Text('Sistemas Gerentes')),
          DataColumn(label: Text('Observaciones Gerentes')),
          DataColumn(label: Text('Miembro de equipo')),
          DataColumn(label: Text('Sistemas miembro de equipo')),
          DataColumn(label: Text('Observaciones miembro de equipo')),
        ],
        rows: _generarFilas(),
      ),
    );
  }

  List<DataRow> _generarFilas() {
    const estructura = [
      {
        'principio': 'Respetar a Cada Individuo',
        'comportamientos': ['Soporte', 'Reconocer', 'Comunidad']
      },
      {
        'principio': 'Liderar con Humildad',
        'comportamientos': ['Liderazgo de Servidor', 'Valorar', 'Empoderar']
      },
      {
        'principio': 'Buscar la Perfección',
        'comportamientos': ['Mentalidad', 'Estructura']
      },
      {
        'principio': 'Abrazar el Pensamiento Cientifico',
        'comportamientos': ['Reflexionar', 'Análisis', 'Colaborar']
      },
      {
        'principio': 'Enfocarse en el Proceso',
        'comportamientos': ['Comprender', 'Diseño', 'Atribución']
      },
      {
        'principio': 'Asegurar la Calidad en la Fuente',
        'comportamientos': ['A Prueba de Errores', 'Propiedad', 'Conectar']
      },
      {
        'principio': 'Mejorar el Flujo y Jalón de Valor',
        'comportamientos': ['Ininterrumpido', 'Demanda', 'Eliminar']
      },
      {
        'principio': 'Pensar Sistémicamente',
        'comportamientos': ['Optimizar', 'Impacto']
      },
      {
        'principio': 'Crear Constancia de Propósito',
        'comportamientos': ['Alinear', 'Aclarar', 'Comunicar']
      },
      {
        'principio': 'Crear Valor para el Cliente',
        'comportamientos': ['Relación', 'Valor', 'Medida']
      },
    ];

    final List<DataRow> rows = [];

    for (final entry in estructura) {
      final principio = entry['principio'] as String;
      final comportamientos = entry['comportamientos'] as List<String>;

      for (final comportamiento in comportamientos) {
        rows.add(DataRow(cells: [
          DataCell(Text(principio)),
          DataCell(Text(comportamiento)),
          const DataCell(Text('')),
          const DataCell(Text('')),
          const DataCell(Text('')),
          const DataCell(Text('')),
          const DataCell(Text('')),
          const DataCell(Text('')),
          const DataCell(Text('')),
          const DataCell(Text('')),
          const DataCell(Text('')),
        ]));
      }
    }

    return rows;
  }
}