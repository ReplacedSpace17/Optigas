import 'dart:convert';

import 'package:optigas/model/ElementModel.dart';

class ElementoController {
  final List<Elemento> elementos = [];
  int _currentIdIncremental = 1; // Control del ID incremental

  void addElemento({
    required int elementoTipo,
    required int idElemento,
    required double longitud,
    required String nodoInicio,
    required String nodoFin,
    required String direccion, // Nuevo parámetro
  }) {
    

    final nuevoElemento = Elemento(
      idIncremental: _currentIdIncremental,
      elementoTipo: elementoTipo,
      idElemento: idElemento,
      longitud: longitud,
      nodoInicio: nodoInicio,
      nodoFin: nodoFin,
      direccion: direccion, // Asignación
    );

    elementos.add(nuevoElemento);
    _currentIdIncremental++; // Incrementa el ID
  }

  List<Map<String, dynamic>> getListaJson() {
    return elementos.map((elemento) => elemento.toJson()).toList();
  }
  /// Método para obtener el JSON válido con comillas dobles
  String getJsonComillas() {
    final listaJson = getListaJson();
    return jsonEncode(listaJson);
  }
}
