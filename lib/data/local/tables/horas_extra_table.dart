import 'package:drift/drift.dart';

/// Registros de horas extra trabajadas en fuentes de tipo [FuenteTipo.empleo].
///
/// Cada registro corresponde a un bloque de horas extra reportadas por el usuario
/// para una semana o periodo concreto.
class HorasExtraTable extends Table {
  TextColumn get id => text()();
  TextColumn get fuenteId => text()();

  /// Fecha del registro en formato "yyyy-MM-dd".
  TextColumn get fecha => text()();

  RealColumn get horas => real()();

  /// Alumno asociado a estas horas extra (opcional).
  TextColumn get alumnoId => text().nullable()();

  TextColumn get notas => text().withDefault(const Constant(''))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
