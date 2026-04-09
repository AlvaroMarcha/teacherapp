import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../data/local/database.dart';
import 'package:drift/drift.dart';

// SharedPreferences key
const kCobroAutoDiasFuturos = 'cobro_auto_dias_futuros';

/// Servicio que auto-genera SesionRealizada (pendiente) + Cobro (pendiente)
/// para sesiones recurrentes de tipo particular/academia.
///
/// Se ejecuta:
/// 1. Al abrir la app (post-login)
/// 2. Diariamente con WorkManager
/// 3. Al crear/editar una sesión recurrente
///
/// Genera cobros tanto para días pasados como futuros, según configuración:
/// - Días pasados: últimos 7 días (para sesiones que ya ocurrieron)
/// - Días futuros: configurable en Ajustes (default: 30 días)
class CobroAutoService {
  const CobroAutoService._();
  static const _uuid = Uuid();

  /// Genera cobros pendientes para sesiones recurrentes activas
  /// de tipo particular/academia.
  ///
  /// - [diasPasados]: días hacia atrás desde hoy (default: 7)
  /// - [diasFuturos]: días hacia adelante desde hoy (default: 30)
  static Future<int> generarCobrosPendientes(
    AppDatabase db, {
    int diasPasados = 7,
    int? diasFuturos,
  }) async {
    // Obtener días futuros de SharedPreferences si no se especifica
    final diasFuturosFinal = diasFuturos ?? await _getDiasFuturos();
    int generados = 0;

    // 1) Obtener sesiones recurrentes activas (no puntuales)
    final recurrentes = await db.getSesionesRecurrentesActivasRecurrentes();
    if (recurrentes.isEmpty) return 0;

    // 2) Obtener fuentes para filtrar solo particular/academia
    final fuentes = await db.getAllFuentes();
    final fuentesNoEmpleo = <String>{};
    final fuentesTarifa = <String, String>{}; // fuenteId → tipo
    for (final f in fuentes) {
      if (f.tipo != 'empleo') {
        fuentesNoEmpleo.add(f.id);
        fuentesTarifa[f.id] = f.tipo;
      }
    }

    // 3) Obtener alumnos para calcular tarifa
    final alumnos = await db.getAllAlumnos();
    final alumnosMap = <String, AlumnosTableData>{};
    for (final a in alumnos) {
      alumnosMap[a.id] = a;
    }

    // 4) Calcular rango de fechas: hoy - N días hasta ayer (hoy no se genera)
    final hoy = DateTime.now();
    final hoyDate = DateTime(hoy.year, hoy.month, hoy.day);

    for (final recurrente in recurrentes) {
      // Filtrar: solo particular/academia
      if (!fuentesNoEmpleo.contains(recurrente.fuenteId)) continue;

      final diasSemana = List<int>.from(
        jsonDecode(recurrente.diasSemana) as List,
      );

      final fechaInicio = DateTime.tryParse(recurrente.fechaInicio);
      if (fechaInicio == null) continue;

      final fechaFin = recurrente.fechaFin != null
          ? DateTime.tryParse(recurrente.fechaFin!)
          : null;

      // Tarifa: del alumno asociado, o 0 si no hay
      final tarifa = recurrente.alumnoId != null
          ? (alumnosMap[recurrente.alumnoId]?.tarifaSesion ?? 0.0)
          : 0.0;

      // Calcular duración en horas
      final iniParts = recurrente.horaInicio.split(':');
      final finParts = recurrente.horaFin.split(':');
      final iniMin = int.parse(iniParts[0]) * 60 + int.parse(iniParts[1]);
      final finMin = int.parse(finParts[0]) * 60 + int.parse(finParts[1]);
      final duracionHoras = (finMin - iniMin) / 60.0;

      // 5) Iterar días pasados + hoy + días futuros
      for (int d = -diasPasados; d <= diasFuturosFinal; d++) {
        final fecha = hoyDate.add(Duration(days: d));
        final fechaIso =
            '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';

        // ¿El día de la semana coincide con diasSemana?
        if (!diasSemana.contains(fecha.weekday)) continue;

        // ¿La fecha es >= fechaInicio?
        final fechaInicioDate = DateTime(
          fechaInicio.year,
          fechaInicio.month,
          fechaInicio.day,
        );
        if (fecha.isBefore(fechaInicioDate)) continue;

        // ¿La fecha es <= fechaFin (si existe)?
        if (fechaFin != null) {
          final fechaFinDate = DateTime(
            fechaFin.year,
            fechaFin.month,
            fechaFin.day,
          );
          if (fecha.isAfter(fechaFinDate)) continue;
        }

        // ¿Ya existe SesionRealizada para esta combinación?
        final existente = await db.getSesionRealizadaByRecurrenteAndFecha(
          recurrente.id,
          fechaIso,
        );
        if (existente != null) continue;

        // 6) Crear SesionRealizada (pendiente) + Cobro (pendiente)
        final sesionId = _uuid.v4();

        await db.upsertSesionRealizada(
          SesionesRealizadasTableCompanion(
            id: Value(sesionId),
            alumnoId: Value(recurrente.alumnoId),
            fuenteId: Value(recurrente.fuenteId),
            sesionRecurrenteId: Value(recurrente.id),
            fecha: Value(fechaIso),
            horas: Value(duracionHoras),
            cobro: Value(tarifa),
            estado: const Value('pendiente'),
            syncStatus: const Value('pending'),
          ),
        );

        await db.upsertCobro(
          CobrosTableCompanion(
            id: Value(_uuid.v4()),
            sesionId: Value(sesionId),
            alumnoId: Value(recurrente.alumnoId),
            fuenteId: Value(recurrente.fuenteId),
            modoCobro: const Value('sesion'),
            monto: Value(tarifa),
            estado: const Value('pendiente'),
            syncStatus: const Value('pending'),
          ),
        );

        generados++;
      }
    }

    if (generados > 0) {
      print('✅ CobroAutoService: $generados cobros generados');
    }
    return generados;
  }

  /// Obtiene la configuración de días futuros desde SharedPreferences.
  /// Default: 30 días.
  static Future<int> _getDiasFuturos() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(kCobroAutoDiasFuturos) ?? 30;
  }

  /// Elimina todos los cobros pendientes futuros y los regenera con
  /// la configuración actual. Usado al cambiar días futuros en Ajustes.
  static Future<int> regenerarCobrosFuturos(AppDatabase db) async {
    final hoy = DateTime.now();
    final fechaHoy =
        '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';

    // 1. Eliminar todos los pendientes futuros
    await db.deleteAllSesionesRealizadasPendientesFuturas(fechaHoy);

    // 2. Regenerar con la configuración actual
    return await generarCobrosPendientes(db);
  }
}
