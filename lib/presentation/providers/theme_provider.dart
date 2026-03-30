import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeModeKey = 'theme_mode';

/// Modos de tema disponibles en la app.
enum AppThemeMode { system, light, dark }

class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  ThemeModeNotifier() : super(AppThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kThemeModeKey);
    state = switch (stored) {
      'light' || 'pastel' => AppThemeMode.light,
      'dark' => AppThemeMode.dark,
      _ => AppThemeMode.system,
    };
  }

  Future<void> setMode(AppThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, mode.name);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, AppThemeMode>(
  (ref) => ThemeModeNotifier(),
);

// ── Tarifa global (€/h, fallback cuando alumno no tiene tarifa) ──────────────

const _kTarifaGlobalKey = 'tarifa_global';

class TarifaGlobalNotifier extends StateNotifier<double> {
  TarifaGlobalNotifier() : super(0.0) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(_kTarifaGlobalKey) ?? 0.0;
  }

  Future<void> set(double value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kTarifaGlobalKey, value);
  }
}

final tarifaGlobalProvider =
    StateNotifierProvider<TarifaGlobalNotifier, double>(
  (ref) => TarifaGlobalNotifier(),
);
