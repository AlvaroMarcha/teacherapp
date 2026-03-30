---
name: firebase-sync
description: Arquitectura de sincronización Firebase para Teacher Finance App (Sprint 7). Diseño local-first, estructura Firestore, flujo push/pull, manejo de conflictos y checklist de implementación.
---

# Skill: Firebase Sync (Sprint 7 — futuro)

Arquitectura y patrones para implementar la sincronización con Firebase cuando llegue el momento. **NO implementar hasta Sprint 7.**

## Estado actual

El archivo `lib/data/remote/sync_service.dart` es un **stub** (placeholder) con TODOs. La app funciona 100% offline usando Drift + SQLite.

---

## Arquitectura planeada

```
App (offline-first)
    │
    ├── AppDatabase (Drift + SQLite)  ← fuente de verdad local
    │
    └── SyncService                   ← orquesta la sincronización
            │
            ├── FirebaseFirestore      ← datos de negocio
            └── FirebaseAuth           ← autenticación (opcional)
```

### Principio clave: **Local-first, sync-second**
1. Todas las escrituras van primero a SQLite
2. `syncStatus` en cada entidad rastreará el estado de sync: `'pending'` | `'synced'` | `'conflict'`
3. El sync ocurre en background cuando hay conexión

---

## Dependencias a añadir (Sprint 7)

```yaml
# pubspec.yaml — añadir en Sprint 7
dependencies:
  firebase_core: ^2.x
  cloud_firestore: ^4.x
  firebase_auth: ^4.x       # si se pide auth
```

---

## Modelo de sync por entidad

Cada tabla ya tiene columna `syncStatus`:

```dart
// Estados de sync
const syncPending = 'pending';   // cambio local, no sincronizado
const syncSynced  = 'synced';    // sincronizado con Firestore
const syncError   = 'error';     // fallo de sync
```

### Flujo de escritura con sync

```dart
// Patrón a implementar en los repositorios
Future<void> saveAlumno(Alumno alumno) async {
  // 1. Guardar en SQLite (immediato, offline-safe)
  await _db.upsertAlumno(alumno.copyWith(syncStatus: 'pending'));

  // 2. Intentar sync si hay conexión
  if (await _connectivity.isConnected) {
    try {
      await _syncService.pushAlumno(alumno);
      await _db.markAsSynced(alumno.id);
    } catch (e) {
      // Error de sync — se reintentará más tarde
      // El dato LOCAL está seguro en SQLite
    }
  }
}
```

---

## Estructura Firestore (planeada)

```
/users/{userId}/
  fuentes/{fuenteId}
  alumnos/{alumnoId}
  sesiones_recurrentes/{id}
  sesiones_realizadas/{id}
  cobros/{id}
  empleo_config/{fuenteId}
```

### IDs: UUIDs de SQLite = IDs de Firestore
Los UUIDs ya generados localmente (`Uuid().v4()`) serán los IDs de documentos Firestore. **No cambiar el sistema de IDs.**

---

## Detección de conectividad

Ya disponible via `connectivity_plus`:

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

// En SyncService
Stream<bool> get isConnectedStream =>
    Connectivity().onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );
```

---

## Queue de sync (patrón recomendado)

Para manejar operaciones offline → online:

```dart
// Tabla de cola de sync (añadir en Sprint 7)
// sync_queue_table.dart
class SyncQueueTable extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()(); // 'alumno', 'cobro', etc.
  TextColumn get entityId => text()();
  TextColumn get operation => text()();  // 'upsert', 'delete'
  IntColumn get createdAt => integer()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
}
```

---

## Conflictos

Estrategia: **last-write-wins** (por ahora, Sprint 7).
- Comparar timestamp modificación
- Si timestamp local > Firestore → local gana
- Si Firestore > local → Firestore gana

Para Sprint 8+: se puede implementar CRDT o merge manual.

---

## Implementación del SyncService stub

El stub actual en `lib/data/remote/sync_service.dart` tiene TODOs marcados. Al implementar:

```dart
// Sprint 7: reemplazar TODOs con implementación real
class SyncService {
  final AppDatabase _db;
  final FirebaseFirestore _firestore;

  // TODO Sprint 7: implementar push individual
  Future<void> pushAlumno(Alumno alumno) async { ... }

  // TODO Sprint 7: implementar pull completo del usuario
  Future<void> fullSync(String userId) async { ... }

  // TODO Sprint 7: sincronización delta (solo cambios)
  Future<void> deltaSync(String userId, DateTime since) async { ... }
}
```

---

## Checklist antes de implementar sync (Sprint 7)

- [ ] Decidir si se requiere autenticación (Firebase Auth)
- [ ] Definir modelo de seguridad Firestore (`rules`)
- [ ] Testear con >500 sesiones para validar performance
- [ ] Añadir tabla `sync_queue_table` para cola de operaciones
- [ ] Migrar schema a versión 2 (añadir índices de sync)
- [ ] Definir estrategia de conflictos final

Ver [references/sync-architecture.md](references/sync-architecture.md) para decisiones de arquitectura documentadas.
