import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/fuentes/fuentes_screen.dart';
import '../../presentation/screens/fuentes/fuente_form_screen.dart';
import '../../presentation/screens/horario/horario_screen.dart';
import '../../presentation/screens/alumnos/alumnos_list_screen.dart';
import '../../presentation/screens/alumnos/alumno_detalle_screen.dart';
import '../../presentation/screens/alumnos/alumno_form_screen.dart';
import '../../presentation/screens/cobros/cobros_screen.dart';
import '../../presentation/screens/cobros/cobro_detalle_screen.dart';
import '../../presentation/screens/sesiones/registro_sesion_screen.dart';
import '../../presentation/screens/sesiones/sesion_form_screen.dart';
import '../../presentation/screens/horas_extra/horas_extra_screen.dart';
import '../../presentation/screens/ajustes/ajustes_screen.dart';
import '../../presentation/screens/ajustes/tarifas_screen.dart';
import '../../presentation/screens/ajustes/perfil_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';

/// Notifier de autenticación — GoRouter escucha cambios para redirigir.
final authNotifier = ValueNotifier<bool>(false);

/// Rutas nombradas de la aplicación.
abstract class AppRoutes {
  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/';
  static const String fuentes = '/fuentes';
  static const String fuenteForm = '/fuentes/form';
  static const String horario = '/horario';
  static const String alumnos = '/alumnos';
  static const String alumnoDetalle = '/alumnos/:id';
  static const String alumnoForm = '/alumnos/form';
  static const String cobros = '/cobros';
  static const String cobroDetalle = '/cobros/:id';
  static const String registroSesion = '/sesiones/registro';
  static const String sesionForm = '/sesiones/form';
  static const String horasExtra = '/horas-extra';
  static const String ajustes = '/ajustes';
  static const String tarifas = '/ajustes/tarifas';
  static const String perfil = '/ajustes/perfil';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  refreshListenable: authNotifier,
  redirect: (context, state) {
    final loggedIn = authNotifier.value;
    final isLoginRoute = state.matchedLocation == AppRoutes.login;
    if (!loggedIn && !isLoginRoute) return AppRoutes.login;
    if (loggedIn && isLoginRoute) return AppRoutes.dashboard;
    return null;
  },
  routes: [
    // ── Login (fuera del shell) ────────────────────────────────────
    GoRoute(
      path: AppRoutes.login,
      builder: (_, __) => const LoginScreen(),
    ),

    // ── Onboarding (fuera del shell) ─────────────────────────────
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (_, __) => const OnboardingScreen(),
    ),

    // ── Shell con Bottom Navigation ──────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (_, __) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.fuentes,
              builder: (_, __) => const FuentesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.horario,
              builder: (_, __) => const HorarioScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.alumnos,
              builder: (_, __) => const AlumnosListScreen(),
              routes: [
                GoRoute(
                  path: 'form',
                  builder: (context, state) {
                    final alumnoId = state.uri.queryParameters['id'];
                    return AlumnoFormScreen(alumnoId: alumnoId);
                  },
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) => AlumnoDetalleScreen(
                    alumnoId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.cobros,
              builder: (_, __) => const CobrosScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) =>
                      CobroDetalleScreen(cobroId: state.pathParameters['id']!),
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // ── Rutas fuera del shell ─────────────────────────────────────
    GoRoute(
      path: AppRoutes.fuenteForm,
      builder: (context, state) {
        final id = state.uri.queryParameters['id'];
        return FuenteFormScreen(fuenteId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.registroSesion,
      builder: (_, __) => const RegistroSesionScreen(),
    ),
    GoRoute(
      path: AppRoutes.sesionForm,
      builder: (_, __) => const SesionFormScreen(),
    ),
    GoRoute(
      path: AppRoutes.horasExtra,
      builder: (context, state) {
        final fuenteId = state.uri.queryParameters['fuenteId'];
        return HorasExtraScreen(fuenteId: fuenteId);
      },
    ),
    GoRoute(
      path: AppRoutes.ajustes,
      builder: (_, __) => const AjustesScreen(),
      routes: [
        GoRoute(path: 'tarifas', builder: (_, __) => const TarifasScreen()),
        GoRoute(path: 'perfil', builder: (_, __) => const PerfilScreen()),
      ],
    ),
  ],
);

/// Shell widget que envuelve las tabs con NavigationBar.
class _AppShell extends StatelessWidget {
  const _AppShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Fuentes',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Horario',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Alumnos',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Cobros',
          ),
        ],
      ),
    );
  }
}
