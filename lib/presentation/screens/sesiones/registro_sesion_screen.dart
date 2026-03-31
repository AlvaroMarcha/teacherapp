import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../providers/fuentes_provider.dart';
import '../../providers/alumnos_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/theme_provider.dart';
import '../../../domain/models/sesion_recurrente.dart';
import '../../../domain/models/sesion_realizada.dart';
import '../../../domain/models/cobro.dart';
import '../../../domain/models/fuente.dart';
import '../../../domain/models/hora_extra.dart';

/// Pantalla de registro rápido de sesión (flujo de 3 toques).
///
/// Flujo del informe:
///  1. Lau toca el bloque de Blanca en el horario de hoy
///  2. Confirma que la sesión se realizó ✓
///  3. Indica si cobró en efectivo ahora o deja pendiente → cobro automático
class RegistroSesionScreen extends ConsumerStatefulWidget {
  const RegistroSesionScreen({super.key});

  @override
  ConsumerState<RegistroSesionScreen> createState() =>
      _RegistroSesionScreenState();
}

class _RegistroSesionScreenState extends ConsumerState<RegistroSesionScreen> {
  static const _uuid = Uuid();
  final _formKey = GlobalKey<FormState>();
  final _importeCtrl = TextEditingController();

  String? _fuenteId;
  String? _alumnoId;
  DateTime _fecha = DateTime.now();
  TimeOfDay _horaInicio = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _horaFin = const TimeOfDay(hour: 10, minute: 0);
  double _horas = 1.0;
  bool _cobradoAhora = false;
  bool _importeEditable = false;
  bool _esPuntual = true;
  final List<int> _diasSemana = [];
  String? _importeHelper;

  @override
  void dispose() {
    _importeCtrl.dispose();
    super.dispose();
  }

  Future<void> _onAlumnoChanged(String? alumnoId) async {
    setState(() => _alumnoId = alumnoId);
    final l = ref.read(appLocalizationsProvider);
    if (alumnoId == null) {
      // Sin alumno: intentar tarifa global como fallback
      final global = ref.read(tarifaGlobalProvider);
      if (global > 0) {
        _importeCtrl.text = (global * _horas).toStringAsFixed(2);
        setState(() => _importeHelper =
            '${l.tarifaGlobalEditable} (${global.toStringAsFixed(2)}€/h)');
      } else {
        _importeCtrl.clear();
        setState(() => _importeHelper = null);
      }
      return;
    }
    final alumno =
        await ref.read(alumnoRepositoryProvider).getAlumnoById(alumnoId);
    if (alumno != null && mounted) {
      if (alumno.tarifaSesion > 0) {
        final tarifa = alumno.tarifaSesion * _horas;
        _importeCtrl.text = tarifa.toStringAsFixed(2);
        setState(() => _importeHelper =
            '${l.tarifaAlumnoEditable} (${alumno.tarifaSesion.toStringAsFixed(2)}€/h)');
      } else {
        // Alumno sin tarifa propia: fallback a global
        final global = ref.read(tarifaGlobalProvider);
        if (global > 0) {
          _importeCtrl.text = (global * _horas).toStringAsFixed(2);
          setState(() => _importeHelper =
              '${l.tarifaGlobalEditable} (${global.toStringAsFixed(2)}€/h)');
        } else {
          _importeCtrl.clear();
          setState(() => _importeHelper = null);
        }
      }
    }
  }

  void _onHorasChanged(double horas) {
    setState(() {
      _horas = horas;
      // Auto-ajustar horaFin según nueva duración
      final totalMin =
          _horaInicio.hour * 60 + _horaInicio.minute + (horas * 60).round();
      _horaFin = TimeOfDay(hour: totalMin ~/ 60, minute: totalMin % 60);
    });
    if (_alumnoId != null) {
      _onAlumnoChanged(_alumnoId);
    } else {
      // Sin alumno: recalcular con tarifa global si existe
      final global = ref.read(tarifaGlobalProvider);
      if (global > 0) {
        _importeCtrl.text = (global * horas).toStringAsFixed(2);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fuentesAsync = ref.watch(fuentesProvider);
    final alumnosAsync = ref.watch(alumnosProvider);
    final l = ref.watch(appLocalizationsProvider);
    final diasLabels = l.diasAbreviados.split(',');

    return Scaffold(
      appBar: AppBar(title: Text(l.registrarSesion)),
      body: fuentesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (fuentes) => alumnosAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (alumnos) {
            final esEmpleo = _fuenteId != null &&
                fuentes.any(
                    (f) => f.id == _fuenteId && f.tipo == FuenteTipo.empleo);

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(l.queSesionFue, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 16),

                  // Fuente
                  DropdownButtonFormField<String>(
                    value: _fuenteId,
                    decoration: InputDecoration(
                      labelText: l.navFuentes,
                      prefixIcon:
                          const Icon(Icons.account_balance_wallet_outlined),
                    ),
                    items: fuentes
                        .map((f) => DropdownMenuItem(
                              value: f.id,
                              child: Text(f.nombre),
                            ))
                        .toList(),
                    validator: (v) => v == null ? l.seleccionaFuente : null,
                    onChanged: (v) => setState(() {
                      _fuenteId = v;
                      _alumnoId = null;
                      _importeCtrl.clear();
                    }),
                  ),
                  const SizedBox(height: 12),

                  // Alumno (filtrado por fuente)
                  if (_fuenteId != null)
                    DropdownButtonFormField<String>(
                      value: _alumnoId,
                      decoration: InputDecoration(
                        labelText: l.alumnoOpcional,
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(l.sinAlumnoEspecifico),
                        ),
                        ...alumnos
                            .where((a) => a.fuenteId == _fuenteId)
                            .map((a) => DropdownMenuItem(
                                  value: a.id,
                                  child: Text(a.nombre),
                                )),
                      ],
                      onChanged: _onAlumnoChanged,
                    ),
                  const SizedBox(height: 12),

                  // Tipo: puntual o recurrente
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
                        _diasSemana.clear();
                      }),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_esPuntual) ...[
                    // Fecha única
                    GestureDetector(
                      onTap: _pickFecha,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l.fecha,
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          suffixIcon: const Icon(Icons.chevron_right),
                        ),
                        child: Text(AppDateUtils.formatFullDate(_fecha)),
                      ),
                    ),
                  ] else ...[
                    // Días de la semana
                    Text(l.diasSemana, style: AppTextStyles.labelMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: List.generate(7, (i) {
                        final num = i + 1;
                        final selected = _diasSemana.contains(num);
                        return FilterChip(
                          label: Text(diasLabels[i]),
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
                      }),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Hora inicio / fin
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickHora(isInicio: true),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: l.horaInicio,
                              prefixIcon: const Icon(Icons.schedule_outlined),
                            ),
                            child: Text(_formatTime(_horaInicio)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickHora(isInicio: false),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: l.fin,
                              prefixIcon: const Icon(Icons.schedule_outlined),
                            ),
                            child: Text(_formatTime(_horaFin)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Duración
                  DropdownButtonFormField<double>(
                    value: _horas,
                    decoration: InputDecoration(
                      labelText: l.duracion,
                      prefixIcon: const Icon(Icons.access_time_rounded),
                    ),
                    items: [0.5, 0.75, 1.0, 1.5, 2.0]
                        .map((h) => DropdownMenuItem(
                              value: h,
                              child: Text(
                                h == 0.5
                                    ? '30 min'
                                    : h == 0.75
                                        ? '45 min'
                                        : h == 1.5
                                            ? '1h 30 min'
                                            : '${h.toInt()}h',
                              ),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) _onHorasChanged(v);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Importe y cobro (solo para fuentes no-empleo)
                  if (!esEmpleo) ...[
                    TextFormField(
                      controller: _importeCtrl,
                      enabled: _importeEditable,
                      decoration: InputDecoration(
                        labelText: l.importeEuro,
                        prefixIcon: const Icon(Icons.euro_rounded),
                        helperText: _importeHelper ?? l.introduceImporteSesion,
                        suffixIcon: _importeEditable
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                tooltip: l.editarImporte,
                                onPressed: () =>
                                    setState(() => _importeEditable = true),
                              ),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return l.introduceImporte;
                        }
                        if (double.tryParse(v) == null) return l.numeroInvalido;
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Estado de cobro — SegmentedButton
                    Text(
                      l.cuandoCobras,
                      style: AppTextStyles.titleSmall,
                    ),
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
                  const SizedBox(height: 32),

                  FilledButton.icon(
                    onPressed: _fuenteId != null ? _confirmar : null,
                    icon: const Icon(Icons.check),
                    label: Text(l.confirmarSesion),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  Future<void> _pickHora({required bool isInicio}) async {
    final initial = isInicio ? _horaInicio : _horaFin;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      setState(() {
        if (isInicio) {
          _horaInicio = picked;
          // Auto-ajustar horaFin según duración actual
          final totalMin =
              picked.hour * 60 + picked.minute + (_horas * 60).round();
          _horaFin = TimeOfDay(hour: totalMin ~/ 60, minute: totalMin % 60);
        } else {
          _horaFin = picked;
          // Recalcular duración
          final diffMin = (picked.hour * 60 + picked.minute) -
              (_horaInicio.hour * 60 + _horaInicio.minute);
          if (diffMin > 0) {
            _horas = diffMin / 60.0;
          }
        }
      });
    }
  }

  Future<void> _confirmar() async {
    if (_fuenteId == null) return;

    final fuentesAsync = ref.read(fuentesProvider);
    final fuentes = fuentesAsync.valueOrNull ?? [];
    final fuente = fuentes.where((f) => f.id == _fuenteId).firstOrNull;
    final esEmpleo = fuente?.tipo == FuenteTipo.empleo;

    if (!esEmpleo && !_formKey.currentState!.validate()) return;

    if (!_esPuntual && _diasSemana.isEmpty) {
      final l = ref.read(appLocalizationsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.seleccionaDia)),
      );
      return;
    }

    final tarifa = esEmpleo ? 0.0 : (double.tryParse(_importeCtrl.text) ?? 0.0);
    final fechaIso = AppDateUtils.formatIso(_fecha);
    final horaInicioStr = _formatTime(_horaInicio);
    final horaFinStr = _formatTime(_horaFin);

    // 1. Crear SesionRecurrente (puntual o recurrente)
    final recurrenteId = _uuid.v4();
    final recurrente = SesionRecurrente(
      id: recurrenteId,
      fuenteId: _fuenteId!,
      alumnoId: _alumnoId,
      diasSemana: _esPuntual ? [_fecha.weekday] : List.from(_diasSemana),
      horaInicio: horaInicioStr,
      horaFin: horaFinStr,
      fechaInicio: fechaIso,
      esPuntual: _esPuntual,
    );
    await ref.read(sesionRepositoryProvider).saveSesionRecurrente(recurrente);

    // 2. Crear SesionRealizada solo para sesiones puntuales (ya ocurrió)
    if (_esPuntual) {
      final sesionId = _uuid.v4();
      final sesion = SesionRealizada(
        id: sesionId,
        alumnoId: _alumnoId,
        fuenteId: _fuenteId!,
        sesionRecurrenteId: recurrenteId,
        fecha: fechaIso,
        horas: _horas,
        cobro: tarifa,
        estado: EstadoSesion.confirmada,
      );
      await ref.read(sesionRepositoryProvider).saveSesionRealizada(sesion);

      // 3. Flujo de cobro / horas extra según tipo de fuente
      if (esEmpleo) {
        final horaExtra = HoraExtra(
          id: _uuid.v4(),
          fuenteId: _fuenteId!,
          fecha: fechaIso,
          horas: _horas,
          alumnoId: _alumnoId,
          notas: 'Auto - registro manual',
        );
        await ref.read(horasExtraRepositoryProvider).saveHoraExtra(horaExtra);
      } else {
        final cobro = Cobro(
          id: _uuid.v4(),
          sesionId: sesionId,
          alumnoId: _alumnoId,
          fuenteId: _fuenteId!,
          modoCobro: ModoCobro.sesion,
          monto: tarifa,
          estado: _cobradoAhora ? EstadoCobro.cobrado : EstadoCobro.pendiente,
          fechaCobro: _cobradoAhora ? fechaIso : null,
        );
        await ref.read(cobroRepositoryProvider).saveCobro(cobro);
      }
    }

    if (mounted) context.pop();
  }
}
