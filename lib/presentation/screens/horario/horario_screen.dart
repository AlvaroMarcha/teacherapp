import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/models/evento_calendario.dart';
import '../../providers/theme_provider.dart';
import 'widgets/dia_list.dart';
import 'widgets/mes_calendar.dart';
import 'widgets/semana_timeline.dart';
import 'widgets/anio_heatmap.dart';
import 'widgets/registro_sesion_sheet.dart';

enum _VistaCalendario { dia, semana, mes, anio }

class HorarioScreen extends ConsumerStatefulWidget {
  const HorarioScreen({super.key});

  @override
  ConsumerState<HorarioScreen> createState() => _HorarioScreenState();
}

class _HorarioScreenState extends ConsumerState<HorarioScreen> {
  _VistaCalendario _vista = _VistaCalendario.semana;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // ── Navegación ───────────────────────────────────────────────────

  void _irHoy() => setState(() {
        _selectedDay = DateTime.now();
        _focusedDay = DateTime.now();
      });

  void _irAnterior() {
    setState(() {
      switch (_vista) {
        case _VistaCalendario.dia:
          _selectedDay = _selectedDay.subtract(const Duration(days: 1));
          _focusedDay = _selectedDay;
        case _VistaCalendario.semana:
          _selectedDay = _selectedDay.subtract(const Duration(days: 7));
          _focusedDay = _selectedDay;
        case _VistaCalendario.mes:
          _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
        case _VistaCalendario.anio:
          _focusedDay = DateTime(_focusedDay.year - 1, 1, 1);
      }
    });
  }

  void _irSiguiente() {
    setState(() {
      switch (_vista) {
        case _VistaCalendario.dia:
          _selectedDay = _selectedDay.add(const Duration(days: 1));
          _focusedDay = _selectedDay;
        case _VistaCalendario.semana:
          _selectedDay = _selectedDay.add(const Duration(days: 7));
          _focusedDay = _selectedDay;
        case _VistaCalendario.mes:
          _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
        case _VistaCalendario.anio:
          _focusedDay = DateTime(_focusedDay.year + 1, 1, 1);
      }
    });
  }

  String get _tituloActual {
    switch (_vista) {
      case _VistaCalendario.dia:
        return AppDateUtils.formatFullDate(_selectedDay);
      case _VistaCalendario.semana:
        final lunes = _semanaInicio(_selectedDay);
        final domingo = lunes.add(const Duration(days: 6));
        if (lunes.month == domingo.month) {
          return '${lunes.day}–${domingo.day} ${AppDateUtils.formatMonth(lunes)}';
        }
        return '${AppDateUtils.formatShortDate(lunes)} – ${AppDateUtils.formatShortDate(domingo)}';
      case _VistaCalendario.mes:
        return AppDateUtils.formatMonth(_focusedDay);
      case _VistaCalendario.anio:
        return '${_focusedDay.year}';
    }
  }

  DateTime _semanaInicio(DateTime dia) =>
      dia.subtract(Duration(days: dia.weekday - 1));

  void _onEventoTap(EventoCalendario evento, DateTime dia) {
    showRegistroSesionSheet(context, evento, dia);
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(appLocalizationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(_tituloActual, style: AppTextStyles.titleSmall),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.today_outlined),
            onPressed: _irHoy,
            tooltip: l.hoy,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _irAnterior,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _irSiguiente,
          ),
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            onPressed: () => context.push(AppRoutes.sesionesGestion),
            tooltip: l.gestionSesiones,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: SegmentedButton<_VistaCalendario>(
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              segments: [
                ButtonSegment(
                  value: _VistaCalendario.dia,
                  label: Text(l.dia),
                ),
                ButtonSegment(
                  value: _VistaCalendario.semana,
                  label: Text(l.semana),
                ),
                ButtonSegment(
                  value: _VistaCalendario.mes,
                  label: Text(l.mes),
                ),
                ButtonSegment(
                  value: _VistaCalendario.anio,
                  label: Text(l.anio),
                ),
              ],
              selected: {_vista},
              onSelectionChanged: (v) => setState(() {
                final nuevaVista = v.first;
                // Al cambiar a vista año, resetear al año actual
                if (nuevaVista == _VistaCalendario.anio &&
                    _vista != _VistaCalendario.anio) {
                  _focusedDay = DateTime.now();
                }
                _vista = nuevaVista;
              }),
            ),
          ),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.sesionForm),
        tooltip: l.nuevaSesionRecurrente,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    switch (_vista) {
      case _VistaCalendario.dia:
        return DiaList(
          dia: _selectedDay,
          onEventoTap: (e) => _onEventoTap(e, _selectedDay),
        );

      case _VistaCalendario.semana:
        return SemanaTimeline(
          semanaInicio: _semanaInicio(_selectedDay),
          selectedDay: _selectedDay,
          onDaySelected: (d) => setState(() {
            _selectedDay = d;
            _focusedDay = d;
          }),
          onEventoTap: (e) => _onEventoTap(e, _selectedDay),
        );

      case _VistaCalendario.mes:
        return MesCalendar(
          focusedDay: _focusedDay,
          selectedDay: _selectedDay,
          onDaySelected: (selected, focused) => setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
          }),
          onPageChanged: (d) => setState(() => _focusedDay = d),
          onEventoTap: (e) => _onEventoTap(e, _selectedDay),
        );

      case _VistaCalendario.anio:
        return AnioHeatmap(anio: _focusedDay.year);
    }
  }
}
