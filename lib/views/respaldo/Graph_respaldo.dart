import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MaterialApp(home: NodeGraph()));
}

class NodeGraph extends StatefulWidget {
  @override
  _NodeGraphState createState() => _NodeGraphState();
}

class _NodeGraphState extends State<NodeGraph> {
  // Listas para los nodos y tramos
  List<Map<String, dynamic>> nodos = [
    {"id": 1, "x": 100.0, "y": 100.0},
  ];
  List<Map<String, dynamic>> tramos = [];

  // Variables para los controles
  TextEditingController longitudController = TextEditingController();
  String direccion = 'arriba';
  int nodoInicio = 1;
  int nodoFinal = 2;

  // Nodo seleccionado
  int? nodoSeleccionado;

  // Configuración de las direcciones
  Map<String, Map<String, double>> movementConfig = {
    'abajo': {'dx': 0, 'dy': -1},
    'arriba': {'dx': 0, 'dy': 1},
    'adelante': {'dx': -cos(22 * (pi / 180)), 'dy': -sin(22 * (pi / 180))},
    'atras': {'dx': cos(-22 * (pi / 180)), 'dy': -sin(-22 * (pi / 180))},
    'derecha': {'dx': cos(22 * (pi / 180)), 'dy': -sin(22 * (pi / 180))},
    'izquierda': {'dx': -cos(-22 * (pi / 180)), 'dy': -sin(-22 * (pi / 180))}
  };

  // Función para agregar un tramo
  void agregarTramo() {
    double longitud = double.tryParse(longitudController.text) ?? 0.0;
    Map<String, double> vectorDireccion = movementConfig[direccion]!;

    if (longitud > 0) {
      // Obtener la posición del nodo de inicio
      Map<String, dynamic> nodoInicioPos = nodos.firstWhere((n) => n['id'] == nodoInicio);
      double startX = nodoInicioPos['x']!;
      double startY = nodoInicioPos['y']!;

      // Calcular la nueva posición para el nodo final
      double endX = startX + vectorDireccion['dx']! * longitud;
      double endY = startY + vectorDireccion['dy']! * longitud;

      // Crear el nuevo nodo final
      int nuevoNodoId = nodos.length + 1;
      nodos.add({"id": nuevoNodoId, "x": endX, "y": endY});

      // Crear el tramo
      tramos.add({
        "inicio": nodoInicio,
        "fin": nuevoNodoId,
        "direccion": direccion,
        "longitud": longitud
      });

      // Actualizar el nodo final para el siguiente tramo
      nodoInicio = nuevoNodoId;

      setState(() {});
    }
  }

  // Función para manejar el clic en un nodo
  void seleccionarNodo(int nodoId) {
    setState(() {
      nodoSeleccionado = nodoId;
    });
  }

  // Función para dibujar el gráfico
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gráfico de Nodos y Tramos")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campos para ingresar la longitud y la dirección
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: longitudController,
                    decoration: InputDecoration(labelText: "Longitud (m)"),
                    keyboardType: TextInputType.number,
                  ),
                ),
                DropdownButton<String>(
                  value: direccion,
                  onChanged: (String? newValue) {
                    setState(() {
                      direccion = newValue!;
                    });
                  },
                  items: ['arriba', 'abajo', 'derecha', 'izquierda', 'adelante', 'atras']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                ElevatedButton(
                  onPressed: agregarTramo,
                  child: Text("Agregar Tramo"),
                ),
              ],
            ),

            // CustomPaint para graficar los tramos
            Expanded(
              child: GestureDetector(
                onTapUp: (TapUpDetails details) {
                  // Detectar la posición del toque y ver si coincide con algún nodo
                  double tapX = details.localPosition.dx;
                  double tapY = details.localPosition.dy;

                  for (var nodo in nodos) {
                    double nodeX = nodo['x']!;
                    double nodeY = nodo['y']!;
                    if ((tapX - nodeX).abs() < 15 && (tapY - nodeY).abs() < 15) {
                      seleccionarNodo(nodo['id']);
                      break;
                    }
                  }
                },
                child: CustomPaint(
                  size: Size(double.infinity, double.infinity),
                  painter: NodePainter(nodos, tramos, nodoSeleccionado),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NodePainter extends CustomPainter {
  final List<Map<String, dynamic>> nodos;
  final List<Map<String, dynamic>> tramos;
  final int? nodoSeleccionado;

  NodePainter(this.nodos, this.tramos, this.nodoSeleccionado);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    // Dibujar los tramos
    for (var tramo in tramos) {
      Map<String, dynamic> nodoInicioPos =
          nodos.firstWhere((n) => n['id'] == tramo['inicio']);
      Map<String, dynamic> nodoFinPos =
          nodos.firstWhere((n) => n['id'] == tramo['fin']);

      canvas.drawLine(
        Offset(nodoInicioPos['x']!, nodoInicioPos['y']!),
        Offset(nodoFinPos['x']!, nodoFinPos['y']!),
        paint,
      );
    }

    // Dibujar los nodos
    for (var nodo in nodos) {
      paint.color = nodo['id'] == nodoSeleccionado ? Colors.blue : Colors.black;
      canvas.drawCircle(
        Offset(nodo['x']!, nodo['y']!),
        4.0,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
