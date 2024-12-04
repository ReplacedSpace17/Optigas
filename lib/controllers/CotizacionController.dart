import 'dart:convert';

import 'package:optigas/model/CotizacionModel.dart';

class CotizacionController {
  // Lista para almacenar los registros
  List<CotizacionModel> _registros = [];

  // Método para agregar un nuevo registro
  void addRegister({
    int? indice, 
    required String descripcion,
    required double cantidad,
    required double precioUnitario,
    required double precioTotal,
  }) {
    CotizacionModel nuevaCotizacion = CotizacionModel(
      indice: indice,
      descripcion: descripcion,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
      precioTotal: precioTotal,
    );

    _registros.add(nuevaCotizacion);
  }

  // Método para obtener todos los registros como lista de JSON
  List<Map<String, dynamic>> getTable() {
    return _registros.map((cotizacion) => cotizacion.toJson()).toList();
  }

  // Método para obtener el precio total de un registro específico por descripción
  double? getPrecioTotalByDescripcion(String descripcion) {
    CotizacionModel? registro;

    try {
      registro = _registros.firstWhere((cotizacion) => cotizacion.descripcion == descripcion);
    } catch (e) {
      registro = null;
    }

    return registro?.precioTotal;
  }

  // Método para borrar todos los registros
  void clearAllRegisters() {
    _registros.clear();
  }

  // Método para vaciar la lista de registros
  void emptyRegisters() {
    _registros = [];
  }

  // Método total para sumar todos los precios totales y agregar un nuevo registro con el total
  void total() {
    double sumaTotal = 0.0;

    // Sumar todos los Precio_Total de los registros
    for (var cotizacion in _registros) {
      sumaTotal += cotizacion.precioTotal;
    }

    // Agregar un registro con la descripción 'TOTAL' y la suma de los precios
    addRegister(
      descripcion: "TOTAL",
      cantidad: 0.0, // No tiene cantidad, ya que es un total
      precioUnitario: 0.0, // No tiene precio unitario, ya que es un total
      precioTotal: sumaTotal,
    );
  }

  // Método para exportar los registros en formato JSON
  String exportToJson() {
    List<Map<String, dynamic>> table = getTable(); // Convertir registros a lista de mapas
    return jsonEncode(table); // Convertir la lista de mapas a una cadena JSON
  }
}
