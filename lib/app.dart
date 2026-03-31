import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/theme_provider.dart';

class TeacherApp extends ConsumerWidget {
  const TeacherApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeMode = ref.watch(themeModeProvider);
    final appLocale = ref.watch(localeProvider);

    final flutterThemeMode = switch (appThemeMode) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
    };

    // Tema claro = pastel acentuado
    final lightTheme = AppTheme.pastel;

    return MaterialApp.router(
      title: "Laura's Language",
      theme: lightTheme,
      darkTheme: AppTheme.dark,
      themeMode: flutterThemeMode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      locale: appLocale.locale,
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
        Locale('it', 'IT'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
