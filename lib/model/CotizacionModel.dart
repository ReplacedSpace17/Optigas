class CotizacionModel {
  int? indice; // Puede ser nulo ya que es autoincremental
  String descripcion;
  double cantidad;
  double precioUnitario;
  double precioTotal;

  CotizacionModel({
    this.indice, // Puede ser opcional
    required this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    required this.precioTotal,
  });

  // Convertir la instancia a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'Indice': indice,
      'Descripcion': descripcion,
      'Cantidad': cantidad,
      'Precio_Unitario': precioUnitario,
      'Precio_Total': precioTotal,
    };
  }

  // Crear una instancia desde un mapa JSON
  factory CotizacionModel.fromJson(Map<String, dynamic> json) {
    return CotizacionModel(
      indice: json['Indice'],
      descripcion: json['Descripcion'],
      cantidad: (json['Cantidad'] as num).toDouble(),
      precioUnitario: (json['Precio_Unitario'] as num).toDouble(),
      precioTotal: (json['Precio_Total'] as num).toDouble(),
    );
  }
}
