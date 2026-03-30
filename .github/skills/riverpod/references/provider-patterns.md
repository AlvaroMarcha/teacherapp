# Riverpod — Patrones adicionales de providers

## AsyncValue — manejo completo de estados

```dart
// Patrón completo con guard para loading y error
final dataAsync = ref.watch(alumnosProvider);

// Opción 1: when() — el más común
dataAsync.when(
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (e, stack) => ErrorScreen(error: e),
  data: (alumnos) => AlumnosList(alumnos: alumnos),
);

// Opción 2: map() — útil cuando ya tienes data pero quieres tratar loading
dataAsync.map(
  data: (d) => Text('${d.value.length} alumnos'),
  loading: (_) => const CircularProgressIndicator(),
  error: (_) => const Icon(Icons.error),
);

// Opción 3: acceso directo (cuando ya sabes que hay data)
final alumnos = dataAsync.valueOrNull ?? [];
```

## Providers con parámetros (family)

```dart
// Definition
final cobrosByAlumnoProvider =
    StreamProvider.family<List<Cobro>, String>((ref, alumnoId) {
  return ref.watch(cobroRepositoryProvider).watchCobrosByAlumno(alumnoId);
});

// Uso
ref.watch(cobrosByAlumnoProvider('alumno-id-123'))
```

## Combinar múltiples providers

```dart
// Usando combine de streams (Dart built-in)
final dashboardProvider = StreamProvider<DashboardData>((ref) {
  // Combina 3 streams en uno
  final cobrosStream = ref.watch(cobrosProvider.stream);
  final sesionesStream = ref.watch(sesionesProvider.stream);
  final fuentesStream = ref.watch(fuentesProvider.stream);

  return Rx.combineLatest3(
    cobrosStream,
    sesionesStream,
    fuentesStream,
    DashboardData.new,
  );
});

// Alternativa sin rxdart — usando async*
final dashboardProvider = StreamProvider<DashboardData>((ref) async* {
  // Escucha cambios y recalcula
  final cobros = await ref.watch(cobrosProvider.future);
  final fuentes = await ref.watch(fuentesProvider.future);
  yield DashboardData(cobros: cobros, fuentes: fuentes);
});
```

## NotifierProvider (para lógica de negocio compleja)

```dart
// Cuando un provider necesita métodos públicos
class CobrosNotifier extends AsyncNotifier<List<Cobro>> {
  @override
  Future<List<Cobro>> build() async {
    return ref.watch(cobroRepositoryProvider).getCobrosDelMes(
      AppDateUtils.periodoMes(DateTime.now()),
    );
  }

  Future<void> marcarCobrado(String cobroId) async {
    await ref.read(cobroRepositoryProvider).marcarCobrado(cobroId);
    ref.invalidateSelf();
  }
}

final cobrosNotifierProvider =
    AsyncNotifierProvider<CobrosNotifier, List<Cobro>>(CobrosNotifier.new);
```

## Invalidar y refrescar

```dart
// Fuerza recalcular un provider
ref.invalidate(dashboardProvider);

// Refrescar (equivalente a invalidate + watch inmediatamente)
ref.refresh(alumnosProvider);

// En un callback:
Future<void> onSave() async {
  await repo.saveData(data);
  if (mounted) {
    ref.invalidate(myProvider);
  }
}
```

## ProviderObserver (logging en debug)

```dart
// En main.dart — para debugging
class AppProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(ProviderBase provider, Object? prev, Object? next, ProviderContainer container) {
    debugPrint('[Provider] ${provider.name} updated: $next');
  }
}

runApp(
  ProviderScope(
    observers: [if (kDebugMode) AppProviderObserver()],
    child: const TeacherApp(),
  ),
);
```
