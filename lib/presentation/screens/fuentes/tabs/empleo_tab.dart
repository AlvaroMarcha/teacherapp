import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../providers/fuentes_provider.dart';
import '../../../../domain/models/fuente.dart';
import '../../../providers/theme_provider.dart';

/// Tab de empleo fijo (Around): muestra salario base + horas + tarifa extra.
class EmpleoTab extends ConsumerWidget {
  const EmpleoTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fuentesAsync = ref.watch(fuentesProvider);
    final l = ref.watch(appLocalizationsProvider);

    return fuentesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (fuentes) {
        final empleo = fuentes.where((f) => f.tipo.value == 'empleo').toList();
        if (empleo.isEmpty) {
          return Center(
            child: Text(l.noEmpleoConfigurada),
          );
        }
        final fuente = empleo.first;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionHeader(title: fuente.nombre, color: AppColors.around),
            const SizedBox(height: 12),
            Consumer(
              builder: (context, ref, _) {
                final configAsync = ref.watch(empleoConfigProvider(fuente.id));
                return configAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                  data: (config) {
                    if (config == null) {
                      return Text(l.sinConfiguracionEmpleo);
                    }
                    return Column(
                      children: [
                        _InfoTile(
                          icon: Icons.euro_rounded,
                          label: l.salarioBase,
                          value: CurrencyUtils.formatCompact(
                            config.salarioBase,
                          ),
                          color: AppColors.around,
                        ),
                        _InfoTile(
                          icon: Icons.access_time_rounded,
                          label: l.horasSemanalesContratadas,
                          value: '${config.horasSemanales.toStringAsFixed(0)}h',
                          color: AppColors.around,
                        ),
                        _InfoTile(
                          icon: Icons.add_circle_outline_rounded,
                          label: l.tarifaHoraExtra,
                          value:
                              '${CurrencyUtils.formatCompact(config.tarifaHoraExtra)}/h',
                          color: AppColors.around,
                        ),
                        _InfoTile(
                          icon: Icons.calendar_today_rounded,
                          label: l.diaCobro,
                          value: '${l.dia} ${config.diaCobro} ${l.deCadaMes}',
                          color: AppColors.around,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.titleMedium),
      ],
    );
  }
}

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
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: AppTextStyles.bodySmall),
        trailing: Text(value, style: AppTextStyles.amountSmall),
      ),
    );
  }
}
