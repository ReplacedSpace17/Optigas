import 'package:uuid/uuid.dart';

class IdController {
  final Uuid _uuid = Uuid();

  /// Genera un UUID único
String generateId() {
    return _uuid.v4().substring(0, 8); // Toma los primeros 8 caracteres.
  }
}