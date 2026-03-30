import 'package:drift/drift.dart';

/// Configuración del empleo fijo (Around).
/// Relación 1:1 con la fuente de tipo 'empleo'.
class EmpleoConfigTable extends Table {
  @override
  String get tableName => 'empleo_config';

  TextColumn get fuenteId => text()();
  RealColumn get salarioBase => real()();
  RealColumn get horasSemanales => real()();
  RealColumn get tarifaHoraExtra => real()();

  /// Día del mes en que se cobra (1-31).
  IntColumn get diaCobro => integer()();

  @override
  Set<Column> get primaryKey => {fuenteId};
}
