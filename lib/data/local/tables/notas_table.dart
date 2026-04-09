import 'package:drift/drift.dart';

/// Tabla de notas y recordatorios.
class NotasTable extends Table {
  @override
  String get tableName => 'notas';

  TextColumn get id => text()();
  TextColumn get titulo => text()();
  TextColumn get contenido => text().withDefault(const Constant(''))();

  /// 'nota' | 'recordatorio'
  TextColumn get tipo => text().withDefault(const Constant('nota'))();

  /// 'alta' | 'media' | 'baja'
  TextColumn get prioridad => text().withDefault(const Constant('media'))();

  /// ISO 8601 datetime para recordatorio (nullable si es nota simple)
  TextColumn get fechaRecordatorio => text().nullable()();

  /// 'ninguna' | 'diaria' | 'semanal' | 'mensual'
  TextColumn get recurrencia => text().withDefault(const Constant('ninguna'))();

  BoolColumn get completada => boolean().withDefault(const Constant(false))();

  TextColumn get creadaEn => text()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
