import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../domain/models/evento_calendario.dart';
import '../../../providers/sesiones_provider.dart';
import '../../../providers/theme_provider.dart';

class ClasesHoyCard extends ConsumerWidget {
  const ClasesHoyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(appLocalizationsProvider);
    final hoy = DateUtils.dateOnly(DateTime.now());
    final eventosAsync = ref.watch(eventosDelDiaProvider(hoy));

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go(AppRoutes.horario),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.today,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(l.clasesDeHoy, style: AppTextStyles.titleSmall),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              eventosAsync.when(
                loading: () => const SizedBox(
                  height: 32,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (eventos) {
                  if (eventos.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        l.sinClasesEsteDia,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: eventos.map((e) => _ClaseRow(evento: e)).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClaseRow extends StatelessWidget {
  const _ClaseRow({required this.evento});

  final EventoCalendario evento;

  @override
  Widget build(BuildContext context) {
    final color = evento.color;
    final opacity = evento.esCancelada ? 0.5 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${evento.horaInicio}–${evento.horaFin}',
              style: AppTextStyles.labelMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                evento.titulo,
                style: AppTextStyles.bodyMedium.copyWith(
                  decoration:
                      evento.esCancelada ? TextDecoration.lineThrough : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (evento.esCancelada)
              Icon(Icons.cancel_outlined, size: 16, color: color)
            else if (evento.estaConfirmada)
              Icon(Icons.check_circle_outline, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}
