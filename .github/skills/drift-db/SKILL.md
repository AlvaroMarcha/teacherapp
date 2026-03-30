---
name: drift-db
description: Guía de patrones Drift para Teacher Finance App — tablas, queries CRUD, conversión modelo↔tabla, seed data, migraciones y testing con SQLite offline-first.
---

# Skill: Drift Database (offline-first)

Guía de referencia para trabajar con Drift en el proyecto Teacher Finance App.

## Setup

```yaml
# pubspec.yaml
dependencies:
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.24
  path_provider: ^2.1.3
  path: any
dev_dependencies:
  drift_dev: ^2.28.0
  build_runner: ^2.5.4
```

Comando de generación:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Estructura de tablas

Todas las tablas están en `lib/data/local/tables/`. Cada tabla es una clase que extiende `Table`:

```dart
// Patrón estándar de tabla
class AlumnosTable extends Table {
  TextColumn get id => text()();                      // PK manual (UUID)
  TextColumn get nombre => text()();
  TextColumn get fuenteId => text()();               // FK → fuentes_table
  RealColumn get tarifaSesion => real().withDefault(const Constant(0))();
  IntColumn get duracionMinutos => integer().withDefault(const Constant(60))();
  TextColumn get notas => text().withDefault(const Constant(''))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
```

### Tablas existentes

| Clase Dart | Tabla SQLite | Descripción |
|---|---|---|
| `FuentesTable` | `fuentes_table` | Fuentes de ingresos (Around, Angels, Particulares) |
| `EmpleoConfigTable` | `empleo_config_table` | Config salario/horas de empleo fijo |
| `AlumnosTable` | `alumnos_table` | Alumnos con tarifa y duración propia |
| `SesionesRecurrentesTable` | `sesiones_recurrentes_table` | Plantillas semanales de clases |
| `SesionesRealizadasTable` | `sesiones_realizadas_table` | Sesiones confirmadas |
| `CobrosTable` | `cobros_table` | Pagos generados (pendiente/cobrado/parcial) |

---

## Base de datos (`AppDatabase`)

```dart
@DriftDatabase(tables: [
  FuentesTable,
  EmpleoConfigTable,
  AlumnosTable,
  SesionesRecurrentesTable,
  SesionesRealizadasTable,
  CobrosTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedDemoData();
    },
  );
}
```

---

## Patrones de queries

### Stream (reactivo)
```dart
// Todos los registros ordenados
Stream<List<AlumnosTableData>> watchAlumnos() =>
    (select(alumnosTable)
      ..orderBy([(t) => OrderingTerm.asc(t.nombre)]))
    .watch();

// Filtrado por FK
Stream<List<AlumnosTableData>> watchAlumnosByFuente(String fuenteId) =>
    (select(alumnosTable)
      ..where((t) => t.fuenteId.equals(fuenteId)))
    .watch();
```

### Future (one-shot)
```dart
// Por ID
Future<AlumnosTableData?> getAlumnoById(String id) =>
    (select(alumnosTable)..where((t) => t.id.equals(id)))
    .getSingleOrNull();

// Todos como Future
Future<List<CobrosTableData>> getCobrosDelMes(String periodo) =>
    (select(cobrosTable)
      ..where((t) => t.periodoMes.equals(periodo)))
    .get();
```

### Insert/Update (upsert)
```dart
Future<void> upsertAlumno(AlumnosTableCompanion alumno) =>
    into(alumnosTable).insertOnConflictUpdate(alumno);
```

### Delete
```dart
Future<int> deleteAlumno(String id) =>
    (delete(alumnosTable)..where((t) => t.id.equals(id))).go();
```

---

## Conversión modelo ↔ tabla

Los repositorios convierten entre `TableData` (Drift) y modelos de dominio:

```dart
// TableData → Modelo
Alumno _fromRow(AlumnosTableData row) => Alumno(
  id: row.id,
  nombre: row.nombre,
  fuenteId: row.fuenteId,
  tarifaSesion: row.tarifaSesion,
  duracionMinutos: row.duracionMinutos,
  notas: row.notas,
  syncStatus: row.syncStatus,
);

// Modelo → Companion (para escribir)
AlumnosTableCompanion _toCompanion(Alumno a) => AlumnosTableCompanion(
  id: Value(a.id),
  nombre: Value(a.nombre),
  fuenteId: Value(a.fuenteId),
  tarifaSesion: Value(a.tarifaSesion),
  duracionMinutos: Value(a.duracionMinutos),
  notas: Value(a.notas),
  syncStatus: Value(a.syncStatus),
);
```

---

## Campos especiales

### Lista de enteros (diasSemana)
Drift no tiene `ListColumn`, se serializa como JSON string:
```dart
// Guardar
diasSemana: Value(jsonEncode(sesion.diasSemana)),  // "[1,3,5]"

// Leer
diasSemana: (jsonDecode(row.diasSemana) as List).cast<int>(),
```

### Enums
```dart
// Guardar (usando extensión .value)
estado: Value(cobro.estado.value),  // "pendiente" | "cobrado" | "parcial"

// Leer (usando fromString)
estado: EstadoCobroExt.fromString(row.estado),
```

---

## Seed data

En `_seedDemoData()` se crean las 3 fuentes de Lau en `onCreate`:

```dart
Future<void> _seedDemoData() async {
  await into(fuentesTable).insertOnConflictUpdate(FuentesTableCompanion(
    id: const Value('fuente-around'),
    nombre: const Value('Around'),
    tipo: const Value('empleo'),
    color: const Value('#2563EB'),
    syncStatus: const Value('pending'),
  ));
  // ... Angels (#6366F1), Particulares (#16A34A)
}
```

**Importante**: no modificar el seed sin autorización — Lau espera encontrar las 3 fuentes al abrir la app por primera vez.

---

## Migraciones

Para añadir columnas en versiones futuras:

```dart
@override
int get schemaVersion => 2;  // ← incrementar

@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) async { await m.createAll(); await _seedDemoData(); },
  onUpgrade: (m, from, to) async {
    if (from < 2) {
      await m.addColumn(alumnosTable, alumnosTable.fotoPerfil);
    }
  },
);
```

Ver [references/table-patterns.md](references/table-patterns.md) para más patrones.
