import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/models/sesion_recurrente.dart';
import '../../domain/models/sesion_realizada.dart';
import '../../domain/models/evento_calendario.dart';
import 'database_provider.dart';
import 'fuentes_provider.dart';
import 'alumnos_provider.dart';

/// Stream de todas las sesiones recurrentes (para construir el horario).
final sesionesRecurrentesProvider = StreamProvider<List<SesionRecurrente>>((
  ref,
) {
  return ref.watch(sesionRepositoryProvider).watchSesionesRecurrentes();
});

/// Stream de sesiones realizadas de un mes específico ("yyyy-MM").
final sesionesRealizadasMesProvider =
    StreamProvider.family<List<SesionRealizada>, String>((ref, periodoMes) {
  return ref
      .watch(sesionRepositoryProvider)
      .watchSesionesRealizadasByMes(periodoMes);
});

/// Stream de sesiones realizadas de una fecha concreta ("yyyy-MM-dd").
final sesionesRealizadasFechaProvider =
    StreamProvider.family<List<SesionRealizada>, String>((ref, fecha) {
  return ref
      .watch(sesionRepositoryProvider)
      .watchSesionesRealizadasByFecha(fecha);
});

/// Mes activo para el horario (por defecto el mes actual).
final mesActivoProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Calcula los [EventoCalendario] para un día concreto combinando
/// sesiones recurrentes que caen ese weekday + overrides realizadas.
final eventosDelDiaProvider =
    StreamProvider.family<List<EventoCalendario>, DateTime>((ref, dia) async* {
  final recurrentesAsync = ref.watch(sesionesRecurrentesProvider);
  final fechaIso = AppDateUtils.formatIso(dia);
  final realizadasAsync = ref.watch(sesionesRealizadasFechaProvider(fechaIso));
  final fuentesAsync = ref.watch(fuentesProvider);
  final alumnosAsync = ref.watch(alumnosProvider);

  final recurrentes = recurrentesAsync.valueOrNull ?? [];
  final realizadas = realizadasAsync.valueOrNull ?? [];
  final fuentes = fuentesAsync.valueOrNull ?? [];
  final alumnos = alumnosAsync.valueOrNull ?? [];

  // Mapa rápido: sesionRecurrenteId → SesionRealizada de ese día
  final realizadasMap = <String, SesionRealizada>{};
  for (final r in realizadas) {
    if (r.sesionRecurrenteId != null) {
      realizadasMap[r.sesionRecurrenteId!] = r;
    }
  }

  // Mapa: fuenteId → Fuente
  final fuentesMap = {for (final f in fuentes) f.id: f};
  // Mapa: alumnoId → nombre
  final alumnosMap = {for (final a in alumnos) a.id: a.nombre};

  final weekday = dia.weekday;
  final eventos = <EventoCalendario>[];

  for (final sesion in recurrentes) {
    final fuente = fuentesMap[sesion.fuenteId];
    if (fuente == null) continue;

    final fechaInicioSesion = DateTime.tryParse(sesion.fechaInicio);
    if (fechaInicioSesion != null &&
        dia.isBefore(
          DateTime(
            fechaInicioSesion.year,
            fechaInicioSesion.month,
            fechaInicioSesion.day,
          ),
        )) {
      continue; // La sesión aún no ha empezado
    }

    if (sesion.esPuntual) {
      // Clase única: solo aparece en su fechaInicio exacta
      if (sesion.fechaInicio != fechaIso) continue;
    } else {
      // Recurrente: aparece en el weekday correspondiente
      if (!sesion.diasSemana.contains(weekday)) continue;
    }

    final realizada = realizadasMap[sesion.id];
    final alumnoNombre =
        sesion.alumnoId != null ? alumnosMap[sesion.alumnoId] : null;

    eventos.add(EventoCalendario.fromRecurrente(
      sesion,
      fuente,
      realizada: realizada,
      alumnoNombre: alumnoNombre,
    ));
  }

  // Ordenar por hora de inicio
  eventos.sort((a, b) => a.horaInicio.compareTo(b.horaInicio));

  yield eventos;
});
