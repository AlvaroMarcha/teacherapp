/// Extensiones útiles sobre DateTime.
extension DateTimeExtension on DateTime {
  /// Devuelve true si este DateTime es el mismo día que [other].
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Devuelve true si este DateTime es hoy.
  bool get isToday => isSameDay(DateTime.now());

  /// Copia con los campos especificados reemplazados.
  DateTime copyWithTime({int? hour, int? minute}) =>
      DateTime(year, month, day, hour ?? this.hour, minute ?? this.minute);

  /// Inicio del día (00:00:00).
  DateTime get startOfDay => DateTime(year, month, day);

  /// Fin del día (23:59:59.999).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Primer día del mes.
  DateTime get firstDayOfMonth => DateTime(year, month, 1);

  /// Último día del mes.
  DateTime get lastDayOfMonth => DateTime(year, month + 1, 0);

  /// Período mes como "yyyy-MM".
  String get periodoMes => '$year-${month.toString().padLeft(2, '0')}';
}
