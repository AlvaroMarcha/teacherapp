import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../domain/models/fuente.dart';
import '../../../providers/theme_provider.dart';

class HorasSemanaCard extends ConsumerWidget {
  const HorasSemanaCard({
    super.key,
    required this.fuente,
    required this.horasExtra,
  });

  final Fuente fuente;
  final double horasExtra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(appLocalizationsProvider);
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
          '${l.horasExtra} (${fuente.nombre})',
          style: AppTextStyles.titleSmall,
        ),
        subtitle: Text(
          '${l.esteMesRegistradas}: ${horasExtra.toStringAsFixed(1)}h',
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
