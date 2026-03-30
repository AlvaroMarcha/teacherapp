---
name: riverpod
description: Guía de state management con Riverpod para Teacher Finance App — StreamProvider, FutureProvider, family, NotifierProvider, patrones de lectura/escritura y refresco de providers.
---

# Skill: Riverpod — State Management

Guía de referencia para trabajar con Riverpod en Teacher Finance App.

## Setup

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
dev_dependencies:
  riverpod_generator: ^2.6.5
```

**Nota**: El proyecto usa Riverpod manual (sin `@riverpod` code-gen en la mayoría de providers). Los providers se definen en `lib/presentation/providers/`.

---

## Provider base: base de datos

```dart
// database_provider.dart
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);  // ← IMPORTANTE: siempre cerrar
  return db;
});
```

Los 4 repos se derivan del databaseProvider:

```dart
final fuenteRepositoryProvider = Provider<FuenteRepository>((ref) =>
    FuenteRepository(ref.watch(databaseProvider)));

final alumnoRepositoryProvider = Provider<AlumnoRepository>((ref) =>
    AlumnoRepository(ref.watch(databaseProvider)));

final sesionRepositoryProvider = Provider<SesionRepository>((ref) =>
    SesionRepository(ref.watch(databaseProvider)));

final cobroRepositoryProvider = Provider<CobroRepository>((ref) =>
    CobroRepository(ref.watch(databaseProvider)));
```

---

## Patrones de providers por tipo de dato

### StreamProvider — listas reactivas
```dart
// Lista que se actualiza automáticamente cuando cambia la DB
final alumnosProvider = StreamProvider<List<Alumno>>((ref) {
  return ref.watch(alumnoRepositoryProvider).watchAlumnos();
});
```

### StreamProvider.family — listas filtradas
```dart
// Alumnos filtrados por fuenteId
final alumnosByFuenteProvider =
    StreamProvider.family<List<Alumno>, String>((ref, fuenteId) {
  return ref.watch(alumnoRepositoryProvider).watchAlumnosByFuente(fuenteId);
});
```

### FutureProvider — datos asincrónicos one-shot
```dart
final empleoConfigProvider = FutureProvider.family<EmpleoConfig?, String>(
  (ref, fuenteId) =>
      ref.watch(fuenteRepositoryProvider).getEmpleoConfig(fuenteId),
);
```

### StateProvider — estado UI simple
```dart
// Tab seleccionado, filtro actual, etc.
final cobrosFilterProvider = StateProvider<EstadoCobro?>((ref) => null);
```

### Provider (compute) — datos derivados
```dart
// DashboardData combina cobros + sesiones + fuentes
final dashboardProvider = StreamProvider<DashboardData>((ref) async* {
  final cobros = await ref.watch(cobrosProvider.future);
  final fuentes = await ref.watch(fuentesProvider.future);
  // ... combinar y emitir DashboardData
});
```

---

## Consumir en widgets

### ConsumerWidget (widgets sin estado)
```dart
class AlumnosListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alumnosAsync = ref.watch(alumnosProvider);

    return alumnosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (alumnos) => ListView.builder(
        itemCount: alumnos.length,
        itemBuilder: (_, i) => AlumnoTile(alumno: alumnos[i]),
      ),
    );
  }
}
```

### ConsumerStatefulWidget (widgets con estado)
```dart
class RegistroSesionScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<RegistroSesionScreen> createState() => _State();
}

class _State extends ConsumerState<RegistroSesionScreen> {
  Future<void> _guardar() async {
    // ref.read() para acciones (no ref.watch en callbacks)
    await ref.read(cobroRepositoryProvider).saveCobro(cobro);
    // Invalidar para refrescar
    ref.invalidate(cobrosProvider);
  }
}
```

---

## Reglas importantes

| ✅ Usar | ❌ Evitar |
|---|---|
| `ref.watch()` dentro de `build()` | `ref.watch()` dentro de callbacks/futures |
| `ref.read()` en callbacks y métodos async | `ref.read()` en `build()` para estado reactivo |
| `ref.invalidate(provider)` para forzar refresh | `setState()` para recargar from DB |
| `StreamProvider` para datos Drift (son streams) | `FutureProvider` para Drift streams |

---

## Patrón de escritura + refresco

```dart
// En un ConsumerStatefulWidget
Future<void> _guardarAlumno(Alumno alumno) async {
  await ref.read(alumnoRepositoryProvider).saveAlumno(alumno);
  // Los StreamProviders se actualizan automáticamente gracias a Drift streams
  // Solo invalidar si hay FutureProviders o computados:
  ref.invalidate(dashboardProvider);
}
```

---

## DashboardData — provider compuesto

```dart
class DashboardData {
  final List<Cobro> cobros;
  final List<SesionRealizada> sesiones;
  final List<Fuente> fuentes;
  // ... métodos derivados:
  double get totalMes => ...
  double get totalPendiente => ...
  List<FuenteResumen> get resumenPorFuente => ...
}

class FuenteResumen {
  final Fuente fuente;
  final double totalCobrado;
  final double totalPendiente;
  final double totalHoras;
}
```

Ver [references/provider-patterns.md](references/provider-patterns.md) para más ejemplos.
