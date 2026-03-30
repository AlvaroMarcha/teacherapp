import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables/fuentes_table.dart';
import 'tables/empleo_config_table.dart';
import 'tables/alumnos_table.dart';
import 'tables/sesiones_recurrentes_table.dart';
import 'tables/sesiones_realizadas_table.dart';
import 'tables/cobros_table.dart';

part 'database.g.dart';

/// Base de datos SQLite local (Drift).
///
/// Arquitectura offline-first: todas las operaciones leen/escriben aquí.
/// El futuro SyncService se encargará de replicar a Firestore.
///
/// Para regenerar el código generado:
///   flutter pub run build_runner build --delete-conflicting-outputs
@DriftDatabase(
  tables: [
    FuentesTable,
    EmpleoConfigTable,
    AlumnosTable,
    SesionesRecurrentesTable,
    SesionesRealizadasTable,
    CobrosTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Para tests: acepta una conexión inyectada.
  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedDemoData();
        },
        onUpgrade: (m, from, to) async {
          // Migraciones futuras aquí
        },
      );

  // ── Queries — Fuentes ────────────────────────────────────────────

  Stream<List<FuentesTableData>> watchAllFuentes() =>
      select(fuentesTable).watch();

  Future<List<FuentesTableData>> getAllFuentes() => select(fuentesTable).get();

  Future<FuentesTableData?> getFuenteById(String id) =>
      (select(fuentesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<String> upsertFuente(FuentesTableCompanion fuente) => into(
        fuentesTable,
      ).insertOnConflictUpdate(fuente).then((_) => fuente.id.value);

  Future<int> deleteFuente(String id) =>
      (delete(fuentesTable)..where((t) => t.id.equals(id))).go();

  // ── Queries — EmpleoConfig ───────────────────────────────────────

  Future<EmpleoConfigTableData?> getEmpleoConfig(String fuenteId) => (select(
        empleoConfigTable,
      )..where((t) => t.fuenteId.equals(fuenteId)))
          .getSingleOrNull();

  Future<void> upsertEmpleoConfig(EmpleoConfigTableCompanion config) =>
      into(empleoConfigTable).insertOnConflictUpdate(config);

  // ── Queries — Alumnos ────────────────────────────────────────────

  Stream<List<AlumnosTableData>> watchAllAlumnos() =>
      select(alumnosTable).watch();

  Stream<List<AlumnosTableData>> watchAlumnosByFuente(String fuenteId) =>
      (select(alumnosTable)..where((t) => t.fuenteId.equals(fuenteId))).watch();

  Future<AlumnosTableData?> getAlumnoById(String id) =>
      (select(alumnosTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<String> upsertAlumno(AlumnosTableCompanion alumno) => into(
        alumnosTable,
      ).insertOnConflictUpdate(alumno).then((_) => alumno.id.value);

  Future<int> deleteAlumno(String id) =>
      (delete(alumnosTable)..where((t) => t.id.equals(id))).go();

  // ── Queries — Sesiones Recurrentes ──────────────────────────────

  Stream<List<SesionesRecurrentesTableData>> watchSesionesRecurrentes() =>
      select(sesionesRecurrentesTable).watch();

  Future<List<SesionesRecurrentesTableData>> getSesionesRecurrentes() =>
      select(sesionesRecurrentesTable).get();

  Future<String> upsertSesionRecurrente(
    SesionesRecurrentesTableCompanion sesion,
  ) =>
      into(
        sesionesRecurrentesTable,
      ).insertOnConflictUpdate(sesion).then((_) => sesion.id.value);

  Future<int> deleteSesionRecurrente(String id) =>
      (delete(sesionesRecurrentesTable)..where((t) => t.id.equals(id))).go();

  // ── Queries — Sesiones Realizadas ────────────────────────────────

  Stream<List<SesionesRealizadasTableData>> watchSesionesRealizadas() =>
      select(sesionesRealizadasTable).watch();

  Stream<List<SesionesRealizadasTableData>> watchSesionesRealizadasByMes(
    String periodoMes,
  ) =>
      (select(
        sesionesRealizadasTable,
      )..where((t) => t.fecha.like('$periodoMes%')))
          .watch();

  Future<String> upsertSesionRealizada(
    SesionesRealizadasTableCompanion sesion,
  ) =>
      into(
        sesionesRealizadasTable,
      ).insertOnConflictUpdate(sesion).then((_) => sesion.id.value);

  // ── Queries — Cobros ─────────────────────────────────────────────

  Stream<List<CobrosTableData>> watchAllCobros() => select(cobrosTable).watch();

  Stream<List<CobrosTableData>> watchCobrosPendientes() => (select(cobrosTable)
        ..where(
          (t) => t.estado.equals('pendiente') | t.estado.equals('parcial'),
        )
        ..orderBy([(t) => OrderingTerm.asc(t.id)]))
      .watch();

  Stream<List<CobrosTableData>> watchCobrosByFuente(String fuenteId) =>
      (select(cobrosTable)..where((t) => t.fuenteId.equals(fuenteId))).watch();

  Future<CobrosTableData?> getCobroById(String id) =>
      (select(cobrosTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<String> upsertCobro(CobrosTableCompanion cobro) => into(
        cobrosTable,
      ).insertOnConflictUpdate(cobro).then((_) => cobro.id.value);

  Future<int> deleteCobro(String id) =>
      (delete(cobrosTable)..where((t) => t.id.equals(id))).go();

  Future<void> deleteCobrosByFuente(String fuenteId) =>
      (delete(cobrosTable)..where((t) => t.fuenteId.equals(fuenteId))).go();

  Future<void> deleteSesionesRealizadasByFuente(String fuenteId) =>
      (delete(sesionesRealizadasTable)
            ..where((t) => t.fuenteId.equals(fuenteId)))
          .go();

  Future<void> deleteSesionesRecurrentesByFuente(String fuenteId) =>
      (delete(sesionesRecurrentesTable)
            ..where((t) => t.fuenteId.equals(fuenteId)))
          .go();

  Future<void> deleteAlumnosByFuente(String fuenteId) =>
      (delete(alumnosTable)..where((t) => t.fuenteId.equals(fuenteId))).go();

  Future<void> deleteEmpleoConfigByFuente(String fuenteId) =>
      (delete(empleoConfigTable)..where((t) => t.fuenteId.equals(fuenteId)))
          .go();

  // ── Aggregates (Dashboard) ───────────────────────────────────────

  /// Total de pendientes (€) del mes actual.
  Future<double> getTotalPendienteMes(String periodoMes) async {
    final cobros = await (select(cobrosTable)
          ..where(
            (t) => t.estado.equals('pendiente') | t.estado.equals('parcial'),
          ))
        .get();
    return cobros.fold<double>(0, (acc, c) {
      if (c.estado == 'parcial' && c.montoParcial != null) {
        return acc + (c.monto - c.montoParcial!);
      }
      return acc + c.monto;
    });
  }

  // ── Seed data (solo primera instalación) ────────────────────────

  Future<void> _seedDemoData() async {
    // Las 3 fuentes de Lau (ejemplo del informe)
    await upsertFuente(
      FuentesTableCompanion.insert(
        id: 'fuente-around',
        nombre: 'Around',
        tipo: 'empleo',
        color: '2563EB',
      ),
    );
    await upsertFuente(
      FuentesTableCompanion.insert(
        id: 'fuente-angels',
        nombre: 'Angels',
        tipo: 'academia',
        color: '6366F1',
      ),
    );
    await upsertFuente(
      FuentesTableCompanion.insert(
        id: 'fuente-particulares',
        nombre: 'Particulares',
        tipo: 'particular',
        color: '16A34A',
      ),
    );

    // Configuración empleo Around
    await upsertEmpleoConfig(
      EmpleoConfigTableCompanion.insert(
        fuenteId: 'fuente-around',
        salarioBase: 1840,
        horasSemanales: 16,
        tarifaHoraExtra: 14.5,
        diaCobro: 28,
      ),
    );
  }
}

/// Abre la conexión a la base de datos SQLite del dispositivo.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'teacher_app.db'));
    return NativeDatabase.createInBackground(file);
  });
}
