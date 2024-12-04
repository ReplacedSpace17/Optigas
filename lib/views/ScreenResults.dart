import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:optigas/views/Render.dart';
import 'package:optigas/views/RenderCotizacion.dart';

class ResultsScreen extends StatelessWidget {
  final String? tablaCalculada; // Cambia el tipo según lo que devuelva resolve()
  final String? tablaCotizacion; // Cambia el tipo según lo que devuelva resolve()

  const ResultsScreen({Key? key, this.tablaCalculada, this.tablaCotizacion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convertir tablaCalculada a List<Map<String, dynamic>> si no es null
    List<Map<String, dynamic>> convertedTable = [];
    // Convertir tablaCotizacion a List<Map<String, dynamic>> si no es null
    List<Map<String, dynamic>> convertedTableCotizacion = [];
    if (tablaCalculada != null && tablaCalculada!.isNotEmpty) {
      try {
        convertedTable = List<Map<String, dynamic>>.from(json.decode(tablaCalculada!));
      } catch (e) {
        print("Error al convertir JSON: $e");
        // Manejar error de decodificación si es necesario
      }
    }
    if (tablaCotizacion != null && tablaCotizacion!.isNotEmpty) {
      try {
        convertedTableCotizacion = List<Map<String, dynamic>>.from(json.decode(tablaCotizacion!));
      } catch (e) {
        print("Error al convertir JSON: $e");
        // Manejar error de decodificación si es necesario
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                print(tablaCalculada.toString());
                // Acción del botón "Cálculos"
                print('Cálculos button pressed');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RenderScreen(tabla: convertedTable),
                  ), 
                );
              },
              child: const Text('Cálculos'),
            ),
            const SizedBox(height: 20), // Espaciado entre los botones
            ElevatedButton(
              onPressed: () {
                // Acción del botón "Cotización" 
Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CotizacionScreen(tabla: convertedTableCotizacion),
                  ), 
                );
                print('Cotización button pressed');
              },
              child: const Text('Cotización'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ResultsScreen(),
  ));
}
