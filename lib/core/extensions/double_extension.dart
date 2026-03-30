import 'package:intl/intl.dart';

/// Extensiones útiles sobre double para moneda y porcentajes.
extension DoubleExtension on double {
  /// Formatea como euro: "€20,00"
  String get asEuro =>
      NumberFormat.currency(locale: 'es_ES', symbol: '€').format(this);

  /// Formatea como euro sin decimales si es entero: "€20"
  String get asEuroCompact {
    if (this == truncate()) {
      return NumberFormat.currency(
        locale: 'es_ES',
        symbol: '€',
        decimalDigits: 0,
      ).format(this);
    }
    return asEuro;
  }

  /// Formatea como porcentaje: "85,0%"
  String get asPercent =>
      NumberFormat.percentPattern('es_ES').format(this / 100);

  /// Redondea a [decimals] lugares decimales.
  double roundTo(int decimals) {
    final factor = 10.0.pow(decimals);
    return (this * factor).round() / factor;
  }
}

extension _Pow on double {
  double pow(int exp) {
    double result = 1.0;
    for (var i = 0; i < exp; i++) {
      result *= this;
    }
    return result;
  }
}
