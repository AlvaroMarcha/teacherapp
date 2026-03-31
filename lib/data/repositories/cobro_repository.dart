import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../local/database.dart';
import '../../domain/models/cobro.dart';

class CobroRepository {
  const CobroRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  // ── Mappers ──────────────────────────────────────────────────────

  static Cobro _mapToCobro(CobrosTableData row) => Cobro(
        id: row.id,
        sesionId: row.sesionId,
        alumnoId: row.alumnoId,
        fuenteId: row.fuenteId,
        modoCobro: ModoCobroExt.fromString(row.modoCobro),
        periodoMes: row.periodoMes,
        monto: row.monto,
        montoParcial: row.montoParcial,
        estado: EstadoCobroExt.fromString(row.estado),
        fechaCobro: row.fechaCobro,
        notas: row.notas,
        syncStatus: row.syncStatus,
      );

  // ── Queries ──────────────────────────────────────────────────────

  Stream<List<Cobro>> watchAllCobros() =>
      _db.watchAllCobros().map((rows) => rows.map(_mapToCobro).toList());

  Stream<List<Cobro>> watchCobrosPendientes() =>
      _db.watchCobrosPendientes().map((rows) => rows.map(_mapToCobro).toList());

  Stream<List<Cobro>> watchCobrosByFuente(String fuenteId) => _db
      .watchCobrosByFuente(fuenteId)
      .map((rows) => rows.map(_mapToCobro).toList());

  Future<Cobro?> getCobroById(String id) async {
    final row = await _db.getCobroById(id);
    return row == null ? null : _mapToCobro(row);
  }

  Future<String> saveCobro(Cobro cobro) {
    final id = cobro.id.isEmpty ? _uuid.v4() : cobro.id;
    return _db.upsertCobro(
      CobrosTableCompanion(
        id: Value(id),
        sesionId: Value(cobro.sesionId),
        alumnoId: Value(cobro.alumnoId),
        fuenteId: Value(cobro.fuenteId),
        modoCobro: Value(cobro.modoCobro.value),
        periodoMes: Value(cobro.periodoMes),
        monto: Value(cobro.monto),
        montoParcial: Value(cobro.montoParcial),
        estado: Value(cobro.estado.value),
        fechaCobro: Value(cobro.fechaCobro),
        notas: Value(cobro.notas),
        syncStatus: Value(cobro.syncStatus),
      ),
    );
  }

  /// Marca un cobro como cobrado con la fecha actual.
  Future<void> marcarCobrado(String cobroId) async {
    final cobro = await getCobroById(cobroId);
    if (cobro == null) return;
    await saveCobro(
      cobro.copyWith(
        estado: EstadoCobro.cobrado,
        fechaCobro: DateTime.now().toIso8601String().substring(0, 10),
        syncStatus: 'pending',
      ),
    );
  }

  /// Registra un pago parcial.
  Future<void> marcarParcial(String cobroId, double montoCobrado) async {
    final cobro = await getCobroById(cobroId);
    if (cobro == null) return;
    await saveCobro(
      cobro.copyWith(
        estado: EstadoCobro.parcial,
        montoParcial: montoCobrado,
        syncStatus: 'pending',
      ),
    );
  }

  Future<int> deleteCobro(String id) => _db.deleteCobro(id);

  Future<int> deleteCobroBySesionId(String sesionId) =>
      _db.deleteCobroBySesionId(sesionId);
}
