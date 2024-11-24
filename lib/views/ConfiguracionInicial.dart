// lib/views/configuracion.dart
import 'package:flutter/material.dart';
import 'package:optigas/views/Isometrico_auto.dart';

import '../config/parametros.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({Key? key}) : super(key: key);

  @override
  _ConfiguracionScreenState createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  // Variables locales para almacenar las opciones seleccionadas
  bool isPresionInicial150 = presionInicial == 150;
  bool isDisposicionIzquierda = disposicion == 'izquierda';
  bool isModoAutomatico = modo == 'auto';

  // Método para obtener el valor de presión inicial
  String get presionInicialText => isPresionInicial150 ? '150 mbar' : '350 mbar';

  // Método para obtener la disposición
  String get disposicionText => isDisposicionIzquierda ? 'Izquierda' : 'Derecha';

  // Método para obtener el modo de operación
  String get modoOperacionText => isModoAutomatico ? 'Automático' : 'Manual';

  // Función para actualizar los valores en parametros.dart
  void _updateValues() {
    // Actualizamos las variables globales con los valores seleccionados
    presionInicial = isPresionInicial150 ? 150 : 350;
    disposicion = isDisposicionIzquierda ? 'izquierda' : 'derecha';
    modo = isModoAutomatico ? 'auto' : 'manual';
  }

  // Función para mostrar el diálogo de confirmación
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Configuración'),
          content: Text(
            'Presión Inicial: $presionInicialText\n'
            'Disposición: $disposicionText\n'
            'Modo de Operación: $modoOperacionText',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                _updateValues(); // Actualizamos los valores en parametros.dart
                // Mostrar mensaje de SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configuración guardada')),
                );
                // Redirigir a la pantalla HelloWorld
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  IsometricoScreen()),
                );
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Configuración de la presión inicial
            const Text(
              'Selecciona la presión inicial:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('150 mbar'),
                Switch(
                  value: !isPresionInicial150, // Invertimos la lógica para cumplir la condición
                  onChanged: (value) {
                    setState(() {
                      isPresionInicial150 = !value;
                    });
                  },
                ),
                const Text('350 mbar'),
              ],
            ),
            const SizedBox(height: 20),

            // Configuración de la disposición
            const Text(
              'Selecciona la disposición:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Izquierda'),
                Switch(
                  value: !isDisposicionIzquierda, // Invertimos la lógica para cumplir la condición
                  onChanged: (value) {
                    setState(() {
                      isDisposicionIzquierda = !value;
                    });
                  },
                ),
                const Text('Derecha'),
              ],
            ),
            const SizedBox(height: 20),

            // Configuración del modo de operación
            const Text(
              'Selecciona el modo de operación:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Automático'),
                Switch(
                  value: !isModoAutomatico, // Invertimos la lógica para cumplir la condición
                  onChanged: (value) {
                    setState(() {
                      isModoAutomatico = !value;
                    });
                  },
                ),
                const Text('Manual'),
              ],
            ),
            const SizedBox(height: 20),

            // Botón Continuar
            Center(
              child: ElevatedButton(
                onPressed: _showConfirmationDialog,
                child: const Text('Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
