import 'package:drift/drift.dart';

/// Nómina real mensual de una fuente de empleo.
/// PK compuesta: (fuenteId, anio, mes) → upsert semántico.
class EmpleoNominasTable extends Table {
  @override
  String get tableName => 'empleo_nominas';

  TextColumn get fuenteId => text()();
  IntColumn get anio => integer()();
  IntColumn get mes => integer()();

  /// Salario real cobrado ese mes (€).
  RealColumn get salario => real()();

  TextColumn get notas => text().withDefault(const Constant(''))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  TextColumn get creadaEn => text()();

  @override
  Set<Column> get primaryKey => {fuenteId, anio, mes};
}
