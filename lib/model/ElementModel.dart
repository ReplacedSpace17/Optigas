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

 // Método para convertir JSON a un objeto Elemento
  factory Elemento.fromJson(Map<String, dynamic> json) {
    return Elemento(
      idIncremental: json['ID_incremental'] as int,
      elementoTipo: json['Elemento_tipo'] as int,
      idElemento: json['ID_elemento'] as int,
      longitud: (json['Longitud'] as num).toDouble(),
      nodoInicio: json['NodoIncio'] as String,
      nodoFin: json['NodoFin'] as String,
      direccion: json['Direccion'] as String,
    );
  }
  
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
