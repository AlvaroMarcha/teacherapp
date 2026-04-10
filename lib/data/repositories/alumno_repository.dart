import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../local/database.dart';
import '../../domain/models/alumno.dart';

class AlumnoRepository {
  const AlumnoRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  // ── Mappers ──────────────────────────────────────────────────────

  static Alumno _mapToAlumno(AlumnosTableData row) => Alumno(
        id: row.id,
        nombre: row.nombre,
        fuenteId: row.fuenteId,
        tarifaSesion: row.tarifaSesion,
        duracionMinutos: row.duracionMinutos,
        notas: row.notas,
        materia: row.materia,
        nivel: row.nivel,
        materiales: row.materiales,
        syncStatus: row.syncStatus,
      );

  // ── Queries ──────────────────────────────────────────────────────

  Stream<List<Alumno>> watchAllAlumnos() =>
      _db.watchAllAlumnos().map((rows) => rows.map(_mapToAlumno).toList());

  Stream<List<Alumno>> watchAlumnosByFuente(String fuenteId) => _db
      .watchAlumnosByFuente(fuenteId)
      .map((rows) => rows.map(_mapToAlumno).toList());

  Future<Alumno?> getAlumnoById(String id) async {
    final row = await _db.getAlumnoById(id);
    return row == null ? null : _mapToAlumno(row);
  }

  Future<String> saveAlumno(Alumno alumno) {
    final id = alumno.id.isEmpty ? _uuid.v4() : alumno.id;
    return _db.upsertAlumno(
      AlumnosTableCompanion(
        id: Value(id),
        nombre: Value(alumno.nombre),
        fuenteId: Value(alumno.fuenteId),
        tarifaSesion: Value(alumno.tarifaSesion),
        duracionMinutos: Value(alumno.duracionMinutos),
        notas: Value(alumno.notas),
        materia: Value(alumno.materia),
        nivel: Value(alumno.nivel),
        materiales: Value(alumno.materiales),
        syncStatus: Value(alumno.syncStatus),
      ),
    );
  }

  Future<int> deleteAlumno(String id) => _db.deleteAlumno(id);
}
