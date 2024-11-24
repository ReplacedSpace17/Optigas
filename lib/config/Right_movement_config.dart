import 'dart:math';
import 'dart:ui';

// Factor de escala para representación en el canvas
const double scaleFactor = 20.0;

Offset GetDirectionControlRight(String direccion, double longitud) {
  const double angleDegrees = 25; // Ángulo en grados
  final double angleRadians = angleDegrees * (pi / 180); // Convertir a radianes

  final movementConfig = {
    'Arriba': Offset(0, -1),
    'Abajo': Offset(0, 1),
    'Izquierda': Offset(-cos(angleRadians), -sin(angleRadians)),
    'Derecha': Offset(cos(angleRadians), sin(angleRadians)),
    'Frente': Offset(-cos(angleRadians), sin(angleRadians)),
    'Atrás': Offset(cos(angleRadians), -sin(angleRadians)),
  };

  // Escalar el desplazamiento según la longitud y el factor de escala
  final baseOffset = movementConfig[direccion] ?? Offset.zero;
  return Offset(baseOffset.dx * longitud * scaleFactor,
      baseOffset.dy * longitud * scaleFactor);
}

void main() {
  // Ejemplo de uso
  const double longitud = 12;

  final direcciones = [
    'Arriba',
    'Abajo',
    'Izquierda',
    'Derecha',
    'Frente',
    'Atrás'
  ];

  for (var direccion in direcciones) {
    final offset = GetDirectionControlRight(direccion, longitud);
    print(
        '$direccion: dx = ${offset.dx.toStringAsFixed(2)}, dy = ${offset.dy.toStringAsFixed(2)}');
  }
}
