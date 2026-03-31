import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../domain/models/evento_calendario.dart';
import '../../../providers/sesiones_provider.dart';
import '../../../providers/theme_provider.dart';
import 'dia_list.dart';

/// Vista de calendario en formato mes con marcadores multicolor por tipo de evento.
class MesCalendar extends ConsumerStatefulWidget {
  const MesCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.onEventoTap,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final void Function(DateTime focusedDay) onPageChanged;
  final void Function(EventoCalendario) onEventoTap;

  @override
  ConsumerState<MesCalendar> createState() => _MesCalendarState();
}

class _MesCalendarState extends ConsumerState<MesCalendar> {
  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final l = ref.watch(appLocalizationsProvider);
    return Column(
      children: [
        TableCalendar<EventoCalendario>(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2027, 12, 31),
          focusedDay: widget.focusedDay,
          selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: {CalendarFormat.month: l.mes},
          onDaySelected: widget.onDaySelected,
          onPageChanged: widget.onPageChanged,
          eventLoader: (day) {
            // marcadores construidos via calendarBuilders
            return [];
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              final eventosAsync = ref.watch(eventosDelDiaProvider(day));
              final eventos = eventosAsync.valueOrNull ?? [];
              if (eventos.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: ColorMarkers(eventos: eventos),
              );
            },
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            todayTextStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
            ),
            markersMaxCount: 0, // usamos calendarBuilders.markerBuilder
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleTextStyle: AppTextStyles.titleSmall,
            leftChevronIcon: const Icon(Icons.chevron_left),
            rightChevronIcon: const Icon(Icons.chevron_right),
          ),
          locale: locale.locale.toString(),
        ),
        const Divider(height: 1),
        Expanded(
          child: DiaList(
            dia: widget.selectedDay,
            onEventoTap: widget.onEventoTap,
          ),
        ),
      ],
    );
  }
}
