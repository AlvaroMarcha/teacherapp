# Drift — Patrones adicionales de tablas

## Tipos de columna Drift

| Tipo Dart | Columna Drift | Ejemplo |
|---|---|---|
| `String` | `TextColumn` | `text()()` |
| `int` | `IntColumn` | `integer()()` |
| `double` | `RealColumn` | `real()()` |
| `bool` | `BoolColumn` | `boolean()()` |
| `DateTime` | `DateTimeColumn` | `dateTime()()` |
| `Uint8List` | `BlobColumn` | `blob()()` |

## Columnas con restricciones

```dart
// Nullable
TextColumn get alumnoId => text().nullable()();

// Con valor por defecto
TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
IntColumn get duracion => integer().withDefault(const Constant(60))();

// Con longitud máxima (solo hint, no restricción SQLite)
TextColumn get nombre => text().withLength(min: 1, max: 100)();

// Referencia a otra tabla (FK conceptual, Drift no enforcea FKs por defecto)
TextColumn get fuenteId => text()();  // FK → fuentes_table.id
```

## Índices personalizados

```dart
@DataClassName('CobrosTableData')
class CobrosTable extends Table {
  // ...

  @override
  List<Set<Column>> get uniqueKeys => []; // unique constraints

  // Para añadir índices, usar customStatement en onCreate:
}

// En AppDatabase.onCreate:
await customStatement(
  'CREATE INDEX IF NOT EXISTS idx_cobros_fuente ON cobros_table(fuente_id)',
);
```

## Queries agrupadas (aggregates)

```dart
// Total cobrado por fuente (usando SQL crudo)
Future<Map<String, double>> getTotalPorFuente() async {
  final result = await customSelect(
    'SELECT fuente_id, SUM(monto) as total FROM cobros_table '
    'WHERE estado = ? GROUP BY fuente_id',
    variables: [Variable('cobrado')],
  ).get();

  return {
    for (final row in result)
      row.read<String>('fuente_id'): row.read<double>('total'),
  };
}
```

## Transacciones

```dart
// Para operaciones atómicas (ej: confirmar sesión + crear cobro)
Future<void> confirmarSesionYCobro(
  SesionRealizada sesion,
  Cobro cobro,
) async {
  await transaction(() async {
    await upsertSesionRealizada(sesion);
    await upsertCobro(cobro);
  });
}
```

## Testing con base de datos en memoria

```dart
// En tests:
late AppDatabase db;

setUp(() {
  db = AppDatabase.forTesting(
    DatabaseConnection(NativeDatabase.memory()),
  );
});

tearDown(() => db.close());

test('guardaAlumno', () async {
  await db.upsertAlumno(AlumnosTableCompanion(
    id: const Value('test-id'),
    nombre: const Value('Ana'),
    fuenteId: const Value('fuente-particulares'),
    tarifaSesion: const Value(20.0),
    duracionMinutos: const Value(60),
  ));
  final alumno = await db.getAlumnoById('test-id');
  expect(alumno?.nombre, 'Ana');
});
```
