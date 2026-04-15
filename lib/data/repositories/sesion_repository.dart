import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../local/database.dart';
import '../../domain/models/sesion_recurrente.dart';
import '../../domain/models/sesion_realizada.dart';

class SesionRepository {
  const SesionRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  // ── Mappers ──────────────────────────────────────────────────────

  static SesionRecurrente _mapRecurrente(SesionesRecurrentesTableData row) =>
      SesionRecurrente(
        id: row.id,
        alumnoId: row.alumnoId,
        fuenteId: row.fuenteId,
        diasSemana: List<int>.from(jsonDecode(row.diasSemana) as List),
        horaInicio: row.horaInicio,
        horaFin: row.horaFin,
        fechaInicio: row.fechaInicio,
        fechaFin: row.fechaFin,
        esPuntual: row.esPuntual,
        activa: row.activa,
        syncStatus: row.syncStatus,
      );

  static SesionRealizada _mapRealizada(SesionesRealizadasTableData row) =>
      SesionRealizada(
        id: row.id,
        alumnoId: row.alumnoId,
        fuenteId: row.fuenteId,
        sesionRecurrenteId: row.sesionRecurrenteId,
        fecha: row.fecha,
        horas: row.horas,
        cobro: row.cobro,
        estado: EstadoSesionExt.fromString(row.estado),
        notas: row.notas,
        temaSesion: row.temaSesion,
        syncStatus: row.syncStatus,
      );

  // ── Sesiones Recurrentes ─────────────────────────────────────────

  Stream<List<SesionRecurrente>> watchSesionesRecurrentes() => _db
      .watchSesionesRecurrentes()
      .map((rows) => rows.map(_mapRecurrente).toList());

  Future<List<SesionRecurrente>> getSesionesRecurrentes() async {
    final rows = await _db.getSesionesRecurrentes();
    return rows.map(_mapRecurrente).toList();
  }

  Future<SesionRecurrente?> getSesionRecurrenteById(String id) async {
    final row = await _db.getSesionRecurrenteById(id);
    return row == null ? null : _mapRecurrente(row);
  }

  Future<String> saveSesionRecurrente(SesionRecurrente sesion) {
    final id = sesion.id.isEmpty ? _uuid.v4() : sesion.id;
    return _db.upsertSesionRecurrente(
      SesionesRecurrentesTableCompanion(
        id: Value(id),
        alumnoId: Value(sesion.alumnoId),
        fuenteId: Value(sesion.fuenteId),
        diasSemana: Value(jsonEncode(sesion.diasSemana)),
        horaInicio: Value(sesion.horaInicio),
        horaFin: Value(sesion.horaFin),
        fechaInicio: Value(sesion.fechaInicio),
        fechaFin: Value(sesion.fechaFin),
        esPuntual: Value(sesion.esPuntual),
        activa: Value(sesion.activa),
        syncStatus: Value(sesion.syncStatus),
      ),
    );
  }

  Future<int> deleteSesionRecurrente(String id) =>
      _db.deleteSesionRecurrente(id);

  /// Desvincula sesiones realizadas NO pendientes (pone sesionRecurrenteId = null)
  /// para conservar historial al eliminar la recurrente.
  Future<int> desvincularSesionesRealizadas(String sesionRecurrenteId) =>
      _db.desvincularSesionesRealizadas(sesionRecurrenteId);

  /// Elimina sesiones realizadas pendientes y sus cobros asociados
  /// al eliminar una sesión recurrente.
  Future<int> deleteSesionesRealizadasPendientesByRecurrente(
    String sesionRecurrenteId,
  ) {
    print(
        '📦 REPOSITORY: deleteSesionesRealizadasPendientesByRecurrente llamado con id=$sesionRecurrenteId');
    return _db
        .deleteSesionesRealizadasPendientesByRecurrente(sesionRecurrenteId);
  }

  Future<int> deleteSesionRealizada(String id) => _db.deleteSesionRealizada(id);

  Future<List<SesionRealizada>> getSesionesRealizadasBySesionRecurrenteId(
    String sesionRecurrenteId,
  ) async {
    final rows =
        await _db.getSesionesRealizadasBySesionRecurrenteId(sesionRecurrenteId);
    return rows.map(_mapRealizada).toList();
  }

  Future<int> deleteSesionesRealizadasBySesionRecurrenteId(
    String sesionRecurrenteId,
  ) =>
      _db.deleteSesionesRealizadasBySesionRecurrenteId(sesionRecurrenteId);

  /// Limpia todas las SesionesRealizadas de una recurrente antes de borrarla:
  ///   - Con cobro cobrado → desvincula (conserva historial financiero).
  ///   - Sin cobro o cobro no cobrado → elimina cobro + sesión.
  Future<void> deleteAllSesionesRealizadasByRecurrente(
    String sesionRecurrenteId,
  ) =>
      _db.deleteAllSesionesRealizadasByRecurrente(sesionRecurrenteId);

  // ── Sesiones Realizadas ──────────────────────────────────────────

  Stream<List<SesionRealizada>> watchSesionesRealizadas() => _db
      .watchSesionesRealizadas()
      .map((rows) => rows.map(_mapRealizada).toList());

  Stream<List<SesionRealizada>> watchSesionesRealizadasByMes(
    String periodoMes,
  ) =>
      _db
          .watchSesionesRealizadasByMes(periodoMes)
          .map((rows) => rows.map(_mapRealizada).toList());

  Stream<List<SesionRealizada>> watchSesionesRealizadasByFecha(
    String fecha,
  ) =>
      _db
          .watchSesionesRealizadasByFecha(fecha)
          .map((rows) => rows.map(_mapRealizada).toList());

  Future<SesionRealizada?> getSesionRealizadaById(String id) async {
    final row = await _db.getSesionRealizadaById(id);
    return row == null ? null : _mapRealizada(row);
  }

  Stream<List<SesionRealizada>> watchSesionesRealizadasByFuenteAndMes(
    String fuenteId,
    String periodoMes,
  ) =>
      _db
          .watchSesionesRealizadasByFuenteAndMes(fuenteId, periodoMes)
          .map((rows) => rows.map(_mapRealizada).toList());

  Future<String> saveSesionRealizada(SesionRealizada sesion) {
    final id = sesion.id.isEmpty ? _uuid.v4() : sesion.id;
    return _db.upsertSesionRealizada(
      SesionesRealizadasTableCompanion(
        id: Value(id),
        alumnoId: Value(sesion.alumnoId),
        fuenteId: Value(sesion.fuenteId),
        sesionRecurrenteId: Value(sesion.sesionRecurrenteId),
        fecha: Value(sesion.fecha),
        horas: Value(sesion.horas),
        cobro: Value(sesion.cobro),
        estado: Value(sesion.estado.value),
        notas: Value(sesion.notas),
        temaSesion: Value(sesion.temaSesion),
        syncStatus: Value(sesion.syncStatus),
      ),
    );
  }
}
