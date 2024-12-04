import 'dart:ffi';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:optigas/config/parametros.dart';
import 'package:optigas/controllers/TablaController.dart';
import 'package:optigas/model/ElementModel.dart';
import 'package:optigas/model/TrazadoModel.dart';
import 'dart:convert';
import 'package:optigas/views/Render.dart';

class ResolveController {
  TablaController tablaController = TablaController();
  String ListaTrazadosJSON = "";

  //MAP PARA LOS NODOS Y LETRAS
  Map<String, String> mapaNodosConLetras = {};
  String NODOS_LETRAS = "";

  //cargar materiales y diametros
  // ---------------------------------- Método para cargar el archivo JSON de diametros
  Future<List<Map<String, dynamic>>> cargarMateriales() async {
    final String jsonString =
        await rootBundle.loadString('lib/assets/Tuberias.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> obtenerDiametrosGalvanizado() async {
    // Carga los materiales desde el JSON
    final materiales = await cargarMateriales();

    // Busca el material "Galvanizado" y obtiene su lista de diámetros
    final materialGalvanizado = materiales.firstWhere(
      (material) => material['name'] == 'Galvanizado',
      orElse: () => {},
    );

    // Retorna los diámetros o una lista vacía si no se encuentra
    return materialGalvanizado['Diametros']?.cast<Map<String, dynamic>>() ?? [];
  }

  Future<List<Map<String, dynamic>>> cargarEquipos() async {
    final String jsonString =
        await rootBundle.loadString('lib/assets/CatalogoEquipos.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((e) => e as Map<String, dynamic>).toList();
  }

  void llenarTabla() {
    // Llamar al método addRegister pasando los valores como parámetros
    tablaController.addRegister(
      indice: 1,
      tramo: "A-B",
      l: 10.5,
      leq: 9.8,
      qs: 5.2,
      dc: 1.5,
      dn: 1.2,
      dnr: "DNR123",
      mat: "PVC",
      pi: 1.0,
      deltaP: 0.3,
      pf: 1.2,
      v: 2.5,
      valido: true,
    );

    // Obtener la lista de registros en formato JSON
    List<Map<String, dynamic>> registrosJson = tablaController.getTable();

    // Imprimir los registros en formato JSON
    print(registrosJson);
  }

  Future<String?> resolve(List<Map<String, dynamic>> listaElementosJson) async {
    // Para borrar todos los registros
    tablaController.clearAllRegisters();
    //OBTENER LISTA DE DIAMETROS A UTILIZAR
    print(
        "################################################## IMPRESION DE DIAMETROS");
    final diametros = await obtenerDiametrosGalvanizado();
    print(diametros);

    print(
        "################################################## IMPRESION DE EQUIPOS");
    final equiposLista = await cargarEquipos();
    //print(equiposLista);

    //-------------------------------------------------------------------------- 1- Realizar el trazado de la instalación
    TrazarInstalacion(listaElementosJson);
    var json = jsonDecode(ListaTrazadosJSON);
    List tramos = json['Tramos'];

    //------------ IMPORTANTE OBTENER LA LISTA DE TRAMOS CON SUS NODOS Y LA LETRA
    print(
        '################################################## Cantidad de tramos: ${tramos.length}');
    print(
        '################################################## Impresionde tramos realizados: $tramos');

    //--------------------------------------------------------------------------- 2- Armar el ciclo para recorrer los tramos e ir llenando la tabla
    print(
        "################################################## IMPRESION De For");
    //declarar variables
    var indice,
        tramoActual,
        longitud,
        longEquivalente,
        Qs,
        Dc,
        Dn,
        Dnr,
        Material,
        Pi,
        DeltaP,
        Pf,
        V,
        Valido;

    //print(json);
    var VelocidadTope = 18.28;
    var TramosAceptados = 0;
    outerLoop:
    for (var diametro in diametros) {
      for (int i = 0; i <= tramos.length - 1; i++) {
        print("Tramo actual del for: " + tramos[i].toString());
        //ciclo para recorer cada diametro
        indice = i + 1;
        longitud = CalcularLongitudTramo(tramos[i]);
        longEquivalente = longitud * 1.2;
        Material = "Galvanizado";
        Dnr = diametro['name'];
        Dn = diametro['mm'];
        if (i == 0) {
          //si es el primer registro
          Qs = CalcularConsumoTotal(tramos,
              equiposLista); //Qs = la suma de todos los consumos de los equipos
          Pi = presionInicial - 1.2; //Pi = troncal - 1.2
        } else {
          // calcular consumo total del tramo
          print("Calculando qs....");
          Qs = CalcularConsumoEnTramo(tramos[i], equiposLista);
          print("Calculando tramo anterior....");
          var tramoAnterior = obtenerUltimoTramo(json, tramos[i].keys.first);
          print("Tramo anterior: $tramoAnterior");
          //IMPORTANTE, BUSCAR SI EN EL TRAMO ANTERIOR HAY UNA REGULADOR, SI HAY, TOMAR SU PRESION INICIAL COMO 21MBAR --- PENDIENTE
          Pi = tablaController.getPfByTramo(tramoAnterior.toString()) ??
              0.0; //buscar la presion final del tramo anterior
          //Pi = pf anterior
        }
        Pf = presionFinal(Pi, longEquivalente, Qs, Dn) ?? 0.0;
        DeltaP = Pi - Pf;
        V = calcularVelocidad(Qs, Pf, Dn) ?? 0.0;
        Dc = calcularDiametroCritico(Qs, Pf, VelocidadTope) ?? 0.0;
        //impresion de los valores
        print("Indice: $indice");
        print("Tramo: " + tramos[i].toString());
        print("Longitud: $longitud");
        print("Longitud Equivalente: $longEquivalente");
        print("Qs: $Qs");
        print("Dc: $Dc");
        print("Dn: $Dn");
        print("Dnr: $Dnr");
        print("Material: $Material");
        print("Pi: $Pi");
        print("DeltaP: $DeltaP");
        print("Pf: $Pf");
        print("V: $V");

        if (V < VelocidadTope && Dc < Dn) {
          Valido = true;
          print("Valido: $Valido");
          TramosAceptados++;
          tablaController.addRegister(
            indice: indice,
            tramo: tramos[i].keys.first,
            l: double.parse(longitud.toStringAsFixed(3)),
            leq: double.parse(longEquivalente.toStringAsFixed(3)),
            qs: double.parse(Qs.toStringAsFixed(3)),
            dc: double.parse(Dc.toStringAsFixed(3)),
            dn: double.parse(Dn.toStringAsFixed(3)),
            dnr: Dnr,
            mat: Material,
            pi: double.parse(Pi.toStringAsFixed(3)),
            deltaP: double.parse(DeltaP.toStringAsFixed(3)),
            pf: double.parse(Pf.toStringAsFixed(3)),
            v: double.parse(V.toStringAsFixed(3)),
            valido: Valido,
          );
          print("Ingresando registro a la tabla");
          print(tramos[i].keys.first +
              "-- " +
              longitud.toString() +
              "-- " +
              longEquivalente.toString() +
              "-- " +
              Qs.toString() +
              "-- " +
              Dc.toString() +
              "-- " +
              Dn.toString() +
              "-- " +
              Dnr +
              "-- " +
              Material +
              "-- " +
              Pi.toString() +
              "-- " +
              DeltaP.toString() +
              "-- " +
              Pf.toString() +
              "-- " +
              V.toString() +
              "-- " +
              Valido.toString());
        } else {
          //pasar al siguiente diametro
          continue;
        }
        //validar si ya termino y los tramos fueron aceptados
        if (TramosAceptados == tramos.length) {
          print("Se han aceptado todos los tramos");
          break outerLoop;
        }
      }
    }

    //fin del buble:
    // Obtener la lista de registros en formato JSON
    List<Map<String, dynamic>> registrosCalculados = tablaController.getTable();
    //print("################################################## IMPRESION DE REGISTROS");
    //print(registrosCalculados);

    // Convertir la lista de registros a un String JSON
    String registrosJson = jsonEncode(registrosCalculados);
    //regresar el json
    return registrosJson;
  }

//buscar el tramo si es bifurcacion
  String? obtenerUltimoTramo(Map<String, dynamic> data, String letra) {
    // Asegúrate de que la clave 'Tramos' existe y es una lista
    if (!data.containsKey("Tramos") || data["Tramos"] is! List) {
      throw ArgumentError("El objeto no contiene 'Tramos' o no es una lista");
    }

    // Extraer la lista de tramos
    List<Map<String, dynamic>> tramos =
        List<Map<String, dynamic>>.from(data["Tramos"]);

    // Extraer la letra inicial del tramo dado
    String letraFinal = letra.split('-').first;

    // Iterar por la lista de tramos
    for (var map in tramos) {
      // Cada mapa tiene una clave que representa el nombre del tramo
      String tramoNombre = map.keys.first;

      // Extraer la letra final del nombre del tramo (la parte después del '-')
      String letraInicial = tramoNombre.split('-').last;

      // Verificar si la letra final del tramo coincide con la letra inicial del tramo actual
      if (letraInicial == letraFinal) {
        return tramoNombre; // Retornar el nombre del tramo que cumple la condición
      }
    }

    // Retornar null si no se encuentra coincidencia
    return null;
  }

//calcular diametro calculado
  double? calcularDiametroCritico(double Qs, double Pf, double VTope) {
    /*
   * Calcula el diámetro crítico según la fórmula proporcionada.
   *
   * Parámetros:
   * Qs (double): Flujo volumétrico.
   * Pf (double): Presión final en unidades adecuadas.
   * VTope (double): Velocidad tope.
   *
   * Retorna:
   * double: Diámetro crítico calculado.
   * Null: En caso de un error matemático o de división por cero.
   */

    try {
      // Cálculo del diámetro crítico
      double dc = sqrt((354 * Qs) / ((Pf / 1000 + 0.818) * VTope));
      return dc;
    } on ArgumentError catch (e) {
      print(
          "Error matemático: $e (verifica que los valores proporcionados sean válidos)");
      return null;
    } on UnsupportedError {
      print("Error: División por cero (verifica los valores de VTope y Pf).");
      return null;
    }
  }

//calcular velocidad
  double? calcularVelocidad(double Qs, double Pf, double Dn) {
    /*
   * Calcula la velocidad según la fórmula proporcionada.
   *
   * Parámetros:
   * Qs (double): Flujo volumétrico.
   * Pf (double): Presión final en unidades adecuadas.
   * Dn (double): Diámetro nominal.
   *
   * Retorna:
   * double: Velocidad calculada.
   * Null: En caso de un error matemático o de división por cero.
   */

    try {
      // Cálculo de la velocidad
      double velocidad = 354 *
          Qs *
          pow((Pf / 1000 + 0.818), -1).toDouble() *
          pow(Dn, -2).toDouble();
      return velocidad;
    } on ArgumentError catch (e) {
      print(
          "Error matemático: $e (verifica que los valores proporcionados sean válidos)");
      return null;
    } on UnsupportedError {
      print(
          "Error: División por cero (verifica los valores de los parámetros, especialmente Dn y Pf).");
      return null;
    }
  }

//calcular Presion final
  double? presionFinal(double Pi, double Leq, double Qs, double Dn) {
    /*
   * Calcula la presión final según la fórmula proporcionada.
   *
   * Parámetros:
   * Pi (double): Presión inicial en unidades adecuadas.
   * Leq (double): Longitud equivalente.
   * Qs (double): Flujo volumétrico.
   * Dn (double): Diámetro nominal.
   *
   * Retorna:
   * double: Presión final calculada.
   * Null: En caso de un error matemático.
   */

    try {
      // Convertimos Pi a la escala adecuada
      double term1 = pow((Pi / 1000 + 0.818), 2).toDouble();
      double term2 =
          48.6 * 0.6 * Leq * pow(Qs, 1.82) * pow(Dn, -4.82).toDouble();
      double presion = sqrt(term1 - term2) - 0.818;
      return presion * 1000;
    } on ArgumentError catch (e) {
      print(
          "Error matemático: $e (verifica que los valores proporcionados sean válidos)");
      return null;
    } on UnsupportedError {
      print(
          "Error: División por cero (verifica los valores de los parámetros, especialmente Dn).");
      return null;
    }
  }

  //Calcular la longitud total del tramo
  double CalcularLongitudTramo(Map<String, dynamic> tramo) {
    double longitudTotal = 0.0;

    // Acceder al valor (lista de detalles) dentro del mapa
    for (var detalles in tramo.values) {
      for (var detalle in detalles) {
        // Verificar las condiciones para Elemento_tipo e ID_elemento
        if (detalle['Elemento_tipo'] == 1 && detalle['ID_elemento'] == 1) {
          longitudTotal += detalle['Longitud'];
          print(detalle);
        }
      }
    }

    return longitudTotal;
  }

  //function para calcular el consumo total
  double CalcularConsumoTotal(
      List ListaTramos, List<Map<String, dynamic>> ListaEquipos) {
    double consumoTotal = 0.0;

    // Iterar sobre cada tramo
    for (var tramo in ListaTramos) {
      tramo.forEach((clave, detalles) {
        // Iterar sobre los detalles en la lista del tramo
        for (var detalle in detalles) {
          // Verificar si Elemento_tipo es 3
          if (detalle['Elemento_tipo'] == 3) {
            // Buscar el equipo correspondiente en ListaEquipos
            var equipo = ListaEquipos.firstWhere(
                (e) => e['id'] == detalle['ID_elemento'],
                orElse: () => {});

            // Si se encuentra el equipo, sumar su consumo
            if (equipo != null) {
              consumoTotal += equipo['consumo'];
            }
          }
        }
      });
    }
    //print(consumoTotal);
    return consumoTotal;
  }

//function para buscar el consumo de un aparato
  double CalcularConsumoEnTramo(
      Map<String, dynamic> tramo, List<Map<String, dynamic>> ListaEquipos) {
    double consumoTotal = 0.0;

    // Iteramos sobre los detalles dentro del tramo
    for (var detalles in tramo.values) {
      for (var detalle in detalles) {
        // Verificamos si el Elemento_tipo es 3
        if (detalle['Elemento_tipo'] == 3) {
          // Usamos el ID_elemento para buscar el consumo en ListaEquipos
          var consumo =
              searchConsumoEnEquipo(detalle['ID_elemento'], ListaEquipos);
          consumoTotal += consumo;
        }
      }
    }

    return consumoTotal;
  }

  double searchConsumoEnEquipo(
      int id, List<Map<String, dynamic>> ListaEquipos) {
    // Buscar el equipo con el ID especificado
    var equipo = ListaEquipos.firstWhere(
      (e) => e['id'] == id,
      orElse: () => {},
    );

    // Si se encuentra, regresar el consumo, de lo contrario 0.0
    return equipo != null ? equipo['consumo'].toDouble() : 0.0;
  }

  void imprimir(List<Map<String, dynamic>> listaElementosJson) {
    print(listaElementosJson);
  }

  void TrazarInstalacion(List<Map<String, dynamic>> listaElementosJson) {
    // Crear una lista para almacenar los tramos
    List<Map<String, dynamic>> tramosJson = [];

    // Crear un mapa de nodos de inicio a sus elementos
    Map<String, List<Map<String, dynamic>>> nodos = {};

    // Llenamos el mapa de nodos con los elementos
    for (var elemento in listaElementosJson) {
      String nodoInicio = elemento['NodoIncio'];
      if (!nodos.containsKey(nodoInicio)) {
        nodos[nodoInicio] = [];
      }
      nodos[nodoInicio]!.add(elemento);
    }

    // Crear un conjunto para almacenar nodos únicos de inicio y fin de los tramos
    Set<String> nodosConexiones = {};

    // Procesar los tramos
    while (nodos.isNotEmpty) {
      // Comenzamos con el primer tramo que tomará un nodo de inicio
      List<Map<String, dynamic>> tramo = [];
      String nodoActual = nodos.keys.first;

      // Agregar el nodo inicial del tramo a los nodos de conexiones
      String nodoInicioTramo = nodoActual;
      nodosConexiones.add(nodoInicioTramo);

      // Mientras haya elementos en el nodo actual, los procesamos
      String nodoFinalTramo =
          nodoInicioTramo; // Por defecto, el nodo final es el inicial
      while (nodos.containsKey(nodoActual) && nodos[nodoActual]!.isNotEmpty) {
        // Tomamos el primer elemento del nodo actual
        var elemento = nodos[nodoActual]!.removeAt(0);
        tramo.add(elemento);

        // Actualizar el nodo final del tramo
        nodoFinalTramo = elemento['NodoFin'];

        // Si el nodo de fin de este elemento tiene más conexiones o cumple la condición especial
        if ((nodos.containsKey(nodoFinalTramo) &&
                nodos[nodoFinalTramo]!.length > 1) ||
            (elemento['Elemento_tipo'] == 2 && elemento['ID_elemento'] == 1)) {
          // Si hay bifurcación o condición especial, terminamos el tramo
          break;
        }

        // Si no, continuamos con el nodo de fin
        nodoActual = nodoFinalTramo;
      }

      // Agregar el nodo final del tramo a los nodos de conexiones
      nodosConexiones.add(nodoFinalTramo);

      // Guardamos el tramo procesado en el formato requerido
      String nodoInicioLetras = String.fromCharCode(
          65 + nodosConexiones.toList().indexOf(nodoInicioTramo));
      String nodoFinLetras = String.fromCharCode(
          65 + nodosConexiones.toList().indexOf(nodoFinalTramo));
      String tramoClave = "$nodoInicioLetras-$nodoFinLetras";

      // Crear un mapa para el tramo y agregarlo a la lista de tramos JSON
      tramosJson.add({
        tramoClave: tramo.map((elemento) {
          return {
            'ID_incremental': elemento['ID_incremental'],
            'Elemento_tipo': elemento['Elemento_tipo'],
            'ID_elemento': elemento['ID_elemento'],
            'Longitud': elemento['Longitud'],
            'NodoInicio': elemento['NodoIncio'],
            'NodoFin': elemento['NodoFin'],
            'Direccion': elemento['Direccion']
          };
        }).toList()
      });

      // Eliminar los nodos que ya no tienen más elementos
      nodos.removeWhere((key, value) => value.isEmpty);
    }

    // Asignar letras a los nodos de conexión
    List<String> nodosOrdenados = nodosConexiones.toList();
    Map<String, String> mapaNodosConLetras = {};
    for (int i = 0; i < nodosOrdenados.length; i++) {
      mapaNodosConLetras[nodosOrdenados[i]] = String.fromCharCode(65 + i);
    }

    // Crear el mapa final para el JSON
    Map<String, dynamic> resultadoJson = {
      'Tramos': tramosJson,
      'Puntos de conexión': mapaNodosConLetras.entries.map((nodo) {
        return {'Punto': nodo.value, 'Nodo': nodo.key};
      }).toList()
    };

    // Convertir el resultado a un String JSON
    ListaTrazadosJSON = jsonEncode(resultadoJson);

  //ARMAR  JSON DE NODOS Y LETRAS
  List<Map<String, String>> nodoslETRAS = [];
  print("Nodos y sus letras asignadas:");
  mapaNodosConLetras.forEach((nodo, letra) {
    // Agregar a la lista como un objeto JSON
    nodoslETRAS.add({"nodo": nodo, "letra": letra});
    print("NODO: $nodo, LETRA: $letra");
  });
  NODOS_LETRAS = jsonEncode(nodoslETRAS);
  

    // Imprimir el JSON resultante
    //print(resultadoJson);
  }

  String getNodosLetras() {
    return NODOS_LETRAS;
  }
}
