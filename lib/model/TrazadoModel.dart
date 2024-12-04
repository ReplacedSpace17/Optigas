class TrazadoModel {
  int? indice; // Puede ser nulo ya que es autoincremental
  String tramo;
  double l;
  double leq;
  double qs;
  double dc;
  double dn;
  String dnr;
  String mat;
  double pi;
  double deltaP;
  double pf;
  double v;
  bool valido;

  TrazadoModel({
    required this.indice,
    required this.tramo,
    required this.l,
    required this.leq,
    required this.qs,
    required this.dc,
    required this.dn,
    required this.dnr,
    required this.mat,
    required this.pi,
    required this.deltaP,
    required this.pf,
    required this.v,
    required this.valido,
  });

  // Convertir la instancia a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'Indice': indice,
      'Tramo': tramo,
      'L': l,
      'Leq': leq,
      'Qs': qs,
      'Dc': dc,
      'Dn': dn,
      'Dnr': dnr,
      'Mat': mat,
      'Pi': pi,
      'DeltaP': deltaP,
      'Pf': pf,
      'V': v,
      'Valido': valido,
    };
  }

  // Crear una instancia desde un mapa JSON
  factory TrazadoModel.fromJson(Map<String, dynamic> json) {
    return TrazadoModel(
      indice: json['Indice'],
      tramo: json['Tramo'],
      l: (json['L'] as num).toDouble(),
      leq: (json['Leq'] as num).toDouble(),
      qs: (json['Qs'] as num).toDouble(),
      dc: (json['Dc'] as num).toDouble(),
      dn: (json['Dn'] as num).toDouble(),
      dnr: json['Dnr'],
      mat: json['Mat'],
      pi: (json['Pi'] as num).toDouble(),
      deltaP: (json['DeltaP'] as num).toDouble(),
      pf: (json['Pf'] as num).toDouble(),
      v: (json['V'] as num).toDouble(),
      valido: json['Valido'],
    );
  }
}
