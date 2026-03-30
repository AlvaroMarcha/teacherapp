import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/models/empleo_config.dart';
import '../../../domain/models/fuente.dart';
import '../../providers/database_provider.dart';
import '../../providers/fuentes_provider.dart';

class FuenteFormScreen extends ConsumerStatefulWidget {
  const FuenteFormScreen({super.key, this.fuenteId});

  final String? fuenteId;

  @override
  ConsumerState<FuenteFormScreen> createState() => _FuenteFormScreenState();
}

class _FuenteFormScreenState extends ConsumerState<FuenteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _salarioCtrl = TextEditingController();
  final _horasCtrl = TextEditingController();
  final _tarifaExtraCtrl = TextEditingController();

  FuenteTipo _tipo = FuenteTipo.particular;
  Color _color = const Color(0xFF2563EB);
  int _diaCobro = 1;
  bool _loading = false;
  bool _dataLoaded = false;

  bool get _esEdicion => widget.fuenteId != null;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _salarioCtrl.dispose();
    _horasCtrl.dispose();
    _tarifaExtraCtrl.dispose();
    super.dispose();
  }

  // ── Carga inicial ────────────────────────────────────────────────

  Future<void> _cargarDatos() async {
    if (_dataLoaded || widget.fuenteId == null) {
      _dataLoaded = true;
      return;
    }
    final repo = ref.read(fuenteRepositoryProvider);
    final fuente = await repo.getFuenteById(widget.fuenteId!);
    if (fuente == null || !mounted) return;
    _nombreCtrl.text = fuente.nombre;
    _color = Color(int.parse('FF${fuente.color}', radix: 16));
    if (mounted) setState(() => _tipo = fuente.tipo);

    if (fuente.tipo == FuenteTipo.empleo) {
      final config = await repo.getEmpleoConfig(fuente.id);
      if (config != null && mounted) {
        _salarioCtrl.text = config.salarioBase.toStringAsFixed(2);
        _horasCtrl.text = config.horasSemanales.toStringAsFixed(0);
        _tarifaExtraCtrl.text = config.tarifaHoraExtra.toStringAsFixed(2);
        setState(() => _diaCobro = config.diaCobro);
      }
    }
    _dataLoaded = true;
  }

  // ── Guardar ──────────────────────────────────────────────────────

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final colorHex = _color.value
        .toRadixString(16)
        .toUpperCase()
        .padLeft(8, '0')
        .substring(2);

    final fuente = Fuente(
      id: widget.fuenteId ?? '',
      nombre: _nombreCtrl.text.trim(),
      tipo: _tipo,
      color: colorHex,
    );

    final repo = ref.read(fuenteRepositoryProvider);
    try {
      final id = await repo.saveFuente(fuente);

      if (_tipo == FuenteTipo.empleo) {
        await repo.saveEmpleoConfig(
          EmpleoConfig(
            fuenteId: id,
            salarioBase: double.parse(_salarioCtrl.text),
            horasSemanales: double.parse(_horasCtrl.text),
            tarifaHoraExtra: double.parse(_tarifaExtraCtrl.text),
            diaCobro: _diaCobro,
          ),
        );
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Eliminar ─────────────────────────────────────────────────────

  Future<void> _confirmarEliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar fuente'),
        content: const Text(
          'Se eliminarán también todos los alumnos, sesiones y cobros '
          'asociados a esta fuente. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(fuenteRepositoryProvider)
          .deleteFuenteCascade(widget.fuenteId!);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
        setState(() => _loading = false);
      }
    }
  }

  // ── Color picker ─────────────────────────────────────────────────

  Future<void> _mostrarColorPicker() async {
    Color tempColor = _color;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elige un color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (c) => tempColor = c,
            hexInputBar: true,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              setState(() => _color = tempColor);
              Navigator.pop(ctx);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  // ── UI ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Cargar datos en el primer build si es edición
    if (!_dataLoaded) {
      _cargarDatos();
    }

    // Si estamos en edición, esperar a que carguen los datos
    if (_esEdicion && !_dataLoaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar fuente')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar fuente' : 'Nueva fuente'),
        actions: [
          if (_esEdicion)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Theme.of(context).colorScheme.error,
              tooltip: 'Eliminar fuente',
              onPressed: _loading ? null : _confirmarEliminar,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            // Nombre
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre de la fuente',
                prefixIcon: Icon(Icons.label_outline),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Nombre requerido' : null,
            ),
            const SizedBox(height: 20),

            // Tipo
            Text(
              'Tipo de fuente',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<FuenteTipo>(
              segments: const [
                ButtonSegment(
                  value: FuenteTipo.empleo,
                  label: Text('Empleo'),
                  icon: Icon(Icons.work_outline),
                ),
                ButtonSegment(
                  value: FuenteTipo.academia,
                  label: Text('Academia'),
                  icon: Icon(Icons.school_outlined),
                ),
                ButtonSegment(
                  value: FuenteTipo.particular,
                  label: Text('Particular'),
                  icon: Icon(Icons.person_outline),
                ),
              ],
              selected: {_tipo},
              onSelectionChanged: (s) => setState(() => _tipo = s.first),
            ),
            const SizedBox(height: 20),

            // Color
            Text(
              'Color identificativo',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _mostrarColorPicker,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: _color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.palette_outlined,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '#${_color.value.toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Configuración de empleo (solo visible cuando tipo == empleo)
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _tipo == FuenteTipo.empleo
                  ? _EmpleoConfigSection(
                      salarioCtrl: _salarioCtrl,
                      horasCtrl: _horasCtrl,
                      tarifaExtraCtrl: _tarifaExtraCtrl,
                      diaCobro: _diaCobro,
                      onDiaCobroChanged: (d) => setState(() => _diaCobro = d),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _guardar,
        icon: _loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_outlined),
        label: const Text('Guardar'),
      ),
    );
  }
}

// ── Sección empleoConfig ─────────────────────────────────────────────────────

class _EmpleoConfigSection extends StatelessWidget {
  const _EmpleoConfigSection({
    required this.salarioCtrl,
    required this.horasCtrl,
    required this.tarifaExtraCtrl,
    required this.diaCobro,
    required this.onDiaCobroChanged,
  });

  final TextEditingController salarioCtrl;
  final TextEditingController horasCtrl;
  final TextEditingController tarifaExtraCtrl;
  final int diaCobro;
  final ValueChanged<int> onDiaCobroChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Text(
          'Configuración del empleo',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: salarioCtrl,
          decoration: const InputDecoration(
            labelText: 'Salario base mensual (€)',
            prefixIcon: Icon(Icons.euro_rounded),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Requerido';
            if (double.tryParse(v) == null) return 'Número inválido';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: horasCtrl,
          decoration: const InputDecoration(
            labelText: 'Horas semanales contratadas',
            prefixIcon: Icon(Icons.access_time_rounded),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Requerido';
            if (double.tryParse(v) == null) return 'Número inválido';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: tarifaExtraCtrl,
          decoration: const InputDecoration(
            labelText: 'Tarifa hora extra (€/h)',
            prefixIcon: Icon(Icons.add_circle_outline_rounded),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Requerido';
            if (double.tryParse(v) == null) return 'Número inválido';
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: diaCobro,
          decoration: const InputDecoration(
            labelText: 'Día de cobro mensual',
            prefixIcon: Icon(Icons.calendar_today_rounded),
          ),
          items: List.generate(
            28,
            (i) => DropdownMenuItem(
              value: i + 1,
              child: Text('Día ${i + 1}'),
            ),
          ),
          onChanged: (v) {
            if (v != null) onDiaCobroChanged(v);
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
