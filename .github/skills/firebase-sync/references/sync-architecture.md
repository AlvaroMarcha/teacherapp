# Firebase Sync — Arquitectura detallada (Sprint 7)

## Decisiones de diseño documentadas

### Por qué local-first
- La app debe funcionar sin internet (profesora puede estar en casa sin WiFi)
- Los datos financieros son críticos — no perder ningún cobro
- UX: cero latencia en todas las operaciones
- SQLite como fuente de verdad garantiza consistencia

### Por qué Firestore y no Realtime Database
- Consultas más flexibles (filtros compuestos)
- Escalabilidad de colecciones
- Offline support nativo (aunque nosotros ya lo manejamos con SQLite)
- Mejor integración con Firebase Rules para multi-user (futuro)

---

## Estructura de documentos Firestore

### Usuario raíz
```
/users/{userId}/
  ├── profile/
  │   └── config   { nombre, monedaPreferida }
  ├── fuentes/{fuenteId}/
  │   └── { nombre, tipo, color, ... }
  ├── alumnos/{alumnoId}/
  │   └── { nombre, fuenteId, tarifaSesion, ... }
  ├── sesiones_recurrentes/{id}/
  │   └── { fuenteId, alumnoId, diasSemana, horaInicio, horaFin, ... }
  ├── sesiones_realizadas/{id}/
  │   └── { fuenteId, alumnoId, fecha, horas, cobro, estado, ... }
  └── cobros/{id}/
      └── { fuenteId, alumnoId, monto, estado, modoCobro, ... }
```

### Timestamps de sincronización
```json
{
  "id": "uuid-generado-localmente",
  "nombre": "Blanca",
  "updatedAt": "2025-07-15T18:30:00Z",   // Firestore ServerTimestamp
  "createdAt": "2025-01-10T09:00:00Z"
}
```

---

## Flujo de sync completo

### Push (local → Firestore)
1. Usuario hace cambio → SQLite actualizado con `syncStatus = 'pending'`
2. `SyncService.push()` recorre entidades `pending`
3. Escribe en Firestore con `merge: true` (no sobreescribir campos no enviados)
4. Si éxito → `syncStatus = 'synced'`
5. Si error → `syncStatus = 'error'`, se reintentará

### Pull (Firestore → local)
1. Al iniciar app con conexión, `SyncService.pull()` descarga cambios desde `lastSyncTs`
2. Compara timestamp de cada documento con versión local
3. Si Firestore es más nuevo → actualizar SQLite
4. Guardar `lastSyncTs` en SharedPreferences

### Conflictos
- **Estrategia inicial (Sprint 7)**: last-write-wins por `updatedAt`
- **Estrategia avanzada (Sprint 8+)**: mostrar diálogo al usuario para resolver conflictos en cobros

---

## Código base del SyncService (Sprint 7)

```dart
class SyncService {
  SyncService({required AppDatabase db, required FirebaseFirestore firestore})
      : _db = db,
        _firestore = firestore;

  final AppDatabase _db;
  final FirebaseFirestore _firestore;
  String? _userId;

  void setUserId(String id) => _userId = id;

  Future<void> pushPending() async {
    if (_userId == null) return;
    final pending = await _db.getEntitiesWithSyncStatus('pending');
    for (final entity in pending) {
      try {
        await _firestore
            .collection('users/$_userId/${entity.collectionName}')
            .doc(entity.id)
            .set(entity.toFirestore(), SetOptions(merge: true));
        await _db.markAsSynced(entity.id, entity.tableName);
      } catch (e) {
        await _db.markSyncError(entity.id, entity.tableName);
      }
    }
  }
}
```

---

## Seguridad (Firestore Rules)

```js
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Solo el usuario puede acceder a sus datos
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }
  }
}
```

---

## Checklist de implementación Sprint 7

### Setup
- [ ] `flutter pub add firebase_core cloud_firestore`
- [ ] `flutterfire configure` para iOS y Android
- [ ] Añadir `google-services.json` y `GoogleService-Info.plist`

### Base de datos
```dart
// Migración a schemaVersion 2
if (from < 2) {
  // Añadir índice para sync queries
  await customStatement(
    'CREATE INDEX IF NOT EXISTS idx_sync_status '
    'ON alumnos_table(sync_status)',
  );
  // ... mismo para cada tabla
}
```

### SyncService
- [ ] Implementar `pushPending()`
- [ ] Implementar `pullChanges()`
- [ ] Integrar detector de conectividad
- [ ] Añadir retry con exponential backoff

### UI
- [ ] Añadir banner "Offline" cuando no hay conexión
- [ ] Indicador de sync en ajustes (última sincronización)
- [ ] Activar la pantalla de Sincronización en `ajustes_screen.dart`
