import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.background,

        // ── AppBar ───────────────────────────────────────────────
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 1,
          shadowColor: AppColors.border,
          titleTextStyle:
              AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),

        // ── Bottom Navigation ────────────────────────────────────
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primaryLight,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              );
            }
            return AppTextStyles.labelMedium;
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primary, size: 24);
            }
            return const IconThemeData(
                color: AppColors.textSecondary, size: 24);
          }),
          elevation: 8,
          shadowColor: AppColors.border,
          surfaceTintColor: Colors.transparent,
        ),

        // ── Card ─────────────────────────────────────────────────
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),

        // ── InputDecoration ──────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariant,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textDisabled,
          ),
        ),

        // ── ElevatedButton ───────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: AppTextStyles.labelLarge,
          ),
        ),

        // ── TextButton ───────────────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.labelLarge,
          ),
        ),

        // ── OutlinedButton ───────────────────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: AppTextStyles.labelLarge,
          ),
        ),

        // ── Chip ─────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceVariant,
          selectedColor: AppColors.primaryLight,
          labelStyle: AppTextStyles.labelMedium,
          side: const BorderSide(color: AppColors.border),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),

        // ── Divider ──────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),

        // ── SnackBar ─────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1C1C1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          contentTextStyle:
              AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),

        // ── ListTile ─────────────────────────────────────────────
        listTileTheme: const ListTileThemeData(
          tileColor: AppColors.surface,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),

        // ── FloatingActionButton ─────────────────────────────────
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
        ),

        // ── Text ─────────────────────────────────────────────────
        textTheme: TextTheme(
          displayLarge:
              AppTextStyles.display.copyWith(color: AppColors.textPrimary),
          titleLarge:
              AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary),
          titleMedium:
              AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
          titleSmall:
              AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimary),
          bodyLarge:
              AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
          bodyMedium:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          bodySmall:
              AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          labelLarge:
              AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
          labelMedium: AppTextStyles.labelMedium
              .copyWith(color: AppColors.textSecondary),
          labelSmall:
              AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
        ),
      );

  // ── Dark theme ───────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          surface: AppColors.surfaceDark,
          onSurface: AppColors.textPrimaryDark,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,

        // ── AppBar ───────────────────────────────────────────────
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: AppColors.textPrimaryDark,
          elevation: 0,
          scrolledUnderElevation: 1,
          shadowColor: AppColors.borderDark,
          titleTextStyle: AppTextStyles.titleMedium
              .copyWith(color: AppColors.textPrimaryDark),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),

        // ── Bottom Navigation ────────────────────────────────────
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          indicatorColor: AppColors.primary,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTextStyles.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              );
            }
            return AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondaryDark,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.white, size: 24);
            }
            return const IconThemeData(
                color: AppColors.textSecondaryDark, size: 24);
          }),
          elevation: 8,
          shadowColor: AppColors.borderDark,
          surfaceTintColor: Colors.transparent,
        ),

        // ── Card ─────────────────────────────────────────────────
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.surfaceDark,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.borderDark, width: 1),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),

        // ── InputDecoration ──────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariantDark,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.borderDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.borderDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondaryDark,
          ),
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textDisabledDark,
          ),
        ),

        // ── ElevatedButton ───────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: AppTextStyles.labelLarge,
          ),
        ),

        // ── TextButton ───────────────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.labelLarge,
          ),
        ),

        // ── OutlinedButton ───────────────────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: AppTextStyles.labelLarge,
          ),
        ),

        // ── Chip ─────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceVariantDark,
          selectedColor: AppColors.primaryLightDark,
          labelStyle: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimaryDark,
          ),
          side: const BorderSide(color: AppColors.borderDark),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),

        // ── Divider ──────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.dividerDark,
          thickness: 1,
          space: 1,
        ),

        // ── SnackBar ─────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2C2C2E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          contentTextStyle:
              AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),

        // ── ListTile ─────────────────────────────────────────────
        listTileTheme: const ListTileThemeData(
          tileColor: AppColors.surfaceDark,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),

        // ── FloatingActionButton ─────────────────────────────────
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
        ),

        // ── Text ─────────────────────────────────────────────────
        textTheme: TextTheme(
          displayLarge:
              AppTextStyles.display.copyWith(color: AppColors.textPrimaryDark),
          titleLarge: AppTextStyles.titleLarge
              .copyWith(color: AppColors.textPrimaryDark),
          titleMedium: AppTextStyles.titleMedium
              .copyWith(color: AppColors.textPrimaryDark),
          titleSmall: AppTextStyles.titleSmall
              .copyWith(color: AppColors.textPrimaryDark),
          bodyLarge: AppTextStyles.bodyLarge
              .copyWith(color: AppColors.textPrimaryDark),
          bodyMedium: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textPrimaryDark),
          bodySmall: AppTextStyles.bodySmall
              .copyWith(color: AppColors.textSecondaryDark),
          labelLarge: AppTextStyles.labelLarge
              .copyWith(color: AppColors.textPrimaryDark),
          labelMedium: AppTextStyles.labelMedium
              .copyWith(color: AppColors.textSecondaryDark),
          labelSmall: AppTextStyles.labelSmall
              .copyWith(color: AppColors.textSecondaryDark),
        ),
      );

  // ── Pastel theme ─────────────────────────────────────────────────
  static ThemeData get pastel => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryPastel,
          brightness: Brightness.light,
          surface: AppColors.surfacePastel,
          onSurface: AppColors.textPrimaryPastel,
        ),
        scaffoldBackgroundColor: AppColors.backgroundPastel,

        // ── AppBar ───────────────────────────────────────────────
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surfacePastel,
          foregroundColor: AppColors.textPrimaryPastel,
          elevation: 0,
          scrolledUnderElevation: 1,
          shadowColor: AppColors.borderPastel,
          titleTextStyle: AppTextStyles.titleMedium
              .copyWith(color: AppColors.textPrimaryPastel),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),

        // ── Bottom Navigation ────────────────────────────────────
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surfacePastel,
          indicatorColor: AppColors.primaryLightPastel,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTextStyles.labelMedium.copyWith(
                color: AppColors.primaryPastel,
                fontWeight: FontWeight.w600,
              );
            }
            return AppTextStyles.labelMedium
                .copyWith(color: AppColors.textSecondaryPastel);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: AppColors.primaryPastel, size: 24);
            }
            return IconThemeData(
                color: AppColors.textSecondaryPastel, size: 24);
          }),
          elevation: 8,
          shadowColor: AppColors.borderPastel,
          surfaceTintColor: Colors.transparent,
        ),

        // ── Card ─────────────────────────────────────────────────
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.surfacePastel,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.borderPastel, width: 1),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),

        // ── InputDecoration ──────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariantPastel,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.borderPastel),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.borderPastel),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.primaryPastel, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          labelStyle: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondaryPastel),
          hintStyle: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textDisabledPastel),
        ),

        // ── ElevatedButton ───────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPastel,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: AppTextStyles.labelLarge,
          ),
        ),

        // ── TextButton ───────────────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryPastel,
            textStyle: AppTextStyles.labelLarge,
          ),
        ),

        // ── OutlinedButton ───────────────────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryPastel,
            side: const BorderSide(color: AppColors.primaryPastel),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: AppTextStyles.labelLarge,
          ),
        ),

        // ── Chip ─────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceVariantPastel,
          selectedColor: AppColors.primaryLightPastel,
          labelStyle: AppTextStyles.labelMedium
              .copyWith(color: AppColors.textPrimaryPastel),
          side: const BorderSide(color: AppColors.borderPastel),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),

        // ── Divider ──────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.dividerPastel,
          thickness: 1,
          space: 1,
        ),

        // ── SnackBar ─────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1C1C1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          contentTextStyle:
              AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),

        // ── ListTile ─────────────────────────────────────────────
        listTileTheme: const ListTileThemeData(
          tileColor: AppColors.surfacePastel,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),

        // ── FloatingActionButton ─────────────────────────────────
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primaryPastel,
          foregroundColor: Colors.white,
          elevation: 4,
        ),

        // ── Text ─────────────────────────────────────────────────
        textTheme: TextTheme(
          displayLarge: AppTextStyles.display
              .copyWith(color: AppColors.textPrimaryPastel),
          titleLarge: AppTextStyles.titleLarge
              .copyWith(color: AppColors.textPrimaryPastel),
          titleMedium: AppTextStyles.titleMedium
              .copyWith(color: AppColors.textPrimaryPastel),
          titleSmall: AppTextStyles.titleSmall
              .copyWith(color: AppColors.textPrimaryPastel),
          bodyLarge: AppTextStyles.bodyLarge
              .copyWith(color: AppColors.textPrimaryPastel),
          bodyMedium: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textPrimaryPastel),
          bodySmall: AppTextStyles.bodySmall
              .copyWith(color: AppColors.textSecondaryPastel),
          labelLarge: AppTextStyles.labelLarge
              .copyWith(color: AppColors.textPrimaryPastel),
          labelMedium: AppTextStyles.labelMedium
              .copyWith(color: AppColors.textSecondaryPastel),
          labelSmall: AppTextStyles.labelSmall
              .copyWith(color: AppColors.textSecondaryPastel),
        ),
      );
}
