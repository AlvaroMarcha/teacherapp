import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/drive_backup_service.dart';
import '../../core/services/scheduled_backup_service.dart';

// ── Servicios ────────────────────────────────────────────────────────────────

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService();
});

final driveBackupServiceProvider = Provider<DriveBackupService>((ref) {
  return DriveBackupService(ref.watch(backupServiceProvider));
});

// ── Estado de cuenta Google ──────────────────────────────────────────────────

final googleAccountProvider =
    StateProvider<GoogleSignInAccount?>((ref) => null);

// ── Estado del backup ────────────────────────────────────────────────────────

enum BackupState {
  idle,
  exporting,
  importing,
  uploading,
  downloading,
  success,
  error
}

final backupStateProvider =
    StateProvider<BackupState>((ref) => BackupState.idle);

// ── Última fecha de backup en Drive ──────────────────────────────────────────

final lastDriveBackupProvider = FutureProvider<DateTime?>((ref) async {
  final account = ref.watch(googleAccountProvider);
  if (account == null) return null;
  final driveService = ref.watch(driveBackupServiceProvider);
  return driveService.getLastBackupDate();
});

// ── Programación de backup automático ────────────────────────────────────────

final backupScheduleEnabledProvider = StateProvider<bool>((ref) => false);

final backupScheduleTimeProvider =
    StateProvider<TimeOfDay>((ref) => const TimeOfDay(hour: 2, minute: 0));

final backupScheduleTypeProvider = StateProvider<String>((ref) => 'local');

final lastAutoBackupProvider = FutureProvider<DateTime?>((ref) {
  return ScheduledBackupService.getLastAutoBackupDate();
});
