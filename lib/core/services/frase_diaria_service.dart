import 'package:shared_preferences/shared_preferences.dart';
import '../constants/frases_motivacion.dart';

/// Servicio para gestionar las frases motivacionales diarias.
///
/// - Primera vez: muestra "No olvido el color de tu mirada."
/// - Luego: rota las 200 frases sin repetir hasta completar todas
/// - Cambia de frase cada día
class FraseDiariaService {
  FraseDiariaService._();

  static const _keyPrimerLogin = 'frase_primer_login';
  static const _keyIndiceActual = 'frase_indice_actual';
  static const _keyUltimaFecha = 'frase_ultima_fecha';

  /// Obtiene la frase motivacional del día.
  static Future<String> getFraseDelDia() async {
    final prefs = await SharedPreferences.getInstance();

    // Verificar si es el primer login
    final esPrimerLogin = prefs.getBool(_keyPrimerLogin) ?? true;

    if (esPrimerLogin) {
      // Marcar como ya no es primer login
      await prefs.setBool(_keyPrimerLogin, false);
      // Inicializar índice en 0
      await prefs.setInt(_keyIndiceActual, 0);
      // Guardar fecha de hoy
      await prefs.setString(_keyUltimaFecha, _getFechaHoy());

      // Devolver la frase especial
      return frasesMotivacionalesDiarias[0];
    }

    // Obtener la fecha de la última frase mostrada
    final ultimaFecha = prefs.getString(_keyUltimaFecha) ?? '';
    final fechaHoy = _getFechaHoy();

    // Si cambió el día, avanzar al siguiente índice
    int indiceActual = prefs.getInt(_keyIndiceActual) ?? 0;

    if (ultimaFecha != fechaHoy) {
      // Avanzar al siguiente índice
      indiceActual = (indiceActual + 1) % frasesMotivacionalesDiarias.length;

      // Guardar nuevo índice y fecha
      await prefs.setInt(_keyIndiceActual, indiceActual);
      await prefs.setString(_keyUltimaFecha, fechaHoy);
    }

    return frasesMotivacionalesDiarias[indiceActual];
  }

  /// Resetea el sistema de frases (para testing).
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPrimerLogin);
    await prefs.remove(_keyIndiceActual);
    await prefs.remove(_keyUltimaFecha);
  }

  /// Obtiene la fecha actual en formato yyyy-MM-dd.
  static String _getFechaHoy() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
