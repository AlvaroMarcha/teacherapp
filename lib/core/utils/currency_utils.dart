import 'package:intl/intl.dart';

/// Utilidades de formato de moneda para Teacher Finance App.
class CurrencyUtils {
  CurrencyUtils._();

  static final _eurFormatter = NumberFormat.currency(
    locale: 'es_ES',
    symbol: '€',
    decimalDigits: 2,
  );

  static final _eurCompactFormatter = NumberFormat.currency(
    locale: 'es_ES',
    symbol: '€',
    decimalDigits: 0,
  );

  /// Formatea un [amount] con símbolo de euro, e.g. "€1.840,00"
  static String format(double amount) => _eurFormatter.format(amount);

  /// Formatea sin decimales si es número entero, e.g. "€1.840"
  static String formatCompact(double amount) {
    if (amount == amount.truncate()) {
      return _eurCompactFormatter.format(amount);
    }
    return _eurFormatter.format(amount);
  }

  /// Formatea con signo + para valores positivos.
  static String formatSigned(double amount) {
    final formatted = format(amount.abs());
    return amount >= 0 ? '+$formatted' : '-$formatted';
  }

  /// Convierte string "€1.840,00" a double.
  static double parse(String value) {
    final cleaned = value
        .replaceAll('€', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(cleaned) ?? 0;
  }
}
