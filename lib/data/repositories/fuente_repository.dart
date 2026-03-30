import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../local/database.dart';
import '../../domain/models/fuente.dart';
import '../../domain/models/empleo_config.dart';

class FuenteRepository {
  const FuenteRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  // ── Mappers ──────────────────────────────────────────────────────

  static Fuente _mapToFuente(FuentesTableData row) => Fuente(
        id: row.id,
        nombre: row.nombre,
        tipo: FuenteTipoExt.fromString(row.tipo),
        color: row.color,
        moneda: row.moneda,
        syncStatus: row.syncStatus,
      );

  static FuentesTableCompanion _mapToCompanion(Fuente f) =>
      FuentesTableCompanion(
        id: Value(f.id),
        nombre: Value(f.nombre),
        tipo: Value(f.tipo.value),
        color: Value(f.color),
        moneda: Value(f.moneda),
        syncStatus: Value(f.syncStatus),
      );

  static EmpleoConfig _mapToEmpleoConfig(EmpleoConfigTableData row) =>
      EmpleoConfig(
        fuenteId: row.fuenteId,
        salarioBase: row.salarioBase,
        horasSemanales: row.horasSemanales,
        tarifaHoraExtra: row.tarifaHoraExtra,
        diaCobro: row.diaCobro,
      );

  // ── Fuentes ──────────────────────────────────────────────────────

  Stream<List<Fuente>> watchAllFuentes() =>
      _db.watchAllFuentes().map((rows) => rows.map(_mapToFuente).toList());

  Future<List<Fuente>> getAllFuentes() async {
    final rows = await _db.getAllFuentes();
    return rows.map(_mapToFuente).toList();
  }

  Future<Fuente?> getFuenteById(String id) async {
    final row = await _db.getFuenteById(id);
    return row == null ? null : _mapToFuente(row);
  }

  Future<String> saveFuente(Fuente fuente) {
    final id = fuente.id.isEmpty ? _uuid.v4() : fuente.id;
    return _db.upsertFuente(_mapToCompanion(fuente.copyWith(id: id)));
  }

  Future<int> deleteFuente(String id) => _db.deleteFuente(id);

  Future<void> deleteFuenteCascade(String id) => _db.transaction(() async {
        await _db.deleteCobrosByFuente(id);
        await _db.deleteSesionesRealizadasByFuente(id);
        await _db.deleteSesionesRecurrentesByFuente(id);
        await _db.deleteAlumnosByFuente(id);
        await _db.deleteEmpleoConfigByFuente(id);
        await _db.deleteFuente(id);
      });

  // ── EmpleoConfig ─────────────────────────────────────────────────

  Future<EmpleoConfig?> getEmpleoConfig(String fuenteId) async {
    final row = await _db.getEmpleoConfig(fuenteId);
    return row == null ? null : _mapToEmpleoConfig(row);
  }

  Future<void> saveEmpleoConfig(EmpleoConfig config) => _db.upsertEmpleoConfig(
        EmpleoConfigTableCompanion(
          fuenteId: Value(config.fuenteId),
          salarioBase: Value(config.salarioBase),
          horasSemanales: Value(config.horasSemanales),
          tarifaHoraExtra: Value(config.tarifaHoraExtra),
          diaCobro: Value(config.diaCobro),
        ),
      );
}
