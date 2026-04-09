/// Tipo de nota: simple o recordatorio con fecha.
enum TipoNota { nota, recordatorio }

extension TipoNotaExt on TipoNota {
  String get value => this == TipoNota.nota ? 'nota' : 'recordatorio';

  static TipoNota fromString(String v) =>
      v == 'recordatorio' ? TipoNota.recordatorio : TipoNota.nota;
}

/// Prioridad visual de la nota.
enum Prioridad { alta, media, baja }

extension PrioridadExt on Prioridad {
  String get value {
    switch (this) {
      case Prioridad.alta:
        return 'alta';
      case Prioridad.media:
        return 'media';
      case Prioridad.baja:
        return 'baja';
    }
  }

  static Prioridad fromString(String v) {
    switch (v) {
      case 'alta':
        return Prioridad.alta;
      case 'baja':
        return Prioridad.baja;
      default:
        return Prioridad.media;
    }
  }
}

/// Frecuencia de recurrencia para recordatorios.
enum Recurrencia { ninguna, diaria, semanal, mensual }

extension RecurrenciaExt on Recurrencia {
  String get value {
    switch (this) {
      case Recurrencia.ninguna:
        return 'ninguna';
      case Recurrencia.diaria:
        return 'diaria';
      case Recurrencia.semanal:
        return 'semanal';
      case Recurrencia.mensual:
        return 'mensual';
    }
  }

  static Recurrencia fromString(String v) {
    switch (v) {
      case 'diaria':
        return Recurrencia.diaria;
      case 'semanal':
        return Recurrencia.semanal;
      case 'mensual':
        return Recurrencia.mensual;
      default:
        return Recurrencia.ninguna;
    }
  }
}

class Nota {
  const Nota({
    required this.id,
    required this.titulo,
    required this.creadaEn,
    this.contenido = '',
    this.tipo = TipoNota.nota,
    this.prioridad = Prioridad.media,
    this.fechaRecordatorio,
    this.recurrencia = Recurrencia.ninguna,
    this.completada = false,
    this.etiquetaIds = const [],
    this.syncStatus = 'pending',
  });

  final String id;
  final String titulo;
  final String contenido;
  final TipoNota tipo;
  final Prioridad prioridad;
  final String? fechaRecordatorio;
  final Recurrencia recurrencia;
  final bool completada;
  final String creadaEn;
  final List<String> etiquetaIds;
  final String syncStatus;

  Nota copyWith({
    String? id,
    String? titulo,
    String? contenido,
    TipoNota? tipo,
    Prioridad? prioridad,
    String? fechaRecordatorio,
    Recurrencia? recurrencia,
    bool? completada,
    String? creadaEn,
    List<String>? etiquetaIds,
    String? syncStatus,
  }) =>
      Nota(
        id: id ?? this.id,
        titulo: titulo ?? this.titulo,
        contenido: contenido ?? this.contenido,
        tipo: tipo ?? this.tipo,
        prioridad: prioridad ?? this.prioridad,
        fechaRecordatorio: fechaRecordatorio ?? this.fechaRecordatorio,
        recurrencia: recurrencia ?? this.recurrencia,
        completada: completada ?? this.completada,
        creadaEn: creadaEn ?? this.creadaEn,
        etiquetaIds: etiquetaIds ?? this.etiquetaIds,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Nota && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
