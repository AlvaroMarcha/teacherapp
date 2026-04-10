import 'dart:convert';
import 'package:drift/drift.dart';

/// Converter para almacenar List<String> como JSON en SQLite.
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();
  
  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty || fromDb == '[]') return [];
    try {
      return (jsonDecode(fromDb) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }
  
  @override
  String toSql(List<String> value) {
    return jsonEncode(value);
  }
}

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
  TextColumn get materia => text().withDefault(const Constant(''))();
  TextColumn get nivel => text().withDefault(const Constant(''))();
  TextColumn get materiales => text().map(const StringListConverter()).withDefault(const Constant('[]'))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
