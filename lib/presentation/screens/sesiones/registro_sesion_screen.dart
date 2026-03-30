import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../providers/fuentes_provider.dart';
import '../../providers/alumnos_provider.dart';
import '../../providers/database_provider.dart';
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
  String? _fuenteId;
  String? _alumnoId;
  DateTime _fecha = DateTime.now();
  double _horas = 1.0;
  bool _cobradoAhora = false;

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
          data: (alumnos) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('¿Qué sesión fue?', style: AppTextStyles.titleMedium),
              const SizedBox(height: 16),
              // Fuente
              DropdownButtonFormField<String>(
                value: _fuenteId,
                decoration: const InputDecoration(labelText: 'Fuente'),
                items: fuentes
                    .map(
                      (f) =>
                          DropdownMenuItem(value: f.id, child: Text(f.nombre)),
                    )
                    .toList(),
                onChanged: (v) => setState(() {
                  _fuenteId = v;
                  _alumnoId = null;
                }),
              ),
              const SizedBox(height: 12),
              // Alumno (si la fuente tiene alumnos)
              if (_fuenteId != null)
                DropdownButtonFormField<String>(
                  value: _alumnoId,
                  decoration: const InputDecoration(
                    labelText: 'Alumno (opcional)',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Sin alumno específico'),
                    ),
                    ...alumnos
                        .where((a) => a.fuenteId == _fuenteId)
                        .map(
                          (a) => DropdownMenuItem(
                            value: a.id,
                            child: Text(a.nombre),
                          ),
                        ),
                  ],
                  onChanged: (v) => setState(() => _alumnoId = v),
                ),
              const SizedBox(height: 12),
              // Duración
              DropdownButtonFormField<double>(
                value: _horas,
                decoration: const InputDecoration(labelText: 'Duración'),
                items: [0.5, 0.75, 1.0, 1.5, 2.0]
                    .map(
                      (h) => DropdownMenuItem(
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
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _horas = v);
                },
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              Text('¿Cobré ahora?', style: AppTextStyles.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _cobradoAhora
                            ? Colors.transparent
                            : null,
                      ),
                      onPressed: () => setState(() => _cobradoAhora = false),
                      child: const Text('Dejar pendiente'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _cobradoAhora = true),
                      child: const Text('Cobré ahora'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _fuenteId != null ? _confirmar : null,
                icon: const Icon(Icons.check),
                label: const Text('Confirmar sesión'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmar() async {
    if (_fuenteId == null) return;

    // Calcular tarifa
    double tarifa = 0;
    if (_alumnoId != null) {
      final alumno = await ref
          .read(alumnoRepositoryProvider)
          .getAlumnoById(_alumnoId!);
      tarifa = (alumno?.tarifaSesion ?? 0) * _horas;
    }

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
