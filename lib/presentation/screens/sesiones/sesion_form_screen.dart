import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../providers/fuentes_provider.dart';
import '../../providers/alumnos_provider.dart';
import '../../providers/database_provider.dart';
import '../../../domain/models/sesion_recurrente.dart';

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
  String? _fuenteId;
  String? _alumnoId;
  final List<int> _diasSemana = [];
  TimeOfDay _horaInicio = const TimeOfDay(hour: 9, minute: 0);
  double _duracion = 1.0;
  bool _esPuntual = false;
  DateTime? _fechaUnica;

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final fuentesAsync = ref.watch(fuentesProvider);
    final alumnosAsync = ref.watch(alumnosProvider);
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            isEdit ? 'Editar sesión recurrente' : 'Nueva sesión recurrente'),
        actions: [
          TextButton(
            onPressed: _guardar,
            child: const Text('Guardar'),
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
            data: (alumnos) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Fuente de ingresos', style: AppTextStyles.labelMedium),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _fuenteId,
                  decoration: const InputDecoration(labelText: 'Fuente'),
                  items: fuentes
                      .map((f) =>
                          DropdownMenuItem(value: f.id, child: Text(f.nombre)))
                      .toList(),
                  validator: (v) => v == null ? 'Selecciona una fuente' : null,
                  onChanged: (v) => setState(() {
                    _fuenteId = v;
                    _alumnoId = null;
                  }),
                ),
                const SizedBox(height: 12),
                if (_fuenteId != null) ...[
                  DropdownButtonFormField<String>(
                    value: _alumnoId,
                    decoration:
                        const InputDecoration(labelText: 'Alumno (opcional)'),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Sin alumno específico')),
                      ...alumnos.where((a) => a.fuenteId == _fuenteId).map(
                          (a) => DropdownMenuItem(
                              value: a.id, child: Text(a.nombre))),
                    ],
                    onChanged: (v) => setState(() => _alumnoId = v),
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
                    title: const Text('Clase única'),
                    subtitle: const Text(
                        'Solo ocurre una vez, en una fecha concreta'),
                    value: _esPuntual,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                      decoration: const InputDecoration(
                        labelText: 'Fecha',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        suffixIcon: Icon(Icons.chevron_right),
                      ),
                      child: Text(
                        _fechaUnica != null
                            ? AppDateUtils.formatFullDate(_fechaUnica!)
                            : 'Seleccionar',
                      ),
                    ),
                  ),
                ] else ...[
                  Text('Días de la semana', style: AppTextStyles.labelMedium),
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
                    decoration: const InputDecoration(
                      labelText: 'Hora de inicio',
                      prefixIcon: Icon(Icons.schedule_outlined),
                    ),
                    child: Text(_formatTime(_horaInicio)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<double>(
                  value: _duracion,
                  decoration: const InputDecoration(labelText: 'Duración'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fuenteId == null) return;

    if (_esPuntual) {
      if (_fechaUnica == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Selecciona una fecha para la clase única')),
        );
        return;
      }
    } else {
      if (_diasSemana.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona al menos un día')),
        );
        return;
      }
    }

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

    final sesion = SesionRecurrente(
      id: widget.existing?.id ?? _uuid.v4(),
      alumnoId: _alumnoId,
      fuenteId: _fuenteId!,
      diasSemana: diasFinales,
      horaInicio: horaInicio,
      horaFin: horaFin,
      fechaInicio: fechaBase,
      esPuntual: _esPuntual,
    );

    await ref.read(sesionRepositoryProvider).saveSesionRecurrente(sesion);

    if (mounted) Navigator.of(context).pop();
  }
}
