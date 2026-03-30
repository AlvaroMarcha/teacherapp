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
import '../../../domain/models/sesion_realizada.dart';
import '../../../domain/models/cobro.dart';

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
  double _horas = 1.0;
  bool _cobradoAhora = false;
  String _importeHelper = 'Introduce el importe de la sesión';

  @override
  void dispose() {
    _importeCtrl.dispose();
    super.dispose();
  }

  Future<void> _onAlumnoChanged(String? alumnoId) async {
    setState(() => _alumnoId = alumnoId);
    if (alumnoId == null) {
      // Sin alumno: intentar tarifa global como fallback
      final global = ref.read(tarifaGlobalProvider);
      if (global > 0) {
        _importeCtrl.text = (global * _horas).toStringAsFixed(2);
        setState(() => _importeHelper =
            'Tarifa global (${global.toStringAsFixed(2)}€/h) · editable');
      } else {
        _importeCtrl.clear();
        setState(() => _importeHelper = 'Introduce el importe de la sesión');
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
            'Tarifa del alumno (${alumno.tarifaSesion.toStringAsFixed(2)}€/h) · editable');
      } else {
        // Alumno sin tarifa propia: fallback a global
        final global = ref.read(tarifaGlobalProvider);
        if (global > 0) {
          _importeCtrl.text = (global * _horas).toStringAsFixed(2);
          setState(() => _importeHelper =
              'Tarifa global (${global.toStringAsFixed(2)}€/h) · editable');
        } else {
          _importeCtrl.clear();
          setState(() => _importeHelper = 'Introduce el importe de la sesión');
        }
      }
    }
  }

  void _onHorasChanged(double horas) {
    setState(() => _horas = horas);
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

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar sesión')),
      body: fuentesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (fuentes) => alumnosAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (alumnos) => Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('¿Qué sesión fue?', style: AppTextStyles.titleMedium),
                const SizedBox(height: 16),

                // Fuente
                DropdownButtonFormField<String>(
                  value: _fuenteId,
                  decoration: const InputDecoration(
                    labelText: 'Fuente',
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  ),
                  items: fuentes
                      .map((f) => DropdownMenuItem(
                            value: f.id,
                            child: Text(f.nombre),
                          ))
                      .toList(),
                  validator: (v) => v == null ? 'Selecciona una fuente' : null,
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
                    decoration: const InputDecoration(
                      labelText: 'Alumno (opcional)',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Sin alumno específico'),
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

                // Duración
                DropdownButtonFormField<double>(
                  value: _horas,
                  decoration: const InputDecoration(
                    labelText: 'Duración',
                    prefixIcon: Icon(Icons.access_time_rounded),
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
                                          ? '1h 30min'
                                          : h == 2.0
                                              ? '2 horas'
                                              : '1 hora',
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) _onHorasChanged(v);
                  },
                ),
                const SizedBox(height: 12),

                // Importe (siempre visible; auto-calculado si hay alumno)
                TextFormField(
                  controller: _importeCtrl,
                  decoration: InputDecoration(
                    labelText: 'Importe (€)',
                    prefixIcon: const Icon(Icons.euro_rounded),
                    helperText: _importeHelper,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Introduce el importe';
                    }
                    if (double.tryParse(v) == null) return 'Número inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Estado de cobro — SegmentedButton
                Text(
                  '¿Cuándo cobras?',
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: 12),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: false,
                      label: Text('Pendiente'),
                      icon: Icon(Icons.schedule_outlined),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text('Cobré ahora'),
                      icon: Icon(Icons.payments_outlined),
                    ),
                  ],
                  selected: {_cobradoAhora},
                  onSelectionChanged: (s) =>
                      setState(() => _cobradoAhora = s.first),
                ),
                const SizedBox(height: 32),

                FilledButton.icon(
                  onPressed: _fuenteId != null ? _confirmar : null,
                  icon: const Icon(Icons.check),
                  label: const Text('Confirmar sesión'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmar() async {
    if (_fuenteId == null) return;
    if (!_formKey.currentState!.validate()) return;

    final tarifa = double.parse(_importeCtrl.text);

    final sesionId = _uuid.v4();
    final sesion = SesionRealizada(
      id: sesionId,
      alumnoId: _alumnoId,
      fuenteId: _fuenteId!,
      fecha: AppDateUtils.formatIso(_fecha),
      horas: _horas,
      cobro: tarifa,
      estado: EstadoSesion.confirmada,
    );
    await ref.read(sesionRepositoryProvider).saveSesionRealizada(sesion);

    // Generar cobro automático
    final cobro = Cobro(
      id: _uuid.v4(),
      sesionId: sesionId,
      alumnoId: _alumnoId,
      fuenteId: _fuenteId!,
      modoCobro: ModoCobro.sesion,
      monto: tarifa,
      estado: _cobradoAhora ? EstadoCobro.cobrado : EstadoCobro.pendiente,
      fechaCobro: _cobradoAhora ? AppDateUtils.formatIso(_fecha) : null,
    );
    await ref.read(cobroRepositoryProvider).saveCobro(cobro);

    if (mounted) context.pop();
  }
}
