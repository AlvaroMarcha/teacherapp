/// Sesión recurrente: define el patrón de repetición semanal de una clase.
///
/// Ejemplo: Carles todos los lunes 19:00–19:45 desde el 10/09/2025.
/// Se genera la vista de horario expandiendo este patrón semana a semana.
class SesionRecurrente {
  const SesionRecurrente({
    required this.id,
    required this.fuenteId,
    required this.diasSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.fechaInicio,
    this.alumnoId,
    this.fechaFin,
    this.esPuntual = false,
    this.activa = true,
    this.syncStatus = 'pending',
  });

  final String id;
  final String? alumnoId;
  final String fuenteId;

  /// Días de la semana como lista de enteros (1=Lun, 2=Mar, ..., 7=Dom).
  final List<int> diasSemana;

  /// Hora de inicio en formato "HH:mm".
  final String horaInicio;

  /// Hora de fin en formato "HH:mm".
  final String horaFin;

  /// Fecha de inicio de la recurrencia (ISO 8601, "yyyy-MM-dd").
  final String fechaInicio;

  /// Fecha de fin de la recurrencia (null = indefinida).
  final String? fechaFin;

  /// true = clase puntual/única (no se repite semana a semana).
  final bool esPuntual;

  /// false = sesión archivada (no aparece en el calendario).
  final bool activa;

  final String syncStatus;

  SesionRecurrente copyWith({
    String? id,
    String? alumnoId,
    String? fuenteId,
    List<int>? diasSemana,
    String? horaInicio,
    String? horaFin,
    String? fechaInicio,
    String? fechaFin,
    bool? esPuntual,
    bool? activa,
    String? syncStatus,
  }) =>
      SesionRecurrente(
        id: id ?? this.id,
        alumnoId: alumnoId ?? this.alumnoId,
        fuenteId: fuenteId ?? this.fuenteId,
        diasSemana: diasSemana ?? this.diasSemana,
        horaInicio: horaInicio ?? this.horaInicio,
        horaFin: horaFin ?? this.horaFin,
        fechaInicio: fechaInicio ?? this.fechaInicio,
        fechaFin: fechaFin ?? this.fechaFin,
        esPuntual: esPuntual ?? this.esPuntual,
        activa: activa ?? this.activa,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SesionRecurrente && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
