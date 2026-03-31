import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../providers/sesiones_provider.dart';
import '../../../providers/theme_provider.dart';

/// Vista anual: mapa de calor de densidad de sesiones (estilo GitHub contributions).
///
/// Muestra 52–53 semanas × 7 días. El color de cada celda refleja
/// cuántas sesiones/horas se han registrado ese día.
class AnioHeatmap extends ConsumerWidget {
  const AnioHeatmap({
    super.key,
    required this.anio,
  });

  final int anio;

  static const double _cellSize = 11.0;
  static const double _cellSpacing = 2.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurrentesAsync = ref.watch(sesionesRecurrentesProvider);
    final recurrentes = recurrentesAsync.valueOrNull ?? [];
    final l = ref.watch(appLocalizationsProvider);

    // Construir mapa día → número de sesiones recurrentes esperadas
    final Map<String, int> densidad = {};
    final inicio = DateTime(anio, 1, 1);
    final fin = DateTime(anio, 12, 31);

    for (var d = inicio; !d.isAfter(fin); d = d.add(const Duration(days: 1))) {
      final weekday = d.weekday;
      final fechaIso = AppDateUtils.formatIso(d);
      int count = 0;
      for (final s in recurrentes) {
        if (s.esPuntual) {
          if (s.fechaInicio == fechaIso) count++;
        } else {
          if (s.diasSemana.contains(weekday)) count++;
        }
      }
      if (count > 0) densidad[fechaIso] = count;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '${l.actividad} $anio',
            style: AppTextStyles.titleSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: _Legend(),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: _HeatmapGrid(
            anio: anio,
            densidad: densidad,
            cellSize: _cellSize,
            spacing: _cellSpacing,
          ),
        ),
      ],
    );
  }
}

class _HeatmapGrid extends ConsumerWidget {
  const _HeatmapGrid({
    required this.anio,
    required this.densidad,
    required this.cellSize,
    required this.spacing,
  });

  final int anio;
  final Map<String, int> densidad;
  final double cellSize;
  final double spacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(appLocalizationsProvider);
    final inicio = DateTime(anio, 1, 1);
    final fin = DateTime(anio, 12, 31);
    // Días en la semana del inicio (lunes=0)
    final offsetDias = (inicio.weekday - 1) % 7;

    final diasTotales = fin.difference(inicio).inDays + 1;
    final totalCeldas = offsetDias + diasTotales;
    final numSemanas = (totalCeldas / 7).ceil();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(numSemanas, (semana) {
        return Padding(
          padding: EdgeInsets.only(right: spacing),
          child: Column(
            children: List.generate(7, (diaSemana) {
              final index = semana * 7 + diaSemana;
              if (index < offsetDias) {
                return SizedBox(width: cellSize, height: cellSize + spacing);
              }
              final diaIndex = index - offsetDias;
              if (diaIndex >= diasTotales) {
                return SizedBox(width: cellSize, height: cellSize + spacing);
              }
              final dia = inicio.add(Duration(days: diaIndex));
              final fechaIso = AppDateUtils.formatIso(dia);
              final count = densidad[fechaIso] ?? 0;
              return Padding(
                padding: EdgeInsets.only(bottom: spacing),
                child: Tooltip(
                  message:
                      '${AppDateUtils.formatShortDate(dia)}: $count ${count != 1 ? l.sesiones : l.sesion}',
                  child: Container(
                    width: cellSize,
                    height: cellSize,
                    decoration: BoxDecoration(
                      color: _colorForCount(count),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Color _colorForCount(int count) {
    if (count == 0) return AppColors.border;
    if (count == 1) return AppColors.primary.withOpacity(0.25);
    if (count == 2) return AppColors.primary.withOpacity(0.50);
    if (count == 3) return AppColors.primary.withOpacity(0.75);
    return AppColors.primary;
  }
}

class _Legend extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(appLocalizationsProvider);
    return Row(
      children: [
        Text(l.menos, style: AppTextStyles.caption),
        const SizedBox(width: 4),
        ...[0, 1, 2, 3, 4].map((count) {
          final color = count == 0
              ? AppColors.border
              : AppColors.primary.withOpacity(0.25 * count);
          return Container(
            width: 11,
            height: 11,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
        const SizedBox(width: 4),
        Text(l.mas, style: AppTextStyles.caption),
      ],
    );
  }
}
