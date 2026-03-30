import 'package:drift/drift.dart';

/// Tabla de patrones de sesión recurrente.
/// Los días se guardan como JSON: "[1,3]" (Lun=1, Mié=3).
class SesionesRecurrentesTable extends Table {
  @override
  String get tableName => 'sesiones_recurrentes';

  TextColumn get id => text()();
  TextColumn get alumnoId => text().nullable()();
  TextColumn get fuenteId => text()();

  /// JSON array de días de la semana: "[1,3,5]"
  TextColumn get diasSemana => text()();

  /// "HH:mm"
  TextColumn get horaInicio => text()();

  /// "HH:mm"
  TextColumn get horaFin => text()();

  /// "yyyy-MM-dd"
  TextColumn get fechaInicio => text()();

  /// "yyyy-MM-dd" | null (indefinida)
  TextColumn get fechaFin => text().nullable()();

  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
