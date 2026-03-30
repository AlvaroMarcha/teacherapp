import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../local/database.dart';
import '../../domain/models/hora_extra.dart';

class HorasExtraRepository {
  const HorasExtraRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  // ── Mapper ───────────────────────────────────────────────────────

  static HoraExtra _map(HorasExtraTableData row) => HoraExtra(
        id: row.id,
        fuenteId: row.fuenteId,
        fecha: row.fecha,
        horas: row.horas,
        alumnoId: row.alumnoId,
        notas: row.notas,
        syncStatus: row.syncStatus,
      );

  // ── Queries ──────────────────────────────────────────────────────

  Stream<List<HoraExtra>> watchAllHorasExtra() =>
      _db.watchAllHorasExtra().map((rows) => rows.map(_map).toList());

  Stream<List<HoraExtra>> watchHorasExtraByFuente(String fuenteId) => _db
      .watchHorasExtraByFuente(fuenteId)
      .map((rows) => rows.map(_map).toList());

  Future<void> saveHoraExtra(HoraExtra entry) {
    final id = entry.id.isEmpty ? _uuid.v4() : entry.id;
    return _db.upsertHoraExtra(
      HorasExtraTableCompanion(
        id: Value(id),
        fuenteId: Value(entry.fuenteId),
        fecha: Value(entry.fecha),
        horas: Value(entry.horas),
        alumnoId: Value(entry.alumnoId),
        notas: Value(entry.notas),
        syncStatus: Value(entry.syncStatus),
      ),
    );
  }

  Future<int> deleteHoraExtra(String id) => _db.deleteHoraExtra(id);
}
