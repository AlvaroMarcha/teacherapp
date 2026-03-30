import 'package:drift/drift.dart';

/// Tabla de cobros (generados automáticamente o manuales).
class CobrosTable extends Table {
  @override
  String get tableName => 'cobros';

  TextColumn get id => text()();
  TextColumn get sesionId => text().nullable()();
  TextColumn get alumnoId => text().nullable()();
  TextColumn get fuenteId => text()();

  /// 'sesion' | 'mensual'
  TextColumn get modoCobro => text()();

  /// "yyyy-MM" para cobros mensuales
  TextColumn get periodoMes => text().nullable()();

  /// Importe total del cobro (€)
  RealColumn get monto => real()();

  /// Importe cobrado en pago parcial (€)
  RealColumn get montoParcial => real().nullable()();

  /// 'pendiente' | 'cobrado' | 'parcial'
  TextColumn get estado => text().withDefault(const Constant('pendiente'))();

  /// "yyyy-MM-dd" de cuándo se cobró
  TextColumn get fechaCobro => text().nullable()();

  TextColumn get notas => text().withDefault(const Constant(''))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
