import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class NivelEvaluacion {
  final double valor;
  final String interpretacion;
  final String benchmarkPorCargo;
  final String obs;
  final List<String> sistemasSeleccionados;
  final String? evidenciaUrl;

  NivelEvaluacion({
    required this.valor,
    required this.interpretacion,
    required this.benchmarkPorCargo,
    required this.obs,
    required this.sistemasSeleccionados,
    this.evidenciaUrl,
  });
}

class ReporteComportamiento {
  final String nombre;
  final String benchmarkGeneral;
  final Map<String, NivelEvaluacion> niveles;

  ReporteComportamiento({
    required this.nombre,
    required this.benchmarkGeneral,
    required this.niveles,
  });
}

class ReportePdfService {
  static Future<Uint8List> generarReportePdf(
    List<ReporteComportamiento> datos, [
    List<String>? recomendaciones,
  ]) async {
    final pdf = pw.Document();

    // Estilos reutilizables
    final txtSmall = pw.TextStyle(fontSize: 9);
    final txtNormal = pw.TextStyle(fontSize: 10);
    final headerStyle =
        pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold);

    for (int i = 0; i < datos.length; i++) {
      final comp = datos[i];

      // Página del benchmark
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("BENCHMARK DE COMPORTAMIENTOS", style: headerStyle),
            pw.SizedBox(height: 6),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey700),
                color: PdfColors.grey200,
              ),
              child: pw.Text(comp.benchmarkGeneral, style: txtNormal),
            ),
            pw.SizedBox(height: 10),
            _tablaNiveles(comp, headerStyle, txtSmall),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Center(child: pw.Text("Resumen Gráfico", style: headerStyle)),
            pw.SizedBox(height: 8),
            _buildVerticalBarChartConEscala(comp),
            pw.SizedBox(height: 20),

            // Recomendación integrada (opcional)
            if (recomendaciones != null && recomendaciones.length > i)
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  border: pw.Border.all(color: PdfColors.blueGrey),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Recomendación ${i + 1}: ${comp.nombre}',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      recomendaciones[i],
                      style: txtNormal,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ));
    }

    return pdf.save();
  }

  static pw.Widget _tablaNiveles(
    ReporteComportamiento comp,
    pw.TextStyle headerStyle,
    pw.TextStyle cellStyle,
  ) {
    const nivelesOrdenados = ['E', 'G', 'M'];

    String getNivelNombre(String key) {
      switch (key) {
        case 'E':
          return 'Ejecutivo';
        case 'G':
          return 'Gerente';
        case 'M':
          return 'Miembro de Equipo';
        default:
          return key;
      }
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey700, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(5),
        3: const pw.FlexColumnWidth(5),
        4: const pw.FlexColumnWidth(3),
        5: const pw.FlexColumnWidth(3),
      },
      children: [
        // Encabezado
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            for (final title in [
              "Nivel",
              "Valor",
              "Interpretación",
              "Benchmark por Cargo",
              "Sistemas",
              "Hallazgos"
            ])
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(title, style: headerStyle),
              ),
          ],
        ),
        // Filas por nivel
        for (final key in nivelesOrdenados)
          if (comp.niveles[key] != null)
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(getNivelNombre(key), style: cellStyle),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(comp.niveles[key]!.valor.toStringAsFixed(2),
                      style: cellStyle),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(comp.niveles[key]!.interpretacion,
                      style: cellStyle),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(comp.niveles[key]!.benchmarkPorCargo,
                      style: cellStyle),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                      comp.niveles[key]!.sistemasSeleccionados.join(", "),
                      style: cellStyle),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(comp.niveles[key]!.obs, style: cellStyle),
                ),
              ],
            ),
      ],
    );
  }

  static pw.Widget _buildVerticalBarChartConEscala(
    ReporteComportamiento comp,
  ) {
    final labels = ['Ejecutivo', 'Gerente', 'Miembro'];
    final values = [
      comp.niveles['E']?.valor ?? 0,
      comp.niveles['G']?.valor ?? 0,
      comp.niveles['M']?.valor ?? 0,
    ];

    const maxY = 5.0;
    const barColors = [PdfColors.orange, PdfColors.green, PdfColors.blue];
    const barWidth = 22.0;

    return pw.Center(
      child: pw.Container(
        height: 140,
        padding: const pw.EdgeInsets.only(left: 10),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            // Eje Y
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) {
                final label = (maxY - i).toStringAsFixed(0);
                return pw.SizedBox(
                  height: 20,
                  child:
                      pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
                );
              }),
            ),
            pw.SizedBox(width: 4),
            // Barras
            pw.Expanded(
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: List.generate(3, (i) {
                  final barHeight = (values[i] / maxY) * 100;
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 4),
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Container(
                          height: barHeight > 0 ? barHeight : 1,
                          width: barWidth,
                          color: barColors[i],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(labels[i],
                            style: const pw.TextStyle(fontSize: 8)),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
