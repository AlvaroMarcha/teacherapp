import 'package:drift/drift.dart';

/// Tabla de alumnos del profesor.
class AlumnosTable extends Table {
  @override
  String get tableName => 'alumnos';

  TextColumn get id => text()();
  TextColumn get nombre => text()();
  TextColumn get fuenteId => text()();
  RealColumn get tarifaSesion => real()();
  IntColumn get duracionMinutos => integer().withDefault(const Constant(60))();
  TextColumn get notas => text().withDefault(const Constant(''))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
