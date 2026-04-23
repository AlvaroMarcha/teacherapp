import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../domain/models/empleo_nomina.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/fuentes_provider.dart';
import '../../../providers/theme_provider.dart';

/// Dialog para introducir o editar la nómina mensual de una fuente de empleo.
///
/// [fuenteId]       – ID de la fuente.
/// [anio] / [mes]   – Mes a registrar.
/// [salarioDefault] – Valor pre-rellenado (salarioBase de EmpleoConfig).
/// [nominaActual]   – Si ya existe, se muestra para edición.
Future<void> showNominaMensualDialog(
  BuildContext context, {
  required String fuenteId,
  required int anio,
  required int mes,
  required double salarioDefault,
  EmpleoNomina? nominaActual,
}) {
  return showDialog(
    context: context,
    builder: (_) => _NominaMensualDialog(
      fuenteId: fuenteId,
      anio: anio,
      mes: mes,
      salarioDefault: salarioDefault,
      nominaActual: nominaActual,
    ),
  );
}

class _NominaMensualDialog extends ConsumerStatefulWidget {
  const _NominaMensualDialog({
    required this.fuenteId,
    required this.anio,
    required this.mes,
    required this.salarioDefault,
    this.nominaActual,
  });

  final String fuenteId;
  final int anio;
  final int mes;
  final double salarioDefault;
  final EmpleoNomina? nominaActual;

  @override
  ConsumerState<_NominaMensualDialog> createState() =>
      _NominaMensualDialogState();
}

class _NominaMensualDialogState extends ConsumerState<_NominaMensualDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _salarioCtrl;
  late final TextEditingController _notasCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _salarioCtrl = TextEditingController(
      text: widget.nominaActual != null
          ? widget.nominaActual!.salario.toStringAsFixed(2)
          : widget.salarioDefault.toStringAsFixed(2),
    );
    _notasCtrl = TextEditingController(
      text: widget.nominaActual?.notas ?? '',
    );
  }

  @override
  void dispose() {
    _salarioCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final salario = double.parse(
        _salarioCtrl.text.replaceAll(',', '.'),
      );
      final nomina = EmpleoNomina(
        fuenteId: widget.fuenteId,
        anio: widget.anio,
        mes: widget.mes,
        salario: salario,
        notas: _notasCtrl.text.trim(),
        creadaEn:
            widget.nominaActual?.creadaEn ?? DateTime.now().toIso8601String(),
      );
      await ref.read(fuenteRepositoryProvider).saveEmpleoNomina(nomina);
      ref.invalidate(empleoNominaDelMesProvider(
        (fuenteId: widget.fuenteId, anio: widget.anio, mes: widget.mes),
      ));
      ref.invalidate(empleoNominasProvider(widget.fuenteId));
      ref.invalidate(pendienteIntroducirNominaProvider);
      ref.invalidate(dashboardProvider);
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(appLocalizationsProvider);
    final mesLabel =
        DateFormat('MMMM yyyy', ref.watch(localeProvider).locale.toString())
            .format(DateTime(widget.anio, widget.mes));
    final esNueva = widget.nominaActual == null;

    return AlertDialog(
      title: Text(
        '${esNueva ? l.introducirNomina : l.editarNomina} · $mesLabel',
        style: AppTextStyles.titleSmall,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _salarioCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l.salarioDelMes,
                prefixIcon: const Icon(Icons.euro_rounded),
                suffixText: '€',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l.nombreRequerido;
                final n = double.tryParse(v.replaceAll(',', '.'));
                if (n == null || n < 0) return l.nombreRequerido;
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notasCtrl,
              decoration: InputDecoration(
                labelText: l.notasNomina,
                prefixIcon: const Icon(Icons.notes_rounded),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: Text(l.cancelar),
        ),
        FilledButton(
          onPressed: _saving ? null : _guardar,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l.guardar),
        ),
      ],
    );
  }
}
