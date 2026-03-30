import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';

class HorasSemanaCard extends StatelessWidget {
  const HorasSemanaCard({super.key, required this.totalHoras});

  final double totalHoras;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.aroundLightDark
                : AppColors.aroundLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.access_time_outlined,
            color: AppColors.around,
          ),
        ),
        title: const Text(
          'Horas extra (Around)',
          style: AppTextStyles.titleSmall,
        ),
        subtitle: Text(
          '${totalHoras.toStringAsFixed(0)}h registradas este mes',
          style: AppTextStyles.bodySmall,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: () => context.push(AppRoutes.horasExtra),
      ),
    );
  }
}
