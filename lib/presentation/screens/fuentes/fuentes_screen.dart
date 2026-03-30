import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../domain/models/fuente.dart';
import '../../providers/alumnos_provider.dart';
import '../../providers/fuentes_provider.dart';

class FuentesScreen extends ConsumerStatefulWidget {
  const FuentesScreen({super.key});

  @override
  ConsumerState<FuentesScreen> createState() => _FuentesScreenState();
}

class _FuentesScreenState extends ConsumerState<FuentesScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  List<Fuente> _fuentes = [];

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _updateTabController(List<Fuente> fuentes) {
    if (fuentes.length == _fuentes.length &&
        fuentes.map((f) => f.id).join() == _fuentes.map((f) => f.id).join()) {
      return;
    }

    final prevIndex = _tabController?.index ?? 0;
    _tabController?.dispose();

    _fuentes = fuentes;
    if (fuentes.isEmpty) {
      _tabController = null;
    } else {
      _tabController = TabController(
        length: fuentes.length,
        vsync: this,
        initialIndex: prevIndex.clamp(0, fuentes.length - 1),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fuentesAsync = ref.watch(fuentesProvider);

    return fuentesAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text(AppStrings.fuentesTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text(AppStrings.fuentesTitle)),
        body: Center(child: Text('Error: $e')),
      ),
      data: (fuentes) {
        _updateTabController(fuentes);

        if (fuentes.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text(AppStrings.fuentesTitle)),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sin fuentes de ingreso',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea una para empezar',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => context.push(AppRoutes.fuenteForm),
              child: const Icon(Icons.add),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.fuentesTitle),
            actions: [
              ListenableBuilder(
                listenable: _tabController!,
                builder: (ctx, _) {
                  final idx = _tabController!.index;
                  return IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Editar fuente',
                    onPressed: () {
                      final id = fuentes[idx].id;
                      context.push('${AppRoutes.fuenteForm}?id=$id');
                    },
                  );
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: fuentes.length > 3,
              labelStyle: AppTextStyles.labelLarge,
              unselectedLabelStyle: AppTextStyles.labelMedium,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor:
                  Theme.of(context).colorScheme.onSurfaceVariant,
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: fuentes.map((f) {
                final color = f.flutterColor;
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(f.nombre),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: fuentes.map((f) => _FuenteTabContent(fuente: f)).toList(),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push(AppRoutes.fuenteForm),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

// ── Contenido de cada tab ────────────────────────────────────────────────────

class _FuenteTabContent extends ConsumerWidget {
  const _FuenteTabContent({required this.fuente});

  final Fuente fuente;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (fuente.tipo == FuenteTipo.empleo) {
      return _EmpleoContent(fuente: fuente);
    }
    return _AlumnosContent(fuente: fuente);
  }
}

// ─── Empleo ──────────────────────────────────────────────────────────────────

class _EmpleoContent extends ConsumerWidget {
  const _EmpleoContent({required this.fuente});

  final Fuente fuente;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(empleoConfigProvider(fuente.id));
    return configAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (config) {
        if (config == null) {
          return const Center(child: Text('Sin configuración de empleo'));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _InfoTile(
              icon: Icons.euro_rounded,
              label: 'Salario base',
              value: CurrencyUtils.formatCompact(config.salarioBase),
              color: fuente.flutterColor,
            ),
            _InfoTile(
              icon: Icons.access_time_rounded,
              label: 'Horas/semana contratadas',
              value: '${config.horasSemanales.toStringAsFixed(0)}h',
              color: fuente.flutterColor,
            ),
            _InfoTile(
              icon: Icons.add_circle_outline_rounded,
              label: 'Tarifa hora extra',
              value: '${CurrencyUtils.formatCompact(config.tarifaHoraExtra)}/h',
              color: fuente.flutterColor,
            ),
            _InfoTile(
              icon: Icons.calendar_today_rounded,
              label: 'Día de cobro',
              value: 'Día ${config.diaCobro} de cada mes',
              color: fuente.flutterColor,
            ),
          ],
        );
      },
    );
  }
}

// ─── Alumnos (academia / particular) ─────────────────────────────────────────

class _AlumnosContent extends ConsumerWidget {
  const _AlumnosContent({required this.fuente});

  final Fuente fuente;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alumnosAsync = ref.watch(alumnosByFuenteProvider(fuente.id));
    return alumnosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (alumnos) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Spacer(),
              TextButton.icon(
                onPressed: () => context.push(
                  '${AppRoutes.alumnos}/form?fuenteId=${fuente.id}',
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Añadir alumno'),
              ),
            ],
          ),
          if (alumnos.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sin alumnos en esta fuente',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
          else
            ...alumnos.map(
              (a) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        fuente.flutterColor.withValues(alpha: 0.15),
                    child: Text(
                      a.nombre.substring(0, 1).toUpperCase(),
                      style: TextStyle(color: fuente.flutterColor),
                    ),
                  ),
                  title: Text(a.nombre),
                  subtitle: Text(
                    '${CurrencyUtils.formatCompact(a.tarifaSesion)}/sesión · ${a.duracionMinutos} min',
                    style: AppTextStyles.bodySmall,
                  ),
                  trailing: Text(
                    CurrencyUtils.formatCompact(a.tarifaSesion),
                    style: AppTextStyles.amountSmall.copyWith(
                      color: fuente.flutterColor,
                    ),
                  ),
                  onTap: () => context.push('/alumnos/${a.id}'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── InfoTile ─────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: AppTextStyles.bodySmall),
        trailing: Text(
          value,
          style: AppTextStyles.amountMedium.copyWith(color: color),
        ),
      ),
    );
  }
}
