/// Registro de horas extra trabajadas en una fuente de tipo empleo.
class HoraExtra {
  const HoraExtra({
    required this.id,
    required this.fuenteId,
    required this.fecha,
    required this.horas,
    this.alumnoId,
    this.notas = '',
    this.syncStatus = 'pending',
  });

  final String id;
  final String fuenteId;

  /// Fecha del registro en formato "yyyy-MM-dd".
  final String fecha;

  final double horas;

  /// Alumno asociado a estas horas extra (opcional).
  final String? alumnoId;

  final String notas;
  final String syncStatus;

  HoraExtra copyWith({
    String? id,
    String? fuenteId,
    String? fecha,
    double? horas,
    Object? alumnoId = _sentinel,
    String? notas,
    String? syncStatus,
  }) =>
      HoraExtra(
        id: id ?? this.id,
        fuenteId: fuenteId ?? this.fuenteId,
        fecha: fecha ?? this.fecha,
        horas: horas ?? this.horas,
        alumnoId: alumnoId == _sentinel ? this.alumnoId : alumnoId as String?,
        notas: notas ?? this.notas,
        syncStatus: syncStatus ?? this.syncStatus,
      );
}

/// Sentinel para diferenciar null explícito de "no cambiar" en copyWith.
const _sentinel = Object();
