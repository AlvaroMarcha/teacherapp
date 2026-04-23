import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/datetime_extension.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/currency_utils.dart';
import '../../providers/cobros_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/horas_extra_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/sesiones_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/frase_diaria_provider.dart';
import '../../providers/fuentes_provider.dart';
import '../../../domain/models/fuente.dart';
import 'widgets/resumen_mes_card.dart';
import 'widgets/cobros_pendientes_card.dart';
import 'widgets/clases_hoy_card.dart';
import 'widgets/horas_semana_card.dart';
import 'widgets/salario_empleo_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(appLocalizationsProvider);
    final locale = ref.watch(localeProvider);
    final dashAsync = ref.watch(dashboardProvider);
    final fraseAsync = ref.watch(fraseDiariaProvider);

    // Programar notificaciones de clase del día
    ref.watch(scheduleNotificationsProvider);

    final mesActual = DateFormat('MMMM yyyy', locale.locale.toString())
        .format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.dashboardTitle),
            Text(
              mesActual,
              style: AppTextStyles.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.ajustes),
          ),
        ],
      ),
      body: dashAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardProvider),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // Frase motivacional del día
              fraseAsync.when(
                data: (frase) => Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.6),
                        Theme.of(context)
                            .colorScheme
                            .secondaryContainer
                            .withOpacity(0.4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.format_quote,
                          size: 20,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          frase,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.85),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,
                          maxLines: null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.format_quote,
                          size: 20,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const ClasesHoyCard(),
              ResumenMesCard(data: data),
              CobrosPendientesCard(
                pendientes: data.cobrosPendientesGlobal,
                totalPendiente: data.totalPendienteGlobal,
              ),
              // Una tarjeta de horas extra por cada fuente de tipo empleo
              ...data.fuentesResumen.values
                  .where((r) => r.fuente.tipo == FuenteTipo.empleo)
                  .map(
                    (r) => HorasSemanaCard(
                      fuente: r.fuente,
                      horasExtra: data.horasExtraMes[r.fuente.id] ?? 0,
                    ),
                  ),
              // Una tarjeta de nómina mensual por cada fuente de tipo empleo
              ...data.fuentesResumen.values
                  .where((r) => r.fuente.tipo == FuenteTipo.empleo)
                  .map((r) => _SalarioEmpleoFuenteCard(fuente: r.fuente)),
              if (data.fuentesResumen.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(l.porFuente, style: AppTextStyles.titleSmall),
                ),
                ...data.fuentesResumen.values.map(
                  (resumen) => _FuenteResumenTile(
                    resumen: resumen,
                    onReset: () => _resetFuente(context, ref, resumen.fuente),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.registroSesion),
        icon: const Icon(Icons.add),
        label: Text(l.registrarSesion),
      ),
    );
  }

  Future<void> _resetFuente(
    BuildContext context,
    WidgetRef ref,
    Fuente fuente,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange,
          size: 36,
        ),
        title: const Text('Limpiar sesiones del mes'),
        content: Text(
          'Se eliminarán TODAS las sesiones recurrentes, sesiones '
          'realizadas y cobros de la fuente "${fuente.nombre}".\n\n'
          'Las sesiones volverán a desaparecer del horario.\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final db = ref.read(databaseProvider);
    final periodoMes = DateTime.now().periodoMes;
    await db.resetSesionesMesByFuente(fuente.id, periodoMes);

    ref.invalidate(dashboardProvider);
    ref.invalidate(cobrosProvider);
    ref.invalidate(cobrosPendientesProvider);
    ref.invalidate(sesionesRealizadasMesProvider);
    ref.invalidate(sesionesRecurrentesProvider);
    ref.invalidate(horasExtraProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Datos del mes limpiados para "${fuente.nombre}"'),
        ),
      );
    }
  }
}

class _FuenteResumenTile extends StatelessWidget {
  const _FuenteResumenTile({
    required this.resumen,
    required this.onReset,
  });

  final FuenteResumen resumen;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final color = resumen.fuente.flutterColor;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(resumen.fuente.nombre, style: AppTextStyles.titleSmall),
                  Text(
                    '${resumen.horas.toStringAsFixed(0)}h · ${CurrencyUtils.formatCompact(resumen.ingresado)} cobrado',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            if (resumen.pendiente > 0)
              Chip(
                label: Text(CurrencyUtils.formatCompact(resumen.pendiente)),
                backgroundColor: AppColors.lightForEstadoCobroAdaptive(
                  'pendiente',
                  Theme.of(context).brightness == Brightness.dark,
                ),
                labelStyle: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.cobroPendiente,
                ),
                side: BorderSide.none,
                padding: EdgeInsets.zero,
              ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onSelected: (value) {
                if (value == 'reset') onReset();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'reset',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep_outlined, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Limpiar mes actual'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget que carga la nómina del mes para una fuente de empleo concreta
/// y renderiza [SalarioEmpleoCard].
class _SalarioEmpleoFuenteCard extends ConsumerWidget {
  const _SalarioEmpleoFuenteCard({required this.fuente});

  final Fuente fuente;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hoy = DateTime.now();
    final configAsync = ref.watch(empleoConfigProvider(fuente.id));
    final nominaAsync = ref.watch(empleoNominaDelMesProvider((
      fuenteId: fuente.id,
      anio: hoy.year,
      mes: hoy.month,
    )));

    final config = configAsync.valueOrNull;
    if (config == null) return const SizedBox.shrink();

    return SalarioEmpleoCard(
      fuente: fuente,
      salarioBase: config.salarioBase,
      nomina: nominaAsync.valueOrNull,
    );
  }
}
