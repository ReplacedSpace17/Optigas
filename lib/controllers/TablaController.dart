import 'package:optigas/model/TrazadoModel.dart';

class TablaController {
  // Lista para almacenar los registros
  List<TrazadoModel> _registros = [];

  // Método para agregar un nuevo registro, recibiendo los parámetros individuales
  void addRegister({
    required int indice,
    required String tramo,
    required double l,
    required double leq,
    required double qs,
    required double dc,
    required double dn,
    required String dnr,
    required String mat,
    required double pi,
    required double deltaP,
    required double pf,
    required double v,
    required bool valido,
  }) {
    // Crear una nueva instancia de TrazadoModel usando los parámetros
    TrazadoModel nuevoTrazado = TrazadoModel(
      indice: indice,
      tramo: tramo,
      l: l,
      leq: leq,
      qs: qs,
      dc: dc,
      dn: dn,
      dnr: dnr,
      mat: mat,
      pi: pi,
      deltaP: deltaP,
      pf: pf,
      v: v,
      valido: valido,
    );

    // Agregar el nuevo registro a la lista
    _registros.add(nuevoTrazado);
  }

  // Método para obtener todos los registros como lista de JSON
  List<Map<String, dynamic>> getTable() {
    // Convertir cada TrazadoModel a JSON
    return _registros.map((trazado) => trazado.toJson()).toList();
  }

  // Método para obtener el valor de pf de un registro específico por tramo
  double? getPfByTramo(String tramo) {
    TrazadoModel? registro;

    try {
      // Intentar encontrar el registro
      registro = _registros.firstWhere((trazado) => trazado.tramo == tramo);
    } catch (e) {
      // Si no se encuentra, manejar la excepción
      registro = null;
    }

    // Retornar el valor de pf si se encuentra el registro, o null si no existe
    return registro?.pf;
  }

  // Método para borrar todos los registros y resetear la lista
  void clearAllRegisters() {
    _registros.clear();
  }
}
