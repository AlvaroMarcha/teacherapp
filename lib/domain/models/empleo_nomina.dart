/// Nómina mensual real de una fuente de empleo.
/// Registra el salario efectivamente cobrado cada mes.
class EmpleoNomina {
  const EmpleoNomina({
    required this.fuenteId,
    required this.anio,
    required this.mes,
    required this.salario,
    this.notas = '',
    this.syncStatus = 'pending',
    required this.creadaEn,
  });

  final String fuenteId;
  final int anio;
  final int mes;

  /// Salario real cobrado ese mes (€).
  final double salario;

  final String notas;
  final String syncStatus;
  final String creadaEn;

  EmpleoNomina copyWith({
    String? fuenteId,
    int? anio,
    int? mes,
    double? salario,
    String? notas,
    String? syncStatus,
    String? creadaEn,
  }) =>
      EmpleoNomina(
        fuenteId: fuenteId ?? this.fuenteId,
        anio: anio ?? this.anio,
        mes: mes ?? this.mes,
        salario: salario ?? this.salario,
        notas: notas ?? this.notas,
        syncStatus: syncStatus ?? this.syncStatus,
        creadaEn: creadaEn ?? this.creadaEn,
      );
}
