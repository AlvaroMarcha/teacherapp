import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../local/database.dart';
import '../../domain/models/nota.dart';
import '../../domain/models/etiqueta.dart';

class NotaRepository {
  const NotaRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  // ── Mappers ──────────────────────────────────────────────────────

  static Nota _mapToNota(NotasTableData row,
          [List<String> etiquetaIds = const []]) =>
      Nota(
        id: row.id,
        titulo: row.titulo,
        contenido: row.contenido,
        tipo: TipoNotaExt.fromString(row.tipo),
        prioridad: PrioridadExt.fromString(row.prioridad),
        fechaRecordatorio: row.fechaRecordatorio,
        recurrencia: RecurrenciaExt.fromString(row.recurrencia),
        completada: row.completada,
        creadaEn: row.creadaEn,
        syncStatus: row.syncStatus,
        etiquetaIds: etiquetaIds,
      );

  static Etiqueta _mapToEtiqueta(EtiquetasTableData row) => Etiqueta(
        id: row.id,
        nombre: row.nombre,
        color: row.color,
      );

  // ── Notas — Queries ──────────────────────────────────────────────

  Stream<List<Nota>> watchAllNotas() =>
      _db.watchAllNotas().map((rows) => rows.map(_mapToNota).toList());

  Stream<List<Nota>> watchNotasByTipo(TipoNota tipo) => _db
      .watchNotasByTipo(tipo.value)
      .map((rows) => rows.map(_mapToNota).toList());

  Future<Nota?> getNotaById(String id) async {
    final row = await _db.getNotaById(id);
    if (row == null) return null;
    final joins = await _db.getEtiquetasForNota(id);
    return _mapToNota(row, joins.map((j) => j.etiquetaId).toList());
  }

  Future<String> saveNota(Nota nota) async {
    final id = nota.id.isEmpty ? _uuid.v4() : nota.id;
    await _db.upsertNota(
      NotasTableCompanion(
        id: Value(id),
        titulo: Value(nota.titulo),
        contenido: Value(nota.contenido),
        tipo: Value(nota.tipo.value),
        prioridad: Value(nota.prioridad.value),
        fechaRecordatorio: Value(nota.fechaRecordatorio),
        recurrencia: Value(nota.recurrencia.value),
        completada: Value(nota.completada),
        creadaEn: Value(nota.creadaEn),
        syncStatus: Value(nota.syncStatus),
      ),
    );
    await _db.setEtiquetasForNota(id, nota.etiquetaIds);
    return id;
  }

  Future<void> toggleCompletada(String id) async {
    final nota = await getNotaById(id);
    if (nota == null) return;
    await saveNota(nota.copyWith(
      completada: !nota.completada,
      syncStatus: 'pending',
    ));
  }

  Future<int> deleteNota(String id) async {
    await _db.setEtiquetasForNota(id, []);
    return _db.deleteNota(id);
  }

  Future<List<Nota>> getRecordatoriosPendientes() async {
    final rows = await _db.getRecordatoriosPendientes();
    return rows.map(_mapToNota).toList();
  }

  // ── Etiquetas — Queries ──────────────────────────────────────────

  Stream<List<Etiqueta>> watchAllEtiquetas() =>
      _db.watchAllEtiquetas().map((rows) => rows.map(_mapToEtiqueta).toList());

  Future<String> saveEtiqueta(Etiqueta etiqueta) {
    final id = etiqueta.id.isEmpty ? _uuid.v4() : etiqueta.id;
    return _db.upsertEtiqueta(
      EtiquetasTableCompanion(
        id: Value(id),
        nombre: Value(etiqueta.nombre),
        color: Value(etiqueta.color),
      ),
    );
  }

  Future<void> deleteEtiqueta(String id) async {
    await _db.deleteEtiquetaReferences(id);
    await _db.deleteEtiqueta(id);
  }
}
