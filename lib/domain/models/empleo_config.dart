/// Configuración del empleo fijo (Around).
/// Contiene salario base, horas contratadas y tarifa de hora extra.
class EmpleoConfig {
  const EmpleoConfig({
    required this.fuenteId,
    required this.salarioBase,
    required this.horasSemanales,
    required this.tarifaHoraExtra,
    required this.diaCobro,
  });

  final String fuenteId;

  /// Salario base mensual bruto (€).
  final double salarioBase;

  /// Horas semanales contratadas.
  final double horasSemanales;

  /// Tarifa por hora extra (€/h).
  final double tarifaHoraExtra;

  /// Día del mes en que se cobra (1-31).
  final int diaCobro;

  EmpleoConfig copyWith({
    String? fuenteId,
    double? salarioBase,
    double? horasSemanales,
    double? tarifaHoraExtra,
    int? diaCobro,
  }) => EmpleoConfig(
    fuenteId: fuenteId ?? this.fuenteId,
    salarioBase: salarioBase ?? this.salarioBase,
    horasSemanales: horasSemanales ?? this.horasSemanales,
    tarifaHoraExtra: tarifaHoraExtra ?? this.tarifaHoraExtra,
    diaCobro: diaCobro ?? this.diaCobro,
  );
}
