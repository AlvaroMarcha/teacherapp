/// Sesión que ya se ha realizado (confirmada desde el horario o manual).
///
/// Al confirmar una sesión, se genera automáticamente un [Cobro] asociado.
enum EstadoSesion { pendiente, confirmada, cancelada }

extension EstadoSesionExt on EstadoSesion {
  String get value {
    switch (this) {
      case EstadoSesion.pendiente:
        return 'pendiente';
      case EstadoSesion.confirmada:
        return 'confirmada';
      case EstadoSesion.cancelada:
        return 'cancelada';
    }
  }

  static EstadoSesion fromString(String v) {
    switch (v) {
      case 'confirmada':
        return EstadoSesion.confirmada;
      case 'cancelada':
        return EstadoSesion.cancelada;
      default:
        return EstadoSesion.pendiente;
    }
  }
}

class SesionRealizada {
  const SesionRealizada({
    required this.id,
    required this.fuenteId,
    required this.fecha,
    required this.horas,
    required this.cobro,
    this.alumnoId,
    this.estado = EstadoSesion.pendiente,
    this.notas = '',
    this.syncStatus = 'pending',
  });

  final String id;
  final String? alumnoId;
  final String fuenteId;

  /// Fecha ISO 8601, "yyyy-MM-dd".
  final String fecha;

  /// Duración en horas (decimal), e.g. 0.75 = 45 minutos.
  final double horas;

  /// Importe calculado de la sesión (€).
  final double cobro;

  final EstadoSesion estado;
  final String notas;
  final String syncStatus;

  SesionRealizada copyWith({
    String? id,
    String? alumnoId,
    String? fuenteId,
    String? fecha,
    double? horas,
    double? cobro,
    EstadoSesion? estado,
    String? notas,
    String? syncStatus,
  }) => SesionRealizada(
    id: id ?? this.id,
    alumnoId: alumnoId ?? this.alumnoId,
    fuenteId: fuenteId ?? this.fuenteId,
    fecha: fecha ?? this.fecha,
    horas: horas ?? this.horas,
    cobro: cobro ?? this.cobro,
    estado: estado ?? this.estado,
    notas: notas ?? this.notas,
    syncStatus: syncStatus ?? this.syncStatus,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SesionRealizada && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
