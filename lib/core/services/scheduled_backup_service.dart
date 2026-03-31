import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'backup_service.dart';
import 'drive_backup_service.dart';

// ── Constantes ───────────────────────────────────────────────────────────────

const _taskName = 'scheduled_backup';
const _taskUniqueName = 'teacher_finance_daily_backup';

// SharedPreferences keys
const kBackupScheduleEnabled = 'backup_schedule_enabled';
const kBackupScheduleHour = 'backup_schedule_hour';
const kBackupScheduleMinute = 'backup_schedule_minute';
const kBackupScheduleType = 'backup_schedule_type'; // 'local' | 'drive'
const kLastAutoBackupDate = 'last_auto_backup_date';

// ── Callback top-level (requerido por Workmanager) ───────────────────────────

@pragma('vm:entry-point')
void backupCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != _taskName) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final type = prefs.getString(kBackupScheduleType) ?? 'local';

      final backupService = BackupService();

      if (type == 'drive') {
        final driveService = DriveBackupService(backupService);
        final account = await driveService.signInSilently();
        if (account != null) {
          await driveService.uploadBackup();
        } else {
          // Sin sesión → fallback a copia local
          await backupService.createAutoBackup();
        }
      } else {
        await backupService.createAutoBackup();
      }

      await prefs.setString(
        kLastAutoBackupDate,
        DateTime.now().toIso8601String(),
      );

      // Enviar notificación
      await _showBackupNotification(type == 'drive' ? 'Google Drive' : 'Local');

      return true;
    } catch (_) {
      return false;
    }
  });
}

/// Notificación desde el isolate de background (no tiene acceso al singleton).
Future<void> _showBackupNotification(String type) async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: androidSettings);
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(settings: settings);

  const androidDetails = AndroidNotificationDetails(
    'backup',
    'Copia de seguridad',
    channelDescription: 'Notificaciones de copia de seguridad automática',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );
  const details = NotificationDetails(android: androidDetails);
  await plugin.show(
    id: 9999,
    title: 'Copia de seguridad completada',
    body: 'Backup $type realizado correctamente',
    notificationDetails: details,
  );
}

// ── Servicio de programación ─────────────────────────────────────────────────

class ScheduledBackupService {
  /// Inicializa Workmanager. Llamar una vez en main().
  static Future<void> init() async {
    await Workmanager().initialize(backupCallbackDispatcher);
  }

  /// Activa (o actualiza) la programación diaria.
  static Future<void> enable({
    required int hour,
    required int minute,
    required String type,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kBackupScheduleEnabled, true);
    await prefs.setInt(kBackupScheduleHour, hour);
    await prefs.setInt(kBackupScheduleMinute, minute);
    await prefs.setString(kBackupScheduleType, type);

    // Calcular delay hasta la próxima hora indicada
    final now = DateTime.now();
    var nextRun = DateTime(now.year, now.month, now.day, hour, minute);
    if (nextRun.isBefore(now)) {
      nextRun = nextRun.add(const Duration(days: 1));
    }
    final initialDelay = nextRun.difference(now);

    await Workmanager().registerPeriodicTask(
      _taskUniqueName,
      _taskName,
      frequency: const Duration(hours: 24),
      initialDelay: initialDelay,
      constraints: Constraints(
        networkType:
            type == 'drive' ? NetworkType.connected : NetworkType.notRequired,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  /// Desactiva la programación.
  static Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kBackupScheduleEnabled, false);
    await Workmanager().cancelByUniqueName(_taskUniqueName);
  }

  // ── Lectura de preferencias ──

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(kBackupScheduleEnabled) ?? false;
  }

  static Future<TimeOfDayData> getScheduleTime() async {
    final prefs = await SharedPreferences.getInstance();
    return TimeOfDayData(
      hour: prefs.getInt(kBackupScheduleHour) ?? 2,
      minute: prefs.getInt(kBackupScheduleMinute) ?? 0,
    );
  }

  static Future<String> getScheduleType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kBackupScheduleType) ?? 'local';
  }

  static Future<DateTime?> getLastAutoBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(kLastAutoBackupDate);
    if (str == null) return null;
    return DateTime.tryParse(str);
  }
}

/// Data class simple para hora/minuto (evita depender de Flutter en el service).
class TimeOfDayData {
  final int hour;
  final int minute;
  const TimeOfDayData({required this.hour, required this.minute});
}
