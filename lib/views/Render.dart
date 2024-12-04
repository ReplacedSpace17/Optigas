import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:open_file/open_file.dart';

class RenderScreen extends StatelessWidget {
  final List<Map<String, dynamic>> tabla; // Recibir la tabla como parámetro

  // Modificar el constructor para recibir la tabla
  const RenderScreen({Key? key, required this.tabla}) : super(key: key);

@override
Widget build(BuildContext context) {
  // Aquí usas tablaCalculada en lugar de la tabla fija
  Future<File> generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            headers: [
              "Índice",
              "Tramo",
              "L",
              "Leq",
              "Qs",
              "Dc",
              "Dn",
              "Dnr",
              "Mat",
              "Pi",
              "DeltaP",
              "Pf",
              "V",
              "Valido"
            ],
            data: tabla.map((row) {
              return [
                row["Indice"],
                row["Tramo"],
                row["L"],
                row["Leq"],
                row["Qs"],
                row["Dc"],
                row["Dn"],
                row["Dnr"],
                row["Mat"],
                row["Pi"],
                row["DeltaP"],
                row["Pf"],
                row["V"],
                row["Valido"] ? "Sí" : "No",
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
      title: const Text("Tabla de Datos"),
    ),
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView( // Agregado para desplazamiento vertical
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView( // Mantén el desplazamiento horizontal
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text("Índice")),
              DataColumn(label: Text("Tramo")),
              DataColumn(label: Text("L")),
              DataColumn(label: Text("Leq")),
              DataColumn(label: Text("Qs")),
              DataColumn(label: Text("Dc")),
              DataColumn(label: Text("Dn")),
              DataColumn(label: Text("Dnr")),
              DataColumn(label: Text("Mat")),
              DataColumn(label: Text("Pi")),
              DataColumn(label: Text("DeltaP")),
              DataColumn(label: Text("Pf")),
              DataColumn(label: Text("V")),
              DataColumn(label: Text("Valido")),
            ],
            rows: tabla.map((data) {
              return DataRow(
                cells: [
                  DataCell(Text(data["Indice"].toString())),
                  DataCell(Text(data["Tramo"])),
                  DataCell(Text(data["L"].toString())),
                  DataCell(Text(data["Leq"].toString())),
                  DataCell(Text(data["Qs"].toString())),
                  DataCell(Text(data["Dc"].toString())),
                  DataCell(Text(data["Dn"].toString())),
                  DataCell(Text(data["Dnr"])),
                  DataCell(Text(data["Mat"])),
                  DataCell(Text(data["Pi"].toString())),
                  DataCell(Text(data["DeltaP"].toString())),
                  DataCell(Text(data["Pf"].toString())),
                  DataCell(Text(data["V"].toString())),
                  DataCell(Text(data["Valido"] ? "Sí" : "No")),
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
