import 'package:drift/drift.dart';

/// Tabla de sesiones que se han realizado/confirmado.
/// Al confirmar se genera un Cobro automáticamente.
class SesionesRealizadasTable extends Table {
  @override
  String get tableName => 'sesiones_realizadas';

  TextColumn get id => text()();
  TextColumn get alumnoId => text().nullable()();
  TextColumn get fuenteId => text()();

  /// "yyyy-MM-dd"
  TextColumn get fecha => text()();

  /// Duración en horas (decimal: 0.75 = 45 min)
  RealColumn get horas => real()();

  /// Importe calculado (€)
  RealColumn get cobro => real()();

  /// 'pendiente' | 'confirmada' | 'cancelada'
  TextColumn get estado => text().withDefault(const Constant('pendiente'))();

  /// FK opcional a la sesión recurrente que originó este registro.
  TextColumn get sesionRecurrenteId => text().nullable()();

  TextColumn get notas => text().withDefault(const Constant(''))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
