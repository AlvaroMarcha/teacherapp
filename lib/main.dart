import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/services/cobro_auto_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/scheduled_backup_service.dart';
import 'data/local/database.dart';
import 'app.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await initializeDateFormatting('es_ES', null);
  await NotificationService.instance.init();
  await ScheduledBackupService.init();

  // Auto-generar cobros pendientes para sesiones recurrentes
  final db = AppDatabase();
  await CobroAutoService.generarCobrosPendientes(db);
  await db.close();

  FlutterNativeSplash.remove();
  runApp(const ProviderScope(child: TeacherApp()));
}
