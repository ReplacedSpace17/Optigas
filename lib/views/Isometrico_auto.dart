import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:optigas/config/Left_movement_config.dart';
import 'package:optigas/config/Right_movement_config.dart';
import 'package:optigas/config/parametros.dart';
import 'package:optigas/controllers/ElementController.dart';
import 'package:optigas/controllers/Uuid_Controller.dart';
import 'package:optigas/views/respaldo/Render.dart';
import 'package:flutter/services.dart' show rootBundle;

// Método para cargar el archivo JSON
Future<List<Map<String, dynamic>>> cargarCatalogoEquipos() async {
  final String jsonString = await rootBundle.loadString('lib/assets/CatalogoEquipos.json');
  final List<dynamic> jsonData = json.decode(jsonString);
  return jsonData.map((e) => e as Map<String, dynamic>).toList();
}
Future<List<Map<String, dynamic>>> cargarCatalogoAccesorios() async {
  final String jsonString = await rootBundle.loadString('lib/assets/CatalogoAccesorios.json');
  final List<dynamic> jsonData = json.decode(jsonString);
  return jsonData.map((e) => e as Map<String, dynamic>).toList();
}

class IsometricoScreen extends StatefulWidget {
  @override
  _IsometricoScreenState createState() => _IsometricoScreenState();
}

class _IsometricoScreenState extends State<IsometricoScreen> {
  Offset offset = Offset(0, 0);
  Offset? selectedPoint;
  int? selectedPointIndex;
  final List<Map<String, dynamic>> pointsWithIds = [];
  final List<Map<String, Offset>> lines = []; // Lista de líneas para dibujar
  final ElementoController elementoController = ElementoController();
  final IdController idController = IdController();

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
                _addTuberia(longitud, direccion!);
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
  final nombresEquipos = equipos.map((equipo) => equipo['nombre'].toString()).toList();

  String? direccion;
  String? equipoSeleccionado;
  String? categoriaSeleccionada;

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
                print("Equipo seleccionado: $equipoSeleccionado");
                print("Dirección seleccionada: $direccion");
              } else {
                _showSnackBar("Por favor completa todos los campos correctamente.");
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
  final nombresAccesorios = accesorios.map((accesorio) => accesorio['nombre'].toString()).toList();

  String? direccion;
  String? accesorioSeleccionado;

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
              onChanged: (value) => setState(() => accesorioSeleccionado = value),
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
                // Implementa la lógica para manejar el accesorio seleccionado
                print("Accesorio seleccionado: $accesorioSeleccionado");
                print("Dirección seleccionada: $direccion");
              } else {
                _showSnackBar("Por favor completa todos los campos correctamente.");
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

void _addTuberia(double longitud, String direccion) {
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
  final Offset nodoFinOffset = nodoInicio['point'] + obtenerDireccion(direccion, longitud);

  // Llamar a las funciones comunes para agregar el punto y el elemento
  addPoint(nodoFinOffset.dx, nodoFinOffset.dy, true);
  elementoController.addElemento(
    elementoTipo: 1,
    idElemento: 1,
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
          ),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RenderScreen()),
              );
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

  IsometricPainter({
    required this.offset,
    required this.selectedPointIndex,
    required this.points,
    required this.lines,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color.fromARGB(255, 32, 32, 32)
      ..strokeWidth = 2.0;

    for (final line in lines) {
      final start = line['start']! + offset;
      final end = line['end']! + offset;
      canvas.drawLine(start, end, paint);
    }

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final position = point['point'] + offset;

      canvas.drawCircle(
        position,
        selectedPointIndex == i ? 6.0 : 5.0,
        Paint()
          ..color = selectedPointIndex == i
              ? const Color.fromARGB(255, 54, 136, 244)
              : Colors.black,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
