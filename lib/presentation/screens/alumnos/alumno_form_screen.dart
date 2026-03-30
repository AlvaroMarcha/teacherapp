import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/fuentes_provider.dart';
import '../../providers/database_provider.dart';
import '../../../domain/models/alumno.dart';

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
                onChanged: (v) => setState(() => _fuenteIdSeleccionada = v),
                validator: (v) => v == null ? 'Selecciona una fuente' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tarifaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tarifa por sesión (€)',
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
              ElevatedButton(
                onPressed: _guardar,
                child: Text(AppStrings.guardar),
              ),
            ],
          ),
        ),
      ),
    );
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
}
