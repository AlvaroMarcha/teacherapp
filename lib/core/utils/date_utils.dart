import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utilidades para formateo de fechas.
class AppDateUtils {
  AppDateUtils._();

  static final _dayFormatter = DateFormat('EEEE', 'es_ES');
  static final _shortDayFormatter = DateFormat('EEE', 'es_ES');
  static final _monthFormatter = DateFormat('MMMM yyyy', 'es_ES');
  static final _shortDateFormatter = DateFormat('d MMM', 'es_ES');
  static final _fullDateFormatter = DateFormat('d MMMM yyyy', 'es_ES');
  static final _isoDateFormatter = DateFormat('yyyy-MM-dd');
  static final _timeFormatter = DateFormat('HH:mm');

  static String formatDayName(DateTime date) => _dayFormatter.format(date);
  static String formatShortDay(DateTime date) =>
      _shortDayFormatter.format(date);
  static String formatMonth(DateTime date) => _monthFormatter.format(date);
  static String formatShortDate(DateTime date) =>
      _shortDateFormatter.format(date);
  static String formatFullDate(DateTime date) =>
      _fullDateFormatter.format(date);
  static String formatIso(DateTime date) => _isoDateFormatter.format(date);
  static String formatTime(DateTime date) => _timeFormatter.format(date);

  /// Convierte "HH:mm" string a TimeOfDay.
  static TimeOfDay parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  /// Devuelve el primer día de la semana (lunes) que contiene [date].
  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday; // 1=Mon, 7=Sun
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  /// Devuelve el período "yyyy-MM" del mes de [date].
  static String periodoMes(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  /// Comprueba si [date] es hoy.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Comprueba si [date] está en la semana actual.
  static bool isThisWeek(DateTime date) {
    final weekStart = startOfWeek(DateTime.now());
    final weekEnd = weekStart.add(const Duration(days: 7));
    return date.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
        date.isBefore(weekEnd);
  }
}
