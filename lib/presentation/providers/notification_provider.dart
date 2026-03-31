import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/notification_service.dart';
import 'sesiones_provider.dart';
import 'theme_provider.dart';

const _kNotifMinutesKey = 'notif_minutes_before';
const _kNotifEnabledKey = 'notif_enabled';

// ── Minutos de antelación ────────────────────────────────────────────────────

class NotifMinutesNotifier extends StateNotifier<int> {
  NotifMinutesNotifier() : super(10) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(_kNotifMinutesKey) ?? 10;
  }

  Future<void> set(int minutes) async {
    state = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kNotifMinutesKey, minutes);
  }
}

final notifMinutesProvider = StateNotifierProvider<NotifMinutesNotifier, int>(
  (ref) => NotifMinutesNotifier(),
);

// ── Activar/desactivar notificaciones ────────────────────────────────────────

class NotifEnabledNotifier extends StateNotifier<bool> {
  NotifEnabledNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_kNotifEnabledKey) ?? false;
  }

  Future<void> set(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifEnabledKey, enabled);
  }
}

final notifEnabledProvider = StateNotifierProvider<NotifEnabledNotifier, bool>(
  (ref) => NotifEnabledNotifier(),
);

// ── Programar notificaciones del día ─────────────────────────────────────────

final scheduleNotificationsProvider = FutureProvider<void>((ref) async {
  final enabled = ref.watch(notifEnabledProvider);
  if (!enabled) {
    await NotificationService.instance.cancelAll();
    return;
  }

  final minutes = ref.watch(notifMinutesProvider);
  final hoy = DateUtils.dateOnly(DateTime.now());
  final eventosAsync = ref.watch(eventosDelDiaProvider(hoy));
  final eventos = eventosAsync.valueOrNull ?? [];
  final l = ref.watch(appLocalizationsProvider);

  await NotificationService.instance.cancelAll();

  for (int i = 0; i < eventos.length; i++) {
    final evento = eventos[i];
    final horaInicio = _parseTime(evento.horaInicio, hoy);
    if (horaInicio == null) continue;

    final scheduledTime = horaInicio.subtract(Duration(minutes: minutes));

    await NotificationService.instance.scheduleClassReminder(
      id: i,
      title: l.clasesDeHoy,
      body: '${evento.titulo} – ${evento.horaInicio}',
      scheduledTime: scheduledTime,
    );
  }
});

DateTime? _parseTime(String hhmm, DateTime day) {
  final parts = hhmm.split(':');
  if (parts.length != 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  return DateTime(day.year, day.month, day.day, h, m);
}
