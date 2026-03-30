// TODO(firebase): Implementar en Sprint 7
// Este servicio sincronizará los datos locales con Firebase Firestore.
//
// Flujo offline-first:
//  1. Usuario realiza una acción → se guarda en SQLite con syncStatus='pending'
//  2. SyncService detecta conexión con connectivity_plus
//  3. Lee todos los registros con syncStatus='pending'
//  4. Los sube a Firestore en batch
//  5. Marca como syncStatus='synced'
//  6. Descarga cambios remotos (multi-dispositivo)
//
// Dependencias a añadir en pubspec.yaml cuando se implemente:
//   firebase_core: ^3.1.0
//   firebase_auth: ^5.1.0
//   cloud_firestore: ^5.1.0
//   firebase_messaging: ^15.0.0
//   workmanager: ^0.5.2

// ignore_for_file: unused_element

// class SyncService {
//   // TODO: implementar
// }
