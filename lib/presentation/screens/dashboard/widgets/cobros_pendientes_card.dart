import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../providers/theme_provider.dart';

class CobrosPendientesCard extends ConsumerWidget {
  const CobrosPendientesCard({
    super.key,
    required this.pendientes,
    required this.totalPendiente,
  });

  final int pendientes;
  final double totalPendiente;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(appLocalizationsProvider);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: pendientes > 0
                ? AppColors.lightForEstadoCobroAdaptive(
                    'pendiente',
                    Theme.of(context).brightness == Brightness.dark,
                  )
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.receipt_long_outlined,
            color: pendientes > 0
                ? AppColors.cobroPendiente
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(l.cobrosPendientes, style: AppTextStyles.titleSmall),
        subtitle: Text(
          pendientes == 0
              ? l.todoAlDia
              : '$pendientes ${l.cobro}${pendientes != 1 ? 's' : ''} · ${CurrencyUtils.formatCompact(totalPendiente)}',
          style: AppTextStyles.bodySmall,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: () => context.go(AppRoutes.cobros),
      ),
    );
  }
}
