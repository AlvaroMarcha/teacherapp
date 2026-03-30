import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../providers/fuentes_provider.dart';
import '../../providers/database_provider.dart';
import '../../../domain/models/alumno.dart';
import '../../../domain/models/fuente.dart';

class AlumnoFormScreen extends ConsumerStatefulWidget {
  const AlumnoFormScreen({super.key, this.alumnoId});

  /// Si no es null, estamos editando un alumno existente.
  final String? alumnoId;

  @override
  ConsumerState<AlumnoFormScreen> createState() => _AlumnoFormScreenState();
}

class _AlumnoFormScreenState extends ConsumerState<AlumnoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _tarifaCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  int _duracionMinutos = 60;
  String? _fuenteIdSeleccionada;
  static const _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.alumnoId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final alumno = await ref
            .read(alumnoRepositoryProvider)
            .getAlumnoById(widget.alumnoId!);
        if (alumno != null && mounted) {
          setState(() {
            _nombreCtrl.text = alumno.nombre;
            _tarifaCtrl.text = alumno.tarifaSesion.toString();
            _notasCtrl.text = alumno.notas;
            _duracionMinutos = alumno.duracionMinutos;
            _fuenteIdSeleccionada = alumno.fuenteId;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _tarifaCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fuentesAsync = ref.watch(fuentesProvider);
    final esEdicion = widget.alumnoId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar alumno' : AppStrings.alumnoNuevo),
        actions: [
          if (esEdicion)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Theme.of(context).colorScheme.error,
              onPressed: () => _confirmarEliminar(context),
            ),
        ],
      ),
      body: fuentesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (fuentes) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del alumno',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nombre requerido' : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _fuenteIdSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Fuente de ingreso',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                items: fuentes
                    .map(
                      (f) =>
                          DropdownMenuItem(value: f.id, child: Text(f.nombre)),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() => _fuenteIdSeleccionada = v);
                  if (v != null) _autoFillTarifaEmpleo(v, fuentes);
                },
                validator: (v) => v == null ? 'Selecciona una fuente' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tarifaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tarifa por hora (€/h)',
                  prefixIcon: Icon(Icons.euro_rounded),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Tarifa requerida';
                  if (double.tryParse(v) == null) return 'Número inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _duracionMinutos,
                decoration: const InputDecoration(
                  labelText: 'Duración por defecto',
                  prefixIcon: Icon(Icons.timer_outlined),
                ),
                items: [30, 45, 60, 90, 120]
                    .map(
                      (m) => DropdownMenuItem(value: m, child: Text('$m min')),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _duracionMinutos = v);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notasCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                  hintText: 'Teléfono, observaciones...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _guardar,
                child: Text(AppStrings.guardar),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _autoFillTarifaEmpleo(
    String fuenteId,
    List<Fuente> fuentes,
  ) async {
    final fuente = fuentes.firstWhere((f) => f.id == fuenteId);
    if (fuente.tipo != FuenteTipo.empleo) return;

    final config = await ref.read(empleoConfigProvider(fuenteId).future);
    if (config != null && mounted) {
      _tarifaCtrl.text = config.tarifaHoraExtra.toStringAsFixed(2);
    }
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final alumno = Alumno(
      id: widget.alumnoId ?? _uuid.v4(),
      nombre: _nombreCtrl.text.trim(),
      fuenteId: _fuenteIdSeleccionada!,
      tarifaSesion: double.parse(_tarifaCtrl.text),
      duracionMinutos: _duracionMinutos,
      notas: _notasCtrl.text.trim(),
    );
    ref
        .read(alumnoRepositoryProvider)
        .saveAlumno(alumno)
        .then((_) => context.pop());
  }

  Future<void> _confirmarEliminar(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar alumno'),
        content: const Text(
          '¿Eliminar este alumno? Las sesiones registradas se mantendrán.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(alumnoRepositoryProvider).deleteAlumno(widget.alumnoId!);
      if (mounted) context.go(AppRoutes.alumnos);
    }
  }
}
