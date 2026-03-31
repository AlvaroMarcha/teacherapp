import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../providers/cobros_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/theme_provider.dart';
import '../../../domain/models/cobro.dart';

class CobroDetalleScreen extends ConsumerWidget {
  const CobroDetalleScreen({super.key, required this.cobroId});

  final String cobroId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cobroAsync = ref.watch(cobroByIdProvider(cobroId));
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
          final pendiente = cobro.estado != EstadoCobro.cobrado;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.importe, style: AppTextStyles.labelMedium),
                      Text(
                        CurrencyUtils.format(cobro.monto),
                        style: AppTextStyles.amountLarge,
                      ),
                      const Divider(height: 24),
                      _Row(l.estado, cobro.estado.value),
                      _Row(l.modo, cobro.modoCobro.value),
                      if (cobro.periodoMes != null)
                        _Row(
                            l.periodo,
                            AppDateUtils.formatMonth(
                                DateTime.parse('${cobro.periodoMes!}-01'))),
                      if (cobro.fechaCobro != null)
                        _Row(
                            l.fechaCobro,
                            AppDateUtils.formatFullDate(
                                DateTime.parse(cobro.fechaCobro!))),
                      if (cobro.montoParcial != null)
                        _Row(
                          l.cobradoParcial,
                          CurrencyUtils.format(cobro.montoParcial!),
                        ),
                      if (cobro.notas.isNotEmpty) _Row(l.notas, cobro.notas),
                    ],
                  ),
                ),
              ),
              if (pendiente) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    await ref
                        .read(cobroRepositoryProvider)
                        .marcarCobrado(cobroId);
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
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
