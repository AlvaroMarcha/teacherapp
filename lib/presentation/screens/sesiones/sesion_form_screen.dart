import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../providers/fuentes_provider.dart';
import '../../providers/alumnos_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/cobros_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/horas_extra_provider.dart';
import '../../providers/sesiones_provider.dart';
import '../../../core/services/cobro_auto_service.dart';
import '../../../domain/models/sesion_recurrente.dart';
import '../../../domain/models/sesion_realizada.dart';
import '../../../domain/models/cobro.dart';
import '../../../domain/models/fuente.dart';
import '../../../domain/models/hora_extra.dart';

/// Formulario para crear o editar una sesión recurrente.
/// Se usa al definir el horario semanal (ej: Blanca, lunes y miércoles 17h).
class SesionFormScreen extends ConsumerStatefulWidget {
  final SesionRecurrente? existing;
  const SesionFormScreen({super.key, this.existing});

  @override
  ConsumerState<SesionFormScreen> createState() => _SesionFormScreenState();
}

class _SesionFormScreenState extends ConsumerState<SesionFormScreen> {
  static const _uuid = Uuid();
  final _formKey = GlobalKey<FormState>();
  final _importeCtrl = TextEditingController();
  String? _fuenteId;
  String? _alumnoId;
  final List<int> _diasSemana = [];
  TimeOfDay _horaInicio = const TimeOfDay(hour: 9, minute: 0);
  double _duracion = 1.0;
  bool _esPuntual = false;
  DateTime? _fechaUnica;
  DateTime? _fechaFin;
  bool _cobradoAhora = false;

  // Labels de días lunes=1 ... domingo=7
  static const _dias = [
    (1, 'L'),
    (2, 'M'),
    (3, 'X'),
    (4, 'J'),
    (5, 'V'),
    (6, 'S'),
    (7, 'D'),
  ];

  @override
  void dispose() {
    _importeCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _fuenteId = e.fuenteId;
      _alumnoId = e.alumnoId;
      _diasSemana.addAll(e.diasSemana);
      final parts = e.horaInicio.split(':');
      _horaInicio = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
      // Compute duration from horaInicio/horaFin
      final finParts = e.horaFin.split(':');
      final finMinutes = int.parse(finParts[0]) * 60 + int.parse(finParts[1]);
      final iniMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      _duracion = (finMinutes - iniMinutes) / 60.0;
      _esPuntual = e.esPuntual;
      if (e.esPuntual && e.fechaInicio.isNotEmpty) {
        _fechaUnica = DateTime.tryParse(e.fechaInicio);
      }
      if (e.fechaFin != null) {
        _fechaFin = DateTime.tryParse(e.fechaFin!);
      }
      // Cargar tarifa del alumno si existe
      if (e.alumnoId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final alumnos = ref.read(alumnosProvider).valueOrNull ?? [];
          try {
            final alumno = alumnos.firstWhere((a) => a.id == e.alumnoId);
            if (alumno.tarifaSesion > 0) {
              _importeCtrl.text = alumno.tarifaSesion.toStringAsFixed(2);
            }
          } catch (_) {
            // Alumno no encontrado, ignorar
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(appLocalizationsProvider);
    final fuentesAsync = ref.watch(fuentesProvider);
    final alumnosAsync = ref.watch(alumnosProvider);
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(isEdit ? l.editarSesionRecurrente : l.nuevaSesionRecurrente),
        actions: [
          TextButton(
            onPressed: _guardar,
            child: Text(l.guardar),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: fuentesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (fuentes) => alumnosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (alumnos) {
              final esEmpleo = _fuenteId != null &&
                  fuentes.any(
                      (f) => f.id == _fuenteId && f.tipo == FuenteTipo.empleo);

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(l.fuenteIngreso, style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _fuenteId,
                    decoration: InputDecoration(labelText: l.navFuentes),
                    items: fuentes
                        .map((f) => DropdownMenuItem(
                            value: f.id, child: Text(f.nombre)))
                        .toList(),
                    validator: (v) => v == null ? l.seleccionaFuente : null,
                    onChanged: (v) => setState(() {
                      _fuenteId = v;
                      _alumnoId = null;
                    }),
                  ),
                  const SizedBox(height: 12),
                  if (_fuenteId != null) ...[
                    DropdownButtonFormField<String>(
                      value: _alumnoId,
                      decoration: InputDecoration(labelText: l.alumnoOpcional),
                      items: [
                        DropdownMenuItem(
                            value: null, child: Text(l.sinAlumnoEspecifico)),
                        ...alumnos.where((a) => a.fuenteId == _fuenteId).map(
                            (a) => DropdownMenuItem(
                                value: a.id, child: Text(a.nombre))),
                      ],
                      onChanged: (v) {
                        setState(() => _alumnoId = v);
                        // Cargar tarifa del alumno seleccionado
                        if (v != null) {
                          final alumno = alumnos.firstWhere((a) => a.id == v);
                          if (alumno.tarifaSesion > 0) {
                            _importeCtrl.text =
                                alumno.tarifaSesion.toStringAsFixed(2);
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      title: Text(l.claseUnica),
                      subtitle: Text(l.claseUnicaDesc),
                      value: _esPuntual,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onChanged: (v) => setState(() {
                        _esPuntual = v;
                        if (v) {
                          _diasSemana.clear();
                          _fechaUnica ??= DateTime.now();
                        } else {
                          _fechaUnica = null;
                        }
                      }),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_esPuntual) ...[
                    GestureDetector(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _fechaUnica ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) setState(() => _fechaUnica = d);
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l.fecha,
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          suffixIcon: const Icon(Icons.chevron_right),
                        ),
                        child: Text(
                          _fechaUnica != null
                              ? AppDateUtils.formatFullDate(_fechaUnica!)
                              : l.seleccionar,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Fecha fin opcional para sesiones recurrentes
                    GestureDetector(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _fechaFin ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) setState(() => _fechaFin = d);
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l.fechaFin,
                          prefixIcon: const Icon(Icons.event_busy_outlined),
                          suffixIcon: _fechaFin != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () =>
                                      setState(() => _fechaFin = null),
                                )
                              : const Icon(Icons.chevron_right),
                        ),
                        child: Text(
                          _fechaFin != null
                              ? AppDateUtils.formatFullDate(_fechaFin!)
                              : l.sinFechaFin,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(l.diasSemana, style: AppTextStyles.labelMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _dias.map((d) {
                        final (num, label) = d;
                        final selected = _diasSemana.contains(num);
                        return FilterChip(
                          label: Text(label),
                          selected: selected,
                          shape: const StadiumBorder(),
                          onSelected: (v) => setState(() {
                            if (v) {
                              _diasSemana.add(num);
                            } else {
                              _diasSemana.remove(num);
                            }
                          }),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: _horaInicio,
                      );
                      if (t != null) setState(() => _horaInicio = t);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l.horaInicio,
                        prefixIcon: const Icon(Icons.schedule_outlined),
                      ),
                      child: Text(_formatTime(_horaInicio)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<double>(
                    value: _duracion,
                    decoration: InputDecoration(labelText: l.duracion),
                    items: [0.5, 0.75, 1.0, 1.5, 2.0]
                        .map((h) => DropdownMenuItem(
                              value: h,
                              child: Text(
                                h == 0.5
                                    ? '30 min'
                                    : h == 0.75
                                        ? '45 min'
                                        : h == 1.5
                                            ? '1h 30min'
                                            : h == 2.0
                                                ? '2 horas'
                                                : '1 hora',
                              ),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _duracion = v);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Campos de importe y cobro para sesiones no-empleo
                  if (!esEmpleo) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _importeCtrl,
                      decoration: InputDecoration(
                        labelText: l.importeEuro,
                        prefixIcon: const Icon(Icons.euro_rounded),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return l.introduceImporte;
                        if (double.tryParse(v) == null) return l.numeroInvalido;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(l.cuandoCobras, style: AppTextStyles.titleSmall),
                    const SizedBox(height: 12),
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(
                          value: false,
                          label: Text(l.pendiente),
                          icon: const Icon(Icons.schedule_outlined),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text(l.cobreAhora),
                          icon: const Icon(Icons.payments_outlined),
                        ),
                      ],
                      selected: {_cobradoAhora},
                      onSelectionChanged: (s) =>
                          setState(() => _cobradoAhora = s.first),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _guardar() async {
    final l = ref.read(appLocalizationsProvider);
    if (!_formKey.currentState!.validate()) return;
    if (_fuenteId == null) return;

    if (_esPuntual) {
      if (_fechaUnica == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.seleccionaFechaUnica)),
        );
        return;
      }
    } else {
      if (_diasSemana.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.seleccionaDia)),
        );
        return;
      }
    }

    // Detectar si es fuente empleo
    final fuentes = ref.read(fuentesProvider).valueOrNull ?? [];
    final esEmpleo =
        fuentes.any((f) => f.id == _fuenteId && f.tipo == FuenteTipo.empleo);

    String fmt(int h, int m) =>
        '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    final horaInicio = fmt(_horaInicio.hour, _horaInicio.minute);
    final totalMinutes =
        _horaInicio.hour * 60 + _horaInicio.minute + (_duracion * 60).round();
    final horaFin = fmt(totalMinutes ~/ 60 % 24, totalMinutes % 60);

    final fechaBase = _esPuntual
        ? _fechaUnica!.toIso8601String().substring(0, 10)
        : (widget.existing?.fechaInicio ??
            DateTime.now().toIso8601String().substring(0, 10));

    final diasFinales = _esPuntual
        ? [_fechaUnica!.weekday]
        : (List<int>.from(_diasSemana)..sort());

    final recurrenteId = widget.existing?.id ?? _uuid.v4();
    final fechaFinStr = (!_esPuntual && _fechaFin != null)
        ? _fechaFin!.toIso8601String().substring(0, 10)
        : null;

    final sesion = SesionRecurrente(
      id: recurrenteId,
      alumnoId: _alumnoId,
      fuenteId: _fuenteId!,
      diasSemana: diasFinales,
      horaInicio: horaInicio,
      horaFin: horaFin,
      fechaInicio: fechaBase,
      fechaFin: fechaFinStr,
      esPuntual: _esPuntual,
      activa: widget.existing?.activa ?? true,
    );

    await ref.read(sesionRepositoryProvider).saveSesionRecurrente(sesion);

    // Para recurrentes no puntuales: regenerar cobros pendientes
    if (!_esPuntual && !esEmpleo) {
      final db = ref.read(databaseProvider);

      // Si es edición, eliminar cobros pendientes futuros antes de regenerar
      if (widget.existing != null) {
        final hoy = DateTime.now();
        final fechaHoy =
            '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
        await db.deleteSesionesRealizadasPendientesFuturas(
          recurrenteId,
          fechaHoy,
        );
      }

      // Regenerar cobros
      await CobroAutoService.generarCobrosPendientes(db);

      // Actualizar importe de sesiones pendientes con el valor del formulario
      final tarifa = double.tryParse(_importeCtrl.text) ?? 0.0;
      if (tarifa > 0) {
        await db.actualizarTarifaPendientesByRecurrente(recurrenteId, tarifa);
      }

      ref.invalidate(cobrosProvider);
      ref.invalidate(cobrosPendientesProvider);
      ref.invalidate(sesionesRecurrentesProvider);
    }

    // Crear SesionRealizada + Cobro/HoraExtra solo para sesiones puntuales
    if (_esPuntual) {
      final db = ref.read(databaseProvider);

      // Si es edición, eliminar SesionRealizada + Cobro pendientes existentes
      if (widget.existing != null) {
        await db.deleteSesionesRealizadasPendientesFuturas(
          recurrenteId,
          '2000-01-01',
        );
      }

      final sesionId = _uuid.v4();

      if (esEmpleo) {
        // Para sesiones de empleo: determinar estado según si la hora de fin ya pasó
        final finParts = horaFin.split(':');
        final fechaHoraFin = DateTime(
          _fechaUnica!.year,
          _fechaUnica!.month,
          _fechaUnica!.day,
          int.parse(finParts[0]),
          int.parse(finParts[1]),
        );
        final yaTermino = DateTime.now().isAfter(fechaHoraFin);

        final realizada = SesionRealizada(
          id: sesionId,
          alumnoId: _alumnoId,
          fuenteId: _fuenteId!,
          sesionRecurrenteId: recurrenteId,
          fecha: fechaBase,
          horas: _duracion,
          cobro: 0,
          estado: yaTermino ? EstadoSesion.confirmada : EstadoSesion.pendiente,
        );
        await ref.read(sesionRepositoryProvider).saveSesionRealizada(realizada);

        // Crear HoraExtra solo si la sesión ya terminó
        if (yaTermino) {
          final horaExtra = HoraExtra(
            id: _uuid.v4(),
            fuenteId: _fuenteId!,
            fecha: fechaBase,
            horas: _duracion,
            alumnoId: _alumnoId,
            notas: 'Auto - calendario',
          );
          await ref.read(horasExtraRepositoryProvider).saveHoraExtra(horaExtra);
        }

        // Invalidar providers para actualizar toda la app
        ref.invalidate(horasExtraProvider);
        ref.invalidate(dashboardProvider);
        ref.invalidate(sesionesRecurrentesProvider);
        ref.invalidate(sesionesRealizadasFechaProvider(fechaBase));
      } else {
        // Para sesiones no-empleo: crear SesionRealizada + Cobro
        final tarifa = double.tryParse(_importeCtrl.text) ?? 0.0;
        final realizada = SesionRealizada(
          id: sesionId,
          alumnoId: _alumnoId,
          fuenteId: _fuenteId!,
          sesionRecurrenteId: recurrenteId,
          fecha: fechaBase,
          horas: _duracion,
          cobro: tarifa,
          estado:
              _cobradoAhora ? EstadoSesion.confirmada : EstadoSesion.pendiente,
        );
        await ref.read(sesionRepositoryProvider).saveSesionRealizada(realizada);

        final cobro = Cobro(
          id: _uuid.v4(),
          sesionId: sesionId,
          alumnoId: _alumnoId,
          fuenteId: _fuenteId!,
          modoCobro: ModoCobro.sesion,
          monto: tarifa,
          estado: _cobradoAhora ? EstadoCobro.cobrado : EstadoCobro.pendiente,
          fechaCobro: _cobradoAhora ? fechaBase : null,
        );
        await ref.read(cobroRepositoryProvider).saveCobro(cobro);

        // Invalidar providers para actualizar toda la app
        ref.invalidate(cobrosProvider);
        ref.invalidate(cobrosPendientesProvider);
        ref.invalidate(dashboardProvider);
        ref.invalidate(sesionesRecurrentesProvider);
        ref.invalidate(sesionesRealizadasFechaProvider(fechaBase));
      }
    }

    if (mounted) Navigator.of(context).pop();
  }
}
