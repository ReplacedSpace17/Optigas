import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:open_file/open_file.dart';

class RenderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> tableData = [
      {"ID": "1", "Descripción": "Estudio de viabilidad", "Cantidad": "1", "Precio Unitario": "1000", "Total": "1000"},
      {"ID": "2", "Descripción": "Instalación de medidor de gas", "Cantidad": "1", "Precio Unitario": "800", "Total": "800"},
      {"ID": "3", "Descripción": "Tubería de gas (m)", "Cantidad": "50", "Precio Unitario": "20", "Total": "1000"},
      {"ID": "4", "Descripción": "Conexión de tuberías internas", "Cantidad": "1", "Precio Unitario": "600", "Total": "600"},
      {"ID": "5", "Descripción": "Válvulas de seguridad", "Cantidad": "2", "Precio Unitario": "150", "Total": "300"},
      {"ID": "6", "Descripción": "Mano de obra", "Cantidad": "20", "Precio Unitario": "200", "Total": "4000"},
      {"ID": "7", "Descripción": "Prueba de presión", "Cantidad": "1", "Precio Unitario": "500", "Total": "500"},
      {"ID": "8", "Descripción": "Certificación y permisos", "Cantidad": "1", "Precio Unitario": "400", "Total": "400"},
      {"ID": "9", "Descripción": "Transportación de materiales", "Cantidad": "1", "Precio Unitario": "300", "Total": "300"},
      {"ID": "10", "Descripción": "Total", "Cantidad": "", "Precio Unitario": "", "Total": "8200"},
    ];

    Future<File> generatePdf() async {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Table.fromTextArray(
              headers: ["ID", "Descripción", "Cantidad", "Precio Unitario", "Total"],
              data: tableData.map((row) {
                return [row["ID"], row["Descripción"], row["Cantidad"], row["Precio Unitario"], row["Total"]];
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

      final file = File("${downloadDirectory.path}/tabla_datos.pdf");
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
                  Share.shareFiles([pdfFile.path], text: "¡Revisa este archivo PDF!");
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
        title: const Text("Tabla de Datos"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text("ID")),
              DataColumn(label: Text("Descripción")),
              DataColumn(label: Text("Cantidad")),
              DataColumn(label: Text("Precio Unitario")),
              DataColumn(label: Text("Total")),
            ],
            rows: tableData.map((data) {
              return DataRow(
                cells: [
                  DataCell(Text(data["ID"]!)),
                  DataCell(Text(data["Descripción"]!)),
                  DataCell(Text(data["Cantidad"] ?? "-")),
                  DataCell(Text(data["Precio Unitario"] ?? "-")),
                  DataCell(Text(data["Total"]!)),
                ],
              );
            }).toList(),
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
              Share.shareFiles([pdfFile.path], text: "¡Revisa este archivo PDF!");
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
