import 'package:drift/drift.dart';

/// Tabla de etiquetas para categorizar notas.
class EtiquetasTable extends Table {
  @override
  String get tableName => 'etiquetas';

  TextColumn get id => text()();
  TextColumn get nombre => text()();

  /// Color hex (e.g. 'FF5722')
  TextColumn get color => text().withDefault(const Constant('6366F1'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla join notas ↔ etiquetas (relación N:M).
class NotasEtiquetasTable extends Table {
  @override
  String get tableName => 'notas_etiquetas';

  TextColumn get notaId => text()();
  TextColumn get etiquetaId => text()();

  @override
  Set<Column> get primaryKey => {notaId, etiquetaId};
}
