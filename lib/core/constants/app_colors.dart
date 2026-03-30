import 'package:flutter/material.dart';

/// Design tokens de color para Teacher Finance App.
///
/// Paleta inspirada en el informe del producto:
///  - Primario: azul índigo (usado en Around / empleo fijo)
///  - Verde: alumnos particulares
///  - Morado: clases únicas / variables
///  - Gris: clases canceladas
class AppColors {
  AppColors._();

  // ── Primary ─────────────────────────────────────────────────────
  static const Color primary = Color(0xFF2563EB); // blue-600
  static const Color primaryLight = Color(0xFFEFF6FF); // blue-50
  static const Color primaryDark = Color(0xFF1D4ED8); // blue-700

  // ── Surface / Background ────────────────────────────────────────
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // ── Text ────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFFCBD5E1);

  // ── Fuentes de ingreso ──────────────────────────────────────────
  /// Around (empleo fijo) → Azul
  static const Color around = Color(0xFF2563EB);
  static const Color aroundLight = Color(0xFFDBEAFE);

  /// Angels (academia) → Añil/Indigo
  static const Color angels = Color(0xFF6366F1);
  static const Color angelsLight = Color(0xFFE0E7FF);

  /// Particulares → Verde
  static const Color particulares = Color(0xFF16A34A);
  static const Color particularesLight = Color(0xFFDCFCE7);

  // ── Tipos de sesión (calendario) ────────────────────────────────
  static const Color sesionRecurrente = Color(0xFF2563EB); // Azul
  static const Color sesionParticular = Color(0xFF16A34A); // Verde
  static const Color sesionUnica = Color(0xFF9333EA); // Morado
  static const Color sesionCancelada = Color(0xFF94A3B8); // Gris

  // ── Estado de cobros ────────────────────────────────────────────
  static const Color cobroPendiente = Color(0xFFF59E0B); // Amber
  static const Color cobroPendienteLight = Color(0xFFFEF3C7);
  static const Color cobroCobrado = Color(0xFF16A34A); // Verde
  static const Color cobroCobradoLight = Color(0xFFDCFCE7);
  static const Color cobroParcial = Color(0xFF0EA5E9); // Sky
  static const Color cobroParcialLight = Color(0xFFE0F2FE);

  // ── Semantic ────────────────────────────────────────────────────
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);

  // ── Borders & Dividers ──────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // ── Dark theme tokens (azul marino profundo) ────────────────────
  static const Color backgroundDark = Color(0xFF0D1B2E);
  static const Color surfaceDark = Color(0xFF15243B);
  static const Color surfaceVariantDark = Color(0xFF1C2F4A);

  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textDisabledDark = Color(0xFF475569);

  static const Color borderDark = Color(0xFF2D3C5A);
  static const Color dividerDark = Color(0xFF1C2F4A);

  static const Color primaryLightDark = Color(0xFF1E3A6E);

  static const Color aroundLightDark = Color(0xFF0F2A52);
  static const Color angelsLightDark = Color(0xFF1E1B4B);
  static const Color particularesLightDark = Color(0xFF052E16);

  static const Color cobroPendienteLightDark = Color(0xFF451A03);
  static const Color cobroCobradoLightDark = Color(0xFF052E16);
  static const Color cobroParcialLightDark = Color(0xFF082F49);

  static const Color errorLightDark = Color(0xFF450A0A);

  // ── Pastel theme tokens (lila pastel real) ───────────────────────
  static const Color backgroundPastel =
      Color(0xFFEDE9FE); // violet-100 — lila visible
  static const Color surfacePastel = Color(0xFFF5F3FF); // violet-50
  static const Color surfaceVariantPastel = Color(0xFFDDD6FE); // violet-200

  static const Color primaryPastel =
      Color(0xFF8B5CF6); // violet-500 — pastel suave
  static const Color primaryLightPastel = Color(0xFFEDE9FE); // violet-100

  static const Color textPrimaryPastel =
      Color(0xFF1E0A4C); // violet oscuro legible
  static const Color textSecondaryPastel = Color(0xFF5B21B6); // violet-800
  static const Color textDisabledPastel = Color(0xFFC4B5FD); // violet-300

  static const Color borderPastel = Color(0xFFC4B5FD); // violet-300
  static const Color dividerPastel = Color(0xFFDDD6FE); // violet-200

  static const Color aroundLightPastel = Color(0xFFDBEAFE);
  static const Color angelsLightPastel = Color(0xFFEDE9FE);
  static const Color particularesLightPastel = Color(0xFFDCFCE7);

  static const Color cobroPendienteLightPastel = Color(0xFFFEF9C3);
  static const Color cobroCobradoLightPastel = Color(0xFFDCFCE7);
  static const Color cobroParcialLightPastel = Color(0xFFE0F2FE);

  /// Devuelve el color principal asociado a un tipo de fuente.
  static Color forFuenteTipo(String tipo) {
    switch (tipo) {
      case 'empleo':
        return around;
      case 'academia':
        return angels;
      case 'particular':
        return particulares;
      default:
        return primary;
    }
  }

  /// Devuelve el color de fondo (light) asociado a un tipo de fuente.
  static Color lightForFuenteTipo(String tipo) {
    switch (tipo) {
      case 'empleo':
        return aroundLight;
      case 'academia':
        return angelsLight;
      case 'particular':
        return particularesLight;
      default:
        return primaryLight;
    }
  }

  /// Devuelve el color según el estado del cobro.
  static Color forEstadoCobro(String estado) {
    switch (estado) {
      case 'cobrado':
        return cobroCobrado;
      case 'parcial':
        return cobroParcial;
      case 'pendiente':
      default:
        return cobroPendiente;
    }
  }

  /// Devuelve el color de fondo adaptativo (light/dark) según fuente.
  static Color lightForFuenteTipoAdaptive(String tipo, bool isDark) {
    if (isDark) {
      switch (tipo) {
        case 'empleo':
          return aroundLightDark;
        case 'academia':
          return angelsLightDark;
        case 'particular':
          return particularesLightDark;
        default:
          return primaryLightDark;
      }
    }
    return lightForFuenteTipo(tipo);
  }

  /// Devuelve el color de fondo de badge adaptativo según estado de cobro.
  static Color lightForEstadoCobroAdaptive(String estado, bool isDark) {
    if (isDark) {
      switch (estado) {
        case 'cobrado':
          return cobroCobradoLightDark;
        case 'parcial':
          return cobroParcialLightDark;
        default:
          return cobroPendienteLightDark;
      }
    }
    switch (estado) {
      case 'cobrado':
        return cobroCobradoLight;
      case 'parcial':
        return cobroParcialLight;
      default:
        return cobroPendienteLight;
    }
  }
}
