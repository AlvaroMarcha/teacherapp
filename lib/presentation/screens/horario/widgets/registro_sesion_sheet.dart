import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/models/cobro.dart';
import '../../../../domain/models/evento_calendario.dart';
import '../../../../domain/models/fuente.dart';
import '../../../../domain/models/hora_extra.dart';
import '../../../../domain/models/sesion_realizada.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/cobros_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/horas_extra_provider.dart';
import '../../../providers/sesiones_provider.dart';

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
    final l = ref.watch(appLocalizationsProvider);

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

          if (_step == 0) _buildStepConfirmar(context, evento, l),
          if (_step == 1) _buildStepImporte(context, l),
        ],
      ),
    );
  }

  // ── Paso 1: ¿Se realizó la sesión? ───────────────────────────────

  Widget _buildStepConfirmar(BuildContext context, EventoCalendario evento, l) {
    final yaRegistrada = evento.estaConfirmada || evento.estaPendiente;
    final yaCancel = evento.esCancelada;

    if (yaRegistrada || yaCancel) {
      Color bgColor;
      Color fgColor;
      IconData icono;
      String titulo;
      String subtitulo;

      if (yaCancel) {
        bgColor = AppColors.error.withValues(alpha: 0.12);
        fgColor = AppColors.error;
        icono = Icons.cancel_outlined;
        titulo = l.sesionCancelada;
        subtitulo = l.sesionCanceladaDesc;
      } else if (evento.estaPendiente) {
        bgColor = AppColors.warning.withValues(alpha: 0.12);
        fgColor = AppColors.warning;
        icono = Icons.schedule_outlined;
        titulo = l.sesionPendiente;
        // Cambiar mensaje según tipo de fuente
        if (evento.fuenteTipo == FuenteTipo.empleo) {
          subtitulo = 'Esta sesión se registró pero aún no se ha marcado como realizada';
        } else {
          subtitulo = l.sesionPendienteDesc;
        }
      } else {
        bgColor = AppColors.cobroCobrado.withValues(alpha: 0.12);
        fgColor = AppColors.cobroCobrado;
        icono = Icons.check_circle;
        titulo = l.sesionRealizada;
        subtitulo = l.sesionRealizadaDesc;
      }

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
          if (evento.estaPendiente) ...[
            FilledButton.icon(
              onPressed:
                  _loading ? null : () => _marcarCobrado(context, evento),
              icon: const Icon(
                Icons.check_circle_outline,
              ),
              label: Text(
                evento.fuenteTipo == FuenteTipo.empleo
                    ? l.marcarRealizada
                    : l.marcarCobrado,
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 8),
          ],
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.cerrar),
          ),
          const Divider(height: 24),
          TextButton.icon(
            onPressed: () => _eliminarRegistro(context, evento),
            icon: const Icon(Icons.undo_outlined, size: 18),
            label: Text(l.eliminarRegistro),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
          ),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _editarSesion(context, evento),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(l.editar),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _eliminarSesionRecurrente(context, evento),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text(l.eliminarSesion),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.queOcurrioSesion, style: AppTextStyles.labelMedium),
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
          label: Text(l.seRealizo),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _loading ? null : _marcarCancelada,
          icon: const Icon(Icons.cancel_outlined),
          label: Text(l.noSeDioMarcarCancelada),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
          ),
        ),
        const Divider(height: 24),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () => _editarSesion(context, evento),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(l.editar),
              ),
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: () => _eliminarSesionRecurrente(context, evento),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text(l.eliminar),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Paso 2: Importe + cobro ───────────────────────────────────────

  Widget _buildStepImporte(BuildContext context, l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.importeSesion, style: AppTextStyles.labelMedium),
        const SizedBox(height: 12),
        TextField(
          controller: _importeCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l.importeEuro,
            prefixIcon: const Icon(Icons.euro_rounded),
          ),
          autofocus: true,
        ),
        const SizedBox(height: 16),
        Text(l.cuandoCobras, style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
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
          label: Text(l.confirmarSesion),
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
      final l = ref.read(appLocalizationsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.introduceImporteValido)),
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
      estado: _cobradoAhora ? EstadoSesion.confirmada : EstadoSesion.pendiente,
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

    // Invalidar providers para actualizar toda la app
    ref.invalidate(cobrosProvider);
    ref.invalidate(dashboardProvider);

    if (mounted) {
      Navigator.of(context).pop();
      final l = ref.read(appLocalizationsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _cobradoAhora
                ? '${l.sesionConfirmadaCobrada} ${CurrencyUtils.formatCompact(importe)}'
                : l.sesionConfirmadaPendiente,
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

    // Invalidar provider de horas extra para actualizar dashboard
    ref.invalidate(horasExtraProvider);
    ref.invalidate(dashboardProvider);

    if (mounted) {
      Navigator.of(context).pop();
      final l = ref.read(appLocalizationsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l.sesionRegistradaHoras} (${evento.duracionHoras.toStringAsFixed(1)}h)',
          ),
        ),
      );
    }
  }

  Future<void> _eliminarRegistro(
    BuildContext context,
    EventoCalendario evento,
  ) async {
    final l = ref.read(appLocalizationsProvider);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l.eliminarRegistro),
        content: Text(l.confirmarEliminarSesion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(l.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(l.eliminar),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final sesionId = evento.sesionRealizadaId;
    if (sesionId == null) return;

    // Eliminar SesionRealizada
    await ref.read(sesionRepositoryProvider).deleteSesionRealizada(sesionId);

    // Eliminar registros vinculados
    if (evento.fuenteTipo == FuenteTipo.empleo) {
      // Eliminar HoraExtra auto vinculada
      final fechaIso = AppDateUtils.formatIso(widget.dia);
      await ref
          .read(databaseProvider)
          .deleteHoraExtraByFechaAndFuente(fechaIso, evento.fuenteId);
    } else {
      // Eliminar Cobro vinculado
      await ref.read(cobroRepositoryProvider).deleteCobroBySesionId(sesionId);
    }

    // IMPORTANTE: Invalidar providers para forzar actualización en toda la app
    ref.invalidate(cobrosProvider);
    ref.invalidate(dashboardProvider);
    ref.invalidate(horasExtraProvider);

    if (mounted) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l.registroEliminado)),
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

    // No hay cobro ni horas que actualizar, pero invalidamos por si acaso
    // (la UI del calendario se actualiza automáticamente por el stream)

    if (mounted) {
      Navigator.of(context).pop();
      final l = ref.read(appLocalizationsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.sesionMarcadaCancelada)),
      );
    }
  }

  Future<void> _editarSesion(
    BuildContext context,
    EventoCalendario evento,
  ) async {
    final sesionRecId = evento.sesionRecurrenteId;
    if (sesionRecId == null) return;

    final sesion = await ref
        .read(sesionRepositoryProvider)
        .getSesionRecurrenteById(sesionRecId);
    if (sesion == null || !mounted) return;

    Navigator.of(context).pop();
    if (mounted) {
      context.push(AppRoutes.sesionForm, extra: sesion);
    }
  }

  Future<void> _eliminarSesionRecurrente(
    BuildContext context,
    EventoCalendario evento,
  ) async {
    final sesionRecId = evento.sesionRecurrenteId;
    if (sesionRecId == null) return;

    final l = ref.read(appLocalizationsProvider);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l.eliminarSesion),
        content: Text(l.confirmarEliminarSesionCalendario),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(l.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(l.eliminar),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    // 1. Obtener todas las sesiones realizadas asociadas
    final sesionesRealizadas = await ref
        .read(sesionRepositoryProvider)
        .getSesionesRealizadasBySesionRecurrenteId(sesionRecId);

    // 2. Eliminar cobros de cada sesión realizada
    for (final sesion in sesionesRealizadas) {
      await ref.read(cobroRepositoryProvider).deleteCobroBySesionId(sesion.id);
    }

    // 3. Eliminar las sesiones realizadas
    await ref
        .read(sesionRepositoryProvider)
        .deleteSesionesRealizadasBySesionRecurrenteId(sesionRecId);

    // 4. Eliminar la sesión recurrente
    await ref
        .read(sesionRepositoryProvider)
        .deleteSesionRecurrente(sesionRecId);

    // 5. IMPORTANTE: Invalidar providers para forzar actualización en toda la app
    ref.invalidate(cobrosProvider);
    ref.invalidate(dashboardProvider);
    ref.invalidate(horasExtraProvider);

    if (mounted) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l.sesionEliminada)),
      );
    }
  }

  Future<void> _marcarCobrado(
    BuildContext context,
    EventoCalendario evento,
  ) async {
    final sesionId = evento.sesionRealizadaId;
    if (sesionId == null) return;

    setState(() => _loading = true);

    final l = ref.read(appLocalizationsProvider);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      // Caso 1: Sesión de empleo - solo actualizar estado a confirmada
      if (evento.fuenteTipo == FuenteTipo.empleo) {
        final sesion =
            await ref.read(sesionRepositoryProvider).getSesionRealizadaById(sesionId);
        if (sesion != null) {
          await ref.read(sesionRepositoryProvider).saveSesionRealizada(
                sesion.copyWith(estado: EstadoSesion.confirmada),
              );
        }

        // Invalidar providers para actualizar UI
        ref.invalidate(dashboardProvider);
        ref.invalidate(horasExtraProvider);
        ref.invalidate(sesionesRealizadasFechaProvider);

        if (mounted) {
          navigator.pop();
          messenger.showSnackBar(
            SnackBar(content: Text(l.sesionMarcadaRealizada)),
          );
        }
        return;
      }

      // Caso 2: Sesión con cobro (particular/academia) - marcar cobro
      final cobro =
          await ref.read(cobroRepositoryProvider).getCobroBySesionId(sesionId);

      if (cobro == null) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text(l.cobroNoEncontrado)),
          );
        }
        return;
      }

      // Marcar como cobrado (esto también actualiza la sesión)
      await ref.read(cobroRepositoryProvider).marcarCobrado(cobro.id);

      // Invalidar providers para actualizar UI
      ref.invalidate(cobrosProvider);
      ref.invalidate(dashboardProvider);
      ref.invalidate(sesionesRealizadasFechaProvider);

      if (mounted) {
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(content: Text(l.marcarCobrado)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}
