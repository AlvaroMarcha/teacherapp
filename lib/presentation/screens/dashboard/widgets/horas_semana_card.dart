import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../domain/models/fuente.dart';

class HorasSemanaCard extends StatelessWidget {
  const HorasSemanaCard({
    super.key,
    required this.fuente,
    required this.horasExtra,
  });

  final Fuente fuente;
  final double horasExtra;

  @override
  Widget build(BuildContext context) {
    final color = fuente.flutterColor;
    final colorLight = color.withValues(alpha: 0.15);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.access_time_outlined, color: color),
        ),
        title: Text(
          'Horas extra (${fuente.nombre})',
          style: AppTextStyles.titleSmall,
        ),
        subtitle: Text(
          '${horasExtra.toStringAsFixed(1)}h registradas este mes',
          style: AppTextStyles.bodySmall,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: () => context.push(
          '${AppRoutes.horasExtra}?fuenteId=${fuente.id}',
        ),
      ),
    );
  }
}
