import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/theme_provider.dart';

/// Tarjeta principal del dashboard: muestra ingresos y pendientes del mes.
class ResumenMesCard extends ConsumerWidget {
  const ResumenMesCard({super.key, required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(appLocalizationsProvider);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.ingresosMes, style: AppTextStyles.labelMedium),
            const SizedBox(height: 4),
            Text(
              CurrencyUtils.formatCompact(data.totalIngresadoMes),
              style: AppTextStyles.amountLarge.copyWith(
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatItem(
                  label: l.pendiente,
                  value: CurrencyUtils.formatCompact(data.totalPendienteMes),
                  color: AppColors.cobroPendiente,
                ),
                const SizedBox(width: 24),
                _StatItem(
                  label: l.horas,
                  value: '${data.totalHorasMes.toStringAsFixed(0)}h',
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        Text(value, style: AppTextStyles.amountSmall.copyWith(color: color)),
      ],
    );
  }
}
