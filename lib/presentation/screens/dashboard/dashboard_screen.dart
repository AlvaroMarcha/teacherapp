import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/currency_utils.dart';
import '../../providers/dashboard_provider.dart';
import '../../../domain/models/fuente.dart';
import 'widgets/resumen_mes_card.dart';
import 'widgets/cobros_pendientes_card.dart';
import 'widgets/horas_semana_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(dashboardProvider);
    final mesActual = DateFormat('MMMM yyyy', 'es_ES').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Inicio'),
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
                  child: Text('Por fuente', style: AppTextStyles.titleSmall),
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
        label: const Text('Registrar sesión'),
      ),
    );
  }
}

class _FuenteResumenTile extends StatelessWidget {
  const _FuenteResumenTile({required this.resumen});

  final FuenteResumen resumen;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forFuenteTipo(resumen.fuente.tipo.value);
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
