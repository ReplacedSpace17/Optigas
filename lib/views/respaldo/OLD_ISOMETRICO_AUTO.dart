
import 'package:flutter/material.dart';
import 'package:optigas/config/Left_movement_config.dart';
import 'package:optigas/controllers/ElementController.dart';
import 'package:optigas/controllers/Uuid_Controller.dart';
import 'package:optigas/views/Render.dart';

class IsometricoScreen extends StatefulWidget {
  @override
  _IsometricoScreenState createState() => _IsometricoScreenState();
}

class _IsometricoScreenState extends State<IsometricoScreen> {
  Offset offset = Offset(0, 0);
  Offset? selectedPoint;
  int? selectedPointIndex;
  final List<Map<String, dynamic>> pointsWithIds = [];
  final ElementoController elementoController = ElementoController();
  final IdController idController = IdController();

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Calcula el centro del canvas basándote en el tamaño de la pantalla
    final size = MediaQuery.of(context).size;
    setState(() {
      offset = Offset(size.width / 2, size.height / 2);
    });

    // Agrega el punto inicial en el centro
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showMenuTuberias() {
    if (selectedPointIndex == null) {
      _showSnackBar("Selecciona un nodo de inicio antes de agregar un elemento.");
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
              items: ["Arriba", "Abajo", "Izquierda", "Derecha", "Frente", "Atrás"],
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
                _showSnackBar("Por favor completa todos los campos correctamente.");
              }
              Navigator.pop(context);
            },
            child: Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  void _addTuberia(double longitud, String direccion) {
    final nodoInicio = pointsWithIds[selectedPointIndex!];
    final Offset nodoFinOffset =
        nodoInicio['point'] + GetDirectionControlLeft(direccion, longitud);

    addPoint(nodoFinOffset.dx, nodoFinOffset.dy, true);

    elementoController.addElemento(
      elementoTipo: 1,
      idElemento: 1,
      longitud: longitud,
      nodoInicio: nodoInicio['id'],
      nodoFin: pointsWithIds.last['id'],
      direccion: direccion,
    );
    print(elementoController.getListaJson());
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      String? hint,
      TextInputType? keyboardType}) {
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
      items: items.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
      onChanged: onChanged,
    );
  }

  @override
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
          ),
        ),
      ),
      floatingActionButton: Column(
  mainAxisSize: MainAxisSize.min, // Asegura que la columna ocupe el mínimo espacio
  children: [
    FloatingActionButton(
      onPressed: () {
        // Acción del segundo botón
        
      },
      child: Icon(Icons.build),
    ),
    SizedBox(height: 10), 
     FloatingActionButton(
      onPressed: () {
        // Acción del segundo botón
        
      },
      child: Icon(Icons.local_fire_department),
    ),
    SizedBox(height: 10),// Espacio entre los botones
    FloatingActionButton(
      onPressed: _showMenuTuberias,
      child: Icon(Icons.add),
    ),
    SizedBox(height: 10), // Espacio entre los botones
    FloatingActionButton(
      onPressed: () {

      },
      child: Icon(Icons.done),
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

  IsometricPainter({
    required this.offset,
    required this.selectedPointIndex,
    required this.points,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.white, BlendMode.src);
    final gridPaint = Paint()..color = Colors.grey.withOpacity(0.5);
    const gridSize = 40.0;

    canvas.translate(offset.dx, offset.dy);
    for (double x = -size.width; x < size.width * 2; x += gridSize) {
      for (double y = -size.height; y < size.height * 2; y += gridSize) {
        canvas.drawLine(Offset(x, y), Offset(x + gridSize, y + gridSize), gridPaint);
        canvas.drawLine(Offset(x + gridSize, y), Offset(x, y + gridSize), gridPaint);
      }
    }

    for (int i = 0; i < points.length; i++) {
      final point = points[i]['point'] as Offset;
      final isSelected = i == selectedPointIndex;

      final paint = Paint()
        ..color = isSelected ? Colors.blue : const Color.fromARGB(255, 36, 36, 36)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(point, 6.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}