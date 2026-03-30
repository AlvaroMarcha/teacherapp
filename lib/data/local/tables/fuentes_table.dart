import 'package:drift/drift.dart';

/// Tabla de fuentes de ingreso (Around, Angels, Particulares, etc.)
class FuentesTable extends Table {
  @override
  String get tableName => 'fuentes';

  TextColumn get id => text()();
  TextColumn get nombre => text()();

  /// Tipo: 'empleo' | 'academia' | 'particular'
  TextColumn get tipo => text()();

  /// Color hex sin # (e.g. "2563EB")
  TextColumn get color => text()();

  TextColumn get moneda => text().withDefault(const Constant('EUR'))();

  /// Estado de sincronización: 'pending' | 'synced'
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
