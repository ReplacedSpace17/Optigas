class Elemento {
  final int idIncremental;
  final int elementoTipo;
  final int idElemento;
  final double longitud;
  final String nodoInicio;
  final String nodoFin;
  final String direccion; // Nueva propiedad

  Elemento({
    required this.idIncremental,
    required this.elementoTipo,
    required this.idElemento,
    required this.longitud,
    required this.nodoInicio,
    required this.nodoFin,
    required this.direccion, // Constructor actualizado
  });

  Map<String, dynamic> toJson() {
    return {
      "ID_incremental": idIncremental,
      "Elemento_tipo": elementoTipo,
      "ID_elemento": idElemento,
      "Longitud": longitud,
      "NodoIncio": nodoInicio,
      "NodoFin": nodoFin,
      "Direccion": direccion, // Incluida en JSON
    };
  }
}
