import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:optigas/config/Left_movement_config.dart';
import 'package:optigas/config/Right_movement_config.dart';
import 'package:optigas/config/parametros.dart';
import 'package:optigas/controllers/CotizacionCreate.dart';
import 'package:optigas/controllers/ElementController.dart';
import 'package:optigas/controllers/Resolve_controller.dart';
import 'package:optigas/controllers/Uuid_Controller.dart';
import 'package:optigas/views/Render.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:optigas/views/ScreenResults.dart';

// Método para cargar el archivo JSON
Future<List<Map<String, dynamic>>> cargarCatalogoEquipos() async {
  final String jsonString =
      await rootBundle.loadString('lib/assets/CatalogoEquipos.json');
  final List<dynamic> jsonData = json.decode(jsonString);
  return jsonData.map((e) => e as Map<String, dynamic>).toList();
}

Future<List<Map<String, dynamic>>> cargarCatalogoAccesorios() async {
  final String jsonString =
      await rootBundle.loadString('lib/assets/CatalogoAccesorios.json');
  final List<dynamic> jsonData = json.decode(jsonString);
  return jsonData.map((e) => e as Map<String, dynamic>).toList();
}

class IsometricoScreen extends StatefulWidget {
  @override
  _IsometricoScreenState createState() => _IsometricoScreenState();
}

class _IsometricoScreenState extends State<IsometricoScreen> {
// escala para figuras
  final double scaleFactor = 0.5; // Escala para reducir la figura a la mitad

  Offset offset = Offset(0, 0);
  Offset? selectedPoint;
  int? selectedPointIndex;
  final List<Map<String, dynamic>> pointsWithIds = [];
  final List<Map<String, Offset>> lines = []; // Lista de líneas para dibujar
  final List<Map<String, dynamic>> nodosLetras = []; // Lista de nodos y letras

  //figuras
  final List<Map<String, dynamic>> figuras = [];
  //elementos en canvas como accesorios y equipos
  final List<Map<String, dynamic>> iconos = [];

  final ElementoController elementoController = ElementoController();
  final IdController idController = IdController();

//
  // Crear instancia del controlador para resolver el isolmétrico
  ResolveController resolveController = ResolveController();

// crear instancia para generar la ccotizacion
  CotizacionCreate cotizacion = CotizacionCreate();

  ///

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        offset = Offset(size.width / 2, size.height / 2);
      });
      addPoint(0, 0, true);
    });

    //agregar figuras inicial
    figuras.clear();
    figuras.add({
      "coordenadaInicialX": 0.0, // Coordenada inicial en X
      "coordenadaInicialY": 0.0, // Coordenada inicial en Y
      "instructions": [
        // Línea vertical de arriba a abajo (startX, startY)
        {
          "type": "line",
          "is_node": true,
          "points": [
            {"dx": 0.0 * scaleFactor, "dy": 0.0 * scaleFactor},
            {"dx": 0.0 * scaleFactor, "dy": 20.0 * scaleFactor}
          ]
        },
        // Línea vertical adicional (startX - 20, startY)
        {
          "type": "line",
          "is_node": false,
          "points": [
            {"dx": -20.0 * scaleFactor, "dy": 0.0 * scaleFactor},
            {"dx": -20.0 * scaleFactor, "dy": 20.0 * scaleFactor}
          ]
        },
        // Varias líneas para la base y las diagonales
        {
          "type": "line",
          "is_node": false,
          "points": [
            {"dx": 10.0 * scaleFactor, "dy": 20.0 * scaleFactor},
            {"dx": -30.0 * scaleFactor, "dy": 20.0 * scaleFactor}
          ]
        },
        {
          "type": "line",
          "is_node": false,
          "points": [
            {"dx": -30.0 * scaleFactor, "dy": 20.0 * scaleFactor},
            {"dx": -30.0 * scaleFactor, "dy": 60.0 * scaleFactor}
          ]
        },
        {
          "type": "line",
          "is_node": false,
          "points": [
            {"dx": 10.0 * scaleFactor, "dy": 20.0 * scaleFactor},
            {"dx": 10.0 * scaleFactor, "dy": 60.0 * scaleFactor}
          ]
        },
        {
          "type": "line",
          "is_node": false,
          "points": [
            {"dx": -30.0 * scaleFactor, "dy": 60.0 * scaleFactor},
            {"dx": 10.0 * scaleFactor, "dy": 60.0 * scaleFactor}
          ]
        },
        // Detalles internos (cruces dentro del rectángulo)
        {
          "type": "line",
          "is_node": false,
          "points": [
            {"dx": 0.0 * scaleFactor, "dy": 30.0 * scaleFactor},
            {"dx": -20.0 * scaleFactor, "dy": 30.0 * scaleFactor}
          ]
        },
        {
          "type": "line",
          "is_node": false,
          "points": [
            {"dx": 0.0 * scaleFactor, "dy": 40.0 * scaleFactor},
            {"dx": -20.0 * scaleFactor, "dy": 40.0 * scaleFactor}
          ]
        },
        {
          "type": "line",
          "is_node": false,
          "points": [
            {"dx": 0.0 * scaleFactor, "dy": 30.0 * scaleFactor},
            {"dx": 0.0 * scaleFactor, "dy": 40.0 * scaleFactor}
          ]
        },
        {
          "type": "line",
          "is_node": false,
          "points": [
            {"dx": -20.0 * scaleFactor, "dy": 30.0 * scaleFactor},
            {"dx": -20.0 * scaleFactor, "dy": 40.0 * scaleFactor}
          ]
        },
        // Lado izquierdo y círculo exterior
        {
          "type": "line",
          "is_node": false,
          "points": [
            {"dx": -20.0 * scaleFactor, "dy": 0.0 * scaleFactor},
            {"dx": -90.0 * scaleFactor, "dy": 0.0 * scaleFactor}
          ]
        },
        {
          "type": "line",
          "is_node": false,
          "points": [
            {"dx": -90.0 * scaleFactor, "dy": 0.0 * scaleFactor},
            {"dx": -90.0 * scaleFactor, "dy": 60.0 * scaleFactor}
          ]
        },
        // Círculo exterior
        {
          "type": "circle",
          "is_node": false,
          "center": {"dx": -90.0 * scaleFactor, "dy": 80.0 * scaleFactor},
          "radius": 20.0 * scaleFactor
        },
        // Círculo interior
        {
          "type": "circle",
          "is_node": false,
          "center": {"dx": -90.0 * scaleFactor, "dy": 80.0 * scaleFactor},
          "radius": 10.0 * scaleFactor
        },
        // Líneas de la base del círculo
        {
          "type": "line",
          "is_node": false,
          "points": [
            {"dx": -90.0 * scaleFactor, "dy": 120.0 * scaleFactor},
            {"dx": -90.0 * scaleFactor, "dy": 100.0 * scaleFactor}
          ]
        },
        {
          "type": "line",
          "is_node": false,
          "points": [
            {"dx": -70.0 * scaleFactor, "dy": 120.0 * scaleFactor},
            {"dx": -110.0 * scaleFactor, "dy": 120.0 * scaleFactor}
          ]
        },
        {
          "type": "line",
          "is_node": false,
          "points": [
            {"dx": -70.0 * scaleFactor, "dy": 150.0 * scaleFactor},
            {"dx": -110.0 * scaleFactor, "dy": 150.0 * scaleFactor}
          ]
        },
        {
          "type": "line",
          "is_node": false,
          "points": [
            {"dx": -110.0 * scaleFactor, "dy": 120.0 * scaleFactor},
            {"dx": -70.0 * scaleFactor, "dy": 150.0 * scaleFactor}
          ]
        },
        {
          "type": "line",
          "is_node": false,
          "points": [
            {"dx": -70.0 * scaleFactor, "dy": 120.0 * scaleFactor},
            {"dx": -110.0 * scaleFactor, "dy": 150.0 * scaleFactor}
          ]
        },
        {
          "type": "line",
          "is_node": false,
          "points": [
            {"dx": -90.0 * scaleFactor, "dy": 150.0 * scaleFactor},
            {"dx": -90.0 * scaleFactor, "dy": 170.0 * scaleFactor}
          ]
        }
      ]
    });
  }

  Future<List<dynamic>> searchInstruccions(int tipo, int id) async {
    if (tipo == 2) {
      // Buscar en accesorios la instrucción
      final accesorios = await cargarCatalogoAccesorios();
      // Buscar el accesorio con el ID correspondiente
      var accesorio =
          accesorios.firstWhere((item) => item['id'] == id, orElse: () => {});
      if (accesorio != null) {
        return accesorio['instructions'];
      } else {
        print("No se encontró un accesorio con el ID $id.");
        return [];
      }
    } else if (tipo == 3) {
      // Buscar en equipos la instrucción
      final equipos = await cargarCatalogoEquipos();
      // Buscar el equipo con el ID correspondiente
      var equipo =
          equipos.firstWhere((item) => item['id'] == id, orElse: () => {});
      if (equipo != null) {
        return equipo['instructions'];
      } else {
        print("No se encontró un equipo con el ID $id.");
        return [];
      }
    } else {
      print("Tipo no válido. Use 2 para accesorios o 3 para equipos.");
      return [];
    }
  }

  ///function para agregar una figura
  Future<void> _add_icon(
      int id_elemento, int id_icon, double longitud, String direccion) async {
    //definir si id_elemento = 2 o 3, donde 2 es accesorios y 3 equipos
    var isSelectionable = false;
    var instrucciones = await searchInstruccions(id_elemento, id_icon);
    if (id_elemento == 2) {
      //accesorios
      isSelectionable = true;
    }
    if (id_elemento == 3) {
      //Equipos
      isSelectionable = false;
    }

    //obtener la direccion
// Determinar la función de dirección basada en la disposición
    Offset Function(String direccion, double longitud) obtenerDireccion;

    if (disposicion == 'izquierda') {
      obtenerDireccion = GetDirectionControlLeft;
    } else if (disposicion == 'derecha') {
      obtenerDireccion = GetDirectionControlRight;
    } else {
      // Puedes agregar un manejo para disposiciones no definidas si es necesario
      return;
    }

    //nodo inicio
    final nodoInicio = pointsWithIds[selectedPointIndex!];
    final point = nodoInicio['point'] as Offset;
    final startX = point.dx;
    final startY = point.dy;

    // Calcular la posición final
    final Offset nodoFinOffset =
        nodoInicio['point'] + obtenerDireccion(direccion, longitud);

    final endX = nodoFinOffset.dx;
    final endY = nodoFinOffset.dy;
    //agregar json
    var contenido = {
      "coordenadaInicialX": startX, // Coordenada inicial en X
      "coordenadaInicialY": startY, // Coordenada inicial en Y
      "instructions": instrucciones,
      "coordenadaFinalX": endX,
      "coordenadaFinalY": endY
    };
    //iconos.add(content);
    print(contenido);
    //agregar a la lista de dibujos
    iconos.add(contenido);
    addPoint(endX, endY, isSelectionable); //agregar el punto final
    //agregar a la lista de elementos
    elementoController.addElemento(
      elementoTipo: id_elemento,
      idElemento: id_icon,
      longitud: longitud,
      nodoInicio: nodoInicio['id'],
      nodoFin: pointsWithIds.last['id'],
      direccion: direccion,
    );
    print("Se han agregado elementos:");
    print(elementoController.getListaJson());
  }

  void addPoint(double x, double y, bool isSelectable) {
    setState(() {
      pointsWithIds.add({
        'id': idController.generateId(),
        'point': Offset(x, y),
        'isSeleccionable': isSelectable,
      });
    });
  }

  void _onTapDown(TapDownDetails details) {
    final localPosition = details.localPosition - offset;
    final selected = pointsWithIds.indexWhere((p) =>
        (localPosition - p['point'] as Offset).distance <= 10.0 &&
        p['isSeleccionable'] as bool);

    setState(() {
      selectedPointIndex = selected != -1 ? selected : null;
      selectedPoint = selectedPointIndex != null
          ? pointsWithIds[selectedPointIndex!]['point']
          : null;
    });

    if (selectedPointIndex != null) {
      final point = pointsWithIds[selectedPointIndex!];
      final coords =
          '(${point['point'].dx.toStringAsFixed(2)}, ${point['point'].dy.toStringAsFixed(2)})';
      _showSnackBar("Punto seleccionado: ${point['id']} $coords");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _calcular() async {
    print("Limpiando iconos");
    iconos.clear();
    //tipo_elemento, id, longitud, direccion
    _add_icon(2, 3, 2, 'Arriba');
    /*
    // Obtener la lista de elementos (como Map<String, dynamic>)
    final listaElementosJson = elementoController.getListaJson();
    final listaElementosJsonComillas = elementoController.getJsonComillas();

//pasar la lista  al controlador
//resolveController.imprimir(listaElementosJson);

    var TablaCalculada = await resolveController.resolve(listaElementosJson);
    print(
        "################################################## - TABLA CALCULADA");
    print(TablaCalculada);

    //String lista = resolveController.procesarNodosYGenerarJson(listaElementosJson);

    //obtener las letras de los nodos para dibujar en el canvas

    //Calcular la cotizacion
    var tablaCotizacion = await cotizacion.crear_Cotizacion(
        TablaCalculada.toString(), listaElementosJsonComillas.toString());
    print(tablaCotizacion);
    //obtener las listas de calculos y de elementos
    var nodosLetras = resolveController.getNodosLetras();
    print(nodosLetras);
    print("PointWithIds");
    print(pointsWithIds);

    _searchNodos(nodosLetras);

//imprimir la tabla calculada
    print(
        "Cantidad de registros en Tabla Calculada: ${TablaCalculada?.length}");

    //navegar a la pantalla de resultados si existe registros en la tabla cotizacion
    if (TablaCalculada!.length > 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            tablaCalculada: TablaCalculada,
            tablaCotizacion: tablaCotizacion,
          ),
        ),
      );
    } else {
      _showSnackBar("No existen tramos para calcular");
    }
  }

  void _searchNodos(List<Map<String, dynamic>> listaNodosLetras) {
    nodosLetras.clear();
    // Buscar las letras de los nodos y dibujarlas en el canvas
    for (var nodoLetra in listaNodosLetras) {
      String nodoId = nodoLetra['nodo'];
      String letra = nodoLetra['letra'];

      // Buscar el nodo en pointsWithIds usando el id
      var nodo = pointsWithIds.firstWhere(
        (point) => point['id'] == nodoId,
        orElse: () => {}, // Si no se encuentra, devuelve null
      );

      if (nodo != null) {
        // Obtener las coordenadas del nodo
        Offset nodoPoint = nodo['point'];

        // Aquí puedes dibujar la letra en el canvas
        // Ajusta la posición para que la letra esté a un lado del nodo
        double offsetX = nodoPoint.dx + 20; // Desplazamiento horizontal
        double offsetY = nodoPoint.dy + 30; // Mantener la misma altura

        // Agregar la letra y su posición a la lista para dibujar
        nodosLetras.add({'letra': letra, 'position': Offset(offsetX, offsetY)});

        //agregar figuras

        //imprimir las posicion de las letras
        print("Posicion de la letra");
        print("X: $offsetX");
        print("Y: $offsetY");
      }
    }

    */
  }

  void _showMenuTuberias() {
    if (selectedPointIndex == null) {
      _showSnackBar(
          "Selecciona un nodo de inicio antes de agregar un elemento.");
      return;
    }

    final longitudController = TextEditingController();
    String? direccion;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Insertar tubería"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(
              controller: longitudController,
              label: "Longitud",
              hint: "Introduce un número",
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            _buildDropdown(
              value: direccion,
              items: [
                "Arriba",
                "Abajo",
                "Izquierda",
                "Derecha",
                "Frente",
                "Atrás"
              ],
              label: "Selecciona la dirección",
              onChanged: (value) => direccion = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              final longitud = double.tryParse(longitudController.text);
              if (longitud != null && direccion != null) {
                _addElemento(1, longitud, direccion!, '1');
              } else {
                _showSnackBar(
                    "Por favor completa todos los campos correctamente.");
              }
              Navigator.pop(context);
            },
            child: Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  void _showMenuEquipos() async {
    // Cargar los datos del JSON
    final equipos = await cargarCatalogoEquipos();
    final nombresEquipos =
        equipos.map((equipo) => equipo['nombre'].toString()).toList();

    String? direccion;
    String? equipoSeleccionado;
    String? categoriaSeleccionada;
    String? idEquipo;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("Insertar Equipos"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDropdown(
                value: direccion,
                items: [
                  "Arriba",
                  "Abajo",
                  "Izquierda",
                  "Derecha",
                  "Frente",
                  "Atrás"
                ],
                label: "Selecciona la dirección",
                onChanged: (value) => setState(() => direccion = value),
              ),
              SizedBox(height: 16),
              _buildDropdown(
                value: equipoSeleccionado,
                items: nombresEquipos, // Usar nombres desde el JSON
                label: "Selecciona el equipo",
                onChanged: (value) {
                  setState(() {
                    equipoSeleccionado = value;
                    // Buscar la categoría del equipo seleccionado
                    final equipo = equipos.firstWhere(
                      (e) => e['nombre'] == equipoSeleccionado,
                      orElse: () => {},
                    );
                    categoriaSeleccionada = equipo['categoria'];
                    idEquipo = equipo['id'];
                  });
                },
              ),
              SizedBox(height: 16),
              if (categoriaSeleccionada != null) // Mostrar categoría si existe
                Row(
                  children: [
                    Text(
                      "Categoría:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Text(categoriaSeleccionada!),
                  ],
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (direccion != null && equipoSeleccionado != null) {
                  // Implementa la lógica para manejar el equipo seleccionado
                  _addElemento(3, 2.5, direccion!, '1');
                  print("Equipo seleccionado: $equipoSeleccionado");
                  print("Dirección seleccionada: $direccion");
                } else {
                  _showSnackBar(
                      "Por favor completa todos los campos correctamente.");
                }
                Navigator.pop(context);
              },
              child: Text("Aceptar"),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenuAccesorios() async {
    // Cargar los datos del JSON
    final accesorios = await cargarCatalogoAccesorios();
    final nombresAccesorios =
        accesorios.map((accesorio) => accesorio['nombre'].toString()).toList();

    String? direccion;
    String? accesorioSeleccionado;
    String? idAccesorio;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("Insertar Accesorios"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDropdown(
                value: direccion,
                items: [
                  "Arriba",
                  "Abajo",
                  "Izquierda",
                  "Derecha",
                  "Frente",
                  "Atrás"
                ],
                label: "Selecciona la dirección",
                onChanged: (value) => setState(() => direccion = value),
              ),
              SizedBox(height: 16),
              _buildDropdown(
                value: accesorioSeleccionado,
                items: nombresAccesorios, // Usar nombres desde el JSON
                label: "Selecciona el accesorio",
                onChanged: (value) {
                  setState(() {
                    accesorioSeleccionado = value;
                    final accesorio = accesorios.firstWhere(
                      (e) => e['nombre'] == accesorioSeleccionado,
                      orElse: () => {},
                    );
                    idAccesorio = accesorio['id'].toString();
                    //print("ID del accesorio: $idAccesorio");
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (direccion != null && accesorioSeleccionado != null) {
                  _addElemento(2, 1.5, direccion!, idAccesorio!);
                  print("Accesorio seleccionado: $accesorioSeleccionado");
                  //imprimir el id
                  print("ID del accesorio: $idAccesorio");
                } else {
                  _showSnackBar(
                      "Por favor completa todos los campos correctamente.");
                }
                Navigator.pop(context);
              },
              child: Text("Aceptar"),
            ),
          ],
        ),
      ),
    );
  }

// Función para agregar un elemento al canvas
  void _addElemento(
      int elementoTipo, double longitud, String direccion, String idEquipo) {
    final nodoInicio = pointsWithIds[selectedPointIndex!];

    // Determinar la función de dirección basada en la disposición
    Offset Function(String direccion, double longitud) obtenerDireccion;

    if (disposicion == 'izquierda') {
      obtenerDireccion = GetDirectionControlLeft;
    } else if (disposicion == 'derecha') {
      obtenerDireccion = GetDirectionControlRight;
    } else {
      // Puedes agregar un manejo para disposiciones no definidas si es necesario
      return;
    }

    // Calcular la posición final
    final Offset nodoFinOffset =
        nodoInicio['point'] + obtenerDireccion(direccion, longitud);
    //convertir el id del equipo a entero
    int ID_EQUIPO = int.parse(idEquipo);
    // Llamar a las funciones comunes para agregar el punto y el elemento
    addPoint(nodoFinOffset.dx, nodoFinOffset.dy, true);
    elementoController.addElemento(
      elementoTipo: elementoTipo,
      idElemento: ID_EQUIPO,
      longitud: longitud,
      nodoInicio: nodoInicio['id'],
      nodoFin: pointsWithIds.last['id'],
      direccion: direccion,
    );

    // Agregar línea a la lista de líneas
    setState(() {
      lines.add({
        'start': nodoInicio['point'],
        'end': nodoFinOffset,
      });
    });

    // Imprimir el estado actualizado
    print(elementoController.getListaJson());
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }

  Widget _buildDropdown({
    required List<String> items,
    required String label,
    String? value,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      value: value,
      items: items
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Isométrico Canvas")),
      body: GestureDetector(
        onPanUpdate: (details) => setState(() => offset += details.delta),
        onTapDown: _onTapDown,
        child: CustomPaint(
          size: Size.infinite,
          painter: IsometricPainter(
              offset: offset,
              selectedPointIndex: selectedPointIndex,
              points: pointsWithIds,
              lines: lines, // Pasar las líneas al pintor
              nodosLetras: nodosLetras,
              figuras: figuras,
              iconos: iconos),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize:
            MainAxisSize.min, // Asegura que la columna ocupe el mínimo espacio
        children: [
          FloatingActionButton(
            onPressed: _showMenuAccesorios,
            child: Icon(Icons.build),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _showMenuEquipos,
            child: Icon(Icons.local_fire_department),
          ),
          SizedBox(height: 10), // Espacio entre los botones
          FloatingActionButton(
            onPressed: _showMenuTuberias,
            child: Icon(Icons.add),
          ),
          SizedBox(height: 10), // Espacio entre los botones
          FloatingActionButton(
            onPressed: () {
              //hacer los calculos

              _calcular();
            },
            child: const Icon(Icons.done),
          ),
        ],
      ),
    );
  }
}

class IsometricPainter extends CustomPainter {
  final Offset offset;
  final int? selectedPointIndex;
  final List<Map<String, dynamic>> points;
  final List<Map<String, Offset>> lines;

  final List<Map<String, dynamic>> nodosLetras;

  //para figuras
  final List<Map<String, dynamic>> figuras;

  /// lista para elemetnos como accesorios
  final List<Map<String, dynamic>> iconos;

  IsometricPainter(
      {required this.offset,
      required this.selectedPointIndex,
      required this.points,
      required this.lines,
      required this.nodosLetras,
      required this.figuras,
      required this.iconos});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color.fromARGB(255, 32, 32, 32)
      ..strokeWidth = 2.0;

    //dibuja las lineas
    for (final line in lines) {
      final start = line['start']! + offset;
      final end = line['end']! + offset;
      canvas.drawLine(start, end, paint);
    }

    //dibuja los puntos
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final position = point['point'] + offset;

      canvas.drawCircle(
        position,
        selectedPointIndex == i ? 5.0 : 3.0,
        Paint()
          ..color = selectedPointIndex == i
              ? const Color.fromARGB(255, 54, 136, 244)
              : Colors.black,
      );
    }

    // Dibuja las letras con el desplazamiento aplicado
    for (var nodoLetra in nodosLetras) {
      String letra = nodoLetra['letra'];
      Offset position = nodoLetra['position'] + offset; // Aplica el offset

      // Dibujar la letra en el canvas
      TextSpan span =
          TextSpan(text: letra, style: TextStyle(color: Colors.black));
      TextPainter textPainter = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, position);
    }

    //----------------------------------------------------------------- Itera sobre las figuras por default

    for (final figura in figuras) {
      final coordenadaInicialX = figura['coordenadaInicialX'] as double;
      final coordenadaInicialY = figura['coordenadaInicialY'] as double;

      final instructions = figura['instructions'] as List<dynamic>;

      for (final instruction in instructions) {
        if (instruction['type'] == 'line') {
          final points = instruction['points'] as List<dynamic>;
          final start = points[0];
          final end = points[1];

          // Convertir las proporciones a coordenadas absolutas
          final startX = coordenadaInicialX + (start['dx'] as double);
          final startY = coordenadaInicialY + (start['dy'] as double);
          final endX = coordenadaInicialX + (end['dx'] as double);
          final endY = coordenadaInicialY + (end['dy'] as double);

          // Crear los offsets con las coordenadas absolutas y el offset adicional
          final startOffset = Offset(startX, startY) + offset;
          final endOffset = Offset(endX, endY) + offset;

          // Dibujar la línea en el canvas
          canvas.drawLine(startOffset, endOffset, paint);
        } else if (instruction['type'] == 'circle') {
          final center = instruction['center'] as Map<String, dynamic>;
          final radius = instruction['radius'] as double;

          // Convertir las proporciones a coordenadas absolutas
          final centerX = coordenadaInicialX + (center['dx'] as double);
          final centerY = coordenadaInicialY + (center['dy'] as double);

          // Crear el offset para el centro del círculo
          final centerOffset = Offset(centerX, centerY) + offset;

          // Configurar el estilo del paint para el borde del círculo
          final strokePaint = Paint()
            ..color = paint.color // Usar el color actual
            ..strokeWidth = paint.strokeWidth // Usar el grosor actual
            ..style = PaintingStyle.stroke; // Solo dibujar el borde

          // Dibujar el círculo en el canvas
          canvas.drawCircle(centerOffset, radius, strokePaint);
        }
      }
    }

    var scaleFactor = 0;
//----------------------------------------------------- DIBUJAR ICONOS
 for (final icono in iconos) {
  final coordenadaInicialX = icono['coordenadaInicialX'] as double;
  final coordenadaInicialY = icono['coordenadaInicialY'] as double;
  final coordenadaFinalX = icono['coordenadaFinalX'] as double;
  final coordenadaFinalY = icono['coordenadaFinalY'] as double;

  final instructions = icono['instructions'] as List<dynamic>;

  // Identificamos el primer punto de la primera línea que debe ser el punto de inicio correcto
  final firstLine = instructions[0];
  final firstPoint = firstLine['points'][0]; // Este es el punto inicial de la primera línea (de arriba hacia abajo)
  
  final firstDx = firstPoint['dx'] as double;
  final firstDy = firstPoint['dy'] as double;

  // Calcular la distancia original entre el primer punto y el último punto de la figura (de la primera línea al último)
  final lastLine = instructions.last;
  final lastPoint = lastLine['points'][1]; // Último punto de la figura
  final lastDx = lastPoint['dx'] as double;
  final lastDy = lastPoint['dy'] as double;
  final originalDistance = (lastDx - firstDx).abs() + (lastDy - firstDy).abs();

  // Calcular la distancia deseada entre las coordenadas de inicio y final de la figura
  final desiredDistance = (coordenadaFinalX - coordenadaInicialX).abs() + (coordenadaFinalY - coordenadaInicialY).abs();

  // Calcular el factor de escala
  final scaleFactor = desiredDistance / originalDistance;

  // Primero escalamos todas las coordenadas de la figura
  for (final instruction in instructions) {
    if (instruction['type'] == 'line') {
      final points = instruction['points'] as List<dynamic>;
      final start = points[0];
      final end = points[1];

      // Escalamos las coordenadas de inicio y fin con el factor de escala
      start['dx'] = (start['dx'] as double) * scaleFactor;
      start['dy'] = (start['dy'] as double) * scaleFactor;
      end['dx'] = (end['dx'] as double) * scaleFactor;
      end['dy'] = (end['dy'] as double) * scaleFactor;
    } else if (instruction['type'] == 'circle') {
      final center = instruction['center'] as Map<String, dynamic>;
      final radius = instruction['radius'] as double;

      // Escalamos las coordenadas del centro y el radio
      center['dx'] = (center['dx'] as double) * scaleFactor;
      center['dy'] = (center['dy'] as double) * scaleFactor;
      instruction['radius'] = radius * scaleFactor;
    }
  }

  // Ahora aplicamos el desplazamiento necesario para alinear la figura con las coordenadas iniciales
  final alignmentOffsetX = coordenadaInicialX - firstDx;
  final alignmentOffsetY = coordenadaInicialY - firstDy;

  // Dibujamos la figura ya escalada y centrada
  for (final instruction in instructions) {
    if (instruction['type'] == 'line') {
      final points = instruction['points'] as List<dynamic>;
      final start = points[0];
      final end = points[1];

      // Ajustamos las coordenadas con el desplazamiento
      final startX = alignmentOffsetX + (start['dx'] as double);
      final startY = alignmentOffsetY + (start['dy'] as double);
      final endX = alignmentOffsetX + (end['dx'] as double);
      final endY = alignmentOffsetY + (end['dy'] as double);

      // Dibujamos la línea en el canvas
      final startOffset = Offset(startX, startY) + offset;
      final endOffset = Offset(endX, endY) + offset;
      canvas.drawLine(startOffset, endOffset, paint);
    } else if (instruction['type'] == 'circle') {
      final center = instruction['center'] as Map<String, dynamic>;
      final radius = instruction['radius'] as double;

      // Ajustamos las coordenadas del centro con el desplazamiento
      final centerX = alignmentOffsetX + (center['dx'] as double);
      final centerY = alignmentOffsetY + (center['dy'] as double);

      // Dibujamos el círculo en el canvas
      final centerOffset = Offset(centerX, centerY) + offset;
      canvas.drawCircle(centerOffset, radius, paint);
    }
  }
}

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
