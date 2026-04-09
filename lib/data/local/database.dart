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
import 'tables/horas_extra_table.dart';
import 'tables/notas_table.dart';
import 'tables/etiquetas_table.dart';

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
    HorasExtraTable,
    NotasTable,
    EtiquetasTable,
    NotasEtiquetasTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Para tests: acepta una conexión inyectada.
  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedDemoData();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(horasExtraTable);
          }
          if (from < 3) {
            await m.addColumn(horasExtraTable, horasExtraTable.alumnoId);
          }
          if (from < 4) {
            // Wrapped in try/catch — column may already exist if a previous
            // migration run crashed after ALTER TABLE but before version bump.
            try {
              await m.addColumn(
                sesionesRecurrentesTable,
                sesionesRecurrentesTable.esPuntual,
              );
            } catch (_) {}
            try {
              await m.addColumn(
                sesionesRealizadasTable,
                sesionesRealizadasTable.sesionRecurrenteId,
              );
            } catch (_) {}
          }
          if (from < 5) {
            try {
              await m.addColumn(
                sesionesRecurrentesTable,
                sesionesRecurrentesTable.activa,
              );
            } catch (_) {}
          }
          if (from < 6) {
            await m.createTable(notasTable);
            await m.createTable(etiquetasTable);
            await m.createTable(notasEtiquetasTable);
          }
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

  Future<List<AlumnosTableData>> getAllAlumnos() => select(alumnosTable).get();

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

  Future<SesionesRecurrentesTableData?> getSesionRecurrenteById(String id) =>
      (select(sesionesRecurrentesTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<String> upsertSesionRecurrente(
    SesionesRecurrentesTableCompanion sesion,
  ) =>
      into(
        sesionesRecurrentesTable,
      ).insertOnConflictUpdate(sesion).then((_) => sesion.id.value);

  Future<int> deleteSesionRecurrente(String id) =>
      (delete(sesionesRecurrentesTable)..where((t) => t.id.equals(id))).go();

  /// Desvincula sesiones realizadas de su recurrente (pone sesionRecurrenteId = null).
  /// Solo desvincula las que NO están pendientes (conserva historial).
  /// Las pendientes se eliminan con [deleteSesionesRealizadasPendientesByRecurrente].
  Future<int> desvincularSesionesRealizadas(String sesionRecurrenteId) =>
      (update(sesionesRealizadasTable)
            ..where(
              (t) =>
                  t.sesionRecurrenteId.equals(sesionRecurrenteId) &
                  t.estado.equals('pendiente').not(),
            ))
          .write(
        const SesionesRealizadasTableCompanion(
          sesionRecurrenteId: Value(null),
        ),
      );

  /// Elimina TODAS las SesionesRealizadas pendientes de una sesión recurrente
  /// y sus Cobros pendientes asociados. Usado al eliminar una sesión recurrente.
  Future<int> deleteSesionesRealizadasPendientesByRecurrente(
    String sesionRecurrenteId,
  ) async {
    return await transaction(() async {
      // 1. Buscar sesiones pendientes vinculadas a esta recurrente
      final sesiones = await (select(sesionesRealizadasTable)
            ..where(
              (t) =>
                  t.sesionRecurrenteId.equals(sesionRecurrenteId) &
                  t.estado.equals('pendiente'),
            ))
          .get();

      print('🔍 deletePendientesByRecurrente: id=$sesionRecurrenteId, '
          'found=${sesiones.length} pendientes');

      if (sesiones.isEmpty) return 0;

      // 2. Eliminar Cobros asociados a esas sesiones
      final sesionIds = sesiones.map((s) => s.id).toList();
      final cobrosDeleted = await (delete(cobrosTable)
            ..where((t) => t.sesionId.isIn(sesionIds)))
          .go();

      print('🗑️ deletePendientesByRecurrente: deleted $cobrosDeleted cobros');

      // 3. Eliminar las SesionesRealizadas pendientes
      final sesionesDeleted = await (delete(sesionesRealizadasTable)
            ..where((t) => t.id.isIn(sesionIds)))
          .go();

      print(
          '🗑️ deletePendientesByRecurrente: deleted $sesionesDeleted sesiones');
      return sesionesDeleted;
    });
  }

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

  Stream<List<SesionesRealizadasTableData>> watchSesionesRealizadasByFecha(
    String fecha,
  ) =>
      (select(sesionesRealizadasTable)..where((t) => t.fecha.equals(fecha)))
          .watch();

  Future<SesionesRealizadasTableData?> getSesionRealizadaById(String id) =>
      (select(sesionesRealizadasTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Stream<List<SesionesRealizadasTableData>>
      watchSesionesRealizadasByFuenteAndMes(
    String fuenteId,
    String periodoMes,
  ) =>
          (select(sesionesRealizadasTable)
                ..where(
                  (t) =>
                      t.fuenteId.equals(fuenteId) &
                      t.fecha.like('$periodoMes%') &
                      t.estado.equals('confirmada'),
                ))
              .watch();

  Future<String> upsertSesionRealizada(
    SesionesRealizadasTableCompanion sesion,
  ) =>
      into(
        sesionesRealizadasTable,
      ).insertOnConflictUpdate(sesion).then((_) => sesion.id.value);

  Future<int> deleteSesionRealizada(String id) =>
      (delete(sesionesRealizadasTable)..where((t) => t.id.equals(id))).go();

  /// Elimina SesionesRealizadas pendientes futuras de una sesión recurrente
  /// y sus Cobros asociados. Usado al editar una sesión recurrente para
  /// regenerar cobros con los nuevos parámetros.
  Future<int> deleteSesionesRealizadasPendientesFuturas(
    String sesionRecurrenteId,
    String fechaDesde,
  ) async {
    return await transaction(() async {
      // 1. Obtener SesionesRealizadas pendientes futuras
      final sesiones = await (select(sesionesRealizadasTable)
            ..where(
              (t) =>
                  t.sesionRecurrenteId.equals(sesionRecurrenteId) &
                  t.estado.equals('pendiente') &
                  t.fecha.isBiggerOrEqualValue(fechaDesde),
            ))
          .get();

      if (sesiones.isEmpty) return 0;

      // 2. Eliminar Cobros asociados
      final sesionIds = sesiones.map((s) => s.id).toList();
      await (delete(cobrosTable)..where((t) => t.sesionId.isIn(sesionIds)))
          .go();

      // 3. Eliminar SesionesRealizadas
      return await (delete(sesionesRealizadasTable)
            ..where(
              (t) =>
                  t.sesionRecurrenteId.equals(sesionRecurrenteId) &
                  t.estado.equals('pendiente') &
                  t.fecha.isBiggerOrEqualValue(fechaDesde),
            ))
          .go();
    });
  }

  /// Elimina TODAS las SesionesRealizadas pendientes futuras (de cualquier
  /// sesión recurrente) y sus Cobros asociados. Usado al cambiar la
  /// configuración de días futuros en Ajustes.
  Future<int> deleteAllSesionesRealizadasPendientesFuturas(
    String fechaDesde,
  ) async {
    return await transaction(() async {
      final sesiones = await (select(sesionesRealizadasTable)
            ..where(
              (t) =>
                  t.sesionRecurrenteId.isNotNull() &
                  t.estado.equals('pendiente') &
                  t.fecha.isBiggerOrEqualValue(fechaDesde),
            ))
          .get();

      if (sesiones.isEmpty) return 0;

      final sesionIds = sesiones.map((s) => s.id).toList();
      await (delete(cobrosTable)..where((t) => t.sesionId.isIn(sesionIds)))
          .go();

      return await (delete(sesionesRealizadasTable)
            ..where(
              (t) =>
                  t.sesionRecurrenteId.isNotNull() &
                  t.estado.equals('pendiente') &
                  t.fecha.isBiggerOrEqualValue(fechaDesde),
            ))
          .go();
    });
  }

  Future<List<SesionesRealizadasTableData>>
      getSesionesRealizadasBySesionRecurrenteId(
    String sesionRecurrenteId,
  ) =>
          (select(sesionesRealizadasTable)
                ..where((t) => t.sesionRecurrenteId.equals(sesionRecurrenteId)))
              .get();

  /// Busca si ya existe una SesionRealizada para un recurrenteId + fecha.
  Future<SesionesRealizadasTableData?> getSesionRealizadaByRecurrenteAndFecha(
    String recurrenteId,
    String fecha,
  ) =>
      (select(sesionesRealizadasTable)
            ..where(
              (t) =>
                  t.sesionRecurrenteId.equals(recurrenteId) &
                  t.fecha.equals(fecha),
            ))
          .getSingleOrNull();

  /// Obtiene sesiones recurrentes activas (no archivadas, no puntuales).
  Future<List<SesionesRecurrentesTableData>>
      getSesionesRecurrentesActivasRecurrentes() =>
          (select(sesionesRecurrentesTable)
                ..where(
                  (t) => t.activa.equals(true) & t.esPuntual.equals(false),
                ))
              .get();

  Future<int> deleteSesionesRealizadasBySesionRecurrenteId(
    String sesionRecurrenteId,
  ) =>
      (delete(sesionesRealizadasTable)
            ..where((t) => t.sesionRecurrenteId.equals(sesionRecurrenteId)))
          .go();

  Future<int> deleteHoraExtraByFechaAndFuente(
    String fecha,
    String fuenteId,
  ) =>
      (delete(horasExtraTable)
            ..where(
              (t) => t.fecha.equals(fecha) & t.fuenteId.equals(fuenteId),
            ))
          .go();

  Future<int> deleteSesionRealizadaByFechaAndFuente(
    String fecha,
    String fuenteId,
  ) =>
      (delete(sesionesRealizadasTable)
            ..where(
              (t) => t.fecha.equals(fecha) & t.fuenteId.equals(fuenteId),
            ))
          .go();

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

  Future<CobrosTableData?> getCobroBySesionId(String sesionId) =>
      (select(cobrosTable)..where((t) => t.sesionId.equals(sesionId)))
          .getSingleOrNull();

  Future<String> upsertCobro(CobrosTableCompanion cobro) => into(
        cobrosTable,
      ).insertOnConflictUpdate(cobro).then((_) => cobro.id.value);

  Future<int> deleteCobro(String id) =>
      (delete(cobrosTable)..where((t) => t.id.equals(id))).go();

  Future<int> deleteCobroBySesionId(String sesionId) =>
      (delete(cobrosTable)..where((t) => t.sesionId.equals(sesionId))).go();

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

  // ── Queries — Horas Extra ────────────────────────────────────────

  Stream<List<HorasExtraTableData>> watchAllHorasExtra() =>
      select(horasExtraTable).watch();

  Stream<List<HorasExtraTableData>> watchHorasExtraByFuente(
    String fuenteId,
  ) =>
      (select(horasExtraTable)
            ..where((t) => t.fuenteId.equals(fuenteId))
            ..orderBy([(t) => OrderingTerm.desc(t.fecha)]))
          .watch();

  Future<void> upsertHoraExtra(HorasExtraTableCompanion entry) =>
      into(horasExtraTable).insertOnConflictUpdate(entry);

  Future<int> deleteHoraExtra(String id) =>
      (delete(horasExtraTable)..where((t) => t.id.equals(id))).go();

  Future<void> deleteHorasExtraByFuente(String fuenteId) =>
      (delete(horasExtraTable)..where((t) => t.fuenteId.equals(fuenteId))).go();

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

  // ── Queries — Notas ───────────────────────────────────────────────

  Stream<List<NotasTableData>> watchAllNotas() =>
      (select(notasTable)..orderBy([(t) => OrderingTerm.desc(t.creadaEn)]))
          .watch();

  Stream<List<NotasTableData>> watchNotasByTipo(String tipo) =>
      (select(notasTable)
            ..where((t) => t.tipo.equals(tipo))
            ..orderBy([(t) => OrderingTerm.desc(t.creadaEn)]))
          .watch();

  Future<NotasTableData?> getNotaById(String id) =>
      (select(notasTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<String> upsertNota(NotasTableCompanion nota) =>
      into(notasTable).insertOnConflictUpdate(nota).then((_) => nota.id.value);

  Future<int> deleteNota(String id) =>
      (delete(notasTable)..where((t) => t.id.equals(id))).go();

  /// Obtiene recordatorios pendientes (no completados) con fecha futura o de hoy.
  Future<List<NotasTableData>> getRecordatoriosPendientes() =>
      (select(notasTable)
            ..where(
              (t) =>
                  t.tipo.equals('recordatorio') &
                  t.completada.equals(false) &
                  t.fechaRecordatorio.isNotNull(),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.fechaRecordatorio)]))
          .get();

  // ── Queries — Etiquetas ──────────────────────────────────────────

  Stream<List<EtiquetasTableData>> watchAllEtiquetas() =>
      select(etiquetasTable).watch();

  Future<String> upsertEtiqueta(EtiquetasTableCompanion etiqueta) =>
      into(etiquetasTable)
          .insertOnConflictUpdate(etiqueta)
          .then((_) => etiqueta.id.value);

  Future<int> deleteEtiqueta(String id) =>
      (delete(etiquetasTable)..where((t) => t.id.equals(id))).go();

  // ── Queries — NotasEtiquetas (join) ──────────────────────────────

  Future<List<NotasEtiquetasTableData>> getEtiquetasForNota(
    String notaId,
  ) =>
      (select(notasEtiquetasTable)..where((t) => t.notaId.equals(notaId)))
          .get();

  Future<void> setEtiquetasForNota(
    String notaId,
    List<String> etiquetaIds,
  ) async {
    await transaction(() async {
      await (delete(notasEtiquetasTable)..where((t) => t.notaId.equals(notaId)))
          .go();
      for (final eid in etiquetaIds) {
        await into(notasEtiquetasTable).insert(
          NotasEtiquetasTableCompanion.insert(
            notaId: notaId,
            etiquetaId: eid,
          ),
        );
      }
    });
  }

  Future<void> deleteEtiquetaReferences(String etiquetaId) =>
      (delete(notasEtiquetasTable)
            ..where((t) => t.etiquetaId.equals(etiquetaId)))
          .go();

  // ── Factory Reset ────────────────────────────────────────────────

  /// Elimina TODOS los datos de TODAS las tablas.
  /// ⚠️ Esta acción es IRREVERSIBLE.
  /// Se recomienda hacer un backup antes de ejecutar.
  Future<void> clearAllData() async {
    await transaction(() async {
      // Orden de eliminación: respetando dependencias
      await delete(notasEtiquetasTable).go();
      await delete(notasTable).go();
      await delete(etiquetasTable).go();
      await delete(cobrosTable).go();
      await delete(sesionesRealizadasTable).go();
      await delete(horasExtraTable).go();
      await delete(sesionesRecurrentesTable).go();
      await delete(alumnosTable).go();
      await delete(empleoConfigTable).go();
      await delete(fuentesTable).go();
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
