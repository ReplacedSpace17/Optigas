import 'dart:ffi';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:optigas/config/parametros.dart';
import 'package:optigas/controllers/CotizacionController.dart';
import 'package:optigas/controllers/TablaController.dart';
import 'package:optigas/model/ElementModel.dart';
import 'package:optigas/model/TrazadoModel.dart';
import 'dart:convert';
import 'package:optigas/views/Render.dart';

class CotizacionCreate {
  CotizacionController cotizacion = CotizacionController();
  String Lista = "";

  Future<String> crear_Cotizacion(String tablaTramos, String tablaElementos) async {
        cotizacion.emptyRegisters();
    print(
        "------------------------------------------------------------------------ Cotizacion");

    print(tablaTramos);
    print(tablaElementos);

    // Decodificar el JSON de tablaTramos
    final List<dynamic> tramos = jsonDecode(tablaTramos);
    final List<dynamic> elementos = jsonDecode(tablaElementos);

    // 1- Cuadro de regulacion, dependiendo del tramo troncal
    if (tramos.isNotEmpty) {
      final double dn = tramos[0]['Dn'];
      var cuadroRegulador = await buscar_cuadro_regulador(dn);
      print("El valor de Dn del primer tramo es: $cuadroRegulador");
      //--------------------------------------------------------------------------- Add a la lista
      var cant = 1;
      cotizacion.addRegister(
          descripcion: "Cuadro de regulación",
          cantidad: cant.toDouble(),
          precioUnitario: cuadroRegulador,
          precioTotal: cant * cuadroRegulador);
    } else {
      print("No hay registros en tablaTramos.");
    }
    //2 - Metros totales de tuberias

// Mapa para almacenar la suma de L para cada combinación de Dn y Dnr
    final Map<String, double> resumen = {};

    // Recorrer cada tramo
    for (var tramo in tramos) {
      final dn = tramo['Dn'];
      final dnr = tramo['Dnr'];
      final l = tramo['L'];
      final mat = tramo['Mat'];

      // Crear una clave única para la combinación de Dn y Dnr
      final clave = 'Mat: $mat, Dn: $dn, Dnr: $dnr';

      // Sumar la longitud (L) a la clave correspondiente
      if (resumen.containsKey(clave)) {
        resumen[clave] = resumen[clave]! + l;
      } else {
        resumen[clave] = l;
      }
    }

    // Imprimir el resultado
    resumen.forEach((clave, metros) async {
      // Imprimir los detalles de manera separada
      final parts = clave.split(', ');
      final mat = parts[0].split(': ')[1]; // Extraer Material
      final dn = parts[1].split(': ')[1]; // Extraer Dn
      final dnr = parts[2].split(': ')[1]; // Extraer Dnr
      var costo = await buscar_precio_tuberia(mat, double.parse(dn));
      var total = costo * metros;
      print(
          'Material: $mat, Dn: $dn, Dnr: $dnr -> Total L: ${metros.toStringAsFixed(2)} metros, Costo/metro: $costo, Costo total: $total');

      cotizacion.addRegister(
          descripcion: 'Tuberia de $mat, Dnr: $dnr',
          cantidad: metros,
          precioUnitario: costo,
          precioTotal: total);
    });

    //3 - Valvulas o llaves
    int valvulas = contarElementos(tablaElementos, 2, 3);
    double costoValvulas = await buscar_precio_accesorios(3);
    var costoTotalValvulas = valvulas * costoValvulas;
    print("Valvulas: $valvulas, Costo: $costoTotalValvulas");
    //agregar el costo de las valvulas a la lista
    cotizacion.addRegister(
        descripcion: 'Valvulas',
        cantidad: valvulas.toDouble(),
        precioUnitario: costoValvulas,
        precioTotal: costoTotalValvulas);

    //4 - Costo por equipos
    double totalCostoEquipo = 0.0;
    Map<String, Map<String, dynamic>> resumenCategorias =
        {}; // Para almacenar información por categoría

    for (var elemento in elementos) {
      if (elemento['Elemento_tipo'] == 3) {
        // Buscar el precio del equipo
        var costoEquipo = await buscar_precio_equipo(elemento['ID_elemento']);
        var categoria = await buscar_categoria_equipo(elemento['ID_elemento']);

        // Si la categoría aún no existe en el resumen, inicializa su mapa
        if (!resumenCategorias.containsKey(categoria)) {
          resumenCategorias[categoria] = {
            'cantidad': 0,
            'costo_unitario': costoEquipo,
            'costo_total': 0.0
          };
        }

        // Acumular información en el resumen por categoría
        resumenCategorias[categoria]?['cantidad']++;
        resumenCategorias[categoria]?['costo_total'] += costoEquipo;

        totalCostoEquipo += costoEquipo;
      }
    }

// Imprimir resumen por categoría
    resumenCategorias.forEach((categoria, datos) {
      cotizacion.addRegister(
          descripcion: 'Equipo de $categoria',
          cantidad: datos['cantidad'].toDouble(),
          precioUnitario: datos['costo_unitario'],
          precioTotal: datos['costo_total']);
      print("Categoría: $categoria");
      print("  Cantidad de equipos: ${datos['cantidad']}");
      print("  Costo unitario: ${datos['costo_unitario']}");
      print("  Costo total: ${datos['costo_total']}");
    });

    print("Total costo equipos: $totalCostoEquipo");

    //agregar el costo de los equipos a la lista

    //imprimir la lista
    cotizacion.total();
    cotizacion.getTable().forEach((element) {
      print(element);
    });

    //5 - Exportar la lista a JSON
    return cotizacion.exportToJson();
  }

Future<String> getLista() async {
  return cotizacion.exportToJson();
}

//Buscar el precio de un accesorio
  Future<double> buscar_precio_accesorios(int id) async {
    // Cargar el archivo JSON
    final String accesoriosJson =
        await rootBundle.loadString('lib/assets/CatalogoAccesorios.json');

    // Decodificar el JSON en una lista
    final List<dynamic> accesorios = jsonDecode(accesoriosJson);

    // Buscar el accesorio por id
    final accesorio = accesorios.firstWhere(
      (a) => a['id'] == id,
      orElse: () => null,
    );

    // Manejar el caso donde el accesorio no se encuentra
    if (accesorio == null) {
      print('Accesorio con ID $id no encontrado.');
      return 0.0; // Retorna 0.0 si no encuentra el accesorio
    }

    // Retornar el costo del accesorio
    return accesorio['costo'].toDouble();
  }

//buscar el precio de un equipo
  Future<double> buscar_precio_equipo(int id) async {
    // Cargar los JSONs
    final String equiposJson =
        await rootBundle.loadString('lib/assets/CatalogoEquipos.json');
    final String costosJson =
        await rootBundle.loadString('lib/assets/Costos.json');

    // Decodificar los JSONs
    final List<dynamic> equipos = jsonDecode(equiposJson);
    final List<dynamic> costosCategorias = jsonDecode(costosJson);

    // Buscar el equipo por id
    final equipo = equipos.firstWhere((e) => e['id'] == id, orElse: () => null);

    if (equipo == null) {
      print('Equipo con ID $id no encontrado.');
      return 0.0; // Retorna 0.0 si no se encuentra el equipo
    }

    // Obtener la categoría del equipo
    final String categoria = equipo['categoria'];

    // Buscar el costo de la categoría
    final costos = costosCategorias[0]['Equipos'];
    final costoCategoria = costos.firstWhere(
      (c) => c['Categoria'].toLowerCase() == categoria.toLowerCase(),
      orElse: () => null,
    );

    if (costoCategoria == null) {
      print('Costo para la categoría "$categoria" no encontrado.');
      return 0.0; // Retorna 0.0 si no se encuentra la categoría
    }
    //print("Costo: ${costoCategoria['Costo']}");
    // Retornar el costo encontrado
    return costoCategoria['Costo'].toDouble();
  }

//buscar la categoria
  Future<String> buscar_categoria_equipo(int id) async {
    // Cargar los JSONs
    final String equiposJson =
        await rootBundle.loadString('lib/assets/CatalogoEquipos.json');
    final String costosJson =
        await rootBundle.loadString('lib/assets/Costos.json');

    // Decodificar los JSONs
    final List<dynamic> equipos = jsonDecode(equiposJson);
    final List<dynamic> costosCategorias = jsonDecode(costosJson);

    // Buscar el equipo por id
    final equipo = equipos.firstWhere((e) => e['id'] == id, orElse: () => null);

    if (equipo == null) {
      print('Equipo con ID $id no encontrado.');
      return ''; // Retorna una cadena vacía si no se encuentra el equipo
    }

    // Obtener la categoría del equipo
    final String categoria = equipo['categoria'];

    // Regresar la categoría del equipo
    return categoria;
  }

//Buscar el precio de tuberia
  Future<double> buscar_precio_tuberia(String name, double diameter) async {
    // Cargar el archivo JSON
    final String tuberiasJson =
        await rootBundle.loadString('lib/assets/Tuberias.json');
    //print("Tuberias: $tuberiasJson");

    // Decodificar el JSON
    final List<dynamic> tuberias = jsonDecode(tuberiasJson);

    // Buscar el material por nombre
    final material = tuberias.firstWhere(
      (t) => t['name'] == name,
      orElse: () => null,
    );

    // Si no se encuentra el material, retornar 0.0
    if (material == null) {
      print('Material "$name" no encontrado.');
      return 0.0;
    }

    // Buscar el diámetro correspondiente
    final diametro = material['Diametros'].firstWhere(
      (d) => d['mm'] == diameter,
      orElse: () => null,
    );

    // Si no se encuentra el diámetro, retornar 0.0
    if (diametro == null) {
      print('Diámetro $diameter mm no encontrado para el material "$name".');
      return 0.0;
    }

    // Retornar el precio del diámetro
    return diametro['price'].toDouble();
  }

//buscar el precio del cuadro regulador
  Future<double> buscar_cuadro_regulador(double diameter) async {
    // Cargar el archivo JSON
    final String cuadrosJson =
        await rootBundle.loadString('lib/assets/Costos.json');

    // Decodificar el JSON a un mapa
    final List<dynamic> data = jsonDecode(cuadrosJson);

    // Buscar el cuadro regulador con el diámetro especificado
    for (var item in data) {
      if (item['CuadroRegulacion'] != null) {
        for (var cuadro in item['CuadroRegulacion']) {
          if (cuadro['Diametro_mm'] == diameter) {
            return cuadro['Costo']
                .toDouble(); // Regresar el costo si se encuentra
          }
        }
      }
    }

    // Si no se encuentra el diámetro, retornar 0.0 o lanzar una excepción
    return 0.0;
  }

//Buscar cantidad de valvulas
  int contarElementos(String tablaElementos, int tipo, int idElemento) {
    // Decodificar el JSON de tablaElementos
    final List<dynamic> elementos = jsonDecode(tablaElementos);

    // Filtrar y contar los registros que cumplen con las condiciones
    final int count = elementos.where((elemento) {
      return elemento['Elemento_tipo'] == tipo &&
          elemento['ID_elemento'] == idElemento;
    }).length;

    return count;
  }

//-------------------- Cargar jsons --------------------
//tuberias
  Future<List<Map<String, dynamic>>> cargarJson(String ruta) async {
    final String jsonString = await rootBundle.loadString(ruta);
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((e) => e as Map<String, dynamic>).toList();
  }
}
