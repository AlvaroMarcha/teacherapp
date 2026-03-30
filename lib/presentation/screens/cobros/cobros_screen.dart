import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_utils.dart';
import '../../providers/cobros_provider.dart';
import '../../providers/database_provider.dart';
import '../../../domain/models/cobro.dart';

class CobrosScreen extends ConsumerWidget {
  const CobrosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendientesAsync = ref.watch(cobrosPendientesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.cobrosTitle)),
      body: pendientesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (cobros) {
          if (cobros.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '¡Todo cobrado! 🎉',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            );
          }
          final totalPendiente = cobros.fold<double>(
            0,
            (a, c) => a + c.montoPendiente,
          );
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Column(
            children: [
              // Banner total pendiente
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.cobroPendienteLightDark
                      : AppColors.cobroPendienteLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Text(
                  'Total pendiente: ${CurrencyUtils.formatCompact(totalPendiente)}',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.cobroPendiente,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: cobros.length,
                  itemBuilder: (_, i) => _CobroTile(cobro: cobros[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CobroTile extends ConsumerWidget {
  const _CobroTile({required this.cobro});

  final Cobro cobro;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = AppColors.forEstadoCobro(cobro.estado.value);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _marcarCobrado(ref),
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            icon: Icons.check,
            label: 'Cobrado',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightForFuenteTipoAdaptive(
                cobro.fuenteId.contains('around')
                    ? 'empleo'
                    : cobro.fuenteId.contains('angels')
                        ? 'academia'
                        : 'particular',
                isDark,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.receipt_long_outlined, color: color, size: 20),
          ),
          title: Text(
            CurrencyUtils.formatCompact(cobro.monto),
            style: AppTextStyles.amountSmall,
          ),
          subtitle: Text(
            cobro.estado.value.toUpperCase(),
            style: AppTextStyles.caption.copyWith(color: color),
          ),
          trailing: _EstadoBadge(estado: cobro.estado.value),
          onTap: () => context.push('/cobros/${cobro.id}'),
        ),
      ),
    );
  }

  void _marcarCobrado(WidgetRef ref) {
    ref.read(cobroRepositoryProvider).marcarCobrado(cobro.id);
  }
}

class _EstadoBadge extends StatelessWidget {
  const _EstadoBadge({required this.estado});

  final String estado;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forEstadoCobro(estado);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = AppColors.lightForEstadoCobroAdaptive(estado, isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        estado,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}
