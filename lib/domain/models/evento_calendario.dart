import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'sesion_recurrente.dart';
import 'sesion_realizada.dart';
import 'fuente.dart';

/// Tipo de evento para el calendario.
enum TipoEvento {
  /// Clase recurrente de empleo/academia (azul).
  recurrente,

  /// Clase de alumno particular (verde).
  particular,

  /// Clase única/puntual creada manualmente (morado).
  unica,

  /// Clase cancelada (rojo).
  cancelada,
}

/// Modelo unificado para mostrar bloques en el calendario.
///
/// Combina [SesionRecurrente] (plantilla semanal) con overrides de
/// [SesionRealizada] (confirmada o cancelada ese día concreto).
class EventoCalendario {
  const EventoCalendario({
    required this.tipo,
    required this.color,
    required this.horaInicio,
    required this.horaFin,
    required this.titulo,
    required this.fuenteId,
    this.fuenteTipo,
    this.sesionRecurrenteId,
    this.sesionRealizadaId,
    this.alumnoId,
    this.alumnoNombre,
    this.fuenteNombre,
    this.cobro,
  });

  final TipoEvento tipo;
  final Color color;

  /// "HH:mm"
  final String horaInicio;

  /// "HH:mm"
  final String horaFin;

  final String titulo;
  final String fuenteId;
  final FuenteTipo? fuenteTipo;
  final String? sesionRecurrenteId;
  final String? sesionRealizadaId;
  final String? alumnoId;
  final String? alumnoNombre;
  final String? fuenteNombre;

  /// Importe de la sesión realizada (null si aún no se ha registrado).
  final double? cobro;

  /// Duración en horas (decimal).
  double get duracionHoras {
    final ini = _toMinutes(horaInicio);
    final fin = _toMinutes(horaFin);
    return (fin - ini) / 60.0;
  }

  static int _toMinutes(String hhmm) {
    final parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  /// Hora decimal de inicio (ej: "09:30" → 9.5).
  double get horaInicioDecimal => _toMinutes(horaInicio) / 60.0;

  bool get esCancelada => tipo == TipoEvento.cancelada;
  bool get estaConfirmada => sesionRealizadaId != null && !esCancelada;

  /// Construye un EventoCalendario a partir de una [SesionRecurrente] y una
  /// fuente, posiblemente sobreescrito por una [SesionRealizada] concreta.
  factory EventoCalendario.fromRecurrente(
    SesionRecurrente sesion,
    Fuente fuente, {
    SesionRealizada? realizada,
    String? alumnoNombre,
  }) {
    final esCancelada = realizada?.estado == EstadoSesion.cancelada;
    final esPuntual = sesion.esPuntual;
    final esParticular = fuente.tipo == FuenteTipo.particular;

    TipoEvento tipo;
    Color color;

    if (esCancelada) {
      tipo = TipoEvento.cancelada;
      color = AppColors.sesionCancelada;
    } else if (esPuntual) {
      tipo = TipoEvento.unica;
      color = AppColors.sesionUnica;
    } else if (esParticular) {
      tipo = TipoEvento.particular;
      color = AppColors.sesionParticular;
    } else {
      tipo = TipoEvento.recurrente;
      color = AppColors.sesionRecurrente;
    }

    final titulo = alumnoNombre ?? fuente.nombre;

    return EventoCalendario(
      tipo: tipo,
      color: color,
      horaInicio: sesion.horaInicio,
      horaFin: sesion.horaFin,
      titulo: titulo,
      fuenteId: sesion.fuenteId,
      fuenteTipo: fuente.tipo,
      fuenteNombre: fuente.nombre,
      sesionRecurrenteId: sesion.id,
      sesionRealizadaId: realizada?.id,
      alumnoId: sesion.alumnoId,
      alumnoNombre: alumnoNombre,
      cobro: realizada?.cobro,
    );
  }

  EventoCalendario copyWith({TipoEvento? tipo, Color? color}) =>
      EventoCalendario(
        tipo: tipo ?? this.tipo,
        color: color ?? this.color,
        horaInicio: horaInicio,
        horaFin: horaFin,
        titulo: titulo,
        fuenteId: fuenteId,
        fuenteTipo: fuenteTipo,
        fuenteNombre: fuenteNombre,
        sesionRecurrenteId: sesionRecurrenteId,
        sesionRealizadaId: sesionRealizadaId,
        alumnoId: alumnoId,
        alumnoNombre: alumnoNombre,
        cobro: cobro,
      );
}
