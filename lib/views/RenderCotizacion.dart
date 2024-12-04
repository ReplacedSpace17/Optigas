import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:open_file/open_file.dart';

class CotizacionScreen extends StatelessWidget {
  final List<Map<String, dynamic>> tabla; // Recibir la tabla como parámetro

  const CotizacionScreen({Key? key, required this.tabla}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<File> generatePdf() async {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Table.fromTextArray(
              headers: [
                "Índice",
                "Descripción",
                "Cantidad",
                "Precio Unitario",
                "Precio Total",
              ],
              data: tabla.map((row) {
                return [
                  row["Indice"] ?? "",
                  row["Descripcion"] ?? "",
                  row["Cantidad"] ?? "",
                  row["Precio_Unitario"] ?? "",
                  row["Precio_Total"] ?? "",
                ];
              }).toList(),
            );
          },
        ),
      );

      final directory = await getExternalStorageDirectory();
      final downloadDirectory = Directory('${directory?.parent.path}/Download');
      if (!await downloadDirectory.exists()) {
        await downloadDirectory.create(recursive: true);
      }

      final file = File("${downloadDirectory.path}/cotizacion.pdf");
      await file.writeAsBytes(await pdf.save());
      return file;
    }

    void showPdfDialog(BuildContext context, File pdfFile) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("PDF Generado"),
            content: const Text("El archivo PDF se ha guardado correctamente."),
            actions: [
              TextButton(
                onPressed: () {
                  OpenFile.open(pdfFile.path);
                },
                child: const Text("Abrir PDF"),
              ),
              TextButton(
                onPressed: () {
                  Share.shareFiles([pdfFile.path],
                      text: "¡Revisa este archivo PDF!");
                },
                child: const Text("Compartir PDF"),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cotización"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Índice")),
                DataColumn(label: Text("Descripción")),
                DataColumn(label: Text("Cantidad")),
                DataColumn(label: Text("Precio Unitario")),
                DataColumn(label: Text("Precio Total")),
              ],
              rows: tabla.map((data) {
                return DataRow(
                  cells: [
                    DataCell(Text(data["Indice"]?.toString() ?? "")),
                    DataCell(Text(data["Descripcion"] ?? "")),
                    DataCell(Text(data["Cantidad"]?.toString() ?? "")),
                    DataCell(Text(data["Precio_Unitario"]?.toString() ?? "")),
                    DataCell(Text(data["Precio_Total"]?.toString() ?? "")),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btnShare",
            onPressed: () async {
              final pdfFile = await generatePdf();
              Share.shareFiles([pdfFile.path],
                  text: "¡Revisa este archivo PDF!");
            },
            child: const Icon(Icons.share),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "btnDownload",
            onPressed: () async {
              final pdfFile = await generatePdf();
              showPdfDialog(context, pdfFile);
            },
            child: const Icon(Icons.download),
          ),
        ],
      ),
    );
  }
}
