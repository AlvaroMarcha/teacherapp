import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/notification_service.dart';
import '../../../domain/models/nota.dart';
import '../../../domain/models/etiqueta.dart';
import '../../providers/notas_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/theme_provider.dart';

class NotaFormScreen extends ConsumerStatefulWidget {
  const NotaFormScreen({super.key, this.notaId, this.tipoInicial});

  final String? notaId;
  final String? tipoInicial;

  @override
  ConsumerState<NotaFormScreen> createState() => _NotaFormScreenState();
}

class _NotaFormScreenState extends ConsumerState<NotaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _contenidoCtrl = TextEditingController();

  late TipoNota _tipo;
  Prioridad _prioridad = Prioridad.media;
  DateTime? _fechaRecordatorio;
  Recurrencia _recurrencia = Recurrencia.ninguna;
  List<String> _selectedEtiquetaIds = [];
  bool _guardando = false;
  Nota? _existing;

  bool get _isEditing => widget.notaId != null;

  @override
  void initState() {
    super.initState();
    _tipo = widget.tipoInicial == 'recordatorio'
        ? TipoNota.recordatorio
        : TipoNota.nota;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _contenidoCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    if (!_isEditing || _existing != null) return;
    final nota =
        await ref.read(notaRepositoryProvider).getNotaById(widget.notaId!);
    if (nota != null && mounted) {
      setState(() {
        _existing = nota;
        _tituloCtrl.text = nota.titulo;
        _contenidoCtrl.text = nota.contenido;
        _tipo = nota.tipo;
        _prioridad = nota.prioridad;
        _recurrencia = nota.recurrencia;
        _selectedEtiquetaIds = List.from(nota.etiquetaIds);
        if (nota.fechaRecordatorio != null) {
          _fechaRecordatorio = DateTime.tryParse(nota.fechaRecordatorio!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(appLocalizationsProvider);
    final etiquetasAsync = ref.watch(etiquetasProvider);

    // Load existing nota on first build
    if (_isEditing && _existing == null) {
      _loadExisting();
    }

    final esRecordatorio = _tipo == TipoNota.recordatorio;
    final title = _isEditing
        ? (esRecordatorio ? l.editarRecordatorio : l.editarNota)
        : (esRecordatorio ? l.nuevoRecordatorio : l.nuevaNota);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _eliminar,
            ),
          TextButton(
            onPressed: _guardando ? null : _guardar,
            child: Text(l.guardar),
          ),
        ],
      ),
      body: _isEditing && _existing == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Tipo ──
                  Text(l.tipoNota, style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  SegmentedButton<TipoNota>(
                    segments: [
                      ButtonSegment(
                        value: TipoNota.nota,
                        icon: const Icon(Icons.note_outlined),
                        label: Text(l.notasLabel),
                      ),
                      ButtonSegment(
                        value: TipoNota.recordatorio,
                        icon: const Icon(Icons.alarm_outlined),
                        label: Text(l.recordatorios),
                      ),
                    ],
                    selected: {_tipo},
                    onSelectionChanged: (s) => setState(() => _tipo = s.first),
                  ),

                  const SizedBox(height: 16),

                  // ── Título ──
                  TextFormField(
                    controller: _tituloCtrl,
                    decoration: InputDecoration(
                      labelText: l.titulo,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? l.requerido : null,
                  ),

                  const SizedBox(height: 16),

                  // ── Contenido ──
                  TextFormField(
                    controller: _contenidoCtrl,
                    decoration: InputDecoration(
                      labelText: l.contenido,
                      alignLabelWithHint: true,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 5,
                    minLines: 3,
                  ),

                  const SizedBox(height: 16),

                  // ── Prioridad ──
                  Text(l.prioridad, style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  SegmentedButton<Prioridad>(
                    segments: [
                      ButtonSegment(
                        value: Prioridad.baja,
                        label: Text(l.prioridadBaja),
                      ),
                      ButtonSegment(
                        value: Prioridad.media,
                        label: Text(l.prioridadMedia),
                      ),
                      ButtonSegment(
                        value: Prioridad.alta,
                        label: Text(l.prioridadAlta),
                      ),
                    ],
                    selected: {_prioridad},
                    onSelectionChanged: (s) =>
                        setState(() => _prioridad = s.first),
                  ),

                  // ── Fecha recordatorio ──
                  if (_tipo == TipoNota.recordatorio) ...[
                    const SizedBox(height: 24),
                    Text(l.fechaRecordatorio, style: AppTextStyles.labelMedium),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickDateTime,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          suffixIcon: _fechaRecordatorio != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () =>
                                      setState(() => _fechaRecordatorio = null),
                                )
                              : null,
                        ),
                        child: Text(
                          _fechaRecordatorio != null
                              ? _formatDateTime(_fechaRecordatorio!)
                              : l.seleccionaFechaHora,
                          style: _fechaRecordatorio != null
                              ? AppTextStyles.bodyMedium
                              : AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Recurrencia ──
                    Text(l.recurrencia, style: AppTextStyles.labelMedium),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Recurrencia>(
                      initialValue: _recurrencia,
                      borderRadius: BorderRadius.circular(12),
                      items: [
                        DropdownMenuItem(
                          value: Recurrencia.ninguna,
                          child: Text(l.recurrenciaNinguna),
                        ),
                        DropdownMenuItem(
                          value: Recurrencia.diaria,
                          child: Text(l.recurrenciaDiaria),
                        ),
                        DropdownMenuItem(
                          value: Recurrencia.semanal,
                          child: Text(l.recurrenciaSemanal),
                        ),
                        DropdownMenuItem(
                          value: Recurrencia.mensual,
                          child: Text(l.recurrenciaMensual),
                        ),
                      ],
                      onChanged: (v) => setState(
                          () => _recurrencia = v ?? Recurrencia.ninguna),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ── Etiquetas ──
                  Row(
                    children: [
                      Text(l.etiquetas, style: AppTextStyles.labelMedium),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _addEtiqueta,
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(l.nuevaEtiqueta),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  etiquetasAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (etiquetas) {
                      if (etiquetas.isEmpty) return const SizedBox.shrink();
                      return Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: etiquetas.map((e) {
                          final selected = _selectedEtiquetaIds.contains(e.id);
                          final color =
                              Color(int.parse('FF${e.color}', radix: 16));
                          return FilterChip(
                            label: Text(e.nombre),
                            selected: selected,
                            selectedColor: color.withValues(alpha: 0.2),
                            checkmarkColor: color,
                            onSelected: (v) {
                              setState(() {
                                if (v) {
                                  _selectedEtiquetaIds.add(e.id);
                                } else {
                                  _selectedEtiquetaIds.remove(e.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // ── Toggle completada (solo edición) ──
                  if (_isEditing && _existing != null)
                    Card(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      child: SwitchListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(
                          _existing!.completada
                              ? l.marcarPendiente
                              : l.marcarCompletada,
                        ),
                        value: _existing!.completada,
                        onChanged: (v) => setState(() {
                          _existing = _existing!.copyWith(completada: v);
                        }),
                      ),
                    ),

                  if (_guardando)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: const LinearProgressIndicator(),
                    ),
                ],
              ),
            ),
    );
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _fechaRecordatorio ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _fechaRecordatorio != null
          ? TimeOfDay.fromDateTime(_fechaRecordatorio!)
          : TimeOfDay.now(),
    );
    if (time == null || !mounted) return;

    setState(() {
      _fechaRecordatorio = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final repo = ref.read(notaRepositoryProvider);
    final now = DateTime.now().toIso8601String();

    final nota = Nota(
      id: _existing?.id ?? '',
      titulo: _tituloCtrl.text.trim(),
      contenido: _contenidoCtrl.text.trim(),
      tipo: _tipo,
      prioridad: _prioridad,
      fechaRecordatorio: _fechaRecordatorio?.toIso8601String(),
      recurrencia: _recurrencia,
      completada: _existing?.completada ?? false,
      creadaEn: _existing?.creadaEn ?? now,
      etiquetaIds: _selectedEtiquetaIds,
      syncStatus: 'pending',
    );

    final savedId = await repo.saveNota(nota);

    // Schedule notification for recordatorios
    if (_tipo == TipoNota.recordatorio &&
        _fechaRecordatorio != null &&
        !nota.completada) {
      final notifId = savedId.hashCode.abs() % 100000 + 10000;
      await NotificationService.instance.scheduleReminder(
        id: notifId,
        title: nota.titulo,
        body: nota.contenido.isNotEmpty ? nota.contenido : nota.titulo,
        scheduledTime: _fechaRecordatorio!,
      );
    }

    ref.invalidate(notasProvider);
    ref.invalidate(notasByTipoProvider);

    if (mounted) {
      final l = ref.read(appLocalizationsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.notaGuardada)),
      );
      context.pop();
    }
  }

  Future<void> _eliminar() async {
    final l = ref.read(appLocalizationsProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(l.eliminar),
        content: Text('${l.confirmar}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancelar),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.eliminar),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(notaRepositoryProvider).deleteNota(widget.notaId!);

    // Cancel scheduled notification
    final notifId = widget.notaId!.hashCode.abs() % 100000 + 10000;
    await NotificationService.instance.cancelReminder(notifId);

    ref.invalidate(notasProvider);
    ref.invalidate(notasByTipoProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.notaEliminada)),
      );
      context.pop();
    }
  }

  void _addEtiqueta() {
    final l = ref.read(appLocalizationsProvider);
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(l.nuevaEtiqueta),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(hintText: l.nombreEtiqueta),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancelar),
          ),
          TextButton(
            onPressed: () async {
              final nombre = ctrl.text.trim();
              if (nombre.isEmpty) return;
              final repo = ref.read(notaRepositoryProvider);
              final id = await repo.saveEtiqueta(
                Etiqueta(id: '', nombre: nombre),
              );
              _selectedEtiquetaIds.add(id);
              ref.invalidate(etiquetasProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l.guardar),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
