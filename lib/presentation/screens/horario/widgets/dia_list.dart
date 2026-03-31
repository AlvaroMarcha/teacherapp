import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/models/evento_calendario.dart';
import '../../../providers/sesiones_provider.dart';
import '../../../providers/theme_provider.dart';
import 'evento_bloque.dart';

/// Lista cronológica de eventos de un día concreto.
/// Usada en la vista "Día" y en el panel inferior de las otras vistas.
class DiaList extends ConsumerWidget {
  const DiaList({
    super.key,
    required this.dia,
    required this.onEventoTap,
  });

  final DateTime dia;
  final void Function(EventoCalendario evento) onEventoTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventosAsync = ref.watch(eventosDelDiaProvider(dia));
    final l = ref.watch(appLocalizationsProvider);

    return eventosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (eventos) {
        if (eventos.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.event_available,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 8),
                Text(
                  l.sinClasesEsteDia,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppDateUtils.formatFullDate(dia),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Text(
                AppDateUtils.formatFullDate(dia),
                style: AppTextStyles.labelMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: eventos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => EventoBloque(
                  evento: eventos[i],
                  onTap: () => onEventoTap(eventos[i]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Indicador de puntos de colores para marcadores del calendario.
class ColorMarkers extends StatelessWidget {
  const ColorMarkers({super.key, required this.eventos});

  final List<EventoCalendario> eventos;

  @override
  Widget build(BuildContext context) {
    if (eventos.isEmpty) return const SizedBox.shrink();
    final colors = eventos.map((e) => e.color).toSet().take(3).toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: colors.map((c) {
        return Container(
          width: 5,
          height: 5,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        );
      }).toList(),
    );
  }
}
