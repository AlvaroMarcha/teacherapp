import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../providers/alumnos_provider.dart';
import '../../providers/cobros_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/fuentes_provider.dart';
import '../../providers/sesiones_provider.dart';
import '../../providers/theme_provider.dart';
import '../../../domain/models/alumno.dart';
import '../../../domain/models/cobro.dart';
import '../../../domain/models/fuente.dart';
import '../../../domain/models/sesion_realizada.dart';

class CobroDetalleScreen extends ConsumerWidget {
  const CobroDetalleScreen({super.key, required this.cobroId});

  final String cobroId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cobroAsync = ref.watch(cobroByIdProvider(cobroId));
    final alumnosAsync = ref.watch(alumnosProvider);
    final fuentesAsync = ref.watch(fuentesProvider);
    final l = ref.watch(appLocalizationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.detalleCobro)),
      body: cobroAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (cobro) {
          if (cobro == null) {
            return const Center(child: Text('—'));
          }

          // Build lookup maps
          final alumnos = alumnosAsync.valueOrNull ?? [];
          final fuentes = fuentesAsync.valueOrNull ?? [];
          final alumnoMap = {for (final a in alumnos) a.id: a};
          final fuenteMap = {for (final f in fuentes) f.id: f};

          final alumno =
              cobro.alumnoId != null ? alumnoMap[cobro.alumnoId] : null;
          final fuente = fuenteMap[cobro.fuenteId];

          final fuenteTipo = fuente != null ? fuente.tipo.value : 'particular';
          final isDark = Theme.of(context).brightness == Brightness.dark;

          // Obtener fecha de la sesión realizada
          final sesionAsync = cobro.sesionId != null
              ? ref.watch(_sesionRealizadaByIdProvider(cobro.sesionId!))
              : null;
          final fecha = sesionAsync?.valueOrNull?.fecha;

          final pendiente = cobro.estado != EstadoCobro.cobrado;
          final estadoColor = AppColors.forEstadoCobro(cobro.estado.value);
          final estadoBg =
              AppColors.lightForEstadoCobroAdaptive(cobro.estado.value, isDark);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Card del importe con color destacado
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      estadoColor.withOpacity(0.1),
                      estadoColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: estadoColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(l.importe, style: AppTextStyles.labelMedium),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: estadoBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cobro.estado.value,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: estadoColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyUtils.format(cobro.monto),
                      style: AppTextStyles.amountLarge.copyWith(
                        color: estadoColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Información contextual con cards de color
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (fecha != null) ...[
                        _InfoCard(
                          icon: Icons.calendar_today,
                          iconColor: Theme.of(context).colorScheme.primary,
                          iconBg: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          value: AppDateUtils.formatFullDate(
                              DateTime.parse(fecha)),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (alumno != null) ...[
                        _InfoCard(
                          icon: Icons.person,
                          iconColor: Theme.of(context).colorScheme.secondary,
                          iconBg: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.1),
                          value: alumno.nombre,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (fuente != null) ...[
                        _InfoCard(
                          icon: Icons.business,
                          iconColor: AppColors.forFuenteTipo(fuenteTipo),
                          iconBg: AppColors.lightForFuenteTipoAdaptive(
                              fuenteTipo, isDark),
                          value: fuente.nombre,
                        ),
                        const SizedBox(height: 12),
                      ],
                      _InfoCard(
                        icon: Icons.payment,
                        iconColor: Theme.of(context).colorScheme.tertiary,
                        iconBg: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withOpacity(0.1),
                        label: l.modo,
                        value: cobro.modoCobro.value,
                      ),
                    ],
                  ),
                ),
              ),

              // Detalles adicionales (solo si hay)
              if (cobro.periodoMes != null ||
                  cobro.fechaCobro != null ||
                  cobro.montoParcial != null ||
                  cobro.notas.isNotEmpty) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (cobro.periodoMes != null) ...[
                          _DetailRow(
                            l.periodo,
                            AppDateUtils.formatMonth(
                                DateTime.parse('${cobro.periodoMes!}-01')),
                            icon: Icons.access_time,
                          ),
                          if (cobro.fechaCobro != null ||
                              cobro.montoParcial != null ||
                              cobro.notas.isNotEmpty)
                            const SizedBox(height: 8),
                        ],
                        if (cobro.fechaCobro != null) ...[
                          _DetailRow(
                            l.fechaCobro,
                            AppDateUtils.formatFullDate(
                                DateTime.parse(cobro.fechaCobro!)),
                            icon: Icons.check_circle,
                          ),
                          if (cobro.montoParcial != null ||
                              cobro.notas.isNotEmpty)
                            const SizedBox(height: 8),
                        ],
                        if (cobro.montoParcial != null) ...[
                          _DetailRow(
                            l.cobradoParcial,
                            CurrencyUtils.format(cobro.montoParcial!),
                            icon: Icons.attach_money,
                            valueColor: AppColors.success,
                          ),
                          if (cobro.notas.isNotEmpty) const SizedBox(height: 8),
                        ],
                        if (cobro.notas.isNotEmpty) ...[
                          const Divider(height: 24),
                          Text(l.notas, style: AppTextStyles.labelSmall),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              cobro.notas,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              if (pendiente) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    await ref
                        .read(cobroRepositoryProvider)
                        .marcarCobrado(cobroId);
                    ref.invalidate(dashboardProvider);
                    ref.invalidate(sesionesRealizadasFechaProvider);
                    if (context.mounted) context.pop();
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(l.marcarCobrado),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _mostrarDialogParcial(context, ref, cobro),
                  icon: const Icon(Icons.payments_outlined),
                  label: Text(l.registrarCobroParcial),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _mostrarDialogParcial(
    BuildContext context,
    WidgetRef ref,
    Cobro cobro,
  ) async {
    final l = ref.read(appLocalizationsProvider);
    final formKey = GlobalKey<FormState>();
    final importeCtrl = TextEditingController();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.cobroParcialTitle),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: importeCtrl,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l.importeCobrado,
              hintText: '${l.maxLabel} ${CurrencyUtils.format(cobro.monto)}',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.isEmpty) return l.introduceMonto;
              final n = double.tryParse(v);
              if (n == null || n <= 0) return l.numeroInvalido;
              if (n > cobro.monto) {
                return '${l.noPuedeSuperarMonto} ${CurrencyUtils.format(cobro.monto)}';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancelar),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: Text(l.guardar),
          ),
        ],
      ),
    );

    if (confirmar != true || !context.mounted) return;

    final monto = double.parse(importeCtrl.text);
    await ref.read(cobroRepositoryProvider).marcarParcial(cobroId, monto);
    // Invalidate para que el watch se actualice
    ref.invalidate(cobroByIdProvider(cobroId));
    ref.invalidate(dashboardProvider);
    ref.invalidate(sesionesRealizadasFechaProvider);
  }
}

/// Provider para obtener la SesionRealizada por ID del cobro.
final _sesionRealizadaByIdProvider =
    FutureProvider.family<SesionRealizada?, String>((ref, sesionId) {
  return ref.watch(sesionRepositoryProvider).getSesionRealizadaById(sesionId);
});

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null) ...[
                Text(
                  label!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(
    this.label,
    this.value, {
    this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(label, style: AppTextStyles.bodySmall),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: valueColor,
              fontWeight: valueColor != null ? FontWeight.w600 : null,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
