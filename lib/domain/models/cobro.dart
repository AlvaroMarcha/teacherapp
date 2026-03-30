/// Cobro generado al confirmar una sesión o al final del mes.
///
/// Modos de facturación según el informe:
///  - [ModoCobro.sesion]: clases puntuales (Blanca €20, Pablo €20…)
///  - [ModoCobro.mensual]: cuota fija mensual (Angels con tarifa pactada)
enum ModoCobro { sesion, mensual }

extension ModoCobroExt on ModoCobro {
  String get value => this == ModoCobro.sesion ? 'sesion' : 'mensual';

  static ModoCobro fromString(String v) =>
      v == 'mensual' ? ModoCobro.mensual : ModoCobro.sesion;
}

enum EstadoCobro { pendiente, cobrado, parcial }

extension EstadoCobroExt on EstadoCobro {
  String get value {
    switch (this) {
      case EstadoCobro.pendiente:
        return 'pendiente';
      case EstadoCobro.cobrado:
        return 'cobrado';
      case EstadoCobro.parcial:
        return 'parcial';
    }
  }

  static EstadoCobro fromString(String v) {
    switch (v) {
      case 'cobrado':
        return EstadoCobro.cobrado;
      case 'parcial':
        return EstadoCobro.parcial;
      default:
        return EstadoCobro.pendiente;
    }
  }
}

class Cobro {
  const Cobro({
    required this.id,
    required this.fuenteId,
    required this.modoCobro,
    required this.monto,
    this.sesionId,
    this.alumnoId,
    this.periodoMes,
    this.montoParcial,
    this.estado = EstadoCobro.pendiente,
    this.fechaCobro,
    this.notas = '',
    this.syncStatus = 'pending',
  });

  final String id;
  final String? sesionId;
  final String? alumnoId;
  final String fuenteId;
  final ModoCobro modoCobro;

  /// Período del mes "yyyy-MM" para cobros mensuales.
  final String? periodoMes;

  /// Importe total del cobro (€).
  final double monto;

  /// Importe cobrado en pago parcial (€). Null si no es parcial.
  final double? montoParcial;

  final EstadoCobro estado;

  /// Fecha de cobro efectivo (ISO), null si está pendiente.
  final String? fechaCobro;

  final String notas;
  final String syncStatus;

  /// Importe pendiente de cobro.
  double get montoPendiente {
    if (estado == EstadoCobro.cobrado) return 0;
    if (estado == EstadoCobro.parcial && montoParcial != null) {
      return monto - montoParcial!;
    }
    return monto;
  }

  Cobro copyWith({
    String? id,
    String? sesionId,
    String? alumnoId,
    String? fuenteId,
    ModoCobro? modoCobro,
    String? periodoMes,
    double? monto,
    double? montoParcial,
    EstadoCobro? estado,
    String? fechaCobro,
    String? notas,
    String? syncStatus,
  }) => Cobro(
    id: id ?? this.id,
    sesionId: sesionId ?? this.sesionId,
    alumnoId: alumnoId ?? this.alumnoId,
    fuenteId: fuenteId ?? this.fuenteId,
    modoCobro: modoCobro ?? this.modoCobro,
    periodoMes: periodoMes ?? this.periodoMes,
    monto: monto ?? this.monto,
    montoParcial: montoParcial ?? this.montoParcial,
    estado: estado ?? this.estado,
    fechaCobro: fechaCobro ?? this.fechaCobro,
    notas: notas ?? this.notas,
    syncStatus: syncStatus ?? this.syncStatus,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Cobro && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
