import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../providers/sesiones_provider.dart';
import '../../providers/fuentes_provider.dart';
import '../../providers/database_provider.dart';
import '../../../domain/models/sesion_recurrente.dart';
import '../../../domain/models/fuente.dart';
import 'dart:convert';

class HorarioScreen extends ConsumerStatefulWidget {
  const HorarioScreen({super.key});

  @override
  ConsumerState<HorarioScreen> createState() => _HorarioScreenState();
}

class _HorarioScreenState extends ConsumerState<HorarioScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  Widget build(BuildContext context) {
    final sesionesAsync = ref.watch(sesionesRecurrentesProvider);
    final fuentesAsync = ref.watch(fuentesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Horario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => setState(() {
              _focusedDay = DateTime.now();
              _selectedDay = DateTime.now();
            }),
            tooltip: 'Hoy',
          ),
        ],
      ),
      body: Column(
        children: [
          fuentesAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (fuentes) => sesionesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox(),
              data: (sesiones) => TableCalendar(
                firstDay: DateTime.utc(2025, 1, 1),
                lastDay: DateTime.utc(2027, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                onFormatChanged: (f) => setState(() => _calendarFormat = f),
                onDaySelected: (selected, focused) => setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                }),
                eventLoader: (day) => _getEventosDelDia(day, sesiones),
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
                  markerDecoration: const BoxDecoration(
                    color: AppColors.sesionRecurrente,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonTextStyle: AppTextStyles.labelMedium,
                  titleTextStyle: AppTextStyles.titleSmall,
                  formatButtonDecoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                locale: 'es_ES',
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: sesionesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (sesiones) => fuentesAsync.when(
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
                data: (fuentes) => _SesionesDelDia(
                  dia: _selectedDay,
                  sesiones: sesiones,
                  fuentes: fuentes,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<SesionRecurrente> _getEventosDelDia(
    DateTime day,
    List<SesionRecurrente> sesiones,
  ) {
    final weekday = day.weekday;
    return sesiones.where((s) => s.diasSemana.contains(weekday)).toList();
  }
}

class _SesionesDelDia extends StatelessWidget {
  const _SesionesDelDia({
    required this.dia,
    required this.sesiones,
    required this.fuentes,
  });

  final DateTime dia;
  final List<SesionRecurrente> sesiones;
  final List<Fuente> fuentes;

  @override
  Widget build(BuildContext context) {
    final weekday = dia.weekday;
    final sesionesDelDia = sesiones
        .where((s) => s.diasSemana.contains(weekday))
        .toList()
      ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));

    if (sesionesDelDia.isEmpty) {
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
              'Sin clases este día',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sesionesDelDia.length,
      itemBuilder: (context, i) {
        final sesion = sesionesDelDia[i];
        final fuente = fuentes.firstWhere(
          (f) => f.id == sesion.fuenteId,
          orElse: () => fuentes.first,
        );
        final color = AppColors.forFuenteTipo(fuente.tipo.value);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            title: Text(
              '${sesion.horaInicio} – ${sesion.horaFin}',
              style: AppTextStyles.titleSmall,
            ),
            subtitle: Text(fuente.nombre, style: AppTextStyles.bodySmall),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.lightForFuenteTipo(fuente.tipo.value),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                fuente.nombre,
                style: AppTextStyles.labelSmall.copyWith(color: color),
              ),
            ),
          ),
        );
      },
    );
  }
}
