import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/models/cobro.dart';
import '../../../../domain/models/evento_calendario.dart';
import '../../../../domain/models/fuente.dart';
import '../../../../domain/models/hora_extra.dart';
import '../../../../domain/models/sesion_realizada.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/theme_provider.dart';

/// Bottom sheet del flujo de 3 toques para registrar una sesión desde el calendario.
///
/// Pasos:
///   1. Confirmar (o cancelar) la sesión
///   2. Revisar / editar el importe
///   3. Indicar si se cobró ahora o queda pendiente
///
/// Al confirmar guarda [SesionRealizada] + [Cobro] automáticamente.
/// Al cancelar, guarda [SesionRealizada] con estado=cancelada (sin cobro).
Future<void> showRegistroSesionSheet(
  BuildContext context,
  EventoCalendario evento,
  DateTime dia,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: _RegistroSesionSheet(evento: evento, dia: dia),
    ),
  );
}

class _RegistroSesionSheet extends ConsumerStatefulWidget {
  const _RegistroSesionSheet({
    required this.evento,
    required this.dia,
  });

  final EventoCalendario evento;
  final DateTime dia;

  @override
  ConsumerState<_RegistroSesionSheet> createState() =>
      _RegistroSesionSheetState();
}

class _RegistroSesionSheetState extends ConsumerState<_RegistroSesionSheet> {
  static const _uuid = Uuid();

  // -1 = eligiendo, 0 = confirmar, 1 = cancelar
  int _step = 0;
  bool _cobradoAhora = false;
  bool _loading = false;

  late final TextEditingController _importeCtrl;

  @override
  void initState() {
    super.initState();
    final tarifaGlobal = ref.read(tarifaGlobalProvider);
    final importe = widget.evento.cobro ?? tarifaGlobal;
    _importeCtrl = TextEditingController(
      text: importe > 0 ? importe.toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    _importeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final evento = widget.evento;
    final color = evento.color;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        left: 20,
        right: 20,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header del evento
          Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(evento.titulo, style: AppTextStyles.titleMedium),
                    Text(
                      '${evento.horaInicio} – ${evento.horaFin} · ${AppDateUtils.formatFullDate(widget.dia)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_step == 0) _buildStepConfirmar(context, evento),
          if (_step == 1) _buildStepImporte(context),
        ],
      ),
    );
  }

  // ── Paso 1: ¿Se realizó la sesión? ───────────────────────────────

  Widget _buildStepConfirmar(BuildContext context, EventoCalendario evento) {
    final yaRegistrada = evento.estaConfirmada;
    final yaCancel = evento.esCancelada;

    if (yaRegistrada || yaCancel) {
      final bgColor = yaCancel
          ? AppColors.error.withValues(alpha: 0.12)
          : AppColors.cobroCobrado.withValues(alpha: 0.12);
      final fgColor = yaCancel ? AppColors.error : AppColors.cobroCobrado;
      final icono = yaCancel ? Icons.cancel_outlined : Icons.check_circle;
      final titulo = yaCancel ? 'Sesión cancelada' : 'Sesión realizada';
      final subtitulo = yaCancel
          ? 'Esta sesión fue marcada como no realizada.'
          : 'Esta sesión ya está registrada como realizada.';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: fgColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icono, color: fgColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo,
                          style: AppTextStyles.titleSmall
                              .copyWith(color: fgColor)),
                      const SizedBox(height: 4),
                      Text(subtitulo,
                          style: AppTextStyles.bodySmall.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          const SizedBox(height: 8),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('¿Qué ocurrió con esta sesión?', style: AppTextStyles.labelMedium),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () {
            if (evento.fuenteTipo == FuenteTipo.empleo) {
              _confirmarSesionEmpleo();
            } else {
              setState(() => _step = 1);
            }
          },
          icon: const Icon(Icons.check),
          label: const Text('Se realizó'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _loading ? null : _marcarCancelada,
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('No se dio — marcar cancelada'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Paso 2: Importe + cobro ───────────────────────────────────────

  Widget _buildStepImporte(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Importe de la sesión', style: AppTextStyles.labelMedium),
        const SizedBox(height: 12),
        TextField(
          controller: _importeCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Importe (€)',
            prefixIcon: Icon(Icons.euro_rounded),
          ),
          autofocus: true,
        ),
        const SizedBox(height: 16),
        Text('¿Cuándo cobras?', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
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
          onSelectionChanged: (s) => setState(() => _cobradoAhora = s.first),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _loading ? null : _confirmarSesion,
          icon: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check),
          label: const Text('Confirmar sesión'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Acciones ──────────────────────────────────────────────────────

  Future<void> _confirmarSesion() async {
    final importeText = _importeCtrl.text.trim();
    final importe = double.tryParse(importeText) ?? 0.0;
    if (importe <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce un importe válido')),
      );
      return;
    }

    setState(() => _loading = true);

    final fechaIso = AppDateUtils.formatIso(widget.dia);
    final evento = widget.evento;

    final sesionId = _uuid.v4();
    final sesion = SesionRealizada(
      id: sesionId,
      alumnoId: evento.alumnoId,
      fuenteId: evento.fuenteId,
      sesionRecurrenteId: evento.sesionRecurrenteId,
      fecha: fechaIso,
      horas: evento.duracionHoras,
      cobro: importe,
      estado: EstadoSesion.confirmada,
    );
    await ref.read(sesionRepositoryProvider).saveSesionRealizada(sesion);

    final cobro = Cobro(
      id: _uuid.v4(),
      sesionId: sesionId,
      alumnoId: evento.alumnoId,
      fuenteId: evento.fuenteId,
      modoCobro: ModoCobro.sesion,
      monto: importe,
      estado: _cobradoAhora ? EstadoCobro.cobrado : EstadoCobro.pendiente,
      fechaCobro: _cobradoAhora ? fechaIso : null,
    );
    await ref.read(cobroRepositoryProvider).saveCobro(cobro);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _cobradoAhora
                ? 'Sesión confirmada y cobrada ${CurrencyUtils.formatCompact(importe)}'
                : 'Sesión confirmada — cobro pendiente',
          ),
        ),
      );
    }
  }

  Future<void> _confirmarSesionEmpleo() async {
    setState(() => _loading = true);

    final fechaIso = AppDateUtils.formatIso(widget.dia);
    final evento = widget.evento;

    // Guardar SesionRealizada (sin cobro económico)
    final sesion = SesionRealizada(
      id: _uuid.v4(),
      alumnoId: evento.alumnoId,
      fuenteId: evento.fuenteId,
      sesionRecurrenteId: evento.sesionRecurrenteId,
      fecha: fechaIso,
      horas: evento.duracionHoras,
      cobro: 0,
      estado: EstadoSesion.confirmada,
    );
    await ref.read(sesionRepositoryProvider).saveSesionRealizada(sesion);

    // Crear HoraExtra automáticamente
    final horaExtra = HoraExtra(
      id: _uuid.v4(),
      fuenteId: evento.fuenteId,
      fecha: fechaIso,
      horas: evento.duracionHoras,
      alumnoId: evento.alumnoId,
      notas: 'Auto - calendario',
    );
    await ref.read(horasExtraRepositoryProvider).saveHoraExtra(horaExtra);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sesión registrada — ${evento.duracionHoras.toStringAsFixed(1)} h añadidas',
          ),
        ),
      );
    }
  }

  Future<void> _marcarCancelada() async {
    setState(() => _loading = true);

    final fechaIso = AppDateUtils.formatIso(widget.dia);
    final evento = widget.evento;

    final sesion = SesionRealizada(
      id: _uuid.v4(),
      alumnoId: evento.alumnoId,
      fuenteId: evento.fuenteId,
      sesionRecurrenteId: evento.sesionRecurrenteId,
      fecha: fechaIso,
      horas: evento.duracionHoras,
      cobro: 0,
      estado: EstadoSesion.cancelada,
    );
    await ref.read(sesionRepositoryProvider).saveSesionRealizada(sesion);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión marcada como cancelada')),
      );
    }
  }
}
