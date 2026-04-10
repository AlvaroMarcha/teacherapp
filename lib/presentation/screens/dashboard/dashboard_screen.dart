import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/currency_utils.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/frase_diaria_provider.dart';
import '../../../domain/models/fuente.dart';
import 'widgets/resumen_mes_card.dart';
import 'widgets/cobros_pendientes_card.dart';
import 'widgets/clases_hoy_card.dart';
import 'widgets/horas_semana_card.dart';

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
                pendientes: data.cobrosPendientes,
                totalPendiente: data.totalPendienteMes,
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
              if (data.fuentesResumen.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(l.porFuente, style: AppTextStyles.titleSmall),
                ),
                ...data.fuentesResumen.values.map(
                  (resumen) => _FuenteResumenTile(resumen: resumen),
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
}

class _FuenteResumenTile extends StatelessWidget {
  const _FuenteResumenTile({required this.resumen});

  final FuenteResumen resumen;

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
          ],
        ),
      ),
    );
  }
}
