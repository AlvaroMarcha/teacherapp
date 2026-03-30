import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../domain/models/evento_calendario.dart';
import '../../../providers/sesiones_provider.dart';
import 'evento_bloque.dart';

/// Vista semanal tipo Google Calendar con timeline proporcional.
///
/// - Eje Y: horas del día (07:00–22:00), 60dp por hora.
/// - Eje X: 7 columnas (un día de la semana cada una).
/// - Los bloques se posicionan con [Stack] + [Positioned].
class SemanaTimeline extends ConsumerWidget {
  const SemanaTimeline({
    super.key,
    required this.semanaInicio,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onEventoTap,
  });

  /// Lunes de la semana a mostrar.
  final DateTime semanaInicio;
  final DateTime selectedDay;
  final void Function(DateTime) onDaySelected;
  final void Function(EventoCalendario) onEventoTap;

  static const double _hourHeight = 60.0; // dp por hora
  static const int _startHour = 7; // hora mínima visible (07:00)
  static const int _endHour = 22; // hora máxima visible (22:00)
  static const double _timeAxisWidth = 42.0;
  static const double _topPadding = 8.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dias = List.generate(7, (i) => semanaInicio.add(Duration(days: i)));
    final totalHeight = (_endHour - _startHour) * _hourHeight;

    return Column(
      children: [
        // ── Header de días ──────────────────────────────────────────
        _WeekHeader(
          dias: dias,
          selectedDay: selectedDay,
          onDaySelected: onDaySelected,
          timeAxisWidth: _timeAxisWidth,
        ),
        const Divider(height: 1),
        // ── Timeline ────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            child: SizedBox(
              height: totalHeight + _topPadding + 16,
              child: Stack(
                children: [
                  // ── Grid de fondo (líneas horizontales + verticales) ──
                  Positioned(
                    top: _topPadding,
                    bottom: 0,
                    left: _timeAxisWidth,
                    right: 0,
                    child: _GridBackground(
                      startHour: _startHour,
                      endHour: _endHour,
                      hourHeight: _hourHeight,
                      dayCount: 7,
                    ),
                  ),
                  // ── Eje de horas + columnas de eventos ──
                  Positioned.fill(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: _timeAxisWidth,
                          child: _TimeAxis(
                            startHour: _startHour,
                            endHour: _endHour,
                            hourHeight: _hourHeight,
                            topPadding: _topPadding,
                          ),
                        ),
                        ...dias.map((dia) => Expanded(
                              child: _DayColumn(
                                dia: dia,
                                startHour: _startHour,
                                hourHeight: _hourHeight,
                                topPadding: _topPadding,
                                onEventoTap: onEventoTap,
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({
    required this.dias,
    required this.selectedDay,
    required this.onDaySelected,
    required this.timeAxisWidth,
  });

  final List<DateTime> dias;
  final DateTime selectedDay;
  final void Function(DateTime) onDaySelected;
  final double timeAxisWidth;

  static const _dayNames = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Row(
      children: [
        SizedBox(width: timeAxisWidth),
        ...List.generate(7, (i) {
          final dia = dias[i];
          final isToday = isSameDay(dia, today);
          final isSelected = isSameDay(dia, selectedDay);
          final textColor = isSelected
              ? Colors.white
              : isToday
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface;
          return Expanded(
            child: GestureDetector(
              onTap: () => onDaySelected(dia),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    _dayNames[i],
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : isToday
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${dia.day}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _TimeAxis extends StatelessWidget {
  const _TimeAxis({
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    required this.topPadding,
  });

  final int startHour;
  final int endHour;
  final double hourHeight;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(endHour - startHour, (i) {
        final hour = startHour + i;
        return Positioned(
          top: topPadding + i * hourHeight - 6,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: AppTextStyles.caption.copyWith(fontSize: 10),
              textAlign: TextAlign.right,
            ),
          ),
        );
      }),
    );
  }
}

class _DayColumn extends ConsumerWidget {
  const _DayColumn({
    required this.dia,
    required this.startHour,
    required this.hourHeight,
    required this.topPadding,
    required this.onEventoTap,
  });

  final DateTime dia;
  final int startHour;
  final double hourHeight;
  final double topPadding;
  final void Function(EventoCalendario) onEventoTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventosAsync = ref.watch(eventosDelDiaProvider(dia));
    final eventos = eventosAsync.valueOrNull ?? [];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Hijo de tamaño para que el Stack no colapse a 0
        const SizedBox.expand(),
        // Bloques de eventos
        ...eventos.map((evento) {
          final topHours = evento.horaInicioDecimal - startHour;
          final top = topPadding + topHours * hourHeight;
          final height =
              (evento.duracionHoras * hourHeight).clamp(24.0, double.infinity);
          if (topHours < 0) return const SizedBox.shrink();

          return Positioned(
            top: top,
            left: 2,
            right: 2,
            height: height,
            child: EventoBloque(
              evento: evento,
              onTap: () => onEventoTap(evento),
              compact: true,
            ),
          );
        }),

        // Línea de hora actual
        _CurrentTimeLine(
          startHour: startHour,
          hourHeight: hourHeight,
          topPadding: topPadding,
          dia: dia,
        ),
      ],
    );
  }
}

// ── Grid de fondo con líneas horizontales y verticales ──────────
class _GridBackground extends StatelessWidget {
  const _GridBackground({
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    required this.dayCount,
  });

  final int startHour;
  final int endHour;
  final double hourHeight;
  final int dayCount;

  @override
  Widget build(BuildContext context) {
    final lineColor =
        Theme.of(context).colorScheme.outlineVariant.withOpacity(0.35);
    final hourCount = endHour - startHour;

    return LayoutBuilder(
      builder: (context, constraints) {
        final colWidth = constraints.maxWidth / dayCount;
        return Stack(
          children: [
            // Líneas horizontales (horas)
            ...List.generate(
              hourCount,
              (i) => Positioned(
                top: i * hourHeight,
                left: 0,
                right: 0,
                child: Container(height: 0.5, color: lineColor),
              ),
            ),
            // Líneas verticales (columnas)
            ...List.generate(
              dayCount,
              (i) => Positioned(
                top: 0,
                bottom: 0,
                left: i * colWidth,
                child: Container(width: 0.5, color: lineColor),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CurrentTimeLine extends StatelessWidget {
  const _CurrentTimeLine({
    required this.startHour,
    required this.hourHeight,
    required this.topPadding,
    required this.dia,
  });

  final int startHour;
  final double hourHeight;
  final double topPadding;
  final DateTime dia;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday =
        now.year == dia.year && now.month == dia.month && now.day == dia.day;
    if (!isToday) return const SizedBox.shrink();

    final topHours = now.hour + now.minute / 60.0 - startHour;
    if (topHours < 0) return const SizedBox.shrink();

    return Positioned(
      top: topPadding + topHours * hourHeight,
      left: 0,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Divider(
              height: 1,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
